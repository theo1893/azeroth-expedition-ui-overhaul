-- Run from repository root: lua tools/test_bigwigs_warning_sign.lua
-- Match the 1.12 FontString surface: GetHeight exists, GetStringHeight does not.
local L, now = {}, 100
function L:RegisterTranslations(locale, factory)
    if locale == "enUS" then
        for key, value in pairs(factory()) do L[key] = value end
    end
end
function AceLibrary() return {new = function() return L end} end
BigWigs = {NewModule = function() return {} end}
function GetTime() return now end
dofile("addon/BigWigs/Plugins/WarningSign.lua")

local sign, caption = {}, {}
function sign:Show() self.visible = true end
function sign:Hide() self.visible = false end
function sign:SetScript(_, callback) self.update = callback end
function caption:SetWidth(width) self.width = width end
function caption:SetHeight(height) self.height = height end
function caption:SetText(text) self.value = text end
function caption:GetFont() return "font", 34, "OUTLINE" end
function caption:GetStringWidth()
    return self.value == "亲和即将到来" and 180.5 or 60.25
end
function caption:GetHeight() return self.height == 0 and 34 or self.height end
assert(caption.GetStringHeight == nil)

local plugin = BigWigsWarningSign
plugin.db = {profile = {disabled = false}}
plugin.frames = {anchor = {}, sign = sign}
plugin.texture = {SetTexture = function() end}
plugin.text = caption
plugin:BigWigs_ShowWarningSign("icon", 3, false, "亲和即将到来")
assert(sign.visible and plugin.db.profile.isVisible, "warning must reach Show on the 1.12 API")
assert(caption.value == "亲和即将到来", "caption must keep its final character")
assert(caption.width > caption:GetStringWidth(), "caption needs horizontal glyph room")
assert(caption.height >= 34, "caption must fit the active font")
local longWidth = caption.width

plugin:BigWigs_ShowWarningSign("icon", 3, false, "躲开")
assert(caption.value == "躲开" and caption.width < longWidth, "short caption must be remeasured")
plugin:BigWigs_ShowWarningSign("icon", 3, false)
assert(caption.value == "", "icon-only warnings must clear the old caption")
now = 104
sign.update()
assert(not sign.visible and not plugin.db.profile.isVisible and not sign.update,
    "warning still expires and clears its update handler")
plugin.db.profile.disabled = true
plugin:BigWigs_ShowWarningSign("icon", 3, false, "亲和即将到来")
assert(not sign.visible, "disabled warnings must stay hidden")
print("PASS: warning captions on the 1.12 API, replacement, expiry and disabled fallback")
