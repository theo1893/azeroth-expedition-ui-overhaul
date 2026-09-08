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

local frame
local refreshCount = 0

CreateFrame = function()
  frame = {
    shown = true,
    scripts = {},
    events = {},
  }
  function frame:RegisterEvent(name)
    self.events[name] = true
  end
  function frame:SetScript(name, handler)
    self.scripts[name] = handler
  end
  function frame:Show()
    self.shown = true
  end
  function frame:Hide()
    self.shown = false
  end
  return frame
end

UnitClass = function()
  return "战士", "WARRIOR"
end

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
  RequestReflow = function()
    refreshCount = refreshCount + 1
  end,
}
DoiteAurasDB = {
  spells = {},
  groupSort = {},
  bucketDisabled = {},
}

dofile("DoiteAuras/Modules/DoiteResourceMonitors.lua")

Check(
    DoiteAuras_InstallWarriorResourceMonitors() == true,
    "retired resource preset should finish"
)
Check(
    next(DoiteAurasDB.spells) == nil,
    "retired preset must not create replacement cooldown icons"
)
Check(
    DoiteAurasDB.bucketDisabled["战士手动资源"] == true,
    "current resource group should be disabled"
)
Check(
    DoiteAurasDB.bucketDisabled["Warrior Manual Resources"] == true,
    "English resource group should be disabled"
)
Check(
    DoiteAurasDB.bucketDisabled["Doite手动资源"] == true,
    "legacy resource group should be disabled"
)
Check(
    DoiteAurasDB.doiteResourceMonitorPresetVersion == 6,
    "resource retirement marker should be version 6"
)
Check(refreshCount == 4, "first retirement should refresh all consumers")
Check(
    frame.events.PLAYER_ENTERING_WORLD == true,
    "retirement should be restored on every login"
)
Check(
    frame.events.SPELLS_CHANGED ~= true,
    "retired preset should no longer scan the spellbook"
)

Check(
    DoiteAuras_InstallWarriorResourceMonitors() == true,
    "second retirement pass should remain safe"
)
Check(refreshCount == 4, "unchanged retirement should not refresh again")

local oldBloodrage = {
  doiteResourceMonitorPreset = 5,
  group = "战士手动资源",
  offsetX = 137,
  iconSize = 31,
}
local oldRecklessness = {
  doiteResourceMonitorPreset = 5,
  group = "战士手动资源",
  conditions = { ability = { mode = "notcd" } },
}
DoiteAurasDB = {
  doiteResourceMonitorPresetVersion = 5,
  spells = {
    DoiteResource_Bloodrage = oldBloodrage,
    DoiteResource_Recklessness = oldRecklessness,
  },
  groupSort = { ["战士手动资源"] = "prio" },
  bucketDisabled = {},
}
refreshCount = 0

Check(
    DoiteAuras_InstallWarriorResourceMonitors() == true,
    "existing managed entries should migrate to hidden state"
)
Check(
    DoiteAurasDB.spells.DoiteResource_Bloodrage == oldBloodrage
        and DoiteAurasDB.spells.DoiteResource_Recklessness
            == oldRecklessness,
    "retirement should preserve reversible SavedVariables entries"
)
Check(
    oldBloodrage.offsetX == 137 and oldBloodrage.iconSize == 31,
    "retirement must not rewrite old user layout"
)
Check(
    DoiteAurasDB.bucketDisabled["战士手动资源"] == true,
    "existing managed entries must be hidden as a bucket"
)
Check(refreshCount == 4, "existing-entry retirement should refresh")

DoiteAurasDB.bucketDisabled["战士手动资源"] = nil
refreshCount = 0
Check(
    DoiteAuras_InstallWarriorResourceMonitors() == true,
    "login enforcement should restore the retired state"
)
Check(
    DoiteAurasDB.bucketDisabled["战士手动资源"] == true,
    "resource group must not silently return on a future login"
)
Check(refreshCount == 4, "restored retirement should refresh")

UnitClass = function()
  return "法师", "MAGE"
end
DoiteAurasDB = {
  spells = {},
  groupSort = {},
  bucketDisabled = {},
}
refreshCount = 0
Check(
    DoiteAuras_InstallWarriorResourceMonitors() == true,
    "non-warrior retirement should be a no-op"
)
Check(
    next(DoiteAurasDB.bucketDisabled) == nil and refreshCount == 0,
    "non-warrior settings must remain untouched"
)

print(
    "DoiteResourceMonitors_spec: "
        .. checkCount
        .. " checks passed"
)
