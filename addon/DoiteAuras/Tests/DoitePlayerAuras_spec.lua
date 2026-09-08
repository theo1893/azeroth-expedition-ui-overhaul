local checkCount = 0
local function Check(value, message)
  if not value then
    error(message or "check failed", 2)
  end
  checkCount = checkCount + 1
end

local frames = {}
CreateFrame = function(_, name)
  local frame = {
    scripts = {},
    events = {},
  }
  function frame:RegisterEvent(eventName)
    self.events[eventName] = true
  end
  function frame:UnregisterEvent(eventName)
    self.events[eventName] = nil
  end
  function frame:SetScript(scriptName, handler)
    self.scripts[scriptName] = handler
  end
  frames[name] = frame
  return frame
end

local auraIds = {}
local auraApplications = {}
for i = 1, 48 do
  auraIds[i] = 0
  auraApplications[i] = 0
end
auraIds[3] = 12328
auraApplications[3] = 0

GetUnitField = function(unit, field)
  Check(unit == "player", "only player auras should be queried")
  if field == "aura" then
    return auraIds
  end
  if field == "auraApplications" then
    return auraApplications
  end
  return nil
end

GetSpellRecField = function(spellId, field)
  if spellId == 12328 and field == "name" then
    return "横扫攻击"
  end
  if field == "stackAmount" then
    return 1
  end
  return nil
end

UnitExists = function()
  return true, "Player-1"
end
GetTime = function()
  return 100
end

local enhancedStacks = 5
UnitBuff = function(unit, index)
  Check(unit == "player", "enhanced buff lookup should use player")
  if index == 1 then
    return "Interface\\Icons\\Ability_Rogue_SliceDice",
        enhancedStacks,
        12328
  end
  return nil
end

GetPlayerBuffApplications = function()
  return 1
end

DoiteBuffData = {
  stackModifiers = {},
}

dofile("DoiteAuras/Modules/DoitePlayerAuras.lua")

frames.DoitePlayerAuras_PlayerEnteringWorld.scripts.OnEvent()

Check(
    DoitePlayerAuras.GetBuffStacks("横扫攻击") == 5,
    "enhanced UnitBuff charges should override a one-stack aura cache"
)
Check(
    DoitePlayerAuras.GetBuffStacksBySpellId(12328) == 5,
    "spell-id charge lookup should use the enhanced source"
)

enhancedStacks = 4
arg3 = 12328
arg4 = 4
arg6 = 2
arg7 = 2
frames.DoitePlayerAuras_BuffRemoved.scripts.OnEvent()

Check(
    DoitePlayerAuras.GetBuffStacks("横扫攻击") == 4,
    "charge consumption should update the displayed count"
)

enhancedStacks = 1
arg3 = 12328
arg4 = 1
arg6 = 2
arg7 = 2
frames.DoitePlayerAuras_BuffRemoved.scripts.OnEvent()

Check(
    DoitePlayerAuras.GetBuffStacks("横扫攻击") == 1,
    "the last Sweeping Strikes charge should remain visible"
)

print(
    "DoitePlayerAuras_spec: "
        .. checkCount
        .. " checks passed"
)
