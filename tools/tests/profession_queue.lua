-- Run: lua tools/tests/profession_queue.lua
local file = assert(io.open('addon/pfUI/skins/blizzard/professions.lua'))
local source = file:read('*a'); file:close()
local queueSource = assert(source:match('(%-%- Recipe planning is independent.*)'))
local loadQueue = assert(load(queueSource))
pfUI = {RegisterModule=function() end}
loadQueue()
local plan = pfUI.professionQueue.Plan
local function recipe(id, yield, reagents)
  local result={id=id,name='item'..id,yield=yield,reagents={}}
  for key,count in pairs(reagents) do table.insert(result.reagents,{id=key,name='item'..key,count=count}) end
  return result
end
local b=recipe(2,2,{[3]=3})
local a=recipe(1,1,{[2]=3,[3]=1})
local recipes={[1]=a,[2]=b}
local inventory={[2]=1,[3]=4}
local steps=assert(plan(a,1,recipes,inventory))
assert(#steps==2 and steps[1].recipe==b and steps[1].count==1 and steps[2].recipe==a)
assert(inventory[2]==1 and inventory[3]==4, 'planning must not mutate inventory')
assert(not plan(a,2,recipes,inventory), 'shared raw materials must not be counted twice')
steps=assert(plan(a,2,recipes,{[2]=6,[3]=2,[1]=100}))
assert(#steps==1 and steps[1].count==2, 'existing intermediates must be used; final quantity is new crafts')
local c=recipe(3,1,{[1]=1})
assert(not plan(a,1,{[1]=a,[2]=b,[3]=c},{}), 'cycle must stop before execution')
b.cooldown=30
assert(not plan(a,1,recipes,{[3]=99}), 'cooldown dependency must fail preflight')
b.cooldown=nil
assert(not plan(a,0,recipes,{}))
assert(not plan(a,1.5,recipes,{}))
local free=recipe(4,1,{})
assert(not plan(free,1001,{[4]=free},{}))
local _, _, materials=plan(a,2,recipes,{[2]=1,[3]=1},true)
assert(materials[3].count==11 and materials[3].owned==1, 'preview must aggregate shared raw material despite shortages')
_, _, materials=plan(a,1,recipes,{[2]=3,[3]=5},true)
assert(materials[3].count==1, 'existing intermediate stock must reduce displayed raw materials')
assert(pfUI.professionQueue.Maximum(a,recipes,{[3]=11})==2, 'make all must include intermediate costs and shared raw materials')
assert(pfUI.professionQueue.Maximum(a,recipes,{})==0)
print('PASS profession queue: dependencies, stock reservation, yield, cycles, cooldown and quantity')

-- Run the actual driver: spell completion alone must not advance the queue.
table.getn = table.getn or function(t) return #t end
local boot, driver, button, updater
pfUI.RegisterModule = function(_, _, _, callback) boot=callback end
loadQueue()
local now, selected, inv, calls = 0, 1, {[3]=4}, {}
local inTimer = false
local protectedDepth, nativePcall = 0, pcall
pcall=function(fn,...)
  protectedDepth=protectedDepth+1
  local result=table.pack(nativePcall(fn,...))
  protectedDepth=protectedDepth-1
  return table.unpack(result,1,result.n)
end
local list={a,b}; a.reagents={{id=2,name='B',count=2},{id=3,name='C',count=1}}
function CreateFrame(_, name)
  local w={scripts={}}
  function w:SetScript(key, fn) self.scripts[key]=fn end
  function w:Show() self.shown=true end
  function w:Hide() self.shown=false end
  function w:SetText(t) self.text=t end
  w.RegisterEvent=function() end
  w.SetWidth=w.RegisterEvent; w.SetHeight=w.RegisterEvent; w.SetPoint=w.RegisterEvent
  if name == 'TradeSkillQueueButton' then button=w
  elseif name == 'pfUIProfessionMaterialsUpdater' then updater=w
  else driver=w end
  return w
end
DEFAULT_CHAT_FRAME={AddMessage=function() end}
TradeSkillFrame={IsShown=function() return true end}
TradeSkillInputBox={GetNumber=function() return 1 end, GetScript=function() end, SetScript=function() end}
local summary={GetBottom=function() return 60 end,SetWidth=function() end,SetJustifyH=function() end,SetTextColor=function() end,
  ClearAllPoints=function() end,SetPoint=function() end,SetText=function(self,text) self.text=text end}
TradeSkillDetailScrollChildFrame={CreateFontString=function() return summary end,GetTop=function() return 500 end,
  GetHeight=function(self) return self.height or 150 end, SetHeight=function(self,value) self.height=value end}
TradeSkillDetailScrollFrame={UpdateScrollChildRect=function() end}
math.mod=math.mod or math.fmod
local compatFile = assert(io.open('addon/pfUI/compat/vanilla.lua'))
local compatSource = compatFile:read('*a'); compatFile:close()
pfUI.hooks = {}
assert(load(assert(compatSource:match('(function hooksecurefunc.-)\ndo %-%- GetItemInfo'))))()

local function control()
  return {scripts={},SetText=function(self,t) self.text=t end,SetScript=function(self,key,fn) self.scripts[key]=fn end,
    Enable=function(self) self.enabled=true end,Disable=function(self) self.enabled=false end}
end
TradeSkillCreateButton,TradeSkillCreateAllButton=control(),control()
pfUI_config={disabled={}}
HookAddonOrVariable=function(_, fn) fn() end
GetTime=function() return now end
GetNetStats=function() return 0,0,100 end
GetTradeSkillLine=function() return 'Engineering' end
GetTradeSkillSelectionIndex=function() return selected end
GetNumTradeSkills=function() return #list end
GetTradeSkillInfo=function(i) return list[i].name,'optimal',0 end
GetTradeSkillItemLink=function(i) return 'item:'..list[i].id end
GetTradeSkillNumMade=function(i) return list[i].yield end
GetTradeSkillCooldown=function() return nil end
GetTradeSkillNumReagents=function(i) return #list[i].reagents end
GetTradeSkillReagentInfo=function(i,r) local x=list[i].reagents[r]; return x.name,nil,x.count,inv[x.id] or 0 end
GetTradeSkillReagentItemLink=function(i,r) return 'item:'..list[i].reagents[r].id end
GetTradeSkillSubClasses=function() end; GetTradeSkillInvSlots=function() end
SetTradeSkillSubClassFilter=function() end; SetTradeSkillInvSlotFilter=function() end
ExpandTradeSkillSubClass=function() end
TradeSkillFrame_SetSelection=function(i) selected=i end
TradeSkillFrame_Search=function() end
GetContainerNumSlots=function(bag) return bag==0 and 3 or 0 end
GetContainerItemLink=function(_, slot) return inv[slot] and 'item:'..slot end
GetContainerItemInfo=function(_, slot) return nil,inv[slot] end
DoTradeSkill=function(i,n) assert(not inTimer, "new recipe requires a hardware click"); assert(protectedDepth==0, 'crafting must run outside the protected check'); assert(selected==i, 'native selection must match the batch'); calls[#calls+1]={i,n} end
SpellStopCasting=function() end
local scheduled={}
QueueFunction=function(fn) scheduled[#scheduled+1]=fn end
local function tick(noClick)
  for i=1,6 do
    now=now+.3
    local tasks=scheduled; scheduled={}
    inTimer=true
    for _,fn in ipairs(tasks) do fn() end
    inTimer=false
  end
  if not noClick and TradeSkillCreateButton.text=="继续制造" then TradeSkillCreateButton.scripts.OnClick() end
end
local function signal(e) event=e; driver.scripts.OnEvent() end
boot(); button.scripts.OnClick()
assert(#calls==1 and calls[1][1]==2, 'B must be issued before A')
signal('SPELLCAST_STOP'); tick()
assert(#calls==1, 'cast stop without inventory confirmation must not advance')
inv[2],inv[3]=2,1; tick()
assert(#calls==2 and calls[2][1]==1, 'confirmed B must advance to A')
signal('SPELLCAST_INTERRUPTED'); tick()
assert(not driver.shown and #calls==2, 'interruption must stop subsequent work')
inv={[3]=4}; calls={}; button.scripts.OnClick()
signal('SPELLCAST_STOP'); inv[2],inv[3]=2,1; tick()
signal('SPELLCAST_STOP'); inv[1],inv[2],inv[3]=1,0,0; tick()
assert(not driver.shown and selected==1 and #calls==2, 'completed chain must restore A')
inv={[3]=4}; calls={}; button.scripts.OnClick(); button.scripts.OnClick(); tick()
assert(not driver.shown and #calls==1, 'user cancellation must stop the chain')
inv={[3]=1}; calls={}; updater.scripts.OnUpdate()
assert(summary.text:find('×4',1,true) and summary.text:find('缺 3',1,true), 'selected recipe must show total raw requirement and deficit')
assert(#calls==0, 'display refresh must never start crafting')
assert(TradeSkillDetailScrollChildFrame.height==452, 'raw material summary must be included in scroll range')
assert(not TradeSkillCreateButton.enabled and not TradeSkillCreateAllButton.enabled, 'insufficient raw materials must disable native buttons')
inv={[3]=9}; calls={}; updater.scripts.OnUpdate()
assert(TradeSkillCreateButton.enabled and TradeSkillCreateAllButton.enabled, 'native buttons must allow craftable missing intermediates')
TradeSkillCreateButton.scripts.OnClick()
assert(calls[1][1]==2, 'native create must craft dependency B first')
TradeSkillCreateAllButton:Enable()
assert(not TradeSkillCreateAllButton.enabled, 'native refresh must not enable another batch while active')
TradeSkillCreateAllButton.scripts.OnClick()
assert(#calls==1, 'repeat click must not start another batch')
button.scripts.OnClick()
inv={[3]=9}; calls={}; TradeSkillCreateAllButton.scripts.OnClick()
for i=1,2 do
  local recipe=list[calls[i][1]]
  local count=calls[i][2]
  assert(count==2, "identical dependencies must use one native batch")
  for completed=1,count do
    for _,r in ipairs(recipe.reagents) do inv[r.id]=(inv[r.id] or 0)-r.count end
    inv[recipe.id]=(inv[recipe.id] or 0)+recipe.yield
    signal('SPELLCAST_STOP'); tick()
    if completed<count then assert(#calls==i, 'partial native batch must not start next recipe') end
  end
end
assert(inv[1]==2 and inv[3]==1 and #calls==2 and not driver.shown,
  'native make-all must produce maximum A after dependencies, without overspending stock')
-- Missing SPELLCAST_STOP: both production deltas still advance safely.
inv={[3]=4}; calls={}; TradeSkillCreateButton.scripts.OnClick()
inv[2]=2; tick()
assert(#calls==1, 'received output without ingredient consumption must not advance')
inv[3]=1; tick()
assert(#calls==2 and calls[2][1]==1, 'missing cast-stop must not stall completed dependency')
inv[1],inv[2],inv[3]=1,0,0; tick()
assert(not driver.shown and #calls==2, 'missing cast-stop must not stall final product')
-- Native batch can still be casting after both inventory deltas arrive.
inv={[3]=4}; calls={}; TradeSkillCreateButton.scripts.OnClick()
GetCurrentCastingInfo=function() return 1,0,0,1,0 end
inv[2],inv[3]=2,1; tick()
assert(#calls==1, 'next recipe must wait for native cast state to clear')
GetCurrentCastingInfo=function() return 0,0,0,0,0 end
tick()
assert(#calls==2 and calls[2][1]==1, 'idle native batch must hand off to the final recipe')
inv[1],inv[2],inv[3]=1,0,0; tick()
assert(not driver.shown and #calls==2, 'handoff must not duplicate final product')
-- No hardware click: preparation must pause without calling DoTradeSkill again.
inv={[3]=4}; calls={}; TradeSkillCreateButton.scripts.OnClick()
inv[2],inv[3]=2,1; tick(true)
assert(#calls==1 and selected==1 and TradeSkillCreateButton.text=='继续制造', 'handoff must select A and wait for a real click')
now=now+60; tick(true)
assert(#calls==1 and TradeSkillCreateButton.enabled, 'waiting for click must not issue requests or time out')
TradeSkillCreateButton.scripts.OnClick()
assert(#calls==2 and calls[2][1]==1, 'continue click must start the preserved A batch')
inv[1],inv[2],inv[3]=1,0,0; tick(true)
assert(not driver.shown and #calls==2)
pcall=nativePcall
print('PASS queue driver: B then A, inventory confirmation, interruption, completion and cancellation')
