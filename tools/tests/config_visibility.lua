-- Run from repository root: lua tools/tests/config_visibility.lua
-- Exercises real filtering, row layout and search with a minimal UI surface.
table.getn = table.getn or function(t) return #t end
getn, unpack = table.getn, unpack or table.unpack
strfind, strlower, strlen = string.find, string.lower, string.len
local framesCreated = 0
local function noop() end
local function fire(frame, event)
  local saved = this; this = frame
  if frame.scripts[event] then frame.scripts[event]() end
  this = saved
end
local function frame(parent)
  framesCreated = framesCreated + 1
  local f = { parent = parent, shown = true, scripts = {}, width = 700, height = 22 }
  setmetatable(f, { __index = function(self, key)
    if string.find(key, "^Set") or string.find(key, "^Enable") or string.find(key, "^Register") then return noop end
  end })
  function f:GetParent() return self.parent end
  function f:SetParent(value) self.parent = value end
  function f:SetScript(event, callback) self.scripts[event] = callback end
  function f:GetScript(event) return self.scripts[event] end
  function f:Show() local changed = not self.shown; self.shown = true; if changed then fire(self, "OnShow") end end
  function f:Hide() local changed = self.shown; self.shown = false; if changed then fire(self, "OnHide") end end
  function f:IsShown() return self.shown end
  function f:IsVisible() return self.shown and (not self.parent or self.parent:IsVisible()) end
  function f:Click() fire(self, "OnClick") end
  function f:SetPoint(point, relative, relativePoint, x, y)
    if type(relative) == "number" then x, y, relative, relativePoint = relative, relativePoint, self.parent, point end
    self.point = {point, relative, relativePoint, x or 0, y or 0}
  end
  function f:GetPoint() return unpack(self.point or {"TOPLEFT", self.parent, "TOPLEFT", 0, 0}) end
  function f:ClearAllPoints() self.point = nil end
  function f:SetWidth(value) self.width = value end
  function f:SetHeight(value) self.height = value end
  function f:GetWidth() return self.width end
  function f:GetHeight() return self.height end
  function f:GetRight() return 720 end
  function f:GetLeft() return 0 end
  function f:GetFrameLevel() return 1 end
  function f:SetText(value) self.textValue = value end
  function f:GetText() return self.textValue or "" end
  function f:GetStringHeight() return 24 end
  function f:CreateTexture() return frame(self) end
  function f:CreateFontString() return frame(self) end
  function f:GetFontString() return self.fontString end
  function f:UpdateScrollChildRect() end
  function f:UpdateScrollState() end
  function f:Scroll() end
  function f:ClearFocus() end
  return f
end
function CreateFrame(_, name, parent)
  local f = frame(parent); if name then _G[name] = f end; return f
end
function CreateBackdrop(f) f.backdrop = f.backdrop or frame(f) end
function CreateBackdropShadow() end
function CreateScrollFrame(_, parent) return frame(parent) end
function CreateScrollChild(_, parent) return frame(parent) end
function SkinButton(f) f.fontString = frame(f) end
SetAllPointsOffset = noop
function CreateDropDownButton(_, parent)
  local f = frame(parent); f.menuframe, f.text = frame(f), frame(f)
  function f:SetMenu(callback) self.callback = callback; self:UpdateMenu() end
  function f:UpdateMenu() self.menu = self.callback() end
  function f:SetSelection(id) self.id = id end
  function f:HideMenu() self.menuframe:Hide() end
  return f
end
function strsplit(delimiter, value)
  local parts = {}; for item in string.gmatch(value .. delimiter, '(.-)' .. delimiter) do parts[#parts + 1] = item end
  return unpack(parts)
end
function QueueFunction(callback) callback() end
function GetLocale() return "zhCN" end
function GetTime() return 0 end
function GetCVar() return "0" end
UIParent, UISpecialFrames, SlashCmdList = frame(), {}, {}
T = setmetatable({}, {__index = function(_, key) return key end})
ITEM_QUALITY_COLORS = {}
for i = 0, 7 do ITEM_QUALITY_COLORS[i] = {hex = ""}; _G["ITEM_QUALITY" .. i .. "_DESC"] = tostring(i) end
FONT_COLOR_CODE_CLOSE, NONE = "", "None"
local function config(values) return setmetatable(values or {}, {__index = function() return "0" end}) end
C = {global = config({font_size = 12, language = "zhCN"}), gui = config(),
  nameplates = config({notargalpha = ".25", name = config(), debuffs = config()}),
  unitframes = config({player = config({portrait = "left"})}),
  chat = {right = config({enable = "1"}), left = config(), text = config(), global = config(), bubbles = config()},
}
pfUI_config = C
pfUI = { api = {CreateBackdrop = CreateBackdrop}, modules = {}, skins = {}, version = { string = "test" }, expansion = "vanilla",
  media = setmetatable({}, {__index = function(_, key) return key end}),
  RegisterModule = function(_, _, _, callback) callback() end,
  ShouldUseSingleChatFrame = function() return false end,
  chat = {left = {aeuiBookRuntimeVersion = "1.22"}}, uf = {},
}
dofile("addon/AzerothExpeditionUI/Core/Bootstrap.lua")
local addon = AzerothExpeditionUI
addon.db = { unitframes = {enabled = true}, chat = {enabled = true}, actionbars = {},
  quests = {}, map = {}, character = {}, tooltips = {}, bagshui = {}, gearplanner = {enabled = true} }
addon.modules.Chat = {}
local profile = {mode = "dps"}
local units = {
  GetNameplateProfile = function() return profile end,
  IsPortraitConfigurationEnabled = function() return addon.db.unitframes.enabled end,
  GetPortraitConfigKey = function(_, category) return category == C.unitframes.player and "player" or nil end,
}
addon.modules.UnitFrames = units
pfUI.nameplates = {combatMode = "dps", combatPolicy = units}
local state = addon:GetManagedConfigState()
assert(addon:ShouldHidePfUISetting(C.nameplates, "targetzoom", state))
assert(not addon:ShouldHidePfUISetting(C.nameplates, "combatofftanks", state))
assert(not addon:ShouldHidePfUISetting(C.nameplates, "showfriendly", state))
assert(not addon:ShouldHidePfUISetting(C.nameplates, "clickthrough", state))
assert(not addon:ShouldHidePfUISetting(C.nameplates.debuffs, "blacklist", state))
assert(addon:ShouldHidePfUISetting(C.unitframes.player, "portrait", state))
assert(not addon:ShouldHidePfUISetting(C.unitframes.player, "width", state))
assert(not addon:ShouldHidePfUISetting(C.global, "font_size", state))
local provider = pfUI.nameplates; pfUI.nameplates = nil
assert(not addon:ShouldHidePfUISetting(C.nameplates, "targetzoom"))
pfUI.nameplates = provider
addon.db.chat.enabled = false
assert(not addon:ShouldHidePfUISetting(C.chat.text, "input_width"))
assert(not addon:ShouldHidePfUISetting(C.chat.right, "enable"))
pfUI.ShouldUseSingleChatFrame = function() return true end
assert(addon:ShouldHidePfUISetting(C.chat.right, "enable"), "native single-chat rule still controls this")
addon.db.chat.enabled = true

-- The real load order is pfUI GUI first, then its dependent AEUI addon.
AzerothExpeditionUI = nil
dofile("addon/pfUI/modules/gui.lua")
local gui = pfUI.gui
assert(not gui.frames.AEUI)
AzerothExpeditionUI = addon
gui:Show()
assert(gui.frames.AEUI and gui.frames.AEUI["常用"])
local menuCount = gui.frames.area.count
gui:AddAEUIEntries()
assert(gui.frames.area.count == menuCount, "AEUI pages must be registered once")
local function openPage(name, title)
  local button = title and gui.frames[name][title] or gui.frames[name]
  button.area:Show()
  local page = button.area.scroll.content
  fire(page, "OnShow")
  return page
end
local function entry(page, category, key)
  for _, f in ipairs(page.aeuiConfigEntries) do
    if f.aeuiConfig.category == category and f.aeuiConfig.key == key then return f end
  end
end
local page = openPage("Nameplates")
local zoom = entry(page, C.nameplates, "targetzoom")
local width = entry(page, C.nameplates, "width")
local widthY = width.aeuiConfig.anchor[5]
assert(not zoom:IsShown() and width:IsShown())
assert(width.point[5] > widthY, "hidden rows must not leave gaps")
local initialCount = framesCreated
for i = 1, 10 do
  pfUI.nameplates.combatMode = nil; profile.mode = "off"; gui:RefreshConfigVisibility()
  assert(zoom:IsShown())
  local offY = width.point[5]
  pfUI.nameplates.combatMode = "dps"; profile.mode = "dps"; gui:RefreshConfigVisibility()
  assert(not zoom:IsShown() and width.point[5] > offY)
end
assert(framesCreated == initialCount, "mode switches must reuse widgets")
assert(C.nameplates.notargalpha == ".25" and C.unitframes.player.portrait == "left" and C.chat.right.enable == "1", "filtering must not mutate settings")
-- Search must lose and regain the same entries without reopening the GUI.
gui.search:SetText("Zoom Target Nameplate")
gui:RefreshSearchResults()
local search = gui.frames["[Search]"].area.scroll.content
assert(not search.results[1] or not search.results[1]:IsShown())
pfUI.nameplates.combatMode = nil; profile.mode = "off"; gui:RefreshConfigVisibility()
assert(search.results[1] and search.results[1]:IsShown())
pfUI.nameplates.combatMode = "dps"; profile.mode = "dps"; gui:RefreshConfigVisibility()
assert(not search.results[1]:IsShown())
local chat = openPage("Chat")
assert(not entry(chat, C.chat.right, "enable"):IsShown())
assert(entry(chat, C.chat.text, "time"):IsShown())
-- New actions execute only on click, and the gear switch controls enablement.
local commands = {}
SlashCmdList.AZEROTHEXPEDITIONUI = function(command)
  commands[#commands + 1] = command
  if command == "gear off" then addon.db.gearplanner.enabled = false end
end
local modules = openPage("AEUI", "模块与回退")
assert(#commands == 0)
local gear
for _, f in ipairs(modules.aeuiConfigEntries) do
  if f.button and string.find(f.button:GetText(), "配装伴随栏") then gear = f.button end
end
assert(gear); gear:Click(); gear:Click()
assert(commands[1] == "gear off" and commands[2] == "gear on")
-- With AEUI absent, ordinary controls return and AEUI-only notes disappear.
AzerothExpeditionUI = nil
gui:RefreshConfigVisibility()
assert(zoom:IsShown())
assert(not entry(chat, "AEUI_NOTE", "singleChat"):IsShown())
AzerothExpeditionUI = addon
print("PASS config visibility: active ownership, fallback, preserved values, compact rows, widget reuse, live search, command actions")
