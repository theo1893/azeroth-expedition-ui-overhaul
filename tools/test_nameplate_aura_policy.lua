-- Focused check for the aura policy shared by unit frames and nameplates.
AzerothExpeditionUI = {
  media = { root = "" },
  modules = {},
  RegisterModule = function(self, name, module)
    self.modules[name] = module
  end,
}

local playerFrame = {}
pfUI = {
  api = {
    libdebuff = {
      UnitBuffCaster = function(_, _, _, name)
        return name == "Own Buff" and "player" or "other"
      end,
    },
  },
  uf = { player = playerFrame },
}

GetGlobal = function() end
UnitCanAttack = function(_, unit) return unit == "enemy" end
UnitIsFriend = function(_, unit) return unit == "friend" end
CreateFrame = function()
  return {
    RegisterEvent = function() end,
    SetScript = function() end,
  }
end

assert(loadfile("addon/AzerothExpeditionUI/Modules/ActionBars.lua"))()
local module = assert(AzerothExpeditionUI.modules.ActionBars)
local policy = assert(module.FocusAuraPolicy)
local nameplate = {}

assert(policy(nameplate, "enemy", "buff", "Enemy Buff", nil, 1) == true)
assert(policy(nameplate, "enemy", "debuff", "Mine", "player", 1) == true)
assert(policy(nameplate, "enemy", "debuff", "破甲", "other", 2) == true)
assert(policy(nameplate, "enemy", "debuff", "Other", "other", 3) == false)
assert(policy(nameplate, "friend", "debuff", "Any", "other", 1) == true)
assert(policy(nameplate, "friend", "buff", "Own Buff", nil, 1) == true)
assert(policy(nameplate, "friend", "buff", "Other Buff", nil, 2) == true)
assert(policy(nameplate, "unknown", "debuff", "Any", nil, 1) == nil)

module:ApplyFocusAuraPolicy(true)
assert(pfUI.api.aeuiAuraPolicy == policy)
module:ApplyFocusAuraPolicy(false)
assert(pfUI.api.aeuiAuraPolicy == nil)

UnitName = function() return "Test" end
GetRealmName = function() return "Realm" end
AzerothExpeditionUI.db = { actionbars = {} }
pfUI_config = { unitframes = {
  target = {buffs = "TOPRIGHT", debuffs = "BOTTOMRIGHT", buffsize = "23",
    debuffsize = "23", buffperrow = "8", debuffperrow = "8", bufflimit = "32"},
  ttarget = {buffs = "off", buffsize = "16", width = "240"},
  focus = {buffs = "TOPLEFT", debuffs = "TOPRIGHT", buffsize = "12", width = "100"},
} }
local updates = 0
for _, key in ipairs({"target", "targettarget", "focus"}) do
  pfUI.uf[key] = {UpdateConfig = function() updates = updates + 1 end}
end
module:ApplyFocusAuraPolicy(true)
for _, role in ipairs({"ttarget", "focus"}) do
  local config = pfUI_config.unitframes[role]
  assert(config.buffs == "TOPRIGHT" and config.debuffs == "BOTTOMRIGHT")
  assert(config.buffsize == "23" and config.buffperrow == "8" and config.bufflimit == "32")
end
assert(pfUI_config.unitframes.focus.width == "100")
assert(pfUI.uf.focus.aeuiAuraPolicy == policy and pfUI.uf.targettarget.aeuiAuraPolicy == policy)
module:ApplyFocusAuraPolicy(true)
assert(updates == 2) -- unchanged settings must not trigger another geometry refresh
pfUI.uf.target.GetEffectiveScale = function() return 0.8 end
pfUI.uf.focus.GetEffectiveScale = function() return 1.2 end
pfUI.uf.focus.GetWidth = function() return 120 end
pfUI.api.GetBorderSize = function() return 3, 3 end
module:ApplyFocusAuraPolicy(true)
local focusConfig = pfUI_config.unitframes.focus
assert(math.abs(tonumber(focusConfig.buffsize) * 1.2 - 23 * 0.8) < 0.00001)
assert(math.abs(tonumber(focusConfig.debuffsize) * 1.2 - 23 * 0.8) < 0.00001)
assert(focusConfig.buffperrow == "5" and focusConfig.debuffperrow == "5")
local refreshed = updates
module:ApplyFocusAuraPolicy(true)
assert(updates == refreshed)
module:ApplyFocusAuraPolicy(false)
assert(pfUI_config.unitframes.focus.buffsize == "12")
assert(pfUI_config.unitframes.focus.debuffs == "TOPRIGHT")
assert(pfUI_config.unitframes.ttarget.buffs == "off")
assert(pfUI_config.unitframes.ttarget.debuffs == nil)
assert(pfUI.uf.focus.aeuiAuraPolicy == nil and pfUI.uf.targettarget.aeuiAuraPolicy == nil)
print("shared aura policy and secondary display configuration: PASS")
