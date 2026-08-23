AzerothExpeditionUI = AzerothExpeditionUI or {}

local addon = AzerothExpeditionUI

addon.name = "AzerothExpeditionUI"
addon.version = "0.9.0"
addon.modules = addon.modules or {}
addon.media = addon.media or {}
addon.media.root = "Interface\\AddOns\\AzerothExpeditionUI\\Media\\"

local defaults = {
  actionbars = {
    enabled = true,
    artVersion = 1,
    autoBarPopupMode = "AUTO",
    markersEnabled = true,
    fieldKitBound = true,
    consumableDocked = true,
    trinketDocked = true,
    combatFocusLayoutVersion = 0,
    focusUnitDefaultProfiles = {},
    comfortUIScaleVersion = 0,
    sideBarGroupProfiles = {},
    autoBarClassScopePlayerVersions = {},
    autoBarClassScopeClassVersions = {},
    autoBarClassScopeProfiles = {},
    autoBarClassScopePlayerBackups = {},
    autoBarClassScopeBackups = {},
    autoBarClassScopeOptOut = {},
  },
  chat = {
    enabled = true,
    minimumWidth = 440,
    minimumHeight = 320,
    artVersion = 4,
    bookBrightness = 1.00,
    maintainInterval = 0.25,
  },
  quests = {
    enabled = true,
    artVersion = 4,
  },
  unitframes = {
    enabled = true,
    artVersion = 6,
  },
  map = {
    enabled = true,
    artVersion = 3,
  },
  character = {
    enabled = true,
    artVersion = 3,
  },
  gearplanner = {
    enabled = true,
    schemaVersion = 5,
    companionView = "current",
    inspectView = "gear",
    wideMode = false,
    characters = {},
  },
  spellbook = {
    enabled = false,
    artVersion = 1,
  },
}

local function ApplyDefaults(target, source)
  for key, value in pairs(source) do
    if type(value) == "table" then
      if type(target[key]) ~= "table" then
        target[key] = {}
      end
      ApplyDefaults(target[key], value)
    elseif target[key] == nil then
      target[key] = value
    end
  end
end

function addon:Print(message)
  if DEFAULT_CHAT_FRAME then
    DEFAULT_CHAT_FRAME:AddMessage(
      "|cffc89b55Azeroth Expedition UI:|r " .. tostring(message)
    )
  end
end

function addon:RegisterModule(name, module)
  self.modules[name] = module
end

function addon:RunModuleMethod(name, module, methodName)
  if not module or type(module[methodName]) ~= "function" then
    return true
  end

  self.moduleFailures = self.moduleFailures or {}
  self.reportedModuleFailures =
    self.reportedModuleFailures or {}

  local key = tostring(name) .. ":" .. tostring(methodName)
  local ok, result = pcall(module[methodName], module)
  if not ok then
    local message = tostring(result)
    self.moduleFailures[key] = message
    if self.reportedModuleFailures[key] ~= message then
      self.reportedModuleFailures[key] = message
      self:Print(
        "module " .. tostring(name) .. " " ..
        tostring(methodName) .. " failed: " .. message
      )
    end
    return false
  end

  self.moduleFailures[key] = nil
  self.reportedModuleFailures[key] = nil
  return true
end

function addon:Initialize()
  if self.initialized then
    return
  end

  AzerothExpeditionUIDB = AzerothExpeditionUIDB or {}
  if (
    AzerothExpeditionUIDB.chat and
    (tonumber(AzerothExpeditionUIDB.chat.artVersion) or 0) < 4
  ) then
    AzerothExpeditionUIDB.chat.artVersion = 4
    AzerothExpeditionUIDB.chat.bookBrightness = 1.00
  end
  if (
    AzerothExpeditionUIDB.unitframes and
    (tonumber(AzerothExpeditionUIDB.unitframes.artVersion) or 0) < 6
  ) then
    AzerothExpeditionUIDB.unitframes.artVersion = 6
  end
  if (
    AzerothExpeditionUIDB.map and
    (tonumber(AzerothExpeditionUIDB.map.artVersion) or 0) < 3
  ) then
    AzerothExpeditionUIDB.map.enabled = true
    AzerothExpeditionUIDB.map.artVersion = 3
  end
  if (
    AzerothExpeditionUIDB.character and
    (tonumber(AzerothExpeditionUIDB.character.artVersion) or 0) < 3
  ) then
    AzerothExpeditionUIDB.character.enabled = true
    AzerothExpeditionUIDB.character.artVersion = 3
  end
  ApplyDefaults(AzerothExpeditionUIDB, defaults)
  self.db = AzerothExpeditionUIDB

  for name, module in pairs(self.modules) do
    self:RunModuleMethod(name, module, "Initialize")
  end

  self.initialized = true
  self:ScheduleRefresh(0)
end

function addon:Refresh()
  if not self.initialized then
    return
  end

  for name, module in pairs(self.modules) do
    self:RunModuleMethod(name, module, "Apply")
  end
end

function addon:ScheduleRefresh(delay)
  self.refreshAt = GetTime() + (delay or 0)
end

local eventFrame = CreateFrame("Frame", "AzerothExpeditionUIEventFrame", UIParent)
addon.eventFrame = eventFrame

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_LOGOUT")
eventFrame:RegisterEvent("UI_SCALE_CHANGED")

eventFrame:SetScript("OnEvent", function()
  if event == "ADDON_LOADED" and arg1 == addon.name then
    addon:Initialize()
  elseif event == "PLAYER_ENTERING_WORLD" then
    addon:ScheduleRefresh(0.15)
  elseif event == "PLAYER_LOGOUT" then
    for name, module in pairs(addon.modules) do
      addon:RunModuleMethod(name, module, "PrepareLogout")
    end
  elseif event == "UI_SCALE_CHANGED" then
    addon:ScheduleRefresh(0.15)
  end
end)

eventFrame:SetScript("OnUpdate", function()
  if addon.refreshAt and GetTime() >= addon.refreshAt then
    addon.refreshAt = nil
    addon:Refresh()
  end
end)

SLASH_AZEROTHEXPEDITIONUI1 = "/aeui"
SlashCmdList["AZEROTHEXPEDITIONUI"] = function(message)
  local command = string.lower(message or "")
  command = string.gsub(command, "^%s+", "")
  command = string.gsub(command, "%s+$", "")

  if command == "actionbars" then
    AzerothExpeditionUIDB.actionbars.enabled =
      not AzerothExpeditionUIDB.actionbars.enabled
    addon:Print(
      "action bar art " ..
      (AzerothExpeditionUIDB.actionbars.enabled and "enabled" or "disabled") ..
      "; reloading UI."
    )
    ReloadUI()
  elseif string.find(command, "^autobar") then
    local _, _, subcommand = string.find(command, "^autobar%s*(.*)$")
    local module = addon.modules.ActionBars
    if not module then
      addon:Print("ActionBars module is unavailable.")
    elseif subcommand == "" or subcommand == "open" then
      local _, result = module:OpenAutoBarConfig()
      addon:Print(result)
    elseif subcommand == "apply" or subcommand == "preset" or
      subcommand == "setup"
    then
      local ok, result = module:ApplyRecommendedAutoBarProfile()
      addon:Print(result)
      if ok then
        addon:ScheduleRefresh(0)
      end
    elseif subcommand == "restore" then
      local ok, result = module:RestoreAutoBarProfile()
      addon:Print(result)
      if ok then
        addon:ScheduleRefresh(0)
      end
    elseif string.find(subcommand, "^popup") then
      local _, _, mode = string.find(subcommand, "^popup%s*(.*)$")
      if mode == "" then
        addon:Print("/aeui autobar popup [auto|left|right|native]")
      else
        local _, result = module:SetAutoBarPopupMode(mode)
        addon:Print(result)
      end
    else
      addon:Print(
        "/aeui autobar [open|apply|restore|popup auto|left|right|native]"
      )
    end
  elseif string.find(command, "^fieldkit") then
    local _, _, subcommand = string.find(command, "^fieldkit%s*(.*)$")
    local module = addon.modules.ActionBars
    if not module then
      addon:Print("ActionBars module is unavailable.")
    elseif subcommand == "" or subcommand == "bind" or
      subcommand == "dock"
    then
      local _, result = module:SetFieldKitDocking(true)
      addon:Print(result)
    elseif subcommand == "unbind" or subcommand == "undock" or
      subcommand == "free"
    then
      local _, result = module:SetFieldKitDocking(false)
      addon:Print(result)
    elseif subcommand == "home" or subcommand == "reset" then
      local _, result = module:ResetCombatDeckPosition()
      addon:Print(result)
    elseif subcommand == "status" then
      addon:Print(module:GetRuntimeStatus())
    else
      addon:Print("/aeui fieldkit [bind|unbind|home|status]")
    end
  elseif string.find(command, "^focuslayout") or
    string.find(command, "^combatlayout")
  then
    local _, _, subcommand = string.find(command, "^%S+%s*(.*)$")
    local module = addon.modules.ActionBars
    if not module then
      addon:Print("ActionBars module is unavailable.")
    elseif subcommand == "" or subcommand == "apply" or
      subcommand == "home" or subcommand == "reset"
    then
      local ok, result = module:ApplyCombatFocusLayoutPreset()
      addon:Print(result)
      if ok then
        addon:ScheduleRefresh(0)
      end
    elseif subcommand == "comfort" or subcommand == "scale" then
      local ok, result = module:ApplyComfortUIScalePreset()
      addon:Print(result)
      if ok then
        addon:ScheduleRefresh(0)
      end
    elseif subcommand == "restore" then
      local ok, result = module:RestoreCombatFocusLayoutPreset()
      addon:Print(result)
      if ok then
        addon:ScheduleRefresh(0)
      end
    elseif subcommand == "status" then
      addon:Print(module:GetRuntimeStatus())
    else
      addon:Print("/aeui focuslayout [apply|comfort|restore|status]")
    end
  elseif string.find(command, "^sidebars") then
    local _, _, subcommand = string.find(command, "^sidebars%s*(.*)$")
    local module = addon.modules.ActionBars
    if not module then
      addon:Print("ActionBars module is unavailable.")
    elseif subcommand == "" or subcommand == "bind" or
      subcommand == "group"
    then
      local ok, result = module:SetSideBarGroupBinding(true)
      addon:Print(result)
      if ok then
        addon:ScheduleRefresh(0)
      end
    elseif subcommand == "unbind" or subcommand == "free" or
      subcommand == "ungroup"
    then
      local ok, result = module:SetSideBarGroupBinding(false)
      addon:Print(result)
      if ok then
        addon:ScheduleRefresh(0)
      end
    elseif subcommand == "home" or subcommand == "reset" then
      local ok, result = module:ResetSideBarGroupPosition()
      addon:Print(result)
      if ok then
        addon:ScheduleRefresh(0)
      end
    elseif subcommand == "status" then
      addon:Print(module:GetRuntimeStatus())
    else
      addon:Print("/aeui sidebars [bind|unbind|home|status]")
    end
  elseif string.find(command, "^markers") or
    string.find(command, "^marker%s") or command == "marker"
  then
    local _, _, subcommand = string.find(command, "^%S+%s*(.*)$")
    local module = addon.modules.TargetMarkers
    if not module then
      addon:Print("TargetMarkers module is unavailable.")
    elseif subcommand == "on" or subcommand == "show" or
      subcommand == "enable"
    then
      local _, result = module:SetEnabled(true)
      addon:Print(result)
    elseif subcommand == "off" or subcommand == "hide" or
      subcommand == "disable"
    then
      local _, result = module:SetEnabled(false)
      addon:Print(result)
    elseif subcommand == "toggle" then
      local enabled = not (
        AzerothExpeditionUIDB.actionbars.markersEnabled ~= false
      )
      local _, result = module:SetEnabled(enabled)
      addon:Print(result)
    elseif subcommand == "" or subcommand == "status" then
      addon:Print("markers " .. module:GetRuntimeStatus())
    else
      addon:Print("/aeui markers [on|off|toggle|status]")
    end
  elseif command == "chat" then
    AzerothExpeditionUIDB.chat.enabled =
      not AzerothExpeditionUIDB.chat.enabled
    addon:Print(
      "chat skin " ..
      (AzerothExpeditionUIDB.chat.enabled and "enabled" or "disabled") ..
      "; reloading UI."
    )
    ReloadUI()
  elseif command == "quests" then
    AzerothExpeditionUIDB.quests.enabled =
      not AzerothExpeditionUIDB.quests.enabled
    addon:Print(
      "quest log shell " ..
      (AzerothExpeditionUIDB.quests.enabled and "enabled" or "disabled") ..
      "; reloading UI."
    )
    ReloadUI()
  elseif command == "unitframes" then
    AzerothExpeditionUIDB.unitframes.enabled =
      not AzerothExpeditionUIDB.unitframes.enabled
    addon:Refresh()
    addon:Print(
      "unit-frame bar and raid shell skin " ..
      (AzerothExpeditionUIDB.unitframes.enabled and "enabled" or "disabled") ..
      "."
    )
  elseif command == "map" then
    AzerothExpeditionUIDB.map.enabled =
      not AzerothExpeditionUIDB.map.enabled
    addon:Refresh()
    addon:Print(
      "minimap expedition skin " ..
      (AzerothExpeditionUIDB.map.enabled and "enabled" or "disabled") ..
      "."
    )
  elseif command == "character" then
    AzerothExpeditionUIDB.character.enabled =
      not AzerothExpeditionUIDB.character.enabled
    addon:Refresh()
    addon:Print(
      "character shell skin " ..
      (AzerothExpeditionUIDB.character.enabled and "enabled" or "disabled") ..
      "."
    )
  elseif
    string.find(command, "^gear%s*") or
    string.find(command, "^gearplanner%s*")
  then
    local _, _, subcommand = string.find(command, "^%S+%s*(.*)$")
    local module = addon.modules.GearPlanner
    if not module then
      addon:Print("配装工具模块不可用。")
    elseif subcommand == "open" or subcommand == "plan" then
      local _, result = module:Open()
      addon:Print(result)
    elseif subcommand == "current" then
      local _, result = module:OpenView("current")
      addon:Print(result)
    elseif subcommand == "stats" or subcommand == "attributes" then
      local _, result = module:OpenView("stats")
      addon:Print(result)
    elseif subcommand == "" or subcommand == "toggle" then
      local _, result = module:Toggle()
      addon:Print(result)
    elseif
      subcommand == "on" or
      subcommand == "enable"
    then
      local _, result = module:SetEnabled(true)
      addon:Print(result)
    elseif
      subcommand == "off" or
      subcommand == "disable"
    then
      local _, result = module:SetEnabled(false)
      addon:Print(result)
    elseif subcommand == "status" then
      addon:Print("配装 " .. module:GetRuntimeStatus())
    elseif string.find(subcommand, "^wide%s*") then
      local _, _, wideCommand = string.find(subcommand, "^wide%s*(.*)$")
      local _, result
      if wideCommand == "on" or wideCommand == "enable" then
        _, result = module:SetWideMode(true)
      elseif wideCommand == "off" or wideCommand == "disable" then
        _, result = module:SetWideMode(false)
      elseif wideCommand == "" or wideCommand == "toggle" then
        _, result = module:ToggleWideMode()
      else
        result = "/aeui gear wide [on|off|toggle]"
      end
      addon:Print(result)
    else
      addon:Print(
        "/aeui gear [open|current|stats|plan|wide on|off|toggle|status]"
      )
    end
  elseif command == "refresh" then
    addon:Refresh()
    addon:Print("visual adapters refreshed.")
  elseif command == "status" then
    local expedition =
      pfUI_config and
      pfUI_config.appearance and
      pfUI_config.appearance.expedition
    local scopedRoute =
      expedition and
      expedition.enabled == "1" and
      expedition.ownership == "scoped-v1"
    local chatRuntime =
      addon.modules.Chat and
      addon.modules.Chat.runtimeContract or
      "unknown"
    local questRuntime =
      addon.modules.Quests and
      addon.modules.Quests.runtimeContract or
      "unknown"
    local actionBarRuntime =
      addon.modules.ActionBars and
      addon.modules.ActionBars.runtimeContract or
      "unknown"
    local markerRuntime =
      addon.modules.TargetMarkers and
      addon.modules.TargetMarkers.runtimeContract or
      "unknown"
    local unitFrameRuntime =
      addon.modules.UnitFrames and
      addon.modules.UnitFrames.runtimeContract or
      "unknown"
    local mapRuntime =
      addon.modules.Map and
      addon.modules.Map.runtimeContract or
      "unknown"
    local characterRuntime =
      addon.modules.Character and
      addon.modules.Character.runtimeContract or
      "unknown"
    local gearRuntime =
      addon.modules.GearPlanner and
      addon.modules.GearPlanner.runtimeContract or
      "unknown"
    local chatColorStatus =
      addon.modules.Chat and
      addon.modules.Chat.GetMessageColorStatus and
      addon.modules.Chat:GetMessageColorStatus() or
      "unavailable"
    addon:Print(
      "version " .. addon.version ..
      ", actionbars=" ..
      (AzerothExpeditionUIDB.actionbars.enabled and "enabled" or "disabled") ..
      ", actionbar-runtime=" .. tostring(actionBarRuntime) ..
      ", markers=" ..
      (AzerothExpeditionUIDB.actionbars.enabled and
        AzerothExpeditionUIDB.actionbars.markersEnabled ~= false and
        "enabled" or "disabled") ..
      ", marker-runtime=" .. tostring(markerRuntime) ..
      ", chat=" ..
      (AzerothExpeditionUIDB.chat.enabled and "enabled" or "disabled") ..
      ", chat-runtime=" .. tostring(chatRuntime) ..
      ", chat-color=" .. tostring(chatColorStatus) ..
      ", quests=" ..
      (AzerothExpeditionUIDB.quests.enabled and "enabled" or "disabled") ..
      ", quest-runtime=" .. tostring(questRuntime) ..
      ", unitframes=" ..
      (AzerothExpeditionUIDB.unitframes.enabled and "enabled" or "disabled") ..
      ", unitframes-runtime=" .. tostring(unitFrameRuntime) ..
      ", map=" ..
      (AzerothExpeditionUIDB.map.enabled and "enabled" or "disabled") ..
      ", map-runtime=" .. tostring(mapRuntime) ..
      ", character=" ..
      (AzerothExpeditionUIDB.character.enabled and "enabled" or "disabled") ..
      ", character-runtime=" .. tostring(characterRuntime) ..
      ", gear=" ..
      (AzerothExpeditionUIDB.gearplanner.enabled and
        "enabled" or "disabled") ..
      ", gear-runtime=" .. tostring(gearRuntime) ..
      ", pfUI=" .. (pfUI and "available" or "missing") ..
      ", route=" .. (scopedRoute and "scoped" or "pfui") ..
      ", ownership=" ..
      (scopedRoute and "chat,quests,unitframes,map,character" or "none") ..
      ", blizzard-skins=" ..
      (scopedRoute and "pfui-except-quest-log" or "pfui")
    )
    if
      addon.modules.ActionBars and
      addon.modules.ActionBars.GetRuntimeStatus
    then
      addon:Print(
        "actionbars " .. addon.modules.ActionBars:GetRuntimeStatus()
      )
    end
    if
      addon.modules.TargetMarkers and
      addon.modules.TargetMarkers.GetRuntimeStatus
    then
      addon:Print(
        "markers " .. addon.modules.TargetMarkers:GetRuntimeStatus()
      )
    end
    if
      addon.modules.Quests and
      addon.modules.Quests.GetRuntimeStatus
    then
      addon:Print(
        "quest " .. addon.modules.Quests:GetRuntimeStatus()
      )
    end
    if
      addon.modules.UnitFrames and
      addon.modules.UnitFrames.GetRuntimeStatus
    then
      addon:Print(
        "unitframes " .. addon.modules.UnitFrames:GetRuntimeStatus()
      )
    end
    if addon.modules.Map and addon.modules.Map.GetRuntimeStatus then
      addon:Print("map " .. addon.modules.Map:GetRuntimeStatus())
    end
    if
      addon.modules.Character and
      addon.modules.Character.GetRuntimeStatus
    then
      addon:Print(
        "character " .. addon.modules.Character:GetRuntimeStatus()
      )
    end
    if
      addon.modules.GearPlanner and
      addon.modules.GearPlanner.GetRuntimeStatus
    then
      addon:Print(
        "配装 " .. addon.modules.GearPlanner:GetRuntimeStatus()
      )
    end
  else
    addon:Print(
      "/aeui actionbars, /aeui autobar [open|apply|restore|popup], /aeui fieldkit [bind|unbind|home|status], /aeui focuslayout [apply|comfort|restore|status], /aeui sidebars [bind|unbind|home|status], /aeui markers [on|off|toggle|status], /aeui chat, /aeui quests, /aeui unitframes, /aeui map, /aeui character, /aeui gear [open|current|stats|plan|wide|status], /aeui refresh, /aeui status"
    )
  end
end
