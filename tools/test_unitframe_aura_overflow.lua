-- Focused runtime check for Turtle WoW's debuff-overflow slot mapping.
setfenv = setfenv or function() end

local targetFrame = { label = "target", id = "" }
local focusFrame = { label = "target-guid", id = "" }
pfUI = {
  api = {},
  client = 11200,
  GetEnvironment = function() return _G end,
  uf = { frames = { targetFrame, focusFrame } },
}
L = {
  debuffs = { ["Rallying Cry"] = { [0] = 7200 } },
  dyndebuffs = {},
}

UIParent = {}
StaticPopupDialogs = {}
SlashCmdList = {}
DEFAULT_CHAT_FRAME = { AddMessage = function() end }
libtipscan = { GetScanner = function() return {} end }

local frames = {}
local function NewFrame()
  local frame = { events = {} }
  function frame:RegisterEvent(name) self.events[name] = true end
  function frame:SetScript(name, handler) self[name] = handler end
  frames[#frames + 1] = frame
  return setmetatable(frame, {
    __index = function() return function() end end,
  })
end

CreateFrame = NewFrame
UnitClass = function() return nil, "MAGE" end
GetLocale = function() return "enUS" end
GetNampowerVersion = function() return 3, 0, 0 end
GetTime = function() return 1 end
GetUnitGUID = function(unit)
  if unit == "target" or unit == "target-guid" then
    return "target-guid"
  end
end
GetPlayerGUID = function() return "player-guid" end
UnitName = function() return "Target" end
UnitLevel = function() return 63 end

local auras = { [1] = 101, [3] = 202, [33] = 303 }
GetUnitField = function(_, field)
  if field == "aura" then return auras end
  if field == "auraApplications" then return {} end
end
GetSpellRecField = function(spellId, field)
  if field == "name" then
    return ({
      [101] = "Rallying Cry",
      [202] = "Known Debuff",
      [303] = "Regular Debuff",
    })[spellId]
  elseif field == "spellIconID" then
    return spellId
  elseif field == "attributesEx" then
    return spellId == 101 and 0 or 128
  end
end
GetSpellIconTexture = function(spellId) return "Spell_" .. spellId end
UnitBuff = function() end
UnitDebuff = function() end

assert(loadfile("addon/pfUI/libs/libdebuff.lua"))()

local lib = assert(pfUI.api.libdebuff)
assert(lib:IsOverflowDebuff("target", 1) == false)
local overflow, buffSlot = lib:IsOverflowDebuff("target", 3)
assert(overflow == true and buffSlot == 2)
assert(lib:IsOverflowBuff("target", 2) == true)

local eventFrame
for _, frame in ipairs(frames) do
  if frame.events.DEBUFF_ADDED_OTHER then eventFrame = frame end
end
assert(eventFrame and eventFrame.OnEvent)

event, arg1, arg2, arg3, arg4, arg6 =
  "DEBUFF_ADDED_OTHER", "target-guid", 1, 303, 0, 32
this = eventFrame
eventFrame.OnEvent()

assert(lib:IsOverflowBuff("target", 1) == false)
assert(lib:IsOverflowBuff("target", 2) == true)
assert((lib:UnitDebuff("target", 19)) == "Known Debuff")
assert((lib:UnitDebuff("target", 1)) == "Regular Debuff")
assert(targetFrame.update_aura == true)
assert(focusFrame.update_aura == true)

print("unitframe aura overflow: PASS")
