local addon = AzerothExpeditionUI
local GearPlanner = {}

GearPlanner.runtimeContract = "0.9-zhCN"

local UNKNOWN_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"
local PROFILE_PAGE_SIZE = 8
local ITEM_QUALITY_CHAT_COLORS = {
  [0] = "ff9d9d9d", [1] = "ffffffff", [2] = "ff1eff00",
  [3] = "ff0070dd", [4] = "ffa335ee", [5] = "ffff8000",
  [6] = "ffe6cc80", [7] = "ffe6cc80",
}
local SLOT_DIFFERENCE_LABELS = {
  replace = "更换", add = "新增", empty = "未填",
}
local PLAN_COMPANION_FRAME_WIDTH = 560
local WIDE_RIGHT_FALLBACK = 368
local COMPANION_RAIL_WIDTH = 28
local COMPANION_GAP = 8
local COMPANION_RAIL_GAP = 4
local WIDE_MIN_WIDTH = 1060
local INSPECT_GAP = 8
local INSPECT_RAIL_GAP = 4

local COMPANION_VIEWS = {
  {
    key = "current",
    label = "装",
    title = "当前装备",
    tooltip = "S_ItemTip 装备明细",
  },
  {
    key = "stats",
    label = "属",
    title = "装备属性",
    tooltip = "StatCompare 属性对比",
  },
  {
    key = "plan",
    label = "配",
    title = "配装方案",
    tooltip = "AEUI Gear Planner",
  },
}

local INSPECT_VIEWS = {
  {
    key = "gear",
    label = "装",
    title = "目标装备",
    tooltip = "S_ItemTip 目标装备明细",
  },
  {
    key = "stats",
    label = "属",
    title = "目标属性",
    tooltip = "StatCompare 目标属性",
  },
  {
    key = "compare",
    label = "比",
    title = "双方对比",
    tooltip = "目标属性在右、自身属性在左；仅在净空足够时可用",
  },
}

local function CompanionViewTitle(key)
  local index, definition
  for index = 1, table.getn(COMPANION_VIEWS) do
    definition = COMPANION_VIEWS[index]
    if definition.key == key then return definition.title end
  end
  return nil
end

local SLOT_DEFS = {
  { "Head", "头部", "HeadSlot", "#s1#" },
  { "Neck", "项链", "NeckSlot", "#s2#" },
  { "Shoulder", "肩部", "ShoulderSlot", "#s3#" },
  { "Back", "背部", "BackSlot", "#s4#" },
  { "Chest", "胸部", "ChestSlot", "#s5#" },
  { "Shirt", "衬衣", "ShirtSlot", "#s6#" },
  { "Tabard", "战袍", "TabardSlot", "#s7#" },
  { "Wrist", "护腕", "WristSlot", "#s8#" },
  { "Hands", "手套", "HandsSlot", "#s9#" },
  { "Waist", "腰带", "WaistSlot", "#s10#" },
  { "Legs", "腿部", "LegsSlot", "#s11#" },
  { "Feet", "脚部", "FeetSlot", "#s12#" },
  { "Finger0", "戒指一", "Finger0Slot", "#s13#" },
  { "Finger1", "戒指二", "Finger1Slot", "#s13#" },
  { "Trinket0", "饰品一", "Trinket0Slot", "#s14#" },
  { "Trinket1", "饰品二", "Trinket1Slot", "#s14#" },
  { "MainHand", "主手", "MainHandSlot", "MAINHAND" },
  { "SecondaryHand", "副手", "SecondaryHandSlot", "OFFHAND" },
  { "Ranged", "远程／圣物", "RangedSlot", "RANGED" },
}

local WEAPON_TOKENS = {
  MAINHAND = {
    "#h0#", "#h1#", "#h2#", "#h3#", "#w1#", "#w4#", "#w6#",
    "#w7#", "#w9#", "#w10#", "#w13#", "#w14#", "#w15#",
  },
  OFFHAND = {
    "#s15#", "#h0#", "#h1#", "#h4#", "#w4#", "#w8#", "#w13#",
  },
  RANGED = {
    "#s16#", "#w2#", "#w3#", "#w5#", "#w11#", "#w12#",
    "#e16#", "#e17#", "#e18#",
  },
}

local WEAPON_STAT_DEFS = {
  {
    "MainHand", "MainHandSlot",
    "AEUI_MAINHAND_SPEED", "AEUI_MAINHAND_DPS",
  },
  {
    "SecondaryHand", "SecondaryHandSlot",
    "AEUI_OFFHAND_SPEED", "AEUI_OFFHAND_DPS",
  },
  {
    "Ranged", "RangedSlot",
    "AEUI_RANGED_SPEED", "AEUI_RANGED_DPS",
  },
}

local STAT_LABELS = {
  STR = "力量", AGI = "敏捷", STA = "耐力",
  INT = "智力", SPI = "精神", ARMOR = "护甲", ENARMOR = "额外护甲",
  HEALTH = "生命值", MANA = "法力值",

  ARCANERES = "奥术抗性", FIRERES = "火焰抗性",
  FROSTRES = "冰霜抗性", NATURERES = "自然抗性",
  SHADOWRES = "暗影抗性", HOLYRES = "神圣抗性",
  ALLRES = "所有抗性", RES = "抗性",
  ARCANE = "奥术抗性", FIRE = "火焰抗性", FROST = "冰霜抗性",
  NATURE = "自然抗性", SHADOW = "暗影抗性", HOLY = "神圣抗性",

  FISHING = "钓鱼技能", MINING = "采矿技能",
  HERBALISM = "草药技能", SKINNING = "剥皮技能",
  DEFENSE = "防御技能", DODGE = "躲闪", PARRY = "招架",
  BLOCK = "格挡值", BLOCKVALUE = "格挡值", TOBLOCK = "格挡几率",
  STEALTH = "潜行等级",

  ATTACKPOWER = "攻击强度", ATTACKPOWERUNDEAD = "对亡灵攻强",
  RANGEDATTACKPOWER = "远程攻击强度",
  ATTACKPOWERFERAL = "野性攻击强度",
  BEARAP = "熊形态攻击强度", CATAP = "猫形态攻击强度",
  AEUI_MAINHAND_SPEED = "主手攻速", AEUI_MAINHAND_DPS = "主手秒伤",
  AEUI_OFFHAND_SPEED = "副手攻速", AEUI_OFFHAND_DPS = "副手秒伤",
  AEUI_RANGED_SPEED = "远程攻速", AEUI_RANGED_DPS = "远程秒伤",
  TOHIT = "物理命中", RANGEDTOHIT = "远程命中",
  CRIT = "物理暴击", RANGEDCRIT = "远程暴击",
  HASTE = "急速", LIFEDRAIN = "吸血",
  ARMORPENETRATION = "护甲穿透",

  DMG = "法术伤害", DMGUNDEAD = "对亡灵法伤",
  HEAL = "治疗效果", SPELLTOHIT = "法术命中",
  SPELLCRIT = "法术暴击", HOLYCRIT = "神圣法术暴击",
  NATURECRIT = "自然法术暴击", SPELLPEN = "法术穿透",
  SPELLPENETRATION = "法术穿透",
  ARCANEDMG = "奥术伤害", FIREDMG = "火焰伤害",
  FROSTDMG = "冰霜伤害", HOLYDMG = "神圣伤害",
  NATUREDMG = "自然伤害", SHADOWDMG = "暗影伤害",
  CHAINLIGHTNING = "闪电链伤害", LIGHTNINGBOLT = "闪电箭伤害",
  EARTHSHOCK = "地震术伤害", FLAMESHOCK = "烈焰震击伤害",
  FROSTSHOCK = "冰霜震击伤害",
  FLASHHOLYLIGHTHEAL = "圣光闪现治疗",
  LESSERHEALWAVE = "次级治疗波治疗",

  MANAREG = "每5秒回蓝", HEALTHREG = "每5秒回血",
  CASTING_MANA_REG = "施法回蓝比例",

  WEAPONSKILL_TWOHAND_SWORD = "双手剑技能",
  WEAPONSKILL_TWOHAND_AXE = "双手斧技能",
  WEAPONSKILL_TWOHAND_MACE = "双手锤技能",
  WEAPONSKILL_ONEHAND_SWORD = "单手剑技能",
  WEAPONSKILL_ONEHAND_AXE = "单手斧技能",
  WEAPONSKILL_ONEHAND_MACE = "单手锤技能",
  WEAPONSKILL_FIST = "拳套技能", WEAPONSKILL_DAGGER = "匕首技能",
  WEAPONSKILL_POLEARMS = "长柄武器技能",
}

local STAT_COMPACT_LABELS = {
  RANGEDATTACKPOWER = "远程攻强",
  ATTACKPOWERFERAL = "野性攻强",
  BEARAP = "熊形态攻强",
  CATAP = "猫形态攻强",
  ATTACKPOWERUNDEAD = "对亡灵攻强",
  FLASHHOLYLIGHTHEAL = "闪现治疗",
  LESSERHEALWAVE = "次级治疗波",
  CASTING_MANA_REG = "施法回蓝",
}

local PERCENT_STATS = {
  TOHIT = true, CRIT = true, RANGEDCRIT = true, HASTE = true,
  RANGEDTOHIT = true, LIFEDRAIN = true, DODGE = true, PARRY = true,
  TOBLOCK = true, SPELLTOHIT = true, SPELLCRIT = true,
  HOLYCRIT = true, NATURECRIT = true, CASTING_MANA_REG = true,
}

local WEAPON_DISPLAY_STATS = {
  AEUI_MAINHAND_SPEED = true, AEUI_MAINHAND_DPS = true,
  AEUI_OFFHAND_SPEED = true, AEUI_OFFHAND_DPS = true,
  AEUI_RANGED_SPEED = true, AEUI_RANGED_DPS = true,
}

local WEAPON_SPEED_STATS = {
  AEUI_MAINHAND_SPEED = true,
  AEUI_OFFHAND_SPEED = true,
  AEUI_RANGED_SPEED = true,
}

local STAT_SORT_ORDER = {
  "STR", "AGI", "STA", "INT", "SPI", "ARMOR", "ENARMOR",
  "HEALTH", "MANA", "ATTACKPOWER", "RANGEDATTACKPOWER",
  "ATTACKPOWERFERAL", "BEARAP", "CATAP",
  "AEUI_MAINHAND_DPS", "AEUI_MAINHAND_SPEED",
  "AEUI_OFFHAND_DPS", "AEUI_OFFHAND_SPEED",
  "AEUI_RANGED_DPS", "AEUI_RANGED_SPEED",
  "TOHIT", "RANGEDTOHIT",
  "CRIT", "RANGEDCRIT", "HASTE", "LIFEDRAIN", "ARMORPENETRATION",
  "DEFENSE", "DODGE", "PARRY", "TOBLOCK", "BLOCK", "BLOCKVALUE",
  "DMG", "HEAL", "SPELLTOHIT", "SPELLCRIT", "SPELLPEN",
  "SPELLPENETRATION", "MANAREG", "HEALTHREG", "CASTING_MANA_REG",
  "ARCANERES", "FIRERES", "FROSTRES", "NATURERES", "SHADOWRES",
}

local STAT_SORT_INDEX = {}
local statSortIndex
for statSortIndex = 1, table.getn(STAT_SORT_ORDER) do
  STAT_SORT_INDEX[STAT_SORT_ORDER[statSortIndex]] = statSortIndex
end

local STAT_ROW_HEIGHT = 12
local STAT_ROW_TOP = 29

local function Enabled()
  if not addon.db or not addon.db.gearplanner then return false end
  return addon.db.gearplanner.enabled ~= false
end

local function Trim(value)
  local text = tostring(value or "")
  text = string.gsub(text, "^%s+", "")
  text = string.gsub(text, "%s+$", "")
  return text
end

local function CleanText(value)
  local text = tostring(value or "")
  text = string.gsub(text, "=q%d+=", "")
  text = string.gsub(text, "=ds=", "")
  text = string.gsub(text, "=ec%d+=", "")
  text = string.gsub(text, "|c%x%x%x%x%x%x%x%x", "")
  text = string.gsub(text, "|r", "")
  return Trim(text)
end

local function StatLabel(key, compact)
  local label
  if compact then label = STAT_COMPACT_LABELS[key] end
  if not label then label = STAT_LABELS[key] end
  if not label and type(BONUSSCANNER_NAMES) == "table" then
    label = BONUSSCANNER_NAMES[key]
  end
  label = CleanText(label)
  if label == "" then return "其他属性" end
  return label
end

local function StatLess(left, right)
  local leftIndex = STAT_SORT_INDEX[left]
  local rightIndex = STAT_SORT_INDEX[right]
  local leftLabel, rightLabel
  if leftIndex and rightIndex then return leftIndex < rightIndex end
  if leftIndex then return true end
  if rightIndex then return false end
  leftLabel = StatLabel(left, false)
  rightLabel = StatLabel(right, false)
  if leftLabel == rightLabel then return tostring(left) < tostring(right) end
  return leftLabel < rightLabel
end

local function AtlasLocaleText(locale, value)
  local text = tostring(value or "")
  local ok, translated
  if not locale or text == "" then return text end
  ok, translated = pcall(function() return locale[text] end)
  if ok and translated and translated ~= true then
    return CleanText(translated)
  end
  return CleanText(text)
end

local function CountProfileSlots(profile)
  local count = 0
  local index, definition
  for index = 1, table.getn(SLOT_DEFS) do
    definition = SLOT_DEFS[index]
    if profile and profile.slots and profile.slots[definition[1]] then
      count = count + 1
    end
  end
  return count
end

local function ItemLink(itemID)
  return "item:" .. tostring(itemID) .. ":0:0:0"
end

local function ItemIDFromLink(link)
  local itemID
  if not link then return nil end
  _, _, itemID = string.find(link, "item:(%d+)")
  return tonumber(itemID)
end

local function PlannedItemChatLink(item)
  local itemID, name, quality, color
  if not item then return nil end
  itemID = tonumber(item.id)
  if not itemID then return nil end
  name, _, quality = GetItemInfo(itemID)
  name = CleanText(name or item.name)
  if name == "" then return nil end
  quality = tonumber(quality) or tonumber(item.quality) or 1
  color = ITEM_QUALITY_CHAT_COLORS[quality] or ITEM_QUALITY_CHAT_COLORS[1]
  return "|c" .. color .. "|Hitem:" .. tostring(itemID) ..
    ":0:0:0|h[" .. name .. "]|h|r"
end

local function NormalizeIcon(icon)
  local value = tostring(icon or "")
  if value == "" then return UNKNOWN_ICON end
  if string.find(value, "\\", 1, true) then return value end
  return "Interface\\Icons\\" .. value
end

local function CharacterKey()
  local name = UnitName("player") or "Unknown"
  local realm = ""
  if type(GetCVar) == "function" then realm = GetCVar("realmName") or "" end
  if realm == "" then realm = "UnknownRealm" end
  return realm .. ":" .. name
end

local function AddNumber(target, key, value)
  local number = tonumber(value)
  if not number or number == 0 then return end
  target[key] = (tonumber(target[key]) or 0) + number
end

local function FirstPositiveNumber(value)
  local number = tonumber(value)
  local index
  if number and number > 0 then return number end
  if type(value) ~= "table" then return nil end
  for index = 1, table.getn(value) do
    number = tonumber(value[index])
    if number and number > 0 then return number end
  end
  return nil
end

local function WeaponDamageTotals(minimums, maximums)
  local minimum = tonumber(minimums)
  local maximum = tonumber(maximums)
  local minimumTotal, maximumTotal = 0, 0
  local found, index, count
  if minimum and maximum and (minimum > 0 or maximum > 0) then
    return minimum, maximum
  end
  if type(minimums) ~= "table" or type(maximums) ~= "table" then
    return nil, nil
  end
  count = math.max(table.getn(minimums), table.getn(maximums))
  for index = 1, count do
    minimum = tonumber(minimums[index]) or 0
    maximum = tonumber(maximums[index]) or 0
    if minimum > 0 or maximum > 0 then
      minimumTotal = minimumTotal + minimum
      maximumTotal = maximumTotal + maximum
      found = true
    end
  end
  if found then return minimumTotal, maximumTotal end
  return nil, nil
end

local function ItemStatsWeaponDamage(stats)
  local fieldPairs = {
    { "damageMin", "damageMax" },
    { "dmgMin", "dmgMax" },
    { "minDamage", "maxDamage" },
    { "DamageMin", "DamageMax" },
  }
  local index, pair, minimum, maximum
  if type(stats) ~= "table" then return nil, nil end
  for index = 1, table.getn(fieldPairs) do
    pair = fieldPairs[index]
    minimum, maximum = WeaponDamageTotals(
      stats[pair[1]],
      stats[pair[2]]
    )
    if minimum and maximum then return minimum, maximum end
  end
  return nil, nil
end

local function ParseWeaponTooltipText(text, parsed)
  local normalized = tostring(text or "")
  local lower, value, minimum, maximum
  if normalized == "" then return end
  normalized = string.gsub(normalized, ",", "")
  lower = string.lower(normalized)

  if not parsed.speed then
    _, _, value = string.find(normalized, "速度%s*([%d]+%.?[%d]*)")
    if not value then
      _, _, value = string.find(lower, "speed%s*([%d]+%.?[%d]*)")
    end
    value = tonumber(value)
    if value and value > 0 then parsed.speed = value end
  end

  if not parsed.dps then
    _, _, value = string.find(normalized, "每秒伤害%s*([%d]+%.?[%d]*)")
    if not value then
      _, _, value = string.find(normalized, "([%d]+%.?[%d]*)%s*每秒伤害")
    end
    if not value then
      _, _, value = string.find(
        lower,
        "([%d]+%.?[%d]*)%s*damage per second"
      )
    end
    if not value then
      _, _, value = string.find(
        lower,
        "damage per second%s*([%d]+%.?[%d]*)"
      )
    end
    value = tonumber(value)
    if value and value > 0 then parsed.dps = value end
  end

  if
    not parsed.damageMin and
    (
      string.find(normalized, "伤害", 1, true) or
      string.find(lower, "damage", 1, true)
    )
  then
    _, _, minimum, maximum = string.find(
      normalized,
      "([%d]+%.?[%d]*)%s*%-%s*([%d]+%.?[%d]*)"
    )
    minimum = tonumber(minimum)
    maximum = tonumber(maximum)
    if minimum and maximum and (minimum > 0 or maximum > 0) then
      parsed.damageMin = minimum
      parsed.damageMax = maximum
    end
  end
end

local function CompactNumber(value)
  local number = tonumber(value) or 0
  local absolute = math.abs(number)
  local text
  if number == math.floor(number) then
    text = tostring(number)
  elseif absolute < 10 then
    text = string.format("%.2f", number)
  else
    text = string.format("%.1f", number)
  end
  text = string.gsub(text, "(%..-)0+$", "%1")
  text = string.gsub(text, "%.$", "")
  return text
end

local function ComparisonValue(value, key, signed)
  local number = tonumber(value) or 0
  local prefix = signed and number > 0 and "+" or ""
  local suffix = PERCENT_STATS[key] and "%" or ""
  return prefix .. CompactNumber(number) .. suffix
end

local function CreateBackdrop(frame, alpha)
  frame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
  })
  frame:SetBackdropColor(0.055, 0.045, 0.035, alpha or 0.96)
  frame:SetBackdropBorderColor(0.62, 0.45, 0.24, 1)
end

local function CreateButton(parent, text, width, height)
  local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
  button:SetWidth(width)
  button:SetHeight(height)
  button:SetText(text)
  return button
end

local function AddSpecialFrame(name)
  local index
  if not UISpecialFrames then return end
  for index = 1, table.getn(UISpecialFrames) do
    if UISpecialFrames[index] == name then return end
  end
  table.insert(UISpecialFrames, name)
end

local function FrameVisible(frame)
  if not frame then return false end
  if type(frame.IsVisible) == "function" then
    return frame:IsVisible() and true or false
  end
  if type(frame.IsShown) == "function" then
    return frame:IsShown() and true or false
  end
  return false
end

local function SetShown(frame, shown)
  if not frame then return end
  if shown and type(frame.Show) == "function" then
    frame:Show()
  elseif not shown and type(frame.Hide) == "function" then
    frame:Hide()
  end
end

local function CapturePoints(frame)
  local points = {}
  local index
  if not frame or not frame.GetNumPoints or not frame.GetPoint then
    return points
  end
  for index = 1, frame:GetNumPoints() do
    local point, relativeTo, relativePoint, x, y = frame:GetPoint(index)
    table.insert(points, {
      point = point,
      relativeTo = relativeTo,
      relativePoint = relativePoint,
      x = x,
      y = y,
    })
  end
  return points
end

local function RestorePoints(frame, points)
  local index, definition
  if not frame or not frame.ClearAllPoints or not frame.SetPoint then return end
  frame:ClearAllPoints()
  for index = 1, table.getn(points or {}) do
    definition = points[index]
    frame:SetPoint(
      definition.point,
      definition.relativeTo,
      definition.relativePoint,
      definition.x,
      definition.y
    )
  end
end

local function MatchesCategory(extra, token)
  local tokens, index
  extra = tostring(extra or "")
  if string.find(token, "#s", 1, true) then
    return string.find(extra, token, 1, true) ~= nil
  end
  tokens = WEAPON_TOKENS[token]
  if not tokens then return false end
  for index = 1, table.getn(tokens) do
    if string.find(extra, tokens[index], 1, true) then return true end
  end
  return false
end

local function IsTwoHand(item)
  local extra = tostring(item and item.extra or "")
  if string.find(extra, "#h2#", 1, true) then return true end
  if string.find(extra, "#h1#", 1, true) then return false end
  if string.find(extra, "#h3#", 1, true) then return false end
  if string.find(extra, "#h4#", 1, true) then return false end
  if string.find(extra, "#w7#", 1, true) then return true end
  if string.find(extra, "#w9#", 1, true) then return true end
  if string.find(extra, "#w14#", 1, true) then return true end
  if string.find(extra, "#w15#", 1, true) then return true end
  return false
end

function GearPlanner:GetStore()
  local db = addon.db.gearplanner
  local key = CharacterKey()
  local store
  db.characters = db.characters or {}
  if type(db.characters[key]) ~= "table" then
    db.characters[key] = { active = 1, profiles = {} }
  end
  store = db.characters[key]
  store.profiles = store.profiles or {}
  if table.getn(store.profiles) == 0 then
    table.insert(store.profiles, { name = "方案 1", slots = {} })
  end
  store.active = tonumber(store.active) or 1
  if store.active < 1 or store.active > table.getn(store.profiles) then
    store.active = 1
  end
  return store
end

function GearPlanner:GetProfile()
  local store = self:GetStore()
  local profile = store.profiles[store.active]
  profile.slots = profile.slots or {}
  return profile
end

function GearPlanner:ActivateProfile(index)
  local store = self:GetStore()
  local selected = tonumber(index)
  if not selected or selected < 1 or selected > table.getn(store.profiles) then
    return false, "配装方案索引无效。"
  end
  store.active = selected
  self.statCache = {}
  self.profileSelection = selected
  self:UpdateAll()
  return true, "已切换到“" .. tostring(store.profiles[selected].name) .. "”。"
end

function GearPlanner:CycleProfile(offset)
  local store = self:GetStore()
  local count = table.getn(store.profiles)
  local selected
  if count < 1 then return false, "没有可切换的配装方案。" end
  selected = (store.active or 1) + (tonumber(offset) or 1)
  if selected < 1 then selected = count end
  if selected > count then selected = 1 end
  return self:ActivateProfile(selected)
end

function GearPlanner:UniqueProfileName(base, ignoredIndex)
  local store = self:GetStore()
  local root = Trim(base)
  local candidate, suffix, index, profile, duplicate
  if root == "" then root = "新方案" end
  candidate = root
  suffix = 2
  repeat
    duplicate = false
    for index = 1, table.getn(store.profiles) do
      profile = store.profiles[index]
      if index ~= ignoredIndex and profile and profile.name == candidate then
        duplicate = true
        break
      end
    end
    if duplicate then
      candidate = root .. " " .. tostring(suffix)
      suffix = suffix + 1
    end
  until not duplicate
  return candidate
end

function GearPlanner:CopyProfile(profile, name)
  local copy = { name = name, slots = {} }
  local index, definition, item
  for index = 1, table.getn(SLOT_DEFS) do
    definition = SLOT_DEFS[index]
    item = profile and profile.slots and profile.slots[definition[1]]
    if item then copy.slots[definition[1]] = self:CopyItem(item) end
  end
  return copy
end

function GearPlanner:CreateProfile(name)
  local store = self:GetStore()
  local profileName = self:UniqueProfileName(name or "新方案")
  table.insert(store.profiles, { name = profileName, slots = {} })
  store.active = table.getn(store.profiles)
  self.profileSelection = store.active
  self.statCache = {}
  self:UpdateAll()
  return true, "已新建并激活“" .. tostring(profileName) .. "”。"
end

function GearPlanner:DuplicateProfile(index)
  local store = self:GetStore()
  local selected = tonumber(index)
  local source, copy, name
  if not selected or selected < 1 or selected > table.getn(store.profiles) then
    return false, "请先选择要复制的方案。"
  end
  source = store.profiles[selected]
  name = self:UniqueProfileName(tostring(source.name or "方案") .. " 副本")
  copy = self:CopyProfile(source, name)
  table.insert(store.profiles, selected + 1, copy)
  store.active = selected + 1
  self.profileSelection = store.active
  self.statCache = {}
  self:UpdateAll()
  return true, "已复制并激活“" .. tostring(name) .. "”。"
end

function GearPlanner:RenameProfile(index, name)
  local store = self:GetStore()
  local selected = tonumber(index)
  local profileName = Trim(name)
  local otherIndex
  if not selected or selected < 1 or selected > table.getn(store.profiles) then
    return false, "请先选择要重命名的方案。"
  end
  if profileName == "" then return false, "方案名称不能为空。" end
  for otherIndex = 1, table.getn(store.profiles) do
    if
      otherIndex ~= selected and
      store.profiles[otherIndex].name == profileName
    then
      return false, "已经存在同名方案。"
    end
  end
  store.profiles[selected].name = profileName
  self.profileSelection = selected
  self:UpdateAll()
  return true, "方案已重命名为“" .. tostring(profileName) .. "”。"
end

function GearPlanner:DeleteProfile(index)
  local store = self:GetStore()
  local selected = tonumber(index)
  local removedName
  if table.getn(store.profiles) <= 1 then
    return false, "至少需要保留一套配装方案。"
  end
  if not selected or selected < 1 or selected > table.getn(store.profiles) then
    return false, "请先选择要删除的方案。"
  end
  removedName = tostring(store.profiles[selected].name or "方案")
  table.remove(store.profiles, selected)
  if selected < store.active then store.active = store.active - 1 end
  if store.active > table.getn(store.profiles) then
    store.active = table.getn(store.profiles)
  end
  self.profileSelection = store.active
  self.statCache = {}
  self:UpdateAll()
  return true, "已删除“" .. removedName .. "”。"
end

function GearPlanner:UpdateProfileControls()
  local store, profile
  if not self.frame or not self.titleText then return end
  store = self:GetStore()
  profile = store.profiles[store.active]
  self.titleText:SetText(
    "配装方案 · " .. tostring(profile.name or ("方案 " .. store.active)) ..
    "  " .. tostring(store.active) .. "/" .. tostring(table.getn(store.profiles))
  )
  if self.profilePreviousButton and self.profileNextButton then
    if table.getn(store.profiles) > 1 then
      self.profilePreviousButton:Show()
      self.profileNextButton:Show()
    else
      self.profilePreviousButton:Hide()
      self.profileNextButton:Hide()
    end
  end
  if self.profileManager and FrameVisible(self.profileManager) then
    self:RefreshProfileManager()
  end
end

function GearPlanner:GetAtlasLocale()
  local ok, locale
  if self.atlasLocaleResolved then return self.atlasLocale end
  self.atlasLocaleResolved = true
  if type(AceLibrary) ~= "function" then return nil end
  ok, locale = pcall(function()
    return AceLibrary("AceLocale-2.2"):new("AtlasLoot")
  end)
  if ok then self.atlasLocale = locale end
  return self.atlasLocale
end

function GearPlanner:BuildSourceMetadata()
  local result = {}
  local locale = self:GetAtlasLocale()
  local dungeonKey, sources, dataID, metadata
  local dungeonTitle, sourceTitle
  if type(AtlasLoot_TableNamesBoss) ~= "table" then return result end
  for dungeonKey, sources in pairs(AtlasLoot_TableNamesBoss) do
    if type(sources) == "table" then
      dungeonTitle = AtlasLocaleText(locale, dungeonKey)
      for dataID, metadata in pairs(sources) do
        if type(metadata) == "table" then
          sourceTitle = CleanText(metadata[1] or dataID)
          result[dataID] = {
            dungeonTitle = dungeonTitle,
            sourceTitle = sourceTitle,
          }
        end
      end
    end
  end
  return result
end

function GearPlanner:BuildIndex()
  local dataID, metadata, dataSource, rows, rowIndex, row, slotIndex
  local sourceTitle, qualityText, candidate, itemID
  local sourceMetadata, sourceInfo, dungeonTitle
  self.index = {}
  self.byID = {}
  self.recordCount = 0
  self.itemCount = 0
  self.atlasReady = false
  for slotIndex = 1, table.getn(SLOT_DEFS) do
    self.index[SLOT_DEFS[slotIndex][1]] = {}
  end
  if type(AtlasLoot_Data) ~= "table" or type(AtlasLoot_TableNames) ~= "table" then
    self.indexBuilt = true
    return false
  end
  sourceMetadata = self:BuildSourceMetadata()
  self.sourceMetadata = sourceMetadata
  for dataID, metadata in pairs(AtlasLoot_TableNames) do
    if type(metadata) == "table" then
      dataSource = metadata[2]
      rows = nil
      if dataSource and AtlasLoot_Data[dataSource] then
        rows = AtlasLoot_Data[dataSource][dataID]
      end
      if type(rows) == "table" then
        sourceInfo = sourceMetadata[dataID]
        sourceTitle = CleanText(
          (sourceInfo and sourceInfo.sourceTitle) or metadata[1] or dataID
        )
        dungeonTitle = CleanText(
          (sourceInfo and sourceInfo.dungeonTitle) or ""
        )
        for rowIndex = 1, table.getn(rows) do
          row = rows[rowIndex]
          if type(row) == "table" and tonumber(row[1]) and tonumber(row[1]) > 0 then
            itemID = tonumber(row[1])
            _, _, qualityText = string.find(tostring(row[3] or ""), "=q(%d+)=")
            candidate = {
              id = itemID, icon = NormalizeIcon(row[2]), name = CleanText(row[3]),
              quality = tonumber(qualityText) or 1, extra = tostring(row[4] or ""),
              dropRate = tostring(row[5] or ""), dataID = dataID,
              dataSource = dataSource, sourceTitle = sourceTitle,
              dungeonTitle = dungeonTitle,
            }
            if not self.byID[itemID] then
              self.byID[itemID] = candidate
              self.itemCount = self.itemCount + 1
            end
            for slotIndex = 1, table.getn(SLOT_DEFS) do
              if MatchesCategory(candidate.extra, SLOT_DEFS[slotIndex][4]) then
                table.insert(self.index[SLOT_DEFS[slotIndex][1]], candidate)
              end
            end
            self.recordCount = self.recordCount + 1
          end
        end
      end
    end
  end
  self.indexBuilt = true
  self.atlasReady = true
  return true
end

function GearPlanner:EnsureIndex()
  if self.indexBuilt then return self.atlasReady end
  return self:BuildIndex()
end

function GearPlanner:ResolveItem(item)
  local name, quality, texture
  if not item then return end
  name, _, quality, _, _, _, _, _, texture = GetItemInfo(item.id)
  if name then
    item.name = name
    item.quality = quality or item.quality
    item.icon = texture or item.icon
  elseif type(AtlasLoot_CacheItem) == "function" then
    AtlasLoot_CacheItem(item.id)
  end
end

function GearPlanner:CopyItem(item)
  if not item then return nil end
  return {
    id = item.id, icon = item.icon, name = item.name, quality = item.quality,
    extra = item.extra, dropRate = item.dropRate, dataID = item.dataID,
    dataSource = item.dataSource, sourceTitle = item.sourceTitle,
    dungeonTitle = item.dungeonTitle,
  }
end

function GearPlanner:SelectItem(item)
  local profile = self:GetProfile()
  if not self.selectedSlot or not item then return end
  profile.slots[self.selectedSlot] = self:CopyItem(item)
  if self.selectedSlot == "MainHand" and IsTwoHand(item) then
    profile.slots.SecondaryHand = nil
  elseif self.selectedSlot == "SecondaryHand" and IsTwoHand(profile.slots.MainHand) then
    profile.slots.MainHand = nil
  end
  profile.inspectSignature = nil
  self.statCache[item.id] = nil
  self:UpdateAll()
end

function GearPlanner:ClearSlot(slotKey)
  local profile = self:GetProfile()
  profile.slots[slotKey] = nil
  profile.inspectSignature = nil
  self:UpdateAll()
end

function GearPlanner:ImportCurrent()
  local profile = self:GetProfile()
  local index, definition, slotID, link, itemID, source, name, quality, texture
  self:EnsureIndex()
  profile.slots = {}
  profile.inspectSignature = nil
  profile.referenceSource = nil
  profile.referenceName = nil
  profile.capturedSlots = nil
  for index = 1, table.getn(SLOT_DEFS) do
    definition = SLOT_DEFS[index]
    slotID = GetInventorySlotInfo(definition[3])
    link = slotID and GetInventoryItemLink("player", slotID)
    itemID = ItemIDFromLink(link)
    if itemID then
      source = self.byID[itemID]
      if source then
        profile.slots[definition[1]] = self:CopyItem(source)
      else
        name, _, quality, _, _, _, _, _, texture = GetItemInfo(itemID)
        profile.slots[definition[1]] = {
          id = itemID, name = name or ("物品 " .. tostring(itemID)),
          icon = texture or UNKNOWN_ICON, quality = quality or 1,
          sourceTitle = "AtlasLoot 未收录",
        }
      end
    end
  end
  self.statCache = {}
  self:UpdateAll()
end

function GearPlanner:UniqueInspectProfileName(store, targetName)
  local base = tostring(targetName or "目标") .. " 观察参考"
  local candidate = base
  local suffix = 2
  local index, profile, duplicate
  repeat
    duplicate = false
    for index = 1, table.getn(store.profiles or {}) do
      profile = store.profiles[index]
      if profile and profile.name == candidate then
        duplicate = true
        break
      end
    end
    if duplicate then
      candidate = base .. " " .. tostring(suffix)
      suffix = suffix + 1
    end
  until not duplicate
  return candidate
end

function GearPlanner:SaveInspectReference()
  local unit, targetName, store, profile, previousActive
  local index, definition, slotID, link, itemID, source
  local name, quality, texture, count, signature, signatureParts
  if not Enabled() then return false, "配装工具已禁用。" end
  if not self:InspectContextVisible() or not InspectFrame.unit then
    return false, "当前没有可保存的观察目标。"
  end
  unit = InspectFrame.unit
  if not UnitExists(unit) then
    return false, "观察目标已经失效，请重新观察后再保存。"
  end
  if not self.inspectDataReady then
    return false, "观察数据尚未完成，请等待“存”按钮出现后再保存。"
  end

  self:EnsureIndex()
  targetName = UnitName(unit) or "目标"
  profile = { slots = {} }
  signatureParts = { tostring(targetName) }
  count = 0
  for index = 1, table.getn(SLOT_DEFS) do
    definition = SLOT_DEFS[index]
    slotID = GetInventorySlotInfo(definition[3])
    link = slotID and GetInventoryItemLink(unit, slotID)
    itemID = ItemIDFromLink(link)
    table.insert(
      signatureParts,
      tostring(definition[1]) .. "=" .. tostring(itemID or 0)
    )
    if itemID then
      source = self.byID[itemID]
      if source then
        profile.slots[definition[1]] = self:CopyItem(source)
      else
        name, _, quality, _, _, _, _, _, texture = GetItemInfo(itemID)
        profile.slots[definition[1]] = {
          id = itemID,
          name = name or ("物品 " .. tostring(itemID)),
          icon = texture or UNKNOWN_ICON,
          quality = quality or 1,
          sourceTitle = "观察目标：" .. tostring(targetName),
        }
      end
      count = count + 1
    end
  end
  if count == 0 then
    return false, "尚未读取到目标装备，请等待观察数据完成后重试。"
  end

  signature = table.concat(signatureParts, ";")
  store = self:GetStore()
  for index = 1, table.getn(store.profiles) do
    if store.profiles[index].inspectSignature == signature then
      store.active = index
      self.planPane = "combined"
      self:UpdateAll()
      return true, "该目标当前装备已保存为“" ..
        tostring(store.profiles[index].name) .. "”（" .. tostring(count) ..
        "/19 槽），已切换到该方案。"
    end
  end

  previousActive = store.active
  profile.name = self:UniqueInspectProfileName(store, targetName)
  profile.referenceSource = "inspect"
  profile.referenceName = targetName
  profile.capturedSlots = count
  profile.inspectSignature = signature
  table.insert(store.profiles, profile)
  store.active = table.getn(store.profiles)
  self.planPane = "combined"
  self.statCache = {}
  self:UpdateAll()
  return true, "已新建并激活“" .. tostring(profile.name) .. "”（" ..
    tostring(count) .. "/19 槽）；原第 " .. tostring(previousActive) ..
    " 套方案仍保留，关闭观察页后可用 /aeui gear 继续编辑。"
end

function GearPlanner:GetWeaponScannerTooltip()
  local name = "AzerothExpeditionUIGearPlannerWeaponScanner"
  local tooltip
  if self.weaponTooltip then return self.weaponTooltip end
  tooltip = getglobal(name)
  if not tooltip then
    tooltip = CreateFrame("GameTooltip", name, UIParent, "GameTooltipTemplate")
  end
  tooltip:SetOwner(UIParent, "ANCHOR_NONE")
  self.weaponTooltip = tooltip
  return tooltip
end

function GearPlanner:ScanWeaponItemStats(itemID)
  local ok, stats, delay, minimum, maximum, speed, dps
  if type(GetItemStats) ~= "function" then return nil, nil end
  ok, stats = pcall(GetItemStats, itemID, true)
  if not ok or type(stats) ~= "table" then return nil, nil end
  delay = FirstPositiveNumber(stats.delay) or
    FirstPositiveNumber(stats.Delay) or
    FirstPositiveNumber(stats.weaponDelay) or
    FirstPositiveNumber(stats.attackTime)
  if delay and delay > 100 then speed = delay / 1000 end
  minimum, maximum = ItemStatsWeaponDamage(stats)
  if speed and minimum and maximum then
    dps = ((minimum + maximum) * 0.5) / speed
  end
  return speed, dps
end

function GearPlanner:ScanWeaponTooltip(itemID)
  local tooltip = self:GetWeaponScannerTooltip()
  local name = tooltip:GetName()
  local parsed = {}
  local index, count, left, right
  tooltip:ClearLines()
  tooltip:SetHyperlink(ItemLink(itemID))
  count = tooltip:NumLines() or 0
  for index = 1, count do
    left = getglobal(name .. "TextLeft" .. tostring(index))
    right = getglobal(name .. "TextRight" .. tostring(index))
    if left then ParseWeaponTooltipText(left:GetText(), parsed) end
    if right then ParseWeaponTooltipText(right:GetText(), parsed) end
  end
  tooltip:Hide()
  if
    not parsed.dps and parsed.speed and
    parsed.damageMin and parsed.damageMax
  then
    parsed.dps = ((parsed.damageMin + parsed.damageMax) * 0.5) /
      parsed.speed
  end
  return parsed.speed, parsed.dps
end

function GearPlanner:ScanWeapon(itemID)
  local cached
  local speed, dps, tooltipSpeed, tooltipDps, result
  self.weaponCache = self.weaponCache or {}
  cached = self.weaponCache[itemID]
  if cached then return cached end
  speed, dps = self:ScanWeaponItemStats(itemID)
  if not speed or not dps then
    tooltipSpeed, tooltipDps = self:ScanWeaponTooltip(itemID)
    speed = speed or tooltipSpeed
    dps = dps or tooltipDps
  end
  result = { speed = speed, dps = dps }
  if speed or dps then self.weaponCache[itemID] = result end
  return result
end

function GearPlanner:AddWeaponStats(totals, itemID, speedKey, dpsKey)
  local weapon
  if not itemID then return end
  weapon = self:ScanWeapon(itemID)
  if weapon.speed and weapon.speed > 0 then
    totals[speedKey] = weapon.speed
  end
  if weapon.dps and weapon.dps > 0 then
    totals[dpsKey] = weapon.dps
  end
end

function GearPlanner:ScanItem(itemID)
  local scanned, result, key, value, number, setValue
  if self.statCache[itemID] then return self.statCache[itemID] end
  result = {}
  if BonusScanner and type(BonusScanner.ScanItem) == "function" then
    scanned = BonusScanner:ScanItem(ItemLink(itemID))
    if type(scanned) == "table" then
      for key, value in pairs(scanned) do
        number = tonumber(value)
        if number then
          setValue = 0
          if BonusScanner.temp and BonusScanner.temp.details then
            if BonusScanner.temp.details[key] then
              setValue = tonumber(BonusScanner.temp.details[key].Set) or 0
            end
          end
          if number - setValue ~= 0 then result[key] = number - setValue end
        end
      end
    end
  end
  self.statCache[itemID] = result
  return result
end

function GearPlanner:AddItemStats(totals, itemID)
  local stats, key, value
  if not itemID then return end
  stats = self:ScanItem(itemID)
  for key, value in pairs(stats) do AddNumber(totals, key, value) end
end

function GearPlanner:CollectProfileStats(profile)
  local totals = {}
  local index, definition, item
  for index = 1, table.getn(SLOT_DEFS) do
    definition = SLOT_DEFS[index]
    item = profile and profile.slots and profile.slots[definition[1]]
    if item then self:AddItemStats(totals, item.id) end
  end
  for index = 1, table.getn(WEAPON_STAT_DEFS) do
    definition = WEAPON_STAT_DEFS[index]
    item = profile and profile.slots and profile.slots[definition[1]]
    if item then
      self:AddWeaponStats(totals, item.id, definition[3], definition[4])
    end
  end
  return totals
end

function GearPlanner:CollectCurrentStats()
  local totals = {}
  local index, definition, slotID, link, itemID
  for index = 1, table.getn(SLOT_DEFS) do
    definition = SLOT_DEFS[index]
    slotID = GetInventorySlotInfo(definition[3])
    link = slotID and GetInventoryItemLink("player", slotID)
    itemID = ItemIDFromLink(link)
    if itemID then self:AddItemStats(totals, itemID) end
  end
  for index = 1, table.getn(WEAPON_STAT_DEFS) do
    definition = WEAPON_STAT_DEFS[index]
    slotID = GetInventorySlotInfo(definition[2])
    link = slotID and GetInventoryItemLink("player", slotID)
    itemID = ItemIDFromLink(link)
    if itemID then
      self:AddWeaponStats(totals, itemID, definition[3], definition[4])
    end
  end
  return totals
end

function GearPlanner:OpenSource(item)
  if not item or not item.dataID then
    addon:Print("该物品没有可定位的 AtlasLoot 来源。")
    return
  end
  if type(AtlasLoot_ShowBossLoot) == "function" then
    AtlasLoot_ShowBossLoot(item.dataID, item.sourceTitle)
  elseif type(AtlasLoot_ShowItemsFrame) == "function" then
    AtlasLoot_ShowItemsFrame(item.dataID, item.dataSource, item.sourceTitle)
  else
    addon:Print("AtlasLoot 浏览窗口不可用。")
  end
end

function GearPlanner:InsertItemChatLink(item)
  local link
  if not item then
    addon:Print("当前方案槽位没有装备可发送。")
    return false
  end
  self:ResolveItem(item)
  link = PlannedItemChatLink(item)
  if not link then
    if type(AtlasLoot_CacheItem) == "function" then AtlasLoot_CacheItem(item.id) end
    addon:Print("物品资料尚未缓存，暂时无法生成聊天链接。")
    return false
  end
  if WIM_EditBoxInFocus and type(WIM_EditBoxInFocus.Insert) == "function" then
    WIM_EditBoxInFocus:Insert(link)
  elseif
    ChatFrameEditBox and
    type(ChatFrameEditBox.IsVisible) == "function" and
    ChatFrameEditBox:IsVisible()
  then
    ChatFrameEditBox:Insert(link)
  elseif type(ChatFrame_OpenChat) == "function" then
    ChatFrame_OpenChat(link, SELECTED_DOCK_FRAME or DEFAULT_CHAT_FRAME)
  else
    addon:Print("聊天输入框不可用，请先按 Enter 后重试。")
    return false
  end
  return true
end

function GearPlanner:ShowTooltip(owner, item)
  if not item then return end
  GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
  GameTooltip:SetHyperlink(ItemLink(item.id))
  if item.sourceTitle then
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(item.sourceTitle, 0.82, 0.68, 0.42)
  end
  if owner and owner.slotKey then
    if owner.differenceState then
      GameTooltip:AddLine(" ")
      GameTooltip:AddLine(
        "与当前装备不同：" ..
          tostring(SLOT_DIFFERENCE_LABELS[owner.differenceState] or "变更"),
        1,
        0.72,
        0.24
      )
    end
    GameTooltip:AddLine("Shift+左键：贴入聊天栏", 0.92, 0.78, 0.48)
    GameTooltip:AddLine("Ctrl+左键：查看来源　右键：清空", 0.66, 0.62, 0.54)
  end
  GameTooltip:Show()
end

function GearPlanner:ShowSlotTooltip(button)
  if not button then return end
  if button.item then
    self:ShowTooltip(button, button.item)
    return
  end
  GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
  GameTooltip:AddLine(tostring(button.slotLabel or "装备槽位"))
  if button.differenceState == "empty" then
    GameTooltip:AddLine("当前槽位已有装备；配装方案尚未填写。", 1, 0.72, 0.24)
  else
    GameTooltip:AddLine("配装方案尚未填写。", 0.72, 0.68, 0.60)
  end
  GameTooltip:AddLine("左键：选择装备", 0.92, 0.78, 0.48)
  GameTooltip:Show()
end

function GearPlanner:GetSlotDefinition(slotKey)
  local index, definition
  for index = 1, table.getn(SLOT_DEFS) do
    definition = SLOT_DEFS[index]
    if definition[1] == slotKey then return definition end
  end
  return nil
end

function GearPlanner:AtlasSelectionAvailable()
  return
    self.atlasSelectionActive and
    self.selectedSlot and
    Enabled() and
    FrameVisible(self.frame) and
    (not self.companionMode or self.activeView == "plan")
end

function GearPlanner:GetAtlasButtonItemID(button)
  if not button then return nil end
  return tonumber(button.itemID)
end

function GearPlanner:ResolveAtlasButtonSource(button)
  local dataID, dataSource, sourceTitle
  if button and button.sourcePage then
    _, _, dataID, dataSource = string.find(
      tostring(button.sourcePage),
      "^(.+)|(.+)$"
    )
  end
  if
    not dataID and
    AtlasLootItemsFrame and
    type(AtlasLootItemsFrame.refresh) == "table"
  then
    dataID = AtlasLootItemsFrame.refresh[1]
    dataSource = AtlasLootItemsFrame.refresh[2]
    sourceTitle = AtlasLootItemsFrame.refresh[3]
  end
  if
    dataID and
    type(AtlasLoot_TableNames) == "table" and
    type(AtlasLoot_TableNames[dataID]) == "table"
  then
    sourceTitle = AtlasLoot_TableNames[dataID][1] or sourceTitle
  end
  return dataID, dataSource, CleanText(sourceTitle)
end

function GearPlanner:FindAtlasSlotCandidate(slotKey, itemID, dataID)
  local candidates = self.index[slotKey] or {}
  local fallback, index, candidate
  for index = 1, table.getn(candidates) do
    candidate = candidates[index]
    if tonumber(candidate.id) == tonumber(itemID) then
      if dataID and candidate.dataID == dataID then return candidate end
      if not fallback then fallback = candidate end
    end
  end
  return fallback
end

function GearPlanner:AtlasButtonCompatible(button)
  local itemID = self:GetAtlasButtonItemID(button)
  local definition = self:GetSlotDefinition(self.selectedSlot)
  local dataID, candidate
  if not itemID or itemID <= 0 or not definition then return false end
  if MatchesCategory(button.itemIDExtra, definition[4]) then return true end
  dataID = self:ResolveAtlasButtonSource(button)
  candidate = self:FindAtlasSlotCandidate(self.selectedSlot, itemID, dataID)
  return candidate and true or false
end

function GearPlanner:BuildAtlasButtonCandidate(button)
  local itemID = self:GetAtlasButtonItemID(button)
  local dataID, dataSource, sourceTitle
  local source, candidate, name, quality, texture, iconFrame, sourceInfo
  local buttonName
  if not itemID or itemID <= 0 then return nil end
  dataID, dataSource, sourceTitle = self:ResolveAtlasButtonSource(button)
  source = self:FindAtlasSlotCandidate(self.selectedSlot, itemID, dataID)
  if source then candidate = self:CopyItem(source) else candidate = {} end
  name, _, quality, _, _, _, _, _, texture = GetItemInfo(itemID)
  iconFrame = button.GetID and _G[
    "AtlasLootItem_" .. tostring(button:GetID()) .. "_Icon"
  ]
  candidate.id = itemID
  buttonName = CleanText(button.itemIDName)
  candidate.name = name or
    (buttonName ~= "" and buttonName) or
    ("物品 " .. tostring(itemID))
  candidate.quality = quality or candidate.quality or 1
  candidate.icon = texture or
    (iconFrame and iconFrame:GetTexture()) or candidate.icon or UNKNOWN_ICON
  candidate.extra = tostring(button.itemIDExtra or candidate.extra or "")
  candidate.dropRate = tostring(button.droprate or candidate.dropRate or "")
  candidate.dataID = dataID or candidate.dataID
  candidate.dataSource = dataSource or candidate.dataSource
  if Trim(sourceTitle) ~= "" then candidate.sourceTitle = sourceTitle end
  sourceInfo = self.sourceMetadata and dataID and self.sourceMetadata[dataID]
  if sourceInfo then
    if Trim(candidate.sourceTitle) == "" then
      candidate.sourceTitle = sourceInfo.sourceTitle
    end
    candidate.dungeonTitle = sourceInfo.dungeonTitle
  end
  if Trim(candidate.sourceTitle) == "" then
    candidate.sourceTitle = "AtlasLoot"
  end
  return candidate
end

function GearPlanner:AddAtlasLootButtonToProfile(button)
  local candidate, definition
  if not self:AtlasSelectionAvailable() then
    addon:Print("请先在配装方案中选择一个装备槽位。")
    return false
  end
  if not self:AtlasButtonCompatible(button) then
    addon:Print("该物品不适用于当前配装槽位。")
    return false
  end
  candidate = self:BuildAtlasButtonCandidate(button)
  definition = self:GetSlotDefinition(self.selectedSlot)
  if not candidate then return false end
  self:SelectItem(candidate)
  self.atlasSelectionActive = true
  self:RefreshAtlasLootSelectionButtons()
  addon:Print(
    "已将“" .. tostring(candidate.name) .. "”加入" ..
    tostring(definition and definition[2] or "当前槽位") .. "。"
  )
  return true
end

function GearPlanner:CreateAtlasLootSelectionChrome()
  local index, itemButton, addButton
  self.atlasAddButtons = self.atlasAddButtons or {}
  for index = 1, 30 do
    itemButton = _G["AtlasLootItem_" .. tostring(index)]
    if itemButton and not self.atlasAddButtons[index] then
      addButton = CreateButton(itemButton, "+", 24, 20)
      addButton:SetPoint("RIGHT", itemButton, "RIGHT", -2, 0)
      addButton.ownerButton = itemButton
      addButton:SetScript("OnClick", function()
        GearPlanner:AddAtlasLootButtonToProfile(this.ownerButton)
      end)
      addButton:SetScript("OnEnter", function()
        local candidate = GearPlanner:BuildAtlasButtonCandidate(this.ownerButton)
        if candidate then
          GearPlanner:ShowTooltip(this, candidate)
          GameTooltip:AddLine(
            "加入当前方案 · " ..
            tostring(GearPlanner.atlasSelectionLabel or "装备槽位"),
            0.35,
            1,
            0.35
          )
          GameTooltip:Show()
        end
      end)
      addButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
      addButton:Hide()
      self.atlasAddButtons[index] = addButton
    end
  end
  if AtlasLootDefaultFrame and not self.atlasSelectionText then
    self.atlasSelectionText = AtlasLootDefaultFrame:CreateFontString(
      nil,
      "OVERLAY",
      "GameFontNormalSmall"
    )
    self.atlasSelectionText:SetPoint(
      "BOTTOMLEFT",
      AtlasLootDefaultFrame,
      "BOTTOMLEFT",
      20,
      68
    )
    self.atlasSelectionText:SetWidth(460)
    self.atlasSelectionText:SetJustifyH("LEFT")
    self.atlasSelectionText:Hide()
    self.atlasSelectionStopButton = CreateButton(
      AtlasLootDefaultFrame,
      "结束选装",
      78,
      22
    )
    self.atlasSelectionStopButton:SetPoint(
      "BOTTOMRIGHT",
      AtlasLootDefaultFrame,
      "BOTTOMRIGHT",
      -16,
      64
    )
    self.atlasSelectionStopButton:SetScript("OnClick", function()
      GearPlanner:StopAtlasLootSelection(true)
    end)
    self.atlasSelectionStopButton:Hide()
  end
end

function GearPlanner:RefreshAtlasLootSelectionButtons()
  local active = self:AtlasSelectionAvailable()
  local profile = active and self:GetProfile() or nil
  local selectedItem = profile and profile.slots[self.selectedSlot]
  local index, addButton, itemButton, itemID
  self:CreateAtlasLootSelectionChrome()
  for index = 1, 30 do
    addButton = self.atlasAddButtons and self.atlasAddButtons[index]
    itemButton = addButton and addButton.ownerButton
    if
      active and
      itemButton and
      FrameVisible(itemButton) and
      self:AtlasButtonCompatible(itemButton)
    then
      itemID = self:GetAtlasButtonItemID(itemButton)
      addButton:SetFrameLevel(itemButton:GetFrameLevel() + 3)
      addButton:SetText(
        selectedItem and tonumber(selectedItem.id) == itemID and "已" or "+"
      )
      addButton:Show()
    elseif addButton then
      addButton:Hide()
    end
  end
  if self.atlasSelectionText then
    if active then
      self.atlasSelectionText:SetText(
        "AEUI 配装目标：" .. tostring(self.atlasSelectionLabel or "装备") ..
        " · 点击物品行右侧 + 加入当前方案"
      )
      self.atlasSelectionText:Show()
      self.atlasSelectionStopButton:Show()
    else
      self.atlasSelectionText:Hide()
      self.atlasSelectionStopButton:Hide()
    end
  end
end

function GearPlanner:InstallAtlasLootIntegration()
  self:CreateAtlasLootSelectionChrome()
  if
    not self.atlasLootItemsHooked and
    type(hooksecurefunc) == "function" and
    type(AtlasLoot_ShowItemsFrame) == "function"
  then
    hooksecurefunc("AtlasLoot_ShowItemsFrame", function()
      GearPlanner:RefreshAtlasLootSelectionButtons()
    end)
    self.atlasLootItemsHooked = true
  end
  return
    AtlasLootDefaultFrame and
    AtlasLootItemsFrame and
    type(AtlasLoot_ShowItemsFrame) == "function" and
    self.atlasLootItemsHooked
end

function GearPlanner:SetAtlasLootForeground(active)
  if not self.frame or type(self.frame.SetFrameStrata) ~= "function" then return end
  if active then
    if not self.atlasSelectionFrameStrata then
      self.atlasSelectionFrameStrata = self.frame:GetFrameStrata()
    end
    self.frame:SetFrameStrata("MEDIUM")
  elseif self.atlasSelectionFrameStrata then
    self.frame:SetFrameStrata(self.atlasSelectionFrameStrata)
    self.atlasSelectionFrameStrata = nil
  end
end

function GearPlanner:StopAtlasLootSelection(refresh)
  self.atlasSelectionActive = false
  self.selectedSlot = nil
  self.atlasSelectionLabel = nil
  self:SetAtlasLootForeground(false)
  self:RefreshAtlasLootSelectionButtons()
  if refresh ~= false and self.frame then self:UpdateAll() end
end

function GearPlanner:OpenPicker(slotKey, label)
  self:EnsureIndex()
  self.selectedSlot = slotKey
  self.atlasSelectionLabel = label
  self.atlasSelectionActive = true
  if not self:InstallAtlasLootIntegration() then
    self:StopAtlasLootSelection(false)
    addon:Print("AtlasLoot 原生浏览器未加载，当前槽位无法选择候选。")
    self:UpdateAll()
    return false
  end
  self:SetAtlasLootForeground(true)
  AtlasLootDefaultFrame:Show()
  self:RefreshAtlasLootSelectionButtons()
  self:UpdateAll()
  if AtlasLootDefaultFrameSearchBox then
    AtlasLootDefaultFrameSearchBox:SetFocus()
    if AtlasLootDefaultFrameSearchBox.HighlightText then
      AtlasLootDefaultFrameSearchBox:HighlightText()
    end
  end
  return true
end

function GearPlanner:GetSlotDifferenceState(item, currentItemID)
  local plannedItemID = item and tonumber(item.id)
  currentItemID = tonumber(currentItemID)
  if plannedItemID == currentItemID then return nil end
  if plannedItemID and currentItemID then return "replace" end
  if plannedItemID then return "add" end
  if currentItemID then return "empty" end
  return nil
end

function GearPlanner:SetSlotDifferenceVisual(button, state)
  if not button then return end
  button.differenceState = state
  if state == "replace" or state == "add" then
    button:SetBackdropColor(0.085, 0.060, 0.025, 0.84)
    button:SetBackdropBorderColor(0.95, 0.67, 0.20, 1)
    button.differenceWash:SetTexture(0.95, 0.55, 0.10, 0.11)
    button.differenceText:SetText(SLOT_DIFFERENCE_LABELS[state])
    button.differenceText:SetTextColor(1, 0.78, 0.26)
    button.differenceWash:Show()
    button.differenceText:Show()
  elseif state == "empty" then
    button:SetBackdropColor(0.065, 0.050, 0.035, 0.78)
    button:SetBackdropBorderColor(0.78, 0.51, 0.22, 1)
    button.differenceWash:SetTexture(0.82, 0.48, 0.12, 0.05)
    button.differenceText:SetText(SLOT_DIFFERENCE_LABELS[state])
    button.differenceText:SetTextColor(0.88, 0.62, 0.28)
    button.differenceWash:Show()
    button.differenceText:Show()
  else
    button:SetBackdropColor(0.055, 0.045, 0.035, 0.72)
    button:SetBackdropBorderColor(0.62, 0.45, 0.24, 1)
    button.differenceWash:Hide()
    button.differenceText:Hide()
  end
end

function GearPlanner:UpdateSlots()
  local profile = self:GetProfile()
  local index, definition, button, item, slotID, link, currentItemID
  for index = 1, table.getn(SLOT_DEFS) do
    definition = SLOT_DEFS[index]
    button = self.slotButtons[definition[1]]
    item = profile.slots[definition[1]]
    button.item = item
    if item then
      self:ResolveItem(item)
      button.icon:SetTexture(item.icon or UNKNOWN_ICON)
      button.itemText:SetText(tostring(item.name or ("物品 " .. tostring(item.id))))
    else
      button.icon:SetTexture(UNKNOWN_ICON)
      button.itemText:SetText("点击选择装备")
    end
    slotID = GetInventorySlotInfo(definition[3])
    link = slotID and GetInventoryItemLink("player", slotID)
    currentItemID = ItemIDFromLink(link)
    self:SetSlotDifferenceVisual(
      button,
      self:GetSlotDifferenceState(item, currentItemID)
    )
  end
end

function GearPlanner:LayoutStatRow(row, index)
  local layout = self.statsLayout
  local x, cellIndex, cell
  if not row or not layout then return end
  x = 12
  local cells = {
    { row.label, layout.labelWidth, "LEFT" },
    { row.current, layout.valueWidth, "RIGHT" },
    { row.planned, layout.valueWidth, "RIGHT" },
    { row.delta, layout.deltaWidth, "RIGHT" },
  }
  for cellIndex = 1, table.getn(cells) do
    cell = cells[cellIndex]
    cell[1]:ClearAllPoints()
    cell[1]:SetPoint(
      "TOPLEFT",
      self.statsPanel,
      "TOPLEFT",
      x,
      -STAT_ROW_TOP - (index - 1) * STAT_ROW_HEIGHT
    )
    cell[1]:SetWidth(cell[2])
    cell[1]:SetHeight(STAT_ROW_HEIGHT)
    cell[1]:SetJustifyH(cell[3])
    cell[1]:SetJustifyV("MIDDLE")
    x = x + cell[2]
  end
end

function GearPlanner:CreateStatRow(index)
  local row = {}
  row.label = self.statsPanel:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontHighlightSmall"
  )
  row.current = self.statsPanel:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontHighlightSmall"
  )
  row.planned = self.statsPanel:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontHighlightSmall"
  )
  row.delta = self.statsPanel:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontHighlightSmall"
  )
  self.statRows[index] = row
  self:LayoutStatRow(row, index)
  return row
end

function GearPlanner:EnsureStatRows(count)
  local index
  for index = table.getn(self.statRows) + 1, count do
    self:CreateStatRow(index)
  end
end

function GearPlanner:HideStatRows()
  local index, row
  for index = 1, table.getn(self.statRows) do
    row = self.statRows[index]
    row.label:Hide()
    row.current:Hide()
    row.planned:Hide()
    row.delta:Hide()
  end
end

function GearPlanner:UpdateStats()
  local profile = self:GetProfile()
  local planned = self:CollectProfileStats(profile)
  local current = self:CollectCurrentStats()
  local keys, included = {}, {}
  local index, key, value, plannedValue, currentValue, delta, row
  local weaponStat, currentText, plannedText
  local maxRows, displayCount, overflowCount, requiredRows
  local weaponProvider = type(GetItemStats) == "function" and "NP" or "Tip"
  for key, value in pairs(current) do
    if tonumber(value) and tonumber(value) ~= 0 then
      table.insert(keys, key)
      included[key] = true
    end
  end
  for key, value in pairs(planned) do
    if tonumber(value) and tonumber(value) ~= 0 and not included[key] then
      table.insert(keys, key)
      included[key] = true
    end
  end
  table.sort(keys, StatLess)

  self.statsText:SetText("|cffc89b55属性|r")
  self.statsCurrentText:SetText("|cffc89b55当前|r")
  self.statsPlannedText:SetText("|cffc89b55配装|r")
  self.statsDeltaText:SetText("|cffc89b55变化|r")
  self:HideStatRows()

  if table.getn(keys) == 0 then
    self.statsEmptyText:SetText("|cff888888尚无可统计的装备属性。|r")
    self.statsEmptyText:Show()
  else
    self.statsEmptyText:Hide()
    maxRows = math.floor(
      (self.statsPanel:GetHeight() - STAT_ROW_TOP - 34) / STAT_ROW_HEIGHT
    )
    if maxRows < 2 then maxRows = 2 end
    displayCount = table.getn(keys)
    overflowCount = 0
    if displayCount > maxRows then
      displayCount = maxRows - 1
      overflowCount = table.getn(keys) - displayCount
    end
    requiredRows = displayCount + (overflowCount > 0 and 1 or 0)
    self:EnsureStatRows(requiredRows)

    for index = 1, displayCount do
      key = keys[index]
      currentValue = tonumber(current[key])
      plannedValue = tonumber(planned[key])
      weaponStat = WEAPON_DISPLAY_STATS[key]
      delta = (plannedValue or 0) - (currentValue or 0)
      row = self.statRows[index]
      row.label:SetText(
        "|cffd9c39a" .. StatLabel(key, self.companionMode) .. "|r"
      )
      currentText = weaponStat and not currentValue and "—" or
        ComparisonValue(currentValue or 0, key, false)
      plannedText = weaponStat and not plannedValue and "—" or
        ComparisonValue(plannedValue or 0, key, false)
      row.current:SetText(
        "|cffb8b8b8" .. currentText .. "|r"
      )
      row.planned:SetText(
        "|cffe9d5a2" .. plannedText .. "|r"
      )
      if weaponStat and plannedValue and not currentValue then
        row.delta:SetText("|cffd6a84d新增|r")
      elseif weaponStat and currentValue and not plannedValue then
        row.delta:SetText("|cffd6a84d移除|r")
      elseif WEAPON_SPEED_STATS[key] and delta ~= 0 then
        row.delta:SetText(
          "|cffd6a84d" .. ComparisonValue(delta, key, true) .. "|r"
        )
      elseif delta > 0 then
        row.delta:SetText(
          "|cff55dd77" .. ComparisonValue(delta, key, true) .. "|r"
        )
      elseif delta < 0 then
        row.delta:SetText(
          "|cffff6666" .. ComparisonValue(delta, key, true) .. "|r"
        )
      else
        row.delta:SetText("|cff777777—|r")
      end
      row.label:Show()
      row.current:Show()
      row.planned:Show()
      row.delta:Show()
    end

    if overflowCount > 0 then
      row = self.statRows[requiredRows]
      row.label:SetText("|cff888888另有 " .. tostring(overflowCount) .. " 项|r")
      row.current:SetText("")
      row.planned:SetText("")
      row.delta:SetText("")
      row.label:Show()
      row.current:Show()
      row.planned:Show()
      row.delta:Show()
    end
  end
  if self:AtlasSelectionAvailable() then
    self.providerText:SetText(
      "AtlasLoot 选装：" .. tostring(self.atlasSelectionLabel or "装备") ..
      " · 在原生 AtlasLoot 物品行点击 +"
    )
  elseif self.companionMode then
    self.providerText:SetText(
      "AtlasLoot " .. (self.atlasReady and "OK" or "缺失") ..
      " · " .. tostring(self.itemCount or 0) ..
      " · BS " ..
      ((BonusScanner and BonusScanner.ScanItem) and "OK" or "缺失") ..
      " · 武器 " .. weaponProvider
    )
  else
    self.providerText:SetText("AtlasLoot：" ..
      (self.atlasReady and "就绪" or "缺失") ..
      "   物品：" .. tostring(self.itemCount or 0) .. "   属性：" ..
      ((BonusScanner and BonusScanner.ScanItem) and "BonusScanner" or "缺失") ..
      " + 武器 " .. weaponProvider)
  end
end

function GearPlanner:UpdateAll()
  if not self.frame then return end
  self:UpdateProfileControls()
  self:UpdateSlots()
  self:UpdateStats()
  if self.atlasAddButtons or self.atlasSelectionActive then
    self:RefreshAtlasLootSelectionButtons()
  end
end

function GearPlanner:CreateSlotButton(parent, definition, index)
  local column = math.floor((index - 1) / 10)
  local row = (index - 1) - column * 10
  local button = CreateFrame("Button",
    "AzerothExpeditionUIGearPlannerSlot" .. definition[1], parent)
  button:SetWidth(202)
  button:SetHeight(42)
  button:SetPoint("TOPLEFT", parent, "TOPLEFT", 14 + column * 212, -72 - row * 46)
  button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  button.slotKey = definition[1]
  button.slotLabel = definition[2]
  button.layoutIndex = index
  CreateBackdrop(button, 0.72)
  button.differenceWash = button:CreateTexture(nil, "BACKGROUND")
  button.differenceWash:SetPoint("TOPLEFT", button, "TOPLEFT", 4, -4)
  button.differenceWash:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -4, 4)
  button.differenceWash:Hide()
  button.icon = button:CreateTexture(nil, "ARTWORK")
  button.icon:SetWidth(32)
  button.icon:SetHeight(32)
  button.icon:SetPoint("LEFT", button, "LEFT", 6, 0)
  button.labelText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  button.labelText:SetPoint("TOPLEFT", button.icon, "TOPRIGHT", 7, -3)
  button.labelText:SetText(definition[2])
  button.itemText = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  button.itemText:SetPoint("BOTTOMLEFT", button.icon, "BOTTOMRIGHT", 7, 3)
  button.itemText:SetWidth(152)
  button.itemText:SetJustifyH("LEFT")
  button.differenceText = button:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormalSmall"
  )
  button.differenceText:SetPoint("TOPRIGHT", button, "TOPRIGHT", -7, -4)
  button.differenceText:SetWidth(34)
  button.differenceText:SetHeight(12)
  button.differenceText:SetJustifyH("RIGHT")
  button.differenceText:Hide()
  button:SetScript("OnClick", function()
    if arg1 == "LeftButton" and IsShiftKeyDown() then
      GearPlanner:InsertItemChatLink(this.item)
    elseif arg1 == "RightButton" then
      GearPlanner:ClearSlot(this.slotKey)
    elseif IsControlKeyDown() and this.item then
      GearPlanner:OpenSource(this.item)
    else
      GearPlanner:OpenPicker(this.slotKey, this.slotLabel)
    end
  end)
  button:SetScript("OnEnter", function()
    GearPlanner:ShowSlotTooltip(this)
  end)
  button:SetScript("OnLeave", function() GameTooltip:Hide() end)
  return button
end

function GearPlanner:SetProfileManagerStatus(text, isError)
  if not self.profileManagerStatus then return end
  self.profileManagerStatus:SetText(tostring(text or ""))
  if isError then
    self.profileManagerStatus:SetTextColor(1, 0.35, 0.25)
  else
    self.profileManagerStatus:SetTextColor(0.82, 0.68, 0.42)
  end
end

function GearPlanner:RefreshProfileManager()
  local store = self:GetStore()
  local count = table.getn(store.profiles)
  local totalPages = math.ceil(count / PROFILE_PAGE_SIZE)
  local startIndex, rowIndex, row, profileIndex, profile, metadata
  if not self.profileManager then return end
  if totalPages < 1 then totalPages = 1 end
  self.profileSelection = tonumber(self.profileSelection) or store.active
  if self.profileSelection < 1 or self.profileSelection > count then
    self.profileSelection = store.active
  end
  self.profilePage = tonumber(self.profilePage) or 1
  if self.profilePage > totalPages then self.profilePage = totalPages end
  if self.profilePage < 1 then self.profilePage = 1 end
  startIndex = (self.profilePage - 1) * PROFILE_PAGE_SIZE
  for rowIndex = 1, PROFILE_PAGE_SIZE do
    row = self.profileRows[rowIndex]
    profileIndex = startIndex + rowIndex
    profile = store.profiles[profileIndex]
    row.profileIndex = profile and profileIndex or nil
    if profile then
      row.nameText:SetText(
        (profileIndex == store.active and "|cff1eff00●|r " or "  ") ..
        tostring(profile.name or ("方案 " .. tostring(profileIndex)))
      )
      metadata = tostring(CountProfileSlots(profile)) .. "/19 槽"
      if profile.referenceSource == "inspect" then metadata = metadata .. " · 观察" end
      row.metaText:SetText(metadata)
      if profileIndex == store.active then
        row:SetBackdropColor(0.07, 0.13, 0.055, 0.88)
      else
        row:SetBackdropColor(0.055, 0.045, 0.035, 0.72)
      end
      if profileIndex == self.profileSelection then
        row:LockHighlight()
      else
        row:UnlockHighlight()
      end
      row:Show()
    else
      row:Hide()
    end
  end
  self.profilePageText:SetText(
    tostring(self.profilePage) .. " / " .. tostring(totalPages) ..
    "  (" .. tostring(count) .. ")"
  )
  if self.profilePage > 1 then
    self.profilePreviousPage:Enable()
  else
    self.profilePreviousPage:Disable()
  end
  if self.profilePage < totalPages then
    self.profileNextPage:Enable()
  else
    self.profileNextPage:Disable()
  end
  if count > 1 then
    self.profileDeleteButton:Enable()
  else
    self.profileDeleteButton:Disable()
  end
end

function GearPlanner:SetProfileEditMode(mode)
  local showEditor = mode == "new" or mode == "rename"
  local index, button, store, profile
  self.profileEditMode = showEditor and mode or nil
  for index = 1, table.getn(self.profileActionButtons or {}) do
    button = self.profileActionButtons[index]
    SetShown(button, not showEditor)
  end
  SetShown(self.profileNameEdit, showEditor)
  SetShown(self.profileConfirmButton, showEditor)
  SetShown(self.profileCancelButton, showEditor)
  if not showEditor then
    if self.profileNameEdit and self.profileNameEdit.ClearFocus then
      self.profileNameEdit:ClearFocus()
    end
    return
  end
  store = self:GetStore()
  if mode == "rename" then
    profile = store.profiles[self.profileSelection or store.active]
    self.profileNameEdit:SetText(profile and profile.name or "")
    self:SetProfileManagerStatus("输入新名称后确认。", false)
  else
    self.profileNameEdit:SetText(self:UniqueProfileName("新方案"))
    self:SetProfileManagerStatus("输入新方案名称后确认。", false)
  end
  self.profileNameEdit:SetFocus()
  if self.profileNameEdit.HighlightText then self.profileNameEdit:HighlightText() end
end

function GearPlanner:CommitProfileEdit()
  local ok, message
  if self.profileEditMode == "new" then
    ok, message = self:CreateProfile(self.profileNameEdit:GetText())
  elseif self.profileEditMode == "rename" then
    ok, message = self:RenameProfile(
      self.profileSelection,
      self.profileNameEdit:GetText()
    )
  else
    return
  end
  if ok then
    self.profilePage = math.ceil(self.profileSelection / PROFILE_PAGE_SIZE)
    self:SetProfileEditMode(nil)
  end
  self:SetProfileManagerStatus(message, not ok)
  self:RefreshProfileManager()
end

function GearPlanner:OpenProfileManager()
  local store
  self:CreateProfileManager()
  self:StopAtlasLootSelection(false)
  store = self:GetStore()
  self.profileSelection = store.active
  self.profilePage = math.ceil(store.active / PROFILE_PAGE_SIZE)
  self.profileDeleteArmed = nil
  self:SetProfileEditMode(nil)
  self:SetProfileManagerStatus(
    "选择方案后可激活、复制、重命名或删除。",
    false
  )
  self:RefreshProfileManager()
  self.profileManager:Show()
end

function GearPlanner:CreateProfileManager()
  local frame, close, title, index, row, useButton, newButton
  local copyButton, renameButton, deleteButton, previous, nextButton
  if self.profileManager then return end
  frame = CreateFrame(
    "Frame",
    "AzerothExpeditionUIGearPlannerProfiles",
    UIParent
  )
  frame:SetWidth(430)
  frame:SetHeight(430)
  frame:SetPoint("CENTER", UIParent, "CENTER", 0, 10)
  frame:SetFrameStrata("FULLSCREEN_DIALOG")
  frame:SetFrameLevel(90)
  frame:EnableMouse(true)
  CreateBackdrop(frame, 0.99)
  frame:Hide()
  self.profileManager = frame
  AddSpecialFrame("AzerothExpeditionUIGearPlannerProfiles")
  title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -17)
  title:SetText("配装方案管理")
  close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
  self.profileManagerStatus = frame:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormalSmall"
  )
  self.profileManagerStatus:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -40)
  self.profileManagerStatus:SetWidth(390)
  self.profileManagerStatus:SetJustifyH("LEFT")

  self.profileRows = {}
  for index = 1, PROFILE_PAGE_SIZE do
    row = CreateFrame("Button", nil, frame)
    row:SetWidth(398)
    row:SetHeight(30)
    row:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -58 - (index - 1) * 34)
    CreateBackdrop(row, 0.72)
    row.nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.nameText:SetPoint("LEFT", row, "LEFT", 10, 0)
    row.nameText:SetWidth(250)
    row.nameText:SetJustifyH("LEFT")
    row.metaText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.metaText:SetPoint("RIGHT", row, "RIGHT", -10, 0)
    row.metaText:SetWidth(124)
    row.metaText:SetJustifyH("RIGHT")
    row:SetScript("OnClick", function()
      if not this.profileIndex then return end
      GearPlanner.profileSelection = this.profileIndex
      GearPlanner.profileDeleteArmed = nil
      GearPlanner:SetProfileManagerStatus(
        "已选择“" ..
        tostring(GearPlanner:GetStore().profiles[this.profileIndex].name) ..
        "”。",
        false
      )
      GearPlanner:RefreshProfileManager()
    end)
    self.profileRows[index] = row
  end

  previous = CreateButton(frame, "<", 34, 22)
  previous:SetPoint("BOTTOM", frame, "BOTTOM", -68, 82)
  previous:SetScript("OnClick", function()
    GearPlanner.profilePage = math.max(1, GearPlanner.profilePage - 1)
    GearPlanner.profileSelection =
      (GearPlanner.profilePage - 1) * PROFILE_PAGE_SIZE + 1
    GearPlanner.profileDeleteArmed = nil
    GearPlanner:RefreshProfileManager()
  end)
  self.profilePreviousPage = previous
  self.profilePageText = frame:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormalSmall"
  )
  self.profilePageText:SetPoint("LEFT", previous, "RIGHT", 10, 0)
  self.profilePageText:SetWidth(92)
  nextButton = CreateButton(frame, ">", 34, 22)
  nextButton:SetPoint("LEFT", self.profilePageText, "RIGHT", 4, 0)
  nextButton:SetScript("OnClick", function()
    GearPlanner.profilePage = GearPlanner.profilePage + 1
    GearPlanner.profileSelection =
      (GearPlanner.profilePage - 1) * PROFILE_PAGE_SIZE + 1
    GearPlanner.profileDeleteArmed = nil
    GearPlanner:RefreshProfileManager()
  end)
  self.profileNextPage = nextButton

  useButton = CreateButton(frame, "使用", 54, 24)
  newButton = CreateButton(frame, "新建", 54, 24)
  copyButton = CreateButton(frame, "复制", 54, 24)
  renameButton = CreateButton(frame, "重命名", 64, 24)
  deleteButton = CreateButton(frame, "删除", 54, 24)
  useButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 64, 18)
  newButton:SetPoint("LEFT", useButton, "RIGHT", 4, 0)
  copyButton:SetPoint("LEFT", newButton, "RIGHT", 4, 0)
  renameButton:SetPoint("LEFT", copyButton, "RIGHT", 4, 0)
  deleteButton:SetPoint("LEFT", renameButton, "RIGHT", 4, 0)
  self.profileUseButton = useButton
  self.profileDeleteButton = deleteButton
  self.profileActionButtons = {
    useButton, newButton, copyButton, renameButton, deleteButton,
  }
  useButton:SetScript("OnClick", function()
    local ok, message = GearPlanner:ActivateProfile(
      GearPlanner.profileSelection
    )
    GearPlanner.profilePage = math.ceil(
      GearPlanner.profileSelection / PROFILE_PAGE_SIZE
    )
    GearPlanner:SetProfileManagerStatus(message, not ok)
    GearPlanner:RefreshProfileManager()
  end)
  newButton:SetScript("OnClick", function()
    GearPlanner.profileDeleteArmed = nil
    GearPlanner:SetProfileEditMode("new")
  end)
  copyButton:SetScript("OnClick", function()
    local ok, message = GearPlanner:DuplicateProfile(
      GearPlanner.profileSelection
    )
    GearPlanner.profilePage = math.ceil(
      GearPlanner.profileSelection / PROFILE_PAGE_SIZE
    )
    GearPlanner.profileDeleteArmed = nil
    GearPlanner:SetProfileManagerStatus(message, not ok)
    GearPlanner:RefreshProfileManager()
  end)
  renameButton:SetScript("OnClick", function()
    GearPlanner.profileDeleteArmed = nil
    GearPlanner:SetProfileEditMode("rename")
  end)
  deleteButton:SetScript("OnClick", function()
    local selected = GearPlanner.profileSelection
    local now = GetTime and GetTime() or 0
    local armed = GearPlanner.profileDeleteArmed
    local ok, message
    if
      not armed or
      armed.index ~= selected or
      now - (armed.time or 0) > 5
    then
      GearPlanner.profileDeleteArmed = { index = selected, time = now }
      GearPlanner:SetProfileManagerStatus(
        "再次点击“删除”确认移除所选方案。",
        true
      )
      return
    end
    ok, message = GearPlanner:DeleteProfile(selected)
    GearPlanner.profileDeleteArmed = nil
    GearPlanner.profilePage = math.ceil(
      GearPlanner.profileSelection / PROFILE_PAGE_SIZE
    )
    GearPlanner:SetProfileManagerStatus(message, not ok)
    GearPlanner:RefreshProfileManager()
  end)

  self.profileNameEdit = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
  self.profileNameEdit:SetWidth(236)
  self.profileNameEdit:SetHeight(24)
  self.profileNameEdit:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 34, 18)
  self.profileNameEdit:SetAutoFocus(false)
  if self.profileNameEdit.SetMaxLetters then self.profileNameEdit:SetMaxLetters(32) end
  self.profileNameEdit:SetScript("OnEnterPressed", function()
    GearPlanner:CommitProfileEdit()
  end)
  self.profileNameEdit:SetScript("OnEscapePressed", function()
    GearPlanner:SetProfileEditMode(nil)
    GearPlanner:SetProfileManagerStatus("已取消编辑。", false)
  end)
  self.profileConfirmButton = CreateButton(frame, "确认", 58, 24)
  self.profileConfirmButton:SetPoint("LEFT", self.profileNameEdit, "RIGHT", 6, 0)
  self.profileConfirmButton:SetScript("OnClick", function()
    GearPlanner:CommitProfileEdit()
  end)
  self.profileCancelButton = CreateButton(frame, "取消", 54, 24)
  self.profileCancelButton:SetPoint(
    "LEFT",
    self.profileConfirmButton,
    "RIGHT",
    4,
    0
  )
  self.profileCancelButton:SetScript("OnClick", function()
    GearPlanner:SetProfileEditMode(nil)
    GearPlanner:SetProfileManagerStatus("已取消编辑。", false)
  end)
  frame:SetScript("OnHide", function()
    GearPlanner.profileDeleteArmed = nil
    GearPlanner:SetProfileEditMode(nil)
  end)
  self:SetProfileEditMode(nil)
end

function GearPlanner:CreateFrame()
  local frame, close, title, profilePrevious, profileNext
  local importButton, clearButton, manageButton, index, definition, statsPanel
  if self.frame then return end
  frame = CreateFrame("Frame", "AzerothExpeditionUIGearPlannerFrame", UIParent)
  frame:SetWidth(760)
  frame:SetHeight(555)
  frame:SetPoint("CENTER", UIParent, "CENTER", 0, 10)
  frame:SetFrameStrata("FULLSCREEN_DIALOG")
  frame:SetFrameLevel(70)
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:RegisterForDrag("LeftButton")
  CreateBackdrop(frame, 0.98)
  frame:SetScript("OnDragStart", function()
    if not GearPlanner.companionMode then this:StartMoving() end
  end)
  frame:SetScript("OnDragStop", function()
    if not GearPlanner.companionMode then this:StopMovingOrSizing() end
  end)
  frame:SetScript("OnHide", function()
    if not GearPlanner.suppressPlanHide then
      GearPlanner:StopAtlasLootSelection(false)
    end
    if GearPlanner.profileManager then GearPlanner.profileManager:Hide() end
    GearPlanner:OnPlanFrameHidden()
  end)
  frame:SetScript("OnShow", function() GearPlanner:UpdateAll() end)
  frame:Hide()
  self.frame = frame
  AddSpecialFrame("AzerothExpeditionUIGearPlannerFrame")
  title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -16)
  title:SetWidth(320)
  title:SetHeight(20)
  title:SetJustifyH("LEFT")
  title:SetText("配装方案")
  self.titleText = title
  close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
  close:SetScript("OnClick", function() GearPlanner:CloseActiveView() end)
  self.closeButton = close
  profileNext = CreateButton(frame, ">", 24, 20)
  profileNext:SetPoint("RIGHT", close, "LEFT", -2, 0)
  profileNext:SetScript("OnClick", function() GearPlanner:CycleProfile(1) end)
  self.profileNextButton = profileNext
  profilePrevious = CreateButton(frame, "<", 24, 20)
  profilePrevious:SetPoint("RIGHT", profileNext, "LEFT", -2, 0)
  profilePrevious:SetScript("OnClick", function() GearPlanner:CycleProfile(-1) end)
  self.profilePreviousButton = profilePrevious
  importButton = CreateButton(frame, "导入当前装备", 116, 22)
  importButton:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -43)
  importButton:SetScript("OnClick", function() GearPlanner:ImportCurrent() end)
  self.importButton = importButton
  clearButton = CreateButton(frame, "清空", 64, 22)
  clearButton:SetPoint("LEFT", importButton, "RIGHT", 7, 0)
  clearButton:SetScript("OnClick", function()
    local profile = GearPlanner:GetProfile()
    profile.slots = {}
    profile.inspectSignature = nil
    profile.referenceSource = nil
    profile.referenceName = nil
    profile.capturedSlots = nil
    GearPlanner.statCache = {}
    GearPlanner:UpdateAll()
  end)
  self.clearButton = clearButton
  manageButton = CreateButton(frame, "方案管理", 78, 22)
  manageButton:SetPoint("LEFT", clearButton, "RIGHT", 7, 0)
  manageButton:SetScript("OnClick", function()
    GearPlanner:OpenProfileManager()
  end)
  self.profileManageButton = manageButton
  self.providerText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  self.providerText:SetPoint("LEFT", manageButton, "RIGHT", 14, 0)
  self.providerText:SetWidth(400)
  self.providerText:SetJustifyH("LEFT")
  self.slotButtons = {}
  for index = 1, table.getn(SLOT_DEFS) do
    definition = SLOT_DEFS[index]
    self.slotButtons[definition[1]] = self:CreateSlotButton(frame, definition, index)
  end
  statsPanel = CreateFrame("Frame", nil, frame)
  statsPanel:SetWidth(306)
  statsPanel:SetHeight(463)
  statsPanel:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -16, -72)
  CreateBackdrop(statsPanel, 0.66)
  self.statsPanel = statsPanel
  self.statsText = statsPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  self.statsText:SetPoint("TOPLEFT", statsPanel, "TOPLEFT", 12, -12)
  self.statsText:SetWidth(282)
  self.statsText:SetJustifyH("LEFT")
  self.statsText:SetJustifyV("TOP")
  self.statsCurrentText = statsPanel:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontHighlightSmall"
  )
  self.statsCurrentText:SetJustifyH("RIGHT")
  self.statsCurrentText:SetJustifyV("TOP")
  self.statsPlannedText = statsPanel:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontHighlightSmall"
  )
  self.statsPlannedText:SetJustifyH("RIGHT")
  self.statsPlannedText:SetJustifyV("TOP")
  self.statsDeltaText = statsPanel:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontHighlightSmall"
  )
  self.statsDeltaText:SetJustifyH("RIGHT")
  self.statsDeltaText:SetJustifyV("TOP")
  self.statRows = {}
  self.statsEmptyText = statsPanel:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontHighlightSmall"
  )
  self.statsEmptyText:SetJustifyH("LEFT")
  self.statsEmptyText:SetJustifyV("TOP")
  self.statsNoteText = statsPanel:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormalSmall"
  )
  self.statsNoteText:SetJustifyH("LEFT")
  self.statsNoteText:SetJustifyV("BOTTOM")
  self.statsNoteText:SetText(
    "|cff777777未填槽位按空槽；仅比较装备静态属性\n" ..
    "攻速变化为琥珀色，不判断快慢优劣|r"
  )
  self:SetStandaloneLayout()
end

function GearPlanner:LayoutSlotButton(button, index, companion)
  local column = math.floor((index - 1) / 10)
  local row = (index - 1) - column * 10
  if companion then
    button:SetWidth(164)
    button:SetHeight(40)
    button:ClearAllPoints()
    button:SetPoint(
      "TOPLEFT",
      self.frame,
      "TOPLEFT",
      10 + column * 172,
      -92 - row * 44
    )
    button.icon:SetWidth(28)
    button.icon:SetHeight(28)
    button.itemText:SetWidth(112)
  else
    button:SetWidth(202)
    button:SetHeight(42)
    button:ClearAllPoints()
    button:SetPoint(
      "TOPLEFT",
      self.frame,
      "TOPLEFT",
      14 + column * 212,
      -72 - row * 46
    )
    button.icon:SetWidth(32)
    button.icon:SetHeight(32)
    button.itemText:SetWidth(152)
  end
end

function GearPlanner:SetPlanPane(pane)
  local index, definition, button
  self.planPane = "combined"
  if not self.frame then return end
  for index = 1, table.getn(SLOT_DEFS) do
    definition = SLOT_DEFS[index]
    button = self.slotButtons and self.slotButtons[definition[1]]
    if button then button:Show() end
  end
  if self.statsPanel then self.statsPanel:Show() end
end

function GearPlanner:LayoutStatsColumns(companion)
  local labelWidth = companion and 68 or 120
  local valueWidth = companion and 34 or 48
  local innerWidth = self.statsPanel:GetWidth() - 24
  local deltaWidth = innerWidth - labelWidth - valueWidth * 2
  local x = 12
  local column, index, row
  local columns = {
    { self.statsText, labelWidth, "LEFT" },
    { self.statsCurrentText, valueWidth, "RIGHT" },
    { self.statsPlannedText, valueWidth, "RIGHT" },
    { self.statsDeltaText, deltaWidth, "RIGHT" },
  }
  self.statsLayout = {
    labelWidth = labelWidth,
    valueWidth = valueWidth,
    deltaWidth = deltaWidth,
  }
  for index = 1, table.getn(columns) do
    column = columns[index]
    column[1]:ClearAllPoints()
    column[1]:SetPoint("TOPLEFT", self.statsPanel, "TOPLEFT", x, -12)
    column[1]:SetWidth(column[2])
    column[1]:SetHeight(14)
    column[1]:SetJustifyH(column[3])
    column[1]:SetJustifyV("MIDDLE")
    x = x + column[2]
  end
  for index = 1, table.getn(self.statRows or {}) do
    row = self.statRows[index]
    self:LayoutStatRow(row, index)
  end
  self.statsEmptyText:ClearAllPoints()
  self.statsEmptyText:SetPoint(
    "TOPLEFT",
    self.statsPanel,
    "TOPLEFT",
    12,
    -STAT_ROW_TOP
  )
  self.statsEmptyText:SetWidth(innerWidth)
  self.statsEmptyText:SetHeight(24)
  self.statsNoteText:ClearAllPoints()
  self.statsNoteText:SetPoint("BOTTOMLEFT", self.statsPanel, "BOTTOMLEFT", 12, 8)
  self.statsNoteText:SetWidth(innerWidth)
  self.statsNoteText:SetHeight(24)
end

function GearPlanner:SetCompanionLayout()
  local index, definition, button
  if not self.frame then return end
  if not self.companionMode then
    self.frameAnchorRestore = { points = CapturePoints(self.frame) }
  end
  self.companionMode = true

  self.frame:SetWidth(PLAN_COMPANION_FRAME_WIDTH)
  self.frame:SetHeight(555)
  self.frame:SetMovable(false)
  self.frame:ClearAllPoints()
  if self.companionRail then
    self.frame:SetPoint(
      "TOPLEFT",
      self.companionRail,
      "TOPRIGHT",
      COMPANION_RAIL_GAP,
      0
    )
  else
    self.frame:SetPoint(
      "TOPLEFT",
      CharacterFrame,
      "TOPRIGHT",
      COMPANION_GAP + COMPANION_RAIL_WIDTH + COMPANION_RAIL_GAP,
      0
    )
  end

  self.importButton:SetWidth(94)
  self.importButton:ClearAllPoints()
  self.importButton:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 10, -43)
  self.clearButton:SetWidth(50)
  self.clearButton:ClearAllPoints()
  self.clearButton:SetPoint("LEFT", self.importButton, "RIGHT", 4, 0)
  self.profileManageButton:SetWidth(78)
  self.profileManageButton:ClearAllPoints()
  self.profileManageButton:SetPoint("LEFT", self.clearButton, "RIGHT", 4, 0)

  self.providerText:ClearAllPoints()
  self.providerText:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 12, -70)
  self.providerText:SetWidth(536)

  for index = 1, table.getn(SLOT_DEFS) do
    definition = SLOT_DEFS[index]
    button = self.slotButtons[definition[1]]
    self:LayoutSlotButton(button, index, true)
  end

  self.statsPanel:ClearAllPoints()
  self.statsPanel:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 354, -92)
  self.statsPanel:SetWidth(196)
  self.statsPanel:SetHeight(448)
  self:LayoutStatsColumns(true)
  self:SetPlanPane("combined")
end

function GearPlanner:SetStandaloneLayout()
  local index, definition, button
  if not self.frame then return end
  self.companionMode = false

  self.frame:SetWidth(760)
  self.frame:SetHeight(555)
  self.frame:SetMovable(true)
  if self.frameAnchorRestore and
    table.getn(self.frameAnchorRestore.points or {}) > 0
  then
    RestorePoints(self.frame, self.frameAnchorRestore.points)
  else
    self.frame:ClearAllPoints()
    self.frame:SetPoint("CENTER", UIParent, "CENTER", 0, 10)
  end
  self.frameAnchorRestore = nil

  self.importButton:SetWidth(116)
  self.importButton:ClearAllPoints()
  self.importButton:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 16, -43)
  self.clearButton:SetWidth(64)
  self.clearButton:ClearAllPoints()
  self.clearButton:SetPoint("LEFT", self.importButton, "RIGHT", 7, 0)
  self.profileManageButton:SetWidth(78)
  self.profileManageButton:ClearAllPoints()
  self.profileManageButton:SetPoint("LEFT", self.clearButton, "RIGHT", 7, 0)

  self.providerText:ClearAllPoints()
  self.providerText:SetPoint("LEFT", self.profileManageButton, "RIGHT", 14, 0)
  self.providerText:SetWidth(380)

  for index = 1, table.getn(SLOT_DEFS) do
    definition = SLOT_DEFS[index]
    button = self.slotButtons[definition[1]]
    self:LayoutSlotButton(button, index, false)
    button:Show()
  end

  self.statsPanel:ClearAllPoints()
  self.statsPanel:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", -16, -72)
  self.statsPanel:SetWidth(306)
  self.statsPanel:SetHeight(463)
  self:LayoutStatsColumns(false)
  self.statsPanel:Show()
end

function GearPlanner:CharacterCompanionSupported()
  local width, height
  if not addon.db or not addon.db.character or not addon.db.character.enabled then
    return false, "character-disabled"
  end
  if not CharacterFrame or not PaperDollFrame then
    return false, "character-provider-missing"
  end
  width = CharacterFrame:GetWidth()
  height = CharacterFrame:GetHeight()
  if
    not width or
    not height or
    math.abs(width - 384) > 2 or
    math.abs(height - 512) > 2
  then
    return false, "character-geometry-unsupported"
  end
  return true, "ready"
end

function GearPlanner:CompanionContextVisible()
  return FrameVisible(CharacterFrame) and FrameVisible(PaperDollFrame)
end

function GearPlanner:DiscoverCompanionProviders()
  self.providers = self.providers or {}
  self.providers.current = _G["S_ItemTip_InspectFrame"]
  if _G["StatCompare_enable"] == 0 then
    self.providers.stats = nil
  else
    self.providers.stats = _G["StatCompareSelfFrame"]
  end
  return self.providers
end

function GearPlanner:ViewAvailable(view)
  if view == "plan" then return true end
  self:DiscoverCompanionProviders()
  return self.providers[view] and true or false
end

function GearPlanner:ResolveActiveView()
  local preferred = addon.db.gearplanner.companionView or "current"
  if self:ViewAvailable(preferred) then return preferred end
  if self:ViewAvailable("current") then return "current" end
  if self:ViewAvailable("stats") then return "stats" end
  return "plan"
end

function GearPlanner:CaptureProviderState(frame)
  if not frame then return end
  self.providerRestores = self.providerRestores or {}
  if self.providerRestores[frame] then return end
  self.providerRestores[frame] = {
    shown = FrameVisible(frame),
    points = CapturePoints(frame),
  }
end

function GearPlanner:RestoreProviderStates(restore)
  local frame, state
  for frame, state in pairs(self.providerRestores or {}) do
    if restore then
      RestorePoints(frame, state.points)
      SetShown(frame, state.shown)
    end
  end
  self.providerRestores = {}
end

function GearPlanner:AnchorProviderRight(frame)
  if not frame or not self.companionRail then return false end
  self:CaptureProviderState(frame)
  frame:ClearAllPoints()
  frame:SetPoint(
    "TOPLEFT",
    self.companionRail,
    "TOPRIGHT",
    COMPANION_RAIL_GAP,
    0
  )
  return true
end

function GearPlanner:AnchorStatsLeft(frame)
  if not frame or not CharacterFrame then return false end
  self:CaptureProviderState(frame)
  frame:ClearAllPoints()
  frame:SetPoint(
    "TOPRIGHT",
    CharacterFrame,
    "TOPLEFT",
    -COMPANION_GAP,
    0
  )
  return true
end

function GearPlanner:WideLayoutSupported()
  local parentWidth, left, right, statsWidth, rightNeed
  self:DiscoverCompanionProviders()
  if
    self.activeView == "plan" or
    addon.db.gearplanner.companionView == "plan"
  then
    return false
  end
  if not self.providers.stats or not UIParent or not CharacterFrame then
    return false
  end
  parentWidth = UIParent:GetWidth()
  if not parentWidth or parentWidth < WIDE_MIN_WIDTH then return false end
  left = CharacterFrame:GetLeft()
  right = CharacterFrame:GetRight()
  if not left or not right then return true end
  statsWidth = self.providers.stats:GetWidth() or 240
  rightNeed =
    COMPANION_GAP + COMPANION_RAIL_WIDTH +
    COMPANION_RAIL_GAP + WIDE_RIGHT_FALLBACK
  return left >= statsWidth + COMPANION_GAP and
    parentWidth - right >= rightNeed
end

function GearPlanner:CreateCompanionRailButton(
  parent,
  name,
  label,
  title,
  tooltip,
  view
)
  local button = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
  button:SetWidth(24)
  button:SetHeight(24)
  button:SetText(label)
  button.viewKey = view
  button.tooltipTitle = title
  button.tooltipText = tooltip
  button:SetScript("OnClick", function()
    if this.viewKey == "wide" then
      GearPlanner:ToggleWideMode()
    else
      GearPlanner:SetActiveView(this.viewKey, true)
    end
  end)
  button:SetScript("OnEnter", function()
    GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
    GameTooltip:SetText(this.tooltipTitle, 1, 0.82, 0)
    if this.tooltipText then
      GameTooltip:AddLine(this.tooltipText, 0.82, 0.76, 0.62)
    end
    GameTooltip:Show()
  end)
  button:SetScript("OnLeave", function() GameTooltip:Hide() end)
  return button
end

function GearPlanner:CreateCompanionRail()
  local rail, index, definition, button
  if self.companionRail or not CharacterFrame then return end
  rail = CreateFrame(
    "Frame",
    "AzerothExpeditionUICharacterCompanionRail",
    CharacterFrame
  )
  rail:SetWidth(COMPANION_RAIL_WIDTH)
  rail:SetHeight(30)
  rail:SetPoint("TOPLEFT", CharacterFrame, "TOPRIGHT", COMPANION_GAP, 0)
  rail:SetFrameStrata("FULLSCREEN_DIALOG")
  rail:SetFrameLevel(75)
  CreateBackdrop(rail, 0.94)
  rail:Hide()
  self.companionRail = rail
  self.companionButtons = {}

  for index = 1, table.getn(COMPANION_VIEWS) do
    definition = COMPANION_VIEWS[index]
    button = self:CreateCompanionRailButton(
      rail,
      "AzerothExpeditionUICharacterCompanion" .. definition.key,
      definition.label,
      definition.title,
      definition.tooltip,
      definition.key
    )
    self.companionButtons[definition.key] = button
  end
  self.wideButton = self:CreateCompanionRailButton(
    rail,
    "AzerothExpeditionUICharacterCompanionWide",
    "双",
    "双栏模式",
    "宽屏时在角色页左侧同时保留 StatCompare",
    "wide"
  )
end

function GearPlanner:UpdateCompanionRail()
  local index, definition, button, count, y
  if not self.companionRail then return end
  count = 0
  y = -2
  for index = 1, table.getn(COMPANION_VIEWS) do
    definition = COMPANION_VIEWS[index]
    button = self.companionButtons[definition.key]
    button:ClearAllPoints()
    if self:ViewAvailable(definition.key) then
      button:SetPoint("TOP", self.companionRail, "TOP", 0, y)
      button:Show()
      y = y - 26
      count = count + 1
      if definition.key == self.activeView then
        button:LockHighlight()
      else
        button:UnlockHighlight()
      end
    else
      button:Hide()
      button:UnlockHighlight()
    end
  end

  self.wideButton:ClearAllPoints()
  if self:WideLayoutSupported() then
    self.wideButton:SetPoint("TOP", self.companionRail, "TOP", 0, y)
    self.wideButton:Show()
    count = count + 1
    if self.wideActive then
      self.wideButton:LockHighlight()
    else
      self.wideButton:UnlockHighlight()
    end
  else
    self.wideButton:Hide()
    self.wideButton:UnlockHighlight()
  end

  self.companionRail:SetHeight(math.max(30, 4 + count * 26))
  self.companionRail:Show()
end

function GearPlanner:InspectCompanionSupported()
  local width, height
  if not InspectFrame or not InspectPaperDollFrame then
    return false, "inspect-provider-missing"
  end
  width = InspectFrame:GetWidth()
  height = InspectFrame:GetHeight()
  if
    not width or
    not height or
    math.abs(width - 384) > 2 or
    math.abs(height - 512) > 2
  then
    return false, "inspect-geometry-unsupported"
  end
  return true, "ready"
end

function GearPlanner:InspectContextVisible()
  return FrameVisible(InspectFrame) and FrameVisible(InspectPaperDollFrame)
end

function GearPlanner:PrepareInspectSession()
  local unit = InspectFrame and InspectFrame.unit
  local name = unit and UnitName(unit)
  local key = tostring(unit or "none") .. ":" .. tostring(name or "unknown")
  if key ~= self.inspectSessionKey then
    self.inspectSessionKey = key
    self.inspectDataReady = false
  end
  return unit, name
end

function GearPlanner:DiscoverInspectProviders()
  self.inspectProviders = self.inspectProviders or {}
  self.inspectProviders.gear = _G["S_ItemTip_InspectFrame"]
  if _G["StatCompare_enable"] == 0 then
    self.inspectProviders.targetStats = nil
    self.inspectProviders.selfStats = nil
  else
    self.inspectProviders.targetStats = _G["StatCompareTargetFrame"]
    self.inspectProviders.selfStats = _G["StatCompareSelfFrame"]
  end
  return self.inspectProviders
end

function GearPlanner:InspectCompareSupported()
  local parentWidth, left, right, selfWidth, targetWidth, rightNeed
  self:DiscoverInspectProviders()
  if
    not UIParent or
    not InspectFrame or
    not self.inspectProviders.targetStats or
    not self.inspectProviders.selfStats
  then
    return false
  end
  parentWidth = UIParent:GetWidth()
  left = InspectFrame:GetLeft()
  right = InspectFrame:GetRight()
  if not parentWidth or not left or not right then return false end
  selfWidth = self.inspectProviders.selfStats:GetWidth() or 240
  targetWidth = self.inspectProviders.targetStats:GetWidth() or 240
  rightNeed = INSPECT_GAP + COMPANION_RAIL_WIDTH +
    INSPECT_RAIL_GAP + targetWidth
  return left >= selfWidth + INSPECT_GAP and
    parentWidth - right >= rightNeed
end

function GearPlanner:InspectViewAvailable(view)
  self:DiscoverInspectProviders()
  if view == "gear" then
    return self.inspectProviders.gear and true or false
  elseif view == "stats" then
    return self.inspectProviders.targetStats and true or false
  elseif view == "compare" then
    return self:InspectCompareSupported()
  end
  return false
end

function GearPlanner:ResolveInspectView()
  local preferred = addon.db.gearplanner.inspectView or "gear"
  if self:InspectViewAvailable(preferred) then return preferred end
  if self:InspectViewAvailable("gear") then return "gear" end
  if self:InspectViewAvailable("stats") then return "stats" end
  return nil
end

function GearPlanner:CaptureInspectProviderState(frame)
  if not frame then return end
  self.inspectProviderRestores = self.inspectProviderRestores or {}
  if self.inspectProviderRestores[frame] then return end
  self.inspectProviderRestores[frame] = {
    shown = FrameVisible(frame),
    points = CapturePoints(frame),
  }
end

function GearPlanner:RestoreInspectProviderStates(restore)
  local frame, state
  for frame, state in pairs(self.inspectProviderRestores or {}) do
    if restore then
      RestorePoints(frame, state.points)
      SetShown(frame, state.shown)
    end
  end
  self.inspectProviderRestores = {}
end

function GearPlanner:ReleaseInspectProviderStates()
  local frame, state
  for frame, state in pairs(self.inspectProviderRestores or {}) do
    RestorePoints(frame, state.points)
    SetShown(frame, false)
  end
  self.inspectProviderRestores = {}
end

function GearPlanner:AnchorInspectProviderRight(frame)
  if not frame or not self.inspectRail then return false end
  self:CaptureInspectProviderState(frame)
  frame:ClearAllPoints()
  frame:SetPoint(
    "TOPLEFT",
    self.inspectRail,
    "TOPRIGHT",
    INSPECT_RAIL_GAP,
    0
  )
  return true
end

function GearPlanner:AnchorInspectSelfLeft(frame)
  if not frame or not InspectFrame then return false end
  self:CaptureInspectProviderState(frame)
  frame:ClearAllPoints()
  frame:SetPoint(
    "TOPRIGHT",
    InspectFrame,
    "TOPLEFT",
    -INSPECT_GAP,
    0
  )
  return true
end

function GearPlanner:CreateInspectRailButton(
  parent,
  name,
  label,
  title,
  tooltip,
  view
)
  local button = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
  button:SetWidth(24)
  button:SetHeight(24)
  button:SetText(label)
  button.inspectViewKey = view
  button.tooltipTitle = title
  button.tooltipText = tooltip
  button:SetScript("OnClick", function()
    local _, result
    if this.inspectViewKey == "save" then
      _, result = GearPlanner:SaveInspectReference()
      addon:Print(result)
    else
      GearPlanner:SetInspectView(this.inspectViewKey)
    end
  end)
  button:SetScript("OnEnter", function()
    GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
    GameTooltip:SetText(this.tooltipTitle, 1, 0.82, 0)
    if this.tooltipText then
      GameTooltip:AddLine(this.tooltipText, 0.82, 0.76, 0.62)
    end
    GameTooltip:Show()
  end)
  button:SetScript("OnLeave", function() GameTooltip:Hide() end)
  return button
end

function GearPlanner:CreateInspectRail()
  local rail, index, definition, button
  if self.inspectRail or not InspectFrame then return end
  rail = CreateFrame(
    "Frame",
    "AzerothExpeditionUIInspectCompanionRail",
    InspectFrame
  )
  rail:SetWidth(COMPANION_RAIL_WIDTH)
  rail:SetHeight(30)
  rail:SetPoint("TOPLEFT", InspectFrame, "TOPRIGHT", INSPECT_GAP, 0)
  rail:SetFrameStrata("FULLSCREEN_DIALOG")
  rail:SetFrameLevel(75)
  CreateBackdrop(rail, 0.94)
  rail:Hide()
  self.inspectRail = rail
  self.inspectButtons = {}

  for index = 1, table.getn(INSPECT_VIEWS) do
    definition = INSPECT_VIEWS[index]
    button = self:CreateInspectRailButton(
      rail,
      "AzerothExpeditionUIInspectCompanion" .. definition.key,
      definition.label,
      definition.title,
      definition.tooltip,
      definition.key
    )
    self.inspectButtons[definition.key] = button
  end
  self.inspectSaveButton = self:CreateInspectRailButton(
    rail,
    "AzerothExpeditionUIInspectCompanionSave",
    "存",
    "保存为配装参考",
    "新建并激活目标装备方案；原方案不会被覆盖",
    "save"
  )
end

function GearPlanner:UpdateInspectRail()
  local index, definition, button, count, y
  if not self.inspectRail then return end
  count = 0
  y = -2
  for index = 1, table.getn(INSPECT_VIEWS) do
    definition = INSPECT_VIEWS[index]
    button = self.inspectButtons[definition.key]
    button:ClearAllPoints()
    if self:InspectViewAvailable(definition.key) then
      button:SetPoint("TOP", self.inspectRail, "TOP", 0, y)
      button:Show()
      y = y - 26
      count = count + 1
      if definition.key == self.inspectActiveView then
        button:LockHighlight()
      else
        button:UnlockHighlight()
      end
    else
      button:Hide()
      button:UnlockHighlight()
    end
  end

  self.inspectSaveButton:ClearAllPoints()
  if
    self.inspectDataReady and
    InspectFrame and
    InspectFrame.unit and
    UnitExists(InspectFrame.unit)
  then
    self.inspectSaveButton:SetPoint("TOP", self.inspectRail, "TOP", 0, y)
    self.inspectSaveButton:Show()
    count = count + 1
  else
    self.inspectSaveButton:Hide()
  end
  self.inspectRail:SetHeight(math.max(30, 4 + count * 26))
  if count > 0 then self.inspectRail:Show() else self.inspectRail:Hide() end
end

function GearPlanner:InstallProviderHooks()
  if
    not self.statCompareShowHooked and
    type(hooksecurefunc) == "function" and
    type(SCShowFrame) == "function"
  then
    hooksecurefunc("SCShowFrame", function(frame)
      if
        frame == _G["StatCompareSelfFrame"] and
        GearPlanner:CompanionContextVisible() and
        Enabled()
      then
        GearPlanner:ScheduleCompanionSettle(1)
      end
      if
        (frame == _G["StatCompareTargetFrame"] or
          frame == _G["StatCompareSelfFrame"]) and
        GearPlanner:InspectContextVisible() and
        Enabled()
      then
        GearPlanner:ScheduleInspectSettle(1)
      end
    end)
    self.statCompareShowHooked = true
  end
  if
    not self.sItemUpdateHooked and
    type(hooksecurefunc) == "function" and
    type(S_ItemTip_UpdateFrame) == "function"
  then
    hooksecurefunc("S_ItemTip_UpdateFrame", function(unit)
      if
        not GearPlanner.suppressProviderUpdateHook and
        GearPlanner:InspectContextVisible() and
        InspectFrame and
        unit == InspectFrame.unit and
        Enabled()
      then
        GearPlanner:PrepareInspectSession()
        GearPlanner.inspectDataReady = true
        GearPlanner:ScheduleInspectSettle(1)
      end
    end)
    self.sItemUpdateHooked = true
  end
  self:InstallAtlasLootIntegration()
end

function GearPlanner:CreateCompanionControllers()
  local controller
  if CharacterFrame and not self.characterController then
    controller = CreateFrame(
      "Frame",
      "AzerothExpeditionUICharacterCompanionController",
      CharacterFrame
    )
    controller:SetWidth(1)
    controller:SetHeight(1)
    controller:SetPoint("TOPLEFT", CharacterFrame, "TOPLEFT", 0, 0)
    controller:SetScript("OnShow", function()
      GearPlanner:ScheduleCompanionSettle(2)
    end)
    controller:SetScript("OnHide", function()
      GearPlanner:OnCompanionContextHidden()
    end)
    controller:Show()
    self.characterController = controller
  end

  if PaperDollFrame and not self.paperDollController then
    controller = CreateFrame(
      "Frame",
      "AzerothExpeditionUIPaperDollCompanionController",
      PaperDollFrame
    )
    controller:SetWidth(1)
    controller:SetHeight(1)
    controller:SetPoint("TOPLEFT", PaperDollFrame, "TOPLEFT", 0, 0)
    controller:SetScript("OnShow", function()
      GearPlanner:ScheduleCompanionSettle(2)
    end)
    controller:SetScript("OnHide", function()
      GearPlanner:OnCompanionContextHidden()
    end)
    controller:Show()
    self.paperDollController = controller
  end

  if not self.providerEventFrame then
    controller = CreateFrame(
      "Frame",
      "AzerothExpeditionUICompanionProviderEvents",
      UIParent
    )
    controller:RegisterEvent("ADDON_LOADED")
    controller:RegisterEvent("INSPECT_READY")
    controller:RegisterEvent("UNIT_INVENTORY_CHANGED")
    controller:SetScript("OnEvent", function()
      if event == "UNIT_INVENTORY_CHANGED" then
        if
          arg1 == "player" and
          Enabled() and
          GearPlanner.frame and
          FrameVisible(GearPlanner.frame)
        then
          GearPlanner:UpdateSlots()
          GearPlanner:UpdateStats()
        end
        return
      end
      GearPlanner:CreateCompanionControllers()
      GearPlanner:CreateInspectControllers()
      GearPlanner:InstallProviderHooks()
      if event == "INSPECT_READY" and InspectFrame and InspectFrame.unit then
        GearPlanner:PrepareInspectSession()
        GearPlanner.inspectDataReady = true
      end
      if GearPlanner:CompanionContextVisible() then
        GearPlanner:ScheduleCompanionSettle(2)
      end
      if GearPlanner:InspectContextVisible() then
        GearPlanner:ScheduleInspectSettle(2)
      end
    end)
    self.providerEventFrame = controller
  end
end

function GearPlanner:CreateInspectControllers()
  local controller
  if InspectFrame and not self.inspectController then
    controller = CreateFrame(
      "Frame",
      "AzerothExpeditionUIInspectCompanionController",
      InspectFrame
    )
    controller:SetWidth(1)
    controller:SetHeight(1)
    controller:SetPoint("TOPLEFT", InspectFrame, "TOPLEFT", 0, 0)
    controller:SetScript("OnShow", function()
      GearPlanner:ScheduleInspectSettle(2)
    end)
    controller:SetScript("OnHide", function()
      GearPlanner:OnInspectHostHidden()
    end)
    controller:Show()
    self.inspectController = controller
  end

  if InspectPaperDollFrame and not self.inspectPaperDollController then
    controller = CreateFrame(
      "Frame",
      "AzerothExpeditionUIInspectPaperDollCompanionController",
      InspectPaperDollFrame
    )
    controller:SetWidth(1)
    controller:SetHeight(1)
    controller:SetPoint("TOPLEFT", InspectPaperDollFrame, "TOPLEFT", 0, 0)
    controller:SetScript("OnShow", function()
      GearPlanner:ScheduleInspectSettle(2)
    end)
    controller:SetScript("OnHide", function()
      GearPlanner:OnInspectContextHidden()
    end)
    controller:Show()
    self.inspectPaperDollController = controller
  end
end

function GearPlanner:ScheduleCompanionSettle(passes)
  local requested = tonumber(passes) or 1
  if requested < 1 then requested = 1 end
  if not self.settleFrame then
    self.settleFrame = CreateFrame(
      "Frame",
      "AzerothExpeditionUICompanionSettleFrame",
      UIParent
    )
  end
  self.settlePasses = math.max(tonumber(self.settlePasses) or 0, requested)
  self.settleFrame:SetScript("OnUpdate", function()
    GearPlanner.settlePasses = (tonumber(GearPlanner.settlePasses) or 1) - 1
    if GearPlanner.settlePasses <= 0 then
      this:SetScript("OnUpdate", nil)
      GearPlanner.settlePasses = 0
      GearPlanner:ReconcileCompanion()
    end
  end)
end

function GearPlanner:ScheduleInspectSettle(passes)
  local requested = tonumber(passes) or 1
  if requested < 1 then requested = 1 end
  if not self.inspectSettleFrame then
    self.inspectSettleFrame = CreateFrame(
      "Frame",
      "AzerothExpeditionUIInspectCompanionSettleFrame",
      UIParent
    )
  end
  self.inspectSettlePasses = math.max(
    tonumber(self.inspectSettlePasses) or 0,
    requested
  )
  self.inspectSettleFrame:SetScript("OnUpdate", function()
    GearPlanner.inspectSettlePasses =
      (tonumber(GearPlanner.inspectSettlePasses) or 1) - 1
    if GearPlanner.inspectSettlePasses <= 0 then
      this:SetScript("OnUpdate", nil)
      GearPlanner.inspectSettlePasses = 0
      GearPlanner:ReconcileInspectCompanion()
    end
  end)
end

function GearPlanner:HideInspectViews()
  self:DiscoverInspectProviders()
  SetShown(self.inspectProviders.gear, false)
  SetShown(self.inspectProviders.targetStats, false)
  SetShown(self.inspectProviders.selfStats, false)
end

function GearPlanner:OnInspectContextHidden()
  if self.inspectActive or self.inspectVisible then
    self:HideInspectViews()
  end
  if self.inspectRail then self.inspectRail:Hide() end
  self:ReleaseInspectProviderStates()
  self.inspectActive = false
  self.inspectVisible = false
  self.inspectActiveView = nil
  self.inspectReason = "hidden"
end

function GearPlanner:OnInspectHostHidden()
  self:OnInspectContextHidden()
  self.inspectSessionKey = nil
  self.inspectDataReady = false
end

function GearPlanner:SetInspectView(view)
  local index, definition, selectedDefinition
  for index = 1, table.getn(INSPECT_VIEWS) do
    definition = INSPECT_VIEWS[index]
    if definition.key == view then selectedDefinition = definition end
  end
  if not selectedDefinition then return false, "未知观察视图。" end
  if not self:InspectViewAvailable(view) then
    return false, "当前 Provider 或可用宽度不支持“" ..
      tostring(selectedDefinition.title) .. "”。"
  end
  addon.db.gearplanner.inspectView = view
  if self:InspectContextVisible() then
    self:ReconcileInspectCompanion()
  else
    self:ScheduleInspectSettle(2)
  end
  return true, "观察页已切换到“" .. tostring(selectedDefinition.title) .. "”。"
end

function GearPlanner:ReconcileInspectCompanion()
  local supported, reason, active
  local gearFrame, targetStats, selfStats, unit
  self:CreateInspectControllers()
  self:InstallProviderHooks()
  self:DiscoverInspectProviders()
  supported, reason = self:InspectCompanionSupported()
  self.inspectReason = reason

  if not Enabled() or not supported then
    if self.inspectRail then self.inspectRail:Hide() end
    if self.inspectActive and self:InspectContextVisible() then
      self:RestoreInspectProviderStates(true)
    end
    self.inspectActive = false
    self.inspectVisible = false
    self.inspectActiveView = nil
    return false
  end

  if not self:InspectContextVisible() then
    if self.inspectRail then self.inspectRail:Hide() end
    self.inspectVisible = false
    return false
  end

  self:PrepareInspectSession()
  self:CreateInspectRail()
  gearFrame = self.inspectProviders.gear
  targetStats = self.inspectProviders.targetStats
  selfStats = self.inspectProviders.selfStats
  self:CaptureInspectProviderState(gearFrame)
  self:CaptureInspectProviderState(targetStats)
  self:CaptureInspectProviderState(selfStats)

  active = self:ResolveInspectView()
  self:HideInspectViews()
  unit = InspectFrame and InspectFrame.unit
  if active == "gear" and gearFrame then
    self:AnchorInspectProviderRight(gearFrame)
    gearFrame:Show()
    if unit and type(S_ItemTip_UpdateFrame) == "function" then
      self.suppressProviderUpdateHook = true
      pcall(S_ItemTip_UpdateFrame, unit)
      self.suppressProviderUpdateHook = false
    end
  elseif active == "stats" and targetStats then
    self:AnchorInspectProviderRight(targetStats)
    targetStats:Show()
  elseif
    active == "compare" and
    targetStats and
    selfStats and
    self:InspectCompareSupported()
  then
    self:AnchorInspectProviderRight(targetStats)
    self:AnchorInspectSelfLeft(selfStats)
    targetStats:Show()
    selfStats:Show()
  else
    active = nil
  end

  self.inspectActive = true
  self.inspectVisible = true
  self.inspectActiveView = active
  self.inspectReason = active and "active" or "providers-missing"
  self:UpdateInspectRail()
  return true
end

function GearPlanner:HideCompanionViews()
  self:DiscoverCompanionProviders()
  SetShown(self.providers.current, false)
  SetShown(self.providers.stats, false)
  SetShown(self.frame, false)
  SetShown(self.profileManager, false)
end

function GearPlanner:OnCompanionContextHidden()
  if self.companionActive or self.companionVisible then
    self:HideCompanionViews()
  end
  if self.companionRail then self.companionRail:Hide() end
  self.providerRestores = {}
  self.companionVisible = false
  self.wideActive = false
end

function GearPlanner:OnPlanFrameHidden()
  if
    self.suppressPlanHide or
    not Enabled() or
    not self.companionMode or
    not self:CompanionContextVisible() or
    self.activeView ~= "plan"
  then
    return
  end
  if self:ViewAvailable("current") then
    addon.db.gearplanner.companionView = "current"
  elseif self:ViewAvailable("stats") then
    addon.db.gearplanner.companionView = "stats"
  else
    return
  end
  self:ScheduleCompanionSettle(1)
end

function GearPlanner:ReconcileCompanion()
  local supported, reason, active, wide
  local currentFrame, statsFrame
  self:InstallProviderHooks()
  self:DiscoverCompanionProviders()
  supported, reason = self:CharacterCompanionSupported()
  self.companionReason = reason

  if not Enabled() or not supported then
    if self.companionRail then self.companionRail:Hide() end
    if self.companionMode and self:CompanionContextVisible() then
      self:RestoreProviderStates(true)
      self:SetStandaloneLayout()
      self:UpdateAll()
    end
    self.companionActive = false
    self.companionVisible = false
    self.wideActive = false
    return false
  end

  if not self:CompanionContextVisible() then
    if self.companionRail then self.companionRail:Hide() end
    self.companionVisible = false
    self.wideActive = false
    return false
  end

  self:CreateCompanionRail()
  self:CreateFrame()
  self:SetCompanionLayout()
  currentFrame = self.providers.current
  statsFrame = self.providers.stats
  self:CaptureProviderState(currentFrame)
  self:CaptureProviderState(statsFrame)

  active = self:ResolveActiveView()
  self.activeView = active
  wide = addon.db.gearplanner.wideMode and
    self:WideLayoutSupported() and active ~= "stats" and active ~= "plan"

  SetShown(currentFrame, false)
  SetShown(statsFrame, false)
  self.suppressPlanHide = true
  self.frame:Hide()
  self.suppressPlanHide = false
  if active ~= "plan" then self:StopAtlasLootSelection(false) end

  if active == "current" and currentFrame then
    self:AnchorProviderRight(currentFrame)
    currentFrame:Show()
    if type(S_ItemTip_UpdateFrame) == "function" then
      pcall(S_ItemTip_UpdateFrame, "player")
    end
  elseif active == "stats" and statsFrame then
    self:AnchorProviderRight(statsFrame)
    statsFrame:Show()
  else
    self.activeView = "plan"
    self:EnsureIndex()
    self:UpdateAll()
    self.frame:Show()
  end

  if wide and statsFrame then
    self:AnchorStatsLeft(statsFrame)
    statsFrame:Show()
  end

  self.wideActive = wide and true or false
  self.companionActive = true
  self.companionVisible = true
  self.companionReason = "active"
  self:UpdateCompanionRail()
  return true
end

function GearPlanner:ShowCharacterPaperDoll()
  local ok
  if not CharacterFrame or not PaperDollFrame then return false end
  if type(ShowUIPanel) == "function" then
    ShowUIPanel(CharacterFrame)
  else
    CharacterFrame:Show()
  end
  if type(CharacterFrame_ShowSubFrame) == "function" then
    ok = pcall(CharacterFrame_ShowSubFrame, "PaperDollFrame")
    if not ok then PaperDollFrame:Show() end
  else
    PaperDollFrame:Show()
  end
  return true
end

function GearPlanner:SetActiveView(view, refreshProvider)
  local selectedDefinition, index, definition
  for index = 1, table.getn(COMPANION_VIEWS) do
    definition = COMPANION_VIEWS[index]
    if definition.key == view then selectedDefinition = definition end
  end
  if not selectedDefinition then return false, "未知伴随视图。" end

  addon.db.gearplanner.companionView = view
  if
    refreshProvider and
    view == "stats" and
    type(SCPaperDollFrame_OnShow) == "function"
  then
    pcall(SCPaperDollFrame_OnShow)
  end
  if self:CompanionContextVisible() then
    self:ReconcileCompanion()
  else
    self:ScheduleCompanionSettle(2)
  end
  return true, "已切换到“" .. tostring(selectedDefinition.title) .. "”。"
end

function GearPlanner:SetWideMode(enabled)
  if enabled and not self:WideLayoutSupported() then
    return false, "当前有效宽度或 StatCompare Provider 不支持双栏。"
  end
  addon.db.gearplanner.wideMode = enabled and true or false
  if enabled and addon.db.gearplanner.companionView == "stats" then
    if self:ViewAvailable("current") then
      addon.db.gearplanner.companionView = "current"
    else
      addon.db.gearplanner.companionView = "plan"
    end
  end
  if self:CompanionContextVisible() then self:ReconcileCompanion() end
  return true, "双栏模式已" .. (enabled and "启用。" or "关闭。")
end

function GearPlanner:ToggleWideMode()
  return self:SetWideMode(not addon.db.gearplanner.wideMode)
end

function GearPlanner:OpenStandalone(reason)
  if self.companionRail then self.companionRail:Hide() end
  if self:CompanionContextVisible() then self:RestoreProviderStates(true) end
  self:CreateFrame()
  self:SetStandaloneLayout()
  self:EnsureIndex()
  self:UpdateAll()
  self.frame:Show()
  self.activeView = "plan"
  self.companionActive = false
  self.companionVisible = false
  self.companionReason = "standalone-" .. tostring(reason or "requested")
  return true, "角色伴随栏不可用，已打开独立配装窗口。"
end

function GearPlanner:OpenView(view)
  local supported, reason, title, requestedTitle
  if not Enabled() then return false, "配装工具已禁用。" end
  title = CompanionViewTitle(view)
  if not title then return false, "未知伴随视图。" end
  requestedTitle = title
  supported, reason = self:CharacterCompanionSupported()
  if not supported then
    if view == "plan" then return self:OpenStandalone(reason) end
    return false, "角色伴随栏不可用：" .. tostring(reason) .. "。"
  end

  addon.db.gearplanner.companionView = view
  self:CreateCompanionControllers()
  self:CreateCompanionRail()
  self:CreateFrame()
  if not self:ShowCharacterPaperDoll() then
    if view == "plan" then return self:OpenStandalone("open-failed") end
    return false, "角色页面无法打开。"
  end
  if not self:ViewAvailable(view) then
    view = self:ResolveActiveView()
    addon.db.gearplanner.companionView = view
    title = CompanionViewTitle(view) or "配装方案"
  end
  if view == "stats" and type(SCPaperDollFrame_OnShow) == "function" then
    pcall(SCPaperDollFrame_OnShow)
  end
  self:ScheduleCompanionSettle(2)
  if title ~= requestedTitle then
    return true, "“" .. tostring(requestedTitle) ..
      "” Provider 不可用，已改为“" .. tostring(title) .. "”。"
  end
  return true, "角色页已打开，伴随视图为“" .. tostring(title) .. "”。"
end

function GearPlanner:CloseActiveView()
  if self.companionMode and self:CompanionContextVisible() then
    if self:ViewAvailable("current") then
      self:SetActiveView("current", true)
    elseif self:ViewAvailable("stats") then
      self:SetActiveView("stats", true)
    elseif type(HideUIPanel) == "function" then
      HideUIPanel(CharacterFrame)
    else
      CharacterFrame:Hide()
    end
    return
  end
  if self.profileManager then self.profileManager:Hide() end
  if self.frame then self.frame:Hide() end
end

function GearPlanner:Open()
  return self:OpenView("plan")
end

function GearPlanner:Toggle()
  if not Enabled() then return false, "配装工具已禁用。" end
  if
    self.companionMode and
    self:CompanionContextVisible() and
    self.activeView == "plan" and
    FrameVisible(self.frame)
  then
    if type(HideUIPanel) == "function" then
      HideUIPanel(CharacterFrame)
    else
      CharacterFrame:Hide()
    end
    return true, "角色页与配装伴随栏已隐藏。"
  end
  if self.frame and not self.companionMode and FrameVisible(self.frame) then
    self.frame:Hide()
    return true, "配装工具已隐藏。"
  end
  return self:Open()
end

function GearPlanner:SetEnabled(enabled)
  addon.db.gearplanner.enabled = enabled and true or false
  if not enabled then
    if self.settleFrame then self.settleFrame:SetScript("OnUpdate", nil) end
    if self.inspectSettleFrame then
      self.inspectSettleFrame:SetScript("OnUpdate", nil)
    end
    self.settlePasses = 0
    self.inspectSettlePasses = 0
    self:RestoreProviderStates(self:CompanionContextVisible())
    self:RestoreInspectProviderStates(self:InspectContextVisible())
    self:StopAtlasLootSelection(false)
    if self.companionRail then self.companionRail:Hide() end
    if self.inspectRail then self.inspectRail:Hide() end
    if self.profileManager then self.profileManager:Hide() end
    if self.frame then self.frame:Hide() end
    if self.companionMode then self:SetStandaloneLayout() end
    self.companionActive = false
    self.companionVisible = false
    self.wideActive = false
    self.companionReason = "disabled"
    self.inspectActive = false
    self.inspectVisible = false
    self.inspectActiveView = nil
    self.inspectReason = "disabled"
  else
    self:CreateCompanionControllers()
    self:CreateInspectControllers()
    self:InstallProviderHooks()
    if self:CompanionContextVisible() then
      self:ScheduleCompanionSettle(2)
    end
    if self:InspectContextVisible() then
      self:ScheduleInspectSettle(2)
    end
  end
  return true, "配装工具已" .. (enabled and "启用。" or "禁用。")
end

function GearPlanner:GetRuntimeStatus()
  local supported, reason = self:CharacterCompanionSupported()
  local inspectSupported, inspectReason = self:InspectCompanionSupported()
  local store = self:GetStore()
  self:DiscoverCompanionProviders()
  self:DiscoverInspectProviders()
  return "runtime=" .. self.runtimeContract .. ", enabled=" .. tostring(Enabled()) ..
    ", mode=" .. tostring(self.companionMode and "companion" or "standalone") ..
    ", active=" .. tostring(self.activeView or "none") ..
    ", requested=" ..
    tostring(addon.db.gearplanner.companionView or "current") ..
    ", wide=" .. tostring(self.wideActive and "active" or
      (addon.db.gearplanner.wideMode and "requested" or "off")) ..
    ", character=" .. tostring(supported and "ready" or reason) ..
    ", providers=current:" ..
    tostring(self.providers.current and "ready" or "missing") ..
    "/stats:" .. tostring(self.providers.stats and "ready" or "missing") ..
    ", inspect=" .. tostring(self.inspectVisible and
      (self.inspectActiveView or "rail") or
      (inspectSupported and "ready" or inspectReason)) ..
    ", inspectProviders=gear:" ..
    tostring(self.inspectProviders.gear and "ready" or "missing") ..
    "/target:" ..
    tostring(self.inspectProviders.targetStats and "ready" or "missing") ..
    "/self:" ..
    tostring(self.inspectProviders.selfStats and "ready" or "missing") ..
    ", atlas=" .. tostring(self.atlasReady and "就绪" or "缺失") ..
    ", items=" .. tostring(self.itemCount or 0) ..
    ", profiles=" .. tostring(table.getn(store.profiles)) ..
    ", picker=native-atlasloot" ..
    ", selecting=" .. tostring(self.atlasSelectionActive and
      (self.atlasSelectionLabel or "active") or "off") ..
    ", stats=" ..
    tostring((BonusScanner and BonusScanner.ScanItem) and "BonusScanner" or "缺失") ..
    ", weapon=" ..
    tostring(type(GetItemStats) == "function" and "Nampower+Tooltip" or "Tooltip")
end

function GearPlanner:Initialize()
  local db = addon.db.gearplanner
  if (tonumber(db.schemaVersion) or 0) < 2 then
    db.companionView = db.companionView or "current"
    db.wideMode = db.wideMode and true or false
    db.schemaVersion = 2
  end
  if (tonumber(db.schemaVersion) or 0) < 3 then
    db.inspectView = db.inspectView or "gear"
    db.schemaVersion = 3
  end
  if (tonumber(db.schemaVersion) or 0) < 5 then db.schemaVersion = 5 end
  self.index = {}
  self.byID = {}
  self.statCache = {}
  self.weaponCache = {}
  self.weaponTooltip = nil
  self.indexBuilt = false
  self.atlasLocale = nil
  self.atlasLocaleResolved = false
  self.atlasReady = false
  self.itemCount = 0
  self.recordCount = 0
  self.profilePage = 1
  self.profileSelection = nil
  self.atlasSelectionActive = false
  self.atlasSelectionLabel = nil
  self.atlasLootItemsHooked = false
  self.planPane = "combined"
  self.providers = {}
  self.providerRestores = {}
  self.inspectProviders = {}
  self.inspectProviderRestores = {}
  self.companionActive = false
  self.companionVisible = false
  self.companionMode = false
  self.wideActive = false
  self.companionReason = "initialized"
  self.inspectActive = false
  self.inspectVisible = false
  self.inspectActiveView = nil
  self.inspectSessionKey = nil
  self.inspectDataReady = false
  self.inspectReason = "initialized"
  self:CreateCompanionControllers()
  self:CreateInspectControllers()
  self:InstallProviderHooks()
end

function GearPlanner:Apply()
  self:CreateCompanionControllers()
  self:CreateInspectControllers()
  self:InstallProviderHooks()
  if not Enabled() then
    self:RestoreProviderStates(self:CompanionContextVisible())
    self:RestoreInspectProviderStates(self:InspectContextVisible())
    self:StopAtlasLootSelection(false)
    if self.companionRail then self.companionRail:Hide() end
    if self.inspectRail then self.inspectRail:Hide() end
    if self.profileManager then self.profileManager:Hide() end
    if self.frame then self.frame:Hide() end
    self.companionActive = false
    self.companionVisible = false
    self.wideActive = false
    self.companionReason = "disabled"
    self.inspectActive = false
    self.inspectVisible = false
    self.inspectActiveView = nil
    self.inspectReason = "disabled"
    return
  end
  if self:CompanionContextVisible() then
    self:ScheduleCompanionSettle(2)
  elseif self.companionRail then
    self.companionRail:Hide()
  end
  if self:InspectContextVisible() then
    self:ScheduleInspectSettle(2)
  elseif self.inspectRail then
    self.inspectRail:Hide()
  end
end

addon:RegisterModule("GearPlanner", GearPlanner)
