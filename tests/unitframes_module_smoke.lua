local root = assert(arg[1], "repository root argument is required")

local configuredHealth = {}
local configuredPower = {}
local routeEnabled = true

local function NewVisibility(shown)
  return {
    shown = shown and true or false,
    Show = function(self) self.shown = true end,
    Hide = function(self) self.shown = false end,
    IsShown = function(self) return self.shown end,
  }
end

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

local function NewTexture()
  local texture = NewVisibility(false)
  texture.points = {}
  texture.SetTexture = function(self, value) self.texture = value end
  texture.SetTexCoord = function(self, ...)
    self.texcoord = { ... }
  end
  texture.ClearAllPoints = function(self) self.points = {} end
  texture.SetPoint = function(self, ...)
    table.insert(self.points, { ... })
  end
  texture.SetWidth = function(self, value) self.width = value end
  texture.SetHeight = function(self, value) self.height = value end
  return texture
end

local function NewFrame(name, label, width, height)
  local frame = {
    name = name,
    label = label or name,
    width = width or 200,
    height = height or 33,
    textures = {},
    config = {
      width = width or 200,
      height = height or 30,
      bartexture = "provider-health-" .. name,
      pbartexture = "provider-power-" .. name,
    },
    hp = {
      bar = NewBar(),
      backdrop = NewVisibility(true),
    },
    power = {
      bar = NewBar(),
      backdrop = NewVisibility(true),
    },
  }
  frame.GetWidth = function(self) return self.width end
  frame.GetHeight = function(self) return self.height end
  frame.CreateTexture = function(self)
    local texture = NewTexture()
    table.insert(self.textures, texture)
    return texture
  end
  configuredHealth[name] = frame.config.bartexture
  configuredPower[name] = frame.config.pbartexture
  return frame
end

local raidFrames = {}
for slot = 1, 40 do
  raidFrames[slot] = NewFrame("raid" .. slot, "raid", 70, 33)
end

AzerothExpeditionUI = {
  media = {
    root = "Interface\\AddOns\\AzerothExpeditionUI\\Media\\",
  },
  db = {
    unitframes = {
      enabled = true,
      artVersion = 2,
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
    raid = raidFrames,
  },
}

function pfUI:GetExpeditionComponentOwner(name)
  if not routeEnabled then return nil end
  if
    name == "unitframes.health-fill" or
    name == "unitframes.power-fill" or
    name == "unitframes.raid-shell" or
    name == "unitframes.raid-health-fill" or
    name == "unitframes.raid-power-fill"
  then
    return "unitframes"
  end
end

dofile(root .. "/addon/AzerothExpeditionUI/Modules/UnitFrames.lua")

local module = assert(AzerothExpeditionUI.modules.UnitFrames)
module:Initialize()

local healthTexture =
  "Interface\\AddOns\\AzerothExpeditionUI\\Media\\" ..
  "UnitFrames\\UnitFrameHealthFillV1"
local powerTexture =
  "Interface\\AddOns\\AzerothExpeditionUI\\Media\\" ..
  "UnitFrames\\UnitFramePowerFillV1"
local raidRoot =
  "Interface\\AddOns\\AzerothExpeditionUI\\Media\\" ..
  "UnitFrames\\RaidMemberShell"

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
  assert(frame.aeuiUnitFrameBarsContract == "1.1")
end
assert(module.appliedFrameCount == 4)

local expectedVariants = {
  "A", "C", "B", "D", "D", "B", "A", "C", "B", "D",
  "C", "A", "C", "A", "D", "B", "A", "D", "B", "C",
  "B", "C", "A", "D", "D", "A", "C", "B", "C", "B",
  "D", "A", "A", "C", "D", "B", "D", "B", "C", "A",
}

for slot = 1, 40 do
  local frame = pfUI.uf.raid[slot]
  local variant = expectedVariants[slot]
  local expectedTexture = raidRoot .. variant .. "V1"
  assert(frame.hp.bar.texture == healthTexture)
  assert(frame.power.bar.texture == powerTexture)
  assert(frame.aeuiRaidShellVariant == variant)
  assert(frame.aeuiRaidShellTexture == expectedTexture)
  assert(frame.aeuiRaidShellContract == "1.1")
  assert(frame.aeuiRaidShellAssembly == "complete-74x37")
  assert(frame.aeuiRaidShellTextures.full.texture == expectedTexture)
  assert(frame.aeuiRaidShellTextures.full.shown == true)
  assert(frame.aeuiRaidShellTextures.full.width == 74)
  assert(frame.aeuiRaidShellTextures.full.height == 37)
  assert(frame.aeuiRaidShellTextures.left.shown == false)
  assert(frame.aeuiRaidShellTextures.centre.shown == false)
  assert(frame.aeuiRaidShellTextures.right.shown == false)
  assert(frame.hp.backdrop.shown == false)
  assert(frame.power.backdrop.shown == false)
  assert(type(frame.aeuiRaidRefreshVisual) == "function")
end
assert(module.appliedRaidFrameCount == 40)

-- Width-only provider changes use the fixed 6/62/6 UV assembly and leave the
-- Secure Button dimensions under provider control.
local variable = pfUI.uf.raid[1]
variable.width = 90
variable:aeuiRaidRefreshVisual()
assert(variable.aeuiRaidShellAssembly == "three-slice-6-centre-6")
assert(variable.aeuiRaidShellTextures.full.shown == false)
assert(variable.aeuiRaidShellTextures.left.shown == true)
assert(variable.aeuiRaidShellTextures.centre.shown == true)
assert(variable.aeuiRaidShellTextures.right.shown == true)
assert(variable.aeuiRaidShellTextures.left.width == 6)
assert(variable.aeuiRaidShellTextures.centre.width == 82)
assert(variable.aeuiRaidShellTextures.right.width == 6)
assert(variable.width == 90)
variable.width = 70
variable:aeuiRaidRefreshVisual()
assert(variable.aeuiRaidShellAssembly == "complete-74x37")

-- Unowned frames are not rewritten.
for _, key in ipairs({ "focustarget", "party" }) do
  local frame = pfUI.uf[key]
  assert(frame.hp.bar.texture == nil)
  assert(frame.power.bar.texture == nil)
  assert(frame.aeuiHealthBarTexture == nil)
  assert(frame.aeuiPowerBarTexture == nil)
end

-- Disabling this AEUI module restores provider bar media and both Raid
-- backdrops; created texture objects remain harmless and hidden.
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
for slot = 1, 40 do
  local frame = pfUI.uf.raid[slot]
  assert(frame.hp.bar.texture == configuredHealth["raid" .. slot])
  assert(frame.power.bar.texture == configuredPower["raid" .. slot])
  assert(frame.aeuiRaidShellContract == nil)
  assert(frame.aeuiRaidShellVariant == nil)
  assert(frame.aeuiRaidShellTextures.full.shown == false)
  assert(frame.aeuiRaidShellTextures.left.shown == false)
  assert(frame.aeuiRaidShellTextures.centre.shown == false)
  assert(frame.aeuiRaidShellTextures.right.shown == false)
  assert(frame.hp.backdrop.shown == true)
  assert(frame.power.backdrop.shown == true)
end
assert(module.appliedFrameCount == 0)
assert(module.appliedRaidFrameCount == 0)

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
for slot = 1, 40 do
  local frame = pfUI.uf.raid[slot]
  assert(frame.hp.bar.texture == configuredHealth["raid" .. slot])
  assert(frame.power.bar.texture == configuredPower["raid" .. slot])
  assert(frame.hp.backdrop.shown == true)
  assert(frame.power.backdrop.shown == true)
end

local status = module:GetRuntimeStatus()
assert(string.find(status, "contract=1.1", 1, true))
assert(string.find(status, "primary-bars=0/4", 1, true))
assert(string.find(status, "raid-shells=0/40", 1, true))
assert(string.find(status, "raid-slices=6/62/6", 1, true))
assert(string.find(status, "fallback=pfui-configured-bars-and-raid-backdrops", 1, true))

print("unitframes module smoke test passed")
