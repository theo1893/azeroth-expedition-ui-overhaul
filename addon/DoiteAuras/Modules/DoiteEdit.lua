---------------------------------------------------------------
-- DoiteEdit.lua
-- 用于编辑光环条件的辅助框架 / 编辑界面
-- 请尊重许可说明：使用前请询问
-- WoW 1.12 | Lua 5.0
---------------------------------------------------------------

if DoiteConditionsFrame then
  DoiteConditionsFrame:Hide()
  DoiteConditionsFrame = nil
end

local condFrame = nil
local currentKey = nil
local EnsureDBEntry
local ClearDropdown
local SafeRefresh
local SafeEvaluate
local srows
local ShowSeparatorsForType
local SetSeparator
local SetGroupMode
local DEFAULT_CUSTOM_FUNCTION_SOURCE
local _ReflowCondAreaHeight

-- 图标级分类界面辅助工具（稍后在 CreateConditionsUI 中赋值）
local AuraCond_Managers = {}
local AuraCond_RegisterManager
local AuraCond_RefreshFromDB
local AuraCond_ResetEditing

local VfxCond_Managers = {}
local VfxCond_RegisterManager
local VfxCond_RefreshFromDB
local VfxCond_ResetEditing

local function _ParseFadeAlphaFromBox(box)
  local pct = tonumber(box and box:GetText())
  if not pct then
    return 0
  end
  if pct < 0 then pct = 0 end
  if pct > 100 then pct = 100 end
  return pct / 100
end

local function _NormalizeFadeBox(box, alpha)
  if not box then return end
  local pct = math.floor(((alpha or 0) * 100) + 0.5)
  if pct < 0 then pct = 0 end
  if pct > 100 then pct = 100 end
  box:SetText(tostring(pct))
end

local SOUND_FILES = {
  "JDO - Dont move, Shackles.ogg", "JDO - Loot banned.ogg", "Trend - Uwu.ogg", "Custom - Poison ammo.ogg", "Custom - Arcane ammo.ogg", "Custom - Explosive ammo.ogg", "Custom - Lock n Load.ogg",
  "MPOWA - Aggro.ogg", "MPOWA - Arrow Swoosh.ogg", "MPOWA - Bam.ogg", "MPOWA - Bigkiss.ogg", "MPOWA - Bite.ogg", "MPOWA - Burp.ogg", "MPOWA - Cat.ogg", "MPOWA - Chant (1).ogg", "MPOWA - Chant (2).ogg", "MPOWA - Chimes.ogg", "MPOWA - Cookie.ogg", "MPOWA - ESpark.ogg", "MPOWA - Fireball.ogg", "MPOWA - Gasp.ogg",
  "MPOWA - Heartbeat.ogg", "MPOWA - Hic.ogg", "MPOWA - Hit (1).ogg", "MPOWA - Hit (2).ogg", "MPOWA - Hit (3).ogg", "MPOWA - Hit (4).ogg", "MPOWA - Hit (5).ogg", "MPOWA - Hit (6).ogg", "MPOWA - Hit (7).ogg", "MPOWA - Hit (8).ogg",
  "MPOWA - Huh.ogg", "MPOWA - Hurricane.ogg", "MPOWA - Hyena.ogg", "MPOWA - Kaching.ogg", "MPOWA - Moan.ogg", "MPOWA - Panther.ogg", "MPOWA - Polarbear.ogg", "MPOWA - Punch.ogg", "MPOWA - Phone.ogg",
  "MPOWA - Rainroof.ogg", "MPOWA - Rocket.ogg", "MPOWA - Shipswhistle.ogg", "MPOWA - Shot.ogg", "MPOWA - Snakeatt.ogg", "MPOWA - Sneeze.ogg", "MPOWA - Sonar.ogg",
  "MPOWA - Splash.ogg", "MPOWA - Squeakypig.ogg", "MPOWA - Swordecho.ogg", "MPOWA - Throwknife.ogg", "MPOWA - Thunder.ogg", "MPOWA - Wilhelm.ogg", "MPOWA - Wickedlaugh (1).ogg",
  "MPOWA - Wickedlaugh (2).ogg", "MPOWA - Wolf.ogg", "MPOWA - Yeehaw.ogg"
}

local function DoiteEdit_SetDropdownInteractive(dd, enabled)
  if not dd then
    return
  end

  local name = dd.GetName and dd:GetName()
  local btn = name and _G[name .. "Button"] or nil

  if enabled then
    if UIDropDownMenu_EnableDropDown then
      pcall(UIDropDownMenu_EnableDropDown, dd)
    end

    if btn and btn.Enable then
      btn:Enable()
    end

    if name then
      local t = _G[name .. "Text"]
      if t and t.SetTextColor then
        t:SetTextColor(1, 1, 1)
      end
    end
  else
    if UIDropDownMenu_DisableDropDown then
      pcall(UIDropDownMenu_DisableDropDown, dd)
    end

    if btn and btn.Disable then
      btn:Disable()
    end

    if name then
      local t = _G[name .. "Text"]
      if t and t.SetTextColor then
        t:SetTextColor(0.6, 0.6, 0.6)
      end
    end
  end
end

local function DoiteEdit_HookDropDownButtonOnClick(dd, fn)
  if not dd or not fn or not dd.GetName then
    return
  end

  local name = dd:GetName()
  if not name then
    return
  end

  local btn = _G[name .. "Button"]
  if not btn or btn._doiteRefreshHooked then
    return
  end
  btn._doiteRefreshHooked = true

  local prev = btn.GetScript and btn:GetScript("OnClick")
  btn:SetScript("OnClick", function()
    fn()
    if prev then
      prev()
    end
  end)
end

local function DoiteEdit_SetSoundFromDropdown(typeKey, eventKey, value)
  if not currentKey then
    return
  end
  local d = EnsureDBEntry(currentKey)
  d.conditions = d.conditions or {}
  d.conditions[typeKey] = d.conditions[typeKey] or {}
  d.conditions[typeKey][eventKey] = value
  SafeRefresh();
  SafeEvaluate()
end

local function DoiteEdit_SetSoundEnabled(typeKey, enabledKey, enabled)
  if not currentKey then
    return
  end
  local d = EnsureDBEntry(currentKey)
  d.conditions = d.conditions or {}
  d.conditions[typeKey] = d.conditions[typeKey] or {}
  d.conditions[typeKey][enabledKey] = enabled and true or false
  SafeRefresh();
  SafeEvaluate()
end

local function DoiteEdit_InitSoundDropdown(dd, typeKey, eventKey, selectedValue)
  if not dd then
    return
  end

  -- 在下拉框本身上保留选择，以便分页正确
  dd._selectedSound = (selectedValue and selectedValue ~= "") and selectedValue or ""
  dd._soundPage = dd._soundPage or 1

  ClearDropdown(dd)

  local total = table.getn(SOUND_FILES)
  local perPage = 20  -- 保持在 UIDropDownMenu 按钮上限之下
  local maxPage = 1
  if total > 0 then
    maxPage = math.ceil(total / perPage)
  end
  if dd._soundPage < 1 then dd._soundPage = 1 end
  if dd._soundPage > maxPage then dd._soundPage = maxPage end

  local function ReopenNextFrame()
    local f = dd._reopenFrame
    if not f then
      f = CreateFrame("Frame", nil, UIParent)
      dd._reopenFrame = f
      f:Hide()
      f:SetScript("OnUpdate", function()
        f:Hide()
        ToggleDropDownMenu(nil, nil, dd, dd, 0, 0)
      end)
    end
    f:Show()
  end

  UIDropDownMenu_Initialize(dd, function(frame, level, menuList)
    level = level or 1
    local page = dd._soundPage or 1

    -- 上一页
    if page > 1 then
      local infoPrev = UIDropDownMenu_CreateInfo()
      infoPrev.text = "|cffffd000<< 上一页|r"
      infoPrev.notCheckable = true
      infoPrev.func = function()
        dd._soundPage = page - 1
        if CloseDropDownMenus then CloseDropDownMenus() end
        ReopenNextFrame()
      end
      UIDropDownMenu_AddButton(infoPrev, level)
    end

    -- 当前页条目
    local startIndex = (page - 1) * perPage + 1
    local endIndex = math.min(startIndex + perPage - 1, total)

    local i = startIndex
    while i <= endIndex do
      local fname = SOUND_FILES[i]
      local info2 = UIDropDownMenu_CreateInfo()
      info2.text = fname
      info2.value = fname
      info2.checked = (dd._selectedSound == fname)
      info2.func = function(button)
        local picked = (button and button.value) or fname
        dd._selectedSound = picked
        UIDropDownMenu_SetSelectedValue(dd, picked)
        UIDropDownMenu_SetText(picked, dd)
        DoiteEdit_SetSoundFromDropdown(typeKey, eventKey, picked)
        if PlaySoundFile and picked and picked ~= "" then
          pcall(PlaySoundFile, "Interface\\AddOns\\DoiteAuras\\Sounds\\" .. picked)
        end
        if CloseDropDownMenus then CloseDropDownMenus() end
      end
      UIDropDownMenu_AddButton(info2, level)
      i = i + 1
    end

    -- 下一页
    if page < maxPage then
      local infoNext = UIDropDownMenu_CreateInfo()
      infoNext.text = "|cffffd000下一页 >>|r"
      infoNext.notCheckable = true
      infoNext.func = function()
        dd._soundPage = page + 1
        if CloseDropDownMenus then CloseDropDownMenus() end
        ReopenNextFrame()
      end
      UIDropDownMenu_AddButton(infoNext, level)
    end
  end)

  -- 恢复可见文本
  if dd._selectedSound ~= "" then
    UIDropDownMenu_SetSelectedValue(dd, dd._selectedSound)
    UIDropDownMenu_SetText(dd._selectedSound, dd)
  else
    UIDropDownMenu_SetSelectedValue(dd, "")
    UIDropDownMenu_SetText("选择音效", dd)
  end

  if _GoldifyDD then
    _GoldifyDD(dd)
  end
end

-- UpdateConditionsUI 和其他地方使用的职业门控函数
local function _IsRogueOrDruid()
  local _, c = UnitClass("player")
  c = c and string.upper(c) or ""
  return (c == "ROGUE" or c == "DRUID")
end

local function _IsHunterOrWarlock()
  local _, c = UnitClass("player")
  c = c and string.upper(c) or ""
  return (c == "HUNTER" or c == "WARLOCK")
end

local function DoiteEdit_AbilitySupportsProcSound(data)
  if not data then
    return false
  end
  local spellName = data.name
  if not spellName or spellName == "" then
    spellName = data.displayName
  end
  if not spellName or spellName == "" then
    return false
  end
  local tbl = _G.DoiteConditions_ProcWindowDurations
  local dur = tbl and tbl[spellName]
  return (type(dur) == "number" and dur > 0) and true or false
end

local function DoiteEdit_YellowifyButton(btn)
  if not btn then
    return
  end
  if btn.SetNormalFontObject then
    btn:SetNormalFontObject("GameFontNormalSmall")
  end
  local fs = btn:GetFontString()
  if fs and fs.SetTextColor then
    fs:SetTextColor(1, 0.82, 0)
  end
end

local function DoiteEdit_EnableCheck(cb)
  if not cb then
    return
  end
  cb:Enable()
  if cb.text and cb.text.SetTextColor then
    cb.text:SetTextColor(1, 0.82, 0)
  end
end

local function DoiteEdit_DisableCheck(cb)
  if not cb then
    return
  end
  cb:Disable()
  if cb.text and cb.text.SetTextColor then
    cb.text:SetTextColor(0.6, 0.6, 0.6)
  end
end

local function DoiteEdit_AddGroupModeOption(typeKey, text, value)
  local info = UIDropDownMenu_CreateInfo()
  info.text = text
  info.value = value
  info.func = function(button)
    local v = (button and button.value) or value
    if v == "__default" then
      SetGroupMode(typeKey, nil)
    else
      SetGroupMode(typeKey, v)
    end
  end
  UIDropDownMenu_AddButton(info)
end

-- === 轻量级限流器，防止拖拽滑块时卡顿 ===
local _DoiteEdit_PendingHeavy = false
local _DoiteEdit_Accum = 0
local _DoiteEdit_Throttle = CreateFrame("Frame", "DoiteEditThrottle")

-- 主编辑框或主框被拖拽时置为 true
_G["DoiteUI_Dragging"] = _G["DoiteUI_Dragging"] or false

---------------------------------------------------------------
-- 图标定位网格覆盖层（重新实现）
---------------------------------------------------------------
local _DoiteGridFrame = nil
local _DoiteGridLines = {}

-- 创建网格覆盖层
local function _CreateGridFrame()
  if _DoiteGridFrame then
    return _DoiteGridFrame
  end

  local grid = CreateFrame("Frame", "DoiteGridOverlay", UIParent)
  grid:SetAllPoints(UIParent)
  grid:SetFrameStrata("BACKGROUND") -- 图标后方
  grid:SetFrameLevel(1)
  grid:EnableMouse(false)  -- 不捕获点击

  -- 半透明背景便于对比
  local bg = grid:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints(grid)
  bg:SetTexture(0, 0, 0, 0.7)

  grid:Hide()

  -- 绘制网格线（基于屏幕中心）
  local function DrawGrid()
    -- 清除现有线条
    for _, line in ipairs(_DoiteGridLines) do
      line:Hide()
    end

    local gridSize = 20
    -- 使用超大尺寸保证任何缩放比例都能覆盖全屏
    local w, h = UIParent:GetWidth() * 2, UIParent:GetHeight() * 2
    local limitW, limitH = (UIParent:GetWidth() / 2) * 1.5, (UIParent:GetHeight() / 2) * 1.5
    local lineIdx = 0

    -- 辅助函数：获取/创建线条
    local function GetLine()
        lineIdx = lineIdx + 1
        local line = _DoiteGridLines[lineIdx]
        if not line then
            line = grid:CreateTexture(nil, "OVERLAY")
            _DoiteGridLines[lineIdx] = line
        end
        return line
    end

    -- 1. 中心十字线（高亮，固定在0,0）
    local v = GetLine()
    v:SetTexture(1, 0, 0, 0.5) -- 红色垂直线
    v:SetWidth(2)
    v:SetHeight(h)
    v:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    v:Show()

    local hz = GetLine()
    hz:SetTexture(1, 0, 0, 0.5) -- 红色水平线
    hz:SetHeight(2)
    hz:SetWidth(w)
    hz:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    hz:Show()

    -- 2. 网格线（淡色，从中心向外延伸）
    -- 右侧垂直线 (+)
    local x = gridSize
    while x < limitW do
      local l = GetLine()
      l:SetTexture(1, 1, 1, 0.15)
      l:SetWidth(1)
      l:SetHeight(h)
      l:SetPoint("CENTER", UIParent, "CENTER", x, 0)
      l:Show()
      x = x + gridSize
    end
    -- 左侧垂直线 (-)
    x = -gridSize
    while x > -limitW do
      local l = GetLine()
      l:SetTexture(1, 1, 1, 0.15)
      l:SetWidth(1)
      l:SetHeight(h)
      l:SetPoint("CENTER", UIParent, "CENTER", x, 0)
      l:Show()
      x = x - gridSize
    end

    -- 上方水平线 (+)
    local y = gridSize
    while y < limitH do
      local l = GetLine()
      l:SetTexture(1, 1, 1, 0.15)
      l:SetWidth(w)
      l:SetHeight(1)
      l:SetPoint("CENTER", UIParent, "CENTER", 0, y)
      l:Show()
      y = y + gridSize
    end
    -- 下方水平线 (-)
    y = -gridSize
    while y > -limitH do
      local l = GetLine()
      l:SetTexture(1, 1, 1, 0.15)
      l:SetWidth(w)
      l:SetHeight(1)
      l:SetPoint("CENTER", UIParent, "CENTER", 0, y)
      l:Show()
      y = y - gridSize
    end

    -- 中心标签
    if not grid.label then
      grid.label = grid:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
      grid.label:SetPoint("TOP", UIParent, "CENTER", 0, -20)
      grid.label:SetTextColor(1, 1, 0)
      grid.label:SetText("中心 (0,0)")
    end
  end

  grid.DrawGrid = DrawGrid
  _DoiteGridFrame = grid
  return grid
end

-- 切换网格显示
function DoiteEdit_ToggleGrid()
  local grid = _CreateGridFrame()
  if grid:IsShown() then
    grid:Hide()
  else
    grid.DrawGrid()
    grid:Show()
  end
  return grid:IsShown()
end
_G["DoiteEdit_ToggleGrid"] = DoiteEdit_ToggleGrid

-- 检查网格是否显示
function DoiteEdit_IsGridShown()
  return _DoiteGridFrame and _DoiteGridFrame:IsShown()
end
_G["DoiteEdit_IsGridShown"] = DoiteEdit_IsGridShown



-- 内部立即执行的重度操作辅助函数（仅由限流器调用，从不直接从 UI 调用）
local function _DoiteEdit_ImmediateRefresh()
  if DoiteAuras_RefreshList then
    DoiteAuras_RefreshList()
  end
  if DoiteAuras_RefreshIcons then
    DoiteAuras_RefreshIcons()
  end
end

local function _DoiteEdit_ImmediateEvaluate()
  if DoiteConditions_RequestEvaluate then
    DoiteConditions_RequestEvaluate()
  elseif DoiteConditions and DoiteConditions.EvaluateAll then
    DoiteConditions:EvaluateAll()
  end
end

local function DoiteEdit_QueueHeavy()
  _DoiteEdit_PendingHeavy = true
end

local function DoiteEdit_FlushHeavy()
  if not _DoiteEdit_PendingHeavy then
    return
  end
  _DoiteEdit_PendingHeavy = false
  _DoiteEdit_Accum = 0

  -- 一次性组合重度操作，在限流器后批处理
  _DoiteEdit_ImmediateRefresh()
  _DoiteEdit_ImmediateEvaluate()
end

-- 全局暴露，拖拽处理器可以调用
_G["DoiteEdit_FlushHeavy"] = DoiteEdit_FlushHeavy

-- 图标拖拽后同步滑块到新位置
function DoiteEdit_SyncSlidersToPosition(key, x, y)
  if condFrame and currentKey == key then
    if condFrame.sliderX then
      condFrame.sliderX._isSyncing = true
      condFrame.sliderX:SetValue(x)
      condFrame.sliderX._isSyncing = false
    end
    if condFrame.sliderY then
      condFrame.sliderY._isSyncing = true
      condFrame.sliderY:SetValue(y)
      condFrame.sliderY._isSyncing = false
    end
    if condFrame.sliderXBox then
      condFrame.sliderXBox:SetText(tostring(math.floor(x + 0.5)))
    end
    if condFrame.sliderYBox then
      condFrame.sliderYBox:SetText(tostring(math.floor(y + 0.5)))
    end
  end
end
_G["DoiteEdit_SyncSlidersToPosition"] = DoiteEdit_SyncSlidersToPosition

_DoiteEdit_Throttle:SetScript("OnUpdate", function()
  if not _DoiteEdit_PendingHeavy then
    return
  end
  if _G["DoiteUI_Dragging"] then
    return
  end  -- 用户拖拽时延迟处理
  _DoiteEdit_Accum = _DoiteEdit_Accum + (arg1 or 0)
  if _DoiteEdit_Accum >= 0.05 then
    -- 滑块拖拽时约20fps限流
    DoiteEdit_FlushHeavy()
  end
end)

EnsureDBEntry = function(key)
  -- 确保全局分类表存在（所有图标共享）
  if DoiteAurasDB and not DoiteAurasDB.categories then
    DoiteAurasDB.categories = {}
  end

  if not DoiteAurasDB.spells[key] then
    DoiteAurasDB.spells[key] = {
      order = 999,
      type = "Ability",
      displayName = key,
      growth = "水平向右",
      numAuras = 5,
      offsetX = 0,
      offsetY = 0,
      iconSize = 40,
      conditions = {}
    }
  end

  local d = DoiteAurasDB.spells[key]

  -- 常规默认值（不覆盖已有值）
  if not d.growth then
    d.growth = "水平向右"
  end
  if not d.numAuras then
    d.numAuras = 5
  end
  if not d.offsetX then
    d.offsetX = 0
  end
  if not d.offsetY then
    d.offsetY = 0
  end
  if not d.iconSize then
    d.iconSize = 40
  end
  if not d.conditions then
    d.conditions = {}
  end

  -- 只为此条目类型创建正确的子表，并清除其他类型
  if d.type == "Ability" then
    -- 保留ability，移除aura/item
    d.conditions.ability = d.conditions.ability or {}
    d.conditions.aura = nil
    d.conditions.item = nil
    -- 动态光环条件（额外的Buff/Debuff检查）
    if not d.conditions.ability.auraConditions then
      d.conditions.ability.auraConditions = {}
    end

    -- 默认值（ability）
    if d.conditions.ability.mode == nil then
      d.conditions.ability.mode = "notcd"
    end
    if d.conditions.ability.inCombat == nil then
      d.conditions.ability.inCombat = true
    end
    if d.conditions.ability.outCombat == nil then
      d.conditions.ability.outCombat = true
    end
    if d.conditions.ability.targetHelp == nil then
      d.conditions.ability.targetHelp = false
    end
    if d.conditions.ability.targetHarm == nil then
      d.conditions.ability.targetHarm = false
    end
    if d.conditions.ability.targetSelf == nil then
      d.conditions.ability.targetSelf = false
    end
    if d.conditions.ability.form == nil then
      d.conditions.ability.form = "所有形态"
    end

    if d.conditions.ability.targetDistance == nil then
      d.conditions.ability.targetDistance = nil
    end
    if d.conditions.ability.targetUnitType == nil then
      d.conditions.ability.targetUnitType = nil
    end
    if d.conditions.ability.weaponFilter == nil then
      d.conditions.ability.weaponFilter = nil
    end

    -- 清理遗留字段
    d.conditions.ability.target = nil

  elseif d.type == "Item" then
    -- 保留item，移除ability/aura
    d.conditions.item = d.conditions.item or {}
    d.conditions.ability = nil
    d.conditions.aura = nil

    -- 默认值（item）
    local ic = d.conditions.item

    -- 动态光环条件（额外的Buff/Debuff检查）
    if not ic.auraConditions then
      ic.auraConditions = {}
    end

    if ic.whereEquipped == nil then
      ic.whereEquipped = true
    end
    if ic.whereBag == nil then
      ic.whereBag = true
    end
    if ic.whereMissing == nil then
      ic.whereMissing = false
    end

    if ic.mode == nil then
      ic.mode = "notcd"
    end
    if ic.inCombat == nil then
      ic.inCombat = true
    end
    if ic.outCombat == nil then
      ic.outCombat = true
    end
    if ic.targetHelp == nil then
      ic.targetHelp = false
    end
    if ic.targetHarm == nil then
      ic.targetHarm = false
    end
    if ic.targetSelf == nil then
      ic.targetSelf = false
    end
    if ic.form == nil then
      ic.form = "所有形态"
    end

    if ic.targetDistance == nil then
      ic.targetDistance = nil
    end
    if ic.targetUnitType == nil then
      ic.targetUnitType = nil
    end
    if ic.weaponFilter == nil then
      ic.weaponFilter = nil
    end

  elseif d.type == "Custom" then
    -- 自定义代码控制可见性/纹理/覆盖层，不保留标准条件子树
    d.conditions.ability = nil
    d.conditions.aura = nil
    d.conditions.item = nil

    if type(d.customFunctionSource) ~= "string" or d.customFunctionSource == "" then
      d.customFunctionSource = DEFAULT_CUSTOM_FUNCTION_SOURCE
    end

  else
    -- Buff / Debuff（将非"Ability"/"Item"视为光环载体）
    -- 保留aura，移除ability/item
    d.conditions.aura = d.conditions.aura or {}
    d.conditions.ability = nil
    d.conditions.item = nil
    -- 动态光环条件（额外的Buff/Debuff检查）
    if not d.conditions.aura.auraConditions then
      d.conditions.aura.auraConditions = {}
    end


    -- 默认值（aura）
    if d.conditions.aura.mode == nil then
      d.conditions.aura.mode = "found"
    end
    if d.conditions.aura.inCombat == nil then
      d.conditions.aura.inCombat = true
    end
    if d.conditions.aura.outCombat == nil then
      d.conditions.aura.outCombat = true
    end
    if d.conditions.aura.targetSelf == nil then
      d.conditions.aura.targetSelf = true
    end
    if d.conditions.aura.targetHelp == nil then
      d.conditions.aura.targetHelp = false
    end
    if d.conditions.aura.targetHarm == nil then
      d.conditions.aura.targetHarm = false
    end
    if d.conditions.aura.form == nil then
      d.conditions.aura.form = "所有形态"
    end

    if d.conditions.aura.targetDistance == nil then
      d.conditions.aura.targetDistance = nil
    end
    if d.conditions.aura.targetUnitType == nil then
      d.conditions.aura.targetUnitType = nil
    end
    if d.conditions.aura.weaponFilter == nil then
      d.conditions.aura.weaponFilter = nil
    end

    if d.conditions.aura.trackpet == nil then
      d.conditions.aura.trackpet = false
    end

    -- 清理遗留字段
    d.conditions.aura.target = nil
    d.conditions.aura.targetTarget = nil
  end

  return d
end

-- 清空下拉框以便安全地重新初始化
ClearDropdown = function(dd)
  if not dd then
    return
  end
  if UIDropDownMenu_Initialize then
    pcall(UIDropDownMenu_Initialize, dd, function()
    end)
  end
  if UIDropDownMenu_ClearAll then
    pcall(UIDropDownMenu_ClearAll, dd)
  end
  dd._initializedForKey = nil
  dd._initializedForType = nil
end

SafeEvaluate = function()
  DoiteEdit_QueueHeavy()
end

SafeRefresh = function()
  DoiteEdit_QueueHeavy()
end

-- === 根据 UIParent 动态调整位置和尺寸滑块的范围 ===
local function _DA_GetParentDims()
  local uw, uh = UIParent:GetWidth(), UIParent:GetHeight()
  local sw, sh = GetScreenWidth(), GetScreenHeight()
  if sw > uw then uw = sw end
  if sh > uh then uh = sh end
  return uw, uh
end

-- X/Y是相对于屏幕中心的偏移，因此范围大致为±父框一半大小（略微留边）
-- 尺寸最大值随屏幕较小边缩放，以便高分辨率可使用更大的图标。
local function _DA_ComputePosSizeRanges()
  local w, h = _DA_GetParentDims()
  w = math.floor(w + 0.5)
  h = math.floor(h + 0.5)

  local halfW = math.floor(w * 0.5)
  local halfH = math.floor(h * 0.5)

  -- 基于中心的范围（-Half 到 +Half）
  local minX, maxX = -halfW, halfW
  local minY, maxY = -halfH, halfH

  local minSize = 10
  -- 最大图标尺寸约为较短边的20%，但不低于100，使小分辨率表现如旧
  local maxSize = math.max(100, math.floor(math.min(w, h) * 0.20 + 0.5))

  return minX, maxX, minY, maxY, minSize, maxSize
end

-- 应用到现有滑块，若当前DB值超出范围则钳位
local function _DA_ApplySliderRanges()
  if not condFrame or not condFrame.sliderX or not condFrame.sliderY or not condFrame.sliderSize then
    return
  end

  local minX, maxX, minY, maxY, minSize, maxSize = _DA_ComputePosSizeRanges()

  -- X滑块
  condFrame.sliderX:SetMinMaxValues(minX, maxX)
  local lowX = _G[condFrame.sliderX:GetName() .. "Low"]
  local highX = _G[condFrame.sliderX:GetName() .. "High"]
  if lowX then
    lowX:SetText(tostring(minX))
  end
  if highX then
    highX:SetText(tostring(maxX))
  end

  -- Y滑块
  condFrame.sliderY:SetMinMaxValues(minY, maxY)
  local lowY = _G[condFrame.sliderY:GetName() .. "Low"]
  local highY = _G[condFrame.sliderY:GetName() .. "High"]
  if lowY then
    lowY:SetText(tostring(minY))
  end
  if highY then
    highY:SetText(tostring(maxY))
  end

  -- 尺寸滑块
  condFrame.sliderSize:SetMinMaxValues(minSize, maxSize)
  local lowS = _G[condFrame.sliderSize:GetName() .. "Low"]
  local highS = _G[condFrame.sliderSize:GetName() .. "High"]
  if lowS then
    lowS:SetText(tostring(minSize))
  end
  if highS then
    highS:SetText(tostring(maxSize))
  end

  -- 钳位当前值（以及DB值）到新范围内
  local function clamp(v, lo, hi)
    if v < lo then
      return lo
    elseif v > hi then
      return hi
    else
      return v
    end
  end

  if currentKey then
    local d = DoiteAurasDB and DoiteAurasDB.spells and DoiteAurasDB.spells[currentKey]
    if d then
      d.offsetX = clamp(d.offsetX or 0, minX, maxX)
      d.offsetY = clamp(d.offsetY or 0, minY, maxY)
      d.iconSize = clamp(d.iconSize or 40, minSize, maxSize)
    end
  end

  -- 将钳位后的值推入滑块/输入框
  if currentKey then
    local d = DoiteAurasDB.spells[currentKey]
    if d then
      condFrame.sliderX:SetValue(d.offsetX or 0)
      condFrame.sliderY:SetValue(d.offsetY or 0)
      condFrame.sliderSize:SetValue(d.iconSize or 40)
      if condFrame.sliderXBox then
        condFrame.sliderXBox:SetText(tostring(math.floor((d.offsetX or 0) + 0.5)))
      end
      if condFrame.sliderYBox then
        condFrame.sliderYBox:SetText(tostring(math.floor((d.offsetY or 0) + 0.5)))
      end
      if condFrame.sliderSizeBox then
        condFrame.sliderSizeBox:SetText(tostring(math.floor((d.iconSize or 40) + 0.5)))
      end
    end
  end
end


-- 内部：初始化增长方向下拉框（仅组长可用）
local function InitGrowthDropdown(dd, data)
  UIDropDownMenu_Initialize(dd, function(frame, level, menuList)
    local info
    local directions = { "水平向右", "水平向左", "水平居中", "垂直向下", "垂直向上", "垂直居中" }
    for _, dir in ipairs(directions) do
      info = {}
      info.text = dir
      info.value = dir
      local pickedDir = dir
      info.func = function(button)
        local picked = (button and button.value) or pickedDir
        if not currentKey then
          return
        end
        local d = EnsureDBEntry(currentKey)
        d.growth = picked
        UIDropDownMenu_SetSelectedValue(dd, picked)
        UIDropDownMenu_SetText(picked, dd)
        CloseDropDownMenus()
        SafeRefresh()
        SafeEvaluate()
      end
      info.checked = (data and data.growth == dir)
      UIDropDownMenu_AddButton(info)
    end
  end)
end

-- 内部：初始化光环数量下拉框（仅组长可用）
local function InitNumAurasDropdown(dd, data)
  UIDropDownMenu_Initialize(dd, function(frame, level, menuList)
    local info
    for i = 1, 10 do
      info = {}
      info.text = tostring(i)
      info.value = i
      local pickedNum = i
      info.func = function(button)
        local picked = (button and button.value) or pickedNum
        if not currentKey then
          return
        end
        local d = EnsureDBEntry(currentKey)
        d.numAuras = picked
        UIDropDownMenu_SetSelectedValue(dd, picked)
        UIDropDownMenu_SetText(tostring(picked), dd)
        CloseDropDownMenus()
        SafeRefresh()
        SafeEvaluate()
      end
      info.checked = (data and data.numAuras == i)
      UIDropDownMenu_AddButton(info)
    end
    info = {}
    info.text = "无限制"
    info.value = "无限制"
    info.func = function(button)
      local picked = (button and button.value) or "无限制"
      if not currentKey then
        return
      end
      local d = EnsureDBEntry(currentKey)
        d.numAuras = picked
        UIDropDownMenu_SetSelectedValue(dd, picked)
        UIDropDownMenu_SetText(picked, dd)
        CloseDropDownMenus()
        SafeRefresh()
        SafeEvaluate()
      end
      info.checked = (data and data.numAuras == "无限制")
      UIDropDownMenu_AddButton(info)
    end)
end

-- 统一的形态/姿态下拉框初始化器（适用于 Ability / Aura / Item）
local function InitFormDropdown(dd, data, condType)
  if not dd then
    return
  end
  condType = condType or "ability"

  local thisKey = currentKey
  if not thisKey then
    ClearDropdown(dd)
    return
  end

  if dd._initializedForKey == thisKey and dd._initializedForType == condType then
    return
  end

  -- 确定玩家职业并构建选项（重新排序，添加牧师）
  local _, class = UnitClass("player")
  class = class and string.upper(class) or ""

  local forms = {}
  if class == "DRUID" then
    forms = {
      "所有形态",
      "0. 无形态", "1. 熊", "2. 水栖", "3. 猫", "4. 旅行",
      "5. 枭兽", "6. 生命之树", "7. 潜行", "8. 非潜行",
      "复合: 0+5", "复合: 0+6", "复合: 1+3", "复合: 3+7", "复合: 3+8",
      "复合: 5+6", "复合: 0+5+6", "复合: 1+3+8"
    }
  elseif class == "WARRIOR" then
    forms = { "所有姿态", "1. 战斗", "2. 防御", "3. 狂暴",
              "复合: 1+2", "复合: 1+3", "复合: 2+3" }
  elseif class == "ROGUE" then
    forms = { "所有形态", "0. 非潜行", "1. 潜行" }
  elseif class == "PRIEST" then
    forms = { "所有形态", "0. 无形态", "1. 暗影形态" }
  elseif class == "PALADIN" then
    forms = {
      "所有光环", "无光环", "1. 虔诚光环", "2. 惩戒光环", "3. 专注光环",
      "4. 暗影抗性光环", "5. 冰霜抗性光环", "6. 火焰抗性光环", "7. 圣洁光环",
      "复合: 1+2", "复合: 1+3", "复合: 1+4+5+6", "复合: 1+7", "复合: 1+2+3", "复合: 1+2+3+4+5+6",
      "复合: 2+3", "复合: 2+4+5+6", "复合: 2+7", "复合: 2+3+4+5+6",
      "复合: 3+4+5+6", "复合: 3+7",
      "复合: 4+5+6+7"
    }
  else
    dd:Hide()
    return
  end

  -- 确保在构建前清空旧菜单
  ClearDropdown(dd)

  -- 构建/初始化下拉框
  UIDropDownMenu_Initialize(dd, function(frame, level, menuList)
    for i, form in ipairs(forms) do
      local info = UIDropDownMenu_CreateInfo()
      info.text = form
      info.value = form
      local pickedForm = form

      info.func = function(button)
        local picked = (button and button.value) or pickedForm
        UIDropDownMenu_SetSelectedValue(dd, picked)
        UIDropDownMenu_SetText(picked, dd)

        if condType == "ability" then
          data.conditions.ability = data.conditions.ability or {}
          data.conditions.ability.form = picked
        elseif condType == "aura" then
          data.conditions.aura = data.conditions.aura or {}
          data.conditions.aura.form = picked
        elseif condType == "item" then
          data.conditions.item = data.conditions.item or {}
          data.conditions.item.form = picked
        end

        SafeRefresh()
        SafeEvaluate()
        UpdateCondFrameForKey(currentKey)
      end

      -- 根据传入的data设置勾选状态
      local savedForm = (data and data.conditions and data.conditions[condType] and data.conditions[condType].form)
      info.checked = (savedForm == form)

      UIDropDownMenu_AddButton(info)
    end
  end)

  -- 恢复可见值（保存值或默认）
  local savedForm = (data and data.conditions and data.conditions[condType] and data.conditions[condType].form)

  local matched = false
  if savedForm and savedForm ~= "所有形态" and savedForm ~= "" then
    for i, f in ipairs(forms) do
      if f == savedForm then
        UIDropDownMenu_SetSelectedID(dd, i)
        matched = true
        break
      end
    end
  end

  if matched then
    UIDropDownMenu_SetText(savedForm, dd)
  else
    UIDropDownMenu_SetText("选择形态", dd)
  end

  dd._initializedForKey = thisKey
  dd._initializedForType = condType
end

-- 统一的武器/战斗风格下拉框（职业专用：战士/圣骑士/萨满）
local function InitWeaponDropdown(dd, data, condType)
  if not dd then
    return
  end
  condType = condType or "ability"

  local thisKey = currentKey
  if not thisKey then
    ClearDropdown(dd)
    return
  end

  -- 检测玩家职业
  local _, class = UnitClass("player")
  class = class and string.upper(class) or ""

  -- 按职业的选项
  local choices
  if class == "WARRIOR" then
    choices = { "任意", "双手", "盾牌", "双持" }
  elseif class == "PALADIN" or class == "SHAMAN" then
    choices = { "任意", "双手", "盾牌" }
  else
    -- 不支持：隐藏下拉框
    dd:Hide()
    return
  end

  ClearDropdown(dd)

  UIDropDownMenu_Initialize(dd, function(frame, level, menuList)
    for _, val in ipairs(choices) do
      local info = UIDropDownMenu_CreateInfo()
      info.text = val
      info.value = val
      local pickedVal = val

      info.func = function(button)
        local picked = (button and button.value) or pickedVal
        if not currentKey then
          return
        end

        -- 更新控件
        UIDropDownMenu_SetSelectedValue(dd, picked)
        UIDropDownMenu_SetText(picked, dd)
        _GoldifyDD(dd)

        -- 持久化到正确的条件表
        local d = EnsureDBEntry(currentKey)
        d.conditions = d.conditions or {}

        if condType == "ability" then
          d.conditions.ability = d.conditions.ability or {}
          d.conditions.ability.weaponFilter = picked
        elseif condType == "aura" then
          d.conditions.aura = d.conditions.aura or {}
          d.conditions.aura.weaponFilter = picked
        elseif condType == "item" then
          d.conditions.item = d.conditions.item or {}
          d.conditions.item.weaponFilter = picked
        end

        SafeRefresh();
        SafeEvaluate()
        if UpdateCondFrameForKey then
          UpdateCondFrameForKey(currentKey)
        end
        if CloseDropDownMenus then
          CloseDropDownMenus()
        end
      end

      local saved
      if data and data.conditions and data.conditions[condType] then
        saved = data.conditions[condType].weaponFilter
      end
      info.checked = (saved == val)

      UIDropDownMenu_AddButton(info)
    end
  end)

  -- 初始可见状态：保存的值，或默认的"已装备"占位符
  local saved
  if data and data.conditions and data.conditions[condType] then
    saved = data.conditions[condType].weaponFilter
  end

  if saved then
    if UIDropDownMenu_SetSelectedValue then
      pcall(UIDropDownMenu_SetSelectedValue, dd, saved)
    end
    if UIDropDownMenu_SetText then
      pcall(UIDropDownMenu_SetText, saved, dd)
    end
    _GoldifyDD(dd)
  else
    if UIDropDownMenu_SetSelectedValue then
      pcall(UIDropDownMenu_SetSelectedValue, dd, nil)
    end
    if UIDropDownMenu_SetText then
      -- "已装备" = 默认/中性状态
      pcall(UIDropDownMenu_SetText, "已装备", dd)
    end
    _GoldifyDD(dd)
  end

  dd._initializedForKey = thisKey
  dd._initializedForType = condType
end

----------------------------------------------------------------
-- 互斥辅助函数
----------------------------------------------------------------
local function SetExclusiveAbilityMode(mode)
  if not currentKey then
    return
  end
  local d = EnsureDBEntry(currentKey)
  d.conditions = d.conditions or {}
  d.conditions.ability = d.conditions.ability or {}

  if mode ~= nil
      and mode ~= "usable"
      and mode ~= "notcd"
      and mode ~= "oncd"
      and mode ~= "usableoncd"
      and mode ~= "nocdoncd" then
    mode = "notcd"
  end

  d.conditions.ability.mode = mode
  UpdateCondFrameForKey(currentKey)
  SafeRefresh()
  SafeEvaluate()
end

local function SetExclusiveItemMode(mode)
  if not currentKey then return end
  local d = EnsureDBEntry(currentKey)
  d.conditions = d.conditions or {}
  d.conditions.item = d.conditions.item or {}

  -- mode 是 "notcd", "oncd", "both" 之一
  if mode ~= "notcd" and mode ~= "oncd" and mode ~= "both" then
    mode = "notcd"
  end

  d.conditions.item.mode = mode
  UpdateCondFrameForKey(currentKey)
end

-- 独立的战斗标志切换（inCombat / outCombat）
local function SetCombatFlag(typeTable, which, enabled)
  if not currentKey then
    return
  end
  local d = EnsureDBEntry(currentKey)
  d.conditions = d.conditions or {}
  d.conditions[typeTable] = d.conditions[typeTable] or {}

  -- 严格分离：绝不允许相反的表存在
  if typeTable == "ability" then
    d.conditions.aura = nil
    d.conditions.item = nil
  elseif typeTable == "aura" then
    d.conditions.ability = nil
    d.conditions.item = nil
  elseif typeTable == "item" then
    d.conditions.ability = nil
    d.conditions.aura = nil
  end

  if which == "in" then
    d.conditions[typeTable].inCombat = enabled and true or false
  elseif which == "out" then
    d.conditions[typeTable].outCombat = enabled and true or false
  end
  d.conditions[typeTable].combat = nil
  UpdateCondFrameForKey(currentKey)
  SafeRefresh()
  SafeEvaluate()
end

-- 组队模式下拉框模式：
local function _DeriveGroupingMode(t)
  if not t then
    return nil
  end
  if t.grouping ~= nil then
    return t.grouping
  end
  -- 遗留字段后备（尽力而为）
  if t.notInGroup == true then
    return "nogroup"
  end
  local p = (t.inParty == true)
  local r = (t.inRaid == true)
  if p and r then
    return "partyraid"
  elseif p then
    return "party"
  elseif r then
    return "raid"
  end
  return nil
end

SetGroupMode = function(typeTable, mode)
  if not currentKey then
    return
  end

  local d = EnsureDBEntry(currentKey)
  d.conditions = d.conditions or {}
  d.conditions[typeTable] = d.conditions[typeTable] or {}
  local t = d.conditions[typeTable]

  -- 严格分离：绝不允许相反的表存在
  if typeTable == "ability" then
    d.conditions.aura = nil
    d.conditions.item = nil
  elseif typeTable == "aura" then
    d.conditions.ability = nil
    d.conditions.item = nil
  elseif typeTable == "item" then
    d.conditions.ability = nil
    d.conditions.aura = nil
  end

  -- 存储规范模式
  if mode == nil then
    t.grouping = nil
  else
    t.grouping = mode
  end

  -- 保持遗留字段镜像（兼容性）
  t.notInGroup = nil
  if mode == "nogroup" then
    t.notInGroup = true
    t.inParty = nil
    t.inRaid = nil
  elseif mode == "party" then
    t.inParty = true
    t.inRaid = nil
  elseif mode == "raid" then
    t.inParty = nil
    t.inRaid = true
  elseif mode == "partyraid" then
    t.inParty = true
    t.inRaid = true
  elseif mode == "any" then
    t.inParty = nil
    t.inRaid = nil
  else
    t.grouping = nil
    t.inParty = nil
    t.inRaid = nil
    t.notInGroup = nil
  end

  UpdateCondFrameForKey(currentKey)
  SafeRefresh()
  SafeEvaluate()
end

local function SetExclusiveAuraFoundMode(mode)
  if not currentKey then
    return
  end
  local d = EnsureDBEntry(currentKey)
  d.conditions = d.conditions or {}
  d.conditions.aura = d.conditions.aura or {}

  if mode ~= nil and mode ~= "found" and mode ~= "missing" and mode ~= "both" then
    mode = "found"
  end

  d.conditions.aura.mode = mode
  UpdateCondFrameForKey(currentKey)
  SafeRefresh()
  SafeEvaluate()
end

-- 文件作用域辅助函数，供 CreateConditionsUI 和 UpdateConditionsUI 调用
function _GoldifyDD(dd)
  if not dd or not dd.GetName then
    return
  end
  local name = dd:GetName()
  if not name then
    return
  end
  local txt = _G[name .. "Text"]
  if txt and txt.SetTextColor then
    txt:SetTextColor(1, 0.82, 0)
  end
end

function _GreyifyDD(dd)
  if not dd or not dd.GetName then
    return
  end
  local name = dd:GetName()
  local txt = _G[name .. "Text"]
  if txt and txt.SetTextColor then
    txt:SetTextColor(0.6, 0.6, 0.6)
  end
end

function _WhiteifyDDText(dd)
  if not dd or not dd.GetName then
    return
  end
  local name = dd:GetName()
  if not name then
    return
  end
  local txt = _G[name .. "Text"]
  if txt and txt.SetTextColor then
    txt:SetTextColor(1, 1, 1)
  end
end

-- 仅在禁用时修改文本/占位符。
local function _SetDDEnabled(dd, enabled, placeholderText)
  if not dd or not dd.GetName then
    return
  end
  local name = dd:GetName()
  local btn = name and _G[name .. "Button"]

  if enabled then
    -- 启用按钮，保留_RestoreDD或Init*设置的文本
    if btn and btn.Enable then
      btn:Enable()
    end
    _GoldifyDD(dd)
  else
    -- 禁用并显示中性占位符
    if btn and btn.Disable then
      btn:Disable()
    end
    if UIDropDownMenu_ClearAll then
      pcall(UIDropDownMenu_ClearAll, dd)
    end
    if placeholderText and UIDropDownMenu_SetText then
      UIDropDownMenu_SetText(placeholderText, dd)
    end
    _GreyifyDD(dd)
  end
end

-- 打印辅助：进入图标编辑时在聊天框提示
local lastAnnouncedKey = nil

-- 打印辅助：进入图标编辑时在聊天框提示
local function DoiteEdit_AnnounceEditingIcon(displayName)
  -- 每个编辑会话每个图标只提示一次
  if currentKey and lastAnnouncedKey == currentKey then
    return
  end
  lastAnnouncedKey = currentKey

  if not displayName or displayName == "" then
    displayName = "未知"
  end

  local prefix = "|cff4da6ffDoiteAuras:|r "
  local name = "|cffffff00" .. tostring(displayName) .. "|r"

  local msg = prefix ..
      "编辑 " .. name ..
      " 期间，此图标将保持可见，并固定在动态组顶部（如果有），以方便查看。"

  DEFAULT_CHAT_FRAME:AddMessage(msg)
end

DEFAULT_CUSTOM_FUNCTION_SOURCE = [[-- 为这个光环定义自定义逻辑。会传入一个名为 'data' 的表，你可以在此存储帧之间的数据。

-- 你的代码块必须返回以下内容：
local show = true -- [布尔值] true 显示图标，false 隐藏
local texture = "Interface\\Icons\\Temp" -- [字符串] MPOWA 图标位于 "Interface\\Addons\\DoiteAuras\\Textures\\MPOWA\\AuraXX"

local hideBackground = false -- [布尔值] 如果为 true，将隐藏图标纹理后面的默认背景

local remaining = nil -- [数字] 如果存在，将显示在图标中心
local stacks = nil -- [数字] 如果存在，将显示在图标右下角

return show, texture, hideBackground, remaining, stacks]]

-- 与其他模块共享（如DoiteConditions）
_G["DOITE_DEFAULT_CUSTOM_FUNCTION_SOURCE"] = DEFAULT_CUSTOM_FUNCTION_SOURCE

local function CompileCustomFunctionSource(source)
  if type(source) ~= "string" then
    return nil, "自定义函数源码必须是字符串。"
  end
  if source == "" then
    return nil, "自定义函数源码不能为空。"
  end

  local wrapped = "return function(data)\n" .. source .. "\nend"
  local chunk, err = loadstring(wrapped)
  if not chunk then
    return nil, err
  end

  local ok, fn = pcall(chunk)
  if not ok then
    return nil, fn
  end
  if type(fn) ~= "function" then
    return nil, "编译后的自定义函数不可调用。"
  end
  return fn, nil
end


-- DoiteAuras使用的TitleCase辅助函数的本地副本（用于美化光环名称）
-- 特殊处理罗马数字（II, IV, VI, VIII, X等），使其保持全大写。
local function AuraCond_TitleCase(str)
  if not str then
    return ""
  end
  str = tostring(str)

  local exceptions = {
    ["of"] = true, ["and"] = true, ["the"] = true, ["for"] = true,
    ["in"] = true, ["on"] = true, ["to"] = true, ["a"] = true,
    ["an"] = true, ["with"] = true, ["by"] = true, ["at"] = true
  }

  local function IsRomanNumeralToken(core)
    if not core or core == "" then
      return false
    end
    local upper = string.upper(core)
    -- 仅包含罗马数字字符
    if not string.find(upper, "^[IVXLCDM]+$") then
      return false
    end
    -- 保守处理：等级通常很短
    if string.len(upper) > 4 then
      return false
    end
    return true
  end

  local function DotAwareLowerRest(rest)
    if not rest or rest == "" then
      return ""
    end
    rest = string.lower(rest)
    -- 将点号后的字母大写
    rest = string.gsub(rest, "%.(%a)", function(a)
      return "." .. string.upper(a)
    end)
    return rest
  end

  local result, first = "", true
  local word
  for word in string.gfind(str, "%S+") do
    local startsParen = (string.sub(word, 1, 1) == "(")
    local leading = startsParen and "(" or ""
    local core = startsParen and string.sub(word, 2) or word

    local lowerCore = string.lower(core or "")
    local upperCore = string.upper(core or "")
    local c = string.sub(core or "", 1, 1) or ""
    local rest = string.sub(core or "", 2) or ""

    -- 1) 罗马数字：保持全大写
    if IsRomanNumeralToken(core) then
      result = result .. leading .. upperCore .. " "
      first = false
    else
      -- 2) 标准标题大小写规则
      if first then
        result = result .. leading .. string.upper(c) .. DotAwareLowerRest(rest) .. " "
        first = false
      else
        if startsParen then
          result = result .. leading .. string.upper(c) .. DotAwareLowerRest(rest) .. " "
        elseif exceptions[lowerCore] then
          result = result .. lowerCore .. " "
        else
          result = result .. leading .. string.upper(c) .. DotAwareLowerRest(rest) .. " "
        end
      end
    end
  end

  result = string.gsub(result, "%s+$", "")
  return result
end

----------------------------------------------------------------
-- 条件界面创建与连接
----------------------------------------------------------------
local function CreateConditionsUI()
  if not condFrame then
    return
  end
  if condFrame._conditionsUIBuilt then
    return
  end
  condFrame._conditionsUIBuilt = true

  -- 辅助函数（父级为可滚动内容区域）
  local function _Parent()
    return (condFrame and condFrame._condArea) or condFrame
  end

  local function MakeCheck(name, label, x, y)
    local parent = _Parent()
    local cb = CreateFrame("CheckButton", name, parent, "UICheckButtonTemplate")
    cb:SetWidth(20);
    cb:SetHeight(20)
    cb:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    cb.text = cb:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    cb.text:SetPoint("LEFT", cb, "RIGHT", 4, 0)
    cb.text:SetText(label)
    return cb
  end

  local function MakeComparatorDD(name, x, y, width)
    local parent = _Parent()
    local dd = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
    dd:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    if UIDropDownMenu_SetWidth then
      pcall(UIDropDownMenu_SetWidth, width or 55, dd)
    end
    return dd
  end

  local function MakeSmallEdit(name, x, y, width)
    local parent = _Parent()
    local eb = CreateFrame("EditBox", name, parent, "InputBoxTemplate")
    eb:SetWidth(width or 44)
    eb:SetHeight(18)
    eb:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    eb:SetAutoFocus(false)
    eb:SetJustifyH("CENTER")
    eb:SetFontObject("GameFontNormalSmall")
    return eb
  end

  local function MakeMiniFadeSlider(name, x, y)
    local parent = _Parent()
    local eb = CreateFrame("EditBox", name, parent, "InputBoxTemplate")
    eb:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    eb:SetWidth(26)
    eb:SetHeight(16)
    eb:SetAutoFocus(false)
    eb:SetJustifyH("CENTER")
    eb:SetFontObject("GameFontNormalSmall")
    eb:SetNumeric(true)

    local pct = eb:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    pct:SetPoint("LEFT", eb, "RIGHT", 4, 0)
    pct:SetText("|cffffd000%|r")
    eb._pct = pct
    return eb
  end

  -- 渲染一个小的粗体白色标题，带有“分裂”分隔线，该线不会穿过文本下方
  local function MakeSeparatorRow(parent, y, title, drawLine)
    drawLine = (drawLine ~= false)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, y)
    holder:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, y)
    holder:SetHeight(16)

    local label = holder:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, 0)
    label:SetJustifyH("LEFT")
    label:SetText("|cffffffff" .. (title or "") .. "|r")

    local lineY = -8
    local lineL = holder:CreateTexture(nil, "ARTWORK")
    lineL:SetHeight(1);
    lineL:SetTexture(1, 1, 1);
    lineL:SetVertexColor(1, 1, 1, 0.25)
    lineL:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, lineY)
    lineL:SetPoint("TOPRIGHT", label, "TOPLEFT", -6, lineY)

    local lineR = holder:CreateTexture(nil, "ARTWORK")
    lineR:SetHeight(1);
    lineR:SetTexture(1, 1, 1);
    lineR:SetVertexColor(1, 1, 1, 0.25)
    lineR:SetPoint("TOPLEFT", label, "TOPRIGHT", 6, lineY)
    lineR:SetPoint("TOPRIGHT", holder, "TOPRIGHT", 0, lineY)

    if not drawLine then
      lineL:Hide();
      lineR:Hide()
    end

    holder._label = label
    holder._lineL = lineL
    holder._lineR = lineR
    holder:Hide() -- 默认隐藏；由管理器控制可见性
    return holder
  end

  local function SetSeparatorLineVisible(sep, visible)
    if not sep then
      return
    end
    if visible then
      if sep._lineL then
        sep._lineL:Show()
      end
      if sep._lineR then
        sep._lineR:Show()
      end
    else
      if sep._lineL then
        sep._lineL:Hide()
      end
      if sep._lineR then
        sep._lineR:Hide()
      end
    end
  end

  -- === 分隔线Y位置 ===
  local srow1_y, srow2_y, srow3_y, srow4_y, srow5_y = -5, -45, -110, -150, -190
  local srow6_y, srow7_y, srow8_y, srow9_y, srow10_y = -230, -270, -310, -350, -390
  local srow11_y, srow12_y, srow13_y, srow14_y, srow15_y = -430, -470, -510, -550, -590
  local srow16_y, srow17_y, srow18_y, srow19_y, srow20_y = -630, -670, -710, -750, -790

  srows = {
    srow1_y, srow2_y, srow3_y, srow4_y, srow5_y,
    srow6_y, srow7_y, srow8_y, srow9_y, srow10_y,
    srow11_y, srow12_y, srow13_y, srow14_y, srow15_y,
    srow16_y, srow17_y, srow18_y, srow19_y, srow20_y
  }

  -- === 按类型的分隔线缓存（ability/aura/item/custom各自独立）
  condFrame._seps = condFrame._seps or { ability = {}, aura = {}, item = {}, custom = {} }

  local function _EnsureSep(typeKey, slot)
    local list = condFrame._seps[typeKey]
    if not list[slot] then
      local y = srows[slot] or srows[1]
      list[slot] = MakeSeparatorRow(_Parent(), y, "", true)
      list[slot]._visible = false
      list[slot]._lineOn = true
    end
    return list[slot]
  end

  -- 规范化任何扩展类型键（例如"item_trinket", "item_weapon"）到其基础桶。
  local function _NormalizeSepTypeKey(typeKey)
    if not typeKey then
      return nil
    end
    if typeKey == "ability" or typeKey == "aura" or typeKey == "item" or typeKey == "custom" then
      return typeKey
    end

    local lower = string.lower(tostring(typeKey))

    -- 将任何*包含*这些子字符串的内容映射回基础键。
    -- 例如"item_trinket_slots" -> "item"
    if string.find(lower, "ability", 1, true) then
      return "ability"
    elseif string.find(lower, "aura", 1, true) then
      return "aura"
    elseif string.find(lower, "item", 1, true) then
      return "item"
    elseif string.find(lower, "custom", 1, true) then
      return "custom"
    end

    return nil
  end

  -- typeKey = "ability" | "aura" | "item"（或扩展形式如"item_trinket"）；slot = 1..20
  SetSeparator = function(typeKey, slot, title, showLine, isVisible)
    typeKey = _NormalizeSepTypeKey(typeKey)
    if not typeKey then
      return
    end
    if slot < 1 or slot > 20 then
      return
    end

    local sep = _EnsureSep(typeKey, slot)
    if sep._label then
      sep._label:SetText("|cffffffff" .. (title or "") .. "|r")
    end
    sep._lineOn = (showLine ~= false)
    SetSeparatorLineVisible(sep, sep._lineOn)
    sep._visible = (isVisible and true) or false
    if sep._visible then
      sep:Show()
    else
      sep:Hide()
    end
    return sep
  end

  -- 导出：UpdateConditionsUI调用此函数
  ShowSeparatorsForType = function(typeKey)
    -- 将任何扩展键（"item_trinket", "item_weapon"等）映射到基础桶。
    typeKey = _NormalizeSepTypeKey(typeKey)
    if not typeKey then
      -- 未知类型：不进行任何操作
      return
    end

    -- 先隐藏所有分隔线
    for _, list in pairs(condFrame._seps) do
      for _, sep in pairs(list) do
        sep:Hide()
      end
    end

    -- 然后只显示此类型的可见分隔线（保留线条状态）
    local mine = condFrame._seps[typeKey] or {}
    for _, sep in pairs(mine) do
      if sep._visible then
        SetSeparatorLineVisible(sep, sep._lineOn)
        sep:Show()
      end
    end
  end

  -- 行位置
  local row1_y, row2_y, row2b_y, row3_y, row4_y, row5_y = -20, -60, -85, -125, -165, -205
  local row6_y, row7_y, row8_y, row9_y, row10_y = -245, -285, -325, -365, -405
  local row11_y, row12_y, row13_y, row14_y, row15_y = -445, -485, -525, -565, -605
  local row16_y, row17_y, row18_y, row19_y, row20_y = -620, -660, -700, -740, -780

  condFrame._rowY = {
    [7] = row7_y,
    [8] = row8_y,
    [10] = row10_y,
    [11] = row11_y,
  }

  --------------------------------------------------
  -- 技能行
  --------------------------------------------------
  condFrame.cond_ability_usable = MakeCheck("DoiteCond_Ability_Usable", "可用", 0, row1_y)
  condFrame.cond_ability_notcd = MakeCheck("DoiteCond_Ability_NotCD", "不在冷却中", 70, row1_y)
  condFrame.cond_ability_oncd = MakeCheck("DoiteCond_Ability_OnCD", "冷却中", 190, row1_y)
  SetSeparator("ability", 1, "可用性和冷却", true, true)

  condFrame.cond_ability_incombat = MakeCheck("DoiteCond_Ability_InCombat", "战斗中", 0, row2_y)
  condFrame.cond_ability_outcombat = MakeCheck("DoiteCond_Ability_OutCombat", "非战斗中", 80, row2_y)

  -- 组队状态下拉框（替代“在队伍中”/“在团队中”复选框）
  do
    local parent = _Parent()
    condFrame.cond_ability_groupingDD = CreateFrame("Frame", "DoiteCond_Ability_GroupingDD", parent, "UIDropDownMenuTemplate")
    condFrame.cond_ability_groupingDD:SetPoint("TOPLEFT", parent, "TOPLEFT", -15, row2b_y + 5)
    if UIDropDownMenu_SetWidth then
      pcall(UIDropDownMenu_SetWidth, 100, condFrame.cond_ability_groupingDD)
    end

    ClearDropdown(condFrame.cond_ability_groupingDD)
    UIDropDownMenu_Initialize(condFrame.cond_ability_groupingDD, function(frame, level, menuList)
      DoiteEdit_AddGroupModeOption("ability", "任意", "any")
      DoiteEdit_AddGroupModeOption("ability", "不在队伍/团队中", "nogroup")
      DoiteEdit_AddGroupModeOption("ability", "在队伍中", "party")
      DoiteEdit_AddGroupModeOption("ability", "在团队中", "raid")
      DoiteEdit_AddGroupModeOption("ability", "在队伍或团队中", "partyraid")
    end)
  end

  SetSeparator("ability", 2, "战斗和组队状态", true, true)

  condFrame.cond_ability_target_help = MakeCheck("DoiteCond_Ability_TargetHelp", "目标(友善)", 0, row3_y)
  condFrame.cond_ability_target_harm = MakeCheck("DoiteCond_Ability_TargetHarm", "目标(敌对)", 95, row3_y)
  condFrame.cond_ability_target_self = MakeCheck("DoiteCond_Ability_TargetSelf", "目标(自己)", 200, row3_y)
  SetSeparator("ability", 3, "目标条件", true, true)

  -- 目标状态
  condFrame.cond_ability_target_alive = MakeCheck("DoiteCond_Ability_TargetAlive", "活着", 0, row4_y)
  condFrame.cond_ability_target_dead = MakeCheck("DoiteCond_Ability_TargetDead", "死亡", 70, row4_y)
  SetSeparator("ability", 4, "目标状态", true, true)

  condFrame.cond_ability_glow = MakeCheck("DoiteCond_Ability_Glow", "发光", 0, row5_y)
  condFrame.cond_ability_greyscale = MakeCheck("DoiteCond_Ability_Greyscale", "灰色", 70, row5_y)
  condFrame.cond_ability_fade = MakeCheck("DoiteCond_Ability_Fade", "淡出", 140, row5_y)
  condFrame.cond_ability_fade_slider = MakeMiniFadeSlider("DoiteCond_Ability_FadeSlider", 200, row5_y - 2)
  SetSeparator("ability", 5, "视觉效果", true, true)

  -- 技能行：目标距离与类型
  SetSeparator("ability", 6, "目标距离和类型", true, true)

  condFrame.cond_ability_distanceDD = CreateFrame("Frame", "DoiteCond_Ability_DistanceDD", _Parent(), "UIDropDownMenuTemplate")
  condFrame.cond_ability_distanceDD:SetPoint("TOPLEFT", _Parent(), "TOPLEFT", -15, row6_y + 3)
  if UIDropDownMenu_SetWidth then
    pcall(UIDropDownMenu_SetWidth, 100, condFrame.cond_ability_distanceDD)
  end

  condFrame.cond_ability_unitTypeDD = CreateFrame("Frame", "DoiteCond_Ability_UnitTypeDD", _Parent(), "UIDropDownMenuTemplate")
  condFrame.cond_ability_unitTypeDD:SetPoint("TOPLEFT", _Parent(), "TOPLEFT", 120, row6_y + 3)
  if UIDropDownMenu_SetWidth then
    pcall(UIDropDownMenu_SetWidth, 100, condFrame.cond_ability_unitTypeDD)
  end

  condFrame.cond_ability_slider = MakeCheck("DoiteCond_Ability_Slider", "即将冷却完毕指示器", 0, row7_y)
  condFrame.cond_ability_slider_dir = CreateFrame("Frame", "DoiteCond_Ability_SliderDir", _Parent(), "UIDropDownMenuTemplate")
  condFrame.cond_ability_slider_dir:SetPoint("LEFT", condFrame.cond_ability_slider, "RIGHT", 53, -3)
  if UIDropDownMenu_SetWidth then
    pcall(UIDropDownMenu_SetWidth, 60, condFrame.cond_ability_slider_dir)
  end
  condFrame.cond_ability_remaining_cb = MakeCheck("DoiteCond_Ability_RemainingCB", "剩余", 0, row7_y)
  condFrame.cond_ability_remaining_comp = MakeComparatorDD("DoiteCond_Ability_RemComp", 65, row7_y + 3, 50)
  condFrame.cond_ability_remaining_val = MakeSmallEdit("DoiteCond_Ability_RemVal", 160, row7_y - 2, 40)
  condFrame.cond_ability_remaining_val_enter = _Parent():CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  condFrame.cond_ability_remaining_val_enter:SetPoint("LEFT", condFrame.cond_ability_remaining_val, "RIGHT", 4, 0)
  condFrame.cond_ability_remaining_val_enter:SetText("(秒)")
  condFrame.cond_ability_remaining_val_enter:Hide()
  condFrame.cond_ability_slider_glow = MakeCheck("DoiteCond_Ability_SliderGlow", "发光", 170, row7_y)
  condFrame.cond_ability_slider_grey = MakeCheck("DoiteCond_Ability_SliderGrey", "灰色", 230, row7_y)
  SetSeparator("ability", 7, "剩余时间", true, true)

  condFrame.cond_ability_power = MakeCheck("DoiteCond_Ability_PowerCB", "资源", 0, row8_y)
  condFrame.cond_ability_power_comp = MakeComparatorDD("DoiteCond_Ability_PowerComp", 65, row8_y + 3, 50)
  condFrame.cond_ability_power_val = MakeSmallEdit("DoiteCond_Ability_PowerVal", 160, row8_y - 2, 40)
  condFrame.cond_ability_power_val_enter = _Parent():CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  condFrame.cond_ability_power_val_enter:SetPoint("LEFT", condFrame.cond_ability_power_val, "RIGHT", 4, 0)
  condFrame.cond_ability_power_val_enter:SetText("(%)")
  condFrame.cond_ability_power_val_enter:Hide()
  SetSeparator("ability", 8, "资源", true, true)

  condFrame.cond_ability_hp_my = MakeCheck("DoiteCond_Ability_HP_My", "我的HP", 0, row9_y)
  condFrame.cond_ability_hp_tgt = MakeCheck("DoiteCond_Ability_HP_Tgt", "目标HP", 65, row9_y)
  condFrame.cond_ability_hp_comp = MakeComparatorDD("DoiteCond_Ability_HP_Comp", 130, row9_y + 3, 50)
  condFrame.cond_ability_hp_val = MakeSmallEdit("DoiteCond_Ability_HP_Val", 225, row9_y - 2, 40)
  condFrame.cond_ability_hp_val_enter = _Parent():CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  condFrame.cond_ability_hp_val_enter:SetPoint("LEFT", condFrame.cond_ability_hp_val, "RIGHT", 4, 0)
  condFrame.cond_ability_hp_val_enter:SetText("(%)")
  condFrame.cond_ability_hp_comp:Hide()
  condFrame.cond_ability_hp_val:Hide()
  condFrame.cond_ability_hp_val_enter:Hide()
  SetSeparator("ability", 9, "生命值条件", true, true)

  condFrame.cond_ability_text_time = MakeCheck("DoiteCond_Ability_TextTime", "图标文本：剩余时间", 0, row10_y)
  SetSeparator("ability", 10, "图标文本", true, true)

  -- 连击点数下拉框（职业专用：德鲁伊/盗贼）
  condFrame.cond_ability_cp_cb = MakeCheck("DoiteCond_Ability_CP_CB", "连击点数", 0, row11_y)
  condFrame.cond_ability_cp_comp = MakeComparatorDD("DoiteCond_Ability_CP_Comp", 85, row11_y + 3, 50)
  condFrame.cond_ability_cp_val = MakeSmallEdit("DoiteCond_Ability_CP_Val", 180, row11_y - 2, 40)
  condFrame.cond_ability_cp_val_enter = _Parent():CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  condFrame.cond_ability_cp_val_enter:SetPoint("LEFT", condFrame.cond_ability_cp_val, "RIGHT", 4, 0)
  condFrame.cond_ability_cp_val_enter:SetText("(#)")
  condFrame.cond_ability_cp_val_enter:Hide()
  SetSeparator("ability", 11, "职业专属", true, true)

  -- 技能：职业专用武器/战斗风格下拉框（萨满/战士/圣骑士）
  condFrame.cond_ability_weaponDD = CreateFrame("Frame", "DoiteCond_Ability_WeaponDD", _Parent(), "UIDropDownMenuTemplate")
  condFrame.cond_ability_weaponDD:SetPoint("TOPLEFT", _Parent(), "TOPLEFT", -15, row11_y + 3)
  if UIDropDownMenu_SetWidth then
    pcall(UIDropDownMenu_SetWidth, 90, condFrame.cond_ability_weaponDD)
  end
  condFrame.cond_ability_weaponDD:Hide()
  ClearDropdown(condFrame.cond_ability_weaponDD)

  -- 技能：无连击点数的职业的提示
  condFrame.cond_ability_class_note = _Parent():CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  condFrame.cond_ability_class_note:SetPoint("TOPLEFT", _Parent(), "TOPLEFT", 0, row11_y)
  condFrame.cond_ability_class_note:SetTextColor(1, 0.82, 0)
  condFrame.cond_ability_class_note:SetText("未为你的职业添加专属选项。")
  condFrame.cond_ability_class_note:Hide()

  -- 技能：音效
  condFrame.cond_ability_sound_oncd_cb = MakeCheck("DoiteCond_Ability_Sound_OnCD_CB", "冷却时", 0, row12_y)
  condFrame.cond_ability_sound_oncd_dd = CreateFrame("Frame", "DoiteCond_Ability_Sound_OnCD_DD", _Parent(), "UIDropDownMenuTemplate")
  condFrame.cond_ability_sound_oncd_dd:SetPoint("TOPLEFT", _Parent(), "TOPLEFT", 100, row12_y + 3)
  if UIDropDownMenu_SetWidth then
    pcall(UIDropDownMenu_SetWidth, 140, condFrame.cond_ability_sound_oncd_dd)
  end

  condFrame.cond_ability_sound_offcd_cb = MakeCheck("DoiteCond_Ability_Sound_OffCD_CB", "冷却结束时", 0, row12_y - 25)
  condFrame.cond_ability_sound_offcd_dd = CreateFrame("Frame", "DoiteCond_Ability_Sound_OffCD_DD", _Parent(), "UIDropDownMenuTemplate")
  condFrame.cond_ability_sound_offcd_dd:SetPoint("TOPLEFT", _Parent(), "TOPLEFT", 100, row12_y - 22)
  if UIDropDownMenu_SetWidth then
    pcall(UIDropDownMenu_SetWidth, 140, condFrame.cond_ability_sound_offcd_dd)
  end

  condFrame.cond_ability_sound_onproc_cb = MakeCheck("DoiteCond_Ability_Sound_OnProc_CB", "触发时", 0, row12_y - 50)
  condFrame.cond_ability_sound_onproc_dd = CreateFrame("Frame", "DoiteCond_Ability_Sound_OnProc_DD", _Parent(), "UIDropDownMenuTemplate")
  condFrame.cond_ability_sound_onproc_dd:SetPoint("TOPLEFT", _Parent(), "TOPLEFT", 100, row12_y - 47)
  if UIDropDownMenu_SetWidth then
    pcall(UIDropDownMenu_SetWidth, 140, condFrame.cond_ability_sound_onproc_dd)
  end
  SetSeparator("ability", 12, "音效", true, true)

  -- 技能：动态光环条件部分
  local abilityAuraBaseY = row14_y - 15
  local sepAbilityAura = SetSeparator("ability", 14, "额外：可见性（显示/隐藏）条件", true, true)
  if sepAbilityAura then
    local sepAuraY = ((srows and srows[14]) or 0) - 15
    sepAbilityAura:ClearAllPoints()
    sepAbilityAura:SetPoint("TOPLEFT", _Parent(), "TOPLEFT", 0, sepAuraY)
    sepAbilityAura:SetPoint("TOPRIGHT", _Parent(), "TOPRIGHT", 0, sepAuraY)
  end
  condFrame.abilityAuraAnchor = CreateFrame("Frame", nil, _Parent())
  condFrame.abilityAuraAnchor:SetPoint("TOPLEFT", _Parent(), "TOPLEFT", 0, abilityAuraBaseY)
  condFrame.abilityAuraAnchor:SetPoint("TOPRIGHT", _Parent(), "TOPRIGHT", 0, abilityAuraBaseY)
  condFrame.abilityAuraAnchor:SetHeight(20)

  -- 技能：动态视觉效果条件部分
  local abilityVfxBaseY = row15_y - 15
  local sepAbilityVfx = SetSeparator("ability", 15, "额外：视觉效果（发光/灰色）条件", true, true)
  if sepAbilityVfx then
    local sepVfxY = ((srows and srows[15]) or 0) - 15
    sepAbilityVfx:ClearAllPoints()
    sepAbilityVfx:SetPoint("TOPLEFT", _Parent(), "TOPLEFT", 0, sepVfxY)
    sepAbilityVfx:SetPoint("TOPRIGHT", _Parent(), "TOPRIGHT", 0, sepVfxY)
  end
  condFrame.abilityVfxAnchor = CreateFrame("Frame", nil, _Parent())
  condFrame.abilityVfxAnchor:SetPoint("TOPLEFT", _Parent(), "TOPLEFT", 0, abilityVfxBaseY)
  condFrame.abilityVfxAnchor:SetPoint("TOPRIGHT", _Parent(), "TOPRIGHT", 0, abilityVfxBaseY)
  condFrame.abilityVfxAnchor:SetHeight(20)

  --------------------------------------------------
  -- Buff/Debuff行
  --------------------------------------------------
  condFrame.cond_aura_found = MakeCheck("DoiteCond_Aura_Found", "光环存在", 0, row1_y)
  condFrame.cond_aura_missing = MakeCheck("DoiteCond_Aura_Missing", "光环缺失", 85, row1_y)
  condFrame.cond_aura_tip = _Parent():CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  condFrame.cond_aura_tip:SetPoint("LEFT", condFrame.cond_aura_missing.text, "RIGHT", 2, 0)
  condFrame.cond_aura_tip:SetText("(要显示图标，光环必须被施加过一次)")
  condFrame.cond_aura_tip:SetWidth(120)
  condFrame.cond_aura_tip:Hide()
  SetSeparator("aura", 1, "光环存在状态", true, true)

  -- 自定义函数编辑器（自定义类型）
  -- 编辑框直接位于_condArea中；外部条件滚动条驱动它。
  -- 没有嵌套滚动框 – EditBox自动增高，父级滚动。
  SetSeparator("custom", 1, "自定义函数", true, true)

  condFrame.cond_custom_function_edit = CreateFrame("EditBox", nil, _Parent())
  condFrame.cond_custom_function_edit:SetMultiLine(true)
  condFrame.cond_custom_function_edit:SetAutoFocus(false)
  condFrame.cond_custom_function_edit:SetFontObject("GameFontHighlightSmall")
  condFrame.cond_custom_function_edit:SetPoint("TOPLEFT", _Parent(), "TOPLEFT", 2, -5)
  condFrame.cond_custom_function_edit:SetPoint("TOPRIGHT", _Parent(), "TOPRIGHT", -2, -5)
  condFrame.cond_custom_function_edit:SetWidth((_Parent():GetWidth() or 260) - 4)
  condFrame.cond_custom_function_edit:SetHeight(500)
  condFrame.cond_custom_function_edit:EnableMouse(true)
  if condFrame.cond_custom_function_edit.SetTextInsets then
    condFrame.cond_custom_function_edit:SetTextInsets(4, 4, 4, 4)
  end
  -- 自动增高以适应内容，使外部滚动区域正确调整大小。
  condFrame.cond_custom_function_edit:SetScript("OnTextChanged", function()
    local eb = condFrame.cond_custom_function_edit
    if not eb then return end
    -- 通过文本中的换行符统计行数
    local txt = eb:GetText() or ""
    local lines = 1
    for _ in string.gfind(txt, "\n") do
      lines = lines + 1
    end
    local lineH = 15  -- GameFontHighlightSmall的近似行高
    local newH = math.max((lines + 3) * lineH, 180)
    eb:SetHeight(newH)
    if _ReflowCondAreaHeight then
      _ReflowCondAreaHeight()
    end
  end)
  -- 将编辑框的鼠标滚轮转发到外部条件滚动框。
  condFrame.cond_custom_function_edit:EnableMouseWheel(true)
  condFrame.cond_custom_function_edit:SetScript("OnMouseWheel", function()
    local sf = condFrame and condFrame._scrollFrame
    if not sf then return end
    local cur = sf:GetVerticalScroll() or 0
    local step = 40
    if arg1 and arg1 > 0 then
      sf:SetVerticalScroll(math.max(cur - step, 0))
    elseif arg1 and arg1 < 0 then
      local sbName = sf:GetName() and (sf:GetName() .. "ScrollBar")
      local sb = sbName and getglobal(sbName)
      local maxScroll = 0
      if sb and sb.GetMinMaxValues then
        local _, hi = sb:GetMinMaxValues()
        maxScroll = hi or 0
      end
      sf:SetVerticalScroll(math.min(cur + step, maxScroll))
    end
  end)
  condFrame.cond_custom_function_edit:Hide()

  -- 保存按钮和状态将在gridBtn创建后创建（见下方gridBtn创建部分）。

  condFrame.cond_aura_incombat = MakeCheck("DoiteCond_Aura_InCombat", "战斗中", 0, row2_y)
  condFrame.cond_aura_outcombat = MakeCheck("DoiteCond_Aura_OutCombat", "非战斗中", 80, row2_y)

  -- 组队状态下拉框（替代“在队伍中”/“在团队中”复选框）
  do
    local parent = _Parent()
    condFrame.cond_aura_groupingDD = CreateFrame("Frame", "DoiteCond_Aura_GroupingDD", parent, "UIDropDownMenuTemplate")
    condFrame.cond_aura_groupingDD:SetPoint("TOPLEFT", parent, "TOPLEFT", -15, row2b_y + 5)
    if UIDropDownMenu_SetWidth then
      pcall(UIDropDownMenu_SetWidth, 100, condFrame.cond_aura_groupingDD)
    end

    ClearDropdown(condFrame.cond_aura_groupingDD)
    UIDropDownMenu_Initialize(condFrame.cond_aura_groupingDD, function(frame, level, menuList)
      DoiteEdit_AddGroupModeOption("aura", "任意", "any")
      DoiteEdit_AddGroupModeOption("aura", "不在队伍/团队中", "nogroup")
      DoiteEdit_AddGroupModeOption("aura", "在队伍中", "party")
      DoiteEdit_AddGroupModeOption("aura", "在团队中", "raid")
      DoiteEdit_AddGroupModeOption("aura", "在队伍或团队中", "partyraid")
    end)
  end

  SetSeparator("aura", 2, "战斗和组队状态", true, true)

  condFrame.cond_aura_target_help = MakeCheck("DoiteCond_Aura_TargetHelp", "目标 (友善)", 0, row3_y)
  condFrame.cond_aura_target_harm = MakeCheck("DoiteCond_Aura_TargetHarm", "目标 (敌对)", 94, row3_y)
  condFrame.cond_aura_onself = MakeCheck("DoiteCond_Aura_OnSelf", "玩家自己身上", 192, row3_y)
  SetSeparator("aura", 3, "目标条件", true, true)

  -- 目标状态
  condFrame.cond_aura_target_alive = MakeCheck("DoiteCond_Aura_TargetAlive", "活着", 0, row4_y)
  condFrame.cond_aura_target_dead = MakeCheck("DoiteCond_Aura_TargetDead", "死亡", 70, row4_y)
  SetSeparator("aura", 4, "目标状态", true, true)

  condFrame.cond_aura_glow = MakeCheck("DoiteCond_Aura_Glow", "发光", 0, row5_y)
  condFrame.cond_aura_greyscale = MakeCheck("DoiteCond_Aura_Greyscale", "灰色", 70, row5_y)
  condFrame.cond_aura_fade = MakeCheck("DoiteCond_Aura_Fade", "淡出", 140, row5_y)
  condFrame.cond_aura_fade_slider = MakeMiniFadeSlider("DoiteCond_Aura_FadeSlider", 200, row5_y - 2)
  SetSeparator("aura", 5, "视觉效果", true, true)

  -- 光环行：目标距离与类型
  SetSeparator("aura", 6, "目标距离和类型", true, true)

  condFrame.cond_aura_distanceDD = CreateFrame("Frame", "DoiteCond_Aura_DistanceDD", _Parent(), "UIDropDownMenuTemplate")
  condFrame.cond_aura_distanceDD:SetPoint("TOPLEFT", _Parent(), "TOPLEFT", -15, row6_y + 3)
  if UIDropDownMenu_SetWidth then
    pcall(UIDropDownMenu_SetWidth, 100, condFrame.cond_aura_distanceDD)
  end

  condFrame.cond_aura_unitTypeDD = CreateFrame("Frame", "DoiteCond_Aura_UnitTypeDD", _Parent(), "UIDropDownMenuTemplate")
  condFrame.cond_aura_unitTypeDD:SetPoint("TOPLEFT", _Parent(), "TOPLEFT", 120, row6_y + 3)
  if UIDropDownMenu_SetWidth then
    pcall(UIDropDownMenu_SetWidth, 100, condFrame.cond_aura_unitTypeDD)
  end

  condFrame.cond_aura_power = MakeCheck("DoiteCond_Aura_PowerCB", "资源", 0, row7_y)
  condFrame.cond_aura_power_comp = MakeComparatorDD("DoiteCond_Aura_PowerComp", 65, row7_y + 3, 50)
  condFrame.cond_aura_power_val = MakeSmallEdit("DoiteCond_Aura_PowerVal", 160, row7_y - 2, 40)
  condFrame.cond_aura_power_val_enter = _Parent():CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  condFrame.cond_aura_power_val_enter:SetPoint("LEFT", condFrame.cond_aura_power_val, "RIGHT", 4, 0)
  condFrame.cond_aura_power_val_enter:SetText("(%)")
  condFrame.cond_aura_power_comp:Hide()
  condFrame.cond_aura_power_val:Hide()
  condFrame.cond_aura_power_val_enter:Hide()
  SetSeparator("aura", 7, "资源", true, true)

  condFrame.cond_aura_hp_my = MakeCheck("DoiteCond_Aura_HP_My", "我的HP", 0, row8_y)
  condFrame.cond_aura_hp_tgt = MakeCheck("DoiteCond_Aura_HP_Tgt", "目标HP", 65, row8_y)
  condFrame.cond_aura_hp_comp = MakeComparatorDD("DoiteCond_Aura_HP_Comp", 130, row8_y + 3, 50)
  condFrame.cond_aura_hp_val = MakeSmallEdit("DoiteCond_Aura_HP_Val", 225, row8_y - 2, 40)
  condFrame.cond_aura_hp_val_enter = _Parent():CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  condFrame.cond_aura_hp_val_enter:SetPoint("LEFT", condFrame.cond_aura_hp_val, "RIGHT", 4, 0)
  condFrame.cond_aura_hp_val_enter:SetText("(%)")
  condFrame.cond_aura_hp_comp:Hide()
  condFrame.cond_aura_hp_val:Hide()
  condFrame.cond_aura_hp_val_enter:Hide()
  SetSeparator("aura", 8, "生命值条件", true, true)

  -- 光环拥有者
  condFrame.cond_aura_mine = MakeCheck("DoiteCond_Aura_MyAura", "我的光环", 0, row9_y)
  condFrame.cond_aura_others = MakeCheck("DoiteCond_Aura_OthersAura", "他人的光环", 75, row9_y)
  condFrame.cond_aura_owner_tip = _Parent():CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  condFrame.cond_aura_owner_tip:SetPoint("LEFT", condFrame.cond_aura_others, "RIGHT", 70, -3)
  condFrame._aura_owner_tip_default = condFrame._aura_owner_tip_default
      or "'剩余' 只能用于'目标(友善/敌对)'上的'我的光环'"
  condFrame.cond_aura_owner_tip:SetText(condFrame._aura_owner_tip_default)
  condFrame.cond_aura_owner_tip:SetWidth(120)
  condFrame.cond_aura_owner_tip:SetTextColor(1, 0.82, 0)
  condFrame.cond_aura_owner_tip:Hide()

  SetSeparator("aura", 9, "光环拥有者", true, true)

  -- 剩余时间与层数
  condFrame.cond_aura_remaining_cb = MakeCheck("DoiteCond_Aura_RemCB", "剩余", 0, row10_y)
  condFrame.cond_aura_remaining_comp = MakeComparatorDD("DoiteCond_Aura_RemComp", 65, row10_y + 3, 50)
  condFrame.cond_aura_remaining_val = MakeSmallEdit("DoiteCond_Aura_RemVal", 160, row10_y - 2, 40)
  condFrame.cond_aura_remaining_val_enter = _Parent():CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  condFrame.cond_aura_remaining_val_enter:SetPoint("LEFT", condFrame.cond_aura_remaining_val, "RIGHT", 4, 0)
  condFrame.cond_aura_remaining_val_enter:SetText("(秒)")
  condFrame.cond_aura_remaining_val_enter:Hide()

  condFrame.cond_aura_stacks_cb = MakeCheck("DoiteCond_Aura_StacksCB", "层数", 0, srow11_y)
  condFrame.cond_aura_stacks_comp = MakeComparatorDD("DoiteCond_Aura_StacksComp", 65, srow11_y + 3, 50)
  condFrame.cond_aura_stacks_val = MakeSmallEdit("DoiteCond_Aura_StacksVal", 160, srow11_y - 2, 40)
  condFrame.cond_aura_stacks_val_enter = _Parent():CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  condFrame.cond_aura_stacks_val_enter:SetPoint("LEFT", condFrame.cond_aura_stacks_val, "RIGHT", 4, 0)
  condFrame.cond_aura_stacks_val_enter:SetText("(#)")
  condFrame.cond_aura_stacks_val_enter:Hide()

  condFrame.cond_aura_text_time = MakeCheck("DoiteCond_Aura_TextTime", "图标文本：剩余时间", 0, row11_y - 11)
  condFrame.cond_aura_text_stack = MakeCheck("DoiteCond_Aura_TextStack", "图标文本：层数", 0, row12_y+3)
  condFrame.cond_aura_text_time_override = CreateFrame("EditBox", "DoiteCond_Aura_TextTimeOverride", _Parent(), "InputBoxTemplate")
  condFrame.cond_aura_text_time_override:SetWidth(100)
  condFrame.cond_aura_text_time_override:SetHeight(18)
  condFrame.cond_aura_text_time_override:SetPoint("TOPLEFT", _Parent(), "TOPLEFT", 165, row11_y - 11)
  condFrame.cond_aura_text_time_override:SetAutoFocus(false)
  condFrame.cond_aura_text_time_override:SetJustifyH("LEFT")
  condFrame.cond_aura_text_time_override:SetFontObject("GameFontNormalSmall")
  condFrame.cond_aura_text_time_override:Hide()

  condFrame.cond_aura_text_stack_override = CreateFrame("EditBox", "DoiteCond_Aura_TextStackOverride", _Parent(), "InputBoxTemplate")
  condFrame.cond_aura_text_stack_override:SetWidth(100)
  condFrame.cond_aura_text_stack_override:SetHeight(18)
  condFrame.cond_aura_text_stack_override:SetPoint("TOPLEFT", _Parent(), "TOPLEFT", 165, row12_y+3)
  condFrame.cond_aura_text_stack_override:SetAutoFocus(false)
  condFrame.cond_aura_text_stack_override:SetJustifyH("LEFT")
  condFrame.cond_aura_text_stack_override:SetFontObject("GameFontNormalSmall")
  condFrame.cond_aura_text_stack_override:Hide()

  condFrame.cond_aura_text_override_note = _Parent():CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  condFrame.cond_aura_text_override_note:SetPoint("TOPLEFT", condFrame.cond_aura_text_stack_override, "BOTTOMLEFT", -70, -2)
  condFrame.cond_aura_text_override_note:SetTextColor(1, 0.82, 0)
  condFrame.cond_aura_text_override_note:SetText("输入覆盖光环名称或法术ID (基于玩家)。留空则使用默认。")
  condFrame.cond_aura_text_override_note:SetWidth(220)
  condFrame.cond_aura_text_override_note:SetJustifyH("LEFT")
  condFrame.cond_aura_text_override_note:Hide()
  SetSeparator("aura", 10, "剩余时间和层数", true, true)

  -- 职业专属（连击点数）

  local auraClassRowY = row13_y -11

  condFrame.cond_aura_cp_cb = MakeCheck("DoiteCond_Aura_CP_CB", "连击点数", 0, auraClassRowY)
  condFrame.cond_aura_cp_comp = MakeComparatorDD("DoiteCond_Aura_CP_Comp", 85, auraClassRowY + 3, 50)
  condFrame.cond_aura_cp_val = MakeSmallEdit("DoiteCond_Aura_CP_Val", 180, auraClassRowY - 2, 40)
  condFrame.cond_aura_cp_val_enter = _Parent():CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  condFrame.cond_aura_cp_val_enter:SetPoint("LEFT", condFrame.cond_aura_cp_val, "RIGHT", 4, 0)
  condFrame.cond_aura_cp_val_enter:SetText("(#)")
  condFrame.cond_aura_cp_val_enter:Hide()

  local sepAuraClass = SetSeparator("aura", 13, "职业专属", true, true)
  if sepAuraClass and srows then
    local newY = (srows[13] or 0) - 10  -- 原始第10槽Y减10
    sepAuraClass:ClearAllPoints()
    sepAuraClass:SetPoint("TOPLEFT", _Parent(), "TOPLEFT", 0, newY)
    sepAuraClass:SetPoint("TOPRIGHT", _Parent(), "TOPRIGHT", 0, newY)
  end

  -- 光环：职业专用武器/战斗风格下拉框（萨满/战士/圣骑士）
  condFrame.cond_aura_weaponDD = CreateFrame("Frame", "DoiteCond_Aura_WeaponDD", _Parent(), "UIDropDownMenuTemplate")
  condFrame.cond_aura_weaponDD:SetPoint("TOPLEFT", _Parent(), "TOPLEFT", -15, auraClassRowY + 3)
  if UIDropDownMenu_SetWidth then
    pcall(UIDropDownMenu_SetWidth, 90, condFrame.cond_aura_weaponDD)
  end
  condFrame.cond_aura_weaponDD:Hide()
  ClearDropdown(condFrame.cond_aura_weaponDD)

  -- 光环：无连击点数的职业的提示
  condFrame.cond_aura_class_note = _Parent():CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  condFrame.cond_aura_class_note:SetPoint("TOPLEFT", _Parent(), "TOPLEFT", 0, auraClassRowY)
  condFrame.cond_aura_class_note:SetTextColor(1, 0.82, 0)
  condFrame.cond_aura_class_note:SetText("未为你的职业添加专属选项。")
  condFrame.cond_aura_class_note:Hide()

  condFrame.cond_aura_trackpet = MakeCheck("DoiteCond_Aura_TrackPet", "在宠物上跟踪此光环", 0, auraClassRowY)
  condFrame.cond_aura_trackpet:Hide()

  -- 光环：音效
  condFrame.cond_aura_sound_ongain_cb = MakeCheck("DoiteCond_Aura_Sound_OnGain_CB", "获得时", 0, row14_y - 10)
  condFrame.cond_aura_sound_ongain_dd = CreateFrame("Frame", "DoiteCond_Aura_Sound_OnGain_DD", _Parent(), "UIDropDownMenuTemplate")
  condFrame.cond_aura_sound_ongain_dd:SetPoint("TOPLEFT", _Parent(), "TOPLEFT", 100, row14_y - 7)
  if UIDropDownMenu_SetWidth then
    pcall(UIDropDownMenu_SetWidth, 140, condFrame.cond_aura_sound_ongain_dd)
  end

  condFrame.cond_aura_sound_onfade_cb = MakeCheck("DoiteCond_Aura_Sound_OnFade_CB", "消失时", 0, row14_y - 35)
  condFrame.cond_aura_sound_onfade_dd = CreateFrame("Frame", "DoiteCond_Aura_Sound_OnFade_DD", _Parent(), "UIDropDownMenuTemplate")
  condFrame.cond_aura_sound_onfade_dd:SetPoint("TOPLEFT", _Parent(), "TOPLEFT", 100, row14_y - 32)
  if UIDropDownMenu_SetWidth then
    pcall(UIDropDownMenu_SetWidth, 140, condFrame.cond_aura_sound_onfade_dd)
  end

  local sepAuraSound = SetSeparator("aura", 14, "音效", true, true)
  if sepAuraSound and srows then
    local newY = (srows[14] or 0) - 10
    sepAuraSound:ClearAllPoints()
    sepAuraSound:SetPoint("TOPLEFT", _Parent(), "TOPLEFT", 0, newY)
    sepAuraSound:SetPoint("TOPRIGHT", _Parent(), "TOPRIGHT", 0, newY)
  end

  local sepAuraBuff = SetSeparator("aura", 16, "额外：可见性（显示/隐藏）条件", true, true)
  if sepAuraBuff and srows then
    local newY = (srows[16] or 0)
    sepAuraBuff:ClearAllPoints()
    sepAuraBuff:SetPoint("TOPLEFT", _Parent(), "TOPLEFT", 0, newY)
    sepAuraBuff:SetPoint("TOPRIGHT", _Parent(), "TOPRIGHT", 0, newY)
  end

  -- 光环（Buff/Debuff）：动态光环条件部分
  local auraAuraBaseY = row17_y + 15
  condFrame.auraAuraAnchor = CreateFrame("Frame", nil, _Parent())
  condFrame.auraAuraAnchor:SetPoint("TOPLEFT", _Parent(), "TOPLEFT", 0, auraAuraBaseY)
  condFrame.auraAuraAnchor:SetPoint("TOPRIGHT", _Parent(), "TOPRIGHT", 0, auraAuraBaseY)
  condFrame.auraAuraAnchor:SetHeight(20)

  -- 光环：动态视觉效果条件部分
  local auraVfxBaseY = row17_y
  SetSeparator("aura", 17, "额外：视觉效果（发光/灰色）条件", true, true)
  condFrame.auraVfxAnchor = CreateFrame("Frame", nil, _Parent())
  condFrame.auraVfxAnchor:SetPoint("TOPLEFT", _Parent(), "TOPLEFT", 0, auraVfxBaseY)
  condFrame.auraVfxAnchor:SetPoint("TOPRIGHT", _Parent(), "TOPRIGHT", 0, auraVfxBaseY)
  condFrame.auraVfxAnchor:SetHeight(20)

  --------------------------------------------------
  -- 物品行
  --------------------------------------------------
  -- 位置/物品栏槽位（特殊物品）
  condFrame.cond_item_where_equipped = MakeCheck("DoiteCond_Item_WhereEquipped", "已装备", 0, row1_y)
  condFrame.cond_item_where_bag = MakeCheck("DoiteCond_Item_WhereBag", "在背包中", 90, row1_y)
  condFrame.cond_item_where_missing = MakeCheck("DoiteCond_Item_WhereMissing", "缺失", 190, row1_y)

  -- 特殊合成物品的槽位单选组：
  condFrame.cond_item_inv_trinket1 = MakeCheck("DoiteCond_Item_Inv_Trinket1", "饰品 1", 0, row1_y)
  condFrame.cond_item_inv_trinket2 = MakeCheck("DoiteCond_Item_Inv_Trinket2", "饰品 2", 73, row1_y)
  condFrame.cond_item_inv_trinket_first = MakeCheck("DoiteCond_Item_Inv_TrinketFirst", "首个就绪", 148, row1_y)
  condFrame.cond_item_inv_trinket_both = MakeCheck("DoiteCond_Item_Inv_TrinketBoth", "两者", 230, row1_y)

  condFrame.cond_item_inv_wep_mainhand = MakeCheck("DoiteCond_Item_Inv_WepMain", "主手", 0, row1_y)
  condFrame.cond_item_inv_wep_offhand = MakeCheck("DoiteCond_Item_Inv_WepOff", "副手", 87, row1_y)
  condFrame.cond_item_inv_wep_ranged = MakeCheck("DoiteCond_Item_Inv_WepRanged", "远程/神像/圣物", 165, row1_y)
  condFrame.cond_item_inv_wep_ammo = MakeCheck("DoiteCond_Item_Inv_WepAmmo", "弹药", 235, row1_y)

  -- 默认标题；在UpdateConditionsUI中针对特殊物品动态更改
  SetSeparator("item", 1, "位置", true, true)

  -- 战斗状态
  condFrame.cond_item_incombat = MakeCheck("DoiteCond_Item_InCombat", "战斗中", 0, row2_y)
  condFrame.cond_item_outcombat = MakeCheck("DoiteCond_Item_OutCombat", "非战斗中", 80, row2_y)

  -- 组队状态下拉框（替代“在队伍中”/“在团队中”复选框）
  do
    local parent = _Parent()
    condFrame.cond_item_groupingDD = CreateFrame("Frame", "DoiteCond_Item_GroupingDD", parent, "UIDropDownMenuTemplate")
    condFrame.cond_item_groupingDD:SetPoint("TOPLEFT", parent, "TOPLEFT", -15, row2b_y + 5)
    if UIDropDownMenu_SetWidth then
      pcall(UIDropDownMenu_SetWidth, 100, condFrame.cond_item_groupingDD)
    end

    ClearDropdown(condFrame.cond_item_groupingDD)
    UIDropDownMenu_Initialize(condFrame.cond_item_groupingDD, function(frame, level, menuList)
      DoiteEdit_AddGroupModeOption("item", "任意", "any")
      DoiteEdit_AddGroupModeOption("item", "不在队伍/团队中", "nogroup")
      DoiteEdit_AddGroupModeOption("item", "在队伍中", "party")
      DoiteEdit_AddGroupModeOption("item", "在团队中", "raid")
      DoiteEdit_AddGroupModeOption("item", "在队伍或团队中", "partyraid")
    end)
  end

  SetSeparator("item", 2, "战斗和组队状态", true, true)

  -- 可用性和冷却（无“可用”）
  condFrame.cond_item_notcd = MakeCheck("DoiteCond_Item_NotCD", "不在冷却中", 0, row3_y)
  condFrame.cond_item_oncd = MakeCheck("DoiteCond_Item_OnCD", "冷却中", 100, row3_y)
  -- 可点击选项
  condFrame.cond_item_clickable = MakeCheck("DoiteCond_Item_Clickable", "使用物品", 200, row3_y)

  SetSeparator("item", 3, "可用性和冷却", true, true)

  -- 附魔状态（仅当 mode == "notcd" 或 "both" 时对“---EQUIPPED WEAPON SLOTS---”启用）
  do
    local parent = _Parent()
    condFrame.cond_item_enchant = CreateFrame("Frame", "DoiteCond_Item_Enchant", parent, "UIDropDownMenuTemplate")
    condFrame.cond_item_enchant:SetPoint("TOPLEFT", parent, "TOPLEFT", -15, row4_y + 3)
    if UIDropDownMenu_SetWidth then
      pcall(UIDropDownMenu_SetWidth, 120, condFrame.cond_item_enchant)
    end
    condFrame.cond_item_enchant:Hide()
  end
  condFrame.cond_item_text_enchant = MakeCheck("DoiteCond_Item_TextEnchant", "图标文本：附魔剩余时间", 150, row4_y)
  if condFrame.cond_item_text_enchant and condFrame.cond_item_text_enchant.text and condFrame.cond_item_text_enchant.text.SetWidth then
    condFrame.cond_item_text_enchant.text:SetWidth(90)
  end
  condFrame.cond_item_text_enchant:Hide()
  SetSeparator("item", 4, "临时武器附魔", true, true)


  -- 目标条件
  condFrame.cond_item_target_help = MakeCheck("DoiteCond_Item_TargetHelp", "目标 (友善)", 0, row5_y)
  condFrame.cond_item_target_harm = MakeCheck("DoiteCond_Item_TargetHarm", "目标 (敌对)", 95, row5_y)
  condFrame.cond_item_target_self = MakeCheck("DoiteCond_Item_TargetSelf", "目标 (自己)", 200, row5_y)
  SetSeparator("item", 5, "目标条件", true, true)

  -- 目标状态（物品） – 使用row5_y使其靠近物品的视觉效果行
  condFrame.cond_item_target_alive = MakeCheck("DoiteCond_Item_TargetAlive", "活着", 0, row6_y)
  condFrame.cond_item_target_dead = MakeCheck("DoiteCond_Item_TargetDead", "死亡", 70, row6_y)
  SetSeparator("item", 6, "目标状态", true, true)

  -- 视觉效果
  condFrame.cond_item_glow = MakeCheck("DoiteCond_Item_Glow", "发光", 0, row7_y)
  condFrame.cond_item_greyscale = MakeCheck("DoiteCond_Item_Greyscale", "灰色", 70, row7_y)
  condFrame.cond_item_fade = MakeCheck("DoiteCond_Item_Fade", "淡出", 140, row7_y)
  condFrame.cond_item_fade_slider = MakeMiniFadeSlider("DoiteCond_Item_FadeSlider", 200, row7_y - 2)
  SetSeparator("item", 7, "视觉效果", true, true)

  -- 物品行：目标距离与类型
  SetSeparator("item", 8, "目标距离和类型", true, true)

  condFrame.cond_item_distanceDD = CreateFrame("Frame", "DoiteCond_Item_DistanceDD", _Parent(), "UIDropDownMenuTemplate")
  condFrame.cond_item_distanceDD:SetPoint("TOPLEFT", _Parent(), "TOPLEFT", -15, row8_y + 3)
  if UIDropDownMenu_SetWidth then
    pcall(UIDropDownMenu_SetWidth, 100, condFrame.cond_item_distanceDD)
  end

  condFrame.cond_item_unitTypeDD = CreateFrame("Frame", "DoiteCond_Item_UnitTypeDD", _Parent(), "UIDropDownMenuTemplate")
  condFrame.cond_item_unitTypeDD:SetPoint("TOPLEFT", _Parent(), "TOPLEFT", 120, row8_y + 3)
  if UIDropDownMenu_SetWidth then
    pcall(UIDropDownMenu_SetWidth, 100, condFrame.cond_item_unitTypeDD)
  end

  -- 数量（物品）
  condFrame.cond_item_text_stack = MakeCheck("DoiteCond_Item_TextStack", "图标文本", 0, row9_y)
  condFrame.cond_item_stacks_cb = MakeCheck("DoiteCond_Item_StacksCB", "数量", 75, row9_y)
  condFrame.cond_item_stacks_comp = MakeComparatorDD("DoiteCond_Item_StacksComp", 130, row9_y + 3, 50)
  condFrame.cond_item_stacks_val = MakeSmallEdit("DoiteCond_Item_StacksVal", 225, row9_y - 2, 40)
  condFrame.cond_item_stacks_val_enter = _Parent():CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  condFrame.cond_item_stacks_val_enter:SetPoint("LEFT", condFrame.cond_item_stacks_val, "RIGHT", 4, 0)
  condFrame.cond_item_stacks_val_enter:SetText("(#)")
  condFrame.cond_item_stacks_val_enter:Hide()
  SetSeparator("item", 9, "数量", true, true)

  -- 资源（能量）
  condFrame.cond_item_power = MakeCheck("DoiteCond_Item_PowerCB", "资源", 0, row10_y)
  condFrame.cond_item_power_comp = MakeComparatorDD("DoiteCond_Item_PowerComp", 65, row10_y + 3, 50)
  condFrame.cond_item_power_val = MakeSmallEdit("DoiteCond_Item_PowerVal", 160, row10_y - 2, 40)
  condFrame.cond_item_power_val_enter = _Parent():CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  condFrame.cond_item_power_val_enter:SetPoint("LEFT", condFrame.cond_item_power_val, "RIGHT", 4, 0)
  condFrame.cond_item_power_val_enter:SetText("(%)")
  condFrame.cond_item_power_comp:Hide()
  condFrame.cond_item_power_val:Hide()
  condFrame.cond_item_power_val_enter:Hide()
  SetSeparator("item", 10, "资源", true, true)


  -- 生命值条件
  condFrame.cond_item_hp_my = MakeCheck("DoiteCond_Item_HP_My", "我的HP", 0, row11_y)
  condFrame.cond_item_hp_tgt = MakeCheck("DoiteCond_Item_HP_Tgt", "目标HP", 65, row11_y)
  condFrame.cond_item_hp_comp = MakeComparatorDD("DoiteCond_Item_HP_Comp", 130, row11_y + 3, 50)
  condFrame.cond_item_hp_val = MakeSmallEdit("DoiteCond_Item_HP_Val", 225, row11_y - 2, 40)
  condFrame.cond_item_hp_val_enter = _Parent():CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  condFrame.cond_item_hp_val_enter:SetPoint("LEFT", condFrame.cond_item_hp_val, "RIGHT", 4, 0)
  condFrame.cond_item_hp_val_enter:SetText("(%)")
  condFrame.cond_item_hp_comp:Hide()
  condFrame.cond_item_hp_val:Hide()
  condFrame.cond_item_hp_val_enter:Hide()
  SetSeparator("item", 11, "生命值条件", true, true)

  -- 剩余时间（无滑块）
  condFrame.cond_item_remaining_cb = MakeCheck("DoiteCond_Item_RemCB", "剩余", 0, row12_y)
  condFrame.cond_item_remaining_comp = MakeComparatorDD("DoiteCond_Item_RemComp", 80, row12_y + 3, 50)
  condFrame.cond_item_remaining_val = MakeSmallEdit("DoiteCond_Item_RemVal", 175, row12_y - 2, 40)
  condFrame.cond_item_remaining_val_enter = _Parent():CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  condFrame.cond_item_remaining_val_enter:SetPoint("LEFT", condFrame.cond_item_remaining_val, "RIGHT", 4, 0)
  condFrame.cond_item_remaining_val_enter:SetText("(秒)")
  condFrame.cond_item_remaining_comp:Hide()
  condFrame.cond_item_remaining_val:Hide()
  condFrame.cond_item_remaining_val_enter:Hide()
  condFrame.cond_item_text_time = MakeCheck("DoiteCond_Item_TextTime", "图标文本：剩余时间", 0, row12_y - 25)
  condFrame.cond_item_text_time_override = CreateFrame("EditBox", "DoiteCond_Item_TextTimeOverride", _Parent(), "InputBoxTemplate")
  condFrame.cond_item_text_time_override:SetWidth(100)
  condFrame.cond_item_text_time_override:SetHeight(18)
  condFrame.cond_item_text_time_override:SetPoint("TOPLEFT", _Parent(), "TOPLEFT", 165, row12_y - 25)
  condFrame.cond_item_text_time_override:SetAutoFocus(false)
  condFrame.cond_item_text_time_override:SetJustifyH("LEFT")
  condFrame.cond_item_text_time_override:SetFontObject("GameFontNormalSmall")
  condFrame.cond_item_text_time_override:Hide()

  condFrame.cond_item_text_override_note = _Parent():CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  condFrame.cond_item_text_override_note:SetPoint("TOPLEFT", condFrame.cond_item_text_time_override, "BOTTOMLEFT", -70, -2)
  condFrame.cond_item_text_override_note:SetTextColor(1, 0.82, 0)
  condFrame.cond_item_text_override_note:SetText("输入覆盖光环名称或法术ID (基于玩家)。留空则使用默认。")
  condFrame.cond_item_text_override_note:SetWidth(220)
  condFrame.cond_item_text_override_note:SetJustifyH("LEFT")
  condFrame.cond_item_text_override_note:Hide()
  SetSeparator("item", 12, "剩余时间", true, true)

  -- 职业专属（连击点数）
  condFrame.cond_item_cp_cb = MakeCheck("DoiteCond_Item_CP_CB", "连击点数", 0, row14_y)
  condFrame.cond_item_cp_comp = MakeComparatorDD("DoiteCond_Item_CP_Comp", 85, row14_y + 3, 50)
  condFrame.cond_item_cp_val = MakeSmallEdit("DoiteCond_Item_CP_Val", 180, row14_y - 2, 40)
  condFrame.cond_item_cp_val_enter = _Parent():CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  condFrame.cond_item_cp_val_enter:SetPoint("LEFT", condFrame.cond_item_cp_val, "RIGHT", 4, 0)
  condFrame.cond_item_cp_val_enter:SetText("(#)")
  condFrame.cond_item_cp_val_enter:Hide()
  SetSeparator("item", 14, "职业专属", true, true)

  -- 物品：职业专用武器/战斗风格下拉框（萨满/战士/圣骑士）
  condFrame.cond_item_weaponDD = CreateFrame("Frame", "DoiteCond_Item_WeaponDD", _Parent(), "UIDropDownMenuTemplate")
  condFrame.cond_item_weaponDD:SetPoint("TOPLEFT", _Parent(), "TOPLEFT", -15, row14_y + 3)
  if UIDropDownMenu_SetWidth then
    pcall(UIDropDownMenu_SetWidth, 90, condFrame.cond_item_weaponDD)
  end
  condFrame.cond_item_weaponDD:Hide()
  ClearDropdown(condFrame.cond_item_weaponDD)

  -- 物品：无连击点数的职业的提示
  condFrame.cond_item_class_note = _Parent():CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  condFrame.cond_item_class_note:SetPoint("TOPLEFT", _Parent(), "TOPLEFT", 0, row14_y)
  condFrame.cond_item_class_note:SetTextColor(1, 0.82, 0)
  condFrame.cond_item_class_note:SetText("未为你的职业添加专属选项。")
  condFrame.cond_item_class_note:Hide()

  -- 物品：音效
  condFrame.cond_item_sound_oncd_cb = MakeCheck("DoiteCond_Item_Sound_OnCD_CB", "冷却时", 0, row15_y)
  condFrame.cond_item_sound_oncd_dd = CreateFrame("Frame", "DoiteCond_Item_Sound_OnCD_DD", _Parent(), "UIDropDownMenuTemplate")
  condFrame.cond_item_sound_oncd_dd:SetPoint("TOPLEFT", _Parent(), "TOPLEFT", 100, row15_y + 3)
  if UIDropDownMenu_SetWidth then
    pcall(UIDropDownMenu_SetWidth, 140, condFrame.cond_item_sound_oncd_dd)
  end

  condFrame.cond_item_sound_offcd_cb = MakeCheck("DoiteCond_Item_Sound_OffCD_CB", "冷却结束时", 0, row15_y - 25)
  condFrame.cond_item_sound_offcd_dd = CreateFrame("Frame", "DoiteCond_Item_Sound_OffCD_DD", _Parent(), "UIDropDownMenuTemplate")
  condFrame.cond_item_sound_offcd_dd:SetPoint("TOPLEFT", _Parent(), "TOPLEFT", 100, row15_y - 22)
  if UIDropDownMenu_SetWidth then
    pcall(UIDropDownMenu_SetWidth, 140, condFrame.cond_item_sound_offcd_dd)
  end
  SetSeparator("item", 15, "音效", true, true)

  -- 物品：动态光环条件部分
  local itemAuraBaseY = row17_y - 25
  SetSeparator("item", 17, "额外：可见性（显示/隐藏）条件", true, true)
  condFrame.itemAuraAnchor = CreateFrame("Frame", nil, _Parent())
  condFrame.itemAuraAnchor:SetPoint("TOPLEFT", _Parent(), "TOPLEFT", 0, itemAuraBaseY)
  condFrame.itemAuraAnchor:SetPoint("TOPRIGHT", _Parent(), "TOPRIGHT", 0, itemAuraBaseY)
  condFrame.itemAuraAnchor:SetHeight(20)

  -- 物品：动态视觉效果条件部分
  local itemVfxBaseY = row18_y
  SetSeparator("item", 18, "额外：视觉效果（发光/灰色）条件", true, true)
  condFrame.itemVfxAnchor = CreateFrame("Frame", nil, _Parent())
  condFrame.itemVfxAnchor:SetPoint("TOPLEFT", _Parent(), "TOPLEFT", 0, itemVfxBaseY)
  condFrame.itemVfxAnchor:SetPoint("TOPRIGHT", _Parent(), "TOPRIGHT", 0, itemVfxBaseY)
  condFrame.itemVfxAnchor:SetHeight(20)

  -- 旧版图标类别小部件已被移除；组/类别由 DoiteGroup.AttachEditGroupUI 处理。

  ----------------------------------------------------------------
  -- '形态'下拉框
  ----------------------------------------------------------------
  condFrame.cond_ability_formDD = CreateFrame("Frame", "DoiteCond_Ability_FormDD", _Parent(), "UIDropDownMenuTemplate")
  condFrame.cond_ability_formDD:SetPoint("TOPLEFT", _Parent(), "TOPLEFT", 165, row2_y + 3)
  if UIDropDownMenu_SetWidth then
    pcall(UIDropDownMenu_SetWidth, 90, condFrame.cond_ability_formDD)
  end
  condFrame.cond_ability_formDD:Hide()
  ClearDropdown(condFrame.cond_ability_formDD)

  condFrame.cond_aura_formDD = CreateFrame("Frame", "DoiteCond_Aura_FormDD", _Parent(), "UIDropDownMenuTemplate")
  condFrame.cond_aura_formDD:SetPoint("TOPLEFT", _Parent(), "TOPLEFT", 165, row2_y + 3)
  if UIDropDownMenu_SetWidth then
    pcall(UIDropDownMenu_SetWidth, 90, condFrame.cond_aura_formDD)
  end
  condFrame.cond_aura_formDD:Hide()
  ClearDropdown(condFrame.cond_aura_formDD)

  condFrame.cond_item_formDD = CreateFrame("Frame", "DoiteCond_Item_FormDD", _Parent(), "UIDropDownMenuTemplate")
  condFrame.cond_item_formDD:SetPoint("TOPLEFT", _Parent(), "TOPLEFT", 165, row2_y + 3)
  if UIDropDownMenu_SetWidth then
    pcall(UIDropDownMenu_SetWidth, 90, condFrame.cond_item_formDD)
  end
  condFrame.cond_item_formDD:Hide()
  ClearDropdown(condFrame.cond_item_formDD)

  ----------------------------------------------------------------
  -- 接线：立即强制执行互斥 + 保存到数据库
  ----------------------------------------------------------------

  -- 技能行1脚本（可用 / 不在冷却 / 冷却中）
  -- 规则：
  --  * 至少一个必须保持选中。
  --  * 可用和不在冷却互斥。
  --  * 可用或不在冷却可以与冷却中组合。
  local function _SaveAbilityModeFromUI()
    local usable = condFrame.cond_ability_usable:GetChecked() and true or false
    local notcd = condFrame.cond_ability_notcd:GetChecked() and true or false
    local oncd = condFrame.cond_ability_oncd:GetChecked() and true or false

    local mode
    if usable and oncd then
      mode = "usableoncd"
    elseif notcd and oncd then
      mode = "nocdoncd"
    elseif oncd then
      mode = "oncd"
    elseif usable then
      mode = "usable"
    else
      mode = "notcd"
    end

    SetExclusiveAbilityMode(mode)
  end

  condFrame.cond_ability_usable:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end

    if this:GetChecked() then
      condFrame.cond_ability_notcd:SetChecked(false)
    elseif not condFrame.cond_ability_notcd:GetChecked() and not condFrame.cond_ability_oncd:GetChecked() then
      this:SetChecked(true)
    end

    _SaveAbilityModeFromUI()
  end)

  condFrame.cond_ability_notcd:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end

    if this:GetChecked() then
      condFrame.cond_ability_usable:SetChecked(false)
    elseif not condFrame.cond_ability_usable:GetChecked() and not condFrame.cond_ability_oncd:GetChecked() then
      this:SetChecked(true)
    end

    _SaveAbilityModeFromUI()
  end)

  condFrame.cond_ability_oncd:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end

    if (not this:GetChecked())
        and (not condFrame.cond_ability_usable:GetChecked())
        and (not condFrame.cond_ability_notcd:GetChecked()) then
      this:SetChecked(true)
    end

    _SaveAbilityModeFromUI()
  end)

  -- 物品可用性和冷却（NotCD / OnCD 可组合；至少一个必须选中）
  condFrame.cond_item_notcd:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end

    -- 强制：notcd/oncd至少一个保持选中
    if (not this:GetChecked()) and (not condFrame.cond_item_oncd:GetChecked()) then
      this:SetChecked(true)
    end

    local notcd = condFrame.cond_item_notcd:GetChecked() and true or false
    local oncd  = condFrame.cond_item_oncd:GetChecked() and true or false

    local mode
    if notcd and oncd then
      mode = "both"
    elseif notcd then
      mode = "notcd"
    else
      mode = "oncd"
    end

    SetExclusiveItemMode(mode)
  end)

  condFrame.cond_item_oncd:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end

    -- 强制：notcd/oncd至少一个保持选中
    if (not this:GetChecked()) and (not condFrame.cond_item_notcd:GetChecked()) then
      this:SetChecked(true)
    end

    local notcd = condFrame.cond_item_notcd:GetChecked() and true or false
    local oncd  = condFrame.cond_item_oncd:GetChecked() and true or false

    local mode
    if notcd and oncd then
      mode = "both"
    elseif notcd then
      mode = "notcd"
    else
      mode = "oncd"
    end

    SetExclusiveItemMode(mode)
  end)

  local function _AbilitySoundToggle(which)
    if not currentKey then
      return
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions = d.conditions or {}
    d.conditions.ability = d.conditions.ability or {}

    local cb = (which == "oncd") and condFrame.cond_ability_sound_oncd_cb
        or ((which == "offcd") and condFrame.cond_ability_sound_offcd_cb or condFrame.cond_ability_sound_onproc_cb)
    local dd = (which == "oncd") and condFrame.cond_ability_sound_oncd_dd
        or ((which == "offcd") and condFrame.cond_ability_sound_offcd_dd or condFrame.cond_ability_sound_onproc_dd)
    local field = (which == "oncd") and "soundOnCD"
        or ((which == "offcd") and "soundOffCD" or "soundOnProc")
    local enabledField = (which == "oncd") and "soundOnCDEnabled"
        or ((which == "offcd") and "soundOffCDEnabled" or "soundOnProcEnabled")

    local enabled = cb and cb.GetChecked and cb:GetChecked()
    if enabled then
      DoiteEdit_SetSoundEnabled("ability", enabledField, true)
      DoiteEdit_SetDropdownInteractive(dd, true)
    else
      DoiteEdit_SetSoundEnabled("ability", enabledField, false)
      d.conditions.ability[field] = nil
      DoiteEdit_SetSoundFromDropdown("ability", field, nil)
      DoiteEdit_InitSoundDropdown(dd, "ability", field, nil)
      DoiteEdit_SetDropdownInteractive(dd, false)
    end
  end

  condFrame.cond_ability_sound_oncd_cb:SetScript("OnClick", function() _AbilitySoundToggle("oncd") end)
  condFrame.cond_ability_sound_offcd_cb:SetScript("OnClick", function() _AbilitySoundToggle("offcd") end)
  condFrame.cond_ability_sound_onproc_cb:SetScript("OnClick", function() _AbilitySoundToggle("onproc") end)

  local function _AuraSoundToggle(which)
    if not currentKey then
      return
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions = d.conditions or {}
    d.conditions.aura = d.conditions.aura or {}

    local cb = (which == "ongain") and condFrame.cond_aura_sound_ongain_cb or condFrame.cond_aura_sound_onfade_cb
    local dd = (which == "ongain") and condFrame.cond_aura_sound_ongain_dd or condFrame.cond_aura_sound_onfade_dd
    local field = (which == "ongain") and "soundOnGain" or "soundOnFade"
    local enabledField = (which == "ongain") and "soundOnGainEnabled" or "soundOnFadeEnabled"

    local enabled = cb and cb.GetChecked and cb:GetChecked()
    if enabled then
      DoiteEdit_SetSoundEnabled("aura", enabledField, true)
      DoiteEdit_SetDropdownInteractive(dd, true)
    else
      DoiteEdit_SetSoundEnabled("aura", enabledField, false)
      d.conditions.aura[field] = nil
      DoiteEdit_SetSoundFromDropdown("aura", field, nil)
      DoiteEdit_InitSoundDropdown(dd, "aura", field, nil)
      DoiteEdit_SetDropdownInteractive(dd, false)
    end
  end

  condFrame.cond_aura_sound_ongain_cb:SetScript("OnClick", function() _AuraSoundToggle("ongain") end)
  condFrame.cond_aura_sound_onfade_cb:SetScript("OnClick", function() _AuraSoundToggle("onfade") end)

  local function _ItemSoundToggle(which)
    if not currentKey then
      return
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions = d.conditions or {}
    d.conditions.item = d.conditions.item or {}

    local cb = (which == "oncd") and condFrame.cond_item_sound_oncd_cb or condFrame.cond_item_sound_offcd_cb
    local dd = (which == "oncd") and condFrame.cond_item_sound_oncd_dd or condFrame.cond_item_sound_offcd_dd
    local field = (which == "oncd") and "soundOnCD" or "soundOffCD"
    local enabledField = (which == "oncd") and "soundOnCDEnabled" or "soundOffCDEnabled"

    local enabled = cb and cb.GetChecked and cb:GetChecked()
    if enabled then
      DoiteEdit_SetSoundEnabled("item", enabledField, true)
      DoiteEdit_SetDropdownInteractive(dd, true)
    else
      DoiteEdit_SetSoundEnabled("item", enabledField, false)
      d.conditions.item[field] = nil
      DoiteEdit_SetSoundFromDropdown("item", field, nil)
      DoiteEdit_InitSoundDropdown(dd, "item", field, nil)
      DoiteEdit_SetDropdownInteractive(dd, false)
    end
  end

  condFrame.cond_item_sound_oncd_cb:SetScript("OnClick", function() _ItemSoundToggle("oncd") end)
  condFrame.cond_item_sound_offcd_cb:SetScript("OnClick", function() _ItemSoundToggle("offcd") end)

  condFrame.cond_item_clickable:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    -- 直接保存到数据库
    local d = EnsureDBEntry(currentKey)
    d.conditions = d.conditions or {}
    d.conditions.item = d.conditions.item or {}
    local ic = d.conditions.item

    ic.clickable = this:GetChecked() and true or nil
    SafeRefresh()
    SafeEvaluate()
  end)

  -- 物品：附魔状态下拉框
  if condFrame.cond_item_enchant then
    ClearDropdown(condFrame.cond_item_enchant)

    UIDropDownMenu_Initialize(condFrame.cond_item_enchant, function(frame, level, menuList)
      local function _Add(text, value)
        local info = UIDropDownMenu_CreateInfo()
        info.text = text
        info.value = value
        info.func = function(button)
          if not currentKey then
            return
          end

          local d = EnsureDBEntry(currentKey)
          d.conditions = d.conditions or {}
          d.conditions.item = d.conditions.item or {}
          local ic = d.conditions.item

          local v = (button and button.value) or value

          if v == "true" then
            ic.enchant = true
          elseif v == "false" then
            ic.enchant = false
          else
            -- "任意"或其他
            ic.enchant = nil
          end

          -- 立即更新下拉框界面，使选择在刷新前可见
          if condFrame and condFrame.cond_item_enchant then
            local dd = condFrame.cond_item_enchant
            local txt = "附魔状态"
            local sel = nil

            if ic.enchant == true then
              txt = "已附魔"
              sel = "true"
            elseif ic.enchant == false then
              txt = "未附魔"
              sel = "false"
            else
              txt = "附魔状态"
              sel = nil
            end

            if UIDropDownMenu_SetSelectedValue then
              pcall(UIDropDownMenu_SetSelectedValue, dd, sel)
            end
            if UIDropDownMenu_SetText then
              pcall(UIDropDownMenu_SetText, txt, dd)
            end
          end

          UpdateCondFrameForKey(currentKey)
          SafeRefresh()
          SafeEvaluate()
        end

        UIDropDownMenu_AddButton(info)
      end

      _Add("任意", "any")
      _Add("已附魔", "true")
      _Add("未附魔", "false")
    end)
  end

  -- 物品：图标文本：附魔剩余时间
  if condFrame.cond_item_text_enchant then
    condFrame.cond_item_text_enchant:SetScript("OnClick", function()
      if not currentKey then
        this:SetChecked(false)
        return
      end

      local d = EnsureDBEntry(currentKey)
      d.conditions = d.conditions or {}
      d.conditions.item = d.conditions.item or {}
      local ic = d.conditions.item

      if this:GetChecked() then
        ic.textTimeRemaining = true
      else
        ic.textTimeRemaining = nil
      end

      UpdateCondFrameForKey(currentKey)
      SafeRefresh()
      SafeEvaluate()
    end)
  end

  -- 技能战斗行2 - 切换按钮现在独立（不互斥）
  condFrame.cond_ability_incombat:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end

    if not this:GetChecked() and not condFrame.cond_ability_outcombat:GetChecked() then
      this:SetChecked(true)
      return
    end

    SetCombatFlag("ability", "in", this:GetChecked())
  end)

  condFrame.cond_ability_outcombat:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end

    if not this:GetChecked() and not condFrame.cond_ability_incombat:GetChecked() then
      this:SetChecked(true)
      return
    end

    SetCombatFlag("ability", "out", this:GetChecked())
  end)


  -- 物品战斗行（独立，至少一个）
  condFrame.cond_item_incombat:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    if not this:GetChecked() and not condFrame.cond_item_outcombat:GetChecked() then
      this:SetChecked(true)
      return
    end
    SetCombatFlag("item", "in", this:GetChecked())
  end)

  condFrame.cond_item_outcombat:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    if not this:GetChecked() and not condFrame.cond_item_incombat:GetChecked() then
      this:SetChecked(true)
      return
    end
    SetCombatFlag("item", "out", this:GetChecked())
  end)

  -- 技能目标行（多选）+ 目标状态行
  local function SaveAbilityTargetsFromUI()
    if not currentKey then
      return
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions = d.conditions or {}
    d.conditions.ability = d.conditions.ability or {}

    local ca = d.conditions.ability

    ca.targetHelp = condFrame.cond_ability_target_help:GetChecked() and true or false
    ca.targetHarm = condFrame.cond_ability_target_harm:GetChecked() and true or false
    ca.targetSelf = condFrame.cond_ability_target_self:GetChecked() and true or false
    ca.targetAlive = condFrame.cond_ability_target_alive:GetChecked() and true or false
    ca.targetDead = condFrame.cond_ability_target_dead:GetChecked() and true or false
  end

  condFrame.cond_ability_target_alive:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end

    if this:GetChecked() then
      -- 选中“活着”时关闭“死亡”
      condFrame.cond_ability_target_dead:SetChecked(false)
    end

    SaveAbilityTargetsFromUI()
    SafeRefresh();
    SafeEvaluate()
  end)

  condFrame.cond_ability_target_dead:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end

    if this:GetChecked() then
      -- 选中“死亡”时关闭“活着”
      condFrame.cond_ability_target_alive:SetChecked(false)
    end

    SaveAbilityTargetsFromUI()
    SafeRefresh();
    SafeEvaluate()
  end)

  condFrame.cond_ability_target_help:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    SaveAbilityTargetsFromUI()
    SafeRefresh();
    SafeEvaluate()
    -- 确保目标距离和类型下拉框重新评估锁定状态
    UpdateCondFrameForKey(currentKey)
  end)

  condFrame.cond_ability_target_harm:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    SaveAbilityTargetsFromUI()
    SafeRefresh();
    SafeEvaluate()
    -- 确保目标距离和类型下拉框重新评估锁定状态
    UpdateCondFrameForKey(currentKey)
  end)

  condFrame.cond_ability_target_self:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    SaveAbilityTargetsFromUI()
    SafeRefresh();
    SafeEvaluate()
    -- 确保目标距离和类型下拉框重新评估锁定状态
    UpdateCondFrameForKey(currentKey)
  end)

  -- 物品目标行（与技能相同逻辑）
  local function SaveItemTargetsFromUI()
    if not currentKey then
      return
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions = d.conditions or {}
    d.conditions.item = d.conditions.item or {}

    local ca = d.conditions.item

    ca.targetHelp = condFrame.cond_item_target_help:GetChecked() and true or false
    ca.targetHarm = condFrame.cond_item_target_harm:GetChecked() and true or false
    ca.targetSelf = condFrame.cond_item_target_self:GetChecked() and true or false
    ca.targetAlive = condFrame.cond_item_target_alive:GetChecked() and true or false
    ca.targetDead = condFrame.cond_item_target_dead:GetChecked() and true or false
  end

  condFrame.cond_item_target_alive:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    if this:GetChecked() then
      condFrame.cond_item_target_dead:SetChecked(false)
    end
    SaveItemTargetsFromUI()
    SafeRefresh();
    SafeEvaluate()
  end)

  condFrame.cond_item_target_dead:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    if this:GetChecked() then
      condFrame.cond_item_target_alive:SetChecked(false)
    end
    SaveItemTargetsFromUI()
    SafeRefresh();
    SafeEvaluate()
  end)

  condFrame.cond_item_target_help:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    SaveItemTargetsFromUI()
    SafeRefresh();
    SafeEvaluate()
    -- 重新评估物品的目标距离和类型下拉框锁定状态
    UpdateCondFrameForKey(currentKey)
  end)

  condFrame.cond_item_target_harm:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    SaveItemTargetsFromUI()
    SafeRefresh();
    SafeEvaluate()
    -- 重新评估物品的目标距离和类型下拉框锁定状态
    UpdateCondFrameForKey(currentKey)
  end)

  condFrame.cond_item_target_self:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    SaveItemTargetsFromUI()
    SafeRefresh();
    SafeEvaluate()
    -- 重新评估物品的目标距离和类型下拉框锁定状态
    UpdateCondFrameForKey(currentKey)
  end)

  -- 物品位置行（已装备 / 在背包中 / 缺失）
  local function SaveItemWhereaboutsFromUI()
    if not currentKey then
      return
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions = d.conditions or {}
    d.conditions.item = d.conditions.item or {}
    local ic = d.conditions.item
    ic.whereEquipped = condFrame.cond_item_where_equipped:GetChecked() and true or false
    ic.whereBag = condFrame.cond_item_where_bag:GetChecked() and true or false
    ic.whereMissing = condFrame.cond_item_where_missing:GetChecked() and true or false
  end

  local function EnforceItemWhereabouts(clicked)
    local eq = condFrame.cond_item_where_equipped:GetChecked()
    local bg = condFrame.cond_item_where_bag:GetChecked()
    local ms = condFrame.cond_item_where_missing:GetChecked()

    -- （不再强制互斥）

    eq = condFrame.cond_item_where_equipped:GetChecked()
    bg = condFrame.cond_item_where_bag:GetChecked()
    ms = condFrame.cond_item_where_missing:GetChecked()

    if not eq and not bg and not ms then
      if clicked then
        clicked:SetChecked(true)
      end
    end
  end

function UpdateItemStacksForMissing()
    if not condFrame or not condFrame.cond_item_where_missing then
      return
    end

    local ms = condFrame.cond_item_where_missing:GetChecked() and true or false

    local function _setCheckState(cb, enabled, clearWhenDisabling)
      if not cb then
        return
      end
      if enabled then
        cb:Enable()
        if cb.text and cb.text.SetTextColor then
          cb.text:SetTextColor(1, 0.82, 0)
        end
      else
        if clearWhenDisabling and cb.SetChecked then
          cb:SetChecked(false)
        end
        cb:Disable()
        if cb.text and cb.text.SetTextColor then
          cb.text:SetTextColor(0.6, 0.6, 0.6)
        end
      end
    end

    -- 如果物品仅标记为缺失：层数条件和“图标文本：层数”不适用。
    local eq = condFrame.cond_item_where_equipped and condFrame.cond_item_where_equipped:GetChecked()
    local bg = condFrame.cond_item_where_bag and condFrame.cond_item_where_bag:GetChecked()

    -- 仅当缺失被选中且已装备和背包都未选中时，才禁用相关功能
    local shouldDisable = (ms and (not eq) and (not bg))

    _setCheckState(condFrame.cond_item_stacks_cb, (not shouldDisable), true)
    _setCheckState(condFrame.cond_item_text_stack, (not shouldDisable), true)

    if shouldDisable then
      if condFrame.cond_item_stacks_comp then
        condFrame.cond_item_stacks_comp:Hide()
      end
      if condFrame.cond_item_stacks_val then
        condFrame.cond_item_stacks_val:Hide()
      end
      if condFrame.cond_item_stacks_val_enter then
        condFrame.cond_item_stacks_val_enter:Hide()
      end
    end

    -- 保持数据库与UI程序化更改同步
    if currentKey then
      local d = EnsureDBEntry(currentKey)
      d.conditions = d.conditions or {}
      d.conditions.item = d.conditions.item or {}

      local stacksOn = (condFrame.cond_item_stacks_cb and condFrame.cond_item_stacks_cb.GetChecked
          and condFrame.cond_item_stacks_cb:GetChecked()) and true or false
      local textOn = (condFrame.cond_item_text_stack and condFrame.cond_item_text_stack.GetChecked
          and condFrame.cond_item_text_stack:GetChecked()) and true or false

      d.conditions.item.stacksEnabled = stacksOn and true or false
      d.conditions.item.textStackCounter = textOn and true or false
    end
  end

  condFrame.cond_item_where_equipped:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    EnforceItemWhereabouts(this)
    SaveItemWhereaboutsFromUI()
    UpdateItemStacksForMissing()
    SafeRefresh();
    SafeEvaluate()
    UpdateCondFrameForKey(currentKey)
  end)

  condFrame.cond_item_where_bag:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    EnforceItemWhereabouts(this)
    SaveItemWhereaboutsFromUI()
    UpdateItemStacksForMissing()
    SafeRefresh();
    SafeEvaluate()
    UpdateCondFrameForKey(currentKey)
  end)

  condFrame.cond_item_where_missing:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    EnforceItemWhereabouts(this)
    SaveItemWhereaboutsFromUI()
    UpdateItemStacksForMissing()
    SafeRefresh();
    SafeEvaluate()
    UpdateCondFrameForKey(currentKey)
  end)

  -- 合成物品的槽位单选行（"---EQUIPPED TRINKET SLOTS---" / "---EQUIPPED WEAPON SLOTS---"）
  local function SaveItemInventoryTrinketFromUI()
    if not currentKey then
      return
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions = d.conditions or {}
    d.conditions.item = d.conditions.item or {}
    local ic = d.conditions.item

    if condFrame.cond_item_inv_trinket1:GetChecked() then
      ic.inventorySlot = "TRINKET1"
    elseif condFrame.cond_item_inv_trinket2:GetChecked() then
      ic.inventorySlot = "TRINKET2"
    elseif condFrame.cond_item_inv_trinket_both:GetChecked() then
      ic.inventorySlot = "TRINKET_BOTH"
    else
      -- 默认/后备
      ic.inventorySlot = "TRINKET_FIRST"
    end
  end

  local function SaveItemInventoryWeaponFromUI()
    if not currentKey then
      return
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions = d.conditions or {}
    d.conditions.item = d.conditions.item or {}
    local ic = d.conditions.item

    if condFrame.cond_item_inv_wep_mainhand:GetChecked() then
      ic.inventorySlot = "MAINHAND"
    elseif condFrame.cond_item_inv_wep_offhand:GetChecked() then
      ic.inventorySlot = "OFFHAND"
    elseif condFrame.cond_item_inv_wep_ammo and condFrame.cond_item_inv_wep_ammo:GetChecked() then
      ic.inventorySlot = "AMMO"
    else
      -- 默认/后备
      ic.inventorySlot = "RANGED"
    end
  end

  local function EnforceInventoryRadio(clicked, group)
    if not clicked then
      return
    end

    if group == "TRINKET" then
      local c1 = condFrame.cond_item_inv_trinket1
      local c2 = condFrame.cond_item_inv_trinket2
      local c3 = condFrame.cond_item_inv_trinket_first
      local c4 = condFrame.cond_item_inv_trinket_both

      if clicked:GetChecked() then
        if clicked ~= c1 then
          c1:SetChecked(false)
        end
        if clicked ~= c2 then
          c2:SetChecked(false)
        end
        if clicked ~= c3 then
          c3:SetChecked(false)
        end
        if clicked ~= c4 then
          c4:SetChecked(false)
        end
      end

      -- 确保至少一个被选中
      if not c1:GetChecked() and not c2:GetChecked() and not c3:GetChecked() and not c4:GetChecked() then
        clicked:SetChecked(true)
      end

    elseif group == "WEAPON" then
      local c1 = condFrame.cond_item_inv_wep_mainhand
      local c2 = condFrame.cond_item_inv_wep_offhand
      local c3 = condFrame.cond_item_inv_wep_ranged
      local c4 = condFrame.cond_item_inv_wep_ammo

      if clicked:GetChecked() then
        if clicked ~= c1 then
          c1:SetChecked(false)
        end
        if clicked ~= c2 then
          c2:SetChecked(false)
        end
        if clicked ~= c3 then
          c3:SetChecked(false)
        end
        if c4 and clicked ~= c4 then
          c4:SetChecked(false)
        end
      end

      -- 确保至少一个被选中
      if not c1:GetChecked() and not c2:GetChecked() and not c3:GetChecked() and (not c4 or not c4:GetChecked()) then
        clicked:SetChecked(true)
      end
    end
  end

  -- 饰品槽位点击
  condFrame.cond_item_inv_trinket1:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    EnforceInventoryRadio(this, "TRINKET")
    SaveItemInventoryTrinketFromUI()
    SafeRefresh();
    SafeEvaluate()
  end)
  condFrame.cond_item_inv_trinket2:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    EnforceInventoryRadio(this, "TRINKET")
    SaveItemInventoryTrinketFromUI()
    SafeRefresh();
    SafeEvaluate()
  end)
  condFrame.cond_item_inv_trinket_first:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    EnforceInventoryRadio(this, "TRINKET")
    SaveItemInventoryTrinketFromUI()
    SafeRefresh();
    SafeEvaluate()
  end)
  condFrame.cond_item_inv_trinket_both:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    EnforceInventoryRadio(this, "TRINKET")
    SaveItemInventoryTrinketFromUI()
    SafeRefresh();
    SafeEvaluate()
  end)

  -- 武器槽位点击
  condFrame.cond_item_inv_wep_mainhand:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    EnforceInventoryRadio(this, "WEAPON")
    SaveItemInventoryWeaponFromUI()
    SafeRefresh();
    SafeEvaluate()
    UpdateCondFrameForKey(currentKey)
  end)
  condFrame.cond_item_inv_wep_offhand:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    EnforceInventoryRadio(this, "WEAPON")
    SaveItemInventoryWeaponFromUI()
    SafeRefresh();
    SafeEvaluate()
    UpdateCondFrameForKey(currentKey)
  end)
  condFrame.cond_item_inv_wep_ranged:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    EnforceInventoryRadio(this, "WEAPON")
    SaveItemInventoryWeaponFromUI()
    SafeRefresh();
    SafeEvaluate()
    UpdateCondFrameForKey(currentKey)
  end)
  condFrame.cond_item_inv_wep_ammo:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    EnforceInventoryRadio(this, "WEAPON")
    SaveItemInventoryWeaponFromUI()
    SafeRefresh();
    SafeEvaluate()
    UpdateCondFrameForKey(currentKey)
  end)


  -- 光环模式（存在 / 缺失；两者都允许）。至少一个必须保持选中。
  local function _SaveAuraModeFromUI()
    local found = condFrame.cond_aura_found:GetChecked() and true or false
    local missing = condFrame.cond_aura_missing:GetChecked() and true or false

    local mode
    if found and missing then
      mode = "both"
    elseif missing then
      mode = "missing"
    else
      mode = "found"
    end

    SetExclusiveAuraFoundMode(mode)
  end

  condFrame.cond_aura_found:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end

    if (not this:GetChecked()) and (not condFrame.cond_aura_missing:GetChecked()) then
      this:SetChecked(true)
    end

    _SaveAuraModeFromUI()

    -- 保持数据库/UI逻辑同步（稍后在“缺失”上灰显拥有者时需要）
    if UpdateCondFrameForKey then
      UpdateCondFrameForKey(currentKey)
    end
    SafeRefresh();
    SafeEvaluate()
  end)

  condFrame.cond_aura_missing:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end

    if (not this:GetChecked()) and (not condFrame.cond_aura_found:GetChecked()) then
      this:SetChecked(true)
    end

    _SaveAuraModeFromUI()

    if UpdateCondFrameForKey then
      UpdateCondFrameForKey(currentKey)
    end
    SafeRefresh();
    SafeEvaluate()
  end)

  -- 光环战斗行2 - 切换按钮（独立）
  condFrame.cond_aura_incombat:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end

    if not this:GetChecked() and not condFrame.cond_aura_outcombat:GetChecked() then
      this:SetChecked(true)
      return
    end

    SetCombatFlag("aura", "in", this:GetChecked())
  end)

  condFrame.cond_aura_outcombat:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end

    if not this:GetChecked() and not condFrame.cond_aura_incombat:GetChecked() then
      this:SetChecked(true)
      return
    end

    SetCombatFlag("aura", "out", this:GetChecked())
  end)

  -- 光环目标行（自身互斥；友善/敌对可组合；至少一个必须选中）
  local function SaveAuraTargets()
    if not currentKey then
      return
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions = d.conditions or {}

    local ca = d.conditions.aura

    ca.targetHelp = condFrame.cond_aura_target_help:GetChecked() and true or false
    ca.targetHarm = condFrame.cond_aura_target_harm:GetChecked() and true or false
    ca.targetSelf = condFrame.cond_aura_onself:GetChecked() and true or false
    ca.targetAlive = condFrame.cond_aura_target_alive:GetChecked() and true or false
    ca.targetDead = condFrame.cond_aura_target_dead:GetChecked() and true or false
  end

  local function EnforceAuraExclusivity(changedBox)
    local h = condFrame.cond_aura_target_help:GetChecked()
    local hm = condFrame.cond_aura_target_harm:GetChecked()
    local s = condFrame.cond_aura_onself:GetChecked()

    -- 自身互斥：如果自身选中，取消选中友善/敌对
    if changedBox == condFrame.cond_aura_onself and s then
      condFrame.cond_aura_target_help:SetChecked(false)
      condFrame.cond_aura_target_harm:SetChecked(false)
    end

    -- 如果友善/敌对被选中时自身已选中，则取消自身
    if (changedBox == condFrame.cond_aura_target_help and condFrame.cond_aura_target_help:GetChecked())
        or (changedBox == condFrame.cond_aura_target_harm and condFrame.cond_aura_target_harm:GetChecked()) then
      if condFrame.cond_aura_onself:GetChecked() then
        condFrame.cond_aura_onself:SetChecked(false)
      end
    end

    -- 至少一个必须保持选中
    h = condFrame.cond_aura_target_help:GetChecked()
    hm = condFrame.cond_aura_target_harm:GetChecked()
    s = condFrame.cond_aura_onself:GetChecked()
    if (not h) and (not hm) and (not s) then
      -- 重新选中刚刚被取消的框
      if changedBox then
        changedBox:SetChecked(true)
      end
    end
  end

  condFrame.cond_aura_target_alive:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    if this:GetChecked() then
      condFrame.cond_aura_target_dead:SetChecked(false)
    end
    SaveAuraTargets()
    SafeRefresh();
    SafeEvaluate()
  end)

  condFrame.cond_aura_target_dead:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    if this:GetChecked() then
      condFrame.cond_aura_target_alive:SetChecked(false)
    end
    SaveAuraTargets()
    SafeRefresh();
    SafeEvaluate()
  end)

  condFrame.cond_aura_target_help:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    EnforceAuraExclusivity(this)
    SaveAuraTargets()
    SafeRefresh();
    SafeEvaluate()
    UpdateCondFrameForKey(currentKey)
  end)

  condFrame.cond_aura_target_harm:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    EnforceAuraExclusivity(this)
    SaveAuraTargets()
    SafeRefresh();
    SafeEvaluate()
    UpdateCondFrameForKey(currentKey)
  end)

  condFrame.cond_aura_onself:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    EnforceAuraExclusivity(this)
    SaveAuraTargets()
    SafeRefresh();
    SafeEvaluate()
    UpdateCondFrameForKey(currentKey)
  end)

  -- 光环拥有者标志（“我的光环” / “他人的光环”）+ 依赖控件。
  local function _SetAuraCheckEnabled(cb, enabled, clearWhenDisabling)
    if not cb then
      return
    end

    if enabled then
      if cb.Enable then
        cb:Enable()
      end
      if cb.text and cb.text.SetTextColor then
        cb.text:SetTextColor(1, 0.82, 0)
      end
    else
      if clearWhenDisabling and cb.SetChecked then
        cb:SetChecked(false)
      end
      if cb.Disable then
        cb:Disable()
      end
      if cb.text and cb.text.SetTextColor then
        cb.text:SetTextColor(0.6, 0.6, 0.6)
      end
    end
  end

  local function AuraOwner_UpdateDependentChecks()
    if not condFrame then
      return
    end

    local mine = condFrame.cond_aura_mine
        and condFrame.cond_aura_mine.GetChecked
        and condFrame.cond_aura_mine:GetChecked()
    local others = condFrame.cond_aura_others
        and condFrame.cond_aura_others.GetChecked
        and condFrame.cond_aura_others:GetChecked()

    local ownerActive = (mine or others) and true or false

    local rem = condFrame.cond_aura_remaining_cb
    local textR = condFrame.cond_aura_text_time

    -- 保持数据库与UI程序化更改同步（SetChecked不会触发OnClick）
    if currentKey then
      local d = EnsureDBEntry(currentKey)
      d.conditions = d.conditions or {}
      d.conditions.aura = d.conditions.aura or {}

      local remOn = (rem and rem.GetChecked and rem:GetChecked()) and true or false
      local textOn = (textR and textR.GetChecked and textR:GetChecked()) and true or false

      d.conditions.aura.remainingEnabled = remOn or false
      d.conditions.aura.textTimeRemaining = textOn or false
    end
  end

  local function AuraOwner_EnforceExclusivity(changed)
    if not condFrame then
      return
    end
    local mine = condFrame.cond_aura_mine
    local others = condFrame.cond_aura_others

    if not mine or not others then
      AuraOwner_UpdateDependentChecks()
      return
    end

    if changed == mine and mine:GetChecked() then
      others:SetChecked(false)
    elseif changed == others and others:GetChecked() then
      mine:SetChecked(false)
    end

    -- “两者都不”是允许的；这里不再强制。

    AuraOwner_UpdateDependentChecks()
  end

  local function SaveAuraOwnerFlags(changed)
    if not currentKey then
      return
    end

    local d = EnsureDBEntry(currentKey)
    d.conditions = d.conditions or {}
    d.conditions.aura = d.conditions.aura or {}

    local mine = (condFrame.cond_aura_mine and condFrame.cond_aura_mine:GetChecked()) and true or false
    local others = (condFrame.cond_aura_others and condFrame.cond_aura_others:GetChecked()) and true or false

    -- 数据库层严格互斥：如果两者都为真，则仅保留刚点击的那个。
    if mine and others then
      if changed == condFrame.cond_aura_mine then
        others = false
        if condFrame.cond_aura_others and condFrame.cond_aura_others.SetChecked then
          condFrame.cond_aura_others:SetChecked(false)
        end
      elseif changed == condFrame.cond_aura_others then
        mine = false
        if condFrame.cond_aura_mine and condFrame.cond_aura_mine.SetChecked then
          condFrame.cond_aura_mine:SetChecked(false)
        end
      else
        -- 后备：优先“我的光环”
        others = false
        if condFrame.cond_aura_others and condFrame.cond_aura_others.SetChecked then
          condFrame.cond_aura_others:SetChecked(false)
        end
      end
    end

    d.conditions.aura.onlyMine = mine or nil
    d.conditions.aura.onlyOthers = others or nil

    -- 每次拥有者标志更改时也更新剩余/文本检查。
    AuraOwner_UpdateDependentChecks()
  end


  -- 光环剩余切换
  condFrame.cond_aura_remaining_cb:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions = d.conditions or {}
    d.conditions.aura = d.conditions.aura or {}
    d.conditions.aura.remainingEnabled = this:GetChecked() and true or false
    UpdateCondFrameForKey(currentKey)
    SafeRefresh()
    SafeEvaluate()
  end)

  -- 连接光环拥有者复选框（“我的光环” / “他人的光环”）
  if condFrame.cond_aura_mine then
    condFrame.cond_aura_mine:SetScript("OnClick", function()
      if not currentKey then
        this:SetChecked(false)
        return
      end

      -- 强制互斥状态并更新剩余/文本逻辑
      AuraOwner_EnforceExclusivity(this)
      SaveAuraOwnerFlags(this)

      SafeRefresh();
      SafeEvaluate()

      if UpdateCondFrameForKey then
        UpdateCondFrameForKey(currentKey)
      end
    end)
  end

  if condFrame.cond_aura_others then
    condFrame.cond_aura_others:SetScript("OnClick", function()
      if not currentKey then
        this:SetChecked(false)
        return
      end

      -- 强制互斥状态并更新剩余/文本逻辑
      AuraOwner_EnforceExclusivity(this)
      SaveAuraOwnerFlags(this)

      SafeRefresh();
      SafeEvaluate()

      if UpdateCondFrameForKey then
        UpdateCondFrameForKey(currentKey)
      end
    end)
  end

  -- 光环层数切换
  condFrame.cond_aura_stacks_cb:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions = d.conditions or {}
    d.conditions.aura = d.conditions.aura or {}
    d.conditions.aura.stacksEnabled = this:GetChecked() and true or false
    UpdateCondFrameForKey(currentKey)
    SafeRefresh()
    SafeEvaluate()
  end)


  -- 光环发光 / 灰色
  condFrame.cond_aura_glow:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions = d.conditions or {}
    d.conditions.aura = d.conditions.aura or {}
    d.conditions.aura.glow = this:GetChecked() and true or false
    UpdateCondFrameForKey(currentKey)
    SafeRefresh()
    SafeEvaluate()
  end)

  condFrame.cond_aura_greyscale:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions = d.conditions or {}
    d.conditions.aura = d.conditions.aura or {}
    d.conditions.aura.greyscale = this:GetChecked() and true or false
    UpdateCondFrameForKey(currentKey)
    SafeRefresh()
    SafeEvaluate()
  end)

  condFrame.cond_aura_fade:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions = d.conditions or {}
    d.conditions.aura = d.conditions.aura or {}
    d.conditions.aura.fade = this:GetChecked() and true or false
    if d.conditions.aura.fade and not d.conditions.aura.fadeAlpha then
      d.conditions.aura.fadeAlpha = 0
    end
    UpdateCondFrameForKey(currentKey)
    SafeRefresh()
    SafeEvaluate()
  end)

  local function SaveAuraFadeAlpha()
    if not currentKey then return end
    local d = EnsureDBEntry(currentKey)
    d.conditions = d.conditions or {}
    d.conditions.aura = d.conditions.aura or {}
    d.conditions.aura.fadeAlpha = _ParseFadeAlphaFromBox(condFrame.cond_aura_fade_slider)
    _NormalizeFadeBox(condFrame.cond_aura_fade_slider, d.conditions.aura.fadeAlpha)
    SafeRefresh()
    SafeEvaluate()
  end
  condFrame.cond_aura_fade_slider:SetScript("OnEnterPressed", function() SaveAuraFadeAlpha(); this:ClearFocus() end)
  condFrame.cond_aura_fade_slider:SetScript("OnEditFocusLost", SaveAuraFadeAlpha)
  condFrame.cond_aura_fade_slider:SetScript("OnEscapePressed", function() this:ClearFocus() end)

  -- === 连击点数启用切换 ===
  condFrame.cond_ability_cp_cb:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    local d = EnsureDBEntry(currentKey);
    d.conditions.ability = d.conditions.ability or {}
    d.conditions.ability.cpEnabled = this:GetChecked() and true or false
    UpdateCondFrameForKey(currentKey);
    SafeRefresh();
    SafeEvaluate()
  end)
  condFrame.cond_aura_cp_cb:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    local d = EnsureDBEntry(currentKey);
    d.conditions.aura = d.conditions.aura or {}
    d.conditions.aura.cpEnabled = this:GetChecked() and true or false
    UpdateCondFrameForKey(currentKey);
    SafeRefresh();
    SafeEvaluate()
  end)
  condFrame.cond_item_cp_cb:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    local d = EnsureDBEntry(currentKey);
    d.conditions.item = d.conditions.item or {}
    d.conditions.item.cpEnabled = this:GetChecked() and true or false
    UpdateCondFrameForKey(currentKey);
    SafeRefresh();
    SafeEvaluate()
  end)

  -- === HP选择器（互斥，相同X位置的控件） ===
  local function _AbilityHP_Update(which)
    local d = EnsureDBEntry(currentKey);
    d.conditions.ability = d.conditions.ability or {}
    if which == "my" then
      condFrame.cond_ability_hp_tgt:SetChecked(false)
      d.conditions.ability.hpMode = "my"
    elseif which == "tgt" then
      condFrame.cond_ability_hp_my:SetChecked(false)
      d.conditions.ability.hpMode = "target"
    else
      d.conditions.ability.hpMode = nil
    end
    UpdateCondFrameForKey(currentKey);
    SafeRefresh();
    SafeEvaluate()
  end
  condFrame.cond_ability_hp_my:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    if this:GetChecked() then
      _AbilityHP_Update("my")
    else
      _AbilityHP_Update(nil)
    end
  end)
  condFrame.cond_ability_hp_tgt:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    if this:GetChecked() then
      _AbilityHP_Update("tgt")
    else
      _AbilityHP_Update(nil)
    end
  end)

  local function _AuraHP_Update(which)
    local d = EnsureDBEntry(currentKey);
    d.conditions.aura = d.conditions.aura or {}
    if which == "my" then
      condFrame.cond_aura_hp_tgt:SetChecked(false)
      d.conditions.aura.hpMode = "my"
    elseif which == "tgt" then
      condFrame.cond_aura_hp_my:SetChecked(false)
      d.conditions.aura.hpMode = "target"
    else
      d.conditions.aura.hpMode = nil
    end
    UpdateCondFrameForKey(currentKey);
    SafeRefresh();
    SafeEvaluate()
  end
  condFrame.cond_aura_hp_my:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    if this:GetChecked() then
      _AuraHP_Update("my")
    else
      _AuraHP_Update(nil)
    end
  end)
  condFrame.cond_aura_hp_tgt:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    if this:GetChecked() then
      _AuraHP_Update("tgt")
    else
      _AuraHP_Update(nil)
    end
  end)

  local function _ItemHP_Update(which)
    local d = EnsureDBEntry(currentKey);
    d.conditions.item = d.conditions.item or {}
    if which == "my" then
      condFrame.cond_item_hp_tgt:SetChecked(false)
      d.conditions.item.hpMode = "my"
    elseif which == "tgt" then
      condFrame.cond_item_hp_my:SetChecked(false)
      d.conditions.item.hpMode = "target"
    else
      d.conditions.item.hpMode = nil
    end
    UpdateCondFrameForKey(currentKey);
    SafeRefresh();
    SafeEvaluate()
  end
  condFrame.cond_item_hp_my:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    if this:GetChecked() then
      _ItemHP_Update("my")
    else
      _ItemHP_Update(nil)
    end
  end)
  condFrame.cond_item_hp_tgt:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    if this:GetChecked() then
      _ItemHP_Update("tgt")
    else
      _ItemHP_Update(nil)
    end
  end)

  -- === 技能滑块额外选项 ===
  condFrame.cond_ability_slider_glow:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    local d = EnsureDBEntry(currentKey);
    d.conditions.ability = d.conditions.ability or {}
    d.conditions.ability.sliderGlow = this:GetChecked() and true or false
    SafeRefresh();
    SafeEvaluate()
  end)
  condFrame.cond_ability_slider_grey:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    local d = EnsureDBEntry(currentKey);
    d.conditions.ability = d.conditions.ability or {}
    d.conditions.ability.sliderGrey = this:GetChecked() and true or false
    SafeRefresh();
    SafeEvaluate()
  end)

  -- === 文本标志（技能/光环） ===
  condFrame.cond_ability_text_time:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    local d = EnsureDBEntry(currentKey);
    d.conditions.ability = d.conditions.ability or {}
    d.conditions.ability.textTimeRemaining = this:GetChecked() and true or false
    SafeRefresh();
    SafeEvaluate()
  end)
  condFrame.cond_aura_text_time:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    local d = EnsureDBEntry(currentKey);
    d.conditions.aura = d.conditions.aura or {}
    d.conditions.aura.textTimeRemaining = this:GetChecked() and true or false
    UpdateCondFrameForKey(currentKey)
    SafeRefresh();
    SafeEvaluate()
  end)
  condFrame.cond_aura_text_stack:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    local d = EnsureDBEntry(currentKey);
    d.conditions.aura = d.conditions.aura or {}
    d.conditions.aura.textStackCounter = this:GetChecked() and true or false
    UpdateCondFrameForKey(currentKey)
    SafeRefresh();
    SafeEvaluate()
  end)

  if condFrame.cond_aura_trackpet then
    condFrame.cond_aura_trackpet:SetScript("OnClick", function()
      if not currentKey then
        this:SetChecked(false)
        return
      end
      local d = EnsureDBEntry(currentKey);
      d.conditions.aura = d.conditions.aura or {}
      d.conditions.aura.trackpet = this:GetChecked() and true or false
      if UpdateCondFrameForKey then
        UpdateCondFrameForKey(currentKey)
      end
      SafeRefresh();
      SafeEvaluate()
    end)
  end

  -- === 光环资源切换 ===
  condFrame.cond_aura_power:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    local d = EnsureDBEntry(currentKey);
    d.conditions.aura = d.conditions.aura or {}
    d.conditions.aura.powerEnabled = this:GetChecked() and true or false
    UpdateCondFrameForKey(currentKey);
    SafeRefresh();
    SafeEvaluate()
  end)

  -- 物品资源切换
  condFrame.cond_item_power:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    local d = EnsureDBEntry(currentKey);
    d.conditions.item = d.conditions.item or {}
    d.conditions.item.powerEnabled = this:GetChecked() and true or false
    UpdateCondFrameForKey(currentKey);
    SafeRefresh();
    SafeEvaluate()
  end)

  -- 物品剩余切换
  condFrame.cond_item_remaining_cb:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    local d = EnsureDBEntry(currentKey);
    d.conditions.item = d.conditions.item or {}
    d.conditions.item.remainingEnabled = this:GetChecked() and true or false
    UpdateCondFrameForKey(currentKey);
    SafeRefresh();
    SafeEvaluate()
  end)

  -- 物品层数切换
  condFrame.cond_item_stacks_cb:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    local enabled = this:GetChecked() and true or false
    local d = EnsureDBEntry(currentKey);
    d.conditions.item = d.conditions.item or {}
    d.conditions.item.stacksEnabled = enabled

    if enabled then
      condFrame.cond_item_stacks_comp:Show()
      condFrame.cond_item_stacks_val:Show()
      condFrame.cond_item_stacks_val_enter:Show()
    else
      condFrame.cond_item_stacks_comp:Hide()
      condFrame.cond_item_stacks_val:Hide()
      condFrame.cond_item_stacks_val_enter:Hide()
    end

    UpdateCondFrameForKey(currentKey);
    SafeRefresh();
    SafeEvaluate()
  end)

  -- 物品文本：层数计数器
  condFrame.cond_item_text_stack:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    local d = EnsureDBEntry(currentKey);
    d.conditions.item = d.conditions.item or {}
    d.conditions.item.textStackCounter = this:GetChecked() and true or false
    UpdateCondFrameForKey(currentKey)
    SafeRefresh();
    SafeEvaluate()
  end)

  -- 物品发光/灰色
  condFrame.cond_item_glow:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    local d = EnsureDBEntry(currentKey);
    d.conditions.item = d.conditions.item or {}
    d.conditions.item.glow = this:GetChecked() and true or false
    UpdateCondFrameForKey(currentKey);
    SafeRefresh();
    SafeEvaluate()
  end)
  condFrame.cond_item_greyscale:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    local d = EnsureDBEntry(currentKey);
    d.conditions.item = d.conditions.item or {}
    d.conditions.item.greyscale = this:GetChecked() and true or false
    UpdateCondFrameForKey(currentKey);
    SafeRefresh();
    SafeEvaluate()
  end)
  condFrame.cond_item_fade:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    local d = EnsureDBEntry(currentKey);
    d.conditions.item = d.conditions.item or {}
    d.conditions.item.fade = this:GetChecked() and true or false
    if d.conditions.item.fade and not d.conditions.item.fadeAlpha then
      d.conditions.item.fadeAlpha = 0
    end
    UpdateCondFrameForKey(currentKey);
    SafeRefresh();
    SafeEvaluate()
  end)

  local function SaveItemFadeAlpha()
    if not currentKey then return end
    local d = EnsureDBEntry(currentKey)
    d.conditions.item = d.conditions.item or {}
    d.conditions.item.fadeAlpha = _ParseFadeAlphaFromBox(condFrame.cond_item_fade_slider)
    _NormalizeFadeBox(condFrame.cond_item_fade_slider, d.conditions.item.fadeAlpha)
    SafeRefresh()
    SafeEvaluate()
  end
  condFrame.cond_item_fade_slider:SetScript("OnEnterPressed", function() SaveItemFadeAlpha(); this:ClearFocus() end)
  condFrame.cond_item_fade_slider:SetScript("OnEditFocusLost", SaveItemFadeAlpha)
  condFrame.cond_item_fade_slider:SetScript("OnEscapePressed", function() this:ClearFocus() end)


  -- 物品文本：剩余时间
  condFrame.cond_item_text_time:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    local d = EnsureDBEntry(currentKey);
    d.conditions.item = d.conditions.item or {}
    d.conditions.item.textTimeRemaining = this:GetChecked() and true or false
    UpdateCondFrameForKey(currentKey)
    SafeRefresh();
    SafeEvaluate()
  end)

  local function _SaveAuraTextOverride(which)
    if not currentKey then
      return
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions = d.conditions or {}
    d.conditions.aura = d.conditions.aura or {}
    local ca = d.conditions.aura
    local eb = (which == "stack") and condFrame.cond_aura_text_stack_override or condFrame.cond_aura_text_time_override
    local txt = ""
    if eb and eb.GetText then
      txt = eb:GetText() or ""
      txt = string.gsub(txt, "^%s*(.-)%s*$", "%1")
      if txt ~= "" and (not tonumber(txt)) then
        txt = AuraCond_TitleCase(txt)
      end
    end
    if which == "stack" then
      ca.stackOverride = (txt ~= "") and txt or nil
    else
      ca.remOverride = (txt ~= "") and txt or nil
    end
    UpdateCondFrameForKey(currentKey)
    SafeRefresh();
    SafeEvaluate()
  end

  if condFrame.cond_aura_text_time_override then
    condFrame.cond_aura_text_time_override:SetScript("OnEnterPressed", function()
      _SaveAuraTextOverride("rem")
      this:ClearFocus()
    end)
    condFrame.cond_aura_text_time_override:SetScript("OnEscapePressed", function()
      this:ClearFocus()
      UpdateCondFrameForKey(currentKey)
    end)
  end
  if condFrame.cond_aura_text_stack_override then
    condFrame.cond_aura_text_stack_override:SetScript("OnEnterPressed", function()
      _SaveAuraTextOverride("stack")
      this:ClearFocus()
    end)
    condFrame.cond_aura_text_stack_override:SetScript("OnEscapePressed", function()
      this:ClearFocus()
      UpdateCondFrameForKey(currentKey)
    end)
  end

  local function _SaveItemTextOverride()
    if not currentKey then
      return
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions = d.conditions or {}
    d.conditions.item = d.conditions.item or {}
    local ci = d.conditions.item
    local txt = ""
    local eb = condFrame.cond_item_text_time_override
    if eb and eb.GetText then
      txt = eb:GetText() or ""
      txt = string.gsub(txt, "^%s*(.-)%s*$", "%1")
      if txt ~= "" and (not tonumber(txt)) then
        txt = AuraCond_TitleCase(txt)
      end
    end
    ci.remOverride = (txt ~= "") and txt or nil
    UpdateCondFrameForKey(currentKey)
    SafeRefresh();
    SafeEvaluate()
  end

  if condFrame.cond_item_text_time_override then
    condFrame.cond_item_text_time_override:SetScript("OnEnterPressed", function()
      _SaveItemTextOverride()
      this:ClearFocus()
    end)
    condFrame.cond_item_text_time_override:SetScript("OnEscapePressed", function()
      this:ClearFocus()
      UpdateCondFrameForKey(currentKey)
    end)
  end

  -- 下拉框初始化器
  local function InitComparatorDD(ddframe, commitFunc)
    UIDropDownMenu_Initialize(ddframe, function(frame, level, menuList)
      local info
      local choices = { ">=", "<=", "==" }
      for _, c in ipairs(choices) do
        local picked = c
        info = {}
        info.text = picked
        info.value = picked
        info.func = function(button)
          local val = (button and button.value) or picked
          if commitFunc then
            pcall(commitFunc, val)
          end
          UIDropDownMenu_SetSelectedValue(ddframe, val)
          UIDropDownMenu_SetText(val, ddframe)
          CloseDropDownMenus()
        end
        info.checked = (UIDropDownMenu_GetSelectedValue(ddframe) == picked)
        UIDropDownMenu_AddButton(info)
      end
    end)
  end

  ----------------------------------------------------------------
  -- 目标距离与类型下拉框（共享列表）
  ----------------------------------------------------------------
  local distanceChoices = { "任意", "范围内", "范围外", "背后", "正面", "背后且在范围内", "正面且在范围内" }
  local distanceNeedsUnitXP = {
    ["背后"] = true,
    ["正面"] = true,
    ["背后且在范围内"] = true,
    ["正面且在范围内"] = true
  }

  local function _HasUnitXP()
    if type(UnitXP) ~= "function" then
      return false
    end
    local ok = pcall(UnitXP, "nop", "nop")
    return ok == true
  end

  local unitTypeChoices = {
    "任意", "玩家", "NPC", "首领", "非首领",
    "1. 人型生物", "2. 野兽", "3. 龙类", "4. 亡灵",
    "5. 恶魔", "6. 巨人", "7. 机械", "8. 元素生物",
    -- 复合版本（类似形态，添加常见组合）
    "复合: 1+2",
    "复合: 1+4",
    "复合: 1+2+3",
    "复合: 2+3",
    "复合: 4+5",
    "复合: 5+8"
  }

  local function _CommitTargetField(typeKey, field, picked)
    if not currentKey then
      return
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions = d.conditions or {}
    d.conditions[typeKey] = d.conditions[typeKey] or {}
    -- 如果是“任意”，则存储nil以保持数据库简洁
    if picked == "任意" then
      d.conditions[typeKey][field] = nil
    else
      d.conditions[typeKey][field] = picked
    end
    SafeRefresh();
    SafeEvaluate()
    UpdateCondFrameForKey(currentKey)
  end

  local function InitSimpleListDD(dd, choices, typeKey, field, placeholder)
    if not dd then
      return
    end
    ClearDropdown(dd)
    UIDropDownMenu_Initialize(dd, function(frame, level, menuList)
      local info
      local hasUnitXP = _HasUnitXP()
      for _, txt in ipairs(choices) do
        local picked = txt
        info = {}
        local requiresUnitXP = (field == "targetDistance") and (distanceNeedsUnitXP[picked] == true)
        if requiresUnitXP and (not hasUnitXP) then
          info.text = "|cff808080Req.UnitXP: " .. txt .. "|r"
          info.disabled = true
        else
          info.text = txt
        end
        info.value = txt
        info.func = function(button)
          if requiresUnitXP and (not hasUnitXP) then
            return
          end
          local val = (button and button.value) or picked
          -- 更新控件文本/选择
          if UIDropDownMenu_SetSelectedValue then
            UIDropDownMenu_SetSelectedValue(dd, val)
          end
          if UIDropDownMenu_SetText then
            UIDropDownMenu_SetText(val, dd)
          end
          _GoldifyDD(dd)
          -- 持久化到数据库并刷新逻辑
          _CommitTargetField(typeKey, field, val)
          -- 像其他下拉框一样关闭菜单
          if CloseDropDownMenus then
            CloseDropDownMenus()
          end
        end
        -- 这些列表没有勾选标记
        info.notCheckable = true
        UIDropDownMenu_AddButton(info)
      end
    end)

    -- 初始占位文本
    if UIDropDownMenu_SetSelectedValue then
      pcall(UIDropDownMenu_SetSelectedValue, dd, nil)
    end
    if UIDropDownMenu_SetText and placeholder then
      -- 占位文本
      pcall(UIDropDownMenu_SetText, placeholder, dd)
    end
    _WhiteifyDDText(dd)
  end

  -- 技能DD
  InitSimpleListDD(condFrame.cond_ability_distanceDD, distanceChoices, "ability", "targetDistance", "距离")
  InitSimpleListDD(condFrame.cond_ability_unitTypeDD, unitTypeChoices, "ability", "targetUnitType", "单位类型")

  -- 光环DD
  InitSimpleListDD(condFrame.cond_aura_distanceDD, distanceChoices, "aura", "targetDistance", "距离")
  InitSimpleListDD(condFrame.cond_aura_unitTypeDD, unitTypeChoices, "aura", "targetUnitType", "单位类型")

  -- 物品DD
  InitSimpleListDD(condFrame.cond_item_distanceDD, distanceChoices, "item", "targetDistance", "距离")
  InitSimpleListDD(condFrame.cond_item_unitTypeDD, unitTypeChoices, "item", "targetUnitType", "单位类型")

  -- 滑块方向DD
  UIDropDownMenu_Initialize(condFrame.cond_ability_slider_dir, function(frame, level, menuList)
    local info
    local choices = { "左", "右", "居中", "上", "下" }
    for _, c in ipairs(choices) do
      local picked = c
      info = {}
      info.text = picked
      info.value = picked
      info.func = function(button)
        local val = (button and button.value) or picked
        if not currentKey then
          return
        end
        local d = EnsureDBEntry(currentKey)
        d.conditions = d.conditions or {}
        d.conditions.ability = d.conditions.ability or {}
        d.conditions.ability.sliderDir = val
        UIDropDownMenu_SetSelectedValue(condFrame.cond_ability_slider_dir, val)
        UIDropDownMenu_SetText(val, condFrame.cond_ability_slider_dir)
        _GoldifyDD(condFrame.cond_ability_slider_dir)
        CloseDropDownMenus()
        SafeRefresh()
        SafeEvaluate()
      end
      info.checked = (UIDropDownMenu_GetSelectedValue(condFrame.cond_ability_slider_dir) == picked)
      UIDropDownMenu_AddButton(info)
    end
  end)

  -- 连接比较器init与写入数据库的提交函数
  InitComparatorDD(condFrame.cond_ability_power_comp, function(picked)
    if not currentKey then
      return
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions = d.conditions or {}
    d.conditions.ability = d.conditions.ability or {}
    d.conditions.ability.powerComp = picked
    SafeRefresh()
    SafeEvaluate()
  end)

  InitComparatorDD(condFrame.cond_ability_remaining_comp, function(picked)
    if not currentKey then
      return
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions = d.conditions or {}
    d.conditions.ability = d.conditions.ability or {}
    d.conditions.ability.remainingComp = picked
    SafeRefresh()
    SafeEvaluate()
  end)

  InitComparatorDD(condFrame.cond_aura_remaining_comp, function(picked)
    if not currentKey then
      return
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions = d.conditions or {}
    d.conditions.aura = d.conditions.aura or {}
    d.conditions.aura.remainingComp = picked
    SafeRefresh()
    SafeEvaluate()
  end)

  InitComparatorDD(condFrame.cond_aura_stacks_comp, function(picked)
    if not currentKey then
      return
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions = d.conditions or {}
    d.conditions.aura = d.conditions.aura or {}
    d.conditions.aura.stacksComp = picked
    SafeRefresh()
    SafeEvaluate()
  end)

  InitComparatorDD(condFrame.cond_ability_cp_comp, function(picked)
    if not currentKey then
      return
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions.ability = d.conditions.ability or {}
    d.conditions.ability.cpComp = picked
    SafeRefresh();
    SafeEvaluate()
  end)
  InitComparatorDD(condFrame.cond_aura_cp_comp, function(picked)
    if not currentKey then
      return
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions.aura = d.conditions.aura or {}
    d.conditions.aura.cpComp = picked
    SafeRefresh();
    SafeEvaluate()
  end)
  InitComparatorDD(condFrame.cond_item_cp_comp, function(picked)
    if not currentKey then
      return
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions.item = d.conditions.item or {}
    d.conditions.item.cpComp = picked
    SafeRefresh();
    SafeEvaluate()
  end)

  -- HP比较器
  InitComparatorDD(condFrame.cond_ability_hp_comp, function(picked)
    if not currentKey then
      return
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions.ability = d.conditions.ability or {}
    d.conditions.ability.hpComp = picked
    SafeRefresh();
    SafeEvaluate()
  end)
  InitComparatorDD(condFrame.cond_aura_hp_comp, function(picked)
    if not currentKey then
      return
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions.aura = d.conditions.aura or {}
    d.conditions.aura.hpComp = picked
    SafeRefresh();
    SafeEvaluate()
  end)
  InitComparatorDD(condFrame.cond_item_hp_comp, function(picked)
    if not currentKey then
      return
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions.item = d.conditions.item or {}
    d.conditions.item.hpComp = picked
    SafeRefresh();
    SafeEvaluate()
  end)

  -- 光环资源比较器
  InitComparatorDD(condFrame.cond_aura_power_comp, function(picked)
    if not currentKey then
      return
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions.aura = d.conditions.aura or {}
    d.conditions.aura.powerComp = picked
    SafeRefresh();
    SafeEvaluate()
  end)

  -- 物品资源比较器
  InitComparatorDD(condFrame.cond_item_power_comp, function(picked)
    if not currentKey then
      return
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions.item = d.conditions.item or {}
    d.conditions.item.powerComp = picked
    SafeRefresh();
    SafeEvaluate()
  end)

  -- 物品剩余比较器
  InitComparatorDD(condFrame.cond_item_remaining_comp, function(picked)
    if not currentKey then
      return
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions.item = d.conditions.item or {}
    d.conditions.item.remainingComp = picked
    SafeRefresh();
    SafeEvaluate()
  end)

  -- 物品层数比较器
  InitComparatorDD(condFrame.cond_item_stacks_comp, function(picked)
    if not currentKey then
      return
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions.item = d.conditions.item or {}
    d.conditions.item.stacksComp = picked
    SafeRefresh();
    SafeEvaluate()
  end)

  -- 编辑框提交处理器（回车 / 失去焦点）
  -- 技能连击点数值
  condFrame.cond_ability_cp_val:SetScript("OnEnterPressed", function()
    if not currentKey then
      return
    end
    local v = tonumber(this:GetText())
    if not v then
      local d = EnsureDBEntry(currentKey)
      this:SetText(tostring((d.conditions.ability and d.conditions.ability.cpVal) or 0))
      return
    end
    if v < 0 then
      v = 0
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions.ability = d.conditions.ability or {}
    d.conditions.ability.cpVal = v
    SafeRefresh();
    SafeEvaluate()
    UpdateCondFrameForKey(currentKey)
    if this.ClearFocus then
      this:ClearFocus()
    end
  end)
  do
    local _guard = false
    condFrame.cond_ability_cp_val:SetScript("OnEditFocusLost", function()
      if _guard then
        return
      end ;
      _guard = true
      this:GetScript("OnEnterPressed")()
      _guard = false
    end)
  end

  -- 光环连击点数值
  condFrame.cond_aura_cp_val:SetScript("OnEnterPressed", function()
    if not currentKey then
      return
    end
    local v = tonumber(this:GetText())
    if not v then
      local d = EnsureDBEntry(currentKey)
      this:SetText(tostring((d.conditions.aura and d.conditions.aura.cpVal) or 0))
      return
    end
    if v < 0 then
      v = 0
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions.aura = d.conditions.aura or {}
    d.conditions.aura.cpVal = v
    SafeRefresh();
    SafeEvaluate()
    UpdateCondFrameForKey(currentKey)
    if this.ClearFocus then
      this:ClearFocus()
    end
  end)
  do
    local _guard = false
    condFrame.cond_aura_cp_val:SetScript("OnEditFocusLost", function()
      if _guard then
        return
      end ;
      _guard = true
      this:GetScript("OnEnterPressed")()
      _guard = false
    end)
  end

  -- 技能生命值百分比
  condFrame.cond_ability_hp_val:SetScript("OnEnterPressed", function()
    if not currentKey then
      return
    end
    local v = tonumber(this:GetText())
    if not v then
      local d = EnsureDBEntry(currentKey)
      this:SetText(tostring((d.conditions.ability and d.conditions.ability.hpVal) or 0))
      return
    end
    if v < 0 then
      v = 0
    end
    if v > 100 then
      v = 100
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions.ability = d.conditions.ability or {}
    d.conditions.ability.hpVal = v
    SafeRefresh();
    SafeEvaluate()
    UpdateCondFrameForKey(currentKey)
    if this.ClearFocus then
      this:ClearFocus()
    end
  end)
  do
    local _guard = false
    condFrame.cond_ability_hp_val:SetScript("OnEditFocusLost", function()
      if _guard then
        return
      end ;
      _guard = true
      this:GetScript("OnEnterPressed")()
      _guard = false
    end)
  end

  -- 光环生命值百分比
  condFrame.cond_aura_hp_val:SetScript("OnEnterPressed", function()
    if not currentKey then
      return
    end
    local v = tonumber(this:GetText())
    if not v then
      local d = EnsureDBEntry(currentKey)
      this:SetText(tostring((d.conditions.aura and d.conditions.aura.hpVal) or 0))
      return
    end
    if v < 0 then
      v = 0
    end
    if v > 100 then
      v = 100
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions.aura = d.conditions.aura or {}
    d.conditions.aura.hpVal = v
    SafeRefresh();
    SafeEvaluate()
    UpdateCondFrameForKey(currentKey)
    if this.ClearFocus then
      this:ClearFocus()
    end
  end)
  do
    local _guard = false
    condFrame.cond_aura_hp_val:SetScript("OnEditFocusLost", function()
      if _guard then
        return
      end ;
      _guard = true
      this:GetScript("OnEnterPressed")()
      _guard = false
    end)
  end

  -- 光环资源值（百分比）
  condFrame.cond_aura_power_val:SetScript("OnEnterPressed", function()
    if not currentKey then
      return
    end
    local v = tonumber(this:GetText())
    if not v then
      local d = EnsureDBEntry(currentKey)
      this:SetText(tostring((d.conditions.aura and d.conditions.aura.powerVal) or 0))
      return
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions.aura = d.conditions.aura or {}
    d.conditions.aura.powerVal = v
    SafeRefresh();
    SafeEvaluate()
    UpdateCondFrameForKey(currentKey)
    if this.ClearFocus then
      this:ClearFocus()
    end
  end)
  do
    local _guard = false
    condFrame.cond_aura_power_val:SetScript("OnEditFocusLost", function()
      if _guard then
        return
      end ;
      _guard = true
      this:GetScript("OnEnterPressed")()
      _guard = false
    end)
  end

  condFrame.cond_ability_power_val:SetScript("OnEnterPressed", function()
    if not currentKey then
      return
    end
    local v = tonumber(this:GetText())
    local minv, maxv = -999999, 999999
    if not v then
      local d = EnsureDBEntry(currentKey)
      d.conditions = d.conditions or {}
      d.conditions.ability = d.conditions.ability or {}
      this:SetText(tostring(d.conditions.ability.powerVal or 0))
      return
    end
    if v < minv then
      v = minv
    end
    if v > maxv then
      v = maxv
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions = d.conditions or {}
    d.conditions.ability = d.conditions.ability or {}
    d.conditions.ability.powerVal = v
    SafeRefresh()
    SafeEvaluate()
    UpdateCondFrameForKey(currentKey)
    if this.ClearFocus then
      this:ClearFocus()
    end
  end)
  do
    local handling_power = false
    condFrame.cond_ability_power_val:SetScript("OnEditFocusLost", function()
      if handling_power then
        return
      end
      handling_power = true
      this:GetScript("OnEnterPressed")()
      handling_power = false
    end)
  end

  condFrame.cond_ability_remaining_val:SetScript("OnEnterPressed", function()
    if not currentKey then
      return
    end
    local v = tonumber(this:GetText())
    if not v then
      local d = EnsureDBEntry(currentKey)
      this:SetText(tostring((d.conditions and d.conditions.ability and d.conditions.ability.remainingVal) or 0))
      return
    end
    if v < 0 then
      v = 0
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions = d.conditions or {}
    d.conditions.ability = d.conditions.ability or {}
    d.conditions.ability.remainingVal = v
    SafeRefresh()
    SafeEvaluate()
    UpdateCondFrameForKey(currentKey)
    if this.ClearFocus then
      this:ClearFocus()
    end
  end)
  do
    local handling_ability_remaining = false
    condFrame.cond_ability_remaining_val:SetScript("OnEditFocusLost", function()
      if handling_ability_remaining then
        return
      end
      handling_ability_remaining = true
      this:GetScript("OnEnterPressed")()
      handling_ability_remaining = false
    end)
  end

  condFrame.cond_aura_remaining_val:SetScript("OnEnterPressed", function()
    if not currentKey then
      return
    end
    local v = tonumber(this:GetText())
    if not v then
      local d = EnsureDBEntry(currentKey)
      this:SetText(tostring((d.conditions and d.conditions.aura and d.conditions.aura.remainingVal) or 0))
      return
    end
    if v < 0 then
      v = 0
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions = d.conditions or {}
    d.conditions.aura = d.conditions.aura or {}
    d.conditions.aura.remainingVal = v
    SafeRefresh()
    SafeEvaluate()
    UpdateCondFrameForKey(currentKey)
    if this.ClearFocus then
      this:ClearFocus()
    end
  end)
  do
    local handling_aura_remaining = false
    condFrame.cond_aura_remaining_val:SetScript("OnEditFocusLost", function()
      if handling_aura_remaining then
        return
      end
      handling_aura_remaining = true
      this:GetScript("OnEnterPressed")()
      handling_aura_remaining = false
    end)
  end

  condFrame.cond_aura_stacks_val:SetScript("OnEnterPressed", function()
    if not currentKey then
      return
    end
    local v = tonumber(this:GetText())
    if not v then
      local d = EnsureDBEntry(currentKey)
      this:SetText(tostring((d.conditions and d.conditions.aura and d.conditions.aura.stacksVal) or 0))
      return
    end
    if v < 0 then
      v = 0
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions = d.conditions or {}
    d.conditions.aura = d.conditions.aura or {}
    d.conditions.aura.stacksVal = v
    SafeRefresh()
    SafeEvaluate()
    UpdateCondFrameForKey(currentKey)
    if this.ClearFocus then
      this:ClearFocus()
    end
  end)
  do
    local handling_aura_stacks = false
    condFrame.cond_aura_stacks_val:SetScript("OnEditFocusLost", function()
      if handling_aura_stacks then
        return
      end
      handling_aura_stacks = true
      this:GetScript("OnEnterPressed")()
      handling_aura_stacks = false
    end)
  end

  -- 物品连击点数值
  condFrame.cond_item_cp_val:SetScript("OnEnterPressed", function()
    if not currentKey then
      return
    end
    local v = tonumber(this:GetText())
    local d = EnsureDBEntry(currentKey)
    d.conditions.item = d.conditions.item or {}
    if not v then
      this:SetText(tostring(d.conditions.item.cpVal or 0))
      return
    end
    if v < 0 then
      v = 0
    end
    d.conditions.item.cpVal = v
    SafeRefresh();
    SafeEvaluate()
    UpdateCondFrameForKey(currentKey)
    if this.ClearFocus then
      this:ClearFocus()
    end
  end)
  do
    local _g = false
    condFrame.cond_item_cp_val:SetScript("OnEditFocusLost", function()
      if _g then
        return
      end ;
      _g = true
      this:GetScript("OnEnterPressed")()
      _g = false
    end)
  end

  -- 物品生命值百分比
  condFrame.cond_item_hp_val:SetScript("OnEnterPressed", function()
    if not currentKey then
      return
    end
    local v = tonumber(this:GetText())
    local d = EnsureDBEntry(currentKey)
    d.conditions.item = d.conditions.item or {}
    if not v then
      this:SetText(tostring(d.conditions.item.hpVal or 0))
      return
    end
    if v < 0 then
      v = 0
    end
    if v > 100 then
      v = 100
    end
    d.conditions.item.hpVal = v
    SafeRefresh();
    SafeEvaluate()
    UpdateCondFrameForKey(currentKey)
    if this.ClearFocus then
      this:ClearFocus()
    end
  end)
  do
    local _g = false
    condFrame.cond_item_hp_val:SetScript("OnEditFocusLost", function()
      if _g then
        return
      end ;
      _g = true
      this:GetScript("OnEnterPressed")()
      _g = false
    end)
  end

  -- 物品资源值
  condFrame.cond_item_power_val:SetScript("OnEnterPressed", function()
    if not currentKey then
      return
    end
    local v = tonumber(this:GetText())
    local d = EnsureDBEntry(currentKey)
    d.conditions.item = d.conditions.item or {}
    if not v then
      this:SetText(tostring(d.conditions.item.powerVal or 0))
      return
    end
    d.conditions.item.powerVal = v
    SafeRefresh();
    SafeEvaluate()
    UpdateCondFrameForKey(currentKey)
    if this.ClearFocus then
      this:ClearFocus()
    end
  end)
  do
    local _g = false
    condFrame.cond_item_power_val:SetScript("OnEditFocusLost", function()
      if _g then
        return
      end ;
      _g = true
      this:GetScript("OnEnterPressed")()
      _g = false
    end)
  end

  -- 物品层数值
  condFrame.cond_item_stacks_val:SetScript("OnEnterPressed", function()
    if not currentKey then
      return
    end
    local v = tonumber(this:GetText())
    local d = EnsureDBEntry(currentKey)
    d.conditions.item = d.conditions.item or {}
    if not v then
      this:SetText(tostring(d.conditions.item.stacksVal or 0))
      return
    end
    if v < 0 then
      v = 0
    end
    d.conditions.item.stacksVal = v
    SafeRefresh();
    SafeEvaluate()
    UpdateCondFrameForKey(currentKey)
    if this.ClearFocus then
      this:ClearFocus()
    end
  end)
  do
    local _g = false
    condFrame.cond_item_stacks_val:SetScript("OnEditFocusLost", function()
      if _g then
        return
      end ;
      _g = true
      this:GetScript("OnEnterPressed")()
      _g = false
    end)
  end

  -- 物品剩余时间（秒）
  condFrame.cond_item_remaining_val:SetScript("OnEnterPressed", function()
    if not currentKey then
      return
    end
    local v = tonumber(this:GetText())
    local d = EnsureDBEntry(currentKey)
    d.conditions.item = d.conditions.item or {}
    if not v then
      this:SetText(tostring(d.conditions.item.remainingVal or 0))
      return
    end
    if v < 0 then
      v = 0
    end
    d.conditions.item.remainingVal = v
    SafeRefresh();
    SafeEvaluate()
    UpdateCondFrameForKey(currentKey)
    if this.ClearFocus then
      this:ClearFocus()
    end
  end)
  do
    local _g = false
    condFrame.cond_item_remaining_val:SetScript("OnEditFocusLost", function()
      if _g then
        return
      end ;
      _g = true
      this:GetScript("OnEnterPressed")()
      _g = false
    end)
  end

  -- 技能资源切换
  condFrame.cond_ability_power:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions = d.conditions or {}
    d.conditions.ability = d.conditions.ability or {}
    d.conditions.ability.powerEnabled = this:GetChecked() and true or false
    UpdateCondFrameForKey(currentKey)
    SafeRefresh()
    SafeEvaluate()
  end)

  -- 技能滑块切换
  condFrame.cond_ability_slider:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions = d.conditions or {}
    d.conditions.ability = d.conditions.ability or {}
    d.conditions.ability.slider = this:GetChecked() and true or false
    if d.conditions.ability.slider and not d.conditions.ability.sliderDir then
      d.conditions.ability.sliderDir = "居中"
    end
    UpdateCondFrameForKey(currentKey)
    SafeRefresh()
    SafeEvaluate()
  end)

  -- 技能剩余切换
  condFrame.cond_ability_remaining_cb:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions = d.conditions or {}
    d.conditions.ability = d.conditions.ability or {}
    d.conditions.ability.remainingEnabled = this:GetChecked() and true or false
    UpdateCondFrameForKey(currentKey)
    SafeRefresh()
    SafeEvaluate()
  end)

  -- 技能发光/灰色（独立复选框）
  condFrame.cond_ability_glow:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions = d.conditions or {}
    d.conditions.ability = d.conditions.ability or {}
    d.conditions.ability.glow = this:GetChecked() and true or false
    UpdateCondFrameForKey(currentKey)
    SafeRefresh()
    SafeEvaluate()
  end)
  condFrame.cond_ability_greyscale:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions = d.conditions or {}
    d.conditions.ability = d.conditions.ability or {}
    d.conditions.ability.greyscale = this:GetChecked() and true or false
    UpdateCondFrameForKey(currentKey)
    SafeRefresh()
    SafeEvaluate()
  end)
  condFrame.cond_ability_fade:SetScript("OnClick", function()
    if not currentKey then
      this:SetChecked(false)
      return
    end
    local d = EnsureDBEntry(currentKey)
    d.conditions = d.conditions or {}
    d.conditions.ability = d.conditions.ability or {}
    d.conditions.ability.fade = this:GetChecked() and true or false
    if d.conditions.ability.fade and not d.conditions.ability.fadeAlpha then
      d.conditions.ability.fadeAlpha = 0
    end
    UpdateCondFrameForKey(currentKey)
    SafeRefresh()
    SafeEvaluate()
  end)

  local function SaveAbilityFadeAlpha()
    if not currentKey then return end
    local d = EnsureDBEntry(currentKey)
    d.conditions = d.conditions or {}
    d.conditions.ability = d.conditions.ability or {}
    d.conditions.ability.fadeAlpha = _ParseFadeAlphaFromBox(condFrame.cond_ability_fade_slider)
    _NormalizeFadeBox(condFrame.cond_ability_fade_slider, d.conditions.ability.fadeAlpha)
    SafeRefresh()
    SafeEvaluate()
  end
  condFrame.cond_ability_fade_slider:SetScript("OnEnterPressed", function() SaveAbilityFadeAlpha(); this:ClearFocus() end)
  condFrame.cond_ability_fade_slider:SetScript("OnEditFocusLost", SaveAbilityFadeAlpha)
  condFrame.cond_ability_fade_slider:SetScript("OnEscapePressed", function() this:ClearFocus() end)

  -- 形态下拉框由UpdateConditionsUI初始化/更新
  condFrame.cond_ability_formDD:Hide()
  condFrame.cond_aura_formDD:Hide()
  condFrame.cond_item_formDD:Hide()
  ClearDropdown(condFrame.cond_ability_formDD)
  ClearDropdown(condFrame.cond_aura_formDD)
  ClearDropdown(condFrame.cond_item_formDD)

  -- 默认隐藏所有控件
  condFrame.cond_ability_usable:Hide()
  condFrame.cond_ability_notcd:Hide()
  condFrame.cond_ability_oncd:Hide()
  condFrame.cond_ability_incombat:Hide()
  condFrame.cond_ability_outcombat:Hide()
  condFrame.cond_ability_target_help:Hide()
  condFrame.cond_ability_target_harm:Hide()
  condFrame.cond_ability_target_self:Hide()
  condFrame.cond_ability_power:Hide()
  condFrame.cond_ability_power_comp:Hide()
  condFrame.cond_ability_power_val:Hide()
  condFrame.cond_ability_power_val_enter:Hide()
  condFrame.cond_ability_glow:Hide()
  condFrame.cond_ability_slider:Hide()
  condFrame.cond_ability_slider_dir:Hide()
  condFrame.cond_ability_remaining_cb:Hide()
  condFrame.cond_ability_remaining_comp:Hide()
  condFrame.cond_ability_remaining_val:Hide()
  condFrame.cond_ability_remaining_val_enter:Hide()
  condFrame.cond_ability_greyscale:Hide()
  condFrame.cond_ability_fade:Hide()
  condFrame.cond_ability_fade_slider:Hide()
  condFrame.cond_ability_cp_cb:Hide()
  condFrame.cond_ability_cp_comp:Hide()
  condFrame.cond_ability_cp_val:Hide()
  condFrame.cond_ability_cp_val_enter:Hide()
  condFrame.cond_ability_hp_my:Hide()
  condFrame.cond_ability_hp_tgt:Hide()
  condFrame.cond_ability_hp_comp:Hide()
  condFrame.cond_ability_hp_val:Hide()
  condFrame.cond_ability_hp_val_enter:Hide()
  condFrame.cond_ability_slider_glow:Hide()
  condFrame.cond_ability_slider_grey:Hide()
  condFrame.cond_ability_text_time:Hide()
  if condFrame.cond_ability_weaponDD then
    condFrame.cond_ability_weaponDD:Hide()
  end

  if condFrame.cond_ability_distanceDD then
    condFrame.cond_ability_distanceDD:Hide()
  end
  if condFrame.cond_ability_unitTypeDD then
    condFrame.cond_ability_unitTypeDD:Hide()
  end

  if condFrame.cond_aura_distanceDD then
    condFrame.cond_aura_distanceDD:Hide()
  end
  if condFrame.cond_aura_unitTypeDD then
    condFrame.cond_aura_unitTypeDD:Hide()
  end

  condFrame.cond_aura_cp_cb:Hide()
  condFrame.cond_aura_cp_comp:Hide()
  condFrame.cond_aura_cp_val:Hide()
  condFrame.cond_aura_cp_val_enter:Hide()
  condFrame.cond_aura_hp_my:Hide()
  condFrame.cond_aura_hp_tgt:Hide()
  condFrame.cond_aura_hp_comp:Hide()
  condFrame.cond_aura_hp_val:Hide()
  condFrame.cond_aura_hp_val_enter:Hide()
  condFrame.cond_aura_text_time:Hide()
  condFrame.cond_aura_text_stack:Hide()
  condFrame.cond_aura_power:Hide()
  condFrame.cond_aura_power_comp:Hide()
  condFrame.cond_aura_power_val:Hide()
  condFrame.cond_aura_power_val_enter:Hide()
  condFrame.cond_aura_found:Hide()
  condFrame.cond_aura_missing:Hide()
  condFrame.cond_aura_incombat:Hide()
  condFrame.cond_aura_outcombat:Hide()
  condFrame.cond_aura_target_help:Hide()
  condFrame.cond_aura_target_harm:Hide()
  condFrame.cond_aura_onself:Hide()
  condFrame.cond_aura_glow:Hide()
  condFrame.cond_aura_remaining_cb:Hide()
  condFrame.cond_aura_remaining_comp:Hide()
  condFrame.cond_aura_remaining_val:Hide()
  condFrame.cond_aura_remaining_val_enter:Hide()
  condFrame.cond_aura_stacks_cb:Hide()
  condFrame.cond_aura_stacks_comp:Hide()
  condFrame.cond_aura_stacks_val:Hide()
  condFrame.cond_aura_stacks_val_enter:Hide()
  condFrame.cond_aura_greyscale:Hide()
  condFrame.cond_aura_fade:Hide()
  condFrame.cond_aura_fade_slider:Hide()
  condFrame.cond_aura_mine:Hide()
  if condFrame.cond_aura_trackpet then
    condFrame.cond_aura_trackpet:Hide()
  end
  if condFrame.cond_aura_others then
    condFrame.cond_aura_others:Hide()
  end
  if condFrame.cond_aura_owner_tip then
    condFrame.cond_aura_owner_tip:Hide()
  end
  if condFrame.cond_aura_distanceDD then
    condFrame.cond_aura_distanceDD:Hide()
  end
  if condFrame.cond_aura_unitTypeDD then
    condFrame.cond_aura_unitTypeDD:Hide()
  end
  if condFrame.cond_aura_weaponDD then
    condFrame.cond_aura_weaponDD:Hide()
  end

  condFrame.cond_item_where_equipped:Hide()
  condFrame.cond_item_where_bag:Hide()
  condFrame.cond_item_where_missing:Hide()
  condFrame.cond_item_notcd:Hide()
  condFrame.cond_item_oncd:Hide()
  if condFrame.cond_item_enchant then
    condFrame.cond_item_enchant:Hide()
  end
  if condFrame.cond_item_text_enchant then
    condFrame.cond_item_text_enchant:Hide()
  end
  condFrame.cond_item_incombat:Hide()
  condFrame.cond_item_outcombat:Hide()
  condFrame.cond_item_target_help:Hide()
  condFrame.cond_item_target_harm:Hide()
  condFrame.cond_item_target_self:Hide()
  condFrame.cond_item_glow:Hide()
  condFrame.cond_item_greyscale:Hide()
  condFrame.cond_item_fade:Hide()
  condFrame.cond_item_fade_slider:Hide()
  condFrame.cond_item_text_time:Hide()
  condFrame.cond_item_power:Hide()
  condFrame.cond_item_power_comp:Hide()
  condFrame.cond_item_power_val:Hide()
  condFrame.cond_item_power_val_enter:Hide()
  condFrame.cond_item_stacks_cb:Hide()
  condFrame.cond_item_stacks_comp:Hide()
  condFrame.cond_item_stacks_val:Hide()
  condFrame.cond_item_stacks_val_enter:Hide()
  condFrame.cond_item_text_stack:Hide()
  condFrame.cond_item_hp_my:Hide()
  condFrame.cond_item_hp_tgt:Hide()
  condFrame.cond_item_hp_comp:Hide()
  condFrame.cond_item_hp_val:Hide()
  condFrame.cond_item_hp_val_enter:Hide()
  condFrame.cond_item_remaining_cb:Hide()
  condFrame.cond_item_remaining_comp:Hide()
  condFrame.cond_item_remaining_val:Hide()
  condFrame.cond_item_remaining_val_enter:Hide()
  condFrame.cond_item_cp_cb:Hide()
  condFrame.cond_item_cp_comp:Hide()
  condFrame.cond_item_cp_val:Hide()
  condFrame.cond_item_cp_val_enter:Hide()
  if condFrame.cond_item_weaponDD then
    condFrame.cond_item_weaponDD:Hide()
  end
  condFrame.cond_item_inv_trinket1:Hide()
  condFrame.cond_item_inv_trinket2:Hide()
  condFrame.cond_item_inv_trinket_first:Hide()
  condFrame.cond_item_inv_trinket_both:Hide()
  condFrame.cond_item_inv_wep_mainhand:Hide()
  condFrame.cond_item_inv_wep_offhand:Hide()
  condFrame.cond_item_inv_wep_ranged:Hide()
  if condFrame.cond_item_inv_wep_ammo then
    condFrame.cond_item_inv_wep_ammo:Hide()
  end
  if condFrame.cond_item_class_note then
    condFrame.cond_item_class_note:Hide()
  end
  -- 注册三种类型的动态光环条件管理器
  if AuraCond_RegisterManager then
    if condFrame.abilityAuraAnchor then
      AuraCond_RegisterManager("ability", condFrame.abilityAuraAnchor)
    end
    if condFrame.auraAuraAnchor then
      AuraCond_RegisterManager("aura", condFrame.auraAuraAnchor)
    end
    if condFrame.itemAuraAnchor then
      AuraCond_RegisterManager("item", condFrame.itemAuraAnchor)
    end
  end

  -- 注册三种类型的动态视觉效果条件管理器
  if VfxCond_RegisterManager then
    if condFrame.abilityVfxAnchor then
      VfxCond_RegisterManager("ability", condFrame.abilityVfxAnchor)
    end
    if condFrame.auraVfxAnchor then
      VfxCond_RegisterManager("aura", condFrame.auraVfxAnchor)
    end
    if condFrame.itemVfxAnchor then
      VfxCond_RegisterManager("item", condFrame.itemVfxAnchor)
    end
  end

  -- 默认隐藏；由UpdateConditionsUI控制可见性
  if condFrame.abilityAuraAnchor then
    condFrame.abilityAuraAnchor:Hide()
  end
  if condFrame.auraAuraAnchor then
    condFrame.auraAuraAnchor:Hide()
  end
  if condFrame.itemAuraAnchor then
    condFrame.itemAuraAnchor:Hide()
  end
  if condFrame.abilityVfxAnchor then
    condFrame.abilityVfxAnchor:Hide()
  end
  if condFrame.auraVfxAnchor then
    condFrame.auraVfxAnchor:Hide()
  end
  if condFrame.itemVfxAnchor then
    condFrame.itemVfxAnchor:Hide()
  end

  -- 确保AND/OR逻辑弹窗和按钮在编辑框关闭时消失
  if condFrame and not condFrame._logicHideHooked then
    condFrame._logicHideHooked = true
    local oldOnHide = condFrame:GetScript("OnHide")

    condFrame:SetScript("OnHide", function()
      -- 如果AND/OR / ()弹窗打开则关闭
      if DoiteAuraLogicFrame and DoiteAuraLogicFrame:IsShown() then
        DoiteAuraLogicFrame:Hide()
      end

      -- 同时隐藏所有类型的逻辑按钮
      if AuraCond_Managers then
        for _, mgr in pairs(AuraCond_Managers) do
          if mgr.logicButton then
            mgr.logicButton:Hide()
          end
        end
      end

      if oldOnHide then
        oldOnHide()
      end
    end)
  end
end

-- 动态调整滚动/内容区域高度以适应最后可见行（+20px缓冲区）+ 动态调整滚动/内容区域并重新定位VFX部分
_ReflowCondAreaHeight = function()
  if not condFrame then
    return
  end

  local parent = condFrame._condArea or condFrame.condArea or condFrame
  if not parent then
    return
  end

  if condFrame.abilityAuraAnchor and condFrame.abilityAuraAnchor:IsShown() then
    local visHeight = condFrame.abilityAuraAnchor:GetHeight() or 20

    local ROW14_Y = -550
    local ROW15_Y = -605

    local expansion = visHeight - 20
    if expansion < 0 then expansion = 0 end

    local newVfxY = ROW15_Y - expansion

    -- 移动分隔线
    if condFrame._seps and condFrame._seps.ability and condFrame._seps.ability[15] then
      local sep = condFrame._seps.ability[15]
      sep:ClearAllPoints()
      sep:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, newVfxY)
      sep:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, newVfxY)
    end

    -- 移动VFX锚点
    if condFrame.abilityVfxAnchor then
      condFrame.abilityVfxAnchor:ClearAllPoints()
      condFrame.abilityVfxAnchor:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, newVfxY)
      condFrame.abilityVfxAnchor:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, newVfxY)
    end
  end

  -- 2. 重新流式光环部分
  -- 光环可见性基址为(row16_y) = -630
  -- 光环VFX基址为(row17_y) = -670
  if condFrame.auraAuraAnchor and condFrame.auraAuraAnchor:IsShown() then
    local visHeight = condFrame.auraAuraAnchor:GetHeight() or 20
    local AURA_VIS_Y = -630
    local AURA_VFX_Y = -670

    local expansion = visHeight - 20
    if expansion < 0 then expansion = 0 end

    local newVfxY = AURA_VFX_Y - expansion
    if condFrame._seps and condFrame._seps.aura and condFrame._seps.aura[17] then
      local sep = condFrame._seps.aura[17]
      sep:ClearAllPoints()
      sep:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, newVfxY)
      sep:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, newVfxY)
    end
    if condFrame.auraVfxAnchor then
      condFrame.auraVfxAnchor:ClearAllPoints()
      condFrame.auraVfxAnchor:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, newVfxY)
      condFrame.auraVfxAnchor:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, newVfxY)
    end
  end

  -- 3. 重新流式物品部分
  -- 物品可见性基址为row17_y = -550
  -- 物品VFX基址为row18_y = -590
  if condFrame.itemAuraAnchor and condFrame.itemAuraAnchor:IsShown() then
    local visHeight = condFrame.itemAuraAnchor:GetHeight() or 20
    local ITEM_VIS_Y = -670
    local ITEM_VFX_Y = -710

    local expansion = visHeight - 20
    if expansion < 0 then expansion = 0 end

    local newVfxY = ITEM_VFX_Y - expansion

    if condFrame._seps and condFrame._seps.item and condFrame._seps.item[18] then
      local sep = condFrame._seps.item[18]
      sep:ClearAllPoints()
      sep:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, newVfxY)
      sep:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, newVfxY)
    end
    if condFrame.itemVfxAnchor then
      condFrame.itemVfxAnchor:ClearAllPoints()
      condFrame.itemVfxAnchor:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, newVfxY)
      condFrame.itemVfxAnchor:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, newVfxY)
    end
  end


  -- 现在根据新位置计算总高度
  if not parent.GetChildren then
    return
  end
  local children = { parent:GetChildren() }
  local minBottom = nil

  local i = 1
  while children[i] do
    local f = children[i]
    if f and f.IsShown and f:IsShown() and f.GetPoint and f.GetHeight then
      local _, _, _, _, y = f:GetPoint(1)
      if y then
        local h = f:GetHeight() or 0
        local bottom = y - h
        if not minBottom or bottom < minBottom then
          minBottom = bottom
        end
      end
    end
    i = i + 1
  end

  if not minBottom then
    return
  end

  local height = -minBottom + 20
  if height < 200 then
    height = 200
  end

  parent:SetHeight(height)

  local sf = condFrame._scrollFrame or condFrame.scrollFrame
  if sf then
    if sf.SetScrollChild then
      sf:SetScrollChild(parent)
    end
    if sf.UpdateScrollChildRect then
      sf:UpdateScrollChildRect()
    end
  end
end

-- 动态“光环条件”管理器（技能 / 光环 / 物品）
do
  -- 辅助函数：一帧后重新打开下拉框（类似物品版本）
  local _ddReopenFrame = CreateFrame("Frame", "DoiteEditReopenFrame")
  local _ddReopenRow = nil

  _ddReopenFrame:Hide()
  _ddReopenFrame:SetScript("OnUpdate", function()
    _ddReopenFrame:Hide()
    if not _ddReopenRow or not _ddReopenRow.abilityDD then
      _ddReopenRow = nil
      return
    end
    -- 重新打开，锚点在下拉框本身，偏移x=0
    ToggleDropDownMenu(nil, nil, _ddReopenRow.abilityDD, _ddReopenRow.abilityDD, 0, 0)
    _ddReopenRow = nil
  end)

  local function AuraCond_ReopenDDNextFrame(row)
    _ddReopenRow = row
    _ddReopenFrame:Show()
  end

  local function AuraCond_Len(t)
    if not t then
      return 0
    end
    local n = 0
    while t[n + 1] ~= nil do
      n = n + 1
    end
    return n
  end

  local function AuraCond_GetListForType(typeKey)
    if not currentKey or not DoiteAurasDB or not DoiteAurasDB.spells then
      return nil
    end
    local d = EnsureDBEntry(currentKey)
    if not d or not d.conditions then
      return nil
    end

    if typeKey == "ability" then
      d.conditions.ability = d.conditions.ability or {}
      d.conditions.ability.auraConditions = d.conditions.ability.auraConditions or {}
      return d.conditions.ability.auraConditions
    elseif typeKey == "aura" then
      d.conditions.aura = d.conditions.aura or {}
      d.conditions.aura.auraConditions = d.conditions.aura.auraConditions or {}
      return d.conditions.aura.auraConditions
    elseif typeKey == "item" then
      d.conditions.item = d.conditions.item or {}
      d.conditions.item.auraConditions = d.conditions.item.auraConditions or {}
      return d.conditions.item.auraConditions
    end
    return nil
  end

  -- 从法术书中构建非被动技能的排序列表
  local function AuraCond_BuildAbilitySpellList()
    local spells = {}
    local seen = {}
    local passiveAllow = _G["DA_AbilityDropdownPassiveAllow"] or {}

    local function scanBook(bookType)
      local i = 1
      while true do
        local name, rank = GetSpellName(i, bookType)
        if not name then
          break
        end

        local isPassive = false
        if IsPassiveSpell then
          local ok, passive = pcall(IsPassiveSpell, i, bookType)
          if ok and passive then
            isPassive = true
          end
        end
        if (not isPassive) and rank and string.find(rank, "Passive") then
          isPassive = true
        end

        if name and name ~= "" then
          local allowPassive = (passiveAllow[name] == true)
          if ((not isPassive) or allowPassive) and not seen[name] then
            table.insert(spells, name)
            seen[name] = true
          end
        end

        i = i + 1
      end
    end

    scanBook(BOOKTYPE_SPELL)
    scanBook(BOOKTYPE_PET)

    table.sort(spells, function(a, b)
      a = string.lower(a or "")
      b = string.lower(b or "")
      return a < b
    end)

    return spells
  end

  local function AuraCond_BuildItemOptions()
    local items, seen = {}, {}
    local function _Add(name)
      if not name or name == "" or seen[name] then return end
      seen[name] = true
      table.insert(items, name)
    end
    local function _NameFromLink(link)
      if not link or link == "" then return nil end
      local nm = GetItemInfo and GetItemInfo(link)
      if nm and nm ~= "" then return nm end
      local _, _, txt = string.find(link, "%[(.-)%]")
      return txt
    end
    local i
    for _, i in ipairs({13,14,16,17,18}) do
      _Add(_NameFromLink(GetInventoryItemLink and GetInventoryItemLink("player", i)))
    end
    local bag, slot
    for bag = 0, 4 do
      local n = GetContainerNumSlots and GetContainerNumSlots(bag)
      if n and n > 0 then
        for slot = 1, n do
          _Add(_NameFromLink(GetContainerItemLink and GetContainerItemLink(bag, slot)))
        end
      end
    end
    table.sort(items, function(a, b)
      return string.lower(a or "") < string.lower(b or "")
    end)
    table.insert(items, 1, "---已装备的武器栏位---")
    table.insert(items, 1, "---已装备的饰品栏位---")
    return items
  end

  -- 初始化/刷新给定编辑行的技能下拉框
  local function AuraCond_InitAbilityDropdown(row)
    if not row or not row.abilityDD then
      return
    end

    local spells = AuraCond_BuildAbilitySpellList()
    row._abilitySpells = spells

    local total = table.getn(spells)
    local perPage = 10

    if total == 0 then
      UIDropDownMenu_Initialize(row.abilityDD, function()
      end)
      if UIDropDownMenu_SetText then
        pcall(UIDropDownMenu_SetText, "未找到技能", row.abilityDD)
      end
      return
    end

    local maxPage = math.max(1, math.ceil(total / perPage))
    local page = row._abilityPage or 1
    if page < 1 then
      page = 1
    end
    if page > maxPage then
      page = maxPage
    end
    row._abilityPage = page

    local startIndex = (page - 1) * perPage + 1
    local endIndex = math.min(startIndex + perPage - 1, total)

    UIDropDownMenu_Initialize(row.abilityDD, function(frame, level, menuList)
      local info

      -- 上一页（在顶部，黄色文本）
      if page > 1 then
        info = {}
        info.text = "|cffffd000<< 上一页|r"
        info.value = "PREV"
        info.notCheckable = true
        info.func = function()
          row._abilityPage = page - 1
          AuraCond_InitAbilityDropdown(row)
          AuraCond_ReopenDDNextFrame(row)
        end
        UIDropDownMenu_AddButton(info)
      end

      -- 技能条目
      local idx = startIndex
      while idx <= endIndex do
        local name = spells[idx]
        info = {}
        info.text = name
        info.value = name
        local pickedName = name
        info.func = function(button)
          local val = (button and button.value) or pickedName
          row._spellName = val
          if UIDropDownMenu_SetSelectedValue then
            pcall(UIDropDownMenu_SetSelectedValue, row.abilityDD, val)
          end
          if UIDropDownMenu_SetText then
            pcall(UIDropDownMenu_SetText, val, row.abilityDD)
          end
          if _GoldifyDD then
            _GoldifyDD(row.abilityDD)
          end
        end
        info.checked = (row._spellName == name)
        UIDropDownMenu_AddButton(info)
        idx = idx + 1
      end

      -- 下一页（在底部，黄色文本）
      if page < maxPage then
        info = {}
        info.text = "|cffffd000下一页 >>|r"
        info.value = "NEXT"
        info.notCheckable = true
        info.func = function()
          row._abilityPage = page + 1
          AuraCond_InitAbilityDropdown(row)
          AuraCond_ReopenDDNextFrame(row)
        end
        UIDropDownMenu_AddButton(info)
      end
    end)

    local label = row._spellName or "选择技能"
    if UIDropDownMenu_SetText then
      pcall(UIDropDownMenu_SetText, label, row.abilityDD)
    end
    if _GoldifyDD then
      _GoldifyDD(row.abilityDD)
    end
  end

  local function AuraCond_InitItemDropdown(row)
    if not row or not row.itemDD then return end

    local items = AuraCond_BuildItemOptions()
    row._itemOptions = items

    local total = table.getn(items)
    local perPage = 10

    if total == 0 then
      UIDropDownMenu_Initialize(row.itemDD, function() end)
      if UIDropDownMenu_SetText then
        pcall(UIDropDownMenu_SetText, "未找到物品", row.itemDD)
      end
      return
    end

    local maxPage = math.max(1, math.ceil(total / perPage))
    local page = row._itemPage or 1
    if page < 1 then page = 1 end
    if page > maxPage then page = maxPage end
    row._itemPage = page

    local function ReopenItemDDNextFrame()
      local f = row.itemDD and row.itemDD._reopenFrame
      if not f then
        f = CreateFrame("Frame", nil, UIParent)
        if row.itemDD then
          row.itemDD._reopenFrame = f
        end
        f:Hide()
        f:SetScript("OnUpdate", function()
          f:Hide()
          if row and row.itemDD then
            ToggleDropDownMenu(nil, nil, row.itemDD, row.itemDD, 0, 0)
          end
        end)
      end
      f:Show()
    end

    local startIndex = (page - 1) * perPage + 1
    local endIndex = math.min(startIndex + perPage - 1, total)

    UIDropDownMenu_Initialize(row.itemDD, function(frame, level, menuList)
      local info

      if page > 1 then
        info = {}
        info.text = "|cffffd000<< 上一页|r"
        info.value = "PREV"
        info.notCheckable = true
        info.func = function()
          row._itemPage = page - 1
          AuraCond_InitItemDropdown(row)
          if CloseDropDownMenus then
            CloseDropDownMenus()
          end
          ReopenItemDDNextFrame()
        end
        UIDropDownMenu_AddButton(info)
      end

      local idx = startIndex
      while idx <= endIndex do
        local name = items[idx]
        info = {}
        info.text = name
        info.value = name
        local pickedName = name
        info.func = function(button)
          local val = (button and button.value) or pickedName
          row._itemName = val
          if UIDropDownMenu_SetSelectedValue then
            pcall(UIDropDownMenu_SetSelectedValue, row.itemDD, val)
          end
          if UIDropDownMenu_SetText then
            pcall(UIDropDownMenu_SetText, val, row.itemDD)
          end
          if _GoldifyDD then
            _GoldifyDD(row.itemDD)
          end
        end
        info.checked = (row._itemName == name)
        UIDropDownMenu_AddButton(info)
        idx = idx + 1
      end

      if page < maxPage then
        info = {}
        info.text = "|cffffd000下一页 >>|r"
        info.value = "NEXT"
        info.notCheckable = true
        info.func = function()
          row._itemPage = page + 1
          AuraCond_InitItemDropdown(row)
          if CloseDropDownMenus then
            CloseDropDownMenus()
          end
          ReopenItemDDNextFrame()
        end
        UIDropDownMenu_AddButton(info)
      end
    end)

    if UIDropDownMenu_SetText then
      pcall(UIDropDownMenu_SetText, row._itemName or "选择物品", row.itemDD)
    end
    if _GoldifyDD then
      _GoldifyDD(row.itemDD)
    end
  end

  local function AuraCond_BuildDescription(buffType, mode, unit, name, stacksEnabled, stacksComp, stacksVal)
    local niceName = AuraCond_TitleCase(name or "")

    local yellow = "|cffffd000"
    local white  = "|cffffffff"
    local sep    = "|cffffffff | |r"  -- 白色" | "

    -- 特殊情况：技能行
    if buffType == "ABILITY" then
      local typeColor = "|cff4da6ff" -- 技能蓝色
      local typePart = typeColor .. "技能" .. "|r"

      local modeWord
      if mode == "oncd" or mode == "usableoncd" or mode == "nocdoncd" then
        modeWord = "冷却中"
      else
        modeWord = "不在冷却中"
      end
      local modePart = yellow .. modeWord .. "|r"
      local namePart = white .. (niceName or "") .. "|r"

      return typePart .. " " .. sep .. modePart .. ": " .. namePart

    elseif buffType == "TALENT" then
      local modeStr = mode or ""
      local lower = string.lower(modeStr)

      local isKnown = (lower == "known")
      local stateWord
      if isKnown then
        stateWord = "已学习"
      else
        stateWord = "未学习"
      end

      local stateColor = isKnown and "|cff00ff00" or "|cffff0000"
      local statePart = stateColor .. stateWord .. "|r"

      local talentPart = yellow .. "天赋" .. "|r"
      local namePart = white .. (niceName or "") .. "|r"

      return talentPart .. " " .. sep .. statePart .. ": " .. namePart
    elseif buffType == "ITEM" then
      local whereWord = (mode == "missing") and "缺失" or "在背包/已装备"
      local cdWord = (unit == "oncd") and "冷却中" or "不在冷却中"
      local itemPart = yellow .. "物品" .. "|r"
      local wherePart = yellow .. whereWord .. "|r"

      local prefix = ""
      if stacksEnabled and stacksComp and stacksComp ~= "" and stacksVal and tostring(stacksVal) ~= "" then
        local sym = stacksComp
        if sym == ">=" then sym = "≥"
        elseif sym == "<=" then sym = "≤"
        elseif sym == "==" then sym = "="
        end
        prefix = tostring(sym) .. tostring(stacksVal) .. "x"
      end

      local namePart = white .. prefix .. (niceName or "") .. "|r"

      if mode == "missing" then
        return itemPart .. " " .. sep .. wherePart .. ": " .. namePart
      end

      local cdPart = yellow .. cdWord .. "|r"
      return itemPart .. " " .. sep .. wherePart .. " " .. sep .. cdPart .. ": " .. namePart
    end

    -- 默认：增益/减益光环行
    local typeWord = (buffType == "DEBUFF") and "减益" or "增益"
    local modeWord = (mode == "missing") and "缺失" or "存在"
    local unitWord
    if unit == "target" then
      unitWord = "目标"
    else
      unitWord = "玩家"
    end

    local typeColor = (buffType == "DEBUFF") and "|cffff0000" or "|cff00ff00"

    local typePart = typeColor .. typeWord .. "|r"
    local modePart = yellow .. modeWord .. "|r"
    local unitPart = yellow .. unitWord .. "|r"

    -- 层数前缀：≥5x名称, ≤3x名称, =2x名称
    local prefix = ""
    if stacksEnabled and stacksComp and stacksComp ~= "" and stacksVal and tostring(stacksVal) ~= "" then
      local sym = stacksComp
      if sym == ">=" then sym = "≥"
      elseif sym == "<=" then sym = "≤"
      elseif sym == "==" then sym = "="
      end
      prefix = tostring(sym) .. tostring(stacksVal) .. "x"
    end

    local namePart = white .. prefix .. (niceName or "") .. "|r"
    return typePart .. " " .. sep .. modePart .. " " .. sep .. unitPart .. ": " .. namePart
  end

  local function AuraCond_ParseAuraInput(rawText)
    local text = string.gsub(rawText or "", "^%s*(.-)%s*$", "%1")
    if text == "" then
      return nil
    end

    local sid = tonumber(text)
    if sid and sid > 0 then
      local sidStr = tostring(sid)
      local displayName = sidStr

      if type(GetSpellNameAndRankForId) == "function" then
        local ok, sn = pcall(GetSpellNameAndRankForId, sid)
        if ok and sn and sn ~= "" then
          displayName = tostring(sn)
        end
      end

      return {
        name = displayName,
        spellid = sidStr,
        Addedviaspellid = true,
      }
    end

    return {
      name = AuraCond_TitleCase(text),
      spellid = nil,
      Addedviaspellid = nil,
    }
  end

  -- 仅更新层数控件的可见性 + 继续按钮的启用状态。
  -- 重要：这不会重建整个行，因此编辑框保持焦点。
  local function AuraCond_UpdateStacksUI(row)
    if not row then return end

    local enabled = row._stacksEnabled and true or false

    if row.stacksCompDD then
      if enabled then row.stacksCompDD:Show() else row.stacksCompDD:Hide() end
    end
    if row.stacksVal then
      if enabled then row.stacksVal:Show() else row.stacksVal:Hide() end
    end
    if row.stacksValEnter then
      if enabled then row.stacksValEnter:Show() else row.stacksValEnter:Hide() end
    end

    -- 如果：- 层数未启用 或者 启用并且比较器已选且值非空，则继续按钮启用
    local ok = true
    if enabled then
      local comp = row._stacksComp
      local val  = row._stacksVal
      comp = string.gsub(tostring(comp or ""), "^%s*(.-)%s*$", "%1")
      val  = string.gsub(tostring(val  or ""), "^%s*(.-)%s*$", "%1")
      if comp == "" or val == "" then
        ok = false
      end
    end
    if row.okBtn and row.okBtn.SetEnabled then
      row.okBtn:SetEnabled(ok and 1 or 0)
    end
  end

  local function AuraCond_SetRowState(row, state)
    row._state = state

    -- 默认隐藏所有内容
    row.btn1:Hide()
    row.btn2:Hide()
    if row.btn3 then row.btn3:Hide() end
    if row.btn4 then row.btn4:Hide() end
    row.closeBtn:Show()
    row.okBtn:Hide()
    row.editBox:Hide()
    row.addButton:Hide()
    row.labelFS:Hide()
    if row.abilityDD then row.abilityDD:Hide() end
    if row.itemDD then row.itemDD:Hide() end

    if row.stacksLabel then row.stacksLabel:Hide() end
    if row.stacksCB then row.stacksCB:Hide() end
    if row.stacksCompDD then row.stacksCompDD:Hide() end
    if row.stacksVal then row.stacksVal:Hide() end
    if row.stacksValEnter then row.stacksValEnter:Hide() end

    -- 缓存的布局参数
    local spacing = row._spacing or 4
    local parentWidth = row._parentWidth or 260
    local closeWidth = row._closeWidth or 20
    local okWidth = row._okWidth or 20


    if state == "STEP1" then
      row._branch = nil

      local available = parentWidth - closeWidth - spacing * 6
      if available < 80 then available = 80 end
      local w = math.floor(available / 5)

      row.btn1:SetWidth(w)
      row.btn2:SetWidth(w)
      row.addButton:SetWidth(w)
      if row.btn3 then row.btn3:SetWidth(w) end
      if row.btn4 then row.btn4:SetWidth(w) end

      row.btn1:ClearAllPoints()
      row.btn2:ClearAllPoints()
      row.addButton:ClearAllPoints()
      if row.btn3 then row.btn3:ClearAllPoints() end
      if row.btn4 then row.btn4:ClearAllPoints() end

      row.btn1:SetPoint("LEFT", row, "LEFT", 0, 0)
      row.btn2:SetPoint("LEFT", row.btn1, "RIGHT", spacing, 0)
      row.addButton:SetPoint("LEFT", row.btn2, "RIGHT", spacing, 0)
      if row.btn3 then row.btn3:SetPoint("LEFT", row.addButton, "RIGHT", spacing, 0) end
      if row.btn4 then row.btn4:SetPoint("LEFT", row.btn3, "RIGHT", spacing, 0) end

      row.btn1:SetText("技能")
      row.btn2:SetText("增益")
      row.addButton:SetText("减益")
      if row.btn3 then row.btn3:SetText("天赋") end
      if row.btn4 then row.btn4:SetText("物品") end

      row.btn1:Show()
      row.btn2:Show()
      row.addButton:Show()
      if row.btn3 then row.btn3:Show() end
      if row.btn4 then row.btn4:Show() end

    elseif state == "STEP2" then
      local available = parentWidth - closeWidth - spacing * 3
      if available < 120 then available = 120 end
      local w = math.floor(available / 2)

      row.btn1:SetWidth(w)
      row.btn2:SetWidth(w)

      row.btn1:ClearAllPoints()
      row.btn2:ClearAllPoints()
      row.btn1:SetPoint("LEFT", row, "LEFT", 0, 0)
      row.btn2:SetPoint("LEFT", row.btn1, "RIGHT", spacing, 0)

      if row._branch == "ABILITY" then
        row.btn1:SetText("不在冷却中")
        row.btn2:SetText("冷却中")
      elseif row._branch == "ITEM" then
        row.btn1:SetText("在背包/已装备")
        row.btn2:SetText("缺失")
      elseif row._branch == "TALENT" then
        row.btn1:SetText("已学习")
        row.btn2:SetText("未学习")
      else
        row.btn1:SetText("存在")
        row.btn2:SetText("缺失")
      end

      row.btn1:Show()
      row.btn2:Show()

    elseif state == "STEP3" then
      local available = parentWidth - closeWidth - spacing * 3
      if available < 120 then available = 120 end
      local w = math.floor(available / 2)

      row.btn1:SetWidth(w)
      row.btn2:SetWidth(w)

      row.btn1:ClearAllPoints()
      row.btn2:ClearAllPoints()
      row.btn1:SetPoint("LEFT", row, "LEFT", 0, 0)
      row.btn2:SetPoint("LEFT", row.btn1, "RIGHT", spacing, 0)

      if row._branch == "ITEM" then
        row.btn1:SetText("不在冷却中")
        row.btn2:SetText("冷却中")
      else
        row.btn1:SetText("玩家自身")
        row.btn2:SetText("目标")
      end
      row.btn1:Show()
      row.btn2:Show()

    elseif state == "STACKS" then
      -- 布局：层数？ [ ] [DD] [编辑框] (#) [✓] [X]
      row.okBtn:Show()

      -- 右侧按钮
      row.closeBtn:ClearAllPoints()
      row.okBtn:ClearAllPoints()
      row.closeBtn:SetPoint("RIGHT", row, "RIGHT", 0, 0)
      row.okBtn:SetPoint("RIGHT", row.closeBtn, "LEFT", -spacing, 0)

      -- 左侧层数控件
      if row.stacksLabel then
        row.stacksLabel:ClearAllPoints()
        row.stacksLabel:SetPoint("LEFT", row, "LEFT", 0, 0)
        if row._branch == "ITEM" then row.stacksLabel:SetText("数量?") else row.stacksLabel:SetText("层数?") end
        row.stacksLabel:Show()
      end
      if row.stacksCB then
        row.stacksCB:ClearAllPoints()
        row.stacksCB:SetPoint("LEFT", row, "LEFT", 52, 0)
        row.stacksCB:Show()
        row.stacksCB:SetChecked(row._stacksEnabled and true or false)
      end
      if row.stacksCompDD then
        row.stacksCompDD:ClearAllPoints()
        row.stacksCompDD:SetPoint("LEFT", row, "LEFT", 57, -3)
      end
      if row.stacksVal then
        row.stacksVal:ClearAllPoints()
        row.stacksVal:SetPoint("LEFT", row, "LEFT", 142, 0)
      end
      if row.stacksValEnter then
        row.stacksValEnter:ClearAllPoints()
        row.stacksValEnter:SetPoint("LEFT", row.stacksVal, "RIGHT", 4, 0)
      end

      AuraCond_UpdateStacksUI(row)

    elseif state == "INPUT" then
      local addWidth = row.addButton:GetWidth() or 40
      local rightGap = 2
      local totalRight = closeWidth + spacing + addWidth + rightGap

      local editWidth = parentWidth - spacing - totalRight
      if editWidth < 60 then editWidth = 60 end

      row.editBox:ClearAllPoints()
      row.addButton:ClearAllPoints()
      if row.abilityDD then row.abilityDD:ClearAllPoints() end
      if row.itemDD then row.itemDD:ClearAllPoints() end

      row.editBox:SetWidth(editWidth)
      row.editBox:SetPoint("LEFT", row, "LEFT", 10, 0)

      row.addButton:SetPoint("RIGHT", row.closeBtn, "LEFT", -rightGap, 0)
      row.addButton:SetText("添加")

      if row._branch == "ABILITY" then
        if row.abilityDD then
          row.editBox:Hide()
          row.abilityDD:SetPoint("LEFT", row, "LEFT", -15, -3)
          if UIDropDownMenu_SetWidth then
            pcall(UIDropDownMenu_SetWidth, editWidth, row.abilityDD)
          end
          AuraCond_InitAbilityDropdown(row)
          row.abilityDD:Show()
        end
        row.addButton:Show()
      elseif row._branch == "ITEM" then
        if row.itemDD then
          row.editBox:Hide()
          row.itemDD:SetPoint("LEFT", row, "LEFT", -15, -3)
          if UIDropDownMenu_SetWidth then
            pcall(UIDropDownMenu_SetWidth, editWidth, row.itemDD)
          end
          AuraCond_InitItemDropdown(row)
          row.itemDD:Show()
        end
        row.addButton:Show()
      else
        row.editBox:Show()
        row.addButton:Show()
      end

    elseif state == "SAVED" then
      row.labelFS:SetText(row._desc or "")
      row.labelFS:Show()
    end
  end

  local function AuraCond_OnCancelEditing(row)
    -- 将单个编辑行重置回第一步
    row._branch = nil
    row._choiceBuffType = nil
    row._choiceMode = nil
    row._choiceUnit = nil
    row._spellName = nil
    row._itemName = nil
    row._choiceItemCd = nil
    row._abilityPage = 1

    -- 层数重置
    row._stacksEnabled = nil
    row._stacksComp = nil
    row._stacksVal = nil

    if row.stacksCB then
      row.stacksCB:SetChecked(false)
    end
    if row.stacksVal and row.stacksVal.SetText then
      row.stacksVal:SetText("")
    end
    if row.stacksCompDD then
      if UIDropDownMenu_ClearAll then
        pcall(UIDropDownMenu_ClearAll, row.stacksCompDD)
      end
      if UIDropDownMenu_SetText then
        pcall(UIDropDownMenu_SetText, "", row.stacksCompDD)
      end
    end

    if row.editBox and row.editBox.SetText then
      row.editBox:SetText("")
    end

    if row.abilityDD then
      if UIDropDownMenu_ClearAll then
        pcall(UIDropDownMenu_ClearAll, row.abilityDD)
      end
      if UIDropDownMenu_SetText then
        pcall(UIDropDownMenu_SetText, "选择技能", row.abilityDD)
      end
    end

    AuraCond_SetRowState(row, "STEP1")
  end

  local function AuraCond_RebuildFromDB_Internal(typeKey)

    local mgr = AuraCond_Managers[typeKey]
    if not mgr or not mgr.anchor then
      return
    end

    local list = AuraCond_GetListForType(typeKey) or {}
    local count = AuraCond_Len(list)

    if not mgr.savedRows then
      mgr.savedRows = {}
    end

    -- 从数据库构建/更新已保存的行
    local i
    for i = 1, count do
      local entry = list[i]
      local row = mgr.savedRows[i]
      if not row then
        row = mgr._createRow(mgr, false)
        mgr.savedRows[i] = row
      end
      row._entryIndex = i
      row._choiceBuffType = (entry and entry.buffType) or "BUFF"
      row._choiceMode = (entry and entry.mode) or "found"
      row._choiceUnit = (entry and entry.unit) or "player"
      row._spellName = (entry and entry.name) or ""
      row._itemName = (entry and entry.name) or ""
      row._choiceItemCd = (entry and entry.unit) or "notcd"
      row._stacksEnabled = (entry and entry.stacksEnabled) and true or nil
      row._stacksComp    = (entry and entry.stacksComp) or nil
      row._stacksVal     = (entry and entry.stacksVal) or nil

      row._desc = AuraCond_BuildDescription(
        row._choiceBuffType,
        row._choiceMode,
        row._choiceUnit,
        row._spellName,
        row._stacksEnabled,
        row._stacksComp,
        row._stacksVal
      )
      AuraCond_SetRowState(row, "SAVED")
      row:Show()
    end

    -- 隐藏超出数据库长度的额外已保存行
    local nRows = AuraCond_Len(mgr.savedRows)
    for i = count + 1, nRows do
      if mgr.savedRows[i] then
        mgr.savedRows[i]:Hide()
        mgr.savedRows[i]._entryIndex = nil
      end
    end

    -- 确保底部有一个编辑行
    if not mgr.editRow then
      mgr.editRow = mgr._createRow(mgr, true)
    end
    AuraCond_OnCancelEditing(mgr.editRow)
    mgr.editRow:Show()

    -- 布局：标签在0，然后行向下排列
    local y = -14

    -- 已保存的行
    i = 1
    while mgr.savedRows and mgr.savedRows[i] do
      local row = mgr.savedRows[i]
      if row:IsShown() then
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", mgr.anchor, "TOPLEFT", 0, y)
        row:SetPoint("TOPRIGHT", mgr.anchor, "TOPRIGHT", 0, y)
        y = y - 18
      end
      i = i + 1
    end

    -- 逻辑按钮位于最后一条条件行下方（仅当≥2时）
    local list = AuraCond_GetListForType(typeKey) or {}
    local count = AuraCond_Len(list)

    if mgr.logicButton then
      if count >= 2 then
        mgr.logicButton:Show()
        mgr.logicButton:ClearAllPoints()
        mgr.logicButton:SetPoint("TOPLEFT", mgr.anchor, "TOPLEFT", 0, y)
        mgr.logicButton:SetWidth(110)
        y = y - 20
      else
        mgr.logicButton:Hide()
      end
    end

    -- 编辑行在逻辑按钮下方（如果有）
    if mgr.editRow and mgr.editRow:IsShown() then
      mgr.editRow:ClearAllPoints()
      mgr.editRow:SetPoint("TOPLEFT", mgr.anchor, "TOPLEFT", 0, y)
      mgr.editRow:SetPoint("TOPRIGHT", mgr.anchor, "TOPRIGHT", 0, y)
      y = y - 18
    end

    mgr.anchor:SetHeight(-y + 4)
    _ReflowCondAreaHeight()
  end

  local function AuraCond_OnAdd(row)
    if not currentKey then
      return
    end
    local mgr = row._manager
    if not mgr then
      return
    end

    local text
    if row._branch == "ABILITY" then
      text = row._spellName or ""
    elseif row._branch == "ITEM" then
      text = row._itemName or ""
    else
      text = row.editBox and row.editBox:GetText() or ""
    end
    local parsedInput = AuraCond_ParseAuraInput(text)
    if not parsedInput then
      return
    end

    local buffType = row._choiceBuffType or "BUFF"
    local mode = row._choiceMode or "found"
    local unit

    if row._branch == "ABILITY" then
      unit = nil
      buffType = "ABILITY"
    elseif row._branch == "ITEM" then
      if row._choiceMode == "missing" then
        unit = nil
      else
        unit = row._choiceItemCd or "notcd"
      end
      buffType = "ITEM"
    elseif row._branch == "TALENT" then
      -- 天赋行没有单位字段；保持buffType = "TALENT"
      unit = nil
    else
      unit = row._choiceUnit or "player"
    end

    local list = AuraCond_GetListForType(mgr.typeKey)
    if not list then
      return
    end

    local entry = {
      buffType = buffType,
      mode = mode,
      unit = unit,
      name = parsedInput.name,
      spellid = parsedInput.spellid,
      Addedviaspellid = parsedInput.Addedviaspellid,
    }

    -- 仅对于光环（增益/减益），存储可选的层数设置
    if row._branch ~= "ABILITY" and row._branch ~= "TALENT" then
      entry.stacksEnabled = row._stacksEnabled and true or nil
      if entry.stacksEnabled then
        entry.stacksComp = row._stacksComp
        entry.stacksVal  = row._stacksVal
      else
        entry.stacksComp = nil
        entry.stacksVal  = nil
      end
    end

    local n = AuraCond_Len(list)
    list[n + 1] = entry

    -- 重建，以便出现一个新的已保存行和一个干净的新编辑行
    AuraCond_RebuildFromDB_Internal(mgr.typeKey)
  end

  local function AuraCond_OnDeleteSaved(row)
    if not currentKey then
      return
    end
    local mgr = row._manager
    if not mgr then
      return
    end

    local list = AuraCond_GetListForType(mgr.typeKey)
    if not list then
      return
    end

    local idx = row._entryIndex or 0
    local n = AuraCond_Len(list)
    if idx < 1 or idx > n then
      return
    end

    -- 记住此条目是否带有括号；只有在这种情况下才允许逻辑重置（“不影响括号”规则）。
    local deletedEntry = list[idx]
    local hadParens = deletedEntry and (deletedEntry.parenOpen or deletedEntry.parenClose)

    -- 压缩数组：将idx之后的所有元素前移
    local i
    for i = idx, n - 1 do
      list[i] = list[i + 1]
    end
    list[n] = nil

    -- 如果此删除破坏了括号结构，将此typeKey的图标逻辑重置为纯AND且无括号，并通知。
    if hadParens and DoiteLogic and DoiteLogic.ValidateOrResetCurrentLogic then
      DoiteLogic.ValidateOrResetCurrentLogic(mgr.typeKey)
    end

    AuraCond_RebuildFromDB_Internal(mgr.typeKey)
  end

  -- 简单计数器，使每个下拉框获得唯一的框架名称
  local AuraCond_RowCounter = (AuraCond_RowCounter or 0)

  local function AuraCond_InitComparatorDD(ddframe, commitFunc)
    UIDropDownMenu_Initialize(ddframe, function(frame, level, menuList)
      local info
      local choices = { ">=", "<=", "==" }
      for _, c in ipairs(choices) do
        local picked = c
        info = {}
        info.text = picked
        info.value = picked
        info.func = function(button)
          local val = (button and button.value) or picked
          if commitFunc then
            pcall(commitFunc, val)
          end
          UIDropDownMenu_SetSelectedValue(ddframe, val)
          UIDropDownMenu_SetText(val, ddframe)
          CloseDropDownMenus()
        end
        info.checked = (UIDropDownMenu_GetSelectedValue(ddframe) == picked)
        UIDropDownMenu_AddButton(info)
      end
    end)
  end


  local function AuraCond_CreateRow(mgr, isEditing)
    AuraCond_RowCounter = AuraCond_RowCounter + 1

    local parent = mgr.anchor
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(18)

    row._manager = mgr
    row._abilityPage = 1

    -- 在行上缓存布局参数，以便SetRowState重用
    local parentWidth = (parent and parent.GetWidth and parent:GetWidth()) or 0
    if parentWidth <= 0 then
      parentWidth = 260
    end
    local closeWidth = 20
    local spacing = 4
    local mainWidth = math.floor((parentWidth - closeWidth - spacing * 3) / 2)

    row._parentWidth = parentWidth
    row._closeWidth = closeWidth
    row._spacing = spacing
    row._mainWidth = mainWidth

    -- 主要2个按钮
    row.btn1 = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    row.btn2 = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    row.btn3 = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    row.btn4 = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    row.closeBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    row.editBox = CreateFrame("EditBox", nil, row)
    row.addButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    row.labelFS = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")

    row.editBox:SetAutoFocus(false)
    row.editBox:SetFontObject("GameFontNormalSmall")
    if row.editBox.SetTextInsets then
      row.editBox:SetTextInsets(6, 6, 0, 0)
    end
    if row.editBox.SetBackdrop then
      row.editBox:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
      })
      row.editBox:SetBackdropColor(0, 0, 0, 0.85)
      row.editBox:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
    end

    local ddName = "DoiteAuraCond_AbilityDD_" .. tostring(mgr.typeKey or "X") .. "_" .. tostring(AuraCond_RowCounter)
    row.abilityDD = CreateFrame("Frame", ddName, row, "UIDropDownMenuTemplate")
    row.itemDD = CreateFrame("Frame", "DoiteAuraCond_ItemDD_" .. tostring(mgr.typeKey or "X") .. "_" .. tostring(AuraCond_RowCounter), row, "UIDropDownMenuTemplate")

    -- ✓ 按钮（位于内容和X之间），在STACKS阶段使用
    row.okBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    row.okBtn:SetWidth(60)
    row.okBtn:SetHeight(18)
    row.okBtn:SetText("继续") -- 如果客户端字体无法显示，请改为"OK"

    -- 层数界面（仅在STACKS阶段使用）
    row.stacksLabel = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.stacksLabel:SetText("层数?")

    row.stacksCB = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
    row.stacksCB:SetWidth(18); row.stacksCB:SetHeight(18)

    -- 比较器下拉框（默认空白）
    local dd2Name = "DoiteAuraCond_StacksCompDD_" .. tostring(mgr.typeKey or "X") .. "_" .. tostring(AuraCond_RowCounter)
    row.stacksCompDD = CreateFrame("Frame", dd2Name, row, "UIDropDownMenuTemplate")

    -- 使层数比较器下拉框更窄
    row._stacksCompWidth = 45
    if UIDropDownMenu_SetWidth then
      pcall(UIDropDownMenu_SetWidth, row._stacksCompWidth, row.stacksCompDD)
    end

    row.stacksVal = CreateFrame("EditBox", nil, row)
    row.stacksVal:SetWidth(40)
    row.stacksVal:SetHeight(18)
    row.stacksVal:SetAutoFocus(false)
    row.stacksVal:SetFontObject("GameFontNormalSmall")
    if row.stacksVal.SetTextInsets then
      row.stacksVal:SetTextInsets(6, 6, 0, 0)
    end
    if row.stacksVal.SetBackdrop then
      row.stacksVal:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
      })
      row.stacksVal:SetBackdropColor(0, 0, 0, 0.85)
      row.stacksVal:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
    end

    row.stacksValEnter = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.stacksValEnter:SetText("(#)")

    row.btn1:SetWidth(mainWidth)
    row.btn2:SetWidth(mainWidth)
    row.btn3:SetWidth(mainWidth)
    row.btn4:SetWidth(mainWidth)
    row.btn1:SetHeight(18)
    row.btn2:SetHeight(18)
    row.btn3:SetHeight(18)
    row.btn4:SetHeight(18)

    row.closeBtn:SetWidth(closeWidth)
    row.closeBtn:SetHeight(18)

    -- 初始编辑框宽度；将在INPUT状态重新计算
    local editWidth = parentWidth - closeWidth - spacing * 3 - 40
    if editWidth < 60 then
      editWidth = 60
    end

    row.editBox:SetWidth(editWidth)
    row.editBox:SetHeight(18)
    row.editBox:SetAutoFocus(false)
    row.editBox:SetFontObject("GameFontNormalSmall")

    row.addButton:SetWidth(40)
    row.addButton:SetHeight(18)

    -- 默认位置（用于STEP2/STEP3/SAVED）；STEP1/INPUT将覆盖布局
    row.btn1:SetPoint("LEFT", row, "LEFT", 0, 0)
    row.btn2:SetPoint("LEFT", row.btn1, "RIGHT", spacing, 0)
    row.closeBtn:SetPoint("RIGHT", row, "RIGHT", 0, 0)

    row.editBox:SetPoint("LEFT", row, "LEFT", 0, 0)
    row.addButton:SetPoint("LEFT", row.editBox, "RIGHT", spacing, 0)

    -- 技能下拉框位于编辑框的位置（INPUT状态两者互换）
    row.abilityDD:SetPoint("LEFT", row, "LEFT", 0, -2)
    if UIDropDownMenu_SetWidth then
      pcall(UIDropDownMenu_SetWidth, parentWidth - closeWidth - spacing * 3 - 40, row.abilityDD)
    end

    row.labelFS:SetPoint("LEFT", row, "LEFT", 0, 0)
    row.labelFS:SetTextColor(1, 1, 1)
    -- 无固定宽度：长描述保持单行，可能在右侧被截断
    row.labelFS:SetNonSpaceWrap(false)

    row.closeBtn:SetText("X")

    DoiteEdit_YellowifyButton(row.btn1)
    DoiteEdit_YellowifyButton(row.btn2)
    DoiteEdit_YellowifyButton(row.btn3)
    DoiteEdit_YellowifyButton(row.btn4)
    DoiteEdit_YellowifyButton(row.addButton)
    DoiteEdit_YellowifyButton(row.closeBtn)
    DoiteEdit_YellowifyButton(row.okBtn)

    -- 进度按钮：
    row.btn1:SetScript("OnClick", function()
      if not currentKey then
        return
      end
      local state = row._state

      if state == "STEP1" then
        -- 技能
        row._branch = "ABILITY"
        row._choiceBuffType = "ABILITY"
        row._choiceMode = nil
        row._choiceUnit = nil
        AuraCond_SetRowState(row, "STEP2")

      elseif state == "STEP2" then
        if row._branch == "ABILITY" then
          -- 技能：不在冷却中
          row._choiceMode = "notcd"
          AuraCond_SetRowState(row, "INPUT")

        elseif row._branch == "ITEM" then
          row._choiceMode = "found"
          AuraCond_SetRowState(row, "STEP3")

        elseif row._branch == "TALENT" then
          -- 天赋：已学习
          row._choiceMode = "Known"
          AuraCond_SetRowState(row, "INPUT")

        else
          -- 光环：存在
          row._choiceMode = "found"
          AuraCond_SetRowState(row, "STEP3")
        end

      elseif state == "STEP3" then
        if row._branch == "ITEM" then
          row._choiceItemCd = "notcd"
          if row._choiceMode == "missing" then
            AuraCond_SetRowState(row, "INPUT")
          else
            AuraCond_SetRowState(row, "STACKS")
          end
          return
        end
        -- 光环：玩家自身
        row._choiceUnit = "player"

        -- 如果模式是"missing"，跳过STACKS阶段
        if row._choiceMode == "missing" then
          AuraCond_SetRowState(row, "INPUT")
        else
          AuraCond_SetRowState(row, "STACKS")
        end
      end
    end)

    row.btn2:SetScript("OnClick", function()
      if not currentKey then
        return
      end
      local state = row._state

      if state == "STEP1" then
        -- 增益（光环）
        row._branch = "AURA"
        row._choiceBuffType = "BUFF"
        row._choiceMode = nil
        row._choiceUnit = nil
        AuraCond_SetRowState(row, "STEP2")

      elseif state == "STEP2" then
        if row._branch == "ABILITY" then
          -- 技能：冷却中
          row._choiceMode = "oncd"
          AuraCond_SetRowState(row, "INPUT")

        elseif row._branch == "ITEM" then
          row._choiceMode = "missing"
          row._choiceItemCd = nil
          row._stacksEnabled = nil
          row._stacksComp = nil
          row._stacksVal  = nil
          AuraCond_SetRowState(row, "INPUT")

        elseif row._branch == "TALENT" then
          -- 天赋：未学习
          row._choiceMode = "Not Known"
          AuraCond_SetRowState(row, "INPUT")

        else
          -- 光环：缺失（不可能有层数）
          row._choiceMode = "missing"

          -- 硬重置层数，确保“缺失 + 层数”永远不会被存储/使用
          row._stacksEnabled = nil
          row._stacksComp = nil
          row._stacksVal  = nil
          if row.stacksCB then
            row.stacksCB:SetChecked(false)
          end
          if row.stacksVal and row.stacksVal.SetText then
            row.stacksVal:SetText("")
          end
          if row.stacksCompDD then
            if UIDropDownMenu_ClearAll then
              pcall(UIDropDownMenu_ClearAll, row.stacksCompDD)
            end
            if UIDropDownMenu_SetText then
              pcall(UIDropDownMenu_SetText, "", row.stacksCompDD)
            end
          end

          AuraCond_SetRowState(row, "STEP3")
        end

      elseif state == "STEP3" then
        if row._branch == "ITEM" then
          row._choiceItemCd = "oncd"
          if row._choiceMode == "missing" then
            AuraCond_SetRowState(row, "INPUT")
          else
            AuraCond_SetRowState(row, "STACKS")
          end
          return
        end
        -- 光环：目标
        row._choiceUnit = "target"

        -- 如果模式是"missing"，跳过STACKS阶段
        if row._choiceMode == "missing" then
          AuraCond_SetRowState(row, "INPUT")
        else
          AuraCond_SetRowState(row, "STACKS")
        end
      end
    end)

    row.btn3:SetScript("OnClick", function()
      if not currentKey then
        return
      end
      local state = row._state

      if state == "STEP1" then
        -- 天赋分支
        row._branch = "TALENT"
        row._choiceBuffType = "TALENT"
        row._choiceMode = nil
        row._choiceUnit = nil
        AuraCond_SetRowState(row, "STEP2")
      end
    end)

    row.btn4:SetScript("OnClick", function()
      if not currentKey then
        return
      end
      if row._state == "STEP1" then
        row._branch = "ITEM"
        row._choiceBuffType = "ITEM"
        row._choiceMode = nil
        row._choiceUnit = nil
        row._choiceItemCd = nil
        AuraCond_SetRowState(row, "STEP2")
      end
    end)

    row.addButton:SetText("添加")
    row.addButton:SetScript("OnClick", function()
      if not currentKey then
        return
      end
      local state = row._state

      if state == "STEP1" then
        -- 减益（光环）第三个选项
        row._branch = "AURA"
        row._choiceBuffType = "DEBUFF"
        row._choiceMode = nil
        row._choiceUnit = nil
        AuraCond_SetRowState(row, "STEP2")
        return
      end

      if state == "INPUT" then
        AuraCond_OnAdd(row)
      end
    end)

    row.editBox:SetScript("OnEnterPressed", function()
      if not currentKey then
        return
      end
      AuraCond_OnAdd(row)
      if this and this.ClearFocus then
        this:ClearFocus()
      end
    end)

    row.closeBtn:SetScript("OnClick", function()
      if row._state == "SAVED" then
        AuraCond_OnDeleteSaved(row)
      else
        -- 编辑行；始终重置到第一步
        AuraCond_OnCancelEditing(row)
        _ReflowCondAreaHeight()
      end
    end)

    -- 初始化比较器下拉框（空白文本）
    AuraCond_InitComparatorDD(row.stacksCompDD, function(val)
      row._stacksComp = val
      -- 仅刷新“继续”按钮的启用状态（不要重建行）
      if row._state == "STACKS" then
        AuraCond_UpdateStacksUI(row)
      end
    end)
    if UIDropDownMenu_SetText then
      pcall(UIDropDownMenu_SetText, "", row.stacksCompDD)
    end

    row.stacksCB:SetScript("OnClick", function()
      row._stacksEnabled = this:GetChecked() and true or nil
      if not row._stacksEnabled then
        row._stacksComp = nil
        row._stacksVal  = nil
        if row.stacksVal and row.stacksVal.SetText then
          row.stacksVal:SetText("")
        end
        if UIDropDownMenu_ClearAll then
          pcall(UIDropDownMenu_ClearAll, row.stacksCompDD)
        end
        if UIDropDownMenu_SetText then
          pcall(UIDropDownMenu_SetText, "", row.stacksCompDD)
        end
      end

      if row._state == "STACKS" then
        AuraCond_UpdateStacksUI(row)
      end
    end)

    row.stacksVal:SetScript("OnTextChanged", function()
      row._stacksVal = row.stacksVal:GetText()
      if row._state == "STACKS" then
        AuraCond_UpdateStacksUI(row)
      end
    end)

    row.okBtn:SetScript("OnClick", function()
      if not currentKey then return end
      if row._state ~= "STACKS" then return end

      -- 如果层数启用，需要比较器和值
      if row._stacksEnabled then
        local comp = string.gsub(tostring(row._stacksComp or ""), "^%s*(.-)%s*$", "%1")
        local val  = string.gsub(tostring(row._stacksVal  or ""), "^%s*(.-)%s*$", "%1")
        if comp == "" or val == "" then
          return
        end
      end

      AuraCond_SetRowState(row, "INPUT")
    end)

    if isEditing then
      AuraCond_OnCancelEditing(row)
    else
      row._state = "SAVED"
      AuraCond_SetRowState(row, "SAVED")
    end

    row:Hide()
    return row
  end

  AuraCond_RegisterManager = function(typeKey, anchorFrame)
    if not anchorFrame then
      return
    end

    local mgr = AuraCond_Managers[typeKey]
    if not mgr then
      mgr = {}
      AuraCond_Managers[typeKey] = mgr
    end

    mgr.typeKey = typeKey
    mgr.anchor = anchorFrame
    mgr.savedRows = mgr.savedRows or {}
    mgr.editRow = mgr.editRow or nil
    mgr._createRow = AuraCond_CreateRow

    -- 此部分的标题标签
    if not mgr.label then
      local label = anchorFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
      label:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT", 0, 0)
      label:SetJustifyH("LEFT")
      label:SetTextColor(1, 0.82, 0)
      label:SetText("添加额外的可见性条件以显示/隐藏：")
      mgr.label = label
    end

    -- 每个管理器创建一个“与/或逻辑”按钮
    if not mgr.logicButton then
      local btnName = "DoiteAuraLogicButton_" .. tostring(typeKey)
      -- 父级必须是同一个滚动子锚点框架，以便随行滚动
      local btn = CreateFrame("Button", btnName, anchorFrame, "UIPanelButtonTemplate")
      btn:SetWidth(50)
      btn:SetHeight(18)
      btn:SetText("与/或 逻辑")

      -- 将其放置在锚点框架的同一顶部行右侧
      btn:ClearAllPoints()
      btn:SetPoint("TOPRIGHT", anchorFrame, "TOPRIGHT", 0, 0)

      -- 确保其绘制在滚动子内容之上
      if btn.SetFrameStrata then
        btn:SetFrameStrata("HIGH")
      end
      if anchorFrame.GetFrameLevel and btn.SetFrameLevel then
        btn:SetFrameLevel(anchorFrame:GetFrameLevel() + 1)
      end

      -- 黄色小文本，类似于其他小按钮
      local fs = btn:GetFontString()
      if fs and fs.SetTextColor then
        fs:SetTextColor(1, 0.82, 0)
      end

      btn:Hide()

      btn:SetScript("OnClick", function()
        local DL = _G["DoiteLogic"]
        if DL and DL.OpenAuraLogicEditor then
          DL.OpenAuraLogicEditor(typeKey)   -- 或 "ability"/"item"
        end
      end)

      mgr.logicButton = btn
    end

    -- 基础高度：行将通过AuraCond_CreateRow / 刷新扩展此高度
    anchorFrame:SetHeight(20)
    anchorFrame:Hide()
  end

  AuraCond_RefreshFromDB = function(typeKey)
    local tk, mgr
    for tk, mgr in pairs(AuraCond_Managers) do
      if mgr.anchor then
        if tk == typeKey then
          mgr.anchor:Show()
        else
          mgr.anchor:Hide()
        end
      end
    end

    if typeKey then
      AuraCond_RebuildFromDB_Internal(typeKey)
    end
    _ReflowCondAreaHeight()
  end

  AuraCond_ResetEditing = function()
    -- 目前无操作；所有编辑状态在AuraCond_RefreshFromDB中从数据库重建
  end
end

----------------------------------------------------------------
-- VfxCond：视觉效果条件系统
-- （使用与AuraCond相同的技能/增益/减益/天赋界面，但存储到vfxConds）
----------------------------------------------------------------
do
  -- VfxCond共享AuraCond的行状态机和界面，但使用不同的管理器和数据存储。
  -- 通过引用重用AuraCond_SetRowState、AuraCond_BuildDescription等。

  local function VfxCond_GetListForType(typeKey)
    if not currentKey then
      DEFAULT_CHAT_FRAME:AddMessage("|cffff0000GetList: 没有currentKey|r")
      return nil
    end

    local d = EnsureDBEntry(currentKey)
    if not d then
      DEFAULT_CHAT_FRAME:AddMessage("|cffff0000GetList: EnsureDBEntry失败，键为'"..tostring(currentKey).."'|r")
      return nil
    end

    if not d.conditions then d.conditions = {} end

    if typeKey == "ability" then
      d.conditions.ability = d.conditions.ability or {}
      d.conditions.ability.vfxConditions = d.conditions.ability.vfxConditions or {}
      return d.conditions.ability.vfxConditions

    elseif typeKey == "aura" then
      d.conditions.aura = d.conditions.aura or {}
      d.conditions.aura.vfxConditions = d.conditions.aura.vfxConditions or {}
      return d.conditions.aura.vfxConditions

    elseif typeKey == "item" then
      d.conditions.item = d.conditions.item or {}
      d.conditions.item.vfxConditions = d.conditions.item.vfxConditions or {}
      return d.conditions.item.vfxConditions
    end

    return nil
  end


  local function VfxCond_TitleCase(str)
    if not str then
      return ""
    end

    -- 优先使用AuraCond_TitleCase以保持不同条件系统行为一致
    if AuraCond_TitleCase then
      return AuraCond_TitleCase(str)
    end

    -- 后备（此文件中不应命中）
    str = tostring(str)
    return string.sub(string.gsub(" " .. str, "%W%l", string.upper), 2)
  end

  local function VfxCond_BuildItemOptions()
    local items, seen = {}, {}
    local function _Add(name)
      if not name or name == "" or seen[name] then return end
      seen[name] = true
      table.insert(items, name)
    end
    local function _NameFromLink(link)
      if not link or link == "" then return nil end
      local nm = GetItemInfo and GetItemInfo(link)
      if nm and nm ~= "" then return nm end
      local _, _, txt = string.find(link, "%[(.-)%]")
      return txt
    end
    local i
    for _, i in ipairs({13,14,16,17,18}) do
      _Add(_NameFromLink(GetInventoryItemLink and GetInventoryItemLink("player", i)))
    end
    local bag, slot
    for bag = 0, 4 do
      local n = GetContainerNumSlots and GetContainerNumSlots(bag)
      if n and n > 0 then
        for slot = 1, n do
          _Add(_NameFromLink(GetContainerItemLink and GetContainerItemLink(bag, slot)))
        end
      end
    end
    table.sort(items, function(a, b)
      return string.lower(a or "") < string.lower(b or "")
    end)
    table.insert(items, 1, "---已装备的武器栏位---")
    table.insert(items, 1, "---已装备的饰品栏位---")
    return items
  end

  local function VfxCond_InitItemDropdown(row)
    if not row or not row.itemDD then return end

    local items = VfxCond_BuildItemOptions()
    row._itemOptions = items

    local total = table.getn(items)
    local perPage = 10

    if total == 0 then
      UIDropDownMenu_Initialize(row.itemDD, function() end)
      if UIDropDownMenu_SetText then
        pcall(UIDropDownMenu_SetText, "未找到物品", row.itemDD)
      end
      return
    end

    local maxPage = math.max(1, math.ceil(total / perPage))
    local page = row._itemPage or 1
    if page < 1 then page = 1 end
    if page > maxPage then page = maxPage end
    row._itemPage = page

    local function ReopenItemDDNextFrame()
      local f = row.itemDD and row.itemDD._reopenFrame
      if not f then
        f = CreateFrame("Frame", nil, UIParent)
        if row.itemDD then
          row.itemDD._reopenFrame = f
        end
        f:Hide()
        f:SetScript("OnUpdate", function()
          f:Hide()
          if row and row.itemDD then
            ToggleDropDownMenu(nil, nil, row.itemDD, row.itemDD, 0, 0)
          end
        end)
      end
      f:Show()
    end

    local startIndex = (page - 1) * perPage + 1
    local endIndex = math.min(startIndex + perPage - 1, total)

    UIDropDownMenu_Initialize(row.itemDD, function(frame, level, menuList)
      local info

      if page > 1 then
        info = {}
        info.text = "|cffffd000<< 上一页|r"
        info.value = "PREV"
        info.notCheckable = true
        info.func = function()
          row._itemPage = page - 1
          VfxCond_InitItemDropdown(row)
          if CloseDropDownMenus then
            CloseDropDownMenus()
          end
          ReopenItemDDNextFrame()
        end
        UIDropDownMenu_AddButton(info)
      end

      local idx = startIndex
      while idx <= endIndex do
        local name = items[idx]
        info = {}
        info.text = name
        info.value = name
        local pickedName = name
        info.func = function(button)
          local val = (button and button.value) or pickedName
          row._itemName = val
          if UIDropDownMenu_SetSelectedValue then
            pcall(UIDropDownMenu_SetSelectedValue, row.itemDD, val)
          end
          if UIDropDownMenu_SetText then
            pcall(UIDropDownMenu_SetText, val, row.itemDD)
          end
          if _GoldifyDD then
            _GoldifyDD(row.itemDD)
          end
        end
        info.checked = (row._itemName == name)
        UIDropDownMenu_AddButton(info)
        idx = idx + 1
      end

      if page < maxPage then
        info = {}
        info.text = "|cffffd000下一页 >>|r"
        info.value = "NEXT"
        info.notCheckable = true
        info.func = function()
          row._itemPage = page + 1
          VfxCond_InitItemDropdown(row)
          if CloseDropDownMenus then
            CloseDropDownMenus()
          end
          ReopenItemDDNextFrame()
        end
        UIDropDownMenu_AddButton(info)
      end
    end)

    if UIDropDownMenu_SetText then
      pcall(UIDropDownMenu_SetText, row._itemName or "选择物品", row.itemDD)
    end
    if _GoldifyDD then
      _GoldifyDD(row.itemDD)
    end
  end

  local function VfxCond_BuildDescription(buffType, mode, unit, name, stacksEnabled, stacksComp, stacksVal)
    local niceName = VfxCond_TitleCase(name or "")

    local yellow = "|cffffd000"
    local white  = "|cffffffff"
    local sep    = "|cffffffff | |r"  -- 白色" | "

    -- 规范化输入（VFX可能存储不同的大小写）
    local bt = string.upper(tostring(buffType or ""))
    local m  = string.lower(tostring(mode or ""))
    local u  = string.lower(tostring(unit or ""))

    -- 特殊情况：技能行
    if bt == "ABILITY" then
      local typeColor = "|cff4da6ff" -- 技能蓝色
      local typePart  = typeColor .. "技能" .. "|r"

      local modeWord
      if m == "oncd" then
        modeWord = "冷却中"
      else
        modeWord = "不在冷却中"
      end

      local modePart = yellow .. modeWord .. "|r"
      local namePart = white .. (niceName or "") .. "|r"
      return typePart .. " " .. sep .. modePart .. ": " .. namePart

    elseif bt == "TALENT" then
      local isKnown = (m == "known")
      local stateWord = isKnown and "已学习" or "未学习"
      local stateColor = isKnown and "|cff00ff00" or "|cffff0000"
      local statePart = stateColor .. stateWord .. "|r"

      local talentPart = yellow .. "天赋" .. "|r"
      local namePart   = white .. (niceName or "") .. "|r"
      return talentPart .. " " .. sep .. statePart .. ": " .. namePart
    elseif bt == "ITEM" then
      local whereWord = (m == "missing") and "缺失" or "在背包/已装备"
      local cdWord = (u == "oncd") and "冷却中" or "不在冷却中"
      local itemPart = yellow .. "物品" .. "|r"
      local wherePart = yellow .. whereWord .. "|r"

      local prefix = ""
      if stacksEnabled and stacksComp and stacksComp ~= "" and stacksVal and tostring(stacksVal) ~= "" then
        local sym = stacksComp
        if sym == ">=" then sym = "≥"
        elseif sym == "<=" then sym = "≤"
        elseif sym == "==" then sym = "="
        end
        prefix = tostring(sym) .. tostring(stacksVal) .. "x"
      end

      local namePart = white .. prefix .. (niceName or "") .. "|r"

      if m == "missing" then
        return itemPart .. " " .. sep .. wherePart .. ": " .. namePart
      end

      local cdPart = yellow .. cdWord .. "|r"
      return itemPart .. " " .. sep .. wherePart .. " " .. sep .. cdPart .. ": " .. namePart
    end

    -- 默认：增益/减益光环行
    local isDebuff = (bt == "DEBUFF")
    local typeWord = isDebuff and "减益" or "增益"
    local modeWord = (m == "missing") and "缺失" or "存在"

    local unitWord
    if u == "target" then
      unitWord = "目标"
    else
      unitWord = "玩家"
    end

    local typeColor = isDebuff and "|cffff0000" or "|cff00ff00"
    local typePart = typeColor .. typeWord .. "|r"
    local modePart = yellow .. modeWord .. "|r"
    local unitPart = yellow .. unitWord .. "|r"

    -- 层数前缀：≥5x名称, ≤3x名称, =2x名称
    local prefix = ""
    if stacksEnabled and stacksComp and stacksComp ~= "" and stacksVal and tostring(stacksVal) ~= "" then
      local sym = stacksComp
      if sym == ">=" then sym = "≥"
      elseif sym == "<=" then sym = "≤"
      elseif sym == "==" then sym = "="
      end
      prefix = tostring(sym) .. tostring(stacksVal) .. "x"
    end

    local namePart = white .. prefix .. (niceName or "") .. "|r"
    return typePart .. " " .. sep .. modePart .. " " .. sep .. unitPart .. ": " .. namePart
  end

  local function VfxCond_ParseAuraInput(rawText)
    local text = string.gsub(rawText or "", "^%s*(.-)%s*$", "%1")
    if text == "" then
      return nil
    end

    local sid = tonumber(text)
    if sid and sid > 0 then
      local sidStr = tostring(sid)
      local displayName = sidStr

      if type(GetSpellNameAndRankForId) == "function" then
        local ok, sn = pcall(GetSpellNameAndRankForId, sid)
        if ok and sn and sn ~= "" then
          displayName = tostring(sn)
        end
      end

      return {
        name = displayName,
        spellid = sidStr,
        Addedviaspellid = true,
      }
    end

    return {
      name = VfxCond_TitleCase(text),
      spellid = nil,
      Addedviaspellid = nil,
    }
  end

  local VfxCond_RowCounter = 0

  -- 辅助函数：一帧后重新打开下拉框
  local _vfxDDReopenFrame = CreateFrame("Frame", "DoiteEditVfxReopenFrame")
  local _vfxDDReopenRow = nil

  _vfxDDReopenFrame:Hide()
  _vfxDDReopenFrame:SetScript("OnUpdate", function()
    _vfxDDReopenFrame:Hide()
    if not _vfxDDReopenRow or not _vfxDDReopenRow.abilityDD then
      _vfxDDReopenRow = nil
      return
    end
    ToggleDropDownMenu(nil, nil, _vfxDDReopenRow.abilityDD, _vfxDDReopenRow.abilityDD, 0, 0)
    _vfxDDReopenRow = nil
  end)

  local function VfxCond_ReopenDDNextFrame(row)
    _vfxDDReopenRow = row
    _vfxDDReopenFrame:Show()
  end

  -- 使VfxCond长度行为与AuraCond完全一致（数组样式）
  local function VfxCond_Len(t)
    if not t then return 0 end
    local n = 0
    while t[n + 1] ~= nil do
      n = n + 1
    end
    return n
  end

  -- 从法术书中构建非被动技能的排序列表（与AuraCond相同的逻辑）
  local function VfxCond_BuildAbilitySpellList()
    local spells = {}
    local seen = {}
    local passiveAllow = _G["DA_AbilityDropdownPassiveAllow"] or {}

    local function scanBook(bookType)
      local i = 1
      while true do
        local name, rank = GetSpellName(i, bookType)
        if not name then break end

        local isPassive = false
        if IsPassiveSpell then
          local ok, passive = pcall(IsPassiveSpell, i, bookType)
          if ok and passive then
            isPassive = true
          end
        end
        if (not isPassive) and rank and string.find(rank, "Passive") then
          isPassive = true
        end

        if name and name ~= "" then
          local allowPassive = (passiveAllow[name] == true)
          if ((not isPassive) or allowPassive) and not seen[name] then
            table.insert(spells, name)
            seen[name] = true
          end
        end

        i = i + 1
      end
    end

    scanBook(BOOKTYPE_SPELL)
    scanBook(BOOKTYPE_PET)

    table.sort(spells, function(a, b)
      a = string.lower(a or "")
      b = string.lower(b or "")
      return a < b
    end)

    return spells
  end

  -- 初始化/刷新给定VFX编辑行的技能下拉框
  local function VfxCond_InitAbilityDropdown(row)
    if not row or not row.abilityDD then return end

    local spells = VfxCond_BuildAbilitySpellList()
    row._abilitySpells = spells

    local total = table.getn(spells)
    local perPage = 10

    if total == 0 then
      UIDropDownMenu_Initialize(row.abilityDD, function() end)
      if UIDropDownMenu_SetText then
        pcall(UIDropDownMenu_SetText, "未找到技能", row.abilityDD)
      end
      return
    end

    local maxPage = math.max(1, math.ceil(total / perPage))
    local page = row._abilityPage or 1
    if page < 1 then page = 1 end
    if page > maxPage then page = maxPage end
    row._abilityPage = page

    local startIndex = (page - 1) * perPage + 1
    local endIndex = math.min(startIndex + perPage - 1, total)

    UIDropDownMenu_Initialize(row.abilityDD, function(frame, level, menuList)
      local info

      if page > 1 then
        info = {}
        info.text = "|cffffd000<< 上一页|r"
        info.value = "PREV"
        info.notCheckable = true
        info.func = function()
          row._abilityPage = page - 1
          VfxCond_InitAbilityDropdown(row)
          VfxCond_ReopenDDNextFrame(row)
        end
        UIDropDownMenu_AddButton(info)
      end

      local idx = startIndex
      while idx <= endIndex do
        local name = spells[idx]
        info = {}
        info.text = name
        info.value = name
        local pickedName = name
        info.func = function(button)
          local val = (button and button.value) or pickedName
          row._spellName = val

          if UIDropDownMenu_SetSelectedValue then
            pcall(UIDropDownMenu_SetSelectedValue, row.abilityDD, val)
         end
          if UIDropDownMenu_SetText then
            pcall(UIDropDownMenu_SetText, val, row.abilityDD)
         end
          if _GoldifyDD then
            _GoldifyDD(row.abilityDD)
          end
        end
        info.checked = (row._spellName == name)
        UIDropDownMenu_AddButton(info)
        idx = idx + 1
      end

      if page < maxPage then
        info = {}
        info.text = "|cffffd000下一页 >>|r"
        info.value = "NEXT"
        info.notCheckable = true
        info.func = function()
          row._abilityPage = page + 1
          VfxCond_InitAbilityDropdown(row)
          VfxCond_ReopenDDNextFrame(row)
        end
        UIDropDownMenu_AddButton(info)
      end
    end)

    local label = row._spellName or "选择技能"
    if UIDropDownMenu_SetText then
      pcall(UIDropDownMenu_SetText, label, row.abilityDD)
    end
    if _GoldifyDD then
      _GoldifyDD(row.abilityDD)
    end
  end

  -- 仅更新层数控件的可见性 + 继续按钮的启用状态（不重建行）。
  local function VfxCond_UpdateStacksUI(row)
    if not row then return end

    local enabled = row._stacksEnabled and true or false

    if row.stacksCompDD then
      if enabled then row.stacksCompDD:Show() else row.stacksCompDD:Hide() end
    end
    if row.stacksVal then
      if enabled then row.stacksVal:Show() else row.stacksVal:Hide() end
    end
    if row.stacksValEnter then
      if enabled then row.stacksValEnter:Show() else row.stacksValEnter:Hide() end
    end

    local ok = true
    if enabled then
      local comp = row._stacksComp
      local val  = row._stacksVal
      comp = string.gsub(tostring(comp or ""), "^%s*(.-)%s*$", "%1")
      val  = string.gsub(tostring(val  or ""), "^%s*(.-)%s*$", "%1")
      if comp == "" or val == "" then
        ok = false
      end
    end
    if row.okBtn and row.okBtn.SetEnabled then
      row.okBtn:SetEnabled(ok and 1 or 0)
    end
  end

  local function VfxCond_SetRowState(row, state)
    row._state = state

    row.btn1:Hide()
    row.btn2:Hide()
    if row.btn3 then row.btn3:Hide() end
    if row.btn4 then row.btn4:Hide() end
    row.closeBtn:Show()
    if row.okBtn then row.okBtn:Hide() end
    row.editBox:Hide()
    row.addButton:Hide()
    row.labelFS:Hide()
    if row.abilityDD then row.abilityDD:Hide() end
    if row.itemDD then row.itemDD:Hide() end
    if row.glowCB then row.glowCB:Hide() end
    if row.greyCB then row.greyCB:Hide() end
    if row.fadeCB then row.fadeCB:Hide() end
    if row.fadeSlider then row.fadeSlider:Hide() end
    if row.fadeSliderPct then row.fadeSliderPct:Hide() end

    if row.stacksLabel then row.stacksLabel:Hide() end
    if row.stacksCB then row.stacksCB:Hide() end
    if row.stacksCompDD then row.stacksCompDD:Hide() end
    if row.stacksVal then row.stacksVal:Hide() end
    if row.stacksValEnter then row.stacksValEnter:Hide() end

    local spacing = row._spacing or 4
    local parentWidth = row._parentWidth or 260
    local closeWidth = row._closeWidth or 20

    if state == "STEP1" then
      row._branch = nil
      local available = parentWidth - closeWidth - spacing * 6
      if available < 80 then available = 80 end
      local w = math.floor(available / 5)

      row.btn1:SetWidth(w)
      row.btn2:SetWidth(w)
      row.addButton:SetWidth(w)
      if row.btn3 then row.btn3:SetWidth(w) end
      if row.btn4 then row.btn4:SetWidth(w) end

      row.btn1:ClearAllPoints()
      row.btn2:ClearAllPoints()
      row.addButton:ClearAllPoints()
      if row.btn3 then row.btn3:ClearAllPoints() end
      if row.btn4 then row.btn4:ClearAllPoints() end

      row.btn1:SetPoint("LEFT", row, "LEFT", 0, 0)
      row.btn2:SetPoint("LEFT", row.btn1, "RIGHT", spacing, 0)
      row.addButton:SetPoint("LEFT", row.btn2, "RIGHT", spacing, 0)
      if row.btn3 then row.btn3:SetPoint("LEFT", row.addButton, "RIGHT", spacing, 0) end
      if row.btn4 then row.btn4:SetPoint("LEFT", row.btn3, "RIGHT", spacing, 0) end

      row.btn1:SetText("技能")
      row.btn2:SetText("增益")
      row.addButton:SetText("减益")
      if row.btn3 then row.btn3:SetText("天赋") end
      if row.btn4 then row.btn4:SetText("物品") end

      row.btn1:Show()
      row.btn2:Show()
      row.addButton:Show()
      if row.btn3 then row.btn3:Show() end
      if row.btn4 then row.btn4:Show() end

    elseif state == "STEP2" then
      local available = parentWidth - closeWidth - spacing * 3
      if available < 120 then available = 120 end
      local w = math.floor(available / 2)

      row.btn1:SetWidth(w)
      row.btn2:SetWidth(w)

      row.btn1:ClearAllPoints()
      row.btn2:ClearAllPoints()
      row.btn1:SetPoint("LEFT", row, "LEFT", 0, 0)
      row.btn2:SetPoint("LEFT", row.btn1, "RIGHT", spacing, 0)

      if row._branch == "ABILITY" then
        row.btn1:SetText("不在冷却中")
        row.btn2:SetText("冷却中")
      elseif row._branch == "ITEM" then
        row.btn1:SetText("在背包/已装备")
        row.btn2:SetText("缺失")
      elseif row._branch == "TALENT" then
        row.btn1:SetText("已学习")
        row.btn2:SetText("未学习")
      else
        row.btn1:SetText("存在")
        row.btn2:SetText("缺失")
      end

      row.btn1:Show()
      row.btn2:Show()

    elseif state == "STEP3" then
      local available = parentWidth - closeWidth - spacing * 3
      if available < 120 then available = 120 end
      local w = math.floor(available / 2)

      row.btn1:SetWidth(w)
      row.btn2:SetWidth(w)

      row.btn1:ClearAllPoints()
      row.btn2:ClearAllPoints()
      row.btn1:SetPoint("LEFT", row, "LEFT", 0, 0)
      row.btn2:SetPoint("LEFT", row.btn1, "RIGHT", spacing, 0)

      if row._branch == "ITEM" then
        row.btn1:SetText("不在冷却中")
        row.btn2:SetText("冷却中")
      else
        row.btn1:SetText("玩家自身")
        row.btn2:SetText("目标")
      end
      row.btn1:Show()
      row.btn2:Show()

    elseif state == "STACKS" then
      -- 布局：层数？ [ ] [DD] [编辑框] (#) [继续] [X]
      if row.okBtn then row.okBtn:Show() end

      row.closeBtn:ClearAllPoints()
      if row.okBtn then row.okBtn:ClearAllPoints() end

      row.closeBtn:SetPoint("RIGHT", row, "RIGHT", 0, 0)
      if row.okBtn then
       row.okBtn:SetPoint("RIGHT", row.closeBtn, "LEFT", -spacing, 0)
      end

      if row.stacksLabel then
        row.stacksLabel:ClearAllPoints()
        row.stacksLabel:SetPoint("LEFT", row, "LEFT", 0, 0)
        if row._branch == "ITEM" then row.stacksLabel:SetText("数量?") else row.stacksLabel:SetText("层数?") end
        row.stacksLabel:Show()
      end
      if row.stacksCB then
        row.stacksCB:ClearAllPoints()
        row.stacksCB:SetPoint("LEFT", row, "LEFT", 52, 0)
        row.stacksCB:Show()
        row.stacksCB:SetChecked(row._stacksEnabled and true or false)
      end
      if row.stacksCompDD then
        row.stacksCompDD:ClearAllPoints()
        row.stacksCompDD:SetPoint("LEFT", row, "LEFT", 57, -3)
      end
      if row.stacksVal then
        row.stacksVal:ClearAllPoints()
        row.stacksVal:SetPoint("LEFT", row, "LEFT", 142, 0)
      end
      if row.stacksValEnter then
        row.stacksValEnter:ClearAllPoints()
        row.stacksValEnter:SetPoint("LEFT", row.stacksVal, "RIGHT", 4, 0)
      end

      VfxCond_UpdateStacksUI(row)

    elseif state == "INPUT" then
      local addWidth = row.addButton:GetWidth() or 40
      local rightGap = 2
      local totalRight = closeWidth + spacing + addWidth + rightGap

      local editWidth = parentWidth - spacing - totalRight
      if editWidth < 60 then editWidth = 60 end

      row.editBox:ClearAllPoints()
      row.addButton:ClearAllPoints()
      if row.abilityDD then row.abilityDD:ClearAllPoints() end
      if row.itemDD then row.itemDD:ClearAllPoints() end

      row.editBox:SetWidth(editWidth)
      row.editBox:SetPoint("LEFT", row, "LEFT", 10, 0)

      row.addButton:SetPoint("RIGHT", row.closeBtn, "LEFT", -rightGap, 0)
      row.addButton:SetText("添加")

      if row._branch == "ABILITY" then
        if row.abilityDD then
          row.editBox:Hide()
          row.abilityDD:SetPoint("LEFT", row, "LEFT", -15, -3)
          if UIDropDownMenu_SetWidth then
            pcall(UIDropDownMenu_SetWidth, editWidth, row.abilityDD)
          end
          VfxCond_InitAbilityDropdown(row)
          row.abilityDD:Show()
        end
        row.addButton:Show()
      elseif row._branch == "ITEM" then
        if row.itemDD then
          row.editBox:Hide()
          row.itemDD:SetPoint("LEFT", row, "LEFT", -15, -3)
          if UIDropDownMenu_SetWidth then
            pcall(UIDropDownMenu_SetWidth, editWidth, row.itemDD)
          end
          VfxCond_InitItemDropdown(row)
          row.itemDD:Show()
        end
        row.addButton:Show()
      else
        if row.abilityDD then row.abilityDD:Hide() end
        row.editBox:Show()
        row.addButton:Show()
      end

    elseif state == "SAVED" then
      row.labelFS:SetText(row._desc or "")
      row.labelFS:Show()

      if row.glowCB and row.greyCB then
        row.labelFS:ClearAllPoints()
        row.labelFS:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)

        row.glowCB:ClearAllPoints()
        row.greyCB:ClearAllPoints()
        row.glowCB:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -14)
        row.greyCB:SetPoint("LEFT", row.glowCB, "RIGHT", 40, 0)
        if row.fadeCB then
          row.fadeCB:ClearAllPoints()
          row.fadeCB:SetPoint("LEFT", row.greyCB, "RIGHT", 40, 0)
        end
        if row.fadeSlider then
          row.fadeSlider:ClearAllPoints()
          row.fadeSlider:SetPoint("LEFT", row.fadeCB, "RIGHT", 45, 0)
          if row.fadeSliderPct then
            row.fadeSliderPct:ClearAllPoints()
            row.fadeSliderPct:SetPoint("LEFT", row.fadeSlider, "RIGHT", 5, 0)
          end
        end

        row.glowCB:Show()
        row.greyCB:Show()
        if row.fadeCB then
          row.fadeCB:Show()
          if row.fadeCB:GetChecked() and row.fadeSlider then
            row.fadeSlider:Show()
            if row.fadeSliderPct then row.fadeSliderPct:Show() end
          end
        end
      end
    end
  end

  local function VfxCond_OnCancelEditing(row)
    row._branch = nil
    row._choiceBuffType = nil
    row._choiceMode = nil
    row._choiceUnit = nil
    row._spellName = nil
    row._itemName = nil
    row._choiceItemCd = nil
    row._abilityPage = 1

    -- 层数重置
    row._stacksEnabled = nil
    row._stacksComp = nil
    row._stacksVal = nil

    if row.stacksCB then
      row.stacksCB:SetChecked(false)
    end
    if row.stacksVal and row.stacksVal.SetText then
      row.stacksVal:SetText("")
    end
    if row.stacksCompDD then
      if UIDropDownMenu_ClearAll then
        pcall(UIDropDownMenu_ClearAll, row.stacksCompDD)
      end
      if UIDropDownMenu_SetText then
        pcall(UIDropDownMenu_SetText, "", row.stacksCompDD)
      end
    end

    if row.editBox and row.editBox.SetText then
      row.editBox:SetText("")
    end

    if row.abilityDD then
      if UIDropDownMenu_ClearAll then
        pcall(UIDropDownMenu_ClearAll, row.abilityDD)
      end
      if UIDropDownMenu_SetText then
        pcall(UIDropDownMenu_SetText, "选择技能", row.abilityDD)
      end
    end

    VfxCond_SetRowState(row, "STEP1")
  end


  local function VfxCond_RebuildFromDB_Internal(typeKey)
    local mgr = VfxCond_Managers[typeKey]
    if not mgr or not mgr.anchor then return end

    local list = VfxCond_GetListForType(typeKey) or {}
    local count = VfxCond_Len(list)

    if not mgr.savedRows then mgr.savedRows = {} end

    local i
    for i = 1, count do
      local entry = list[i]
      local row = mgr.savedRows[i]
      if not row then
        row = mgr._createRow(mgr, false)
        mgr.savedRows[i] = row
      end
      row._entryIndex = i
      row._choiceBuffType = (entry and entry.buffType) or "BUFF"
      row._choiceMode = (entry and entry.mode) or "found"
      row._choiceUnit = (entry and entry.unit) or "player"
      row._spellName = (entry and entry.name) or ""
      row._itemName = (entry and entry.name) or ""
      row._choiceItemCd = (entry and entry.unit) or "notcd"
      row._stacksEnabled = (entry and entry.stacksEnabled) and true or nil
      row._stacksComp    = (entry and entry.stacksComp) or nil
      row._stacksVal     = (entry and entry.stacksVal) or nil

      row._desc = VfxCond_BuildDescription(
        row._choiceBuffType,
        row._choiceMode,
        row._choiceUnit,
        row._spellName,
        row._stacksEnabled,
        row._stacksComp,
        row._stacksVal
      )

      if row.glowCB then
        row.glowCB:SetChecked(entry and entry.glow)
        row.glowCB:SetScript("OnClick", function()
          local list = VfxCond_GetListForType(typeKey)
          if list and list[row._entryIndex] then
            list[row._entryIndex].glow = this:GetChecked() and true or nil
            SafeRefresh(); SafeEvaluate()
            UpdateCondFrameForKey(currentKey)
          end
        end)
      end
      if row.greyCB then
        row.greyCB:SetChecked(entry and entry.grey)
        row.greyCB:SetScript("OnClick", function()
          local list = VfxCond_GetListForType(typeKey)
          if list and list[row._entryIndex] then
            list[row._entryIndex].grey = this:GetChecked() and true or nil
            SafeRefresh(); SafeEvaluate()
            UpdateCondFrameForKey(currentKey)
          end
        end)
      end

      if row.fadeCB then
        row.fadeCB:SetChecked(entry and entry.fade)
        row.fadeCB:SetScript("OnClick", function()
          local list = VfxCond_GetListForType(typeKey)
          if list and list[row._entryIndex] then
            list[row._entryIndex].fade = this:GetChecked() and true or nil
            if list[row._entryIndex].fade and not list[row._entryIndex].fadeAlpha then
              list[row._entryIndex].fadeAlpha = 0
            end
            SafeRefresh(); SafeEvaluate()
            UpdateCondFrameForKey(currentKey)
          end
        end)
      end
      if row.fadeSlider then
        local fadeAlpha = tonumber(entry and entry.fadeAlpha) or 0
        if fadeAlpha < 0 then fadeAlpha = 0 end
        if fadeAlpha > 1 then fadeAlpha = 1 end
        row.fadeSlider:SetText(tostring(math.floor((fadeAlpha * 100) + 0.5)))
        local function SaveRowFadeAlpha()
          local list = VfxCond_GetListForType(typeKey)
          if list and list[row._entryIndex] then
            list[row._entryIndex].fadeAlpha = _ParseFadeAlphaFromBox(row.fadeSlider)
            _NormalizeFadeBox(row.fadeSlider, list[row._entryIndex].fadeAlpha)
            SafeRefresh(); SafeEvaluate()
          end
        end
        row.fadeSlider:SetScript("OnEnterPressed", function() SaveRowFadeAlpha(); this:ClearFocus() end)
        row.fadeSlider:SetScript("OnEditFocusLost", SaveRowFadeAlpha)
        row.fadeSlider:SetScript("OnEscapePressed", function() this:ClearFocus() end)
      end

      VfxCond_SetRowState(row, "SAVED")
      row:Show()
    end

    local nRows = VfxCond_Len(mgr.savedRows)
    for i = count + 1, nRows do
      if mgr.savedRows[i] then
        mgr.savedRows[i]:Hide()
        mgr.savedRows[i]._entryIndex = nil
      end
    end

    if not mgr.editRow then
      mgr.editRow = mgr._createRow(mgr, true)
    end
    VfxCond_OnCancelEditing(mgr.editRow)
    mgr.editRow:Show()

    local y = -30

    i = 1
    while mgr.savedRows and mgr.savedRows[i] do
      local row = mgr.savedRows[i]
      if row:IsShown() then
        row:ClearAllPoints()
        row:SetHeight(36)
        row:SetPoint("TOPLEFT", mgr.anchor, "TOPLEFT", 0, y)
        row:SetPoint("TOPRIGHT", mgr.anchor, "TOPRIGHT", 0, y)
        y = y - 38
      end
      i = i + 1
    end

    if mgr.editRow and mgr.editRow:IsShown() then
      mgr.editRow:ClearAllPoints()
      mgr.editRow:SetPoint("TOPLEFT", mgr.anchor, "TOPLEFT", 0, y)
      mgr.editRow:SetPoint("TOPRIGHT", mgr.anchor, "TOPRIGHT", 0, y)
      y = y - 18
    end

    mgr.anchor:SetHeight(-y + 4)
    _ReflowCondAreaHeight()
  end

  local function VfxCond_OnAdd(row)
    if not currentKey then return end
    local mgr = row._manager
    if not mgr then return end

    local text
    if row._branch == "ABILITY" then
      text = row._spellName or ""
    elseif row._branch == "ITEM" then
      text = row._itemName or ""
    else
      text = row.editBox and row.editBox:GetText() or ""
    end
    local parsedInput = VfxCond_ParseAuraInput(text)
    if not parsedInput then return end

    local buffType = row._choiceBuffType or "BUFF"
    local mode = row._choiceMode or "found"
    local unit

    if row._branch == "ABILITY" then
      unit = nil
      buffType = "ABILITY"
    elseif row._branch == "ITEM" then
      if row._choiceMode == "missing" then
        unit = nil
      else
        unit = row._choiceItemCd or "notcd"
      end
      buffType = "ITEM"
    elseif row._branch == "TALENT" then
      unit = nil
    else
      unit = row._choiceUnit or "player"
    end

    local list = VfxCond_GetListForType(mgr.typeKey)
    if not list then
      DEFAULT_CHAT_FRAME:AddMessage("|cffff0000VfxCond_OnAdd: 类型 "..tostring(mgr.typeKey).." 的列表为nil|r")
      return
    end

    local entry = {
      buffType = buffType,
      mode = mode,
      unit = unit,
      name = parsedInput.name,
      spellid = parsedInput.spellid,
      Addedviaspellid = parsedInput.Addedviaspellid,
      fade = nil,
      fadeAlpha = 0,
    }

    -- 仅对于光环（增益/减益），存储可选的层数设置
    if row._branch ~= "ABILITY" and row._branch ~= "TALENT" then
      entry.stacksEnabled = row._stacksEnabled and true or nil
      if entry.stacksEnabled then
        entry.stacksComp = row._stacksComp
        entry.stacksVal  = row._stacksVal
      else
        entry.stacksComp = nil
        entry.stacksVal  = nil
      end
    end

    local n = VfxCond_Len(list)
    list[n + 1] = entry
    VfxCond_RebuildFromDB_Internal(mgr.typeKey)
  end

  local function VfxCond_OnDeleteSaved(row)
    if not currentKey then return end
    local mgr = row._manager
    if not mgr then return end

    local list = VfxCond_GetListForType(mgr.typeKey)
    if not list then return end

    local idx = row._entryIndex or 0
    local n = VfxCond_Len(list)
    if idx < 1 or idx > n then return end

    for j = idx, n - 1 do
      list[j] = list[j + 1]
    end
    list[n] = nil

    VfxCond_RebuildFromDB_Internal(mgr.typeKey)
  end

  local function VfxCond_InitComparatorDD(ddframe, commitFunc)
    UIDropDownMenu_Initialize(ddframe, function(frame, level, menuList)
      local info
      local choices = { ">=", "<=", "==" }
      for _, c in ipairs(choices) do
        local picked = c
        info = {}
        info.text = picked
        info.value = picked
        info.func = function(button)
          local val = (button and button.value) or picked
          if commitFunc then
            pcall(commitFunc, val)
          end
          UIDropDownMenu_SetSelectedValue(ddframe, val)
          UIDropDownMenu_SetText(val, ddframe)
          CloseDropDownMenus()
        end
        info.checked = (UIDropDownMenu_GetSelectedValue(ddframe) == picked)
        UIDropDownMenu_AddButton(info)
      end
    end)
  end

  local function VfxCond_CreateRow(mgr, isEditing)
    VfxCond_RowCounter = VfxCond_RowCounter + 1

    local parent = mgr.anchor
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(18)

    row._manager = mgr

    local parentWidth = (parent and parent.GetWidth and parent:GetWidth()) or 0
    if parentWidth <= 0 then parentWidth = 260 end
    local closeWidth = 20
    local spacing = 4
    local mainWidth = math.floor((parentWidth - closeWidth - spacing * 3) / 2)

    row._parentWidth = parentWidth
    row._closeWidth = closeWidth
    row._spacing = spacing
    row._mainWidth = mainWidth

    row.btn1 = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    row.btn2 = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    row.btn3 = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    row.btn4 = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    row.closeBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    row.editBox = CreateFrame("EditBox", nil, row)
    row.addButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    row.labelFS = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.labelFS:SetJustifyH("LEFT")

    row.editBox:SetAutoFocus(false)
    row.editBox:SetFontObject("GameFontNormalSmall")
    if row.editBox.SetTextInsets then
      row.editBox:SetTextInsets(6, 6, 0, 0)
    end
    if row.editBox.SetBackdrop then
      row.editBox:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
      })
      row.editBox:SetBackdropColor(0, 0, 0, 0.85)
      row.editBox:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
    end

    local ddName = "DoiteVfxCond_AbilityDD_" .. tostring(mgr.typeKey or "X") .. "_" .. tostring(VfxCond_RowCounter)
    row.abilityDD = CreateFrame("Frame", ddName, row, "UIDropDownMenuTemplate")
    row.itemDD = CreateFrame("Frame", "DoiteVfxCond_ItemDD_" .. tostring(mgr.typeKey or "X") .. "_" .. tostring(VfxCond_RowCounter), row, "UIDropDownMenuTemplate")
    row._abilityPage = 1

    -- 继续按钮（位于内容和X之间），在STACKS阶段使用
    row.okBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    row.okBtn:SetWidth(60)
    row.okBtn:SetHeight(18)
    row.okBtn:SetText("继续")

    -- 层数界面（仅在STACKS阶段使用）
    row.stacksLabel = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.stacksLabel:SetText("层数?")

    row.stacksCB = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
    row.stacksCB:SetWidth(18); row.stacksCB:SetHeight(18)

    local dd2Name = "DoiteVfxCond_StacksCompDD_" .. tostring(mgr.typeKey or "X") .. "_" .. tostring(VfxCond_RowCounter)
    row.stacksCompDD = CreateFrame("Frame", dd2Name, row, "UIDropDownMenuTemplate")

    -- 使层数比较器下拉框更窄
    row._stacksCompWidth = 45
    if UIDropDownMenu_SetWidth then
      pcall(UIDropDownMenu_SetWidth, row._stacksCompWidth, row.stacksCompDD)
    end

    row.stacksVal = CreateFrame("EditBox", nil, row)
    row.stacksVal:SetWidth(40)
    row.stacksVal:SetHeight(18)
    row.stacksVal:SetAutoFocus(false)
    row.stacksVal:SetFontObject("GameFontNormalSmall")
    if row.stacksVal.SetTextInsets then
      row.stacksVal:SetTextInsets(6, 6, 0, 0)
    end
    if row.stacksVal.SetBackdrop then
      row.stacksVal:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
      })
      row.stacksVal:SetBackdropColor(0, 0, 0, 0.85)
      row.stacksVal:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
    end

    row.stacksValEnter = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.stacksValEnter:SetText("(#)")

    row.btn1:SetWidth(mainWidth)
    row.btn2:SetWidth(mainWidth)
    row.btn3:SetWidth(mainWidth)
    row.btn4:SetWidth(mainWidth)
    row.btn1:SetHeight(18)
    row.btn2:SetHeight(18)
    row.btn3:SetHeight(18)
    row.btn4:SetHeight(18)

    row.closeBtn:SetWidth(closeWidth)
    row.closeBtn:SetHeight(18)

    local editWidth = parentWidth - closeWidth - spacing * 3 - 40
    if editWidth < 60 then editWidth = 60 end

    row.editBox:SetWidth(editWidth)
    row.editBox:SetHeight(18)
    row.editBox:SetAutoFocus(false)
    row.editBox:SetFontObject("GameFontNormalSmall")

    row.addButton:SetWidth(40)
    row.addButton:SetHeight(18)

    row.btn1:SetPoint("LEFT", row, "LEFT", 0, 0)
    row.btn2:SetPoint("LEFT", row.btn1, "RIGHT", spacing, 0)
    row.closeBtn:SetPoint("RIGHT", row, "RIGHT", 0, 0)

    row.editBox:SetPoint("LEFT", row, "LEFT", 0, 0)
    row.addButton:SetPoint("LEFT", row.editBox, "RIGHT", spacing, 0)

    -- 技能下拉框位于编辑框的位置（INPUT状态两者互换）
    row.abilityDD:SetPoint("LEFT", row, "LEFT", 0, -2)
    if UIDropDownMenu_SetWidth then
      pcall(UIDropDownMenu_SetWidth, parentWidth - closeWidth - spacing * 3 - 40, row.abilityDD)
    end

    row.labelFS:SetPoint("LEFT", row, "LEFT", 0, 0)
    row.labelFS:SetTextColor(1, 1, 1)
    row.labelFS:SetNonSpaceWrap(false)

    -- SAVED状态下的发光/灰色复选框
    local function CreateMiniCheck(label)
      local cb = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
      cb:SetWidth(18); cb:SetHeight(18)
      cb.text = cb:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
      cb.text:SetPoint("LEFT", cb, "RIGHT", 0, 0)
      cb.text:SetText(label)
      return cb
    end

    row.glowCB = CreateMiniCheck("发光")
    row.greyCB = CreateMiniCheck("灰色")
    row.fadeCB = CreateMiniCheck("淡出")
    row.fadeSlider = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
    row.fadeSlider:SetWidth(24)
    row.fadeSlider:SetHeight(16)
    row.fadeSlider:SetAutoFocus(false)
    row.fadeSlider:SetJustifyH("CENTER")
    row.fadeSlider:SetFontObject("GameFontNormalSmall")
    row.fadeSlider:SetNumeric(true)
    row.fadeSliderPct = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.fadeSliderPct:SetText("|cffffd000%|r")

    row.closeBtn:SetText("X")

    DoiteEdit_YellowifyButton(row.btn1)
    DoiteEdit_YellowifyButton(row.btn2)
    DoiteEdit_YellowifyButton(row.btn3)
    DoiteEdit_YellowifyButton(row.btn4)
    DoiteEdit_YellowifyButton(row.addButton)
    DoiteEdit_YellowifyButton(row.closeBtn)
    DoiteEdit_YellowifyButton(row.okBtn)

    -- 按钮点击处理器
    row.btn1:SetScript("OnClick", function()
      local state = row._state
      if state == "STEP1" then
        row._branch = "ABILITY"
        row._choiceBuffType = "ABILITY"
        VfxCond_SetRowState(row, "STEP2")
      elseif state == "STEP2" then
        if row._branch == "ABILITY" then
          row._choiceMode = "notcd"
          VfxCond_SetRowState(row, "INPUT")
        elseif row._branch == "ITEM" then
          row._choiceMode = "found"
          VfxCond_SetRowState(row, "STEP3")
        elseif row._branch == "TALENT" then
          row._choiceMode = "Known"
          VfxCond_SetRowState(row, "INPUT")
        else
          row._choiceMode = "found"
          VfxCond_SetRowState(row, "STEP3")
        end
        elseif state == "STEP3" then
          if row._branch == "ITEM" then
            row._choiceItemCd = "notcd"
          if row._choiceMode == "missing" then
            VfxCond_SetRowState(row, "INPUT")
          else
            VfxCond_SetRowState(row, "STACKS")
          end
          return
        end
          row._choiceUnit = "player"
          if row._choiceMode == "missing" then
            VfxCond_SetRowState(row, "INPUT")
          else
            VfxCond_SetRowState(row, "STACKS")
          end
        end
    end)

    row.btn2:SetScript("OnClick", function()
      local state = row._state
      if state == "STEP1" then
        row._branch = "BUFF"
        row._choiceBuffType = "BUFF"
        VfxCond_SetRowState(row, "STEP2")
      elseif state == "STEP2" then
        if row._branch == "ABILITY" then
          row._choiceMode = "oncd"
          VfxCond_SetRowState(row, "INPUT")
        elseif row._branch == "ITEM" then
          row._choiceMode = "missing"
          row._choiceItemCd = nil
          row._stacksEnabled = nil
          row._stacksComp = nil
          row._stacksVal  = nil
          VfxCond_SetRowState(row, "INPUT")
        elseif row._branch == "TALENT" then
          row._choiceMode = "NotKnown"
          VfxCond_SetRowState(row, "INPUT")
        else
          row._choiceMode = "missing"

          -- 硬重置层数，确保“缺失 + 层数”永远不会被存储/使用
          row._stacksEnabled = nil
          row._stacksComp = nil
          row._stacksVal  = nil
          if row.stacksCB then
            row.stacksCB:SetChecked(false)
          end
          if row.stacksVal and row.stacksVal.SetText then
            row.stacksVal:SetText("")
          end
          if row.stacksCompDD then
            if UIDropDownMenu_ClearAll then
              pcall(UIDropDownMenu_ClearAll, row.stacksCompDD)
            end
            if UIDropDownMenu_SetText then
              pcall(UIDropDownMenu_SetText, "", row.stacksCompDD)
            end
          end

          VfxCond_SetRowState(row, "STEP3")
        end
        elseif state == "STEP3" then
          if row._branch == "ITEM" then
            row._choiceItemCd = "oncd"
          if row._choiceMode == "missing" then
            VfxCond_SetRowState(row, "INPUT")
          else
            VfxCond_SetRowState(row, "STACKS")
          end
          return
        end
          row._choiceUnit = "target"
          if row._choiceMode == "missing" then
            VfxCond_SetRowState(row, "INPUT")
          else
            VfxCond_SetRowState(row, "STACKS")
          end
        end
    end)

    row.addButton:SetScript("OnClick", function()
      local state = row._state
      if state == "STEP1" then
        row._branch = "DEBUFF"
        row._choiceBuffType = "DEBUFF"
        VfxCond_SetRowState(row, "STEP2")
      elseif state == "INPUT" then
        VfxCond_OnAdd(row)
      end
    end)

    row.btn3:SetScript("OnClick", function()
      if row._state == "STEP1" then
        row._branch = "TALENT"
        row._choiceBuffType = "TALENT"
        VfxCond_SetRowState(row, "STEP2")
      end
    end)

    row.btn4:SetScript("OnClick", function()
      if row._state == "STEP1" then
        row._branch = "ITEM"
        row._choiceBuffType = "ITEM"
        row._choiceMode = nil
        row._choiceUnit = nil
        row._choiceItemCd = nil
        VfxCond_SetRowState(row, "STEP2")
      end
    end)

    row.closeBtn:SetScript("OnClick", function()
      if row._state == "SAVED" then
        VfxCond_OnDeleteSaved(row)
      else
        VfxCond_OnCancelEditing(row)
      end
    end)

    row.editBox:SetScript("OnEnterPressed", function()
      VfxCond_OnAdd(row)
    end)

    -- 初始化比较器下拉框（空白文本）
    VfxCond_InitComparatorDD(row.stacksCompDD, function(val)
      row._stacksComp = val
      if row._state == "STACKS" then
        VfxCond_UpdateStacksUI(row)
      end
    end)

    if UIDropDownMenu_SetText then
      pcall(UIDropDownMenu_SetText, "", row.stacksCompDD)
    end

    row.stacksCB:SetScript("OnClick", function()
      row._stacksEnabled = this:GetChecked() and true or nil
      if not row._stacksEnabled then
        row._stacksComp = nil
        row._stacksVal  = nil
        if row.stacksVal and row.stacksVal.SetText then
          row.stacksVal:SetText("")
        end
        if UIDropDownMenu_ClearAll then
          pcall(UIDropDownMenu_ClearAll, row.stacksCompDD)
        end
        if UIDropDownMenu_SetText then
          pcall(UIDropDownMenu_SetText, "", row.stacksCompDD)
        end
      end
      if row._state == "STACKS" then
        VfxCond_UpdateStacksUI(row)
      end
    end)

    row.stacksVal:SetScript("OnTextChanged", function()
      row._stacksVal = row.stacksVal:GetText()
      if row._state == "STACKS" then
        VfxCond_UpdateStacksUI(row)
      end
    end)

    row.okBtn:SetScript("OnClick", function()
      if not currentKey then return end
      if row._state ~= "STACKS" then return end

      -- 如果层数启用，需要比较器和值
      if row._stacksEnabled then
        local comp = string.gsub(tostring(row._stacksComp or ""), "^%s*(.-)%s*$", "%1")
        local val  = string.gsub(tostring(row._stacksVal  or ""), "^%s*(.-)%s*$", "%1")
        if comp == "" or val == "" then
          return
        end
      end

      VfxCond_SetRowState(row, "INPUT")
    end)

    row._state = "SAVED"
    VfxCond_SetRowState(row, "SAVED")

    row:Hide()
    return row
  end

  VfxCond_RegisterManager = function(typeKey, anchorFrame)
    if not anchorFrame then return end

    local mgr = VfxCond_Managers[typeKey]
    if not mgr then
      mgr = {}
      VfxCond_Managers[typeKey] = mgr
    end

    mgr.typeKey = typeKey
    mgr.anchor = anchorFrame
    mgr.savedRows = mgr.savedRows or {}
    mgr.editRow = mgr.editRow or nil
    mgr._createRow = VfxCond_CreateRow

    if not mgr.label then
      local label = anchorFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
      label:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT", 0, -15)
      label:SetJustifyH("LEFT")
      label:SetTextColor(1, 0.82, 0)
      label:SetText("添加视觉效果条件（发光/灰色/淡出）：")
      mgr.label = label
    end

    anchorFrame:SetHeight(20)
    anchorFrame:Hide()
  end

  VfxCond_RefreshFromDB = function(typeKey)
    for tk, mgr in pairs(VfxCond_Managers) do
      if mgr.anchor then
        if tk == typeKey then
          mgr.anchor:Show()
        else
          mgr.anchor:Hide()
        end
      end
    end

    if typeKey then
      VfxCond_RebuildFromDB_Internal(typeKey)
    end
    _ReflowCondAreaHeight()
  end

  VfxCond_ResetEditing = function()
    -- 无操作
  end
end

-- 更新条件界面以反映当前键/数据的数据库状态
local function UpdateConditionsUI(data)
  if not condFrame then
    return
  end
  if not data then
    return
  end
  if not data.conditions then
    data.conditions = {}
  end

  -- 每次进入此图标的编辑状态时，在聊天框提示
  local dn = data.displayName
  if not dn or dn == "" then
    dn = currentKey
  end
  DoiteEdit_AnnounceEditingIcon(dn)

  local c = data.conditions

  local function _HideSoundControls()
    local list = {
      condFrame.cond_ability_sound_oncd_cb, condFrame.cond_ability_sound_oncd_dd,
      condFrame.cond_ability_sound_offcd_cb, condFrame.cond_ability_sound_offcd_dd,
      condFrame.cond_ability_sound_onproc_cb, condFrame.cond_ability_sound_onproc_dd,
      condFrame.cond_aura_sound_ongain_cb, condFrame.cond_aura_sound_ongain_dd,
      condFrame.cond_aura_sound_onfade_cb, condFrame.cond_aura_sound_onfade_dd,
      condFrame.cond_item_sound_oncd_cb, condFrame.cond_item_sound_oncd_dd,
      condFrame.cond_item_sound_offcd_cb, condFrame.cond_item_sound_offcd_dd,
    }
    local i
    for i = 1, table.getn(list) do
      if list[i] and list[i].Hide then
        list[i]:Hide()
      end
    end
  end
  _HideSoundControls()

  -- 重置淡出控件，以防止图标类别之间的视觉泄漏。
  if condFrame.cond_ability_fade then condFrame.cond_ability_fade:Hide() end
  if condFrame.cond_ability_fade_slider then condFrame.cond_ability_fade_slider:Hide() end
  if condFrame.cond_aura_fade then condFrame.cond_aura_fade:Hide() end
  if condFrame.cond_aura_fade_slider then condFrame.cond_aura_fade_slider:Hide() end
  if condFrame.cond_item_fade then condFrame.cond_item_fade:Hide() end
  if condFrame.cond_item_fade_slider then condFrame.cond_item_fade_slider:Hide() end

  -- 自定义控件默认隐藏；仅当类型为Custom时显示。
  if condFrame.cond_custom_function_edit then
    condFrame.cond_custom_function_edit:Hide()
  end
  if condFrame.cond_custom_function_save then
    condFrame.cond_custom_function_save:Hide()
  end
  if condFrame.cond_custom_function_status then
    condFrame.cond_custom_function_status:Hide()
    condFrame.cond_custom_function_status:SetText("")
  end

  local function _IsWarriorPaladinShaman()
    local _, cls = UnitClass("player")
    cls = cls and string.upper(cls) or ""
    return (cls == "WARRIOR" or cls == "PALADIN" or cls == "SHAMAN")
  end


  -- 技能类型
  if data.type == "Ability" then
    -- 显示行
    if ShowSeparatorsForType then ShowSeparatorsForType("ability") end
    -- 确保不在光环编辑时显示光环专用提示
    if condFrame.cond_aura_tip then
      condFrame.cond_aura_tip:Hide()
    end
    if AuraCond_RefreshFromDB then
      AuraCond_RefreshFromDB("ability")
    end
    if VfxCond_RefreshFromDB then
      VfxCond_RefreshFromDB("ability")
    end

    condFrame.cond_ability_usable:Show()
    condFrame.cond_ability_notcd:Show()
    condFrame.cond_ability_oncd:Show()
    condFrame.cond_ability_incombat:Show()
    condFrame.cond_ability_outcombat:Show()
    if condFrame.cond_ability_groupingDD then
      condFrame.cond_ability_groupingDD:Show()
    end
    condFrame.cond_ability_target_help:Show()
    condFrame.cond_ability_target_harm:Show()
    condFrame.cond_ability_target_self:Show()
    condFrame.cond_ability_sound_oncd_cb:Show()
    condFrame.cond_ability_sound_oncd_dd:Show()
    condFrame.cond_ability_sound_offcd_cb:Show()
    condFrame.cond_ability_sound_offcd_dd:Show()
    condFrame.cond_ability_sound_onproc_cb:Show()
    condFrame.cond_ability_sound_onproc_dd:Show()
    condFrame.cond_ability_power:Show()
    condFrame.cond_ability_glow:Show()
    condFrame.cond_ability_greyscale:Show()
    condFrame.cond_ability_fade:Show()
    condFrame.cond_ability_slider:Show()
    condFrame.cond_ability_remaining_cb:Show()

    -- 互斥模式
    local mode = (c.ability and c.ability.mode) or nil
    condFrame.cond_ability_usable:SetChecked(mode == "usable" or mode == "usableoncd")
    condFrame.cond_ability_notcd:SetChecked(mode == "notcd" or mode == "nocdoncd")
    condFrame.cond_ability_oncd:SetChecked(mode == "oncd" or mode == "usableoncd" or mode == "nocdoncd")

    -- 战斗状态 -> 现在是独立布尔值，并回退到遗留字符串'combat'
    local inC, outC
    if c.ability and (c.ability.inCombat ~= nil or c.ability.outCombat ~= nil) then
      inC = c.ability.inCombat and true or false
      outC = c.ability.outCombat and true or false
    else
      -- 遗留处理
      local cm = c.ability and c.ability.combat or nil
      if cm == "in" then
        inC, outC = true, false
      elseif cm == "out" then
        inC, outC = false, true
      else
        inC, outC = true, true -- 默认两者
      end
    end
    condFrame.cond_ability_incombat:SetChecked(inC)
    condFrame.cond_ability_outcombat:SetChecked(outC)

    if condFrame.cond_ability_groupingDD then
      local gm = _DeriveGroupingMode(c.ability)
      local txt
      if gm == "any" then
        txt = "任意"
      elseif gm == "nogroup" then
        txt = "不在队伍/团队中"
      elseif gm == "party" then
        txt = "在队伍中"
      elseif gm == "raid" then
        txt = "在团队中"
      elseif gm == "partyraid" then
        txt = "在队伍或团队中"
      else
        txt = "组队状态"
      end

      if gm == nil then
        if UIDropDownMenu_SetSelectedValue then pcall(UIDropDownMenu_SetSelectedValue, condFrame.cond_ability_groupingDD, "__default") end
      else
        if UIDropDownMenu_SetSelectedValue then pcall(UIDropDownMenu_SetSelectedValue, condFrame.cond_ability_groupingDD, gm) end
      end
      if UIDropDownMenu_SetText then pcall(UIDropDownMenu_SetText, txt, condFrame.cond_ability_groupingDD) end
      if _GoldifyDD then _GoldifyDD(condFrame.cond_ability_groupingDD) end
    end

    -- 多选布尔值
    local ah = (c.ability and c.ability.targetHelp) == true
    local ar = (c.ability and c.ability.targetHarm) == true
    local as = (c.ability and c.ability.targetSelf) == true
    condFrame.cond_ability_target_help:SetChecked(ah)
    condFrame.cond_ability_target_harm:SetChecked(ar)
    condFrame.cond_ability_target_self:SetChecked(as)

    -- 目标状态（技能）：互斥，但两者都可关闭
    local ta = (c.ability and c.ability.targetAlive) == true
    local td = (c.ability and c.ability.targetDead) == true

    if condFrame.cond_ability_target_alive then
      condFrame.cond_ability_target_alive:SetChecked(ta)
      condFrame.cond_ability_target_alive:Show()
    end
    if condFrame.cond_ability_target_dead then
      condFrame.cond_ability_target_dead:SetChecked(td)
      condFrame.cond_ability_target_dead:Show()
    end

    local aSoundOn = (c.ability and c.ability.soundOnCDEnabled) == true
    local aSoundOff = (c.ability and c.ability.soundOffCDEnabled) == true
    local aSoundProc = (c.ability and c.ability.soundOnProcEnabled) == true
    local aOnCds = (c.ability and c.ability.soundOnCD) or nil
    local aOffCds = (c.ability and c.ability.soundOffCD) or nil
    local aProcSnd = (c.ability and c.ability.soundOnProc) or nil
    local canUseProcSound = DoiteEdit_AbilitySupportsProcSound(data)
    condFrame.cond_ability_sound_oncd_cb:SetChecked(aSoundOn)
    condFrame.cond_ability_sound_offcd_cb:SetChecked(aSoundOff)
    condFrame.cond_ability_sound_onproc_cb:SetChecked(aSoundProc)
    DoiteEdit_InitSoundDropdown(condFrame.cond_ability_sound_oncd_dd, "ability", "soundOnCD", aOnCds)
    DoiteEdit_InitSoundDropdown(condFrame.cond_ability_sound_offcd_dd, "ability", "soundOffCD", aOffCds)
    DoiteEdit_InitSoundDropdown(condFrame.cond_ability_sound_onproc_dd, "ability", "soundOnProc", aProcSnd)
    DoiteEdit_EnableCheck(condFrame.cond_ability_sound_oncd_cb)
    DoiteEdit_EnableCheck(condFrame.cond_ability_sound_offcd_cb)
    if aSoundOn then
      DoiteEdit_EnableCheck(condFrame.cond_ability_sound_oncd_cb)
      DoiteEdit_SetDropdownInteractive(condFrame.cond_ability_sound_oncd_dd, true)
    else
      DoiteEdit_SetDropdownInteractive(condFrame.cond_ability_sound_oncd_dd, false)
    end
    if aSoundOff then
      DoiteEdit_SetDropdownInteractive(condFrame.cond_ability_sound_offcd_dd, true)
    else
      DoiteEdit_SetDropdownInteractive(condFrame.cond_ability_sound_offcd_dd, false)
    end
    if canUseProcSound then
      DoiteEdit_EnableCheck(condFrame.cond_ability_sound_onproc_cb)
      if aSoundProc then
        DoiteEdit_SetDropdownInteractive(condFrame.cond_ability_sound_onproc_dd, true)
      else
        DoiteEdit_SetDropdownInteractive(condFrame.cond_ability_sound_onproc_dd, false)
      end
    else
      condFrame.cond_ability_sound_onproc_cb:SetChecked(false)
      DoiteEdit_DisableCheck(condFrame.cond_ability_sound_onproc_cb)
      DoiteEdit_SetDropdownInteractive(condFrame.cond_ability_sound_onproc_dd, false)
      if c.ability then
        c.ability.soundOnProcEnabled = false
      end
    end

    -- === 目标距离与类型（技能） ===
    if condFrame.cond_ability_distanceDD then
      condFrame.cond_ability_distanceDD:Show()
      condFrame.cond_ability_unitTypeDD:Show()

      local a = c.ability or {}

      local function _RestoreDD(dd, val, placeholder)
        if not dd then
          return
        end
        if val and val ~= "" then
          if UIDropDownMenu_SetSelectedValue then
            pcall(UIDropDownMenu_SetSelectedValue, dd, val)
          end
          if UIDropDownMenu_SetText then
            pcall(UIDropDownMenu_SetText, val, dd)
          end
          _GoldifyDD(dd)
        else
          if UIDropDownMenu_SetSelectedValue then
            pcall(UIDropDownMenu_SetSelectedValue, dd, nil)
          end
          if UIDropDownMenu_SetText then
            pcall(UIDropDownMenu_SetText, placeholder, dd)
          end
          _WhiteifyDDText(dd)
        end
      end

      _RestoreDD(condFrame.cond_ability_distanceDD, a.targetDistance, "距离")
      _RestoreDD(condFrame.cond_ability_unitTypeDD, a.targetUnitType, "单位类型")

      -- 当目标为自己时，灰显并使下拉框不可选
      local disableTargetRow = false
      if condFrame.cond_ability_target_self and condFrame.cond_ability_target_self.GetChecked then
        disableTargetRow = condFrame.cond_ability_target_self:GetChecked()
      end

      if disableTargetRow then
        -- 清除数据库字段
        a.targetDistance = nil
        a.targetUnitType = nil

        -- 重置可见状态并禁用
        _SetDDEnabled(condFrame.cond_ability_distanceDD, false, "距离")
        _SetDDEnabled(condFrame.cond_ability_unitTypeDD, false, "单位类型")
      else
        _SetDDEnabled(condFrame.cond_ability_distanceDD, true, "距离")
        _SetDDEnabled(condFrame.cond_ability_unitTypeDD, true, "单位类型")
      end
    end

    -- 资源控件
    local pEnabled = (c.ability and c.ability.powerEnabled) and true or false
    condFrame.cond_ability_power:SetChecked(pEnabled)
    if pEnabled then
      condFrame.cond_ability_power_comp:Show()
      condFrame.cond_ability_power_val:Show()
      condFrame.cond_ability_power_val_enter:Show()
      local comp = (c.ability and c.ability.powerComp) or ""
      UIDropDownMenu_SetSelectedValue(condFrame.cond_ability_power_comp, comp)
      UIDropDownMenu_SetText(comp, condFrame.cond_ability_power_comp)
      _GoldifyDD(condFrame.cond_ability_power_comp)
      condFrame.cond_ability_power_val:SetText(tostring((c.ability and c.ability.powerVal) or 0))
    else
      condFrame.cond_ability_power_comp:Hide()
      condFrame.cond_ability_power_val:Hide()
      condFrame.cond_ability_power_val_enter:Hide()
    end

    -- 发光和灰色状态
    condFrame.cond_ability_glow:SetChecked((c.ability and c.ability.glow) or false)
    condFrame.cond_ability_greyscale:SetChecked((c.ability and c.ability.greyscale) or false)
    condFrame.cond_ability_fade:SetChecked((c.ability and c.ability.fade) or false)
    if (c.ability and c.ability.fade) then
      local fadeAlpha = tonumber(c.ability.fadeAlpha) or 0
      if fadeAlpha < 0 then fadeAlpha = 0 end
      if fadeAlpha > 1 then fadeAlpha = 1 end
      condFrame.cond_ability_fade_slider:SetText(tostring(math.floor((fadeAlpha * 100) + 0.5)))
      condFrame.cond_ability_fade_slider:Show()
    else
      condFrame.cond_ability_fade_slider:Hide()
    end

    -- 滑块 vs 剩余
    local slidEnabled = (c.ability and c.ability.slider) and true or false
    condFrame.cond_ability_slider:SetChecked(slidEnabled)
    local remEnabled = (c.ability and c.ability.remainingEnabled) and true or false
    condFrame.cond_ability_remaining_cb:SetChecked(remEnabled)

    if mode == "oncd" or mode == "usableoncd" or mode == "nocdoncd" then
      condFrame.cond_ability_slider:Disable()
      condFrame.cond_ability_slider:Hide()
      condFrame.cond_ability_slider_dir:Hide()
      if remEnabled then
        condFrame.cond_ability_remaining_comp:Show()
        condFrame.cond_ability_remaining_val:Show()
        condFrame.cond_ability_remaining_val_enter:Show()
        local comp = (c.ability and c.ability.remainingComp) or ""
        UIDropDownMenu_SetSelectedValue(condFrame.cond_ability_remaining_comp, comp)
        UIDropDownMenu_SetText(comp, condFrame.cond_ability_remaining_comp)
        _GoldifyDD(condFrame.cond_ability_remaining_comp)
        condFrame.cond_ability_remaining_val:SetText(tostring((c.ability and c.ability.remainingVal) or 0))
      else
        condFrame.cond_ability_remaining_comp:Hide()
        condFrame.cond_ability_remaining_val:Hide()
        condFrame.cond_ability_remaining_val_enter:Hide()
      end
    else
      condFrame.cond_ability_slider:Enable()
      condFrame.cond_ability_slider:Show()
      if slidEnabled then
        condFrame.cond_ability_slider_dir:Show()
        local dir = (c.ability and c.ability.sliderDir) or "居中"
        UIDropDownMenu_SetSelectedValue(condFrame.cond_ability_slider_dir, dir)
        UIDropDownMenu_SetText(dir, condFrame.cond_ability_slider_dir)
        _GoldifyDD(condFrame.cond_ability_slider_dir)
      else
        condFrame.cond_ability_slider_dir:Hide()
      end
      condFrame.cond_ability_remaining_cb:SetChecked(false)
      condFrame.cond_ability_remaining_comp:Hide()
      condFrame.cond_ability_remaining_val:Hide()
      condFrame.cond_ability_remaining_val_enter:Hide()
      condFrame.cond_ability_remaining_cb:Hide()
    end

    -- 连击点数 / 职业提示 / 武器过滤器
    local isRogueOrDruid = _IsRogueOrDruid and _IsRogueOrDruid() or false
    local isWPS = _IsWarriorPaladinShaman()

    if condFrame.cond_ability_weaponDD then
      condFrame.cond_ability_weaponDD:Hide()
    end

    if isRogueOrDruid then
      -- 原始连击点数行为（盗贼/德鲁伊）
      condFrame.cond_ability_cp_cb:Show()
      if condFrame.cond_ability_class_note then
        condFrame.cond_ability_class_note:Hide()
      end

      local cpOn = (c.ability and c.ability.cpEnabled) and true or false
      condFrame.cond_ability_cp_cb:SetChecked(cpOn)
      if cpOn then
        condFrame.cond_ability_cp_comp:Show()
        condFrame.cond_ability_cp_val:Show()
        condFrame.cond_ability_cp_val_enter:Show()
        local comp = (c.ability and c.ability.cpComp) or ""
        UIDropDownMenu_SetSelectedValue(condFrame.cond_ability_cp_comp, comp)
        UIDropDownMenu_SetText(comp, condFrame.cond_ability_cp_comp)
        _GoldifyDD(condFrame.cond_ability_cp_comp)
        condFrame.cond_ability_cp_val:SetText(tostring((c.ability and c.ability.cpVal) or 0))
      else
        condFrame.cond_ability_cp_comp:Hide()
        condFrame.cond_ability_cp_val:Hide()
        condFrame.cond_ability_cp_val_enter:Hide()
      end

    elseif isWPS and condFrame.cond_ability_weaponDD then
      -- 战士/圣骑士/萨满：使用武器/战斗风格下拉框代替连击点数
      condFrame.cond_ability_cp_cb:Hide()
      condFrame.cond_ability_cp_comp:Hide()
      condFrame.cond_ability_cp_val:Hide()
      condFrame.cond_ability_cp_val_enter:Hide()
      if condFrame.cond_ability_class_note then
        condFrame.cond_ability_class_note:Hide()
      end

      condFrame.cond_ability_weaponDD:Show()
      InitWeaponDropdown(condFrame.cond_ability_weaponDD, data, "ability")

    else
      -- 其他职业：既无连击点数也无武器过滤器 → 显示中性提示
      condFrame.cond_ability_cp_cb:Hide()
      condFrame.cond_ability_cp_comp:Hide()
      condFrame.cond_ability_cp_val:Hide()
      condFrame.cond_ability_cp_val_enter:Hide()
      if condFrame.cond_ability_class_note then
        if _IsHunterOrWarlock and _IsHunterOrWarlock() then
          condFrame.cond_ability_class_note:SetText("在此部分下方提供宠物跟踪选项。")
        else
          condFrame.cond_ability_class_note:SetText("未为你的职业添加专属选项。")
        end
        condFrame.cond_ability_class_note:Show()
      end
    end


    -- 第8行：生命值选择器（互斥）
    condFrame.cond_ability_hp_my:Show()
    condFrame.cond_ability_hp_tgt:Show()
    local hpMode = c.ability and c.ability.hpMode or nil
    condFrame.cond_ability_hp_my:SetChecked(hpMode == "my")
    condFrame.cond_ability_hp_tgt:SetChecked(hpMode == "target")
    if hpMode == "my" or hpMode == "target" then
      condFrame.cond_ability_hp_comp:Show()
      condFrame.cond_ability_hp_val:Show()
      condFrame.cond_ability_hp_val_enter:Show()
      local comp = (c.ability and c.ability.hpComp) or ""
      UIDropDownMenu_SetSelectedValue(condFrame.cond_ability_hp_comp, comp)
      UIDropDownMenu_SetText(comp, condFrame.cond_ability_hp_comp)
      _GoldifyDD(condFrame.cond_ability_hp_comp)
      condFrame.cond_ability_hp_val:SetText(tostring((c.ability and c.ability.hpVal) or 0))
    else
      condFrame.cond_ability_hp_comp:Hide()
      condFrame.cond_ability_hp_val:Hide()
      condFrame.cond_ability_hp_val_enter:Hide()
    end

    -- 第9行：滑块额外选项（仅当滑块启用且模式为usable/notcd时）
    local mode = (c.ability and c.ability.mode) or nil
    local slidEnabled = (c.ability and c.ability.slider) and true or false
    if slidEnabled and (mode == "usable" or mode == "notcd") then
      condFrame.cond_ability_slider_glow:Show()
      condFrame.cond_ability_slider_grey:Show()
      condFrame.cond_ability_slider_glow:SetChecked((c.ability and c.ability.sliderGlow) or false)
      condFrame.cond_ability_slider_grey:SetChecked((c.ability and c.ability.sliderGrey) or false)
    else
      condFrame.cond_ability_slider_glow:Hide()
      condFrame.cond_ability_slider_grey:Hide()
    end

    -- 第10行：文本标志（仅有剩余时间；技能从未有层数文本）

    -- 剩余时间行为如旧（当模式为usable/notcd时由滑块控制；在'oncd'时显示）
    if mode == "oncd" or mode == "usableoncd" or mode == "nocdoncd" then
      condFrame.cond_ability_text_time:Show()
      DoiteEdit_EnableCheck(condFrame.cond_ability_text_time)
      condFrame.cond_ability_text_time:SetChecked((c.ability and c.ability.textTimeRemaining) or false)

    elseif mode == "usable" or mode == "notcd" then
      condFrame.cond_ability_text_time:Show()
      if slidEnabled then
        DoiteEdit_EnableCheck(condFrame.cond_ability_text_time)
        condFrame.cond_ability_text_time:SetChecked((c.ability and c.ability.textTimeRemaining) or false)
      else
        if c.ability and c.ability.textTimeRemaining then
          c.ability.textTimeRemaining = false
        end
        condFrame.cond_ability_text_time:SetChecked(false)
        DoiteEdit_DisableCheck(condFrame.cond_ability_text_time)
      end
    else
      condFrame.cond_ability_text_time:Hide()
    end


    -- 初始化形态下拉框并根据玩家职业可用性显示/隐藏
    local choices = (function()
      local _, cls = UnitClass("player")
      cls = cls and string.upper(cls) or ""
      return (cls == "WARRIOR" or cls == "ROGUE" or cls == "DRUID" or cls == "PRIEST" or cls == "PALADIN")
    end)()

    -- 如果存在光环下拉框，隐藏它
    if condFrame.cond_aura_formDD then
      condFrame.cond_aura_formDD:Hide()
    end

    if choices and condFrame.cond_ability_formDD then
      condFrame.cond_ability_formDD:Show()
      ClearDropdown(condFrame.cond_ability_formDD)
      InitFormDropdown(condFrame.cond_ability_formDD, data, "ability")
      local v = c.ability and c.ability.form
      if v and v ~= "所有形态" and v ~= "" then
        UIDropDownMenu_SetSelectedValue(condFrame.cond_ability_formDD, v)
        UIDropDownMenu_SetText(v, condFrame.cond_ability_formDD)
        _GoldifyDD(condFrame.cond_ability_formDD)
      else
        UIDropDownMenu_SetText("选择形态", condFrame.cond_ability_formDD)
        _GoldifyDD(condFrame.cond_ability_formDD)
      end
    elseif condFrame.cond_ability_formDD then
      condFrame.cond_ability_formDD:Hide()
      ClearDropdown(condFrame.cond_ability_formDD)
    end

    -- 隐藏光环控件
    condFrame.cond_aura_found:Hide()
    condFrame.cond_aura_missing:Hide()
    condFrame.cond_aura_incombat:Hide()
    condFrame.cond_aura_outcombat:Hide()
    if condFrame.cond_aura_groupingDD then
      condFrame.cond_aura_groupingDD:Hide()
    end
    condFrame.cond_aura_target_help:Hide()
    condFrame.cond_aura_target_harm:Hide()
    condFrame.cond_aura_onself:Hide()
    condFrame.cond_aura_glow:Hide()
    condFrame.cond_aura_greyscale:Hide()
    condFrame.cond_aura_fade:Hide()
    condFrame.cond_aura_fade_slider:Hide()
    condFrame.cond_aura_remaining_cb:Hide()
    condFrame.cond_aura_remaining_comp:Hide()
    condFrame.cond_aura_remaining_val:Hide()
    condFrame.cond_aura_remaining_val_enter:Hide()
    condFrame.cond_aura_stacks_cb:Hide()
    condFrame.cond_aura_stacks_comp:Hide()
    condFrame.cond_aura_stacks_val:Hide()
    condFrame.cond_aura_stacks_val_enter:Hide()
    condFrame.cond_aura_tip:Hide()
    if condFrame.cond_aura_text_time then
      condFrame.cond_aura_text_time:Hide()
    end
    if condFrame.cond_aura_text_stack then
      condFrame.cond_aura_text_stack:Hide()
    end
    if condFrame.cond_aura_text_time_override then
      condFrame.cond_aura_text_time_override:Hide()
    end
    if condFrame.cond_aura_text_stack_override then
      condFrame.cond_aura_text_stack_override:Hide()
    end
    if condFrame.cond_aura_text_override_note then
      condFrame.cond_aura_text_override_note:Hide()
    end

    if condFrame.cond_aura_power then
      condFrame.cond_aura_power:Hide()
    end
    if condFrame.cond_aura_power_comp then
      condFrame.cond_aura_power_comp:Hide()
    end
    if condFrame.cond_aura_power_val then
      condFrame.cond_aura_power_val:Hide()
    end
    if condFrame.cond_aura_power_val_enter then
      condFrame.cond_aura_power_val_enter:Hide()
    end

    if condFrame.cond_aura_hp_my then
      condFrame.cond_aura_hp_my:Hide()
    end
    if condFrame.cond_aura_hp_tgt then
      condFrame.cond_aura_hp_tgt:Hide()
    end
    if condFrame.cond_aura_hp_comp then
      condFrame.cond_aura_hp_comp:Hide()
    end
    if condFrame.cond_aura_hp_val then
      condFrame.cond_aura_hp_val:Hide()
    end
    if condFrame.cond_aura_hp_val_enter then
      condFrame.cond_aura_hp_val_enter:Hide()
    end

    if condFrame.cond_aura_cp_cb then
      condFrame.cond_aura_cp_cb:Hide()
    end
    if condFrame.cond_aura_cp_comp then
      condFrame.cond_aura_cp_comp:Hide()
    end
    if condFrame.cond_aura_cp_val then
      condFrame.cond_aura_cp_val:Hide()
    end
    if condFrame.cond_aura_cp_val_enter then
      condFrame.cond_aura_cp_val_enter:Hide()
    end
    if condFrame.cond_aura_class_note then
      condFrame.cond_aura_class_note:Hide()
    end
    if condFrame.cond_aura_trackpet then
      condFrame.cond_aura_trackpet:Hide()
    end
    if condFrame.cond_aura_weaponDD then
      condFrame.cond_aura_weaponDD:Hide()
    end

    -- 非光环编辑时隐藏光环目标距离/类型行
    if condFrame.cond_aura_distanceDD then
      condFrame.cond_aura_distanceDD:Hide()
    end
    if condFrame.cond_aura_unitTypeDD then
      condFrame.cond_aura_unitTypeDD:Hide()
    end

    -- 非物品编辑时也隐藏物品目标距离/类型行
    if condFrame.cond_item_distanceDD then
      condFrame.cond_item_distanceDD:Hide()
    end
    if condFrame.cond_item_unitTypeDD then
      condFrame.cond_item_unitTypeDD:Hide()
    end

    if condFrame.cond_aura_mine then
      condFrame.cond_aura_mine:Hide()
    end
    if condFrame.cond_aura_others then
      condFrame.cond_aura_others:Hide()
    end
    if condFrame.cond_aura_owner_tip then
      condFrame.cond_aura_owner_tip:Hide()
    end
    if condFrame.cond_item_where_equipped then
      condFrame.cond_item_where_equipped:Hide()
    end
    if condFrame.cond_item_where_bag then
      condFrame.cond_item_where_bag:Hide()
    end
    if condFrame.cond_item_where_missing then
      condFrame.cond_item_where_missing:Hide()
    end
    if condFrame.cond_item_notcd then
      condFrame.cond_item_notcd:Hide()
    end
    if condFrame.cond_item_oncd then
      condFrame.cond_item_oncd:Hide()
    end
    if condFrame.cond_item_incombat then
      condFrame.cond_item_incombat:Hide()
    end
    if condFrame.cond_item_outcombat then
      condFrame.cond_item_outcombat:Hide()
    end
    if condFrame.cond_item_groupingDD then
      condFrame.cond_item_groupingDD:Hide()
    end
    if condFrame.cond_item_target_help then
      condFrame.cond_item_target_help:Hide()
    end
    if condFrame.cond_item_target_harm then
      condFrame.cond_item_target_harm:Hide()
    end
    if condFrame.cond_item_target_self then
      condFrame.cond_item_target_self:Hide()
    end
    if condFrame.cond_item_glow then
      condFrame.cond_item_glow:Hide()
    end
    if condFrame.cond_item_greyscale then
      condFrame.cond_item_greyscale:Hide()
    end
    if condFrame.cond_item_fade then
      condFrame.cond_item_fade:Hide()
    end
    if condFrame.cond_item_fade_slider then
      condFrame.cond_item_fade_slider:Hide()
    end
    if condFrame.cond_item_text_time then
      condFrame.cond_item_text_time:Hide()
    end
    if condFrame.cond_item_text_time_override then
      condFrame.cond_item_text_time_override:Hide()
    end
    if condFrame.cond_item_text_override_note then
      condFrame.cond_item_text_override_note:Hide()
    end
    if condFrame.cond_item_enchant then
      condFrame.cond_item_enchant:Hide()
    end
    if condFrame.cond_item_text_enchant then
      condFrame.cond_item_text_enchant:Hide()
    end
    if condFrame.cond_item_power then
      condFrame.cond_item_power:Hide()
    end
    if condFrame.cond_item_power_comp then
      condFrame.cond_item_power_comp:Hide()
    end
    if condFrame.cond_item_power_val then
      condFrame.cond_item_power_val:Hide()
    end
    if condFrame.cond_item_power_val_enter then
      condFrame.cond_item_power_val_enter:Hide()
    end
    if condFrame.cond_item_hp_my then
      condFrame.cond_item_hp_my:Hide()
    end
    if condFrame.cond_item_hp_tgt then
      condFrame.cond_item_hp_tgt:Hide()
    end
    if condFrame.cond_item_hp_comp then
      condFrame.cond_item_hp_comp:Hide()
    end
    if condFrame.cond_item_hp_val then
      condFrame.cond_item_hp_val:Hide()
    end
    if condFrame.cond_item_hp_val_enter then
      condFrame.cond_item_hp_val_enter:Hide()
    end
    if condFrame.cond_item_remaining_cb then
      condFrame.cond_item_remaining_cb:Hide()
    end
    if condFrame.cond_item_remaining_comp then
      condFrame.cond_item_remaining_comp:Hide()
    end
    if condFrame.cond_item_remaining_val then
      condFrame.cond_item_remaining_val:Hide()
    end
    if condFrame.cond_item_remaining_val_enter then
      condFrame.cond_item_remaining_val_enter:Hide()
    end
    if condFrame.cond_item_cp_cb then
      condFrame.cond_item_cp_cb:Hide()
    end
    if condFrame.cond_item_cp_comp then
      condFrame.cond_item_cp_comp:Hide()
    end
    if condFrame.cond_item_cp_val then
      condFrame.cond_item_cp_val:Hide()
    end
    if condFrame.cond_item_cp_val_enter then
      condFrame.cond_item_cp_val_enter:Hide()
    end
    if condFrame.cond_item_formDD then
      condFrame.cond_item_formDD:Hide()
    end
    if condFrame.cond_item_inv_trinket1 then
      condFrame.cond_item_inv_trinket1:Hide()
    end
    if condFrame.cond_item_inv_trinket2 then
      condFrame.cond_item_inv_trinket2:Hide()
    end
    if condFrame.cond_item_inv_trinket_first then
      condFrame.cond_item_inv_trinket_first:Hide()
    end
    if condFrame.cond_item_inv_trinket_both then
      condFrame.cond_item_inv_trinket_both:Hide()
    end
    if condFrame.cond_item_inv_wep_mainhand then
      condFrame.cond_item_inv_wep_mainhand:Hide()
    end
    if condFrame.cond_item_inv_wep_offhand then
      condFrame.cond_item_inv_wep_offhand:Hide()
    end
    if condFrame.cond_item_inv_wep_ranged then
      condFrame.cond_item_inv_wep_ranged:Hide()
    end
    if condFrame.cond_item_inv_wep_ammo then
      condFrame.cond_item_inv_wep_ammo:Hide()
    end
    if condFrame.cond_item_class_note then
      condFrame.cond_item_class_note:Hide()
    end
    if condFrame.cond_item_weaponDD then
      condFrame.cond_item_weaponDD:Hide()
    end
    if condFrame.cond_item_clickable then
      condFrame.cond_item_clickable:Hide()
    end
    -- 在编辑技能时隐藏光环和物品的目标状态行
    if condFrame.cond_aura_target_alive then
      condFrame.cond_aura_target_alive:Hide()
    end
    if condFrame.cond_aura_target_dead then
      condFrame.cond_aura_target_dead:Hide()
    end
    if condFrame.cond_item_target_alive then
      condFrame.cond_item_target_alive:Hide()
    end
    if condFrame.cond_item_target_dead then
      condFrame.cond_item_target_dead:Hide()
    end
    -- 非物品编辑时隐藏物品层数行
    if condFrame.cond_item_stacks_cb then
      condFrame.cond_item_stacks_cb:Hide()
    end
    if condFrame.cond_item_text_stack then
      condFrame.cond_item_text_stack:Hide()
    end
    if condFrame.cond_item_stacks_comp then
      condFrame.cond_item_stacks_comp:Hide()
    end
    if condFrame.cond_item_stacks_val then
      condFrame.cond_item_stacks_val:Hide()
    end
    if condFrame.cond_item_stacks_val_enter then
      condFrame.cond_item_stacks_val_enter:Hide()
    end

    -- 物品类型
  elseif data.type == "Item" then
    if ShowSeparatorsForType then ShowSeparatorsForType("item") end
    -- 确保不在光环编辑时显示光环专用提示
    if condFrame.cond_aura_tip then
      condFrame.cond_aura_tip:Hide()
    end
    if AuraCond_RefreshFromDB then
      AuraCond_RefreshFromDB("item")
    end
    if VfxCond_RefreshFromDB then
      VfxCond_RefreshFromDB("item")
    end

local ic = c.item or {}

    local function _enCheck(cb)
      if not cb then
        return
      end

      -- CheckButton/EditBox有:Enable()；UIDropDownMenuTemplate没有。
      if cb.Enable then
        cb:Enable()
      elseif UIDropDownMenu_EnableDropDown then
        -- 视为下拉框
        pcall(UIDropDownMenu_EnableDropDown, cb)
      end

      if cb.text and cb.text.SetTextColor then
        cb.text:SetTextColor(1, 0.82, 0)
      end
    end

    local function _disCheck(cb)
      if not cb then
        return
      end

      if cb.Disable then
        cb:Disable()
      elseif UIDropDownMenu_DisableDropDown then
        pcall(UIDropDownMenu_DisableDropDown, cb)
      end

      if cb.text and cb.text.SetTextColor then
        cb.text:SetTextColor(0.6, 0.6, 0.6)
      end
    end

    -- 位置/物品栏槽位（特殊物品）
    local dispName = data.displayName or currentKey or ""
    local isTrinketSlots = (dispName == "---已装备的饰品栏位---")
    local isWeaponSlots = (dispName == "---已装备的武器栏位---")

    -- 仅当主手/副手武器槽合成条目且mode=="notcd"/"both"时，将“数量”改为“层数”。
    condFrame._item_qty_cb_default = condFrame._item_qty_cb_default or "数量"
    condFrame._item_qty_sep_default = condFrame._item_qty_sep_default or "数量"

    -- 此处需要mode（此块运行在后面的mode-local之前）
    local _qtyMode = ic.mode or "notcd"
    if _qtyMode ~= "notcd" and _qtyMode ~= "oncd" and _qtyMode ~= "both" then
      _qtyMode = "notcd"
    end

	local _qtySlot = ic.inventorySlot
	if _qtySlot ~= "MAINHAND" and _qtySlot ~= "OFFHAND" and _qtySlot ~= "RANGED" and _qtySlot ~= "AMMO" then
	  _qtySlot = "MAINHAND"
	end
	local useStacks = (isWeaponSlots and (_qtySlot == "MAINHAND" or _qtySlot == "OFFHAND") and (_qtyMode == "notcd" or _qtyMode == "both")) and true or false

    if useStacks then
      if condFrame.cond_item_stacks_cb and condFrame.cond_item_stacks_cb.text and condFrame.cond_item_stacks_cb.text.SetText then
        condFrame.cond_item_stacks_cb.text:SetText("层数")
      end
      SetSeparator("item", 9, "层数 (临时武器附魔)", true, true)
    else
      if condFrame.cond_item_stacks_cb and condFrame.cond_item_stacks_cb.text and condFrame.cond_item_stacks_cb.text.SetText then
        condFrame.cond_item_stacks_cb.text:SetText(condFrame._item_qty_cb_default)
      end
      SetSeparator("item", 9, condFrame._item_qty_sep_default, true, true)
    end

    local isMissing = false

    if isTrinketSlots or isWeaponSlots then
      -- 特殊合成条目：使用“物品栏槽位”行，从不驱动缺失逻辑
      SetSeparator("item", 1, "物品栏槽位", true, true)

      -- 隐藏正常的位置控件
      condFrame.cond_item_where_equipped:Hide()
      condFrame.cond_item_where_bag:Hide()
      condFrame.cond_item_where_missing:Hide()

      if isTrinketSlots then
        -- 隐藏武器单选钮
        if condFrame.cond_item_inv_wep_mainhand then
          condFrame.cond_item_inv_wep_mainhand:Hide()
          condFrame.cond_item_inv_wep_offhand:Hide()
          condFrame.cond_item_inv_wep_ranged:Hide()
          if condFrame.cond_item_inv_wep_ammo then
            condFrame.cond_item_inv_wep_ammo:Hide()
          end
        end

        -- 显示饰品单选钮
        condFrame.cond_item_inv_trinket1:Show()
        condFrame.cond_item_inv_trinket2:Show()
        condFrame.cond_item_inv_trinket_first:Show()
        condFrame.cond_item_inv_trinket_both:Show()

        local slot = ic.inventorySlot
        if slot ~= "TRINKET1" and slot ~= "TRINKET2" and slot ~= "TRINKET_FIRST" and slot ~= "TRINKET_BOTH" then
          -- 默认：首个就绪
          slot = "TRINKET_FIRST"
          ic.inventorySlot = slot
        end

        condFrame.cond_item_inv_trinket1:SetChecked(slot == "TRINKET1")
        condFrame.cond_item_inv_trinket2:SetChecked(slot == "TRINKET2")
        condFrame.cond_item_inv_trinket_first:SetChecked(slot == "TRINKET_FIRST")
        condFrame.cond_item_inv_trinket_both:SetChecked(slot == "TRINKET_BOTH")

      else
        -- 隐藏饰品单选钮
        if condFrame.cond_item_inv_trinket1 then
          condFrame.cond_item_inv_trinket1:Hide()
          condFrame.cond_item_inv_trinket2:Hide()
          condFrame.cond_item_inv_trinket_first:Hide()
          condFrame.cond_item_inv_trinket_both:Hide()
        end

        -- 显示武器单选钮
        condFrame.cond_item_inv_wep_mainhand:Show()
        condFrame.cond_item_inv_wep_offhand:Show()
        condFrame.cond_item_inv_wep_ranged:Show()
        if condFrame.cond_item_inv_wep_ammo then
          condFrame.cond_item_inv_wep_ammo:Show()
        end

        local slot = ic.inventorySlot
        if slot ~= "MAINHAND" and slot ~= "OFFHAND" and slot ~= "RANGED" and slot ~= "AMMO" then
          -- 默认：主手
          slot = "MAINHAND"
          ic.inventorySlot = slot
        end

        local _, classTag = UnitClass("player")
        classTag = classTag and string.upper(classTag) or ""
        local ammoAllowed = (classTag == "WARRIOR" or classTag == "ROGUE" or classTag == "HUNTER")
        if (slot == "AMMO") and (not ammoAllowed) then
          slot = "MAINHAND"
          ic.inventorySlot = slot
        end

        condFrame.cond_item_inv_wep_mainhand:SetChecked(slot == "MAINHAND")
        condFrame.cond_item_inv_wep_offhand:SetChecked(slot == "OFFHAND")
        condFrame.cond_item_inv_wep_ranged:SetChecked(slot == "RANGED")
        if condFrame.cond_item_inv_wep_ammo then
          condFrame.cond_item_inv_wep_ammo:SetChecked(slot == "AMMO")
          if ammoAllowed then
            _enCheck(condFrame.cond_item_inv_wep_ammo)
          else
            condFrame.cond_item_inv_wep_ammo:SetChecked(false)
            _disCheck(condFrame.cond_item_inv_wep_ammo)
          end
        end
      end

      -- isMissing在此保持false → 不会灰显其他行

    else
      -- 普通物品：原始位置行为
      SetSeparator("item", 1, "位置", true, true)

      -- 隐藏任何存在的槽位单选钮
      if condFrame.cond_item_inv_trinket1 then
        condFrame.cond_item_inv_trinket1:Hide()
        condFrame.cond_item_inv_trinket2:Hide()
        condFrame.cond_item_inv_trinket_first:Hide()
        condFrame.cond_item_inv_trinket_both:Hide()
      end
      if condFrame.cond_item_inv_wep_mainhand then
        condFrame.cond_item_inv_wep_mainhand:Hide()
        condFrame.cond_item_inv_wep_offhand:Hide()
        condFrame.cond_item_inv_wep_ranged:Hide()
        if condFrame.cond_item_inv_wep_ammo then
          condFrame.cond_item_inv_wep_ammo:Hide()
        end
      end

      condFrame.cond_item_where_equipped:Show()
      condFrame.cond_item_where_bag:Show()
      condFrame.cond_item_where_missing:Show()

      local eq = (ic.whereEquipped ~= false)
      local bg = (ic.whereBag ~= false)
      local ms = (ic.whereMissing == true)

      if not eq and not bg and not ms then
        eq = true
      end

      condFrame.cond_item_where_equipped:SetChecked(eq)
      condFrame.cond_item_where_bag:SetChecked(bg)
      condFrame.cond_item_where_missing:SetChecked(ms)

      -- 为剩余的物品逻辑保留外部isMissing标志
      -- 仅当缺失是唯一的选中项时才视为“缺失”。
      -- 如果已装备或背包也被选中，允许配置其他属性（层数、冷却等）
      isMissing = (ms and (not eq) and (not bg))
    end

    ----------------------------------------------------------------
    -- === 目标距离与类型（物品） ===   <-- 现在所有物品都有
    ----------------------------------------------------------------
    if condFrame.cond_item_distanceDD then
      condFrame.cond_item_distanceDD:Show()
      condFrame.cond_item_unitTypeDD:Show()

      local function _RestoreItemDD(dd, val, placeholder)
        if not dd then
          return
        end
        if val and val ~= "" then
          if UIDropDownMenu_SetSelectedValue then
            pcall(UIDropDownMenu_SetSelectedValue, dd, val)
          end
          if UIDropDownMenu_SetText then
            pcall(UIDropDownMenu_SetText, val, dd)
          end
          _GoldifyDD(dd)
        else
          if UIDropDownMenu_SetSelectedValue then
            pcall(UIDropDownMenu_SetSelectedValue, dd, nil)
          end
          if UIDropDownMenu_SetText then
            pcall(UIDropDownMenu_SetText, placeholder, dd)
          end
          _WhiteifyDDText(dd)
        end
      end

      -- 对于物品，始终清除并硬禁用距离
      ic.targetDistance = nil
      _RestoreItemDD(condFrame.cond_item_distanceDD, nil, "距离")
      _SetDDEnabled(condFrame.cond_item_distanceDD, false, "距离")

      -- UnitType仍遵循旧规则
      _RestoreItemDD(condFrame.cond_item_unitTypeDD, ic.targetUnitType, "单位类型")

      local isMissingForDD = (ic.whereMissing == true)
      local hasSelfTarget = (ic.targetSelf == true)

      if isMissingForDD or hasSelfTarget then
        ic.targetUnitType = nil
        _SetDDEnabled(condFrame.cond_item_unitTypeDD, false, "单位类型")
      else
        _SetDDEnabled(condFrame.cond_item_unitTypeDD, true, "单位类型")
      end
    end

    -- 可用性和冷却
    condFrame.cond_item_notcd:Show()
    condFrame.cond_item_oncd:Show()
    condFrame.cond_item_sound_oncd_cb:Show()
    condFrame.cond_item_sound_oncd_dd:Show()
    condFrame.cond_item_sound_offcd_cb:Show()
    condFrame.cond_item_sound_offcd_dd:Show()

    _enCheck(condFrame.cond_item_notcd)

    local iSoundOn = (ic.soundOnCDEnabled == true)
    local iSoundOff = (ic.soundOffCDEnabled == true)
    local iSoundOnSel = ic.soundOnCD
    local iSoundOffSel = ic.soundOffCD
    condFrame.cond_item_sound_oncd_cb:SetChecked(iSoundOn)
    condFrame.cond_item_sound_offcd_cb:SetChecked(iSoundOff)
    DoiteEdit_InitSoundDropdown(condFrame.cond_item_sound_oncd_dd, "item", "soundOnCD", iSoundOnSel)
    DoiteEdit_InitSoundDropdown(condFrame.cond_item_sound_offcd_dd, "item", "soundOffCD", iSoundOffSel)
    DoiteEdit_EnableCheck(condFrame.cond_item_sound_oncd_cb)
    DoiteEdit_EnableCheck(condFrame.cond_item_sound_offcd_cb)
    DoiteEdit_SetDropdownInteractive(condFrame.cond_item_sound_oncd_dd, iSoundOn)
    DoiteEdit_SetDropdownInteractive(condFrame.cond_item_sound_offcd_dd, iSoundOff)
    _enCheck(condFrame.cond_item_oncd)

    -- 可点击
    if condFrame.cond_item_clickable then
      condFrame.cond_item_clickable:Show()
      _enCheck(condFrame.cond_item_clickable)
      condFrame.cond_item_clickable:SetChecked(ic.clickable == true)
    end

    -- 模式（必须在任何基于模式的UI逻辑之前定义）
    local mode = ic.mode or "notcd"
    if mode ~= "notcd" and mode ~= "oncd" and mode ~= "both" then
      mode = "notcd"
    end

    condFrame.cond_item_notcd:SetChecked(mode == "notcd" or mode == "both")
    condFrame.cond_item_oncd:SetChecked(mode == "oncd" or mode == "both")

    local isMainOffhandWeaponSlot = (ic.inventorySlot == "MAINHAND" or ic.inventorySlot == "OFFHAND")

    
    -- 附魔状态下拉框：仅对主手/副手武器槽 + notcd/both + 非缺失启用。其他地方禁用，并在禁用时清除ic.enchant。
    if condFrame.cond_item_enchant then
      condFrame.cond_item_enchant:Show()

      local allowEnchant = (not isMissing) and isWeaponSlots and isMainOffhandWeaponSlot and (mode == "notcd" or mode == "both")
      if allowEnchant then
        _enCheck(condFrame.cond_item_enchant)

        local txt = "附魔状态"
        if ic.enchant == true then
          txt = "已附魔"
          if UIDropDownMenu_SetSelectedValue then
            pcall(UIDropDownMenu_SetSelectedValue, condFrame.cond_item_enchant, "true")
          end
        elseif ic.enchant == false then
          txt = "未附魔"
          if UIDropDownMenu_SetSelectedValue then
            pcall(UIDropDownMenu_SetSelectedValue, condFrame.cond_item_enchant, "false")
          end
        else
        -- nil => 占位符；清除选中值以避免旧选择残留
          if UIDropDownMenu_SetSelectedValue then
            pcall(UIDropDownMenu_SetSelectedValue, condFrame.cond_item_enchant, nil)
          end
        end

        if UIDropDownMenu_SetText then
          pcall(UIDropDownMenu_SetText, txt, condFrame.cond_item_enchant)
        end
        if _GoldifyDD then
          _GoldifyDD(condFrame.cond_item_enchant)
        end
      else
        -- 不允许（包括mode=="oncd"或非武器槽物品）
        if ic.enchant ~= nil then
          ic.enchant = nil
        end

        _disCheck(condFrame.cond_item_enchant)
        if UIDropDownMenu_SetText then
          pcall(UIDropDownMenu_SetText, "附魔状态", condFrame.cond_item_enchant)
        end
        if _GreyifyDD then
          _GreyifyDD(condFrame.cond_item_enchant)
        end
      end
    end

    -- 图标文本：附魔剩余时间。仅对主手/副手武器槽 + notcd/both + 非缺失启用，且仅当附魔状态不是明确“未附魔”时。如果选择“未附魔”，则强制关闭并禁用 + 清除数据库条目（未附魔时无法显示剩余时间）。
    if condFrame.cond_item_text_enchant then
      condFrame.cond_item_text_enchant:Show()

      local allowEnchantText = (not isMissing) and isWeaponSlots and isMainOffhandWeaponSlot and (mode == "notcd" or mode == "both")

      -- 额外规则：“未附魔”禁用此复选框并清除其数据库条目
      if allowEnchantText and (ic.enchant == false) then
        if ic.textTimeRemaining ~= nil then
          ic.textTimeRemaining = nil
        end
        condFrame.cond_item_text_enchant:SetChecked(false)
        _disCheck(condFrame.cond_item_text_enchant)

      elseif allowEnchantText then
        _enCheck(condFrame.cond_item_text_enchant)
        condFrame.cond_item_text_enchant:SetChecked(ic.textTimeRemaining == true)

      else
        -- 相反模式/非武器物品：强制关闭 + 禁用（但不清除数据库）
        condFrame.cond_item_text_enchant:SetChecked(false)
        _disCheck(condFrame.cond_item_text_enchant)
      end
    end

    if isMissing then
      condFrame.cond_item_notcd:SetChecked(false)
      condFrame.cond_item_oncd:SetChecked(false)
      _disCheck(condFrame.cond_item_notcd)
      _disCheck(condFrame.cond_item_oncd)

      if condFrame.cond_item_enchant then
        if ic.enchant ~= nil then
          ic.enchant = nil
        end
        _disCheck(condFrame.cond_item_enchant)
        if UIDropDownMenu_SetText then
          pcall(UIDropDownMenu_SetText, "附魔状态", condFrame.cond_item_enchant)
        end
        if _GreyifyDD then
          _GreyifyDD(condFrame.cond_item_enchant)
        end
      end

      if condFrame.cond_item_text_enchant then
        condFrame.cond_item_text_enchant:SetChecked(false)
        _disCheck(condFrame.cond_item_text_enchant)
      end
    end

    -- 战斗状态
    condFrame.cond_item_incombat:Show()
    condFrame.cond_item_outcombat:Show()
    if condFrame.cond_item_groupingDD then
      condFrame.cond_item_groupingDD:Show()
    end

    local inC, outC
    if ic.inCombat ~= nil or ic.outCombat ~= nil then
      inC = ic.inCombat and true or false
      outC = ic.outCombat and true or false
    else
      inC, outC = true, true
    end
    condFrame.cond_item_incombat:SetChecked(inC)
    condFrame.cond_item_outcombat:SetChecked(outC)

    if condFrame.cond_item_groupingDD then
      local gm = _DeriveGroupingMode(ic)
      local txt
      if gm == "any" then
        txt = "任意"
      elseif gm == "nogroup" then
        txt = "不在队伍/团队中"
      elseif gm == "party" then
        txt = "在队伍中"
      elseif gm == "raid" then
        txt = "在团队中"
      elseif gm == "partyraid" then
        txt = "在队伍或团队中"
      else
        txt = "组队状态"
      end

      if gm ~= nil then
        if UIDropDownMenu_SetSelectedValue then
          pcall(UIDropDownMenu_SetSelectedValue, condFrame.cond_item_groupingDD, gm)
        end
      else
      end

      if UIDropDownMenu_SetText then
        pcall(UIDropDownMenu_SetText, txt, condFrame.cond_item_groupingDD)
      end
      if _GoldifyDD then _GoldifyDD(condFrame.cond_item_groupingDD) end
    end

    _enCheck(condFrame.cond_item_incombat)
    _enCheck(condFrame.cond_item_outcombat)
    _enCheck(condFrame.cond_item_groupingDD)

    -- 目标条件
    condFrame.cond_item_target_help:Show()
    condFrame.cond_item_target_harm:Show()
    condFrame.cond_item_target_self:Show()
    condFrame.cond_item_target_help:SetChecked(ic.targetHelp == true)
    condFrame.cond_item_target_harm:SetChecked(ic.targetHarm == true)
    condFrame.cond_item_target_self:SetChecked(ic.targetSelf == true)

    -- 目标状态（物品）
    if condFrame.cond_item_target_alive then
      condFrame.cond_item_target_alive:SetChecked(ic.targetAlive == true)
      condFrame.cond_item_target_alive:Show()
    end
    if condFrame.cond_item_target_dead then
      condFrame.cond_item_target_dead:SetChecked(ic.targetDead == true)
      condFrame.cond_item_target_dead:Show()
    end

    if condFrame.cond_aura_text_time_override then
      condFrame.cond_aura_text_time_override:Hide()
    end
    if condFrame.cond_aura_text_stack_override then
      condFrame.cond_aura_text_stack_override:Hide()
    end
    if condFrame.cond_aura_text_override_note then
      condFrame.cond_aura_text_override_note:Hide()
    end

    -- 视觉效果
    condFrame.cond_item_glow:Show()
    condFrame.cond_item_greyscale:Show()
    condFrame.cond_item_fade:Show()
    condFrame.cond_item_text_time:Show()
    condFrame.cond_item_glow:SetChecked(ic.glow == true)
    condFrame.cond_item_greyscale:SetChecked(ic.greyscale == true)
    condFrame.cond_item_fade:SetChecked(ic.fade == true)
    if ic.fade == true then
      local fadeAlpha = tonumber(ic.fadeAlpha) or 0
      if fadeAlpha < 0 then fadeAlpha = 0 end
      if fadeAlpha > 1 then fadeAlpha = 1 end
      condFrame.cond_item_fade_slider:SetText(tostring(math.floor((fadeAlpha * 100) + 0.5)))
      condFrame.cond_item_fade_slider:Show()
    else
      condFrame.cond_item_fade_slider:Hide()
    end

    -- 保持物品文本-剩余时间标签不变
    do
      local lbl = "图标文本：剩余时间"
      if condFrame.cond_item_text_time and condFrame.cond_item_text_time.text
          and condFrame.cond_item_text_time.text.SetText then
        condFrame.cond_item_text_time.text:SetText(lbl)
      end
    end

    -- 图标文本：剩余时间（共享数据库键：ic.textTimeRemaining）

    do
      local allowTime = (not isMissing) and (mode == "oncd" or ((not isMainOffhandWeaponSlot) and mode == "both"))

      if allowTime then
        _enCheck(condFrame.cond_item_text_time)
        condFrame.cond_item_text_time:SetChecked(ic.textTimeRemaining == true)
      else
        condFrame.cond_item_text_time:SetChecked(false)
        _disCheck(condFrame.cond_item_text_time)

        if not (isMainOffhandWeaponSlot and (mode == "notcd" or mode == "both")) then
          if ic.textTimeRemaining ~= nil then
            ic.textTimeRemaining = nil
          end
        end
      end

      if condFrame.cond_item_text_time_override then
        if allowTime and condFrame.cond_item_text_time:GetChecked() then
          condFrame.cond_item_text_time_override:Show()
          condFrame.cond_item_text_time_override:SetText(ic.remOverride or "")
        else
          condFrame.cond_item_text_time_override:Hide()
        end
      end
      if condFrame.cond_item_text_override_note then
        if allowTime and condFrame.cond_item_text_time:GetChecked() then
          condFrame.cond_item_text_override_note:Show()
        else
          condFrame.cond_item_text_override_note:Hide()
        end
      end
    end

    -- 物品层数行（物品层数 + 文本层数计数器）
    do
      local stacksOn = (ic.stacksEnabled == true)
      local textStacks = (ic.textStackCounter == true)

      -- 对于任何物品类型条目，始终显示这两个复选框
      condFrame.cond_item_stacks_cb:Show()
      condFrame.cond_item_text_stack:Show()

      if isMissing then
        condFrame.cond_item_stacks_cb:SetChecked(false)
        condFrame.cond_item_text_stack:SetChecked(false)

        _disCheck(condFrame.cond_item_stacks_cb)
        _disCheck(condFrame.cond_item_text_stack)

        if condFrame.cond_item_stacks_comp then
          condFrame.cond_item_stacks_comp:Hide()
        end
        if condFrame.cond_item_stacks_val then
          condFrame.cond_item_stacks_val:Hide()
        end
        if condFrame.cond_item_stacks_val_enter then
          condFrame.cond_item_stacks_val_enter:Hide()
        end
      else
        _enCheck(condFrame.cond_item_stacks_cb)
        _enCheck(condFrame.cond_item_text_stack)

        condFrame.cond_item_stacks_cb:SetChecked(stacksOn)
        condFrame.cond_item_text_stack:SetChecked(textStacks)

        if stacksOn then
          if condFrame.cond_item_stacks_comp then
            condFrame.cond_item_stacks_comp:Show()
          end
          if condFrame.cond_item_stacks_val then
            condFrame.cond_item_stacks_val:Show()
          end
          if condFrame.cond_item_stacks_val_enter then
            condFrame.cond_item_stacks_val_enter:Show()
          end

          local comp = ic.stacksComp or ""
          UIDropDownMenu_SetSelectedValue(condFrame.cond_item_stacks_comp, comp)
          UIDropDownMenu_SetText(comp, condFrame.cond_item_stacks_comp)
          _GoldifyDD(condFrame.cond_item_stacks_comp)

          condFrame.cond_item_stacks_val:SetText(tostring(ic.stacksVal or 0))
        else
          if condFrame.cond_item_stacks_comp then
            condFrame.cond_item_stacks_comp:Hide()
          end
          if condFrame.cond_item_stacks_val then
            condFrame.cond_item_stacks_val:Hide()
          end
          if condFrame.cond_item_stacks_val_enter then
            condFrame.cond_item_stacks_val_enter:Hide()
          end
        end
      end
    end

    -- 资源
    condFrame.cond_item_power:Show()
    local pOn = (ic.powerEnabled == true)
    condFrame.cond_item_power:SetChecked(pOn)

    if isMissing then
      condFrame.cond_item_power:SetChecked(false)
      _disCheck(condFrame.cond_item_power)
      condFrame.cond_item_power_comp:Hide()
      condFrame.cond_item_power_val:Hide()
      condFrame.cond_item_power_val_enter:Hide()
    else
      _enCheck(condFrame.cond_item_power)
      if pOn then
        condFrame.cond_item_power_comp:Show()
        condFrame.cond_item_power_val:Show()
        condFrame.cond_item_power_val_enter:Show()
        local comp = ic.powerComp or ""
        UIDropDownMenu_SetSelectedValue(condFrame.cond_item_power_comp, comp)
        UIDropDownMenu_SetText(comp, condFrame.cond_item_power_comp)
        _GoldifyDD(condFrame.cond_item_power_comp)
        condFrame.cond_item_power_val:SetText(tostring(ic.powerVal or 0))
      else
        condFrame.cond_item_power_comp:Hide()
        condFrame.cond_item_power_val:Hide()
        condFrame.cond_item_power_val_enter:Hide()
      end
    end

    -- 生命值条件
    condFrame.cond_item_hp_my:Show()
    condFrame.cond_item_hp_tgt:Show()
    local hpMode = ic.hpMode
    condFrame.cond_item_hp_my:SetChecked(hpMode == "my")
    condFrame.cond_item_hp_tgt:SetChecked(hpMode == "target")

    if isMissing then
      condFrame.cond_item_hp_my:SetChecked(false)
      condFrame.cond_item_hp_tgt:SetChecked(false)
      _disCheck(condFrame.cond_item_hp_my)
      _disCheck(condFrame.cond_item_hp_tgt)
      condFrame.cond_item_hp_comp:Hide()
      condFrame.cond_item_hp_val:Hide()
      condFrame.cond_item_hp_val_enter:Hide()
    else
      _enCheck(condFrame.cond_item_hp_my)
      _enCheck(condFrame.cond_item_hp_tgt)
      if hpMode == "my" or hpMode == "target" then
        condFrame.cond_item_hp_comp:Show()
        condFrame.cond_item_hp_val:Show()
        condFrame.cond_item_hp_val_enter:Show()
        local comp = ic.hpComp or ""
        UIDropDownMenu_SetSelectedValue(condFrame.cond_item_hp_comp, comp)
        UIDropDownMenu_SetText(comp, condFrame.cond_item_hp_comp)
        _GoldifyDD(condFrame.cond_item_hp_comp)
        condFrame.cond_item_hp_val:SetText(tostring(ic.hpVal or 0))
      else
        condFrame.cond_item_hp_comp:Hide()
        condFrame.cond_item_hp_val:Hide()
        condFrame.cond_item_hp_val_enter:Hide()
      end
    end

    -- 剩余时间
    do
      local sepTitle = "剩余时间"
      if isMainOffhandWeaponSlot then
        if mode == "notcd" or mode == "both" then
          sepTitle = "剩余时间 (临时武器附魔)"
        elseif mode == "oncd" then
          sepTitle = "剩余时间"
        end
      end
      SetSeparator("item", 12, sepTitle, true, true)
    end
    condFrame.cond_item_remaining_cb:Show()
	if (not isMissing) and (mode == "oncd" or ((not isMainOffhandWeaponSlot) and mode == "both") or (isMainOffhandWeaponSlot and (mode == "notcd" or mode == "both"))) then
      _enCheck(condFrame.cond_item_remaining_cb)
      local remOn = (ic.remainingEnabled == true)
      condFrame.cond_item_remaining_cb:SetChecked(remOn)
      if remOn then
        condFrame.cond_item_remaining_comp:Show()
        condFrame.cond_item_remaining_val:Show()
        condFrame.cond_item_remaining_val_enter:Show()
        local comp = ic.remainingComp or ""
        UIDropDownMenu_SetSelectedValue(condFrame.cond_item_remaining_comp, comp)
        UIDropDownMenu_SetText(comp, condFrame.cond_item_remaining_comp)
        _GoldifyDD(condFrame.cond_item_remaining_comp)
        condFrame.cond_item_remaining_val:SetText(tostring(ic.remainingVal or 0))
      else
        condFrame.cond_item_remaining_comp:Hide()
        condFrame.cond_item_remaining_val:Hide()
        condFrame.cond_item_remaining_val_enter:Hide()
      end
    else
      if ic.remainingEnabled then
        ic.remainingEnabled = false
      end
      condFrame.cond_item_remaining_cb:SetChecked(false)
      _disCheck(condFrame.cond_item_remaining_cb)
      condFrame.cond_item_remaining_comp:Hide()
      condFrame.cond_item_remaining_val:Hide()
      condFrame.cond_item_remaining_val_enter:Hide()
    end

    -- 职业专属（连击点数 / 提示 / 武器过滤器）
    local isRogueOrDruid = _IsRogueOrDruid and _IsRogueOrDruid() or false
    local isWPS = _IsWarriorPaladinShaman()

    -- 默认：隐藏武器下拉框；仅对战士/圣骑士/萨满显示并初始化
    if condFrame.cond_item_weaponDD then
      condFrame.cond_item_weaponDD:Hide()
    end

    if isRogueOrDruid then
      condFrame.cond_item_cp_cb:Show()
      if condFrame.cond_item_class_note then
        condFrame.cond_item_class_note:Hide()
      end

      if isMissing then
        -- 物品标记为缺失：保持连击点数行可见但强制关闭并灰显
        if ic.cpEnabled then
          ic.cpEnabled = false
        end
        condFrame.cond_item_cp_cb:SetChecked(false)
        _disCheck(condFrame.cond_item_cp_cb)
        condFrame.cond_item_cp_comp:Hide()
        condFrame.cond_item_cp_val:Hide()
        condFrame.cond_item_cp_val_enter:Hide()
      else
        _enCheck(condFrame.cond_item_cp_cb)
        local cpOn = (ic.cpEnabled == true)
        condFrame.cond_item_cp_cb:SetChecked(cpOn)
        if cpOn then
          condFrame.cond_item_cp_comp:Show()
          condFrame.cond_item_cp_val:Show()
          condFrame.cond_item_cp_val_enter:Show()
          local comp = ic.cpComp or ""
          UIDropDownMenu_SetSelectedValue(condFrame.cond_item_cp_comp, comp)
          UIDropDownMenu_SetText(comp, condFrame.cond_item_cp_comp)
          _GoldifyDD(condFrame.cond_item_cp_comp)
          condFrame.cond_item_cp_val:SetText(tostring(ic.cpVal or 0))
        else
          condFrame.cond_item_cp_comp:Hide()
          condFrame.cond_item_cp_val:Hide()
          condFrame.cond_item_cp_val_enter:Hide()
        end
      end

    elseif isWPS and condFrame.cond_item_weaponDD then
      -- 战士/圣骑士/萨满：使用武器/战斗风格下拉框代替连击点数
      condFrame.cond_item_cp_cb:Hide()
      condFrame.cond_item_cp_comp:Hide()
      condFrame.cond_item_cp_val:Hide()
      condFrame.cond_item_cp_val_enter:Hide()
      if condFrame.cond_item_class_note then
        condFrame.cond_item_class_note:Hide()
      end

      condFrame.cond_item_weaponDD:Show()
      InitWeaponDropdown(condFrame.cond_item_weaponDD, data, "item")

    else
      -- 其他职业：无连击点数且无武器过滤器 → 显示中性提示
      condFrame.cond_item_cp_cb:Hide()
      condFrame.cond_item_cp_comp:Hide()
      condFrame.cond_item_cp_val:Hide()
      condFrame.cond_item_cp_val_enter:Hide()
      if condFrame.cond_item_class_note then
        if _IsHunterOrWarlock and _IsHunterOrWarlock() then
          condFrame.cond_item_class_note:SetText("在此部分下方提供宠物跟踪选项。")
        else
          condFrame.cond_item_class_note:SetText("未为你的职业添加专属选项。")
        end
        condFrame.cond_item_class_note:Show()
      end
    end

    -- 形态下拉框（物品）
    if condFrame.cond_ability_formDD then
      condFrame.cond_ability_formDD:Hide()
    end
    if condFrame.cond_aura_formDD then
      condFrame.cond_aura_formDD:Hide()
    end

    local choices = (function()
      local _, cls = UnitClass("player")
      cls = cls and string.upper(cls) or ""
      return (cls == "WARRIOR" or cls == "ROGUE" or cls == "DRUID" or cls == "PRIEST" or cls == "PALADIN")
    end)()
    if choices and condFrame.cond_item_formDD then
      condFrame.cond_item_formDD:Show()
      ClearDropdown(condFrame.cond_item_formDD)
      InitFormDropdown(condFrame.cond_item_formDD, data, "item")
      local v = ic.form
      if v and v ~= "所有形态" and v ~= "" then
        UIDropDownMenu_SetSelectedValue(condFrame.cond_item_formDD, v)
        UIDropDownMenu_SetText(v, condFrame.cond_item_formDD)
        _GoldifyDD(condFrame.cond_item_formDD)
      else
        UIDropDownMenu_SetText("选择形态", condFrame.cond_item_formDD)
        _GoldifyDD(condFrame.cond_item_formDD)
      end
    elseif condFrame.cond_item_formDD then
      condFrame.cond_item_formDD:Hide()
      ClearDropdown(condFrame.cond_item_formDD)
    end

    -- 隐藏技能控件
    condFrame.cond_ability_usable:Hide()
    condFrame.cond_ability_notcd:Hide()
    condFrame.cond_ability_oncd:Hide()
    condFrame.cond_ability_incombat:Hide()
    condFrame.cond_ability_outcombat:Hide()
    if condFrame.cond_ability_groupingDD then
      condFrame.cond_ability_groupingDD:Hide()
    end
    condFrame.cond_ability_target_help:Hide()
    condFrame.cond_ability_target_harm:Hide()
    condFrame.cond_ability_target_self:Hide()
    condFrame.cond_ability_power:Hide()
    condFrame.cond_ability_power_comp:Hide()
    condFrame.cond_ability_power_val:Hide()
    condFrame.cond_ability_power_val_enter:Hide()
    condFrame.cond_ability_glow:Hide()
    condFrame.cond_ability_greyscale:Hide()
    condFrame.cond_ability_fade:Hide()
    condFrame.cond_ability_fade_slider:Hide()
    condFrame.cond_ability_slider:Hide()
    condFrame.cond_ability_slider_dir:Hide()
    condFrame.cond_ability_remaining_cb:Hide()
    condFrame.cond_ability_remaining_comp:Hide()
    condFrame.cond_ability_remaining_val:Hide()
    condFrame.cond_ability_remaining_val_enter:Hide()
    condFrame.cond_ability_text_time:Hide()
    condFrame.cond_ability_slider_glow:Hide()
    condFrame.cond_ability_slider_grey:Hide()
    condFrame.cond_ability_hp_my:Hide()
    condFrame.cond_ability_hp_tgt:Hide()
    condFrame.cond_ability_hp_comp:Hide()
    condFrame.cond_ability_hp_val:Hide()
    condFrame.cond_ability_hp_val_enter:Hide()
    condFrame.cond_ability_cp_cb:Hide()
    condFrame.cond_ability_cp_comp:Hide()
    condFrame.cond_ability_cp_val:Hide()
    condFrame.cond_ability_cp_val_enter:Hide()
    if condFrame.cond_ability_class_note then
      condFrame.cond_ability_class_note:Hide()
    end
    if condFrame.cond_ability_formDD then
      condFrame.cond_ability_formDD:Hide()
    end
    if condFrame.cond_ability_weaponDD then
      condFrame.cond_ability_weaponDD:Hide()
    end
    if condFrame.cond_ability_target_alive then
      condFrame.cond_ability_target_alive:Hide()
    end
    if condFrame.cond_ability_target_dead then
      condFrame.cond_ability_target_dead:Hide()
    end

    -- 隐藏光环控件
    condFrame.cond_aura_found:Hide()
    condFrame.cond_aura_missing:Hide()
    condFrame.cond_aura_incombat:Hide()
    condFrame.cond_aura_outcombat:Hide()
    if condFrame.cond_aura_groupingDD then
      condFrame.cond_aura_groupingDD:Hide()
    end
    condFrame.cond_aura_target_help:Hide()
    condFrame.cond_aura_target_harm:Hide()
    condFrame.cond_aura_onself:Hide()
    if condFrame.cond_aura_target_alive then
      condFrame.cond_aura_target_alive:Hide()
    end
    if condFrame.cond_aura_target_dead then
      condFrame.cond_aura_target_dead:Hide()
    end
    condFrame.cond_aura_glow:Hide()
    condFrame.cond_aura_greyscale:Hide()
    condFrame.cond_aura_fade:Hide()
    condFrame.cond_aura_fade_slider:Hide()
    condFrame.cond_aura_power:Hide()
    condFrame.cond_aura_power_comp:Hide()
    condFrame.cond_aura_power_val:Hide()
    condFrame.cond_aura_power_val_enter:Hide()
    condFrame.cond_aura_hp_my:Hide()
    condFrame.cond_aura_hp_tgt:Hide()
    condFrame.cond_aura_hp_comp:Hide()
    condFrame.cond_aura_hp_val:Hide()
    condFrame.cond_aura_hp_val_enter:Hide()
    condFrame.cond_aura_remaining_cb:Hide()
    condFrame.cond_aura_remaining_comp:Hide()
    condFrame.cond_aura_remaining_val:Hide()
    condFrame.cond_aura_remaining_val_enter:Hide()
    condFrame.cond_aura_stacks_cb:Hide()
    condFrame.cond_aura_stacks_comp:Hide()
    condFrame.cond_aura_stacks_val:Hide()
    condFrame.cond_aura_stacks_val_enter:Hide()
    condFrame.cond_aura_text_time:Hide()
    condFrame.cond_aura_text_stack:Hide()
    condFrame.cond_aura_cp_cb:Hide()
    condFrame.cond_aura_cp_comp:Hide()
    condFrame.cond_aura_cp_val:Hide()
    condFrame.cond_aura_cp_val_enter:Hide()
    if condFrame.cond_aura_weaponDD then
      condFrame.cond_aura_weaponDD:Hide()
    end

    -- 非光环编辑时隐藏光环目标距离/类型行
    if condFrame.cond_aura_distanceDD then
      condFrame.cond_aura_distanceDD:Hide()
    end
    if condFrame.cond_aura_unitTypeDD then
      condFrame.cond_aura_unitTypeDD:Hide()
    end

    -- 非技能编辑时隐藏技能目标距离/类型行
    if condFrame.cond_ability_distanceDD then
      condFrame.cond_ability_distanceDD:Hide()
    end
    if condFrame.cond_ability_unitTypeDD then
      condFrame.cond_ability_unitTypeDD:Hide()
    end

    condFrame.cond_aura_mine:Hide()
    condFrame.cond_aura_others:Hide()
    if condFrame.cond_aura_owner_tip then
      condFrame.cond_aura_owner_tip:Hide()
    end
    if condFrame.cond_aura_tip then
      condFrame.cond_aura_tip:Hide()
    end
    if condFrame.cond_aura_formDD then
      condFrame.cond_aura_formDD:Hide()
    end
    if condFrame.cond_aura_class_note then
      condFrame.cond_aura_class_note:Hide()
    end
    if condFrame.cond_aura_trackpet then
      condFrame.cond_aura_trackpet:Hide()
    end

  elseif data.type == "Custom" then
    -- 隐藏所有分隔线 – 编辑框填充整个条件区域。
    for _, list in pairs(condFrame._seps or {}) do
      for _, sep in pairs(list) do
        sep:Hide()
      end
    end

    if AuraCond_RefreshFromDB then
      AuraCond_RefreshFromDB(nil)
    end
    if VfxCond_RefreshFromDB then
      VfxCond_RefreshFromDB(nil)
    end

    -- 显示自定义函数编辑框（填充外部滚动区域）
    if condFrame.cond_custom_function_edit then
      condFrame.cond_custom_function_edit:Show()
      if condFrame._customFunctionLoadedKey ~= currentKey then
        local src = data.customFunctionSource
        if type(src) ~= "string" or src == "" then
          src = DEFAULT_CUSTOM_FUNCTION_SOURCE
        end
        condFrame.cond_custom_function_edit:SetText(src)
        condFrame._customFunctionLoadedKey = currentKey
      end
    end
    -- 保存按钮 + 状态（在滚动区域外，网格按钮旁边）
    if condFrame.cond_custom_function_save then
      condFrame.cond_custom_function_save:Show()
    end
    if condFrame.cond_custom_function_status then
      condFrame.cond_custom_function_status:Show()
    end

    -- 编辑自定义代码时隐藏所有标准技能/光环/物品控件
    local function _Hide(v)
      if v and v.Hide then
        v:Hide()
      end
    end

    _Hide(condFrame.cond_ability_usable)
    _Hide(condFrame.cond_ability_notcd)
    _Hide(condFrame.cond_ability_oncd)
    _Hide(condFrame.cond_ability_incombat)
    _Hide(condFrame.cond_ability_outcombat)
    _Hide(condFrame.cond_ability_groupingDD)
    _Hide(condFrame.cond_ability_target_help)
    _Hide(condFrame.cond_ability_target_harm)
    _Hide(condFrame.cond_ability_target_self)
    _Hide(condFrame.cond_ability_target_alive)
    _Hide(condFrame.cond_ability_target_dead)
    _Hide(condFrame.cond_ability_glow)
    _Hide(condFrame.cond_ability_greyscale)
    _Hide(condFrame.cond_ability_fade)
    _Hide(condFrame.cond_ability_fade_slider)
    _Hide(condFrame.cond_ability_slider)
    _Hide(condFrame.cond_ability_slider_dir)
    _Hide(condFrame.cond_ability_slider_glow)
    _Hide(condFrame.cond_ability_slider_grey)
    _Hide(condFrame.cond_ability_remaining_cb)
    _Hide(condFrame.cond_ability_remaining_comp)
    _Hide(condFrame.cond_ability_remaining_val)
    _Hide(condFrame.cond_ability_remaining_val_enter)
    _Hide(condFrame.cond_ability_text_time)
    _Hide(condFrame.cond_ability_power)
    _Hide(condFrame.cond_ability_power_comp)
    _Hide(condFrame.cond_ability_power_val)
    _Hide(condFrame.cond_ability_power_val_enter)
    _Hide(condFrame.cond_ability_hp_my)
    _Hide(condFrame.cond_ability_hp_tgt)
    _Hide(condFrame.cond_ability_hp_comp)
    _Hide(condFrame.cond_ability_hp_val)
    _Hide(condFrame.cond_ability_hp_val_enter)
    _Hide(condFrame.cond_ability_cp_cb)
    _Hide(condFrame.cond_ability_cp_comp)
    _Hide(condFrame.cond_ability_cp_val)
    _Hide(condFrame.cond_ability_cp_val_enter)
    _Hide(condFrame.cond_ability_class_note)
    _Hide(condFrame.cond_ability_formDD)
    _Hide(condFrame.cond_ability_weaponDD)
    _Hide(condFrame.cond_ability_distanceDD)
    _Hide(condFrame.cond_ability_unitTypeDD)

    _Hide(condFrame.cond_aura_found)
    _Hide(condFrame.cond_aura_missing)
    _Hide(condFrame.cond_aura_tip)
    _Hide(condFrame.cond_aura_incombat)
    _Hide(condFrame.cond_aura_outcombat)
    _Hide(condFrame.cond_aura_groupingDD)
    _Hide(condFrame.cond_aura_target_help)
    _Hide(condFrame.cond_aura_target_harm)
    _Hide(condFrame.cond_aura_onself)
    _Hide(condFrame.cond_aura_target_alive)
    _Hide(condFrame.cond_aura_target_dead)
    _Hide(condFrame.cond_aura_glow)
    _Hide(condFrame.cond_aura_greyscale)
    _Hide(condFrame.cond_aura_fade)
    _Hide(condFrame.cond_aura_fade_slider)
    _Hide(condFrame.cond_aura_distanceDD)
    _Hide(condFrame.cond_aura_unitTypeDD)
    _Hide(condFrame.cond_aura_power)
    _Hide(condFrame.cond_aura_power_comp)
    _Hide(condFrame.cond_aura_power_val)
    _Hide(condFrame.cond_aura_power_val_enter)
    _Hide(condFrame.cond_aura_hp_my)
    _Hide(condFrame.cond_aura_hp_tgt)
    _Hide(condFrame.cond_aura_hp_comp)
    _Hide(condFrame.cond_aura_hp_val)
    _Hide(condFrame.cond_aura_hp_val_enter)
    _Hide(condFrame.cond_aura_mine)
    _Hide(condFrame.cond_aura_others)
    _Hide(condFrame.cond_aura_trackpet)
    _Hide(condFrame.cond_aura_owner_tip)
    _Hide(condFrame.cond_aura_remaining_cb)
    _Hide(condFrame.cond_aura_remaining_comp)
    _Hide(condFrame.cond_aura_remaining_val)
    _Hide(condFrame.cond_aura_remaining_val_enter)
    _Hide(condFrame.cond_aura_stacks_cb)
    _Hide(condFrame.cond_aura_stacks_comp)
    _Hide(condFrame.cond_aura_stacks_val)
    _Hide(condFrame.cond_aura_stacks_val_enter)
    _Hide(condFrame.cond_aura_text_time)
    _Hide(condFrame.cond_aura_text_stack)
    _Hide(condFrame.cond_aura_text_time_override)
    _Hide(condFrame.cond_aura_text_stack_override)
    _Hide(condFrame.cond_aura_text_override_note)
    _Hide(condFrame.cond_aura_cp_cb)
    _Hide(condFrame.cond_aura_cp_comp)
    _Hide(condFrame.cond_aura_cp_val)
    _Hide(condFrame.cond_aura_cp_val_enter)
    _Hide(condFrame.cond_aura_weaponDD)
    _Hide(condFrame.cond_aura_formDD)
    _Hide(condFrame.cond_aura_class_note)

    _Hide(condFrame.cond_item_where_equipped)
    _Hide(condFrame.cond_item_where_bag)
    _Hide(condFrame.cond_item_where_missing)
    _Hide(condFrame.cond_item_inv_trinket1)
    _Hide(condFrame.cond_item_inv_trinket2)
    _Hide(condFrame.cond_item_inv_trinket_first)
    _Hide(condFrame.cond_item_inv_trinket_both)
    _Hide(condFrame.cond_item_inv_wep_mainhand)
    _Hide(condFrame.cond_item_inv_wep_offhand)
    _Hide(condFrame.cond_item_inv_wep_ranged)
    _Hide(condFrame.cond_item_inv_wep_ammo)
    _Hide(condFrame.cond_item_incombat)
    _Hide(condFrame.cond_item_outcombat)
    _Hide(condFrame.cond_item_groupingDD)
    _Hide(condFrame.cond_item_notcd)
    _Hide(condFrame.cond_item_oncd)
    _Hide(condFrame.cond_item_target_help)
    _Hide(condFrame.cond_item_target_harm)
    _Hide(condFrame.cond_item_target_self)
    _Hide(condFrame.cond_item_target_alive)
    _Hide(condFrame.cond_item_target_dead)
    _Hide(condFrame.cond_item_glow)
    _Hide(condFrame.cond_item_greyscale)
    _Hide(condFrame.cond_item_fade)
    _Hide(condFrame.cond_item_fade_slider)
    _Hide(condFrame.cond_item_text_time)
    _Hide(condFrame.cond_item_text_time_override)
    _Hide(condFrame.cond_item_text_override_note)
    _Hide(condFrame.cond_item_enchant)
    _Hide(condFrame.cond_item_text_enchant)
    _Hide(condFrame.cond_item_stacks_cb)
    _Hide(condFrame.cond_item_stacks_comp)
    _Hide(condFrame.cond_item_stacks_val)
    _Hide(condFrame.cond_item_stacks_val_enter)
    _Hide(condFrame.cond_item_text_stack)
    _Hide(condFrame.cond_item_power)
    _Hide(condFrame.cond_item_power_comp)
    _Hide(condFrame.cond_item_power_val)
    _Hide(condFrame.cond_item_power_val_enter)
    _Hide(condFrame.cond_item_hp_my)
    _Hide(condFrame.cond_item_hp_tgt)
    _Hide(condFrame.cond_item_hp_comp)
    _Hide(condFrame.cond_item_hp_val)
    _Hide(condFrame.cond_item_hp_val_enter)
    _Hide(condFrame.cond_item_remaining_cb)
    _Hide(condFrame.cond_item_remaining_comp)
    _Hide(condFrame.cond_item_remaining_val)
    _Hide(condFrame.cond_item_remaining_val_enter)
    _Hide(condFrame.cond_item_cp_cb)
    _Hide(condFrame.cond_item_cp_comp)
    _Hide(condFrame.cond_item_cp_val)
    _Hide(condFrame.cond_item_cp_val_enter)
    _Hide(condFrame.cond_item_weaponDD)
    _Hide(condFrame.cond_item_class_note)
    _Hide(condFrame.cond_item_formDD)
    _Hide(condFrame.cond_item_distanceDD)
    _Hide(condFrame.cond_item_unitTypeDD)
    _Hide(condFrame.cond_item_clickable)

    -- 光环（增益/减益）
  else
    if ShowSeparatorsForType then ShowSeparatorsForType("aura") end

    if AuraCond_RefreshFromDB then
      AuraCond_RefreshFromDB("aura")
    end
    if VfxCond_RefreshFromDB then
      VfxCond_RefreshFromDB("aura")
    end

    -- 仅在此分支使用的小辅助函数
    local function _enableDD(dd)
      if not dd then
        return
      end
      local btn = _G[dd:GetName() .. "Button"]
      local txt = _G[dd:GetName() .. "Text"]
      if btn and btn.Enable then
        btn:Enable()
      end
      if txt and txt.SetTextColor then
        txt:SetTextColor(1, 0.82, 0)
      end
    end
    local function _hideRemInputs()
      condFrame.cond_aura_remaining_comp:Hide()
      condFrame.cond_aura_remaining_val:Hide()
      condFrame.cond_aura_remaining_val_enter:Hide()
    end

    condFrame.cond_aura_found:Show()
    condFrame.cond_aura_missing:Show()
    if condFrame.cond_aura_tip then
      condFrame.cond_aura_tip:Show()
    end
    if condFrame.cond_aura_owner_tip then
      condFrame.cond_aura_owner_tip:Show()
    end
    condFrame.cond_aura_incombat:Show()
    condFrame.cond_aura_outcombat:Show()
    condFrame.cond_aura_target_help:Show()
    condFrame.cond_aura_target_harm:Show()
    condFrame.cond_aura_onself:Show()
    condFrame.cond_aura_sound_ongain_cb:Show()
    condFrame.cond_aura_sound_ongain_dd:Show()
    condFrame.cond_aura_sound_onfade_cb:Show()
    condFrame.cond_aura_sound_onfade_dd:Show()
    condFrame.cond_aura_glow:Show()
    condFrame.cond_aura_greyscale:Show()
    condFrame.cond_aura_fade:Show()

    -- 模式
    local amode = (c.aura and c.aura.mode) or "found"
    condFrame.cond_aura_found:SetChecked(amode == "found" or amode == "both")
    condFrame.cond_aura_missing:SetChecked(amode == "missing" or amode == "both")

    -- 战斗标志（独立）
    local aIn, aOut
    if c.aura and (c.aura.inCombat ~= nil or c.aura.outCombat ~= nil) then
      aIn = c.aura.inCombat and true or false
      aOut = c.aura.outCombat and true or false
    else
      local cm = c.aura and c.aura.combat or nil
      if cm == "in" then
        aIn, aOut = true, false
      elseif cm == "out" then
        aIn, aOut = false, true
      else
        aIn, aOut = true, true
      end
    end
    condFrame.cond_aura_incombat:SetChecked(aIn)
    condFrame.cond_aura_outcombat:SetChecked(aOut)

    if condFrame.cond_aura_groupingDD then
      condFrame.cond_aura_groupingDD:Show()
      local gm = _DeriveGroupingMode(c.aura)
      local txt
      if gm == "any" then
        txt = "任意"
      elseif gm == "nogroup" then
        txt = "不在队伍/团队中"
      elseif gm == "party" then
        txt = "在队伍中"
      elseif gm == "raid" then
        txt = "在团队中"
      elseif gm == "partyraid" then
        txt = "在队伍或团队中"
      else
        txt = "组队状态"
      end

      if gm == nil then
        if UIDropDownMenu_SetSelectedValue then pcall(UIDropDownMenu_SetSelectedValue, condFrame.cond_aura_groupingDD, "__default") end
      else
        if UIDropDownMenu_SetSelectedValue then pcall(UIDropDownMenu_SetSelectedValue, condFrame.cond_aura_groupingDD, gm) end
      end
      if UIDropDownMenu_SetText then pcall(UIDropDownMenu_SetText, txt, condFrame.cond_aura_groupingDD) end
      if _GoldifyDD then _GoldifyDD(condFrame.cond_aura_groupingDD) end
    end

    -- 目标读取
    local th = (c.aura and c.aura.targetHelp) and true or false
    local tm = (c.aura and c.aura.targetHarm) and true or false
    local ts = (c.aura and c.aura.targetSelf) and true or false

    -- 目标状态
    local taa = (c.aura and c.aura.targetAlive) == true
    local tad = (c.aura and c.aura.targetDead) == true
    condFrame.cond_aura_target_alive:SetChecked(taa)
    condFrame.cond_aura_target_dead:SetChecked(tad)
    if condFrame.cond_aura_target_alive then
      condFrame.cond_aura_target_alive:Show()
    end
    if condFrame.cond_aura_target_dead then
      condFrame.cond_aura_target_dead:Show()
    end

    -- 规范化：自身与友善/敌对阵互斥
    if ts then
      th, tm = false, false
    end

    -- 如果所有都为假（旧状态），默认仅自身
    if (not th) and (not tm) and (not ts) then
      ts = true
      if c.aura then
        c.aura.targetSelf = true
        c.aura.targetHelp = false
        c.aura.targetHarm = false
      end
    end

    -- 派生目标状态
    local isSelfOnly = ts and (not th) and (not tm)
    local isHelpOrHarm = (th or tm) and (not ts)

    -- 反映目标
    condFrame.cond_aura_target_help:SetChecked(th)
    condFrame.cond_aura_target_harm:SetChecked(tm)
    condFrame.cond_aura_onself:SetChecked(ts)

    local isTrackPetActive = (_IsHunterOrWarlock and _IsHunterOrWarlock() and c.aura and c.aura.trackpet) and true or false
    if condFrame.cond_aura_onself and condFrame.cond_aura_onself.text and condFrame.cond_aura_onself.text.SetText then
      if isTrackPetActive then
        condFrame.cond_aura_onself.text:SetText("目标 (任意)")
      else
        condFrame.cond_aura_onself.text:SetText("玩家自己身上")
      end
    end

    -- === 目标距离与类型（光环） ===
    if condFrame.cond_aura_distanceDD then
      condFrame.cond_aura_distanceDD:Show()
      condFrame.cond_aura_unitTypeDD:Show()

      local a = c.aura or {}

      local function _RestoreAuraDD(dd, val, placeholder)
        if not dd then
          return
        end
        if val and val ~= "" then
          if UIDropDownMenu_SetSelectedValue then
            pcall(UIDropDownMenu_SetSelectedValue, dd, val)
          end
          if UIDropDownMenu_SetText then
            pcall(UIDropDownMenu_SetText, val, dd)
          end
          _GoldifyDD(dd)
        else
          if UIDropDownMenu_SetSelectedValue then
            pcall(UIDropDownMenu_SetSelectedValue, dd, nil)
          end
          if UIDropDownMenu_SetText then
            pcall(UIDropDownMenu_SetText, placeholder, dd)
          end
          _WhiteifyDDText(dd)
        end
      end

      -- 对于光环，始终清除并硬禁用距离
      if a then
        a.targetDistance = nil
      end
      _RestoreAuraDD(condFrame.cond_aura_distanceDD, nil, "距离")
      _SetDDEnabled(condFrame.cond_aura_distanceDD, false, "距离")

      -- UnitType仍然可用
      _RestoreAuraDD(condFrame.cond_aura_unitTypeDD, a.targetUnitType, "单位类型")

      -- 仅自身目标：UnitType无意义
      local isSelfOnly = (a.targetSelf == true)
      if isSelfOnly then
        a.targetUnitType = nil

        _SetDDEnabled(condFrame.cond_aura_unitTypeDD, false, "单位类型")
      else
        _SetDDEnabled(condFrame.cond_aura_unitTypeDD, true, "单位类型")
      end
    end

    condFrame.cond_aura_glow:SetChecked((c.aura and c.aura.glow) or false)
    condFrame.cond_aura_greyscale:SetChecked((c.aura and c.aura.greyscale) or false)
    condFrame.cond_aura_fade:SetChecked((c.aura and c.aura.fade) or false)
    if (c.aura and c.aura.fade) then
      local fadeAlpha = tonumber(c.aura.fadeAlpha) or 0
      if fadeAlpha < 0 then fadeAlpha = 0 end
      if fadeAlpha > 1 then fadeAlpha = 1 end
      condFrame.cond_aura_fade_slider:SetText(tostring(math.floor((fadeAlpha * 100) + 0.5)))
      condFrame.cond_aura_fade_slider:Show()
    else
      condFrame.cond_aura_fade_slider:Hide()
    end

    local auraSoundGainOn = (c.aura and c.aura.soundOnGainEnabled) == true
    local auraSoundFadeOn = (c.aura and c.aura.soundOnFadeEnabled) == true
    local auraSoundGain = (c.aura and c.aura.soundOnGain) or nil
    local auraSoundFade = (c.aura and c.aura.soundOnFade) or nil
    condFrame.cond_aura_sound_ongain_cb:SetChecked(auraSoundGainOn)
    condFrame.cond_aura_sound_onfade_cb:SetChecked(auraSoundFadeOn)
    DoiteEdit_InitSoundDropdown(condFrame.cond_aura_sound_ongain_dd, "aura", "soundOnGain", auraSoundGain)
    DoiteEdit_InitSoundDropdown(condFrame.cond_aura_sound_onfade_dd, "aura", "soundOnFade", auraSoundFade)
    DoiteEdit_EnableCheck(condFrame.cond_aura_sound_ongain_cb)
    DoiteEdit_EnableCheck(condFrame.cond_aura_sound_onfade_cb)
    DoiteEdit_SetDropdownInteractive(condFrame.cond_aura_sound_ongain_dd, auraSoundGainOn)
    DoiteEdit_SetDropdownInteractive(condFrame.cond_aura_sound_onfade_dd, auraSoundFadeOn)

    local isBuff = (data.type == "Buff")

    -- 连击点数 / 职业提示 / 武器过滤器
    local isRogueOrDruid = _IsRogueOrDruid and _IsRogueOrDruid() or false
    local isWPS = _IsWarriorPaladinShaman()

    if condFrame.cond_aura_weaponDD then
      condFrame.cond_aura_weaponDD:Hide()
    end

    if isRogueOrDruid then
      condFrame.cond_aura_cp_cb:Show()
      if condFrame.cond_aura_class_note then
        condFrame.cond_aura_class_note:Hide()
      end

      local cpOn = (c.aura and c.aura.cpEnabled) and true or false
      condFrame.cond_aura_cp_cb:SetChecked(cpOn)
      if cpOn then
        condFrame.cond_aura_cp_comp:Show()
        condFrame.cond_aura_cp_val:Show()
        condFrame.cond_aura_cp_val_enter:Show()
        local comp = (c.aura and c.aura.cpComp) or ""
        UIDropDownMenu_SetSelectedValue(condFrame.cond_aura_cp_comp, comp)
        UIDropDownMenu_SetText(comp, condFrame.cond_aura_cp_comp)
        _GoldifyDD(condFrame.cond_aura_cp_comp)
        condFrame.cond_aura_cp_val:SetText(tostring((c.aura and c.aura.cpVal) or 0))
      else
        condFrame.cond_aura_cp_comp:Hide()
        condFrame.cond_aura_cp_val:Hide()
        condFrame.cond_aura_cp_val_enter:Hide()
      end

    elseif isWPS and condFrame.cond_aura_weaponDD then
      -- 战士/圣骑士/萨满：使用武器/战斗风格下拉框代替连击点数
      condFrame.cond_aura_cp_cb:Hide()
      condFrame.cond_aura_cp_comp:Hide()
      condFrame.cond_aura_cp_val:Hide()
      condFrame.cond_aura_cp_val_enter:Hide()
      if condFrame.cond_aura_class_note then
        condFrame.cond_aura_class_note:Hide()
      end

      condFrame.cond_aura_weaponDD:Show()
      InitWeaponDropdown(condFrame.cond_aura_weaponDD, data, "aura")

    else
      condFrame.cond_aura_cp_cb:Hide()
      condFrame.cond_aura_cp_comp:Hide()
      condFrame.cond_aura_cp_val:Hide()
      condFrame.cond_aura_cp_val_enter:Hide()
      if condFrame.cond_aura_class_note then
        if _IsHunterOrWarlock and _IsHunterOrWarlock() then
          condFrame.cond_aura_class_note:Hide()
        else
          condFrame.cond_aura_class_note:SetText("未为你的职业添加专属选项。")
          condFrame.cond_aura_class_note:Show()
        end
      end
    end

    if condFrame.cond_aura_trackpet then
      local isHW = _IsHunterOrWarlock and _IsHunterOrWarlock() or false
      if isHW then
        condFrame.cond_aura_trackpet:Show()
        condFrame.cond_aura_trackpet:SetChecked((c.aura and c.aura.trackpet) and true or false)
      else
        condFrame.cond_aura_trackpet:Hide()
        condFrame.cond_aura_trackpet:SetChecked(false)
      end
    end

    -- 第8行：生命值选择器（互斥）
    condFrame.cond_aura_hp_my:Show()
    condFrame.cond_aura_hp_tgt:Show()
    local hpModeA = c.aura and c.aura.hpMode or nil
    condFrame.cond_aura_hp_my:SetChecked(hpModeA == "my")
    condFrame.cond_aura_hp_tgt:SetChecked(hpModeA == "target")
    if hpModeA == "my" or hpModeA == "target" then
      condFrame.cond_aura_hp_comp:Show()
      condFrame.cond_aura_hp_val:Show()
      condFrame.cond_aura_hp_val_enter:Show()
      local comp = (c.aura and c.aura.hpComp) or ""
      UIDropDownMenu_SetSelectedValue(condFrame.cond_aura_hp_comp, comp)
      UIDropDownMenu_SetText(comp, condFrame.cond_aura_hp_comp)
      _GoldifyDD(condFrame.cond_aura_hp_comp)
      condFrame.cond_aura_hp_val:SetText(tostring((c.aura and c.aura.hpVal) or 0))
    else
      condFrame.cond_aura_hp_comp:Hide()
      condFrame.cond_aura_hp_val:Hide()
      condFrame.cond_aura_hp_val_enter:Hide()
    end

    -- 光环拥有者标志（“我的光环” / “他人的光环”）– 增益和减益相同。
    local function _AO_SetEnabled(cb, enabled, clearWhenDisabling)
      if not cb then
        return
      end
      if type(_SetAuraCheckEnabled) == "function" then
        _SetAuraCheckEnabled(cb, enabled, clearWhenDisabling)
        return
      end

      if enabled then
        if cb.Enable then
          cb:Enable()
        end
        if cb.text and cb.text.SetTextColor then
          cb.text:SetTextColor(1, 0.82, 0)
        end
      else
        if clearWhenDisabling and cb.SetChecked then
          cb:SetChecked(false)
        end
        if cb.Disable then
          cb:Disable()
        end
        if cb.text and cb.text.SetTextColor then
          cb.text:SetTextColor(0.6, 0.6, 0.6)
        end
      end
    end

    local onlyMine = (c.aura and c.aura.onlyMine) and true or false
    local onlyOthers = (c.aura and c.aura.onlyOthers) and true or false

    -- 清理数据库：如果两者都为真，仅保留“我的光环”。
    if onlyMine and onlyOthers then
      onlyOthers = false
      if c.aura then
        c.aura.onlyOthers = nil
      end
    end

    -- If target is "On player (self)", ownership is meaningless.
    local lockOwnerOnSelf = false
    if isTrackPetActive then
      lockOwnerOnSelf = true
    elseif isSelfOnly then
      lockOwnerOnSelf = true
    end

    if amode == "found" or amode == "both" then
      if lockOwnerOnSelf then
        -- Grey out / unselectable / uncheck "My Aura" + "Others Aura"
        if condFrame.cond_aura_mine then
          condFrame.cond_aura_mine:Show()
          condFrame.cond_aura_mine:SetChecked(false)
          _AO_SetEnabled(condFrame.cond_aura_mine, false, true)
        end
        if condFrame.cond_aura_others then
          condFrame.cond_aura_others:Show()
          condFrame.cond_aura_others:SetChecked(false)
          _AO_SetEnabled(condFrame.cond_aura_others, false, true)
        end
        if c.aura then
          c.aura.onlyMine = nil
          c.aura.onlyOthers = nil
        end
      else
        -- Owner row visible for FOUND. Always enabled.
        if condFrame.cond_aura_mine then
          condFrame.cond_aura_mine:Show()
          condFrame.cond_aura_mine:SetChecked(onlyMine)
          _AO_SetEnabled(condFrame.cond_aura_mine, true, true)
        end

        if condFrame.cond_aura_others then
          condFrame.cond_aura_others:Show()
          condFrame.cond_aura_others:SetChecked(onlyOthers)
          _AO_SetEnabled(condFrame.cond_aura_others, true, true)
        end
      end

    elseif amode == "missing" then
      -- 缺失：保持行可见但禁用并清除标志（总是）。
      if condFrame.cond_aura_mine then
        condFrame.cond_aura_mine:Show()
        condFrame.cond_aura_mine:SetChecked(false)
        _AO_SetEnabled(condFrame.cond_aura_mine, false, true)
      end

      if condFrame.cond_aura_others then
        condFrame.cond_aura_others:Show()
        condFrame.cond_aura_others:SetChecked(false)
        _AO_SetEnabled(condFrame.cond_aura_others, false, true)
      end

      if c.aura then
        c.aura.onlyMine = nil
        c.aura.onlyOthers = nil
      end

    else
      -- 未选择光环模式 → 隐藏拥有者控件。
      if condFrame.cond_aura_mine then
        condFrame.cond_aura_mine:Hide()
      end
      if condFrame.cond_aura_others then
        condFrame.cond_aura_others:Hide()
      end
    end

    -- 从数据库设置拥有者标志后，更新剩余/文本灰色状态。
    if AuraOwner_UpdateDependentChecks then
      AuraOwner_UpdateDependentChecks()
    end

    -- 第10行：文本标志（文本：层数 + 文本：剩余）
    if amode == "found" or amode == "both" then
      -- === 文本：层数计数器 ===
      condFrame.cond_aura_text_stack:Show()
      DoiteEdit_EnableCheck(condFrame.cond_aura_text_stack)
      condFrame.cond_aura_text_stack:SetChecked((c.aura and c.aura.textStackCounter) or false)

      -- === 文本：剩余时间 ===
      condFrame.cond_aura_text_time:Show()

      if isTrackPetActive or isSelfOnly then
        -- 宠物跟踪（或玩家自身）：用户可以自由切换文本：剩余
        DoiteEdit_EnableCheck(condFrame.cond_aura_text_time)
        condFrame.cond_aura_text_time:SetChecked((c.aura and c.aura.textTimeRemaining) or false)

      elseif isHelpOrHarm then
        if onlyMine then
          -- 我的光环已选中 -> 用户控制文本：剩余
          DoiteEdit_EnableCheck(condFrame.cond_aura_text_time)
          condFrame.cond_aura_text_time:SetChecked((c.aura and c.aura.textTimeRemaining) or false)
        else
          -- 我的光环未选中 -> 文本：剩余强制关闭并灰显
          if c.aura and c.aura.textTimeRemaining then
            c.aura.textTimeRemaining = false
          end
          condFrame.cond_aura_text_time:SetChecked(false)
          DoiteEdit_DisableCheck(condFrame.cond_aura_text_time)
        end
      else
        -- 后备：禁用
        DoiteEdit_DisableCheck(condFrame.cond_aura_text_time)
        condFrame.cond_aura_text_time:SetChecked(false)
        if c.aura and c.aura.textTimeRemaining then
          c.aura.textTimeRemaining = false
        end
      end

    elseif amode == "missing" then
      -- 光环缺失：保持文本选项可见但禁用并清除
      condFrame.cond_aura_text_stack:Show()
      condFrame.cond_aura_text_time:Show()

      DoiteEdit_DisableCheck(condFrame.cond_aura_text_stack)
      DoiteEdit_DisableCheck(condFrame.cond_aura_text_time)

      condFrame.cond_aura_text_stack:SetChecked(false)
      condFrame.cond_aura_text_time:SetChecked(false)

      if c.aura then
        c.aura.textStackCounter = false
        c.aura.textTimeRemaining = false
      end
    else
      condFrame.cond_aura_text_time:Hide()
      condFrame.cond_aura_text_stack:Hide()
    end

    if condFrame.cond_item_text_time_override then
      condFrame.cond_item_text_time_override:Hide()
    end
    if condFrame.cond_item_text_override_note then
      condFrame.cond_item_text_override_note:Hide()
    end

    do
      local showRemOv = (condFrame.cond_aura_text_time and condFrame.cond_aura_text_time:IsShown() and condFrame.cond_aura_text_time:GetChecked()) and true or false
      local showStackOv = (condFrame.cond_aura_text_stack and condFrame.cond_aura_text_stack:IsShown() and condFrame.cond_aura_text_stack:GetChecked()) and true or false
      local showAnyOv = showRemOv or showStackOv

      if condFrame.cond_aura_text_time_override then
        if showRemOv then
          condFrame.cond_aura_text_time_override:Show()
          condFrame.cond_aura_text_time_override:SetText((c.aura and c.aura.remOverride) or "")
        else
          condFrame.cond_aura_text_time_override:Hide()
        end
      end

      if condFrame.cond_aura_text_stack_override then
        if showStackOv then
          condFrame.cond_aura_text_stack_override:Show()
          condFrame.cond_aura_text_stack_override:SetText((c.aura and c.aura.stackOverride) or "")
        else
          condFrame.cond_aura_text_stack_override:Hide()
        end
      end

      if condFrame.cond_aura_text_override_note then
        if showAnyOv then
          condFrame.cond_aura_text_override_note:Show()
        else
          condFrame.cond_aura_text_override_note:Hide()
        end
      end
    end

    -- 第11行：光环资源（如技能）
    condFrame.cond_aura_power:Show()
    local pOn = (c.aura and c.aura.powerEnabled) and true or false
    condFrame.cond_aura_power:SetChecked(pOn)
    if pOn then
      condFrame.cond_aura_power_comp:Show()
      condFrame.cond_aura_power_val:Show()
      condFrame.cond_aura_power_val_enter:Show()
      local comp = (c.aura and c.aura.powerComp) or ""
      UIDropDownMenu_SetSelectedValue(condFrame.cond_aura_power_comp, comp)
      UIDropDownMenu_SetText(comp, condFrame.cond_aura_power_comp)
      _GoldifyDD(condFrame.cond_aura_power_comp)
      condFrame.cond_aura_power_val:SetText(tostring((c.aura and c.aura.powerVal) or 0))
    else
      condFrame.cond_aura_power_comp:Hide()
      condFrame.cond_aura_power_val:Hide()
      condFrame.cond_aura_power_val_enter:Hide()
    end

    -- 光环形态下拉框
    local choices = (function()
      local _, cls = UnitClass("player")
      cls = cls and string.upper(cls) or ""
      return (cls == "WARRIOR" or cls == "ROGUE" or cls == "DRUID" or cls == "PRIEST" or cls == "PALADIN")
    end)()

    if condFrame.cond_ability_formDD then
      condFrame.cond_ability_formDD:Hide()
    end

    if choices and condFrame.cond_aura_formDD then
      condFrame.cond_aura_formDD:Show()
      ClearDropdown(condFrame.cond_aura_formDD)
      InitFormDropdown(condFrame.cond_aura_formDD, data, "aura")
      local v = c.aura and c.aura.form
      if v and v ~= "所有形态" and v ~= "" then
        UIDropDownMenu_SetSelectedValue(condFrame.cond_aura_formDD, v)
        UIDropDownMenu_SetText(v, condFrame.cond_aura_formDD)
        _GoldifyDD(condFrame.cond_aura_formDD)
      else
        UIDropDownMenu_SetText("选择形态", condFrame.cond_aura_formDD)
        _GoldifyDD(condFrame.cond_aura_formDD)
      end
    elseif condFrame.cond_aura_formDD then
      condFrame.cond_aura_formDD:Hide()
      ClearDropdown(condFrame.cond_aura_formDD)
    end

    -- 剩余（第8行）：行为取决于目标 + “我的光环”
    local aRemEnabled = (c.aura and c.aura.remainingEnabled) and true or false

    if amode == "found" or amode == "both" then
      condFrame.cond_aura_remaining_cb:Show()
      if condFrame.cond_aura_remaining_cb.text then
        condFrame.cond_aura_remaining_cb.text:SetText("剩余")
      end

      if isTrackPetActive or isSelfOnly then
        -- 宠物跟踪（或玩家自身）：用户可以自由切换剩余
        DoiteEdit_EnableCheck(condFrame.cond_aura_remaining_cb)
        condFrame.cond_aura_remaining_cb:SetChecked(aRemEnabled)

      elseif isHelpOrHarm then
        -- 友善/敌对目标：应用我的光环规则
        if onlyMine then
          -- 我的光环已选中 -> 用户控制剩余
          DoiteEdit_EnableCheck(condFrame.cond_aura_remaining_cb)
          condFrame.cond_aura_remaining_cb:SetChecked(aRemEnabled)
        else
          -- 我的光环未选中 -> 剩余禁用并清除
          if c.aura and c.aura.remainingEnabled then
            c.aura.remainingEnabled = false
          end
          aRemEnabled = false
          condFrame.cond_aura_remaining_cb:SetChecked(false)
          DoiteEdit_DisableCheck(condFrame.cond_aura_remaining_cb)
        end
      else
        -- 后备：禁用
        DoiteEdit_DisableCheck(condFrame.cond_aura_remaining_cb)
        condFrame.cond_aura_remaining_cb:SetChecked(false)
        if c.aura then
          c.aura.remainingEnabled = false
        end
      end

      -- 输入框跟随最终的启用标志
      local remOn = (c.aura and c.aura.remainingEnabled) and true or false
      if remOn then
        condFrame.cond_aura_remaining_comp:Show()
        condFrame.cond_aura_remaining_val:Show()
        condFrame.cond_aura_remaining_val_enter:Show()
        _enableDD(condFrame.cond_aura_remaining_comp)

        local comp = (c.aura and c.aura.remainingComp) or ""
        UIDropDownMenu_SetSelectedValue(condFrame.cond_aura_remaining_comp, comp)
        UIDropDownMenu_SetText(comp, condFrame.cond_aura_remaining_comp)
        _GoldifyDD(condFrame.cond_aura_remaining_comp)
        condFrame.cond_aura_remaining_val:SetText(tostring((c.aura and c.aura.remainingVal) or 0))
      else
        _hideRemInputs()
      end

    elseif amode == "missing" then
      -- 光环缺失：保持剩余可见但禁用并清除
      condFrame.cond_aura_remaining_cb:Show()
      if condFrame.cond_aura_remaining_cb.text then
        condFrame.cond_aura_remaining_cb.text:SetText("剩余")
      end

      DoiteEdit_DisableCheck(condFrame.cond_aura_remaining_cb)
      condFrame.cond_aura_remaining_cb:SetChecked(false)
      if c.aura then
        c.aura.remainingEnabled = false
      end
      _hideRemInputs()
    else
      condFrame.cond_aura_remaining_cb:Hide()
      _hideRemInputs()
    end

    -- 层数行：仅在FOUND时启用，MISSING时灰显
    local aStacksEnabled = (c.aura and c.aura.stacksEnabled) and true or false
    condFrame.cond_aura_stacks_cb:SetChecked(aStacksEnabled)
    if amode == "found" or amode == "both" then
      condFrame.cond_aura_stacks_cb:Show()
      DoiteEdit_EnableCheck(condFrame.cond_aura_stacks_cb)
      if aStacksEnabled then
        condFrame.cond_aura_stacks_comp:Show()
        condFrame.cond_aura_stacks_val:Show()
        condFrame.cond_aura_stacks_val_enter:Show()
        local comp = (c.aura and c.aura.stacksComp) or ""
        UIDropDownMenu_SetSelectedValue(condFrame.cond_aura_stacks_comp, comp)
        UIDropDownMenu_SetText(comp, condFrame.cond_aura_stacks_comp)
        _GoldifyDD(condFrame.cond_aura_stacks_comp)
        condFrame.cond_aura_stacks_val:SetText(tostring((c.aura and c.aura.stacksVal) or 0))
      else
        condFrame.cond_aura_stacks_comp:Hide()
        condFrame.cond_aura_stacks_val:Hide()
        condFrame.cond_aura_stacks_val_enter:Hide()
      end
    else
      -- 光环缺失或无模式：对于MISSING显示但禁用/清除，对于nil模式隐藏
      if amode == "missing" then
        condFrame.cond_aura_stacks_cb:Show()
        DoiteEdit_DisableCheck(condFrame.cond_aura_stacks_cb)
        condFrame.cond_aura_stacks_cb:SetChecked(false)
        if c.aura then
          c.aura.stacksEnabled = false
        end
      else
        condFrame.cond_aura_stacks_cb:Hide()
      end
      condFrame.cond_aura_stacks_comp:Hide()
      condFrame.cond_aura_stacks_val:Hide()
      condFrame.cond_aura_stacks_val_enter:Hide()
    end

    -- 隐藏所有技能和物品控件（不变）
    condFrame.cond_ability_usable:Hide()
    condFrame.cond_ability_notcd:Hide()
    condFrame.cond_ability_oncd:Hide()
    condFrame.cond_ability_incombat:Hide()
    condFrame.cond_ability_outcombat:Hide()
    if condFrame.cond_ability_groupingDD then
      condFrame.cond_ability_groupingDD:Hide()
    end
    condFrame.cond_ability_target_help:Hide()
    condFrame.cond_ability_target_harm:Hide()
    condFrame.cond_ability_target_self:Hide()
    condFrame.cond_ability_power:Hide()
    condFrame.cond_ability_power_comp:Hide()
    condFrame.cond_ability_power_val:Hide()
    condFrame.cond_ability_power_val_enter:Hide()
    condFrame.cond_ability_glow:Hide()
    condFrame.cond_ability_greyscale:Hide()
    condFrame.cond_ability_fade:Hide()
    condFrame.cond_ability_fade_slider:Hide()
    condFrame.cond_ability_slider:Hide()
    condFrame.cond_ability_slider_dir:Hide()
    condFrame.cond_ability_remaining_cb:Hide()
    condFrame.cond_ability_remaining_comp:Hide()
    condFrame.cond_ability_remaining_val:Hide()
    condFrame.cond_ability_remaining_val_enter:Hide()
    if condFrame.cond_ability_text_time then
      condFrame.cond_ability_text_time:Hide()
    end
    if condFrame.cond_ability_target_alive then
      condFrame.cond_ability_target_alive:Hide()
    end
    if condFrame.cond_ability_target_dead then
      condFrame.cond_ability_target_dead:Hide()
    end

    if condFrame.cond_ability_hp_my then
      condFrame.cond_ability_hp_my:Hide()
    end
    if condFrame.cond_ability_hp_tgt then
      condFrame.cond_ability_hp_tgt:Hide()
    end
    if condFrame.cond_ability_hp_comp then
      condFrame.cond_ability_hp_comp:Hide()
    end
    if condFrame.cond_ability_hp_val then
      condFrame.cond_ability_hp_val:Hide()
    end
    if condFrame.cond_ability_hp_val_enter then
      condFrame.cond_ability_hp_val_enter:Hide()
    end

    if condFrame.cond_ability_cp_cb then
      condFrame.cond_ability_cp_cb:Hide()
    end
    if condFrame.cond_ability_cp_comp then
      condFrame.cond_ability_cp_comp:Hide()
    end
    if condFrame.cond_ability_cp_val then
      condFrame.cond_ability_cp_val:Hide()
    end
    if condFrame.cond_ability_cp_val_enter then
      condFrame.cond_ability_cp_val_enter:Hide()
    end
    if condFrame.cond_ability_weaponDD then
      condFrame.cond_ability_weaponDD:Hide()
    end
    if condFrame.cond_ability_class_note then
      condFrame.cond_ability_class_note:Hide()
    end

    if condFrame.cond_ability_slider_glow then
      condFrame.cond_ability_slider_glow:Hide()
    end
    if condFrame.cond_ability_slider_grey then
      condFrame.cond_ability_slider_grey:Hide()
    end

    if condFrame.cond_item_where_equipped then
      condFrame.cond_item_where_equipped:Hide()
    end
    if condFrame.cond_item_where_bag then
      condFrame.cond_item_where_bag:Hide()
    end
    if condFrame.cond_item_where_missing then
      condFrame.cond_item_where_missing:Hide()
    end
    if condFrame.cond_item_notcd then
      condFrame.cond_item_notcd:Hide()
    end
    if condFrame.cond_item_oncd then
      condFrame.cond_item_oncd:Hide()
    end
    if condFrame.cond_item_incombat then
      condFrame.cond_item_incombat:Hide()
    end
    if condFrame.cond_item_outcombat then
      condFrame.cond_item_outcombat:Hide()
    end
    if condFrame.cond_item_groupingDD then
      condFrame.cond_item_groupingDD:Hide()
    end
    if condFrame.cond_item_target_help then
      condFrame.cond_item_target_help:Hide()
    end
    if condFrame.cond_item_target_harm then
      condFrame.cond_item_target_harm:Hide()
    end
    if condFrame.cond_item_target_self then
      condFrame.cond_item_target_self:Hide()
    end
    if condFrame.cond_item_glow then
      condFrame.cond_item_glow:Hide()
    end
    if condFrame.cond_item_greyscale then
      condFrame.cond_item_greyscale:Hide()
    end
    if condFrame.cond_item_fade then
      condFrame.cond_item_fade:Hide()
    end
    if condFrame.cond_item_fade_slider then
      condFrame.cond_item_fade_slider:Hide()
    end
    if condFrame.cond_item_text_time then
      condFrame.cond_item_text_time:Hide()
    end
    if condFrame.cond_item_enchant then
      condFrame.cond_item_enchant:Hide()
    end
    if condFrame.cond_item_text_enchant then
      condFrame.cond_item_text_enchant:Hide()
    end
    if condFrame.cond_item_power then
      condFrame.cond_item_power:Hide()
    end
    if condFrame.cond_item_power_comp then
      condFrame.cond_item_power_comp:Hide()
    end
    if condFrame.cond_item_power_val then
      condFrame.cond_item_power_val:Hide()
    end
    if condFrame.cond_item_power_val_enter then
      condFrame.cond_item_power_val_enter:Hide()
    end
    if condFrame.cond_item_hp_my then
      condFrame.cond_item_hp_my:Hide()
    end
    if condFrame.cond_item_hp_tgt then
      condFrame.cond_item_hp_tgt:Hide()
    end
    if condFrame.cond_item_hp_comp then
      condFrame.cond_item_hp_comp:Hide()
    end
    if condFrame.cond_item_hp_val then
      condFrame.cond_item_hp_val:Hide()
    end
    if condFrame.cond_item_hp_val_enter then
      condFrame.cond_item_hp_val_enter:Hide()
    end
    if condFrame.cond_item_remaining_cb then
      condFrame.cond_item_remaining_cb:Hide()
    end
    if condFrame.cond_item_remaining_comp then
      condFrame.cond_item_remaining_comp:Hide()
    end
    if condFrame.cond_item_remaining_val then
      condFrame.cond_item_remaining_val:Hide()
    end
    if condFrame.cond_item_remaining_val_enter then
      condFrame.cond_item_remaining_val_enter:Hide()
    end
    if condFrame.cond_item_cp_cb then
      condFrame.cond_item_cp_cb:Hide()
    end
    if condFrame.cond_item_cp_comp then
      condFrame.cond_item_cp_comp:Hide()
    end
    if condFrame.cond_item_cp_val then
      condFrame.cond_item_cp_val:Hide()
    end
    if condFrame.cond_item_cp_val_enter then
      condFrame.cond_item_cp_val_enter:Hide()
    end
    if condFrame.cond_item_formDD then
      condFrame.cond_item_formDD:Hide()
    end
    if condFrame.cond_item_inv_trinket1 then
      condFrame.cond_item_inv_trinket1:Hide()
    end
    if condFrame.cond_item_inv_trinket2 then
      condFrame.cond_item_inv_trinket2:Hide()
    end
    if condFrame.cond_item_inv_trinket_first then
      condFrame.cond_item_inv_trinket_first:Hide()
    end
    if condFrame.cond_item_inv_trinket_both then
      condFrame.cond_item_inv_trinket_both:Hide()
    end
    if condFrame.cond_item_inv_wep_mainhand then
      condFrame.cond_item_inv_wep_mainhand:Hide()
    end
    if condFrame.cond_item_inv_wep_offhand then
      condFrame.cond_item_inv_wep_offhand:Hide()
    end
    if condFrame.cond_item_inv_wep_ranged then
      condFrame.cond_item_inv_wep_ranged:Hide()
    end
    if condFrame.cond_item_inv_wep_ammo then
      condFrame.cond_item_inv_wep_ammo:Hide()
    end
    if condFrame.cond_item_class_note then
      condFrame.cond_item_class_note:Hide()
    end
    if condFrame.cond_item_target_alive then
      condFrame.cond_item_target_alive:Hide()
    end
    if condFrame.cond_item_target_dead then
      condFrame.cond_item_target_dead:Hide()
    end
    if condFrame.cond_item_weaponDD then
      condFrame.cond_item_weaponDD:Hide()
    end
    if condFrame.cond_item_clickable then
      condFrame.cond_item_clickable:Hide()
    end
    -- 非物品编辑时隐藏物品层数行
    if condFrame.cond_item_stacks_cb then
      condFrame.cond_item_stacks_cb:Hide()
    end
    if condFrame.cond_item_text_stack then
      condFrame.cond_item_text_stack:Hide()
    end
    if condFrame.cond_item_stacks_comp then
      condFrame.cond_item_stacks_comp:Hide()
    end
    if condFrame.cond_item_stacks_val then
      condFrame.cond_item_stacks_val:Hide()
    end
    if condFrame.cond_item_stacks_val_enter then
      condFrame.cond_item_stacks_val_enter:Hide()
    end

    -- 非技能编辑时隐藏技能目标距离/类型行
    if condFrame.cond_ability_distanceDD then
      condFrame.cond_ability_distanceDD:Hide()
    end
    if condFrame.cond_ability_unitTypeDD then
      condFrame.cond_ability_unitTypeDD:Hide()
    end

    -- 非物品编辑时隐藏物品目标距离/类型行
    if condFrame.cond_item_distanceDD then
      condFrame.cond_item_distanceDD:Hide()
    end
    if condFrame.cond_item_unitTypeDD then
      condFrame.cond_item_unitTypeDD:Hide()
    end
  end
  _ReflowCondAreaHeight()
end

----------------------------------------------------------------
-- 条件界面部分结束
----------------------------------------------------------------

-- 更新框架控件以反映键`key`的数据库状态
function UpdateCondFrameForKey(key)
  if not condFrame or not key then
    return
  end

  -- 切换图标时，强制关闭旧图标的AND/OR逻辑弹窗
  if DoiteAuraLogicFrame and DoiteAuraLogicFrame:IsShown() then
    DoiteAuraLogicFrame:Hide()
  end

  -- 禁用之前编辑的图标的鼠标（用于拖拽）
  local _GetIconFrame = DoiteAuras_GetIconFrame or function(k)
    return k and _G["DoiteIcon_" .. k]
  end
  if currentKey and currentKey ~= key then
    local oldFrame = _GetIconFrame(currentKey)
    if oldFrame then
      oldFrame:EnableMouse(false)
    end
  end

  currentKey = key
  _G["DoiteEdit_CurrentKey"] = key

  -- 启用新编辑的图标框架的鼠标（用于拖拽）
  local newFrame = _GetIconFrame(key)
  if newFrame then
    newFrame:EnableMouse(true)
  end

  local data = EnsureDBEntry(key)

  -- 每次编辑器打开此条目时，严格分离条件表
  if data and data.conditions then
    if data.type == "Ability" then
      data.conditions.ability = data.conditions.ability or {}
      data.conditions.aura = nil
      data.conditions.item = nil
    elseif data.type == "Item" then
      data.conditions.item = data.conditions.item or {}
      data.conditions.ability = nil
      data.conditions.aura = nil
    elseif data.type == "Custom" then
      data.conditions.ability = nil
      data.conditions.aura = nil
      data.conditions.item = nil
    else
      data.conditions.aura = data.conditions.aura or {}
      data.conditions.ability = nil
      data.conditions.item = nil
    end
  end

  -- 标题：按类型着色
  local typeColor = "|cffffffff"
  if data.type == "Ability" then
    typeColor = "|cff4da6ff"
  elseif data.type == "Buff" then
    typeColor = "|cff22ff22"
  elseif data.type == "Debuff" then
    typeColor = "|cffff4d4d"
  elseif data.type == "Item" then
    typeColor = "|cffffd000"
  elseif data.type == "Custom" then
    typeColor = "|cff7dd2ff"
  end
  condFrame.header:SetText("编辑: " .. (data.displayName or key) .. " " .. typeColor .. "(" .. (data.type or "") .. ")|r")

  if condFrame.DoiteGroupUIRefresh then
    condFrame:DoiteGroupUIRefresh(key)
  end

  -- 更新条件界面（始终在顶部和位置与尺寸之间可见）
  UpdateConditionsUI(data)

  -- 显示/隐藏位置和尺寸部分（仅当无组或为组长时）
  local showPosSize = (not data.group) or data.isLeader
  if condFrame.DoiteGroupUIIsLeaderOrFree then
    showPosSize = condFrame:DoiteGroupUIIsLeaderOrFree()
  end

  if showPosSize then
    if condFrame.groupTitle3 then
      condFrame.groupTitle3:Show()
    end
    if condFrame.sep3 then
      condFrame.sep3:Show()
    end
    if condFrame.sliderX then
      condFrame.sliderX:Show()
    end
    if condFrame.sliderY then
      condFrame.sliderY:Show()
    end
    if condFrame.sliderSize then
      condFrame.sliderSize:Show()
    end
    if condFrame.sliderXBox then
      condFrame.sliderXBox:Show()
    end
    if condFrame.sliderYBox then
      condFrame.sliderYBox:Show()
    end
    if condFrame.sliderSizeBox then
      condFrame.sliderSizeBox:Show()
    end

    -- 更新滑块位置/值（受保护）
    if condFrame.sliderX then
      condFrame.sliderX:SetValue(data.offsetX or 0)
    end
    if condFrame.sliderY then
      condFrame.sliderY:SetValue(data.offsetY or 0)
    end
    if condFrame.sliderSize then
      condFrame.sliderSize:SetValue(data.iconSize or 40)
    end
    _DA_ApplySliderRanges()

    -- 如果存在数字编辑框，更新它们
    if condFrame.sliderXBox then
      condFrame.sliderXBox:SetText(tostring(math.floor((data.offsetX or 0) + 0.5)))
    end
    if condFrame.sliderYBox then
      condFrame.sliderYBox:SetText(tostring(math.floor((data.offsetY or 0) + 0.5)))
    end
    if condFrame.sliderSizeBox then
      condFrame.sliderSizeBox:SetText(tostring(math.floor((data.iconSize or 40) + 0.5)))
    end
  else
    if condFrame.groupTitle3 then
      condFrame.groupTitle3:Hide()
    end
    if condFrame.sep3 then
      condFrame.sep3:Hide()
    end
    if condFrame.sliderX then
      condFrame.sliderX:Hide()
    end
    if condFrame.sliderY then
      condFrame.sliderY:Hide()
    end
    if condFrame.sliderSize then
      condFrame.sliderSize:Hide()
    end
    if condFrame.sliderXBox then
      condFrame.sliderXBox:Hide()
    end
    if condFrame.sliderYBox then
      condFrame.sliderYBox:Hide()
    end
    if condFrame.sliderSizeBox then
      condFrame.sliderSizeBox:Hide()
    end
  end
end

-- 显示/隐藏入口点
function DoiteConditions_Show(key)
  -- 切换：如果相同键且已显示 -> 隐藏
  if condFrame and condFrame:IsShown() and currentKey == key then
    -- 关闭编辑模式时禁用图标框架的鼠标
    local _GetIconFrame = DoiteAuras_GetIconFrame or function(k)
      return k and _G["DoiteIcon_" .. k]
    end
    local oldFrame = _GetIconFrame(currentKey)
    if oldFrame then
      oldFrame:EnableMouse(false)
    end

    condFrame:Hide()
    currentKey = nil
    _G["DoiteEdit_CurrentKey"] = nil   -- 清除编辑覆盖
    return
  end

  -- 如果需要，创建框架
  if not condFrame then
    condFrame = CreateFrame("Frame", "DoiteConditionsFrame", UIParent)
    condFrame:SetWidth(355)
    condFrame:SetHeight(470)
    if DoiteAurasFrame and DoiteAurasFrame:GetName() then
      condFrame:SetPoint("TOPLEFT", DoiteAurasFrame, "TOPRIGHT", 5, 0)
    else
      condFrame:SetPoint("CENTER", UIParent, "CENTER", 200, 0)
    end

    condFrame:SetBackdrop({
      bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
      edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
      tile = true, tileSize = 16, edgeSize = 32,
      insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    condFrame:SetBackdropColor(0, 0, 0, 1)
    condFrame:SetBackdropBorderColor(1, 1, 1, 1)
    condFrame:SetFrameStrata("FULLSCREEN_DIALOG")
    -- 当条件编辑器以任何方式隐藏时，丢弃编辑覆盖
    condFrame:SetScript("OnHide", function()
      -- 禁用正在编辑的图标的鼠标（修复退出后拖拽错误）
      local _GetIconFrame = DoiteAuras_GetIconFrame or function(k)
        return k and _G["DoiteIcon_" .. k]
      end
      if currentKey then
        local oldFrame = _GetIconFrame(currentKey)
        if oldFrame then
          oldFrame:EnableMouse(false)
        end
      end

      _G["DoiteEdit_CurrentKey"] = nil
      lastAnnouncedKey = nil

      -- 如果网格显示，自动隐藏
      if _G["DoiteGridOverlay"] and _G["DoiteGridOverlay"]:IsShown() then
        _G["DoiteGridOverlay"]:Hide()
      end

      -- 触发重绘，使之前强制显示的图标能够根据条件隐藏
      if DoiteConditions_RequestEvaluate then
        DoiteConditions_RequestEvaluate()
      end
      if DoiteAuras_RefreshIcons then
        DoiteAuras_RefreshIcons()
      end
    end)

    _G["DoiteEdit_Frame"] = condFrame

    -- === 拖拽主DoiteAuras框架时暂停重度工作；释放时刷新 ===
    if DoiteAurasFrame then
      local _oldDown = DoiteAurasFrame:GetScript("OnMouseDown")
      DoiteAurasFrame:SetScript("OnMouseDown", function(self)
        _G["DoiteUI_Dragging"] = true
        if _oldDown then
          _oldDown(self)
        end
      end)

      local _oldUp = DoiteAurasFrame:GetScript("OnMouseUp")
      DoiteAurasFrame:SetScript("OnMouseUp", function(self)
        _G["DoiteUI_Dragging"] = false
        -- 拖拽释放后确保一次最终重绘
        DoiteEdit_FlushHeavy()
        if _oldUp then
          _oldUp(self)
        end
      end)
    end

    condFrame.header = condFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    condFrame.header:SetPoint("TOP", condFrame, "TOP", 0, -15)
    condFrame.header:SetText("编辑:")

    condFrame.groupTitle = condFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    condFrame.groupTitle:SetPoint("TOPLEFT", condFrame, "TOPLEFT", 20, -40)
    condFrame.groupTitle:SetText("|cff6FA8DC组和组长|r")

    local sep = condFrame:CreateTexture(nil, "ARTWORK")
    sep:SetHeight(1)
    sep:SetPoint("TOPLEFT", condFrame, "TOPLEFT", 16, -55)
    sep:SetPoint("TOPRIGHT", condFrame, "TOPRIGHT", -16, -55)
    sep:SetTexture(1, 1, 1)
    if sep.SetVertexColor then
      sep:SetVertexColor(1, 1, 1, 0.25)
    end

    condFrame.groupLabel = condFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    condFrame.groupLabel:SetPoint("TOPLEFT", condFrame, "TOPLEFT", 20, -68)
    condFrame.groupLabel:SetText("如果想对此图标进行分组或分类，请从下方选择：")
    condFrame.groupLabel:SetWidth(315)
    condFrame.groupLabel:SetJustifyH("LEFT")

    condFrame.growthDD = CreateFrame("Frame", "DoiteConditions_GrowthDD", condFrame, "UIDropDownMenuTemplate")
    condFrame.growthDD:SetPoint("BOTTOMLEFT", condFrame.groupLabel, "BOTTOMLEFT", -18, -43)
    if UIDropDownMenu_SetWidth then
      pcall(UIDropDownMenu_SetWidth, 110, condFrame.growthDD)
    end
    condFrame.growthDD:Hide()

    -- 光环数量标签 + 下拉框
    condFrame.numAurasLabel = condFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    condFrame.numAurasLabel:SetPoint("LEFT", condFrame.growthDD, "RIGHT", -5, 2)
    condFrame.numAurasLabel:SetText("光环数量限制？")
    condFrame.numAurasLabel:Hide()

    condFrame.numAurasDD = CreateFrame("Frame", "DoiteConditions_NumAurasDD", condFrame, "UIDropDownMenuTemplate")
    condFrame.numAurasDD:SetPoint("LEFT", condFrame.numAurasLabel, "RIGHT", -10, -2)
    if UIDropDownMenu_SetWidth then
      pcall(UIDropDownMenu_SetWidth, 75, condFrame.numAurasDD)
    end
    condFrame.numAurasDD:Hide()

    -- 间距标签 + 滑块 + 编辑框
    condFrame.spacingLabel = condFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    condFrame.spacingLabel:SetPoint("BOTTOMLEFT", condFrame.growthDD, "BOTTOMLEFT", 18, -15)
    condFrame.spacingLabel:SetText("间距")
    condFrame.spacingLabel:Hide()

    condFrame.spacingSlider = CreateFrame("Slider", "DoiteConditions_SpacingSlider", condFrame, "OptionsSliderTemplate")
    condFrame.spacingSlider:SetWidth(100)
    condFrame.spacingSlider:SetHeight(16)
    condFrame.spacingSlider:SetPoint("LEFT", condFrame.spacingLabel, "RIGHT", 10, 0)
    condFrame.spacingSlider:SetMinMaxValues(0, 100)
    condFrame.spacingSlider:SetValueStep(1)
    condFrame.spacingSlider:Hide()

    _G[condFrame.spacingSlider:GetName() .. 'Low']:SetText("0")
    _G[condFrame.spacingSlider:GetName() .. 'High']:SetText("100")
    _G[condFrame.spacingSlider:GetName() .. 'Text']:SetText("")

    condFrame.spacingEdit = CreateFrame("EditBox", "DoiteConditions_SpacingEdit", condFrame, "InputBoxTemplate")
    condFrame.spacingEdit:SetWidth(30)
    condFrame.spacingEdit:SetHeight(18)
    condFrame.spacingEdit:SetPoint("LEFT", condFrame.spacingSlider, "RIGHT", 10, 0)
    condFrame.spacingEdit:SetAutoFocus(false)
    condFrame.spacingEdit:SetFontObject("GameFontNormalSmall")
    condFrame.spacingEdit:SetMaxLetters(3)
    condFrame.spacingEdit:Hide()

    -- 处理更新的函数
    local function UpdateSpacing(val)
      if not currentKey then return end
      local d = EnsureDBEntry(currentKey)
      d.spacing = val
      if not val then d.spacing = nil end
      DoiteGroup.RequestReflow()
    end

    condFrame.spacingSlider:SetScript("OnValueChanged", function()
      local val = math.floor(this:GetValue() + 0.5)
      if condFrame.spacingEdit then
         condFrame.spacingEdit:SetText(tostring(val))
      end
      UpdateSpacing(val)
    end)

    condFrame.spacingEdit:SetScript("OnEnterPressed", function()
      this:ClearFocus()
      local val = tonumber(this:GetText()) or 0
      if val < 0 then val = 0 end
      if val > 100 then val = 100 end

      condFrame.spacingSlider:SetValue(val)
      UpdateSpacing(val)
      this:SetText(tostring(val))
    end)

    condFrame.spacingEdit:SetScript("OnEscapePressed", function()
      this:ClearFocus()
      local val = math.floor(condFrame.spacingSlider:GetValue() + 0.5)
      this:SetText(tostring(val))
    end)

    condFrame.InitGrowthDropdown = InitGrowthDropdown
    condFrame.InitNumAurasDropdown = InitNumAurasDropdown

    if DoiteGroup and DoiteGroup.AttachEditGroupUI then
      DoiteGroup.AttachEditGroupUI(condFrame, {
        Ensure = EnsureDBEntry,
        SafeRefresh = SafeRefresh,
        SafeEvaluate = SafeEvaluate,
        ListRefresh = DoiteAuras_RefreshList,
        UpdateEditor = UpdateCondFrameForKey,
      })
    end

    condFrame.groupTitle2 = condFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    condFrame.groupTitle2:SetPoint("TOPLEFT", condFrame, "TOPLEFT", 20, -155)
    condFrame.groupTitle2:SetText("|cff6FA8DC条件和规则|r")

    local sep2 = condFrame:CreateTexture(nil, "ARTWORK")
    sep2:SetHeight(1)
    sep2:SetPoint("TOPLEFT", condFrame, "TOPLEFT", 16, -170)
    sep2:SetPoint("TOPRIGHT", condFrame, "TOPRIGHT", -16, -170)
    sep2:SetTexture(1, 1, 1)
    if sep2.SetVertexColor then
      sep2:SetVertexColor(1, 1, 1, 0.25)
    end

    -- === 条件和规则的可滚动容器（不改变其他位置的尺寸/位置） ===

    if not condFrame.condListContainer then
      local cW = condFrame:GetWidth() - 43
      local cH = 190

      local listContainer = CreateFrame("Frame", nil, condFrame)
      listContainer:SetWidth(cW)
      listContainer:SetHeight(cH)
      listContainer:SetPoint("TOPLEFT", condFrame, "TOPLEFT", 14, -173)
      listContainer:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16
      })
      listContainer:SetBackdropColor(0, 0, 0, 0.7)
      condFrame.condListContainer = listContainer

      local scrollFrame = CreateFrame("ScrollFrame", "DoiteConditionsScroll", listContainer, "UIPanelScrollFrameTemplate")
      scrollFrame:SetWidth(cW - 20)
      scrollFrame:SetHeight(cH - 9)
      scrollFrame:SetPoint("TOPLEFT", listContainer, "TOPLEFT", 12, -5)
      condFrame.condScrollFrame = scrollFrame
      condFrame._scrollFrame = scrollFrame

      local listContent = CreateFrame("Frame", "DoiteConditionsListContent", scrollFrame)
      listContent:SetWidth(cW - 20)
      listContent:SetHeight(cH - 10)
      scrollFrame:SetScrollChild(listContent)
      condFrame._condArea = listContent

      listContent:SetHeight(900)

      -- 确保视觉层级（级别）将背景保持在控件下方
      local baseLevel = condFrame:GetFrameLevel() or 1
      listContainer:SetFrameLevel(baseLevel + 0)
      scrollFrame:SetFrameLevel(baseLevel + 1)
      listContent:SetFrameLevel(baseLevel + 2)

      -- 可选（有助于点击/滚动的行为）
      if scrollFrame.EnableMouseWheel then
        scrollFrame:EnableMouseWheel(true)
      end
    end

    -- 创建条件界面部分（独立）
    CreateConditionsUI()

    condFrame.groupTitle3 = condFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    condFrame.groupTitle3:SetPoint("TOPLEFT", condFrame, "TOPLEFT", 20, -375)
    condFrame.groupTitle3:SetText("|cff6FA8DC位置和尺寸|r")

    condFrame.sep3 = condFrame:CreateTexture(nil, "ARTWORK")
    condFrame.sep3:SetHeight(1)
    condFrame.sep3:SetPoint("TOPLEFT", condFrame, "TOPLEFT", 16, -390)
    condFrame.sep3:SetPoint("TOPRIGHT", condFrame, "TOPRIGHT", -16, -390)
    condFrame.sep3:SetTexture(1, 1, 1)
    if condFrame.sep3.SetVertexColor then
      condFrame.sep3:SetVertexColor(1, 1, 1, 0.25)
    end

    -- 显示网格按钮
    local gridBtn = CreateFrame("Button", "DoiteConditions_GridBtn", condFrame, "UIPanelButtonTemplate")
    gridBtn:SetWidth(80)
    gridBtn:SetHeight(20)
    gridBtn:ClearAllPoints()
    gridBtn:SetPoint("LEFT", condFrame.groupTitle3, "RIGHT", 140, 3)
    gridBtn:SetText("显示网格")
    gridBtn:SetScript("OnClick", function()
        DoiteEdit_ToggleGrid()
        if DoiteEdit_IsGridShown() then
            gridBtn:SetText("隐藏网格")
        else
            gridBtn:SetText("显示网格")
        end
    end)
    -- 确保绘制层不与标准对话框重叠
    gridBtn:SetFrameLevel(condFrame:GetFrameLevel() + 5)
    condFrame.gridBtn = gridBtn

    -- 自定义函数保存按钮（网格按钮左侧，同一行）
    local customSaveBtn = CreateFrame("Button", "DoiteConditions_CustomSaveBtn", condFrame, "UIPanelButtonTemplate")
    customSaveBtn:SetWidth(70)
    customSaveBtn:SetHeight(20)
    customSaveBtn:SetPoint("RIGHT", gridBtn, "LEFT", -8, 0)
    customSaveBtn:SetText("保存")
    customSaveBtn:SetFrameLevel(condFrame:GetFrameLevel() + 5)
    customSaveBtn:Hide()
    condFrame.cond_custom_function_save = customSaveBtn

    local customStatusText = condFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    customStatusText:SetPoint("RIGHT", customSaveBtn, "LEFT", -8, 0)
    customStatusText:SetTextColor(0.7, 0.7, 0.7)
    customStatusText:SetText("")
    condFrame.cond_custom_function_status = customStatusText

    customSaveBtn:SetScript("OnClick", function()
      if not currentKey then
        return
      end

      local edit = condFrame and condFrame.cond_custom_function_edit
      local source = (edit and edit.GetText and edit:GetText()) or ""
      local fn, err = CompileCustomFunctionSource(source)
      if not fn then
        if condFrame and condFrame.cond_custom_function_status then
          condFrame.cond_custom_function_status:SetText("|cffff4040错误|r")
        end
        if DEFAULT_CHAT_FRAME then
          DEFAULT_CHAT_FRAME:AddMessage("|cffff4040DoiteAuras: 自定义函数编译错误:|r " .. tostring(err))
        end
        return
      end

      local d = EnsureDBEntry(currentKey)
      local okRun, show, texture, hideBackground, remaining, stacks = pcall(fn, {})
      if not okRun then
        if condFrame and condFrame.cond_custom_function_status then
          condFrame.cond_custom_function_status:SetText("|cffff4040错误|r")
        end
        if DEFAULT_CHAT_FRAME then
          DEFAULT_CHAT_FRAME:AddMessage("|cffff4040DoiteAuras: 自定义函数运行时错误:|r " .. tostring(show))
        end
        return
      end

      d.customFunctionSource = source
      d._daCustomCompiled = fn
      d._daCustomCompiledSrc = source
      d._daCustomRuntime = {}
      d._daCustomShow = (show == true or show == 1)
      d._daCustomTexture = (type(texture) == "string" and texture ~= "") and texture or nil
      d._daCustomHideBG = (hideBackground == true)
      d._daCustomRemaining = (type(remaining) == "number") and remaining or nil
      d._daCustomStacks = (type(stacks) == "number") and stacks or nil

      if condFrame and condFrame.cond_custom_function_status then
        condFrame.cond_custom_function_status:SetText("|cff22ff22已保存|r")
      end

      if DoiteConditions_RequestEvaluate then
        DoiteConditions_RequestEvaluate()
      end
      if DoiteAuras_RefreshIcons then
        DoiteAuras_RefreshIcons()
      end
    end)

    -- 滑块辅助函数（制作一个滑块 + 下方小编辑框）
    local function MakeSlider(name, text, x, y, width, minVal, maxVal, step)
      local s = CreateFrame("Slider", name, condFrame, "OptionsSliderTemplate")
      s:SetWidth(width)
      s:SetHeight(16)
      s:SetMinMaxValues(minVal, maxVal)
      s:SetValueStep(step)
      s:SetPoint("TOPLEFT", condFrame, "TOPLEFT", x, y)

      local txt = _G[s:GetName() .. 'Text']
      local low = _G[s:GetName() .. 'Low']
      local high = _G[s:GetName() .. 'High']
      if txt then
        txt:SetText(text);
        txt:SetFontObject("GameFontNormalSmall")
      end
      if low then
        low:SetText(tostring(minVal));
        low:SetFontObject("GameFontNormalSmall")
      end
      if high then
        high:SetText(tostring(maxVal));
        high:SetFontObject("GameFontNormalSmall")
      end

      -- 滑块下方的小编辑框
      local eb = CreateFrame("EditBox", name .. "_EditBox", condFrame, "InputBoxTemplate")
      eb:SetWidth(33);
      eb:SetHeight(18)
      eb:SetPoint("TOP", s, "BOTTOM", 3, -8)
      eb:SetAutoFocus(false)
      eb:SetText("0")
      eb:SetJustifyH("CENTER")
      eb:SetFontObject("GameFontNormalSmall")
      eb.slider = s
      eb._updating = false

      -- 滑块 -> 编辑框（健壮，避免递归）
      s:SetScript("OnValueChanged", function(self, value)
        local frame = self or s
        if frame._isSyncing then return end
        local v = tonumber(value)
        if not v and frame and frame.GetValue then
          v = frame:GetValue()
        end
        if not v then
          return
        end
        v = math.floor(v + 0.5)
        if eb and eb.SetText and not eb._updating then
          eb._updating = true
          eb:SetText(tostring(v))
          eb._updating = false
        end
        if frame and frame.updateFunc then
          frame.updateFunc(v)
        end
      end)

      -- 滑块被按住时标记“拖拽中”
      s:SetScript("OnMouseDown", function()
        _G["DoiteUI_Dragging"] = true
      end)

      -- 释放时：暂停结束并执行一次重度重绘
      s:SetScript("OnMouseUp", function()
        _G["DoiteUI_Dragging"] = false
        DoiteEdit_FlushHeavy()
      end)

      -- 编辑框提交辅助函数（钳位 + 设置滑块）
      local function CommitEditBox(box)
        if not box or not box.slider then
          return
        end
        local sref = box.slider
        local txt = box:GetText()
        local val = tonumber(txt)
        if not val then
          -- 恢复滑块的当前取整值
          local cur = math.floor((sref:GetValue() or 0) + 0.5)
          box:SetText(tostring(cur))
        else
          if val < minVal then
            val = minVal
          end
          if val > maxVal then
            val = maxVal
          end
          -- 在滑块上设置值；OnValueChanged将通过updateFunc处理数据库更新
          box._updating = true
          sref:SetValue(val)
          box._updating = false
        end
      end

      -- 编辑框 -> 滑块在输入时
      eb:SetScript("OnTextChanged", function()
        if this._updating then
          return
        end
        local txt = this:GetText()
        local num = tonumber(txt)
        if not num then
          return
        end

        -- 钳位到滑块范围（在MakeSlider中捕获）
        if num < minVal then
          num = minVal
        end
        if num > maxVal then
          num = maxVal
        end

        -- 驱动滑块；其OnValueChanged将通过updateFunc(...)推送到数据库
        this._updating = true
        this.slider:SetValue(num)
        this._updating = false
      end)

      eb:SetScript("OnEnterPressed", function(self)
        CommitEditBox(self)
        if self and self.ClearFocus then
          self:ClearFocus()
        end
      end)

      eb:SetScript("OnEscapePressed", function()
        if this.ClearFocus then
          this:ClearFocus()
        end
        -- 同时恢复当前的滑块值
        local cur = math.floor((this.slider:GetValue() or 0) + 0.5)
        this._updating = true
        this:SetText(tostring(cur))
        this._updating = false
      end)

      eb:SetScript("OnEditFocusLost", function()
        CommitEditBox(this)
      end)

      return s, eb
    end

    -- 滑块宽度（左侧留边 + 间距）
    local totalAvailable = condFrame:GetWidth() - 60
    local sliderWidth = math.floor((totalAvailable - 20) / 3)
    if sliderWidth < 100 then
      sliderWidth = 100
    end

    local baseX = 20
    local baseY = -410
    local gap = 8

    do
      local minX, maxX, minY, maxY, minSize, maxSize = _DA_ComputePosSizeRanges()

      condFrame.sliderX, condFrame.sliderXBox = MakeSlider("DoiteConditions_SliderX", "水平位置", baseX, baseY, sliderWidth, minX, maxX, 1)
      condFrame.sliderY, condFrame.sliderYBox = MakeSlider("DoiteConditions_SliderY", "垂直位置", baseX + sliderWidth + gap, baseY, sliderWidth, minY, maxY, 1)
      condFrame.sliderSize, condFrame.sliderSizeBox = MakeSlider("DoiteConditions_SliderSize", "图标尺寸", baseX + 2 * (sliderWidth + gap), baseY, sliderWidth, minSize, maxSize, 1)
    end


    -- 滑块更改时调用的更新函数
    condFrame.sliderX.updateFunc = function(value)
      if not currentKey then
        return
      end
      local d = EnsureDBEntry(currentKey)
      d.offsetX = value
      DoiteEdit_QueueHeavy()
    end
    condFrame.sliderY.updateFunc = function(value)
      if not currentKey then
        return
      end
      local d = EnsureDBEntry(currentKey)
      d.offsetY = value
      DoiteEdit_QueueHeavy()
    end
    condFrame.sliderSize.updateFunc = function(value)
      if not currentKey then
        return
      end
      local d = EnsureDBEntry(currentKey)
      d.iconSize = value
      DoiteEdit_QueueHeavy()
    end

    -- 每次面板显示时，使滑块范围与当前分辨率/UI比例同步
    condFrame:SetScript("OnShow", function(self)
      _DA_ApplySliderRanges()

      -- 编辑器打开时默认显示网格
      if not DoiteEdit_IsGridShown() then
        DoiteEdit_ToggleGrid()
      end
      if condFrame.gridBtn then
        condFrame.gridBtn:SetText("隐藏网格")
      end
    end)

    -- 初始隐藏位置部分
    if condFrame.groupTitle3 then
      condFrame.groupTitle3:Hide()
    end
    if condFrame.sep3 then
      condFrame.sep3:Hide()
    end
    if condFrame.sliderX then
      condFrame.sliderX:Hide()
    end
    if condFrame.sliderY then
      condFrame.sliderY:Hide()
    end
    if condFrame.sliderSize then
      condFrame.sliderSize:Hide()
    end
    if condFrame.sliderXBox then
      condFrame.sliderXBox:Hide()
    end
    if condFrame.sliderYBox then
      condFrame.sliderYBox:Hide()
    end
    if condFrame.sliderSizeBox then
      condFrame.sliderSizeBox:Hide()
    end

    -- 当主DoiteAuras框架隐藏时，也隐藏条件框架
    if DoiteAurasFrame then
      local oldHide = DoiteAurasFrame:GetScript("OnHide")
      DoiteAurasFrame:SetScript("OnHide", function(self)
        if condFrame then
          condFrame:Hide()
        end
        if oldHide then
          oldHide(self)
        end
      end)
    end
  end

  -- 编辑开始时确保网格默认显示
  if not DoiteEdit_IsGridShown() then
    DoiteEdit_ToggleGrid()
  end
  if condFrame.gridBtn then
    condFrame.gridBtn:SetText("隐藏网格")
  end

  condFrame:Show()
  UpdateCondFrameForKey(key)
end