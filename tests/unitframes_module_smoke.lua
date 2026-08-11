local root = assert(arg[1], "repository root argument is required")

local configuredHealth = {}
local configuredPower = {}
local routeEnabled = true

local function NewBar()
  return {
    texture = nil,
    calls = 0,
    SetStatusBarTexture = function(self, value)
      self.texture = value
      self.calls = self.calls + 1
    end,
  }
end

local function NewFrame(name)
  local frame = {
    name = name,
    config = {
      bartexture = "provider-health-" .. name,
      pbartexture = "provider-power-" .. name,
    },
    hp = { bar = NewBar() },
    power = { bar = NewBar() },
  }
  configuredHealth[name] = frame.config.bartexture
  configuredPower[name] = frame.config.pbartexture
  return frame
end

AzerothExpeditionUI = {
  media = {
    root = "Interface\\AddOns\\AzerothExpeditionUI\\Media\\",
  },
  db = {
    unitframes = {
      enabled = true,
      artVersion = 1,
    },
  },
  modules = {},
}

function AzerothExpeditionUI:RegisterModule(name, module)
  self.modules[name] = module
end

pfUI = {
  media = setmetatable(
    {
      ["img:bar"] = "provider-default-bar",
    },
    {
      __index = function(_, key)
        return key
      end,
    }
  ),
  uf = {
    player = NewFrame("player"),
    target = NewFrame("target"),
    targettarget = NewFrame("targettarget"),
    focus = NewFrame("focus"),
    focustarget = NewFrame("focustarget"),
    party = NewFrame("party"),
  },
}

function pfUI:GetExpeditionComponentOwner(name)
  if not routeEnabled then
    return nil
  end
  if
    name == "unitframes.health-fill" or
    name == "unitframes.power-fill"
  then
    return "unitframes"
  end
end

dofile(
  root ..
    "/addon/AzerothExpeditionUI/Modules/UnitFrames.lua"
)

local module = assert(AzerothExpeditionUI.modules.UnitFrames)
module:Initialize()

local healthTexture =
  "Interface\\AddOns\\AzerothExpeditionUI\\Media\\" ..
  "UnitFrames\\UnitFrameHealthFillV1"
local powerTexture =
  "Interface\\AddOns\\AzerothExpeditionUI\\Media\\" ..
  "UnitFrames\\UnitFramePowerFillV1"

for _, key in ipairs({
  "player",
  "target",
  "targettarget",
  "focus",
}) do
  local frame = pfUI.uf[key]
  assert(frame.hp.bar.texture == healthTexture)
  assert(frame.power.bar.texture == powerTexture)
  assert(frame.aeuiHealthBarTexture == healthTexture)
  assert(frame.aeuiPowerBarTexture == powerTexture)
  assert(frame.aeuiUnitFrameBarsContract == "1.0")
end
assert(module.appliedFrameCount == 4)

-- Unowned frames are not rewritten.
for _, key in ipairs({ "focustarget", "party" }) do
  local frame = pfUI.uf[key]
  assert(frame.hp.bar.texture == nil)
  assert(frame.power.bar.texture == nil)
  assert(frame.aeuiHealthBarTexture == nil)
  assert(frame.aeuiPowerBarTexture == nil)
end

-- Disabling only this AEUI module restores each provider-configured donor.
AzerothExpeditionUI.db.unitframes.enabled = false
module:Apply()
for _, key in ipairs({
  "player",
  "target",
  "targettarget",
  "focus",
}) do
  local frame = pfUI.uf[key]
  assert(frame.hp.bar.texture == configuredHealth[key])
  assert(frame.power.bar.texture == configuredPower[key])
  assert(frame.aeuiHealthBarTexture == nil)
  assert(frame.aeuiPowerBarTexture == nil)
  assert(frame.aeuiUnitFrameBarsContract == nil)
end
assert(module.appliedFrameCount == 0)

-- Disabling the global scoped route is the same fail-open boundary.
AzerothExpeditionUI.db.unitframes.enabled = true
routeEnabled = false
module:Apply()
for _, key in ipairs({
  "player",
  "target",
  "targettarget",
  "focus",
}) do
  assert(pfUI.uf[key].hp.bar.texture == configuredHealth[key])
  assert(pfUI.uf[key].power.bar.texture == configuredPower[key])
end

local status = module:GetRuntimeStatus()
assert(string.find(status, "contract=1.0", 1, true))
assert(string.find(status, "frames=0/4", 1, true))
assert(string.find(status, "fallback=pfui-configured-bars", 1, true))

print("unitframes module smoke test passed")
