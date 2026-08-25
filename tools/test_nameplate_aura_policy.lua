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
assert(policy(nameplate, "friend", "buff", "Other Buff", nil, 2) == false)
assert(policy(nameplate, "unknown", "debuff", "Any", nil, 1) == nil)

module:ApplyFocusAuraPolicy(true)
assert(pfUI.api.aeuiAuraPolicy == policy)
module:ApplyFocusAuraPolicy(false)
assert(pfUI.api.aeuiAuraPolicy == nil)

print("nameplate aura policy: PASS")
