-- Run: lua tools/tests/craft_layout.lua
-- Execute the shared Turtle layout against both native control name families.
local file = assert(io.open('addon/pfUI/skins/blizzard/professions.lua'))
local source = file:read('*a'); file:close()
local block = assert(source:match('elseif turtleSearch then %-%- Turtle WoW workbench\n(.-)      else %-%- vanilla'))
local noop = function() end
local function widget(width)
  return {
    width = width, points = {},
    SetHeight = function(self, v) self.height = v end,
    SetWidth = function(self, v) self.width = v end,
    ClearAllPoints = function(self) self.points = {} end,
    SetPoint = function(self, point, ...) self.points[point] = {...} end,
    SetTextInsets = noop, SetTextColor = noop,
  }
end
StripTextures, CreateBackdrop, WorkbenchPanel = noop, noop, noop
SkinCheckbox = function(self, size) self.width, self.height = size, size end
math.mod = math.mod or math.fmod
local names = {'frame','title','close','scrollframe','collapseall','subclassdropdown','invslotdropdown',
  'turtleSearch','detailscroll','detailscrollchild','rankbar','seltitle','reagentlabel','cancel',
  'create','createall','decrease','inputbox','increase','icon'}
local run = assert(load('return function(name,turtlePrefix,displayed,maxreagents,' .. table.concat(names, ',') .. ')\n'
  .. block .. '\nend'))()
for _, name in ipairs({'Craft', 'TradeSkill'}) do
  local prefix = name == 'Craft' and 'CraftFrame' or 'TradeSkill'
  local controls, args = {}, {}
  for _, key in ipairs(names) do
    controls[key] = widget()
    args[#args+1] = controls[key]
  end
  local c = controls
  c.scrollframe.backdrop, c.detailscroll.backdrop = widget(), widget()
  _G[name .. 'RankFrameSkillRank'] = widget()
  for _, suffix in ipairs({'Mats', 'Skill'}) do _G[prefix .. suffix .. 'CheckButton'] = widget() end
  MAX_REAGENTS = 8
  for i = 1, 8 do
    _G[name .. 'Reagent' .. i] = widget()
    _G[name .. 'Reagent' .. i .. 'Name'] = widget()
  end
  run(name, prefix, 'DISPLAYED', 'MAX_REAGENTS', table.unpack(args))
  assert(DISPLAYED * 16 <= c.scrollframe.height, 'recipe rows exceed list')
  assert(132 + c.scrollframe.height + 5 + 5 + c.turtleSearch.height <= c.frame.height - 28,
    'search collides with bottom rim')
  assert(c.turtleSearch.points.TOPLEFT[1] == c.scrollframe.backdrop, 'search must follow list bottom')
  assert(2 * _G[name .. 'Reagent1'].width + 6 + 5 <= c.detailscroll.width, 'materials reach scrollbar')
  assert(_G[name .. 'Reagent7'].points.TOPLEFT[1] == _G[name .. 'Reagent5'], 'seventh reagent must start left column')
  assert(_G[name .. 'Reagent8'].points.TOPLEFT[1] == _G[name .. 'Reagent7'], 'eighth reagent must stay right column')
  for _, suffix in ipairs({'Mats', 'Skill'}) do
    local checkbox = _G[prefix .. suffix .. 'CheckButton']
    assert(checkbox.points.TOPLEFT[1] == c.frame and checkbox.points.TOPLEFT[4] == -50,
      'native filters must leave the recipe/detail area')
  end
  assert(c.cancel.points.TOPRIGHT[4] == -504, 'footer must be below details')
  assert(504 + 22 <= c.frame.height - 16, 'footer outside panel')
  _G[prefix .. 'MatsCheckButton'], _G[prefix .. 'SkillCheckButton'] = nil, nil
  run(name, prefix, 'DISPLAYED', 'MAX_REAGENTS', table.unpack(args))
end
print('PASS professions: both native layouts, search, filters, eight reagents and footer bounds')
