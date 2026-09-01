local function read(path)
  local file = assert(io.open(path, "rb"))
  local value = file:read("*a")
  file:close()
  return value
end

local source = read("addon/pfUI/modules/swingtimer.lua")
local core = read("addon/DoiteDPS/Core.lua")
local arms = read("addon/DoiteDPS/Profiles/WarriorArms.lua")
local protection = read("addon/DoiteDPS/Profiles/WarriorProtection.lua")

local function has(text)
  return source:find(text, 1, true)
end

assert(has('events:RegisterEvent("PLAYER_ENTER_COMBAT")'))
assert(has('events:RegisterEvent("PLAYER_LEAVE_COMBAT")'))
assert(not has("START_AUTOATTACK"))
assert(not has("STOP_AUTOATTACK"))
assert(source:match('if event == "AUTO_ATTACK_SELF" then%s+S%.autoAttackActive = true'))
assert(source:match('elseif event == "PLAYER_ENTER_COMBAT" then%s+S%.autoAttackActive = true'))
assert(source:match('elseif event == "PLAYER_LEAVE_COMBAT" then%s+S%.autoAttackActive = false'))

local resetMH = assert(source:match(
  "local function ResetMH%(reason%)%s*(.-)%s*local function ResetOH"
))
assert(resetMH:find("S.raActive = false", 1, true))
assert(resetMH:find("pfUI.swingtimer.ranged:Hide()", 1, true))

local enterCombat = assert(source:match(
  'elseif event == "PLAYER_ENTER_COMBAT" then(.-)elseif event == "PLAYER_LEAVE_COMBAT" then'
))
assert(enterCombat:find("S.raActive = false", 1, true))
assert(enterCombat:find("pfUI.swingtimer.ranged:Hide()", 1, true))
assert(not enterCombat:find("ResetMH()", 1, true))
assert(not enterCombat:find("ResetOH()", 1, true))
assert(not enterCombat:find("ResetRanged()", 1, true))

-- One append-only file per client session; no in-game log reader or ring cap.
assert(has('S.traceFile = "ddps-swing-" .. sessionStamp .. ".log"'))
assert(has("math.floor(time() - GetTime() + 0.5)"))
assert(has("math.abs(tonumber(traceCache.sessionEpoch) - estimatedSessionEpoch) <= 2"))
assert(has('pcall(WriteCustomFile, S.traceFile, header, "a")'))
assert(has('pcall(WriteCustomFile, fileName, line, "a")'))
assert(not has("ReadCustomFile"))
assert(not has("CustomFileExists"))
assert(has('Trace("STALL_ENTER"'))
assert(has('Trace("STALL_EXIT"'))
assert(has("decision=reject_noaction"))
assert(not has("decision=reject_early_extra"))
assert(has('ResetOH("auto_attack_self")'))
assert(has('ResetMH("auto_attack_self")'))
assert(has("AppendTrace"))
assert(core:find("function D:TraceSwingExecution", 1, true))
assert(core:find('pcall(api.AppendTrace, "DDPS_EXECUTE", detail)', 1, true))
assert(arms:find('D:TraceSwingExecution("arms"', 1, true))
assert(protection:find('D:TraceSwingExecution("protection"', 1, true))

print("swingtimer auto-attack events: PASS")
