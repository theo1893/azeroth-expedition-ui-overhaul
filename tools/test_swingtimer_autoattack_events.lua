local file = assert(io.open("addon/pfUI/modules/swingtimer.lua", "rb"))
local source = file:read("*a")
file:close()

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
  "local function ResetMH%(%)%s*(.-)%s*local function ResetOH"
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

print("swingtimer auto-attack events: PASS")
