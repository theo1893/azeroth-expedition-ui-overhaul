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
  return "萨满祭司", "SHAMAN"
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

DoiteAurasDB = {
  spells = {
    ["元素掌握"] = {
      type = "Ability",
      displayName = "元素掌握",
      group = "Group 1 (4)",
      isLeader = true,
      iconSize = 25,
      order = 6,
      conditions = {
        ability = {
          mode = "usable",
          slider = true,
        },
      },
    },
    ["风暴之狼的狡诈"] = {
      type = "Buff",
      displayName = "风暴之狼的狡诈",
      group = "Group 1 (4)",
      isLeader = false,
      iconSize = 50,
      order = 9,
      conditions = {
        aura = {
          mode = "found",
          targetSelf = true,
        },
      },
    },
    ["节能施法_Buff#2"] = {
      type = "Buff",
      displayName = "节能施法",
      group = "Group 1 (4)",
      isLeader = false,
      iconSize = 50,
      order = 13,
      conditions = {
        aura = {
          mode = "found",
          targetSelf = true,
          textStackCounter = false,
        },
      },
    },
    ["Seismic Strength_Buff"] = {
      type = "Buff",
      displayName = "Seismic Strength",
      group = "Group 1 (4)",
      isLeader = false,
      iconSize = 50,
      order = 15,
      conditions = {
        aura = {
          mode = "found",
          targetSelf = true,
        },
      },
    },
    ["地震术"] = {
      type = "Ability",
      displayName = "地震术",
      group = "Group 2 (4)",
      isLeader = true,
      iconSize = 28,
      order = 2,
      conditions = {
        ability = {
          mode = "usable",
          slider = true,
          sliderDir = "左",
        },
      },
    },
    ["闪电链"] = {
      type = "Ability",
      displayName = "闪电链",
      group = "Group 2 (4)",
      isLeader = false,
      iconSize = 30,
      order = 30,
      conditions = {
        ability = {
          mode = "usable",
          slider = true,
          sliderDir = "右",
        },
      },
    },
    ["火焰图腾持续时间_Custom"] = {
      type = "Custom",
      displayName = "火焰图腾持续时间",
      group = "Group 2 (4)",
      isLeader = false,
      iconSize = 36,
      order = 70,
      customFunctionSource = "return false",
      conditions = {},
    },
    ["烈焰震击"] = {
      type = "Debuff",
      displayName = "烈焰震击",
      group = "Group 4 (2)",
      isLeader = true,
      iconSize = 28,
      order = 18,
      conditions = {
        aura = {
          mode = "found",
          onlyMine = true,
          targetHarm = true,
        },
      },
    },
    ["风怒图腾效果_Buff"] = {
      type = "Buff",
      displayName = "风怒图腾效果",
      group = "风系图腾",
      isLeader = true,
      iconSize = 26,
      order = 36,
      conditions = {
        aura = {
          mode = "found",
          targetSelf = true,
        },
      },
    },
    ["风之优雅_Buff"] = {
      type = "Buff",
      displayName = "风之优雅",
      group = "风系图腾",
      isLeader = false,
      iconSize = 26,
      order = 37,
    },
    ["风怒图腾效果_全系"] = {
      type = "Buff",
      displayName = "风怒图腾效果",
      group = "全系图腾",
      isLeader = true,
      iconSize = 26,
      order = 36,
    },
    ["星界洞察_Debuff"] = {
      type = "Debuff",
      displayName = "星界洞察",
      group = "K40致命技能",
      isLeader = true,
      iconSize = 60,
      order = 53,
    },
  },
  cache = {},
  groupSort = {
    ["Group 1 (4)"] = "prio",
    ["Group 2 (4)"] = "prio",
    ["Group 4 (2)"] = "prio",
    ["风系图腾"] = "prio",
    ["全系图腾"] = "prio",
    ["K40致命技能"] = "prio",
  },
  bucketDisabled = {
    ["主动饰品"] = true,
    ["全系图腾"] = true,
  },
}

local registeredLabelClass
local registeredLabelGroups
DoiteAurasMonitorLabels = {
  Register = function(_, classTag, groups)
    registeredLabelClass = classTag
    registeredLabelGroups = groups
  end,
}

dofile("DoiteAuras/Modules/DoiteShamanMonitors.lua")

Check(registeredLabelClass == "SHAMAN", "Shaman labels were not registered")
Check(
    registeredLabelGroups and table.getn(registeredLabelGroups) == 5,
    "Shaman should register five monitor group labels"
)
Check(
    registeredLabelGroups[1].label == "爆发"
        and registeredLabelGroups[1].labelSide == "TOP",
    "Shaman burst label configuration is wrong"
)
Check(
    registeredLabelGroups[5].label == "图腾"
        and registeredLabelGroups[5].labelSide == "BOTTOM",
    "Shaman totem label configuration is wrong"
)

Check(
    DoiteAuras_InstallShamanMonitors() == true,
    "Shaman monitor preset should install"
)
Check(
    DoiteAurasDB.doiteShamanMonitorPresetVersion == 3,
    "Shaman preset marker missing"
)
Check(
    DoiteAurasDB.shamanMonitorsFollowDoiteDPS == true,
    "DoiteDPS following should default to enabled"
)

local elementalMastery = DoiteAurasDB.spells["元素掌握"]
local clearcasting = DoiteAurasDB.spells["节能施法_Buff#2"]
local stormwolf = DoiteAurasDB.spells["风暴之狼的狡诈"]
local seismic = DoiteAurasDB.spells["Seismic Strength_Buff"]
local earthquake = DoiteAurasDB.spells["地震术"]
local chainLightning = DoiteAurasDB.spells["闪电链"]
local flameShock = DoiteAurasDB.spells["烈焰震击"]
local fireTotem = DoiteAurasDB.spells["火焰图腾持续时间_Custom"]
local windfury = DoiteAurasDB.spells["风怒图腾效果_Buff"]
local graceOfAir = DoiteAurasDB.spells["风之优雅_Buff"]
local disabledTotem = DoiteAurasDB.spells["风怒图腾效果_全系"]

Check(
    elementalMastery.group == "萨满手动爆发",
    "Elemental Mastery group migration failed"
)
Check(elementalMastery.isLeader == true, "Elemental Mastery should lead burst")
Check(
    clearcasting.group == "萨满触发增益",
    "Clearcasting group migration failed"
)
Check(clearcasting.isLeader == true, "Clearcasting should lead proc effects")
Check(
    clearcasting.conditions.aura.textStackCounter == true,
    "Clearcasting should show its remaining charges"
)
Check(
    clearcasting.type == "Custom"
        and clearcasting.doiteRealClearcasting == 3,
    "Clearcasting should use the real-rank custom monitor"
)
Check(
    type(clearcasting.customFunctionSource) == "string"
        and string.find(
            clearcasting.customFunctionSource,
            "DoiteAuras_GetRealClearcastingRank",
            1,
            true
        ),
    "Clearcasting custom monitor should use the corrected rank provider"
)

local trackedClearcastingRank = 2
EleDPS_GetClearcastingRank = function()
  return trackedClearcastingRank
end
DoiteAuras_GetPlayerAuraRemainingSeconds = function()
  return 7.25
end
local sourceLoader = loadstring or load
local sourceChunk = assert(sourceLoader(
    "return function(data)\n"
        .. clearcasting.customFunctionSource
        .. "\nend"
))
local clearcastingFunction = sourceChunk()
local ccShow, ccTexture, ccHideBackground, ccRemaining, ccStacks =
    clearcastingFunction({})
Check(
    ccShow == true and ccStacks == 2,
    "real Clearcasting rank 2 should show two effective charges"
)
Check(
    ccTexture == "Interface\\Icons\\Spell_Shadow_ManaBurn"
        and ccHideBackground == false,
    "real Clearcasting monitor should preserve its icon"
)
Check(
    ccRemaining == 7.25,
    "real Clearcasting monitor should preserve duration text"
)

trackedClearcastingRank = 0
ccShow, _, _, ccRemaining, ccStacks = clearcastingFunction({})
Check(
    ccShow == false and ccStacks == 0 and ccRemaining == nil,
    "ghost client rank 1 should hide when the effective rank is zero"
)

EleDPS_GetClearcastingRank = nil
UnitBuff = function(_, index)
  if index == 1 then
    return "Interface\\Icons\\Spell_Shadow_ManaBurn", 1
  end
  return nil
end
ccShow, _, _, _, ccStacks = clearcastingFunction({})
Check(
    ccShow == true and ccStacks == 1,
    "Clearcasting monitor should fall back to the client aura without DoiteDPS"
)
Check(stormwolf.group == "萨满触发增益", "Stormwolf proc group failed")
Check(seismic.group == "萨满触发增益", "Seismic Strength group failed")
Check(clearcasting.order < stormwolf.order, "Clearcasting should sort first")
Check(
    earthquake.group == "萨满技能冷却",
    "Earthquake cooldown group failed"
)
Check(earthquake.isLeader == true, "Earthquake should lead cooldowns")
Check(chainLightning.group == "萨满技能冷却", "Chain Lightning group failed")
Check(
    earthquake.conditions.ability.sliderDir == "左",
    "existing Earthquake behavior should be preserved"
)
Check(
    flameShock.group == "萨满目标状态",
    "Flame Shock target group failed"
)
Check(flameShock.isLeader == true, "Flame Shock should lead target effects")
Check(fireTotem.group == "萨满图腾状态", "Fire Totem group failed")
Check(fireTotem.isLeader == true, "Fire Totem should lead totem effects")
Check(windfury.group == "萨满图腾状态", "Windfury Totem group failed")
Check(windfury.isLeader == false, "Windfury Totem should follow Fire Totem")
Check(graceOfAir.group == "萨满图腾状态", "Grace of Air group failed")
Check(
    windfury.conditions.aura.targetSelf == true,
    "existing Windfury trigger logic should be preserved"
)
Check(
    fireTotem.customFunctionSource == "return false",
    "custom Fire Totem logic should be preserved"
)
Check(elementalMastery.iconSize == 24, "Shaman groups should be compact")
Check(clearcasting.iconSize == 24, "proc effects should be compact")

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
    DoiteAurasDB.groupSort["Group 1 (4)"] == nil,
    "legacy group sort metadata should be removed"
)
Check(
    DoiteAurasDB.bucketDisabled["萨满触发增益"] == nil,
    "new proc group should be enabled"
)
Check(
    DoiteAurasDB.groupSort["萨满目标状态"] == "prio",
    "new target group should use priority order"
)
Check(
    DoiteAurasDB.groupSort["萨满图腾状态"] == "prio",
    "new totem group should use priority order"
)
Check(
    DoiteAurasDB.bucketDisabled["风系图腾"] == true,
    "legacy Wind Totem group should be disabled"
)
Check(
    DoiteAurasDB.groupSort["风系图腾"] == nil,
    "legacy Wind Totem sort metadata should be removed"
)
Check(
    disabledTotem.group == "全系图腾"
        and DoiteAurasDB.bucketDisabled["全系图腾"] == true,
    "disabled all-totem duplicate group should remain untouched"
)
Check(
    DoiteAurasDB.spells["星界洞察_Debuff"].group == "K40致命技能",
    "raid danger group should remain untouched"
)
Check(
    DoiteAurasDB.bucketDisabled["主动饰品"] == true,
    "unrelated disabled groups should remain untouched"
)

Check(
    elementalMastery.offsetX == -114
        and elementalMastery.offsetY == -83,
    "burst group should sit above the DoiteDPS ready slot"
)
Check(
    clearcasting.offsetX == 35 and clearcasting.offsetY == -83,
    "proc group should sit above the DoiteDPS timeline"
)
Check(
    earthquake.offsetX == -105 and earthquake.offsetY == -167,
    "cooldown group should sit below the timeline on the left"
)
Check(
    flameShock.offsetX == -15 and flameShock.offsetY == -167,
    "target group should sit below the timeline in the middle"
)
Check(
    fireTotem.offsetX == 95 and fireTotem.offsetY == -167,
    "totem group should sit below the timeline on the right"
)
Check(refreshCount == 4, "install should refresh all consumers once")

local beforeClearcasting = clearcasting
Check(
    DoiteAuras_InstallShamanMonitors() == true,
    "second install should be idempotent"
)
Check(
    DoiteAurasDB.spells["节能施法_Buff#2"] == beforeClearcasting,
    "second install should preserve migrated entries"
)
Check(refreshCount == 4, "second install should not refresh")

DoiteDPSMainFrame.centerX = 530
DoiteDPSMainFrame.centerY = 290
Check(
    DoiteAuras_SyncShamanMonitorAnchors() == true,
    "anchor sync should detect DoiteDPS movement"
)
Check(
    elementalMastery.offsetX == -84
        and elementalMastery.offsetY == -68,
    "burst group should follow DoiteDPS"
)
Check(
    clearcasting.offsetX == 65 and clearcasting.offsetY == -68,
    "proc group should follow DoiteDPS"
)
Check(
    earthquake.offsetX == -75 and earthquake.offsetY == -152,
    "cooldown group should follow DoiteDPS"
)
Check(
    flameShock.offsetX == 15 and flameShock.offsetY == -152,
    "target group should follow DoiteDPS"
)
Check(
    fireTotem.offsetX == 125 and fireTotem.offsetY == -152,
    "totem group should follow DoiteDPS"
)
Check(reflowCount == 2, "movement should request exactly one reflow")
Check(
    DoiteAuras_SyncShamanMonitorAnchors() == false,
    "unchanged position should not reflow"
)

DoiteEdit_CurrentKey = "节能施法_Buff#2"
DoiteDPSMainFrame.centerX = 550
Check(
    DoiteAuras_SyncShamanMonitorAnchors() == false,
    "normal sync should pause while an aura is being edited"
)
Check(clearcasting.offsetX == 65, "editor pause should preserve position")
Check(
    DoiteAuras_SyncShamanMonitorAnchors(true) == true,
    "forced sync should bypass the editor pause"
)
Check(clearcasting.offsetX == 85, "forced sync should update position")
DoiteEdit_CurrentKey = nil

DoiteDPSMainFrame.centerY = 300
arg1 = 0.11
this = frames.DoiteAurasShamanMonitorFollower
frames.DoiteAurasShamanMonitorFollower.scripts.OnUpdate()
Check(
    clearcasting.offsetY == -58,
    "follower heartbeat should track DoiteDPS automatically"
)

DoiteAurasDB.shamanMonitorsFollowDoiteDPS = false
DoiteDPSMainFrame.centerX = 600
Check(
    DoiteAuras_SyncShamanMonitorAnchors() == false,
    "disabled following should not move groups"
)
Check(clearcasting.offsetX == 85, "disabled following should preserve anchors")

print(
    "DoiteShamanMonitors_spec: "
        .. checkCount
        .. " checks passed"
)
