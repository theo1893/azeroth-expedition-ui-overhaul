AzerothExpeditionUI = AzerothExpeditionUI or {}

local addon = AzerothExpeditionUI

addon.name = "AzerothExpeditionUI"
addon.version = "0.4.1"
addon.modules = addon.modules or {}
addon.media = addon.media or {}
addon.media.root = "Interface\\AddOns\\AzerothExpeditionUI\\Media\\"

local defaults = {
  chat = {
    enabled = true,
    minimumWidth = 440,
    minimumHeight = 320,
    artVersion = 3,
    bookBrightness = 0.78,
    maintainInterval = 0.25,
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

function addon:Initialize()
  if self.initialized then
    return
  end

  AzerothExpeditionUIDB = AzerothExpeditionUIDB or {}
  if (
    AzerothExpeditionUIDB.chat and
    (tonumber(AzerothExpeditionUIDB.chat.artVersion) or 0) >= 4
  ) then
    AzerothExpeditionUIDB.chat.artVersion = 3
    AzerothExpeditionUIDB.chat.bookBrightness = 0.78
  end
  ApplyDefaults(AzerothExpeditionUIDB, defaults)
  self.db = AzerothExpeditionUIDB

  for _, module in pairs(self.modules) do
    if module.Initialize then
      module:Initialize()
    end
  end

  self.initialized = true
  self:ScheduleRefresh(0)
end

function addon:Refresh()
  if not self.initialized then
    return
  end

  for _, module in pairs(self.modules) do
    if module.Apply then
      module:Apply()
    end
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
  elseif command == "refresh" then
    addon:Refresh()
    addon:Print("visual adapters refreshed.")
  elseif command == "status" then
    local expedition =
      pfUI_config and
      pfUI_config.appearance and
      pfUI_config.appearance.expedition
    local nativeFallback =
      expedition and
      expedition.enabled == "1" and
      expedition.vanilla_fallback == "1"
    local nativeSkins =
      expedition and
      expedition.enabled == "1" and
      expedition.native_blizzard_skins == "1"
    addon:Print(
      "version " .. addon.version ..
      ", chat=" ..
      (AzerothExpeditionUIDB.chat.enabled and "enabled" or "disabled") ..
      ", pfUI=" .. (pfUI and "available" or "missing") ..
      ", route=" .. (nativeFallback and "native-first" or "pfui") ..
      ", blizzard-skins=" .. (nativeSkins and "native" or "pfui")
    )
  else
    addon:Print("/aeui chat, /aeui refresh, /aeui status")
  end
end
