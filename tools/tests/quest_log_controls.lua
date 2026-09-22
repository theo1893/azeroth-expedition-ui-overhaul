-- Run: lua tools/tests/quest_log_controls.lua
-- Check provider refreshes and real selection indices; game rendering is separate.
table.getn = table.getn or function(t) return #t end
unpack = unpack or table.unpack
local methods = {}
local function widget(kind, name)
  local w = setmetatable({ kind = kind, name = name, shown = true,
    enabled = 1, scripts = {}, points = {}, color = { 1, 1, 1, 1 } }, { __index = methods })
  if kind == "Button" then w.text = widget("FontString") end
  if name then _G[name] = w end
  return w
end
function methods:GetName() return self.name end
function methods:GetFontString() return self.text end
function methods:GetRegions() return self.text end
function methods:GetObjectType() return self.kind end
function methods:IsObjectType(kind) return self.kind == kind end
function methods:SetWidth(value) self.width = value end
function methods:SetHeight(value) self.height = value end
function methods:GetWidth() return self.width or 0 end
function methods:GetHeight() return self.height or 0 end
function methods:SetPoint(...) table.insert(self.points, {...}) end
function methods:ClearAllPoints() self.points = {} end
function methods:SetAllPoints(value) self.allPoints = value end
function methods:SetParent(value) self.parent = value end
function methods:SetText(value)
  if self.text then self.text:SetText(value) else self.value = value end
end
function methods:GetText() return self.text and self.text:GetText() or self.value end
function methods:SetFont(path, size, flags) self.font = {path, size, flags} end
function methods:GetFont() return unpack(self.font or { "native", 12, "OUTLINE" }) end
function methods:SetTextColor(...) self.color = {...} end
function methods:GetTextColor() return unpack(self.color) end
function methods:SetShadowColor(...) self.shadow = {...} end
function methods:SetShadowOffset(...) self.shadowOffset = {...} end
function methods:SetBackdrop(value) self.legacyBackdrop = value end
function methods:SetBackdropColor(...) self.backdropColor = {...} end
function methods:SetBackdropBorderColor(...) self.backdropBorderColor = {...} end
function methods:SetSpacing(value) self.spacing = value end
function methods:SetJustifyH(value) self.justifyH = value end
function methods:SetTexture(...)
  self.texture = {...}
  if self.failTexture then return nil end -- Vanilla texture-load failure
  return 1
end
function methods:SetPushedTextOffset(...) self.pushedTextOffset = {...} end
function methods:SetTexCoord(...) self.texcoord = {...} end
function methods:SetVertexColor(...) self.color = {...} end
function methods:SetAlpha(value) self.alpha = value end
function methods:CreateTexture() return widget("Texture") end
function methods:Show() self.shown = true end
function methods:Hide() self.shown = false end
function methods:IsShown() return self.shown end
methods.IsVisible = methods.IsShown
function methods:IsEnabled() return self.enabled end
function methods:SetScript(name, fn) self.scripts[name] = fn end
function methods:GetScript(name) return self.scripts[name] end
function methods:SetID(value) self.id = value end
function methods:GetID() return self.id end
function methods:EnableMouseWheel() end
function methods:SetNormalTexture() end
function methods:SetHighlightTexture() end
function methods:SetPushedTexture() end
function methods:SetDisabledTexture() end
function CreateFrame(kind, name) return widget(kind, name) end
function GetLocale() return "zhCN" end
local selected, offset = 2, 0
function GetQuestLogSelection() return selected end
function GetNumQuestLogEntries() return 30 end
function FauxScrollFrame_GetOffset() return offset end
function GetQuestLogTitle(index) return "Quest " .. index, 60, nil, index == 1, false end
function GetQuestLogLeaderBoard() return "Objective", "item", true end
pfUI = { font_default = "provider-font", expansion = "vanilla" }
AzerothExpeditionUI = { media = {root = "AEUI\\"}, db = { quests = {enabled = true} },
  RegisterModule = function(self, name, module) self[name] = module end }
dofile("addon/AzerothExpeditionUI/Modules/QuestVisualTheme.lua")
dofile("addon/AzerothExpeditionUI/Modules/Quests.lua")
local q = AzerothExpeditionUI.Quests
QuestLogFrame = widget("Frame")
QuestLogListScrollFrame = widget("Frame")
QuestLogTitleText = widget("FontString")
QuestLogQuestCount = widget("FontString")
QuestLogQuestCount:SetText("任务：|cffffffff5/20|r")
QuestLogFrameAbandonButton = widget("Button")
QuestFramePushQuestButton = widget("Button")
QuestFrameExitButton = widget("Button")
QuestLogFrameExpandButton = widget("Button")
local click = function() return "original click" end
QuestLogFrameAbandonButton:SetScript("OnClick", click)

q:UpdateDirectoryRows()
assert(QuestLogTitle2.aeuiQuestSelectedMark.shown)
assert(not QuestLogTitle1.aeuiQuestSelectedMark.shown, "headers must not be selected")
assert(QuestLogTitleText.color[1] > 0.8 and QuestLogTitleText.font[3] == "")
selected, offset = 22, 20
q:UpdateDirectoryRows()
assert(QuestLogTitle2.aeuiQuestSelectedMark.shown, "selection must include the scroll offset")
selected = 24
q:UpdateDirectoryRows()
assert(QuestLogTitle4.aeuiQuestSelectedMark.shown and not QuestLogTitle2.aeuiQuestSelectedMark.shown)
selected = 1
q:UpdateDirectoryRows()
assert(not QuestLogTitle4.aeuiQuestSelectedMark.shown, "off-screen selection must clear recycled rows")
assert(not QuestLogTitle19.shown)

pfQuest = {}
for _, name in ipairs({ "buttonOnline", "buttonLanguage", "buttonShow", "buttonHide", "buttonClean", "buttonReset" }) do
  local b = widget("Button")
  b.txt = b.text
  b:SetScript("OnClick", click)
  if name ~= "buttonOnline" and name ~= "buttonLanguage" then
    -- pfQuest calls pfUI SkinButton: CreateBackdrop(button, nil, true).
    b:SetBackdrop({ bgFile = "legacy fill", edgeFile = "legacy black border" })
    b:SetScript("OnEnter", function() (b.backdrop or b):SetBackdropBorderColor(1, .2, .2, 1) end)
    b:SetScript("OnLeave", function() (b.backdrop or b):SetBackdropBorderColor(0, 0, 0, 1) end)
  end
  pfQuest[name] = b
end
local update = function() pfQuest.buttonLanguage.txt:SetText("|cff3333ff[Chinese (Simplified)]|r") end
pfQuest.buttonLanguage:SetScript("OnUpdate", update)
pfQuest.buttonOnline:SetID(7786)
q:ApplyPfQuestQuestLogCompatibility()
for _, name in ipairs({ "buttonShow", "buttonHide", "buttonClean", "buttonReset" }) do
  local b = pfQuest[name]
  assert(b.legacyBackdrop == nil, "pfUI's direct Button backdrop must be removed")
  b:GetScript("OnEnter")()
  b:GetScript("OnLeave")()
  assert(b.legacyBackdrop == nil and b.aeuiQuestActionArt.shown,
    "provider hover colors must not resurrect the black frame or hide the leather")
  assert(b:GetScript("OnClick") == click)
end
update()
pfQuest.buttonOnline.txt:SetText("|cff000000[|cffaa2222id: 7786|cff000000]")
assert(pfQuest.buttonLanguage.txt:GetText() == "[简体中文]")
assert(pfQuest.buttonOnline.txt:GetText() == "ID 7786")
assert(pfQuest.buttonOnline:GetID() == 7786)
assert(pfQuest.buttonLanguage:GetScript("OnUpdate") == update)
assert(pfQuest.buttonShow:GetScript("OnClick") == click)
assert(pfQuest.buttonShow:GetText() == "显示标记" and pfQuest.buttonReset:GetText() == "重置标记")
assert(pfQuest.buttonLanguage.txt.justifyH == "CENTER")
pfQuest.buttonShow.enabled = 0
q:ApplyPfQuestQuestLogCompatibility()
assert(pfQuest.buttonShow.aeuiQuestActionArt.shown and not pfQuest.buttonShow.aeuiQuestLeatherDisabled.shown)
assert(pfQuest.buttonShow.aeuiQuestActionArt.texcoord[1] == 390 / 512, "disabled atlas state must be selected")
assert(pfQuest.buttonShow.enabled == 0, "styling must not change enabled state")
local setter = pfQuest.buttonLanguage.txt.SetText
q:ApplyPfQuestQuestLogCompatibility()
assert(pfQuest.buttonLanguage.txt.SetText == setter, "text hook must be installed only once")
pfQuest.buttonShow = nil
q:ApplyPfQuestQuestLogCompatibility()
assert(pfQuest.buttonHide.points[1][1] == "BOTTOMLEFT", "missing first button must not drop its siblings")

q:ApplyFrameGeometry()
assert(QuestLogQuestCount:GetText() == "任务：5/20")
QuestLogQuestCount:SetText("任务：|cffffffff6/20|r")
assert(QuestLogQuestCount:GetText() == "任务：6/20", "late count refresh must remain readable")
assert(QuestLogFrameAbandonButton:GetScript("OnClick") == click)
assert(QuestLogFrameAbandonButton.text.color[1] == AzerothExpeditionUI.questVisualTheme.ink.control.danger[1])
assert(QuestFramePushQuestButton.text.font[2] == pfQuest.buttonHide.txt.font[2])
assert(QuestLogFrameAbandonButton.points[1][5] == 38)
assert(QuestLogFrameExpandButton.width == 50 and QuestFrameExitButton.height == 20)
assert(QuestLogFrameAbandonButton.aeuiQuestActionTabWidth == 64)
assert(not QuestLogFrameAbandonButton.aeuiQuestLeatherBase.shown, "legacy rectangle must not show through alpha")
assert(pfQuest.buttonLanguage.aeuiQuestActionArt == nil, "top utility controls are outside footer ownership")
local footer = QuestLogFrameAbandonButton
footer:GetScript("OnEnter")()
assert(footer.aeuiQuestActionArt.texcoord[1] == .25, "hover must use its own atlas cell")
footer:GetScript("OnMouseDown")("LeftButton")
assert(footer.aeuiQuestActionArt.texcoord[1] == .5)
assert(footer.aeuiQuestActionArt.points[1][5] == -1 and footer.pushedTextOffset[2] == -1)
assert(footer.width == 64 and footer.height == 20, "press must not change the hitbox")
footer:GetScript("OnMouseUp")("LeftButton")
footer:GetScript("OnLeave")()
assert(footer.aeuiQuestActionArt.texcoord[1] == 0 and footer.aeuiQuestActionArt.points[1][5] == 0)
footer.aeuiQuestActionArt.failTexture = true
q:ApplyControlVisuals()
assert(footer.aeuiQuestActionTabWidth == nil and footer.aeuiQuestLeatherBase.shown)
assert(not footer.aeuiQuestActionArt.shown, "missing texture must restore the working legacy skin")
footer.aeuiQuestActionArt.failTexture = nil
q:ApplyControlVisuals()
assert(footer.aeuiQuestActionTabWidth == 64 and not footer.aeuiQuestLeatherBase.shown)
QuestLogDetailScrollFrame = widget("Frame")
q:UpdateDetailToggle()
assert(QuestLogFrameExpandButton:GetText() == "收起详情")
QuestLogDetailScrollFrame:Hide()
q:UpdateDetailToggle()
assert(QuestLogFrameExpandButton:GetText() == "展开详情")

QuestLogQuestDescription = widget("FontString")
QuestLogObjective1 = widget("FontString")
QuestLogMoneyFrameGoldButton = widget("Button")
QuestLogRequiredMoneyFrameGoldButton = widget("Button")
QuestLogRequiredMoneyFrameGoldButton.text:SetTextColor(1, 0, 0, 1)
q:ApplyDetailTextTheme()
assert(QuestLogQuestDescription.spacing == 3 and QuestLogObjective1.spacing == 2)
assert(QuestLogMoneyFrameGoldButton.text.font[3] == "")
assert(QuestLogMoneyFrameGoldButton.text.color[1] < 0.2)
assert(QuestLogRequiredMoneyFrameGoldButton.text.color[1] == 1, "required-money warning must survive")
local languageText = pfQuest.buttonLanguage.txt
pfQuest = nil
q:ApplyPfQuestQuestLogCompatibility() -- Missing provider remains safe.
AzerothExpeditionUI.db.quests.enabled = false
local raw = "|cff3333ff[Chinese (Simplified)]|r"
-- Existing hook must pass provider data through when ownership is disabled.
languageText:SetText(raw)
assert(languageText:GetText() == raw)
print("PASS quest log controls: selection, provider refresh, atlas states, unchanged hitboxes/scripts and fallback")
