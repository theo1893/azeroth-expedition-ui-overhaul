-- Run: lua tools/tests/gearplanner_stats.lua
table.getn = table.getn or function(t) return #t end
SlashCmdList = {}
AzerothExpeditionUI = {media={root=""}, RegisterModule=function(self, _, module) self.gear=module end}
dofile('addon/BonusScanner/BonusScanner.lua')
dofile('addon/AzerothExpeditionUI/Modules/GearPlanner.lua')
local gear = AzerothExpeditionUI.gear
gear.statCache = {}
local itemID
function GetItemInfo() return 'Cached item' end
BonusScannerTooltip = {
  ClearLines=function() end,
  SetHyperlink=function(_, link) itemID=tonumber(string.match(link, 'item:(%d+)')) end,
}
-- Use the real single-item scanner and accumulator; fixture replaces tooltip IO.
function BonusScanner:ScanTooltip()
  self:AddValue('DMG', itemID == 1 and 30 or 80)
  if itemID == 3 then
    self.temp.slot = 'Set'
    self:AddValue('DMG', 20)
  end
end
local equippedDetails = {DMG={Set=40, MainHand=30}}
BonusScanner.bonuses_details = equippedDetails
BonusScanner.temp.details = equippedDetails
assert(gear:ScanItem(1).DMG == 30, 'single item must not subtract equipped set bonuses')
assert(gear:ScanItem(2).DMG-gear:ScanItem(1).DMG == 50, 'staff replacement must change spell damage')
assert(gear:ScanItem(3).DMG == 80, 'only the scanned item set lines should be excluded')
gear.statCache = {}
assert(gear:ScanItem(2).DMG == 80, 'prior item set details must not leak into another scan')
assert(equippedDetails.DMG.Set == 40 and equippedDetails.DMG.MainHand == 30,
  'single item scanning must preserve published equipped details')
print('PASS gear stats: staff delta, set isolation, published equipment details')

dofile('addon/BonusScanner/Localization.lua')
-- Lua 5.0 iterates tables directly; emulate that syntax on desktop Lua.
local function iterable(t)
  setmetatable(t, {__call=function(_, _, key) return next(t, key) end})
end
iterable(BONUSSCANNER_PATTERNS_PASSIVE)
for _, pattern in ipairs(BONUSSCANNER_PATTERNS_PASSIVE) do
  if type(pattern.effect) == 'table' then iterable(pattern.effect) end
end
function BonusScanner:ScanTooltip()
  if itemID == 55120 then
    self:ScanLine(BONUSSCANNER_PREFIX_EQUIP .. '法术伤害和治疗效果提高128点。')
  elseif itemID == 4 then
    self:ScanLine(BONUSSCANNER_PREFIX_EQUIP .. '法术伤害和治疗效果增加30。')
  end
end
gear.statCache = {}
local claw, hammer, legacy = gear:ScanItem(55120), gear:ScanItem(55347), gear:ScanItem(4)
assert(claw.DMG == 128 and claw.HEAL == 128, 'live zhCN claw tooltip must count both bonuses once')
assert((hammer.DMG or 0)-claw.DMG == -128 and (hammer.HEAL or 0)-claw.HEAL == -128,
  'replacing the caster claw with a physical hammer removes spell damage and healing')
assert(legacy.DMG == 30 and legacy.HEAL == 30, 'existing tooltip wording must still work')
print('PASS live zhCN tooltip: 55120 to 55347 spell damage/healing delta -128')

BonusScanner.temp = {bonuses={}, details={}, sets={}, set='', slot=''}
BonusScanner:CheckPassive('使你的法术伤害提高最多150点，治疗效果提高最多300点。')
assert(BonusScanner.temp.bonuses.DMG == 150 and BonusScanner.temp.bonuses.HEAL == 300,
  'fixed multi-stat values must be read from the matched rule')
BonusScanner:CheckPassive('使你的有效潜行等级提高1。')
assert(BonusScanner.temp.bonuses.STEALTH == 5, 'fixed scalar values must not be ignored')
BonusScanner:CheckPassive('使你的法术击中敌人的几率提高2%。使你的法术造成致命一击的几率提高2%。使你的法术造成的伤害提高40点。')
assert(BonusScanner.temp.bonuses.SPELLTOHIT == 2 and BonusScanner.temp.bonuses.SPELLCRIT == 2
  and BonusScanner.temp.bonuses.DMG == 190, 'compound fixed rule must count every effect once')
gear.statCache = {}
function GetItemInfo() return nil end
assert(next(gear:ScanItem(55120)) == nil and gear.statCache[55120] == nil,
  'uncached items must not become permanent zero-stat cache entries')
function GetItemInfo() return 'Cached item' end
assert(gear:ScanItem(55120).DMG == 128, 'later scans must recover when item data arrives')
print('PASS fixed-value rules and missing-item cache recovery')
