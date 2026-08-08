local root = assert(arg[1], "repository root argument is required")

local Texture = {}
Texture.__index = Texture

function Texture:SetAllPoints(target)
  self.setAllPointsCalls = self.setAllPointsCalls + 1
  self.allPoints = target
end
function Texture:SetTexture(value)
  self.setTextureCalls = self.setTextureCalls + 1
  self.texture = value
end
function Texture:SetTexCoord(...)
  self.texcoord = { ... }
end
function Texture:SetBlendMode(value)
  self.blendMode = value
end
function Texture:SetVertexColor(...)
  self.vertexColor = { ... }
end
function Texture:Show()
  self.shown = true
end
function Texture:Hide()
  self.shown = false
end

local Backdrop = {}
Backdrop.__index = Backdrop

function Backdrop:CreateTexture(_, layer)
  self.createTextureCalls = self.createTextureCalls + 1
  local texture = setmetatable({
    parent = self,
    drawLayer = layer,
    shown = true,
    setAllPointsCalls = 0,
    setTextureCalls = 0,
  }, Texture)
  self.lastTexture = texture
  return texture
end

local function NewButton(barIndex, buttonIndex)
  local backdrop = setmetatable({
    name = "backdrop-" .. barIndex .. "-" .. buttonIndex,
    shown = true,
    createTextureCalls = 0,
  }, Backdrop)
  return {
    name = "button-" .. barIndex .. "-" .. buttonIndex,
    backdrop = backdrop,
    parent = { id = "provider-parent" },
    points = { "provider-point" },
    width = 36,
    height = 36,
    hitRect = { -2, -2, -2, -2 },
    scripts = { OnClick = function() end },
    icon = { id = "provider-icon" },
    equipped = { id = "provider-equipped" },
    cd = { id = "provider-cooldown" },
    animation = { id = "provider-animation" },
    highlight = { id = "provider-highlight" },
    active = { id = "provider-active" },
    macro = { id = "provider-macro" },
    keybind = { id = "provider-keybind" },
    count = { id = "provider-count" },
  }
end

pfUI = { bars = {} }
local snapshots = {}
for barIndex = 1, 12 do
  pfUI.bars[barIndex] = {}
  for buttonIndex = 1, 12 do
    local button = NewButton(barIndex, buttonIndex)
    pfUI.bars[barIndex][buttonIndex] = button
    snapshots[button] = {
      parent = button.parent,
      points = button.points,
      width = button.width,
      height = button.height,
      hitRect = button.hitRect,
      scripts = button.scripts,
      icon = button.icon,
      equipped = button.equipped,
      cd = button.cd,
      animation = button.animation,
      highlight = button.highlight,
      active = button.active,
      macro = button.macro,
      keybind = button.keybind,
      count = button.count,
    }
  end
end

AzerothExpeditionUI = {
  media = {
    root = "Interface\\AddOns\\AzerothExpeditionUI\\Media\\",
  },
  db = {
    actionbars = {
      enabled = true,
    },
  },
  modules = {},
}

function AzerothExpeditionUI:RegisterModule(name, module)
  self.modules[name] = module
end

dofile(root .. "/addon/AzerothExpeditionUI/Modules/ActionBars.lua")

local module = assert(AzerothExpeditionUI.modules.ActionBars)
assert(module.runtimeContract == "1.0")
module:Initialize()
module:Apply()

assert(module.providerStatus == "available")
assert(module.appliedBars == 10)
assert(module.appliedButtons == 120)

local created = 0
for barIndex = 1, 12 do
  for buttonIndex = 1, 12 do
    local button = pfUI.bars[barIndex][buttonIndex]
    local before = snapshots[button]
    assert(button.parent == before.parent)
    assert(button.points == before.points)
    assert(button.width == before.width)
    assert(button.height == before.height)
    assert(button.hitRect == before.hitRect)
    assert(button.scripts == before.scripts)
    assert(button.icon == before.icon)
    assert(button.equipped == before.equipped)
    assert(button.cd == before.cd)
    assert(button.animation == before.animation)
    assert(button.highlight == before.highlight)
    assert(button.active == before.active)
    assert(button.macro == before.macro)
    assert(button.keybind == before.keybind)
    assert(button.count == before.count)

    local texture = button.backdrop.aeuiActionSlotBaseV1
    if barIndex <= 10 then
      assert(texture)
      assert(texture.parent == button.backdrop)
      assert(texture.drawLayer == "ARTWORK")
      assert(texture.allPoints == button.backdrop)
      assert(texture.texture ==
        "Interface\\AddOns\\AzerothExpeditionUI\\Media\\ActionBars\\ActionSlotBaseV1")
      assert(table.concat(texture.texcoord, ",") == "0,1,0,1")
      assert(texture.blendMode == "BLEND")
      assert(table.concat(texture.vertexColor, ",") == "1,1,1,1")
      assert(texture.shown == true)
      assert(button.backdrop.shown == true)
      created = created + button.backdrop.createTextureCalls
    else
      assert(texture == nil)
      assert(button.backdrop.createTextureCalls == 0)
    end
  end
end
assert(created == 120)

local firstTexture = pfUI.bars[1][1].backdrop.aeuiActionSlotBaseV1
module:Apply()
assert(pfUI.bars[1][1].backdrop.aeuiActionSlotBaseV1 == firstTexture)
assert(firstTexture.setAllPointsCalls == 1)
assert(firstTexture.setTextureCalls == 1)
assert(pfUI.bars[1][1].backdrop.createTextureCalls == 1)

AzerothExpeditionUI.db.actionbars.enabled = false
module:Apply()
assert(firstTexture.shown == false)
assert(pfUI.bars[1][1].backdrop.shown == true)

AzerothExpeditionUI.db.actionbars.enabled = true
module:Apply()
assert(firstTexture.shown == true)

pfUI.bars[10][12].backdrop = nil
module:Apply()
assert(module.appliedBars == 10)
assert(module.appliedButtons == 119)

pfUI = nil
module:Apply()
assert(module.providerStatus == "missing")
assert(module.appliedBars == 0)
assert(module.appliedButtons == 0)
assert(string.find(module:GetRuntimeStatus(), "scope=bars%-1%-10"))
assert(string.find(module:GetRuntimeStatus(), "provider=missing"))

print("actionbars module smoke test passed")
