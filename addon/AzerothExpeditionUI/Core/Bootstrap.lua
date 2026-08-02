AzerothExpeditionUI = AzerothExpeditionUI or {}

local addon = AzerothExpeditionUI

addon.name = "AzerothExpeditionUI"
addon.version = "0.6.0"
addon.modules = addon.modules or {}
addon.media = addon.media or {}
addon.media.root = "Interface\\AddOns\\AzerothExpeditionUI\\Media\\"

local defaults = {
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
eventFrame:RegisterEvent("UI_SCALE_CHANGED")

eventFrame:SetScript("OnEvent", function()
  if event == "ADDON_LOADED" and arg1 == addon.name then
    addon:Initialize()
  elseif event == "PLAYER_ENTERING_WORLD" then
    addon:ScheduleRefresh(0.15)
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

  if command == "chat" then
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
    local chatColorStatus =
      addon.modules.Chat and
      addon.modules.Chat.GetMessageColorStatus and
      addon.modules.Chat:GetMessageColorStatus() or
      "unavailable"
    addon:Print(
      "version " .. addon.version ..
      ", chat=" ..
      (AzerothExpeditionUIDB.chat.enabled and "enabled" or "disabled") ..
      ", chat-runtime=" .. tostring(chatRuntime) ..
      ", chat-color=" .. tostring(chatColorStatus) ..
      ", quests=" ..
      (AzerothExpeditionUIDB.quests.enabled and "enabled" or "disabled") ..
      ", quest-runtime=" .. tostring(questRuntime) ..
      ", pfUI=" .. (pfUI and "available" or "missing") ..
      ", route=" .. (scopedRoute and "scoped" or "pfui") ..
      ", ownership=" .. (scopedRoute and "chat,quests" or "none") ..
      ", blizzard-skins=" ..
      (scopedRoute and "pfui-except-quest-log" or "pfui")
    )
  else
    addon:Print("/aeui chat, /aeui quests, /aeui refresh, /aeui status")
  end
end
