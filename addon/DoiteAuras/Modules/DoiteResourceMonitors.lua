---------------------------------------------------------------
-- DoiteResourceMonitors.lua
-- 战士手动资源监控退役迁移：
--   * 不再创建血性狂暴、种族技能或长冷却的额外图标
--   * 已有托管条目保留在 SavedVariables 中，但对应组默认禁用
--   * 动作栏继续作为这些技能冷却的唯一常驻可视来源
---------------------------------------------------------------

local PRESET_VERSION = 6
local GROUP_NAMES = {
  "战士手动资源",
  "Warrior Manual Resources",
  "Doite手动资源",
}

local function IsWarrior()
  if not UnitClass then
    return false
  end
  local localized, classTag = UnitClass("player")
  classTag = classTag and string.upper(classTag) or ""
  return classTag == "WARRIOR" or localized == "战士"
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

local function DisablePreset()
  if not IsWarrior() then
    return true
  end

  DoiteAurasDB = DoiteAurasDB or {}
  DoiteAurasDB.spells = DoiteAurasDB.spells or {}
  DoiteAurasDB.groupSort = DoiteAurasDB.groupSort or {}
  DoiteAurasDB.bucketDisabled = DoiteAurasDB.bucketDisabled or {}

  local changed =
      (tonumber(DoiteAurasDB.doiteResourceMonitorPresetVersion) or 0)
          < PRESET_VERSION
  local i
  for i = 1, table.getn(GROUP_NAMES) do
    local name = GROUP_NAMES[i]
    if DoiteAurasDB.bucketDisabled[name] ~= true then
      DoiteAurasDB.bucketDisabled[name] = true
      changed = true
    end
  end

  DoiteAurasDB.doiteResourceMonitorPresetVersion = PRESET_VERSION
  if changed then
    RefreshPreset()
  end
  return true
end

_G["DoiteAuras_InstallWarriorResourceMonitors"] = DisablePreset

local eventFrame = CreateFrame(
    "Frame",
    "DoiteAurasResourceMonitorInstaller"
)
local pendingDelay = 0
local elapsed = 0

local function QueueInstall(delay)
  if not IsWarrior() then
    eventFrame:Hide()
    return
  end
  pendingDelay = delay or 0.2
  elapsed = 0
  eventFrame:Show()
end

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function()
  QueueInstall(0.25)
end)
eventFrame:SetScript("OnUpdate", function()
  elapsed = elapsed + (arg1 or 0)
  if elapsed < pendingDelay then
    return
  end

  elapsed = 0
  DisablePreset()
  this:Hide()
end)

QueueInstall(0.20)
