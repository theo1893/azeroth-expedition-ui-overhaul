---------------------------------------------------------------
-- DoiteWarriorMonitors.lua
-- 战士专属监控分组，以及相对 DoiteDPS 时间轴的跟随定位。
-- DoiteAuras 仍负责条件判断和图标显示；两个插件不直接耦合循环逻辑。
---------------------------------------------------------------

local PRESET_VERSION = 6
local FOLLOW_INTERVAL = 0.10

local locale = (GetLocale and GetLocale()) or "zhCN"
local zh = locale == "zhCN" or locale == "zhTW"

local function LocalName(zhName, enName)
  if zh then
    return zhName
  end
  return enName
end

local GROUP_RESOURCE = LocalName("战士手动资源", "Warrior Manual Resources")
local GROUP_EXTERNAL = LocalName("战士外援增益", "Warrior External Effects")
local GROUP_STATUS = LocalName("战士持续状态", "Warrior Active Effects")
local GROUP_MAJOR = LocalName("战士爆发防御", "Warrior Major Effects")
local GROUP_EQUIPMENT = LocalName("战士装备触发", "Warrior Equipment Procs")

-- DoiteDPS 无框时间轴为 318x46；根框架中心就是时间轴中心。
-- 左上槽原为重复的手动资源监控，现专门承载战士收到的外援图腾增益；
-- 这样它们不再与右下角的装备触发共享坐标。
local GROUPS = {
  {
    name = GROUP_EXTERNAL,
    dx = -114,
    dy = 42,
    iconSize = 24,
    spacing = 5,
    limit = 5,
    label = LocalName("外援", "EXTERNAL"),
    labelWidth = zh and 36 or 64,
    labelSide = "TOP",
    labelColor = { 0.30, 0.90, 1.00 },
  },
  {
    name = GROUP_STATUS,
    dx = 35,
    dy = 42,
    iconSize = 24,
    spacing = 5,
    limit = 5,
    leaderId = "battleShout",
    label = LocalName("持续", "STATUS"),
    labelWidth = zh and 36 or 52,
    labelSide = "TOP",
    labelColor = { 0.36, 1.00, 0.55 },
  },
  {
    name = GROUP_MAJOR,
    dx = 25,
    dy = -42,
    iconSize = 24,
    spacing = 5,
    limit = 5,
    leaderId = "retaliation",
    label = LocalName("爆发/防御", "MAJOR"),
    labelWidth = zh and 58 or 52,
    labelSide = "BOTTOM",
    labelColor = { 1.00, 0.38, 0.28 },
  },
  {
    name = GROUP_EQUIPMENT,
    dx = 115,
    dy = -42,
    iconSize = 24,
    spacing = 5,
    limit = 1,
    leaderId = "holyStrength",
    label = LocalName("装备", "GEAR"),
    labelWidth = zh and 36 or 44,
    labelSide = "BOTTOM",
    labelColor = { 0.76, 0.58, 1.00 },
  },
}

if DoiteAurasMonitorLabels
    and DoiteAurasMonitorLabels.Register then
  DoiteAurasMonitorLabels:Register("WARRIOR", GROUPS)
end

local BUFFS = {
  {
    id = "battleShout",
    zhName = "战斗怒吼",
    enName = "Battle Shout",
    group = GROUP_STATUS,
    priority = 1,
    texture = "Interface\\Icons\\Ability_Warrior_BattleShout",
  },
  {
    id = "flurry",
    zhName = "乱舞",
    enName = "Flurry",
    group = GROUP_STATUS,
    priority = 2,
    texture = "Interface\\Icons\\Ability_GhoulFrenzy",
    showStacks = true,
  },
  {
    id = "sweepingStrikes",
    zhName = "横扫攻击",
    enName = "Sweeping Strikes",
    group = GROUP_STATUS,
    priority = 3,
    texture = "Interface\\Icons\\Ability_Rogue_SliceDice",
    showStacks = true,
  },
  {
    id = "bloodFury",
    zhName = "血性狂怒",
    enName = "Blood Fury",
    group = GROUP_STATUS,
    priority = 4,
    texture = "Interface\\Icons\\Racial_Orc_BerserkerStrength",
    orcOnly = true,
    forceTexture = true,
  },
  {
    id = "berserkerRage",
    zhName = "狂暴之怒",
    enName = "Berserker Rage",
    group = GROUP_STATUS,
    priority = 5,
    texture = "Interface\\Icons\\Spell_Nature_AncestralGuardian",
  },
  {
    id = "retaliation",
    zhName = "反击风暴",
    enName = "Retaliation",
    group = GROUP_MAJOR,
    priority = 1,
    texture = "Interface\\Icons\\Ability_Warrior_Challange",
  },
  {
    id = "shieldWall",
    zhName = "盾墙",
    enName = "Shield Wall",
    group = GROUP_MAJOR,
    priority = 2,
    texture = "Interface\\Icons\\Ability_Warrior_ShieldWall",
  },
  {
    id = "recklessness",
    zhName = "鲁莽",
    enName = "Recklessness",
    group = GROUP_MAJOR,
    priority = 3,
    texture = "Interface\\Icons\\Ability_CriticalStrike",
  },
  {
    id = "lastStand",
    zhName = "破釜沉舟",
    enName = "Last Stand",
    group = GROUP_MAJOR,
    priority = 4,
    texture = "Interface\\Icons\\Spell_Holy_AshesToAshes",
  },
  {
    id = "deathWish",
    zhName = "死亡之愿",
    enName = "Death Wish",
    group = GROUP_MAJOR,
    priority = 5,
    texture = "Interface\\Icons\\Spell_Shadow_DeathPact",
  },
  {
    id = "holyStrength",
    zhName = "神圣力量",
    enName = "Holy Strength",
    group = GROUP_EQUIPMENT,
    priority = 1,
    texture = "Interface\\Icons\\Spell_Holy_BlessingOfStrength",
  },
}

local SHAMAN_TOTEM_GROUP_NAMES = {
  "萨满图腾状态",
  "Shaman Totem Effects",
}

local RESOURCE_GROUP_NAMES = {
  "战士手动资源",
  "Warrior Manual Resources",
  "Doite手动资源",
}

local LEGACY_SHAMAN_GROUPS = {
  "Group 1 (4)",
  "Group 2 (4)",
  "Group 4 (2)",
}

local leaderKeys = {}

local function IsWarrior()
  if not UnitClass then
    return false
  end
  local localized, classTag = UnitClass("player")
  classTag = classTag and string.upper(classTag) or ""
  return classTag == "WARRIOR" or localized == "战士"
end

local function IsOrc()
  if not UnitRace then
    return false
  end
  local localized, raceTag = UnitRace("player")
  raceTag = raceTag and string.upper(raceTag) or ""
  return raceTag == "ORC" or localized == "兽人"
end

local function NextOrder()
  local maxOrder = 0
  local _, data
  for _, data in pairs((DoiteAurasDB and DoiteAurasDB.spells) or {}) do
    local order = tonumber(data and data.order) or 0
    if order > maxOrder then
      maxOrder = order
    end
  end
  return maxOrder + 1
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

local function NameMatches(data, target)
  if not data or data.type ~= "Buff" then
    return false
  end
  local name = data.displayName or data.name
  return name == target.zhName or name == target.enName
end

local function FindBuffEntry(target)
  local spells = DoiteAurasDB.spells
  local preferred = {
    target.zhName .. "_Buff",
    target.enName .. "_Buff",
  }
  local i
  for i = 1, table.getn(preferred) do
    local key = preferred[i]
    if NameMatches(spells[key], target) then
      return key, spells[key]
    end
  end

  local key, data
  for key, data in pairs(spells) do
    if NameMatches(data, target) then
      return key, data
    end
  end
  return nil, nil
end

local function IsShamanTotemGroup(groupName)
  local i
  for i = 1, table.getn(SHAMAN_TOTEM_GROUP_NAMES) do
    if groupName == SHAMAN_TOTEM_GROUP_NAMES[i] then
      return true
    end
  end
  return false
end

local function IsManagedExternalBuff(data)
  if not data or data.type ~= "Buff" then
    return false
  end
  if data.doiteWarriorExternalMonitorPreset then
    return true
  end
  return data.doiteShamanMonitorPreset ~= nil
      and IsShamanTotemGroup(data.group)
end

local function IsWindfuryEntry(data)
  local name = data and (data.displayName or data.shownName) or ""
  return name == "风怒图腾效果"
      or name == "Windfury Totem Effect"
      or name == "Windfury Totem"
end

local function SetField(data, key, value)
  if data[key] == value then
    return false
  end
  data[key] = value
  return true
end

local function UniqueBuffKey(target)
  local spells = DoiteAurasDB.spells
  local base = LocalName(target.zhName, target.enName) .. "_Buff"
  if not spells[base] then
    return base
  end

  local index = 2
  local candidate = base .. "#" .. index
  while spells[candidate] do
    index = index + 1
    candidate = base .. "#" .. index
  end
  return candidate
end

local function BuildBuffEntry(key, target, order)
  local displayName = LocalName(target.zhName, target.enName)
  return {
    key = key,
    order = order,
    type = "Buff",
    displayName = displayName,
    shownName = displayName,
    baseKey = displayName .. "_Buff",
    uid = 1,
    iconTexture = target.texture,
    offsetX = 0,
    offsetY = 0,
    iconSize = 24,
    scale = 1,
    alpha = 1,
    group = target.group,
    isLeader = false,
    growth = "水平居中",
    numAuras = 5,
    spacing = 5,
    doiteWarriorMonitorPreset = PRESET_VERSION,
    conditions = {
      aura = {
        mode = "found",
        inCombat = true,
        outCombat = true,
        targetHelp = false,
        targetHarm = false,
        targetSelf = true,
        trackpet = false,
        form = LocalName("所有形态", "All"),
        auraConditions = {},
        vfxConditions = {},
        glow = false,
        greyscale = false,
        fade = false,
        textTimeRemaining = true,
        textStackCounter = target.showStacks == true,
      },
    },
  }
end

local function NormalizeBuffEntry(data, target)
  data.group = target.group
  data.isLeader = false
  data.iconSize = 24
  data.scale = data.scale or 1
  data.alpha = data.alpha or 1
  data.growth = "水平居中"
  data.spacing = 5
  -- 旧的血性狂怒 Buff 条目曾保存为 Ability_Rogue_FeignDeath；
  -- 若保留旧值，_EnsureAuraTexture 会优先采用它。
  if target.forceTexture or not data.iconTexture
      or data.iconTexture == "" then
    data.iconTexture = target.texture
  end
  data.doiteWarriorMonitorPreset = PRESET_VERSION
  data.conditions = data.conditions or {}
  data.conditions.aura = data.conditions.aura or {}

  local aura = data.conditions.aura
  aura.mode = "found"
  aura.inCombat = true
  aura.outCombat = true
  aura.targetHelp = false
  aura.targetHarm = false
  aura.targetSelf = true
  aura.trackpet = false
  aura.form = aura.form or LocalName("所有形态", "All")
  aura.auraConditions = aura.auraConditions or {}
  aura.vfxConditions = aura.vfxConditions or {}
  aura.textTimeRemaining = true
  if target.showStacks == true then
    aura.textStackCounter = true
  end
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

local function RoundTenth(value)
  if value >= 0 then
    return math.floor(value * 10 + 0.5) / 10
  end
  return math.ceil(value * 10 - 0.5) / 10
end

local function SyncAnchors(force)
  if not IsWarrior() or not DoiteAurasDB or not DoiteAurasDB.spells then
    return false
  end
  if DoiteAurasDB.warriorMonitorsFollowDoiteDPS == false then
    return false
  end
  if _G["DoiteEdit_CurrentKey"] and not force then
    return false
  end

  local centerX, centerY, relativeScale = GetTimelineAnchor()
  local changed = false
  local i
  for i = 1, table.getn(GROUPS) do
    local group = GROUPS[i]
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

local function ConfigureExternalGroup(centerX, centerY, relativeScale)
  local group = GROUPS[1]
  local spells = DoiteAurasDB.spells
  local members = {}
  local key, data
  for key, data in pairs(spells) do
    if IsManagedExternalBuff(data) then
      members[table.getn(members) + 1] = {
        key = key,
        data = data,
      }
    end
  end

  table.sort(members, function(a, b)
    local aWindfury = IsWindfuryEntry(a.data)
    local bWindfury = IsWindfuryEntry(b.data)
    if aWindfury ~= bWindfury then
      return aWindfury
    end
    local aOrder = tonumber(a.data and a.data.order) or 999
    local bOrder = tonumber(b.data and b.data.order) or 999
    if aOrder ~= bOrder then
      return aOrder < bOrder
    end
    return tostring(a.key) < tostring(b.key)
  end)

  local changed = false
  if table.getn(members) > 0
      and DoiteAurasDB.groupSort[group.name] == nil then
    DoiteAurasDB.groupSort[group.name] = "prio"
    changed = true
  end
  local i
  for i = 1, table.getn(members) do
    local entry = members[i]
    data = entry.data
    if SetField(data, "group", group.name) then changed = true end
    if SetField(data, "isLeader", i == 1) then changed = true end
    if SetField(data, "iconSize", group.iconSize) then changed = true end
    if SetField(data, "growth", "水平居中") then changed = true end
    if SetField(data, "numAuras", group.limit) then changed = true end
    if SetField(data, "spacing", group.spacing) then changed = true end
    if SetField(
        data,
        "doiteWarriorExternalMonitorPreset",
        PRESET_VERSION
    ) then
      changed = true
    end

    if i == 1 then
      local x = RoundTenth(centerX + group.dx * relativeScale)
      local y = RoundTenth(centerY + group.dy * relativeScale)
      if SetField(data, "point", "CENTER") then changed = true end
      if SetField(data, "relativePoint", "CENTER") then changed = true end
      if SetField(data, "offsetX", x) then changed = true end
      if SetField(data, "offsetY", y) then changed = true end
      leaderKeys[group.name] = entry.key
    end
  end

  if table.getn(members) == 0 then
    leaderKeys[group.name] = nil
  end
  return changed
end

local function ConfigureBuffGroups(centerX, centerY, relativeScale)
  local spells = DoiteAurasDB.spells
  local keysById = {}
  local order = NextOrder()
  local isOrc = IsOrc()
  local i

  for i = 1, table.getn(BUFFS) do
    local target = BUFFS[i]
    if (not target.orcOnly) or isOrc then
      local key, data = FindBuffEntry(target)
      if not data then
        key = UniqueBuffKey(target)
        data = BuildBuffEntry(key, target, order)
        spells[key] = data
        order = order + 1
      end
      NormalizeBuffEntry(data, target)
      keysById[target.id] = key
      DoiteAurasDB.cache[LocalName(target.zhName, target.enName)] =
          data.iconTexture or target.texture
    end
  end

  for i = 2, table.getn(GROUPS) do
    local group = GROUPS[i]
    local leaderKey = keysById[group.leaderId]
    local leader = leaderKey and spells[leaderKey]
    if leader then
      leader.isLeader = true
      leader.iconSize = group.iconSize
      leader.growth = "水平居中"
      leader.numAuras = group.limit
      leader.spacing = group.spacing
      leader.point = "CENTER"
      leader.relativePoint = "CENTER"
      leader.offsetX =
          RoundTenth(centerX + group.dx * relativeScale)
      leader.offsetY =
          RoundTenth(centerY + group.dy * relativeScale)
      leaderKeys[group.name] = leaderKey
    end
  end
end

local function ConfigureBuckets()
  local i
  for i = 1, table.getn(GROUPS) do
    local name = GROUPS[i].name
    DoiteAurasDB.groupSort[name] = "prio"
    DoiteAurasDB.bucketDisabled[name] = nil
    if DoiteGroup and DoiteGroup._sortCache then
      DoiteGroup._sortCache[name] = nil
    end
  end

  -- 这些是当前角色从元素萨满配置继承下来的职业循环组。
  -- 只在战士角色的一次性迁移中禁用；副本减益保持原样。
  for i = 1, table.getn(LEGACY_SHAMAN_GROUPS) do
    DoiteAurasDB.bucketDisabled[LEGACY_SHAMAN_GROUPS[i]] = true
  end

  -- 动作栏已经提供这些技能的冷却反馈，资源组只保留可逆配置，
  -- 不再占用 DDPS 上方的常驻位置。
  DoiteAurasDB.groupSort[GROUP_RESOURCE] = "prio"
  DoiteAurasDB.bucketDisabled[GROUP_RESOURCE] = true
  DoiteAurasDB.groupSort["Doite手动资源"] = nil
  DoiteAurasDB.bucketDisabled["Doite手动资源"] = true

  -- 战士收到的图腾 Buff 已迁入 GROUP_EXTERNAL。禁用原萨满组，
  -- 既避免遗留组长占位，也保证以后新增条目不会回到右下角重叠。
  for i = 1, table.getn(SHAMAN_TOTEM_GROUP_NAMES) do
    DoiteAurasDB.bucketDisabled[SHAMAN_TOTEM_GROUP_NAMES[i]] = true
  end
end

local function EnsureRetiredGroupsDisabled()
  local changed = false
  local i
  for i = 1, table.getn(RESOURCE_GROUP_NAMES) do
    local name = RESOURCE_GROUP_NAMES[i]
    if DoiteAurasDB.bucketDisabled[name] ~= true then
      DoiteAurasDB.bucketDisabled[name] = true
      changed = true
    end
  end
  for i = 1, table.getn(SHAMAN_TOTEM_GROUP_NAMES) do
    local name = SHAMAN_TOTEM_GROUP_NAMES[i]
    if DoiteAurasDB.bucketDisabled[name] ~= true then
      DoiteAurasDB.bucketDisabled[name] = true
      changed = true
    end
  end
  return changed
end

local function InstallPreset()
  if not IsWarrior() then
    return true
  end

  DoiteAurasDB = DoiteAurasDB or {}
  DoiteAurasDB.spells = DoiteAurasDB.spells or {}
  DoiteAurasDB.cache = DoiteAurasDB.cache or {}
  DoiteAurasDB.groupSort = DoiteAurasDB.groupSort or {}
  DoiteAurasDB.bucketDisabled = DoiteAurasDB.bucketDisabled or {}

  if DoiteAurasDB.warriorMonitorsFollowDoiteDPS == nil then
    DoiteAurasDB.warriorMonitorsFollowDoiteDPS = true
  end

  local currentVersion =
      tonumber(DoiteAurasDB.doiteWarriorMonitorPresetVersion) or 0
  local retiredChanged = EnsureRetiredGroupsDisabled()
  local centerX, centerY, relativeScale = GetTimelineAnchor()
  local externalChanged

  if currentVersion < PRESET_VERSION then
    ConfigureBuffGroups(centerX, centerY, relativeScale)
    externalChanged = ConfigureExternalGroup(
        centerX,
        centerY,
        relativeScale
    )
    ConfigureBuckets()
    DoiteAurasDB.doiteWarriorMonitorPresetVersion = PRESET_VERSION
    RefreshPreset()
  else
    -- 每次登录仍收编新出现的萨满图腾 Buff。原萨满组保持禁用，
    -- 因此新增条目至多等待下一次安装，不会重新压到装备触发上。
    externalChanged = ConfigureExternalGroup(
        centerX,
        centerY,
        relativeScale
    )
    if retiredChanged or externalChanged then
      RefreshPreset()
    end
  end
  return true
end

_G["DoiteAuras_InstallWarriorMonitors"] = InstallPreset
_G["DoiteAuras_SyncWarriorMonitorAnchors"] = SyncAnchors

local followFrame = CreateFrame(
    "Frame",
    "DoiteAurasWarriorMonitorFollower"
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
    "DoiteAurasWarriorMonitorInstaller"
)
local pendingDelay = 0
local installElapsed = 0
local attempts = 0

local function QueueInstall(delay)
  if not IsWarrior() then
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
  if InstallPreset() then
    attempts = 0
    this:Hide()
    return
  end

  attempts = attempts + 1
  if attempts >= 8 then
    attempts = 0
    this:Hide()
  else
    pendingDelay = 0.75
  end
end)

QueueInstall(0.30)
