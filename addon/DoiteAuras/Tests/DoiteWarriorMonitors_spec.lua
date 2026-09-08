local checkCount = 0
local function Check(value, message)
  if not value then
    error(message or "check failed", 2)
  end
  checkCount = checkCount + 1
end

table.getn = table.getn or function(value)
  return #value
end

local frames = {}
CreateFrame = function(_, name)
  local frame = {
    shown = true,
    scripts = {},
  }
  function frame:RegisterEvent() end
  function frame:SetScript(scriptName, handler)
    self.scripts[scriptName] = handler
  end
  function frame:Show()
    self.shown = true
  end
  function frame:Hide()
    self.shown = false
  end
  frames[name] = frame
  return frame
end

GetLocale = function()
  return "zhCN"
end
UnitClass = function()
  return "战士", "WARRIOR"
end
UnitRace = function()
  return "兽人", "ORC"
end

UIParent = {
  centerX = 500,
  centerY = 400,
  scale = 1,
}
function UIParent:GetCenter()
  return self.centerX, self.centerY
end
function UIParent:GetEffectiveScale()
  return self.scale
end

DoiteDPSMainFrame = {
  centerX = 500,
  centerY = 275,
  scale = 1,
}
function DoiteDPSMainFrame:GetCenter()
  return self.centerX, self.centerY
end
function DoiteDPSMainFrame:GetEffectiveScale()
  return self.scale
end

local refreshCount = 0
local reflowCount = 0
DoiteAuras_RefreshList = function()
  refreshCount = refreshCount + 1
end
DoiteAuras_RefreshIcons = function()
  refreshCount = refreshCount + 1
end
DoiteConditions_RequestEvaluate = function()
  refreshCount = refreshCount + 1
end
DoiteGroup = {
  _sortCache = {},
  RequestReflow = function()
    refreshCount = refreshCount + 1
    reflowCount = reflowCount + 1
  end,
}

local resourceInstallCount = 0
DoiteAuras_InstallWarriorResourceMonitors = function()
  resourceInstallCount = resourceInstallCount + 1
  return true
end

DoiteAurasDB = {
  spells = {
    DoiteResource_Bloodrage = {
      type = "Ability",
      displayName = "血性狂暴",
      group = "Doite手动资源",
      isLeader = true,
      iconSize = 26,
      order = 72,
    },
    DoiteResource_BloodFury = {
      type = "Ability",
      displayName = "血性狂怒",
      group = "Doite手动资源",
      isLeader = false,
      iconSize = 26,
      order = 73,
    },
    DoiteResource_BerserkerRage = {
      type = "Ability",
      displayName = "狂暴之怒",
      group = "战士手动资源",
      isLeader = false,
      iconSize = 26,
      order = 74,
    },
    DoiteResource_Recklessness = {
      type = "Ability",
      displayName = "鲁莽",
      group = "战士手动资源",
      isLeader = false,
      iconSize = 26,
      order = 75,
    },
    DoiteResource_DeathWish = {
      type = "Ability",
      displayName = "死亡之愿",
      group = "战士手动资源",
      isLeader = false,
      iconSize = 26,
      order = 76,
    },
    ["战斗怒吼_Buff"] = {
      key = "战斗怒吼_Buff",
      type = "Buff",
      displayName = "战斗怒吼",
      group = "Group 1 (4)",
      isLeader = false,
      iconSize = 36,
      order = 71,
      conditions = {
        aura = {
          mode = "found",
          targetSelf = true,
        },
      },
    },
    ["横扫攻击_Buff"] = {
      key = "横扫攻击_Buff",
      type = "Buff",
      displayName = "横扫攻击",
      group = "Group 1 (4)",
      isLeader = false,
      iconSize = 36,
      order = 72,
      conditions = {
        aura = {
          mode = "found",
          targetSelf = true,
          textStackCounter = false,
        },
      },
    },
    ["血性狂怒_Buff"] = {
      key = "血性狂怒_Buff",
      type = "Buff",
      displayName = "血性狂怒",
      group = "种族技能",
      isLeader = false,
      iconSize = 36,
      iconTexture = "Interface\\Icons\\Ability_Rogue_FeignDeath",
      order = 35,
      conditions = {
        aura = {
          mode = "found",
          targetSelf = true,
        },
      },
    },
    ["神圣力量_Buff"] = {
      key = "神圣力量_Buff",
      type = "Buff",
      displayName = "神圣力量",
      group = "装备触发",
      isLeader = false,
      iconSize = 36,
      order = 59,
      conditions = {
        aura = {
          mode = "found",
          targetSelf = true,
        },
      },
    },
    ["风怒图腾效果_Buff"] = {
      key = "风怒图腾效果_Buff",
      type = "Buff",
      displayName = "风怒图腾效果",
      group = "萨满图腾状态",
      isLeader = false,
      iconSize = 24,
      order = 36,
      doiteShamanMonitorPreset = 2,
      conditions = {
        aura = {
          mode = "found",
          targetSelf = true,
        },
      },
    },
    ["风之优雅_Buff"] = {
      key = "风之优雅_Buff",
      type = "Buff",
      displayName = "风之优雅",
      group = "萨满图腾状态",
      isLeader = false,
      iconSize = 24,
      order = 37,
      doiteShamanMonitorPreset = 2,
      conditions = {
        aura = {
          mode = "found",
          targetSelf = true,
        },
      },
    },
    ["火焰图腾持续时间_Custom"] = {
      key = "火焰图腾持续时间_Custom",
      type = "Custom",
      displayName = "火焰图腾持续时间",
      group = "萨满图腾状态",
      isLeader = true,
      iconSize = 24,
      order = 19,
      doiteShamanMonitorPreset = 3,
    },
  },
  cache = {
    ["血性狂怒"] = "Interface\\Icons\\Ability_Rogue_FeignDeath",
  },
  groupSort = {
    ["Doite手动资源"] = "prio",
    ["Group 1 (4)"] = "prio",
    ["Group 2 (4)"] = "prio",
    ["Group 4 (2)"] = "prio",
  },
  bucketDisabled = {
    ["种族技能"] = true,
    ["装备触发"] = true,
  },
  doiteWarriorMonitorPresetVersion = 4,
}

local registeredLabelClass
local registeredLabelGroups
DoiteAurasMonitorLabels = {
  Register = function(_, classTag, groups)
    registeredLabelClass = classTag
    registeredLabelGroups = groups
  end,
}

dofile("DoiteAuras/Modules/DoiteWarriorMonitors.lua")

Check(registeredLabelClass == "WARRIOR", "Warrior labels were not registered")
Check(
    registeredLabelGroups and table.getn(registeredLabelGroups) == 4,
    "Warrior should register four monitor group labels"
)
Check(
    registeredLabelGroups[1].label == "外援"
        and registeredLabelGroups[1].labelSide == "TOP"
        and registeredLabelGroups[1].limit == 5,
    "Warrior external-effect label configuration is wrong"
)
Check(
    registeredLabelGroups[3].label == "爆发/防御"
        and registeredLabelGroups[3].labelSide == "BOTTOM",
    "Warrior major-effect label configuration is wrong"
)

Check(
    DoiteAuras_InstallWarriorMonitors() == true,
    "warrior monitor preset should install"
)
Check(
    resourceInstallCount == 0,
    "retired resource preset must not be installed by the warrior layout"
)
Check(
    DoiteAurasDB.doiteWarriorMonitorPresetVersion == 6,
    "warrior preset marker missing"
)
Check(
    DoiteAurasDB.warriorMonitorsFollowDoiteDPS == true,
    "DoiteDPS following should default to enabled"
)

local bloodrage = DoiteAurasDB.spells.DoiteResource_Bloodrage
local bloodFury = DoiteAurasDB.spells.DoiteResource_BloodFury
Check(
    bloodrage.group == "Doite手动资源"
        and bloodrage.iconSize == 26
        and bloodFury.group == "Doite手动资源",
    "retirement should preserve legacy resource entries without relayout"
)

local battleShout = DoiteAurasDB.spells["战斗怒吼_Buff"]
local flurry = DoiteAurasDB.spells["乱舞_Buff"]
local sweeping = DoiteAurasDB.spells["横扫攻击_Buff"]
local bloodFuryBuff = DoiteAurasDB.spells["血性狂怒_Buff"]
local berserkerBuff = DoiteAurasDB.spells["狂暴之怒_Buff"]
Check(battleShout.group == "战士持续状态", "Battle Shout migration failed")
Check(battleShout.isLeader == true, "Battle Shout should lead status group")
Check(battleShout.numAuras == 5, "status group should allow five effects")
Check(flurry.group == "战士持续状态", "Flurry monitor missing")
Check(
    flurry.conditions.aura.textStackCounter == true,
    "Flurry should show its remaining attacks"
)
Check(
    flurry.iconTexture == "Interface\\Icons\\Ability_GhoulFrenzy",
    "Flurry should use the warrior Flurry texture"
)
Check(sweeping.group == "战士持续状态", "Sweeping Strikes monitor missing")
Check(
    sweeping.conditions.aura.textStackCounter == true,
    "Sweeping Strikes should show its remaining charges"
)
Check(
    battleShout.conditions.aura.textStackCounter ~= true,
    "ordinary active effects should not show a redundant stack count"
)
Check(bloodFuryBuff.group == "战士持续状态", "Blood Fury buff migration failed")
Check(
    bloodFuryBuff.iconTexture
        == "Interface\\Icons\\Racial_Orc_BerserkerStrength",
    "Blood Fury buff should replace the legacy Feign Death icon"
)
Check(
    DoiteAurasDB.cache["血性狂怒"]
        == "Interface\\Icons\\Racial_Orc_BerserkerStrength",
    "Blood Fury texture cache should also be corrected"
)
Check(berserkerBuff.group == "战士持续状态", "Berserker Rage buff missing")
Check(
    battleShout.conditions.aura.textTimeRemaining == true,
    "active effects should show remaining time"
)

local retaliation = DoiteAurasDB.spells["反击风暴_Buff"]
Check(retaliation ~= nil, "Retaliation monitor missing")
Check(retaliation.group == "战士爆发防御", "major-effect group failed")
Check(retaliation.isLeader == true, "Retaliation should lead major effects")
Check(DoiteAurasDB.spells["盾墙_Buff"] ~= nil, "Shield Wall monitor missing")
local recklessnessBuff = DoiteAurasDB.spells["鲁莽_Buff"]
local deathWishBuff = DoiteAurasDB.spells["死亡之愿_Buff"]
Check(recklessnessBuff ~= nil, "Recklessness monitor missing")
Check(DoiteAurasDB.spells["破釜沉舟_Buff"] ~= nil, "Last Stand monitor missing")
Check(deathWishBuff ~= nil, "Death Wish monitor missing")
Check(
    recklessnessBuff.group == "战士爆发防御"
        and recklessnessBuff.conditions.aura.textTimeRemaining == true,
    "Recklessness buff should show its active duration"
)
Check(
    deathWishBuff.group == "战士爆发防御"
        and deathWishBuff.conditions.aura.textTimeRemaining == true,
    "Death Wish buff should show its active duration"
)

local holyStrength = DoiteAurasDB.spells["神圣力量_Buff"]
Check(
    holyStrength.group == "战士装备触发",
    "Holy Strength migration failed"
)
Check(holyStrength.isLeader == true, "Holy Strength should lead equipment")

local windfury = DoiteAurasDB.spells["风怒图腾效果_Buff"]
local graceOfAir = DoiteAurasDB.spells["风之优雅_Buff"]
local fireTotem =
    DoiteAurasDB.spells["火焰图腾持续时间_Custom"]
Check(
    windfury.group == "战士外援增益"
        and windfury.isLeader == true,
    "received Windfury should lead the dedicated external-effect group"
)
Check(
    graceOfAir.group == "战士外援增益"
        and graceOfAir.isLeader == false,
    "other received totem effects should share the safe external group"
)
Check(
    windfury.numAuras == 5
        and windfury.iconSize == 24
        and windfury.spacing == 5,
    "external effects should use one bounded centered layout"
)
Check(
    fireTotem.group == "萨满图腾状态",
    "Shaman-only custom totem timer should not become a Warrior buff"
)

Check(
    DoiteAurasDB.bucketDisabled["Group 1 (4)"] == true,
    "legacy Shaman group 1 should be disabled"
)
Check(
    DoiteAurasDB.bucketDisabled["Group 2 (4)"] == true,
    "legacy Shaman group 2 should be disabled"
)
Check(
    DoiteAurasDB.bucketDisabled["Group 4 (2)"] == true,
    "legacy Shaman group 4 should be disabled"
)
Check(
    DoiteAurasDB.bucketDisabled["战士手动资源"] == true,
    "manual resource group should be retired"
)
Check(
    DoiteAurasDB.bucketDisabled["Doite手动资源"] == true,
    "legacy manual resource group should also be retired"
)
Check(
    DoiteAurasDB.bucketDisabled["萨满图腾状态"] == true,
    "source Shaman totem group should be disabled on Warriors"
)
Check(
    DoiteAurasDB.bucketDisabled["战士外援增益"] == nil,
    "migrated external-effect group should remain enabled"
)
Check(
    DoiteAurasDB.bucketDisabled["战士持续状态"] == nil,
    "new status group should be enabled"
)
Check(
    DoiteAurasDB.groupSort["战士爆发防御"] == "prio",
    "major effects should use priority order"
)
Check(
    DoiteAurasDB.groupSort["Doite手动资源"] == nil,
    "legacy resource group metadata should be removed"
)

Check(
    windfury.offsetX == -114 and windfury.offsetY == -83,
    "external effects should occupy the retired resource slot"
)
Check(
    battleShout.offsetX == 35 and battleShout.offsetY == -83,
    "status group should sit above the DoiteDPS timeline"
)
Check(
    retaliation.offsetX == 25 and retaliation.offsetY == -167,
    "major effects should sit below the DoiteDPS timeline"
)
Check(
    holyStrength.offsetX == 115 and holyStrength.offsetY == -167,
    "equipment effects should sit at the lower right"
)
Check(
    math.abs(windfury.offsetY - holyStrength.offsetY) >= 29,
    "external and equipment groups must have non-overlapping lanes"
)
Check(refreshCount == 4, "install should refresh all consumers once")

local beforeBattleShout = battleShout
Check(
    DoiteAuras_InstallWarriorMonitors() == true,
    "second install should be idempotent"
)
Check(
    DoiteAurasDB.spells["战斗怒吼_Buff"] == beforeBattleShout,
    "second install should preserve migrated entries"
)
Check(resourceInstallCount == 0, "retired resource installer must remain unused")
Check(refreshCount == 4, "second install should not refresh")

local natureResistance = {
  key = "自然抗性_Buff",
  type = "Buff",
  displayName = "自然抗性",
  group = "萨满图腾状态",
  isLeader = false,
  iconSize = 24,
  order = 38,
  doiteShamanMonitorPreset = 3,
}
DoiteAurasDB.spells["自然抗性_Buff"] = natureResistance
Check(
    DoiteAuras_InstallWarriorMonitors() == true,
    "current preset should adopt a newly introduced totem effect"
)
Check(
    natureResistance.group == "战士外援增益"
        and natureResistance.isLeader == false,
    "future totem effects must join the collision-safe group"
)
Check(
    DoiteAurasDB.bucketDisabled["萨满图腾状态"] == true,
    "source group must stay disabled after future adoption"
)
Check(refreshCount == 8, "future adoption should refresh all consumers once")
Check(
    DoiteAuras_InstallWarriorMonitors() == true,
    "future adoption should become idempotent"
)
Check(refreshCount == 8, "settled future entry should not refresh again")

DoiteDPSMainFrame.centerX = 530
DoiteDPSMainFrame.centerY = 290
Check(
    DoiteAuras_SyncWarriorMonitorAnchors() == true,
    "anchor sync should detect DoiteDPS movement"
)
Check(
    windfury.offsetX == -84 and windfury.offsetY == -68,
    "external-effect group should follow DoiteDPS"
)
Check(
    battleShout.offsetX == 65 and battleShout.offsetY == -68,
    "status group should follow DoiteDPS"
)
Check(
    retaliation.offsetX == 55 and retaliation.offsetY == -152,
    "major group should follow DoiteDPS"
)
Check(
    holyStrength.offsetX == 145 and holyStrength.offsetY == -152,
    "equipment group should follow DoiteDPS"
)
Check(reflowCount == 3, "movement should request exactly one reflow")
Check(
    DoiteAuras_SyncWarriorMonitorAnchors() == false,
    "unchanged position should not reflow"
)
Check(reflowCount == 3, "unchanged sync should preserve reflow count")

DoiteEdit_CurrentKey = "战斗怒吼_Buff"
DoiteDPSMainFrame.centerX = 550
Check(
    DoiteAuras_SyncWarriorMonitorAnchors() == false,
    "normal sync should pause while an aura is being edited"
)
Check(battleShout.offsetX == 65, "editor pause should preserve position")
Check(
    DoiteAuras_SyncWarriorMonitorAnchors(true) == true,
    "forced sync should bypass the editor pause"
)
Check(battleShout.offsetX == 85, "forced sync should update position")
DoiteEdit_CurrentKey = nil

DoiteDPSMainFrame.centerY = 300
arg1 = 0.11
this = frames.DoiteAurasWarriorMonitorFollower
frames.DoiteAurasWarriorMonitorFollower.scripts.OnUpdate()
Check(
    battleShout.offsetY == -58,
    "follower heartbeat should track DoiteDPS automatically"
)

DoiteAurasDB.warriorMonitorsFollowDoiteDPS = false
DoiteDPSMainFrame.centerX = 600
Check(
    DoiteAuras_SyncWarriorMonitorAnchors() == false,
    "disabled following should not move groups"
)
Check(battleShout.offsetX == 85, "disabled following should preserve anchors")

print(
    "DoiteWarriorMonitors_spec: "
        .. checkCount
        .. " checks passed"
)
