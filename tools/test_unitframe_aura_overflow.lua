-- Focused runtime check for Turtle WoW's debuff-overflow slot mapping.
setfenv = setfenv or function() end

pfUI = {
  api = {},
  client = 11200,
  GetEnvironment = function() return _G end,
}
L = {
  debuffs = { ["Known Debuff"] = { [0] = 10 } },
  dyndebuffs = {},
}

UIParent = {}
StaticPopupDialogs = {}
SlashCmdList = {}
DEFAULT_CHAT_FRAME = { AddMessage = function() end }
libtipscan = { GetScanner = function() return {} end }

local function NewFrame()
  return setmetatable({}, { __index = function() return function() end end })
end

CreateFrame = NewFrame
UnitClass = function() return nil, "MAGE" end
GetLocale = function() return "enUS" end
GetNampowerVersion = function() return 3, 0, 0 end
GetTime = function() return 1 end
GetUnitGUID = function() return "target-guid" end
GetPlayerGUID = function() return "player-guid" end
UnitName = function() return "Target" end
UnitLevel = function() return 63 end

local auras = { [1] = 101, [2] = 202, [33] = 303 }
GetUnitField = function(_, field)
  if field == "aura" then return auras end
  if field == "auraApplications" then return {} end
end
GetSpellRecField = function(spellId, field)
  if field == "name" then
    return ({ [101] = "Known Debuff", [202] = "Real Buff", [303] = "Regular Debuff" })[spellId]
  elseif field == "spellIconID" then
    return spellId
  end
end
GetSpellIconTexture = function(spellId) return "Spell_" .. spellId end
UnitBuff = function() end
UnitDebuff = function() end

assert(loadfile("addon/pfUI/libs/libdebuff.lua"))()

local lib = assert(pfUI.api.libdebuff)
assert(lib:IsOverflowDebuff("target", 1) == true)
assert(lib:IsOverflowDebuff("target", 2) == false)
assert((lib:UnitDebuff("target", 17)) == "Known Debuff")
assert((lib:UnitDebuff("target", 18)) == nil)
assert((lib:UnitDebuff("target", 1)) == "Regular Debuff")

print("unitframe aura overflow: PASS")
