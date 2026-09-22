-- Run from the repository root: lua tools/tests/shagudps_cache.lua
local now = 100
StaticPopupDialogs = {}
YES, NO = "Yes", "No"
table.getn = table.getn or function(t) return #t end
function GetTime() return now end
function GetLocale() return "enUS" end
function UnitAffectingCombat() return false end
function UnitExists() return false end
function GetNumRaidMembers() return 0 end
function GetNumPartyMembers() return 0 end
function UnitName() return "Player" end
DEFAULT_CHAT_FRAME = { AddMessage = function() end }
function CreateFrame()
    return {
        RegisterEvent = function() end,
        UnregisterEvent = function() end,
        SetScript = function(self, name, fn) self[name] = fn end,
    }
end

local function boot(cache)
    ShaguDPS_Cache = nil
    dofile("addon/ShaguDPS/core.lua")
    -- WoW loads saved globals after addon files and before entering the world.
    ShaguDPS_Cache = cache
    ShaguDPS_Playback = { boss = { { _events = { "legacy replay" } } } }
    ShaguDPS.SaveDataToCache()
    assert(ShaguDPS_Cache == cache, "startup must not overwrite the previous save")
    ShaguDPS.LoadDataFromCache()
    assert(ShaguDPS_Playback == nil, "legacy playback must be released")
    return ShaguDPS.data
end

local old = {
    version = 1, timestamp = 100, combat_start_time = 90,
    total_combat_time = 300, small_fight_total_time = 100,
    classes = { Player = "PRIEST", Pet = "Player" },
    damage0 = { Player = { _sum = 1000, _ctime = 20, _tick = 99,
        _overkill = 80, Hit = 1000, _overkill_by_spell = { Hit = 80 } } },
    heal0 = { Player = { _sum = 900, _esum = 600, _ctime = 30,
        Heal = 900, _effective = { Heal = 600 } } },
    damage_taken0 = { Player = { _sum = 70, _history = { { total = 70 } },
        _detail_history = { { damage = 70 } }, _detail_heal_history = { { heal = 12 } } } },
    invalid_damage0 = { Player = { _sum = 80, _ctime = 2, _overkill = 10,
        _by_target = { Enemy = { Hit = 80 } } } },
    death0 = { Player = 2 }, revive0 = { Player = { _total = 3, Ally = 3 } },
    revive_noncombat = { Player = { _total = 1, Ally = 1 } },
    dispel0 = { Player = { _total = 6, _offensive = 2, _defensive = 3,
        ["错误驱散"] = { Ally = { Debuff = 1 } } } },
    interrupt0 = { Player = { _total = 4, Kick = { _total = 4 } } },
    buff_coverage0 = { Player = { _total_time = 300, buff = { [1] = 200 }, debuff = {} } },
    small_fight = { damage = { Player = { _sum = 200, _ctime = 4, Hit = 200 } } },
    damage1 = { Player = { _sum = 999 } },
    boss_fights = { { damage = { Player = { _sum = 999 } } } },
    recent_fights = { { name = "Old fight" } }, all_death_replays = { "old death" },
}
local d = boot(old)
assert(d.damage[0].Player._sum == 1000 and d.damage[0].Player._ctime == 20)
assert(d.damage[0].Player._tick == nil and d.damage[0].Player._overkill == 80)
assert(d.heal[0].Player._esum == 600 and d.heal[0].Player._effective.Heal == 600)
assert(d.death[0].Player == 2 and d.revive[0].Player._total == 3)
assert(d.dispel[0].Player._offensive == 2 and d.dispel[0].Player["错误驱散"].Ally.Debuff == 1)
assert(d.interrupt[0].Player._total == 4 and d.buff_coverage[0].Player.buff[1] == 200)
assert(d.total_combat_time == 310 and d.combat_start_time == 0)
assert(d.damage[0].Player._sum - d.small_fight.damage.Player._sum == 800)
assert(d.revive_noncombat.Player._total == 1 and d.classes.Pet == "Player")
assert(next(d.damage_taken[0].Player._history) == nil)
assert(d.damage_taken[0].Player._detail_history == nil)
assert(d.damage_taken[0].Player._detail_heal_history == nil)
assert(next(d.invalid_damage[0].Player._by_target) == nil)
assert(next(d.damage[1]) == nil and next(ShaguDPS.boss_fights) == nil)
assert(ShaguDPS_Cache.boss_fights == nil and ShaguDPS_Cache.recent_fights == nil)
assert(ShaguDPS_Cache.all_death_replays == nil and ShaguDPS_Cache.damage1 == nil)
assert(old.damage_taken0.Player._history[1].total == 70, "migration must copy its input")

-- New combat can grow live detail tables without growing the persistence snapshot.
d.damage[0].Player._sum = 1200
d.damage_taken[0].Player._history[1] = { total = 99 }
d.invalid_damage[0].Player._by_target.NewEnemy = { Hit = 5 }
assert(ShaguDPS_Cache.damage0.Player._sum == 1000)
assert(next(ShaguDPS_Cache.damage_taken0.Player._history) == nil)
assert(not ShaguDPS.LoadDataFromCache() and d.damage[0].Player._sum == 1200,
    "zoning must not restore an older snapshot over current combat")
ShaguDPS.playback.current = { Player = { _events = { "session replay" } } }
ShaguDPS.SaveDataToCache()
assert(ShaguDPS.playback.current.Player._events[1] == "session replay")
assert(next(ShaguDPS_Cache.invalid_damage0.Player._by_target) == nil)
d = boot(ShaguDPS_Cache)
assert(d.damage[0].Player._sum == 1200 and d.total_combat_time == 310)
assert(d.heal[0].Player._sum - d.heal[0].Player._esum == 300)
assert(d.damage[0].Player._sum / d.damage[0].Player._ctime == 60)
assert(ShaguDPS.playback.current == nil and next(ShaguDPS.playback.recent) == nil)

-- Exercise the actual logout path: unfinished combat must finalize once, including
-- trash classification and coverage, so the next login retains valid denominators.
dofile("addon/ShaguDPS/parser.lua")
local parser = ShaguDPS.parser
parser:AddData("Player", "Hit", "Enemy", 50, 1, "damage")
assert(d.damage[0].Player._sum == 1250 and d.damage[0].Player._ctime == 20,
    "base parser must continue restored totals without reusing the previous session clock")
ShaguDPS.hasNampower = true
parser.combat.oldstate = "COMBAT"
d.combat_start_time = 80
d.damage[1].Player = { _sum = 50, _ctime = 2, Hit = 50 }
d.buff_coverage[1].Player = { _total_time = 0, buff = {}, debuff = {} }
ShaguDPS.buff_coverage_active.Player = { buff = { [1] = 80 }, debuff = {} }
this, event = parser.combat, "PLAYER_LOGOUT"
parser.combat.OnEvent()
assert(ShaguDPS_Cache.total_combat_time == 330)
assert(ShaguDPS_Cache.small_fight_total_time == 120)
assert(ShaguDPS_Cache.small_fight.damage.Player._sum == 250)
assert(ShaguDPS_Cache.buff_coverage0.Player.buff[1] == 220)
assert(ShaguDPS_Cache.buff_coverage0.Player._total_time == 320)
parser.combat.OnEvent()
assert(ShaguDPS_Cache.total_combat_time == 330, "logout must not count the fight twice")
assert(ShaguDPS_Cache.damage0.Player._sum == 1250)

d = boot(nil)
assert(next(d.damage[0]) == nil)
ShaguDPS.SaveDataToCache()
assert(ShaguDPS_Cache.version == 2)
print("PASS ShaguDPS cache: aggregate migration, snapshot isolation, zoning, reload and combat logout")
