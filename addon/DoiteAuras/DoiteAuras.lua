---------------------------------------------------------------
-- DoiteAuras.lua
-- 适用于魔兽世界经典旧世的轻量级类 WeakAura 插件
-- 请尊重许可说明：使用前请询问
-- WoW 1.12 | Lua 5.0
---------------------------------------------------------------

if DoiteAurasFrame then return end

-- SavedVariables 初始化（保护性，不要覆盖已有数据）
DoiteAurasDB = DoiteAurasDB or {}
DoiteAurasDB.spells         = DoiteAurasDB.spells         or {}
DoiteAurasDB.cache          = DoiteAurasDB.cache          or {}
DoiteAurasDB.groupSort       = DoiteAurasDB.groupSort       or {}
DoiteAurasDB.bucketDisabled  = DoiteAurasDB.bucketDisabled  or {}
DoiteAurasDB.bucketCollapsed = DoiteAurasDB.bucketCollapsed or {}
DoiteAurasDB.pfuiBorder      = DoiteAurasDB.pfuiBorder
if DoiteAurasDB.showtooltip == nil then
  DoiteAurasDB.showtooltip = true
end
DoiteAuras = DoiteAuras or {}

if _G == nil and type(getfenv) == "function" then
  _G = getfenv(0)
end

if UIDropDownMenu_CreateInfo == nil then
  function UIDropDownMenu_CreateInfo()
    return {}
  end
end

local renameState
local DA_GetSpellIdShownName
local DA_ClearRenameState
local DA_CancelRename
local DA_IsRenameNameDuplicate

-- 始终返回一个有效的名称->纹理缓存表
local function DA_Cache()
  DoiteAurasDB = DoiteAurasDB or {}
  DoiteAurasDB.cache = DoiteAurasDB.cache or {}
  return DoiteAurasDB.cache
end

---------------------------------------------------------------
-- pfUI 边框样式辅助函数
---------------------------------------------------------------
local function DA_IsPfUIAvailable()
    if type(IsAddOnLoaded) ~= "function" then
        return false
    end
    local ok = IsAddOnLoaded("pfUI")
    return (ok == 1 or ok == true)
end

-- 可供其他插件文件调用
function DoiteAuras_HasPfUI()
    return DA_IsPfUIAvailable() == true
end

-- 应用/移除辅助函数
local function DA_ApplyPfUIBorder(frame)
    if not frame or not DA_IsPfUIAvailable() then return end

    -- 移除现有背景
    if frame.backdrop then
        frame.backdrop:Hide()
        frame.backdrop = nil
    end

    -- 应用 pfUI 背景
    pfUI.api.CreateBackdrop(frame)

    -- 对图标应用纹理裁剪
    if frame.icon and frame.icon.SetTexCoord then
        frame.icon:SetTexCoord(.08, .92, .08, .92)
    end
end

local function DA_RemovePfUIBorder(frame)
    if not frame then return end

    if frame.backdrop then
        frame.backdrop:Hide()
        frame.backdrop = nil
    end

    if frame.icon and frame.icon.SetTexCoord then
        frame.icon:SetTexCoord(0, 1, 0, 1)
    end
end

local function DA_ApplyBorderToAllIcons()
    local usePfUI = (DoiteAurasDB and DoiteAurasDB.pfuiBorder) == true

    for key, _ in pairs(DoiteAurasDB.spells or {}) do
        local f = _G["DoiteIcon_" .. key]
        if f then
            if usePfUI then
                DA_ApplyPfUIBorder(f)
            else
                DA_RemovePfUIBorder(f)
            end
        end
    end
end

-- 为其他插件文件导出可调用函数
function DoiteAuras_ApplyBorderToAllIcons() DA_ApplyBorderToAllIcons() end

-- 强制执行默认/强制状态：
-- - 如果 pfUI 可用且 pfuiBorder 未设置（nil）：默认开启
-- - 如果 pfUI 不可用且 pfuiBorder 未设置（nil）：默认关闭
local function DA_EnsurePfUIBorderDefault()
    DoiteAurasDB = DoiteAurasDB or {}

    local has = DA_IsPfUIAvailable()

    -- 仅在用户尚未做出选择时设置默认值
    if DoiteAurasDB.pfuiBorder == nil then
        if has then
            DoiteAurasDB.pfuiBorder = true
        else
            DoiteAurasDB.pfuiBorder = false
        end
    end

    -- 如果 pfUI 现在可用，确保现有图标匹配设置
    if has and DoiteAuras_ApplyBorderToAllIcons then
        pcall(DoiteAuras_ApplyBorderToAllIcons)
    end
end

-- 在进入世界后不久运行一次，以及当 pfUI 加载时
do
    local f = CreateFrame("Frame", "DoiteAurasPfUIInit")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:RegisterEvent("ADDON_LOADED")
    f:SetScript("OnEvent", function()
        if event == "ADDON_LOADED" then
            -- 如果 pfUI 在 DoiteAuras 之后加载，则设置默认值并应用
            if arg1 == "pfUI" then
                DA_EnsurePfUIBorderDefault()
            end
            return
        end

        -- PLAYER_ENTERING_WORLD
        if event == "PLAYER_ENTERING_WORLD" then
            DA_EnsurePfUIBorderDefault()
            this:UnregisterEvent("PLAYER_ENTERING_WORLD")
        end
    end)
end

---------------------------------------------------------------
-- Nampower 需求辅助函数
-- 需要特定的 Nampower 版本
---------------------------------------------------------------
local _NP_REQ_MAJOR, _NP_REQ_MINOR, _NP_REQ_PATCH = 4, 1, 3 -- 根据需要更改

local function _NP_GetVersion()
  if type(GetNampowerVersion) == "function" then
    local a, b, c = GetNampowerVersion()
    return (tonumber(a) or 0), (tonumber(b) or 0), (tonumber(c) or 0), true
  end
  return 0, 0, 0, false
end

local function _NP_VersionString(maj, min, pat, hasFn)
  if not hasFn then
    return "未知"
  end
  return tostring(maj) .. "." .. tostring(min) .. "." .. tostring(pat)
end

-- 返回：ok(bool), verStr(string)
local function _NP_AtLeast(reqMaj, reqMin, reqPat)
  local maj, min, pat, hasFn = _NP_GetVersion()
  local verStr = _NP_VersionString(maj, min, pat, hasFn)

  if not hasFn then
    return false, verStr
  end

  if maj > reqMaj then return true, verStr end
  if maj < reqMaj then return false, verStr end

  if min > reqMin then return true, verStr end
  if min < reqMin then return false, verStr end

  if pat >= reqPat then return true, verStr end
  return false, verStr
end

local function DA_GetMissingRequiredMods()
  local missing = {}

  -- Nampower：必须 >= _NP_REQ_MAJOR/_NP_REQ_MINOR/_NP_REQ_PATCH 中指定的版本
  local npOK, npVerStr = _NP_AtLeast(_NP_REQ_MAJOR, _NP_REQ_MINOR, _NP_REQ_PATCH)
  if not npOK then
    table.insert(missing, "Nampower 4.1.3+ (你有 " .. tostring(npVerStr) .. ")")
  end

  return missing
end

local function DA_IsHardDisabled()
  return _G["DoiteAuras_HardDisabled"] == true
end

-- 持久存储组布局计算位置
_G["DoiteGroup_Computed"]       = _G["DoiteGroup_Computed"]       or {}
_G["DoiteGroup_LastLayoutTime"] = _G["DoiteGroup_LastLayoutTime"] or 0

-- ========= 法术纹理缓存（技能） =========

local function DoiteAuras_RebuildSpellTextureCache()
    local cache = DA_Cache()
    for tab = 1, (GetNumSpellTabs() or 0) do
        local _, _, offset, numSlots = GetSpellTabInfo(tab)
        if numSlots and numSlots > 0 then
            for i = 1, numSlots do
                local idx = offset + i
                local name, rank = GetSpellName(idx, BOOKTYPE_SPELL)
                if not name then break end
                local tex = GetSpellTexture and GetSpellTexture(idx, BOOKTYPE_SPELL)
                if name and tex and cache[name] ~= tex then
                    cache[name] = tex
                end
            end
        end
    end

    -- 如果已有配置的技能条目，为其 .iconTexture 播种以便立即使用
    if DoiteAurasDB.spells then
        for key, data in pairs(DoiteAurasDB.spells) do
            if data and data.type == "Ability" then
                local nm = data.displayName or data.name
                local t  = nm and cache[nm]
                if t then data.iconTexture = t end
            end
        end
    end

    -- 法术书索引可能改变；强制下次刷新时重新查找槽位
    if DoiteAuras then
        DoiteAuras._spellSlotCache = nil
    end
end

local function DA_GetSpellTextureById(spellId)
    local sid = tonumber(spellId)
    if not sid or sid <= 0 then
        return nil
    end

    if type(GetSpellRecField) == "function" and type(GetSpellIconTexture) == "function" then
        local okIconId, iconId = pcall(GetSpellRecField, sid, "spellIconID")
        if okIconId and iconId and iconId > 0 then
            local okTex, tex = pcall(GetSpellIconTexture, iconId)
            if okTex and type(tex) == "string" and tex ~= "" then
                return tex
            end
        end
    end

    return nil
end

-- 事件钩子：在登录/进入世界以及法术书改变（天赋/配置切换）时重建
local _daSpellTex = CreateFrame("Frame", "DoiteSpellTex")
_daSpellTex:RegisterEvent("PLAYER_ENTERING_WORLD")
_daSpellTex:RegisterEvent("SPELLS_CHANGED")
_daSpellTex:SetScript("OnEvent", function()
    if DoiteAuras then
        DoiteAuras._spellSlotCache = nil
    end

    DoiteAuras_RebuildSpellTextureCache()
    if DoiteAuras_RefreshIcons then pcall(DoiteAuras_RefreshIcons) end
end)

-- 标题大小写函数，对小词有例外（保持首词大写）
-- 特殊处理罗马数字如 "II", "IV", "VIII", "X"，使其保持全大写。同时，如果字母直接出现在 "." 之后，保持大写（修复 "R.O.I.D.S." => "R.O.I.D.S."）。
local function TitleCase(str)
    if not str then return "" end
    str = tostring(str)

    local exceptions = {
        ["of"]=true, ["and"]=true, ["the"]=true, ["for"]=true,
        ["in"]=true, ["on"]=true, ["to"]=true, ["a"]=true,
        ["an"]=true, ["with"]=true, ["by"]=true, ["at"]=true
    }

    local function IsRomanNumeralToken(core)
        if not core or core == "" then return false end
        local upper = string.upper(core)
        -- 仅包含罗马数字字符
        if not string.find(upper, "^[IVXLCDM]+$") then
            return false
        end
        -- 可选：避免过长的序列；等级通常较短
        if string.len(upper) > 4 then
            return false
        end
        return true
    end

    -- 通常小写字母，但将满足以下条件的字母大写：
    --  - 第一个字符（当 capFirst 为 true 时）
    --  - 紧跟在 '.' 之后
    local function DotAwareCase(core, capFirst)
        if not core or core == "" then
            return ""
        end

        local out = ""
        local i, n = 1, string.len(core)

        while i <= n do
            local ch = string.sub(core, i, i)

            -- 判断 ch 是否为字母 (A-Z / a-z)
            if string.find(ch, "%a") then
                if i == 1 then
                    if capFirst then
                        out = out .. string.upper(ch)
                    else
                        out = out .. string.lower(ch)
                    end
                else
                    local prev = string.sub(core, i-1, i-1)
                    if prev == "." then
                        out = out .. string.upper(ch)
                    else
                        out = out .. string.lower(ch)
                    end
                end
            else
                out = out .. ch
            end

            i = i + 1
        end

        return out
    end

    local result, first = "", true

    for word in string.gfind(str, "%S+") do
        -- 如果单词以 "(" 开头，强制大写 "(" 后的第一个字母。
        local startsParen = (string.sub(word, 1, 1) == "(")
        local leading     = startsParen and "(" or ""
        local core        = startsParen and string.sub(word, 2) or word

        local lowerCore = string.lower(core or "")
        local upperCore = string.upper(core or "")

        -- 1) 罗马数字：始终保持全大写
        if IsRomanNumeralToken(core) then
            result = result .. leading .. upperCore .. " "
            first = false

        else
            -- 2) 标准标题大小写规则（点感知）
            if first then
                -- 始终大写第一个词
                result = result .. leading .. DotAwareCase(core, true) .. " "
                first = false
            else
                if startsParen then
                    -- 括号内的第一个词：不管例外，强制大写
                    result = result .. leading .. DotAwareCase(core, true) .. " "
                elseif exceptions[lowerCore] then
                    -- 正常小词行为（保持小写）
                    result = result .. lowerCore .. " "
                else
                    result = result .. leading .. DotAwareCase(core, true) .. " "
                end
            end
        end
    end

    result = string.gsub(result, "%s+$", "")
    return result
end

-- === 重复项处理辅助函数 ===
local function BaseKeyFor(data_or_name, typ)
  if type(data_or_name) == "table" then
    local d = data_or_name
    local nm = (d.displayName or d.name or "")
    local tp = (d.type or "Ability")
    return nm .. "_" .. tp
  else
    local nm = tostring(data_or_name or "")
    local tp = tostring(typ or "Ability")
    return nm .. "_" .. tp
  end
end

-- 为数据库和框架生成唯一存储键
local function GenerateUniqueKey(name, typ)
  local base = BaseKeyFor(name, typ)
  if not DoiteAurasDB.spells[base] then
    return base, base, 1
  end
  local n = 2
  while DoiteAurasDB.spells[base .. "#" .. tostring(n)] do
    n = n + 1
  end
  return (base .. "#" .. tostring(n)), base, n
end

-- 查找兄弟（相同的 displayName 和类型）
local function IterSiblings(name, typ)
  local base = BaseKeyFor(name, typ)
  local function iter(_, last)
    for k, d in pairs(DoiteAurasDB.spells) do
      if k ~= last then
        local bk = BaseKeyFor(d)
        if bk == base then
          return k, d
        end
      end
    end
  end
  return iter, nil, nil
end

-- 用于增益/减益扫描的工具提示
local daTip = CreateFrame("GameTooltip", "DoiteAurasTooltip", nil, "GameTooltipTemplate")
daTip:SetOwner(UIParent, "ANCHOR_NONE")

-- 缓存工具提示字体字符串
local DA_TipLeft = {}
do
    local i = 1
    while i <= 15 do
        DA_TipLeft[i] = getglobal("DoiteAurasTooltipTextLeft" .. i)
        i = i + 1
    end
end

local function GetBuffName(unit, index, debuff)
    daTip:ClearLines()
    if debuff then
        daTip:SetUnitDebuff(unit, index)
    else
        daTip:SetUnitBuff(unit, index)
    end
    return DoiteAurasTooltipTextLeft1:GetText()
end

-- 主框架（布局和尺寸）
local frame = CreateFrame("Frame", "DoiteAurasFrame", UIParent)
frame:SetWidth(385)
frame:SetHeight(470)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
frame:EnableMouse(true)
frame:SetMovable(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function() this:StartMoving() end)
frame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
frame:Hide()
frame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 16, edgeSize = 32,
    insets = { left=11, right=12, top=12, bottom=11 }
})
frame:SetBackdropColor(0, 0, 0, 1)
frame:SetBackdropBorderColor(1, 1, 1, 1)
frame:SetFrameStrata("FULLSCREEN_DIALOG")

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -15)
title:SetText("|cff6FA8DCDoiteAuras|r")

local sep = frame:CreateTexture(nil, "ARTWORK")
sep:SetHeight(1)
sep:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -35)
sep:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20, -35)
sep:SetTexture(1,1,1)
if sep.SetVertexColor then sep:SetVertexColor(1,1,1,0.25) end

-- 介绍文本
local intro = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
intro:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -40)
intro:SetText("输入名称（通用名称匹配）或通过法术 ID（唯一）添加：")

-- 关闭按钮
local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -6)
closeBtn:SetScript("OnClick", function() this:GetParent():Hide() end)

-- 导入 / 导出按钮（在关闭 "X" 左侧）
local exportBtn = CreateFrame("Button", "DoiteAurasExportButton", frame, "UIPanelButtonTemplate")
exportBtn:SetWidth(60)
exportBtn:SetHeight(20)
exportBtn:SetPoint("RIGHT", closeBtn, "LEFT", -4, 0)
exportBtn:SetText("导出")
exportBtn:SetScript("OnClick", function()
    DA_CancelRename()
    if DoiteAuras_RefreshList then pcall(DoiteAuras_RefreshList) end
    if DoiteExport_ShowExportFrame then
        DoiteExport_ShowExportFrame()
    else
        (DEFAULT_CHAT_FRAME or ChatFrame1):AddMessage("|cffff0000DoiteAuras:|r 导出模块未加载。")
    end
end)

local importBtn = CreateFrame("Button", "DoiteAurasImportButton", frame, "UIPanelButtonTemplate")
importBtn:SetWidth(60)
importBtn:SetHeight(20)
importBtn:SetPoint("RIGHT", exportBtn, "LEFT", -4, 0)
importBtn:SetText("导入")
importBtn:SetScript("OnClick", function()
    DA_CancelRename()
    if DoiteAuras_RefreshList then pcall(DoiteAuras_RefreshList) end
    if DoiteExport_ShowImportFrame then
        DoiteExport_ShowImportFrame()
    else
        (DEFAULT_CHAT_FRAME or ChatFrame1):AddMessage("|cffff0000DoiteAuras:|r 导入模块未加载。")
    end
end)

-- 设置按钮
local settingsBtn = CreateFrame("Button", "DoiteAurasSettingsButton", frame, "UIPanelButtonTemplate")
settingsBtn:SetWidth(70)
settingsBtn:SetHeight(20)
settingsBtn:SetPoint("RIGHT", importBtn, "LEFT", -4, 0)
settingsBtn:SetText("设置")

-- 外部调用
settingsBtn:SetScript("OnClick", function()
    DA_CancelRename()
    if DoiteAuras_RefreshList then pcall(DoiteAuras_RefreshList) end
    if DoiteAuras_ShowSettings then
        DoiteAuras_ShowSettings()
    else
        (DEFAULT_CHAT_FRAME or ChatFrame1):AddMessage("|cff6FA8DCDoiteAuras:|r 设置模块未加载。")
    end
end)

local function DA_StyleRowEditBox(editBox, justify)
    if not editBox then
        return
    end
    editBox:SetAutoFocus(false)
    editBox:SetFontObject("GameFontNormalSmall")
    editBox:SetJustifyH(justify or "LEFT")
    if editBox.SetTextInsets then
        editBox:SetTextInsets(6, 6, 0, 0)
    end
    if editBox.SetBackdrop then
        editBox:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        editBox:SetBackdropColor(0, 0, 0, 0.85)
        editBox:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
    end
end

-- 输入框 + 添加
local input = CreateFrame("EditBox", "DoiteAurasInput", frame)
input:SetWidth(240)
input:SetHeight(20)
input:SetPoint("TOPLEFT", intro, "TOPLEFT", 5, -15)
DA_StyleRowEditBox(input, "LEFT")

local addBtn = CreateFrame("Button", "DoiteAurasAddBtn", frame, "UIPanelButtonTemplate")
addBtn:SetWidth(60)
addBtn:SetHeight(20)
addBtn:SetPoint("LEFT", input, "RIGHT", 10, 0)
addBtn:SetText("添加")

-- 技能下拉框（基于法术书，非被动）
local abilityDropDown = CreateFrame("Frame", "DoiteAurasAbilityDropDown", frame, "UIDropDownMenuTemplate")
abilityDropDown:SetPoint("TOPLEFT", input, "TOPLEFT", -23, 3) -- 调整以视觉上重叠输入框
UIDropDownMenu_Initialize(abilityDropDown, function() end)
UIDropDownMenu_SetWidth(230, abilityDropDown)
UIDropDownMenu_SetText("从下拉列表中选择", abilityDropDown)
abilityDropDown:Hide()

-- 强制技能下拉框文本左对齐
local abilityText  = getglobal("DoiteAurasAbilityDropDownText")
local abilityMiddle = getglobal("DoiteAurasAbilityDropDownMiddle")
if abilityText then
    abilityText:ClearAllPoints()
    if abilityMiddle then
        abilityText:SetPoint("LEFT", abilityMiddle, "LEFT", 10, 2)
    else
        abilityText:SetPoint("LEFT", abilityDropDown, "LEFT", 10, 2)
    end
    abilityText:SetJustifyH("LEFT")
end

-- 物品下拉框
local itemDropDown = CreateFrame("Frame", "DoiteAurasItemDropDown", frame, "UIDropDownMenuTemplate")
itemDropDown:SetPoint("TOPLEFT", input, "TOPLEFT", -23, 3) -- 调整以视觉上重叠输入框
UIDropDownMenu_Initialize(itemDropDown, function() end)
UIDropDownMenu_SetWidth(230, itemDropDown)
UIDropDownMenu_SetText("从下拉列表中选择", itemDropDown)
itemDropDown:Hide()

local function DA_HookDropDownButtonOnClick(dd, fn)
    if not dd or not fn or not dd.GetName then return end
    local btn = getglobal(dd:GetName() .. "Button")
    if not btn or btn._daRebuildHooked then return end
    btn._daRebuildHooked = true

    local prev = btn.GetScript and btn:GetScript("OnClick")
    btn:SetScript("OnClick", function()
        fn()
        if prev then
            prev()
        end
    end)
end

-- 强制物品下拉框文本左对齐
local itemText  = getglobal("DoiteAurasItemDropDownText")
local itemMiddle = getglobal("DoiteAurasItemDropDownMiddle")
if itemText then
    itemText:ClearAllPoints()
    if itemMiddle then
        itemText:SetPoint("LEFT", itemMiddle, "LEFT", 10, 2)
    else
        itemText:SetPoint("LEFT", itemDropDown, "LEFT", 10, 2)
    end
    itemText:SetJustifyH("LEFT")
end

local barDropDown = CreateFrame("Frame", "DoiteAurasBarDropDown", frame, "UIDropDownMenuTemplate")
barDropDown:SetPoint("TOPLEFT", input, "TOPLEFT", -23, 3)

local function DA_RebuildBarDropDown()
    if not barDropDown then return end
    if UIDropDownMenu_Initialize then
        UIDropDownMenu_Initialize(barDropDown, function()
            local added = false
            if DoiteBars and DoiteBars.KindOrder and DoiteBars.Kinds then
                local i
                for i = 1, table.getn(DoiteBars.KindOrder) do
                    local kindKey = DoiteBars.KindOrder[i]
                    local kd = DoiteBars.Kinds[kindKey]
                    if kd and kd.label then
                        local info = UIDropDownMenu_CreateInfo()
                        info.text = kd.label
                        info.value = kd.label
                        info.func = function()
                            UIDropDownMenu_SetText(kd.label, barDropDown)
                        end
                        UIDropDownMenu_AddButton(info)
                        added = true
                    end
                end
            end
            if not added then
                local info = UIDropDownMenu_CreateInfo()
                info.text = "没有可用的条状元素"
                info.notCheckable = true
                info.func = function() end
                UIDropDownMenu_AddButton(info)
            end
        end)
    end
    if UIDropDownMenu_SetText then
        UIDropDownMenu_SetText("从下拉列表中选择", barDropDown)
    end
end

DA_RebuildBarDropDown()

UIDropDownMenu_SetWidth(230, barDropDown)
UIDropDownMenu_SetText("从下拉列表中选择", barDropDown)
barDropDown:Hide()

-- 强制条下拉框文本左对齐
local barText  = getglobal("DoiteAurasBarDropDownText")
local barMiddle = getglobal("DoiteAurasBarDropDownMiddle")
if barText then
    barText:ClearAllPoints()
    if barMiddle then
        barText:SetPoint("LEFT", barMiddle, "LEFT", 10, 2)
    else
        barText:SetPoint("LEFT", barDropDown, "LEFT", 10, 2)
    end
    barText:SetJustifyH("LEFT")
end

-- =========================
-- 技能下拉框扫描（法术书，非被动）
-- =========================

-- 保存当前下拉框中显示的技能名称
local DA_AbilityOptions = {}
local DA_AbilityMenuOffset = 0
local DA_ABILITY_PAGE_SIZE = 20  -- 每页显示的条目数

local function DA_ClearAbilityOptions()
    local n = table.getn(DA_AbilityOptions)
    while n > 0 do
        DA_AbilityOptions[n] = nil
        n = n - 1
    end
end

local function DA_AddAbilityOption(name)
    if not name or name == "" then return end
    local n = table.getn(DA_AbilityOptions)
    local i
    for i = 1, n do
        if DA_AbilityOptions[i] == name then
            return
        end
    end
    DA_AbilityOptions[n + 1] = name
end

-- 辅助函数：在下一帧关闭并重新打开技能下拉框
local function DA_RepageAbilityDropdown()
    if not abilityDropDown then return end
    local dd = abilityDropDown

    if DA_RunLater then
        DA_RunLater(0.01, function()
            if dd then
                ToggleDropDownMenu(nil, nil, dd)
                ToggleDropDownMenu(nil, nil, dd)
            end
        end)
    else
        ToggleDropDownMenu(nil, nil, dd)
        ToggleDropDownMenu(nil, nil, dd)
    end
end

local function DA_AbilityMenu_Initialize()
    if not abilityDropDown then return end

    local total = table.getn(DA_AbilityOptions)
    local info

    -- 上一页按钮
    if DA_AbilityMenuOffset > 0 then
        info = {}
        info.text = "|cffffff00<< 上一页 <<|r"
        info.func = function()
            -- 向上翻一页，限制在 0
            local newOffset = DA_AbilityMenuOffset - DA_ABILITY_PAGE_SIZE
            if newOffset < 0 then newOffset = 0 end
            DA_AbilityMenuOffset = newOffset

            -- 用新页面重新打开下拉框
            DA_RepageAbilityDropdown()
        end
        info.keepShownOnClick = 1
        info.notCheckable     = 1
        info.isNotRadio       = 1
        info.checked          = nil
        UIDropDownMenu_AddButton(info)
    end

    local startIndex = DA_AbilityMenuOffset + 1
    local endIndex   = math.min(total, DA_AbilityMenuOffset + DA_ABILITY_PAGE_SIZE)

    local i
    for i = startIndex, endIndex do
        local caption = DA_AbilityOptions[i]
        info = {}
        info.text = caption
        info.func = function()
            UIDropDownMenu_SetText(caption, abilityDropDown)
        end
        UIDropDownMenu_AddButton(info)
    end

    -- 下一页按钮
    if endIndex < total then
        info = {}
        info.text = "|cffffff00>> 下一页 >>|r"
        info.func = function()
            local total = table.getn(DA_AbilityOptions)
            local maxOffset = 0
            if total > DA_ABILITY_PAGE_SIZE then
                maxOffset = total - DA_ABILITY_PAGE_SIZE
            end
            local newOffset = DA_AbilityMenuOffset + DA_ABILITY_PAGE_SIZE
            if newOffset > maxOffset then newOffset = maxOffset end
            DA_AbilityMenuOffset = newOffset

            DA_RepageAbilityDropdown()
        end
        info.keepShownOnClick = 1
        info.notCheckable     = 1
        info.isNotRadio       = 1
        info.checked          = nil
        UIDropDownMenu_AddButton(info)
    end
end

-- 添加仍然可能导致冷却时间（值得跟踪）的被动技能
local DA_AbilityDropdownPassiveAllow = {
    ["Reincarnation"] = true,
}
_G["DA_AbilityDropdownPassiveAllow"] = DA_AbilityDropdownPassiveAllow

local function DA_RebuildAbilityDropDown()
    if not abilityDropDown then return end

    DA_ClearAbilityOptions()

    local seen = {}

    local function scanBook(bookType)
        local i = 1
        while true do
            local name, rank = GetSpellName(i, bookType)
            if not name then
                break
            end

            local isPassive = false

            if IsPassiveSpell then
                -- 尽力而为：如果可用，使用 IsPassiveSpell（签名可能不同）
                local ok, passive = pcall(IsPassiveSpell, i, bookType)
                if ok and passive then
                    isPassive = true
                end
            end

            -- 备选：许多被动技能在等级字符串中有“Passive”
            if (not isPassive) and rank and string.find(rank, "Passive") then
                isPassive = true
            end

            if name and name ~= "" then
                local lname = string.lower(name or "")
                local allowPassive = (DA_AbilityDropdownPassiveAllow[name] == true)

                if ((not isPassive) or allowPassive) and not seen[lname] then
                    seen[lname] = true
                    DA_AddAbilityOption(name)
                end
            end

            i = i + 1
        end
    end

    -- 玩家技能
    scanBook(BOOKTYPE_SPELL)
    -- 宠物技能（猎人/术士等）
    scanBook(BOOKTYPE_PET)

    -- 排序 0–9 A–Z（不区分大小写；相同时按原字符串排序）
    table.sort(DA_AbilityOptions, function(a, b)
        local la = string.lower(a or "")
        local lb = string.lower(b or "")
        if la == lb then
            return (a or "") < (b or "")
        end
        return la < lb
    end)

    -- 重置分页到顶部，并挂接自定义初始化器
    DA_AbilityMenuOffset = 0
    UIDropDownMenu_Initialize(abilityDropDown, DA_AbilityMenu_Initialize)

    -- 每次重建时重置显示的文本
    UIDropDownMenu_SetText("从下拉列表中选择", abilityDropDown)
end

-- =========================
-- 物品下拉框扫描（背包 + 已装备）
-- =========================

-- 保存当前下拉框中显示的物品名称
local DA_ItemOptions = {}
local DA_ItemMenuOffset = 0
local DA_ITEMMENU_PAGE_SIZE = 20  -- 每页显示的条目数

local function DA_ClearItemOptions()
    local n = table.getn(DA_ItemOptions)
    while n > 0 do
        DA_ItemOptions[n] = nil
        n = n - 1
    end
end

local function DA_AddItemOption(name)
    if not name or name == "" then return end
    -- 按纯名称去重
    local n = table.getn(DA_ItemOptions)
    local i
    for i = 1, n do
        if DA_ItemOptions[i] == name then
            return
        end
    end
    DA_ItemOptions[n + 1] = name
end

local DA_ItemInfoByIdCache = {}

local function DA_GetItemInfoById(itemId)
    if not itemId then return nil, nil end
    local c = DA_ItemInfoByIdCache[itemId]
    if c then
        return c.name, c.texture
    end
    local name, _, _, _, _, _, _, _, texture = GetItemInfo(itemId)
    if not name and not texture then
        return nil, nil
    end
    c = { name = name, texture = texture }
    DA_ItemInfoByIdCache[itemId] = c
    return name, texture
end

-- 扫描已装备的饰品和武器中可用的/消耗性效果
local function DA_ScanEquippedUsable()
    -- 饰品1 (13), 饰品2 (14), 主手 (16), 副手 (17), 远程/魔杖 (18)
    local slots = { 13, 14, 16, 17, 18 }
    local i
    for i = 1, table.getn(slots) do
        local slotId = slots[i]
        local info = GetEquippedItem and GetEquippedItem("player", slotId)
        local itemId = info and info.itemId
        if itemId then
            local itemName = DA_GetItemInfoById(itemId)
            if itemName then
                DA_AddItemOption(itemName)
            end
        end
    end
end

-- 扫描所有背包（0 = 背包，1–4 = 背包栏）中可用的/消耗性物品
local function DA_ScanBagUsable()
    local bags = GetBagItems and GetBagItems()
    if not bags then return end

    local bag = 0
    while bag <= 4 do
        local contents = bags[bag]
        if contents then
            local slot, itemInfo
            for slot, itemInfo in pairs(contents) do
                local itemId = itemInfo and itemInfo.itemId
                if itemId then
                    local itemName = DA_GetItemInfoById(itemId)
                    if itemName then
                        DA_AddItemOption(itemName)
                    end
                end
            end
        end
        bag = bag + 1
    end
end

-- 查找特定物品名称的图标纹理（不区分大小写）
local function DA_FindItemTextureByName(itemName)
    if not itemName or itemName == "" then return nil end

    local target = string.lower(itemName)

    -- 1) 已装备的饰品和武器 (13,14,16,17,18)
    local slots = { 13, 14, 16, 17, 18 }
    local i
    for i = 1, table.getn(slots) do
        local slotId = slots[i]
        local info = GetEquippedItem and GetEquippedItem("player", slotId)
        local itemId = info and info.itemId
        if itemId then
            local tipName, tex = DA_GetItemInfoById(itemId)
            if tipName and string.lower(tipName) == target and tex then
                return tex
            end
        end
    end

    -- 2) 背包 (0–4)
    local bags = GetBagItems and GetBagItems()
    if not bags then return nil end

    local bag = 0
    while bag <= 4 do
        local contents = bags[bag]
        if contents then
            local slot, itemInfo
            for slot, itemInfo in pairs(contents) do
                local itemId = itemInfo and itemInfo.itemId
                if itemId then
                    local tipName, tex = DA_GetItemInfoById(itemId)
                    if tipName and string.lower(tipName) == target and tex then
                        return tex
                    end
                end
            end
        end
        bag = bag + 1
    end

    return nil
end

-- 辅助函数：在下一帧关闭并重新打开下拉框
local function DA_RepageItemDropdown()
    if not itemDropDown then return end
    local dd = itemDropDown

    if DA_RunLater then
        DA_RunLater(0.01, function()
            if dd then
                ToggleDropDownMenu(nil, nil, dd)
                ToggleDropDownMenu(nil, nil, dd)
            end
        end)
    else
        ToggleDropDownMenu(nil, nil, dd)
        ToggleDropDownMenu(nil, nil, dd)
    end
end

local function DA_ItemMenu_Initialize()
    if not itemDropDown then return end

    local total = table.getn(DA_ItemOptions)
    local info

    -- 上一页按钮
    if DA_ItemMenuOffset > 0 then
        info = {}
        info.text = "|cffffff00<< 上一页 <<|r"
        info.func = function()
            -- 向上翻一页，限制在 0
            local newOffset = DA_ItemMenuOffset - DA_ITEMMENU_PAGE_SIZE
            if newOffset < 0 then newOffset = 0 end
            DA_ItemMenuOffset = newOffset

            -- 用新页面重新打开下拉框
            DA_RepageItemDropdown()
        end
        -- 分页行不是真正的选项：无复选，无单选，保持未选中状态
        info.keepShownOnClick = 1
        info.notCheckable     = 1
        info.isNotRadio       = 1
        info.checked          = nil
        UIDropDownMenu_AddButton(info)
    end

    local startIndex = DA_ItemMenuOffset + 1
    local endIndex   = math.min(total, DA_ItemMenuOffset + DA_ITEMMENU_PAGE_SIZE)

    local i
    for i = startIndex, endIndex do
        local caption = DA_ItemOptions[i]
        info = {}
        info.text = caption
        info.func = function()
            UIDropDownMenu_SetText(caption, itemDropDown)
        end
        -- 正常条目：默认行为（选择+关闭）
        UIDropDownMenu_AddButton(info)
    end

    -- 下一页按钮
    if endIndex < total then
        info = {}
        info.text = "|cffffff00>> 下一页 >>|r"
        info.func = function()
            local total = table.getn(DA_ItemOptions)

            local maxOffset = 0
            if total > DA_ITEMMENU_PAGE_SIZE then
                maxOffset = total - DA_ITEMMENU_PAGE_SIZE
            end
            local newOffset = DA_ItemMenuOffset + DA_ITEMMENU_PAGE_SIZE
            if newOffset > maxOffset then newOffset = maxOffset end
            DA_ItemMenuOffset = newOffset

            DA_RepageItemDropdown()
        end
        info.keepShownOnClick = 1
        info.notCheckable     = 1
        info.isNotRadio       = 1
        info.checked          = nil
        UIDropDownMenu_AddButton(info)
    end
end

local function DA_RebuildItemDropDown()
    if not itemDropDown then return end

    -- 常量，用于保持各处一致的标题
    local HEADER_TRINKETS = "---已装备的饰品栏位---"
    local HEADER_WEAPONS  = "---已装备的武器栏位---"

    -- 1) 通过扫描将原始物品收集到 DA_ItemOptions
    DA_ClearItemOptions()
    DA_ScanEquippedUsable()
    DA_ScanBagUsable()

    -- 2) 分离并去重，然后对真实物品排序
    local seen  = {}
    local items = {}
    local i
    for i = 1, table.getn(DA_ItemOptions) do
        local nm = DA_ItemOptions[i]
        if nm and nm ~= "" then
            if not seen[nm] then
                seen[nm] = true
                -- 标题单独添加，因此这里跳过
                if nm ~= HEADER_TRINKETS and nm ~= HEADER_WEAPONS then
                    table.insert(items, nm)
                end
            end
        end
    end

    table.sort(items, function(a, b)
        local la = string.lower(a or "")
        local lb = string.lower(b or "")
        if la == lb then
            return (a or "") < (b or "")
        end
        return la < lb
    end)

    -- 3) 按最终显示顺序重建 DA_ItemOptions：
    --    先标题，然后排序后的物品
    DA_ClearItemOptions()
    DA_AddItemOption(HEADER_TRINKETS)
    DA_AddItemOption(HEADER_WEAPONS)
    for i = 1, table.getn(items) do
        DA_AddItemOption(items[i])
    end

    -- 4) 重置分页到顶部，并挂接自定义初始化器
    DA_ItemMenuOffset = 0
    UIDropDownMenu_Initialize(itemDropDown, DA_ItemMenu_Initialize)

    -- 每次重置显示的文本
    UIDropDownMenu_SetText("从下拉列表中选择", itemDropDown)
end

DA_HookDropDownButtonOnClick(itemDropDown, DA_RebuildItemDropDown)

-- 辅助函数：读取当前下拉框文本
local function DA_GetDropDownText(dd)
    if not dd or not dd.GetName then return nil end
    local n = dd:GetName()
    if not n then return nil end
    local fs = getglobal(n.."Text")
    if fs and fs.GetText then
        return fs:GetText()
    end
    return nil
end

-- 类型选择复选框
local currentType = "Ability"
local abilityCB, buffCB, debuffCB, itemsCB, barsCB, customCB

local function DA_UpdateTypeUI()
    if currentType == "Ability" then
        -- 技能：使用从法术书填充的下拉框（非被动）
        intro:SetText("从下拉列表中选择技能（来自法术书）。")
        input:Hide()
        if abilityDropDown then
            abilityDropDown:Show()
            -- 文本由 DA_RebuildAbilityDropDown 在需要时设置/重置
        end
        if itemDropDown then itemDropDown:Hide() end
        if barDropDown  then barDropDown:Hide()  end
        if addBtn then addBtn:Enable() end

    elseif currentType == "Buff" or currentType == "Debuff" then
        -- 增益/减益：手动文本输入
        intro:SetText("输入名称（通用名称匹配）或通过法术 ID（唯一）添加：")
        input:Show()
        if abilityDropDown then abilityDropDown:Hide() end
        if itemDropDown then itemDropDown:Hide() end
        if barDropDown  then barDropDown:Hide()  end
        if addBtn then addBtn:Enable() end

    elseif currentType == "Item" then
        intro:SetText("从下拉列表中选择物品。")
        input:Hide()
        if abilityDropDown then abilityDropDown:Hide() end
        if itemDropDown then
            itemDropDown:Show()
            UIDropDownMenu_SetText("从下拉列表中选择", itemDropDown)
        end
        if barDropDown then barDropDown:Hide() end
        if addBtn then addBtn:Enable() end

    elseif currentType == "Bar" then
        intro:SetText("从下拉列表中选择条状元素。")
        input:Hide()
        if abilityDropDown then abilityDropDown:Hide() end
        if barDropDown then
            barDropDown:Show()
            UIDropDownMenu_SetText("从下拉列表中选择", barDropDown)
        end
        if itemDropDown then itemDropDown:Hide() end
        if addBtn then addBtn:Enable() end

    elseif currentType == "Custom" then
        intro:SetText("输入自定义光环名称：")
        input:Show()
        if abilityDropDown then abilityDropDown:Hide() end
        if itemDropDown then itemDropDown:Hide() end
        if barDropDown  then barDropDown:Hide()  end
        if addBtn then addBtn:Enable() end
    end
end

abilityCB = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
abilityCB:SetWidth(20); abilityCB:SetHeight(20)
abilityCB:SetPoint("TOPLEFT", input, "BOTTOMLEFT", 0, -3)
abilityCB.text = abilityCB:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
abilityCB.text:SetPoint("LEFT", abilityCB, "RIGHT", 2, 0)
abilityCB.text:SetText("技能")

buffCB = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
buffCB:SetWidth(20); buffCB:SetHeight(20)
buffCB:SetPoint("TOPLEFT", input, "BOTTOMLEFT", 60, -3)
buffCB.text = buffCB:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
buffCB.text:SetPoint("LEFT", buffCB, "RIGHT", 2, 0)
buffCB.text:SetText("增益")

debuffCB = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
debuffCB:SetWidth(20); debuffCB:SetHeight(20)
debuffCB:SetPoint("TOPLEFT", input, "BOTTOMLEFT", 112, -3)
debuffCB.text = debuffCB:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
debuffCB.text:SetPoint("LEFT", debuffCB, "RIGHT", 2, 0)
debuffCB.text:SetText("减益")

-- 物品复选框
itemsCB = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
itemsCB:SetWidth(20); itemsCB:SetHeight(20)
itemsCB:SetPoint("TOPLEFT", input, "BOTTOMLEFT", 177, -3)
itemsCB.text = itemsCB:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
itemsCB.text:SetPoint("LEFT", itemsCB, "RIGHT", 2, 0)
itemsCB.text:SetText("物品")

-- 条复选框（在物品右侧）
barsCB = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
barsCB:SetWidth(20); barsCB:SetHeight(20)
barsCB:SetPoint("TOPLEFT", input, "BOTTOMLEFT", 230, -3)
barsCB.text = barsCB:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
barsCB.text:SetPoint("LEFT", barsCB, "RIGHT", 2, 0)
barsCB.text:SetText("条")

-- 自定义复选框（在条右侧）
customCB = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
customCB:SetWidth(20); customCB:SetHeight(20)
customCB:SetPoint("TOPLEFT", input, "BOTTOMLEFT", 275, -3)
customCB.text = customCB:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
customCB.text:SetPoint("LEFT", customCB, "RIGHT", 2, 0)
customCB.text:SetText("自定义")

abilityCB:SetScript("OnClick", function()
    DA_CancelRename()
    if DoiteAuras_RefreshList then pcall(DoiteAuras_RefreshList) end

    abilityCB:SetChecked(true)
    buffCB:SetChecked(false)
    debuffCB:SetChecked(false)
    if itemsCB then itemsCB:SetChecked(false) end
    if barsCB  then barsCB:SetChecked(false)  end
    if customCB then customCB:SetChecked(false) end
    currentType = "Ability"
    DA_UpdateTypeUI()
    -- 每次（重新）选择技能时重新扫描法术书（用于快速洗天赋）
    if DA_RebuildAbilityDropDown then
        DA_RebuildAbilityDropDown()
    end
end)

buffCB:SetScript("OnClick", function()
    DA_CancelRename()
    if DoiteAuras_RefreshList then pcall(DoiteAuras_RefreshList) end

    abilityCB:SetChecked(false)
    buffCB:SetChecked(true)
    debuffCB:SetChecked(false)
    if itemsCB then itemsCB:SetChecked(false) end
    if barsCB  then barsCB:SetChecked(false)  end
    if customCB then customCB:SetChecked(false) end
    currentType = "Buff"
    DA_UpdateTypeUI()
end)

debuffCB:SetScript("OnClick", function()
    DA_CancelRename()
    if DoiteAuras_RefreshList then pcall(DoiteAuras_RefreshList) end

    abilityCB:SetChecked(false)
    buffCB:SetChecked(false)
    debuffCB:SetChecked(true)
    if itemsCB then itemsCB:SetChecked(false) end
    if barsCB  then barsCB:SetChecked(false)  end
    if customCB then customCB:SetChecked(false) end
    currentType = "Debuff"
    DA_UpdateTypeUI()
end)

itemsCB:SetScript("OnClick", function()
    DA_CancelRename()
    if DoiteAuras_RefreshList then pcall(DoiteAuras_RefreshList) end

    if not itemsCB:GetChecked() then
        -- 防止“未选择任何项”：如果当前类型是物品，则保持选中
        if currentType == "Item" then
            itemsCB:SetChecked(true)
            return
        end
    end

    abilityCB:SetChecked(false)
    buffCB:SetChecked(false)
    debuffCB:SetChecked(false)
    itemsCB:SetChecked(true)
    if barsCB then barsCB:SetChecked(false) end
    if customCB then customCB:SetChecked(false) end

    currentType = "Item"
    DA_UpdateTypeUI()

    -- 从背包和已装备物品构建/刷新下拉框
    DA_RebuildItemDropDown()
end)

barsCB:SetScript("OnClick", function()
    DA_CancelRename()
    if DoiteAuras_RefreshList then pcall(DoiteAuras_RefreshList) end

    if not barsCB:GetChecked() then
        if currentType == "Bar" then
            barsCB:SetChecked(true)
            return
        end
    end

    abilityCB:SetChecked(false)
    buffCB:SetChecked(false)
    debuffCB:SetChecked(false)
    if itemsCB then itemsCB:SetChecked(false) end
    if customCB then customCB:SetChecked(false) end
    barsCB:SetChecked(true)
    currentType = "Bar"
    DA_UpdateTypeUI()
    DA_RebuildBarDropDown()
end)

customCB:SetScript("OnClick", function()
    DA_CancelRename()
    if DoiteAuras_RefreshList then pcall(DoiteAuras_RefreshList) end

    if not customCB:GetChecked() then
        if currentType == "Custom" then
            customCB:SetChecked(true)
            return
        end
    end

    abilityCB:SetChecked(false)
    buffCB:SetChecked(false)
    debuffCB:SetChecked(false)
    if itemsCB then itemsCB:SetChecked(false) end
    if barsCB then barsCB:SetChecked(false) end
    customCB:SetChecked(true)
    currentType = "Custom"
    DA_UpdateTypeUI()
end)

frame:SetScript("OnShow", function()
    abilityCB:SetChecked(true)
    buffCB:SetChecked(false)
    debuffCB:SetChecked(false)
    if itemsCB then itemsCB:SetChecked(false) end
    if barsCB  then barsCB:SetChecked(false)  end
    if customCB then customCB:SetChecked(false) end
    currentType = "Ability"
    DA_UpdateTypeUI()
    -- 打开（/da 或小地图）时，从当前法术书重建技能下拉框
    if DA_RebuildAbilityDropDown then
        DA_RebuildAbilityDropDown()
    end
    if testAllBtn and _DA_UpdateTestAllButton then
        _DA_UpdateTestAllButton()
    end
end)

frame:SetScript("OnHide", function()
    DA_CancelRename()

    -- 当主 DoiteAuras 框架隐藏时，强制关闭导入/导出/设置窗口
    local f

    f = _G["DoiteAurasImportFrame"]
    if f and f.Hide then f:Hide() end

    f = _G["DoiteAurasExportFrame"]
    if f and f.Hide then f:Hide() end

    f = _G["DoiteAurasSettingsFrame"]
    if f and f.Hide then f:Hide() end
end)

-- 可滚动容器
local listContainer = CreateFrame("Frame", nil, frame)
listContainer:SetWidth(330)
listContainer:SetHeight(260)
listContainer:SetPoint("TOPLEFT", input, "BOTTOMLEFT", -5, -25)
listContainer:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16 })
listContainer:SetBackdropColor(0,0,0,0.7)

local scrollFrame = CreateFrame("ScrollFrame", "DoiteAurasScroll", listContainer, "UIPanelScrollFrameTemplate")
-- 稍宽并更靠近边框，使其感觉不那么“内凹”
scrollFrame:SetWidth(320)
scrollFrame:SetHeight(250)
scrollFrame:SetPoint("TOPLEFT", listContainer, "TOPLEFT", 5, -5)

local listContent = CreateFrame("Frame", "DoiteAurasListContent", scrollFrame)
listContent:SetWidth(320)
listContent:SetHeight(252)
scrollFrame:SetScrollChild(listContent)

-- 全部测试按钮（切换）
local testAllBtn = CreateFrame("Button", "DoiteAurasTestAllBtn", frame, "UIPanelButtonTemplate")
testAllBtn:SetWidth(80)
testAllBtn:SetHeight(18)
testAllBtn:SetPoint("TOPLEFT", listContainer, "BOTTOMLEFT", 0, -4)

local function _DA_UpdateTestAllButton()
    if _G["DoiteAuras_TestAll"] == true then
        testAllBtn:SetText("停止测试")
    else
        testAllBtn:SetText("全部测试")
    end
end

testAllBtn:SetScript("OnClick", function()
    if _G["DoiteAuras_TestAll"] == true then
        _G["DoiteAuras_TestAll"] = nil
    else
        _G["DoiteAuras_TestAll"] = true
    end
    _DA_UpdateTestAllButton()
    if DoiteConditions_RequestEvaluate then
        DoiteConditions_RequestEvaluate()
    end
    if DoiteGroup and DoiteGroup.RequestReflow then
        DoiteGroup.RequestReflow()
    else
        _G["DoiteGroup_NeedReflow"] = true
    end
    if DoiteAuras_RefreshIcons then
        pcall(DoiteAuras_RefreshIcons)
    end
end)

_DA_UpdateTestAllButton()

-- 指南文本
local guide = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
guide:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 20, 20)
guide:SetWidth(345)
guide:SetJustifyH("LEFT")
if guide.SetTextColor then guide:SetTextColor(0.7,0.7,0.7) end
guide:SetText("指南：DoiteAuras 仅在你真正需要时显示重要的内容——技能、增益、减益、物品或条状元素。添加一个图标或条，选择其类型，并使用简单的条件（如冷却时间、光环状态、战斗状态或目标）定义其出现时机。所有内容都会自动更新，一旦见过便会记住纹理，保持你的界面整洁且响应迅速。")

-- 存储
local spellButtons, icons, groupHeaders = {}, {}, {}
renameState = {
    key = nil,
    original = nil,
}

DA_GetSpellIdShownName = function(spellIdStr)
    if not spellIdStr or spellIdStr == "" then return nil end

    local resolvedSpellName = nil
    local resolvedSpellRank = nil

    if type(GetSpellNameAndRankForId) == "function" then
        local ok, sn, sr = pcall(GetSpellNameAndRankForId, tonumber(spellIdStr))
        if ok and sn and sn ~= "" then
            resolvedSpellName = tostring(sn)
            if sr and sr ~= "" then
                resolvedSpellRank = tostring(sr)
            end
        end
    end

    if resolvedSpellName then
        if resolvedSpellRank then
            return resolvedSpellName .. " [" .. resolvedSpellRank .. "] - ID: " .. spellIdStr
        end
        return resolvedSpellName .. " - ID: " .. spellIdStr
    end

    return "法术 ID: " .. spellIdStr .. "（将在看到时更新）"
end

DA_ClearRenameState = function()
    renameState.key = nil
    renameState.original = nil
end

DA_CancelRename = function()
    local key = renameState.key
    if key and DoiteAurasDB and DoiteAurasDB.spells and DoiteAurasDB.spells[key] then
        DoiteAurasDB.spells[key].shownName = renameState.original
    end
    DA_ClearRenameState()
end

DA_IsRenameNameDuplicate = function(currentKey, txt)
    if not txt or txt == "" or not DoiteAurasDB or not DoiteAurasDB.spells then
        return false
    end
    local k, d
    for k, d in pairs(DoiteAurasDB.spells) do
        if k ~= currentKey and d then
            local otherShown = d.shownName
            if otherShown and otherShown == txt then
                return true
            end
            local otherDisplay = d.displayName or d.name
            if otherDisplay and otherDisplay == txt then
                return true
            end
        end
    end
    return false
end

function DA_RenameTrim(txt)
    txt = txt or ""
    txt = string.gsub(txt, "^%s+", "")
    txt = string.gsub(txt, "%s+$", "")
    return txt
end

function DA_RenameUpdateAddState(row)
    if not row or not row.renameInput or not row.renameAddBtn then return end
    local key = row.daKey
    local txt = DA_RenameTrim(row.renameInput:GetText() or "")
    if txt == "" or DA_IsRenameNameDuplicate(key, txt) then
        row.renameAddBtn:Disable()
    else
        row.renameAddBtn:Enable()
    end
end

function DA_RenameOnTextChanged()
    local row = this and this:GetParent()
    DA_RenameUpdateAddState(row)
end

function DA_RenameStart()
    local row = this and this:GetParent()
    if not row then return end
    local key = row.daKey
    if not key or not DoiteAurasDB or not DoiteAurasDB.spells then return end
    local data = DoiteAurasDB.spells[key]
    if not data then return end

    DA_CancelRename()
    renameState.key = key
    renameState.original = data.shownName

    if row.renameInput then
        row.renameInput:SetText(data.shownName or data.displayName or data.name or "")
        row.renameInput:Show()
        row.renameInput:SetFocus()
    end
    if row.renameAddBtn then row.renameAddBtn:Show() end
    if row.renameResetBtn then row.renameResetBtn:Show() end
    if row.renameBackBtn then row.renameBackBtn:Show() end

    DA_RenameUpdateAddState(row)
    if DoiteAuras_RefreshList then pcall(DoiteAuras_RefreshList) end
end

function DA_RenameBack()
    DA_CancelRename()
    if DoiteAuras_RefreshList then pcall(DoiteAuras_RefreshList) end
end

function DA_RenameReset()
    local row = this and this:GetParent()
    if not row then return end
    local key = row.daKey
    local data = key and DoiteAurasDB and DoiteAurasDB.spells and DoiteAurasDB.spells[key]
    if not data then return end

    if data.Addedviaspellid == true and data.spellid and data.spellid ~= "" then
        data.shownName = DA_GetSpellIdShownName(tostring(data.spellid))
    else
        data.shownName = nil
    end

    DA_ClearRenameState()
    if DoiteAuras_RefreshList then pcall(DoiteAuras_RefreshList) end
    if DoiteAuras_RefreshIcons then pcall(DoiteAuras_RefreshIcons, true) end
    if DoiteConditions_RequestEvaluate then
        DoiteConditions_RequestEvaluate()
    end
end

function DA_RenameAdd()
    local row = this and this:GetParent()
    if not row then return end
    local key = row.daKey
    local data = key and DoiteAurasDB and DoiteAurasDB.spells and DoiteAurasDB.spells[key]
    if not data then return end

    local txt = DA_RenameTrim(row.renameInput and row.renameInput:GetText() or "")
    if txt == "" then return end
    if DA_IsRenameNameDuplicate(key, txt) then return end

    data.shownName = txt
    DA_ClearRenameState()
    if DoiteAuras_RefreshList then pcall(DoiteAuras_RefreshList) end
    if DoiteAuras_RefreshIcons then pcall(DoiteAuras_RefreshIcons, true) end
    if DoiteConditions_RequestEvaluate then
        DoiteConditions_RequestEvaluate()
    end
end

function DoiteAuras_GetIconFrame(key)
    if not key then return nil end
    local f = icons and icons[key]
    if f then return f end

    f = _G["DoiteIcon_" .. key]
    if f and icons then
        icons[key] = f
    end
    return f
end

-- 辅助函数
local function GetOrderedSpells()
    local list = {}
    for key, data in pairs(DoiteAurasDB.spells) do
        table.insert(list, { key = key, data = data, order = data.order or 999 })
    end
    table.sort(list, function(a, b) return a.order < b.order end)
    return list
end

-- 一个共享的比较器
if DoiteAuras and not DoiteAuras._cmpSpellKeyByOrder then
    DoiteAuras._cmpSpellKeyByOrder = function(a, b)
        local da = DoiteAurasDB.spells[a]
        local db = DoiteAurasDB.spells[b]
        local oa = (da and da.order) or 999
        local ob = (db and db.order) or 999
        return oa < ob
    end
end

-- 用于组感知列表构建和移动的小辅助函数
local function DA_IsGrouped(data)
    if not data then return false end
    if not data.group or data.group == "" or data.group == "no" then return false end
    return true
end

local function DA_ParseGroupIndex(groupName)
    if not groupName or type(groupName) ~= "string" then return 9999 end
    local _, _, num = string.find(groupName, "[Gg]roup%s*(%d+)")
    if num then
        local n = tonumber(num)
        if n then return n end
    end
    return 9999
end

-- 未分组图标的类别辅助函数（与 DoiteEdit 共享）
local function DA_GetCategoryForEntry(entry)
    if not entry or not entry.data then return nil end
    local d = entry.data

    -- 优先使用 DoiteAuras 法术数据本身存储的类别
    local cat = d.category

    -- 备选：如果存在，查看遗留的 DoiteDB.icons
    if (not cat or cat == "" or cat == "no") and DoiteDB and DoiteDB.icons and DoiteDB.icons[entry.key] then
        cat = DoiteDB.icons[entry.key].category
    end

    if cat and cat ~= "" and cat ~= "no" then
        return tostring(cat)
    end
    if d.type == "Bar" then
        return "BARS"
    end
    return nil
end

-- 每组排序模式辅助函数（"prio" 或 "time"，默认为 "prio"）
local function DA_GetGroupSortMode(groupName)
    if not DoiteAurasDB then DoiteAurasDB = {} end
    DoiteAurasDB.groupSort = DoiteAurasDB.groupSort or {}

    if not groupName or groupName == "" then
        return "prio"
    end

    local mode = DoiteAurasDB.groupSort[groupName]
    if mode ~= "time" then
        mode = "prio"
    end
    DoiteAurasDB.groupSort[groupName] = mode
    return mode
end

-- 每桶（组、类别、未分组）禁用的共享辅助函数
local function DA_GetBucketKeyForHeaderEntry(entry)
    if not entry then return nil end
    if entry.kind == "group" then
        return entry.groupName
    elseif entry.kind == "category" then
        return entry.groupName
    elseif entry.kind == "ungrouped" then
        return "Ungrouped"
    end
    return nil
end

local function DA_GetBucketKeyForCandidate(entry)
    if not entry or not entry.data then return nil end
    local d = entry.data

    -- 已分组的条目：桶是组名。
    if DA_IsGrouped(d) then
        return d.group
    end

    -- 未分组：使用与 DA_BuildDisplayList 相同的类别逻辑。
    local dummy = { key = entry.key, data = d }
    local cat = DA_GetCategoryForEntry(dummy)
    if cat and cat ~= "" then
        return cat
    end

    -- 纯未分组
    return "Ungrouped"
end

local function DA_IsBucketDisabled(bucketKey)
    if not bucketKey then return false end
    if not DoiteAurasDB or not DoiteAurasDB.bucketDisabled then return false end
    return DoiteAurasDB.bucketDisabled[bucketKey] == true
end

-- 手风琴折叠辅助函数
local function DA_IsBucketCollapsed(bucketKey)
    if not bucketKey then return false end
    DoiteAurasDB.bucketCollapsed = DoiteAurasDB.bucketCollapsed or {}
    return DoiteAurasDB.bucketCollapsed[bucketKey] == true
end

local function DA_SetBucketCollapsed(bucketKey, collapsed)
    if not bucketKey then return end
    DoiteAurasDB.bucketCollapsed = DoiteAurasDB.bucketCollapsed or {}
    if collapsed then
        DoiteAurasDB.bucketCollapsed[bucketKey] = true
    else
        DoiteAurasDB.bucketCollapsed[bucketKey] = nil
    end
end

local function DoiteAuras_IsKeyDisabled(key)
    if not key or not DoiteAurasDB or not DoiteAurasDB.spells then return false end
    local data = DoiteAurasDB.spells[key]
    if not data then return false end

    -- 重用现有桶逻辑
    local entry = { key = key, data = data }
    local bucketKey = DA_GetBucketKeyForCandidate(entry)
    if not bucketKey then return false end

    return DA_IsBucketDisabled(bucketKey)
end
_G["DoiteAuras_IsKeyDisabled"] = DoiteAuras_IsKeyDisabled

local function DA_BuildDisplayList(ordered)
    local groupedByName      = {}
    local groupOrderList     = {}
    local categorizedByName  = {}
    local categoryOrderList  = {}
    local ungrouped          = {}

    local i
    for i = 1, table.getn(ordered) do
        local entry = ordered[i]
        local d     = entry.data
        if DA_IsGrouped(d) then
            local g = d.group
            if not groupedByName[g] then
                groupedByName[g] = {}
                table.insert(groupOrderList, g)
            end
            table.insert(groupedByName[g], entry)
        else
            -- 未分组：拆分为类别和纯未分组
            local cat = DA_GetCategoryForEntry(entry)
            if cat then
                if not categorizedByName[cat] then
                    categorizedByName[cat] = {}
                    table.insert(categoryOrderList, cat)
                end
                table.insert(categorizedByName[cat], entry)
            else
                table.insert(ungrouped, entry)
            end
        end
    end

    -- 尽可能按 "Group N" 数字索引排序组，否则按名称
    table.sort(groupOrderList, function(a, b)
        local ia = DA_ParseGroupIndex(a)
        local ib = DA_ParseGroupIndex(b)
        if ia ~= ib then
            return ia < ib
        end
        return tostring(a or "") < tostring(b or "")
    end)

    -- 按 0–9 A–Z 顺序排序类别（不区分大小写）
    table.sort(categoryOrderList, function(a, b)
        local la = string.lower(a or "")
        local lb = string.lower(b or "")
        if la == lb then
            return (a or "") < (b or "")
        end
        return la < lb
    end)

    -- 为类别 + 未分组打上每桶索引/总数
    local _, catName
    for _, catName in ipairs(categoryOrderList) do
        local list = categorizedByName[catName]
        local n = table.getn(list or {})
        local j
        for j = 1, n do
            local e = list[j]
            e._bucketName  = catName
            e._bucketIndex = j
            e._bucketTotal = n
        end
    end

    local unTotal = table.getn(ungrouped)
    if unTotal > 0 then
        local j
        for j = 1, unTotal do
            local e = ungrouped[j]
            e._bucketName  = "Ungrouped"
            e._bucketIndex = j
            e._bucketTotal = unTotal
        end
    end

    local display = {}

    local _, groupName
    for _, groupName in ipairs(groupOrderList) do
        table.insert(display, { isHeader = true, groupName = groupName, kind = "group" })

        -- 手风琴：仅当未折叠时才添加成员
        if not DA_IsBucketCollapsed(groupName) then
            local list = groupedByName[groupName]
            local j
            for j = 1, table.getn(list) do
                table.insert(display, list[j])
            end
        end
    end

    for _, catName in ipairs(categoryOrderList) do
        table.insert(display, { isHeader = true, groupName = catName, kind = "category" })

        -- 手风琴：仅当未折叠时才添加成员
        if not DA_IsBucketCollapsed(catName) then
            local list = categorizedByName[catName]
            local j
            for j = 1, table.getn(list) do
                table.insert(display, list[j])
            end
        end
    end

    local showUngroupedHeader = false
    if unTotal > 0 and (table.getn(groupOrderList) > 0 or table.getn(categoryOrderList) > 0) then
        showUngroupedHeader = true
    end

    if showUngroupedHeader then
        table.insert(display, { isHeader = true, groupName = "未分组/未分类", kind = "ungrouped" })
    end

    -- 未分组桶的手风琴键
    local unKey = "Ungrouped"

    -- 仅当未折叠时才添加未分组条目
    if not (showUngroupedHeader and DA_IsBucketCollapsed(unKey)) then
        local j
        for j = 1, unTotal do
            table.insert(display, ungrouped[j])
        end
    end

    return display
end

-- 仅在其组内移动条目；如果发生交换则返回 true
local function DA_MoveOrderWithinGroup(key, direction)
    local data = DoiteAurasDB.spells[key]
    if not DA_IsGrouped(data) then return false end

    local grp = data.group
    local ordered = GetOrderedSpells()
    local groupMembers = {}
    local i

    -- 按 order[] 收集该组的所有成员
    for i = 1, table.getn(ordered) do
        local e = ordered[i]
        if e.data and e.data.group == grp then
            table.insert(groupMembers, e)
        end
    end

    local idx = nil
    local n   = table.getn(groupMembers)
    for i = 1, n do
        if groupMembers[i].key == key then
            idx = i
            break
        end
    end
    if not idx then return false end

    if direction == "up" then
        -- 向组的开始移动
        if idx <= 1 then return false end
        local swapKey = groupMembers[idx - 1].key
        local tmp = DoiteAurasDB.spells[key].order
        DoiteAurasDB.spells[key].order     = DoiteAurasDB.spells[swapKey].order
        DoiteAurasDB.spells[swapKey].order = tmp
        return true

    elseif direction == "down" then
        -- 向组的结束移动
        if idx >= n then return false end
        local swapKey = groupMembers[idx + 1].key
        local tmp = DoiteAurasDB.spells[key].order
        DoiteAurasDB.spells[key].order     = DoiteAurasDB.spells[swapKey].order
        DoiteAurasDB.spells[swapKey].order = tmp
        return true
    end

    return false
end

-- 仅在其类别桶（或纯未分组）内移动未分组条目
local function DA_MoveOrderWithinCategoryOrUngrouped(key, direction)
    if not key then return false end
    local data = DoiteAurasDB.spells[key]
    if not data or DA_IsGrouped(data) then return false end

    -- 确定此条目的桶名称：其类别或 "Ungrouped"
    local dummyEntry = { key = key, data = data }
    local cat = DA_GetCategoryForEntry(dummyEntry)
    local bucketName = cat or "Ungrouped"

    local ordered = GetOrderedSpells()
    local bucket = {}
    local i

    -- 收集所有共享同一桶的未分组条目
    for i = 1, table.getn(ordered) do
        local e = ordered[i]
        local d = e.data
        if d and not DA_IsGrouped(d) then
            local bc = DA_GetCategoryForEntry(e)
            local bname = bc or "Ungrouped"
            if bname == bucketName then
                table.insert(bucket, e)
            end
        end
    end

    local idx, n = nil, table.getn(bucket)
    for i = 1, n do
        if bucket[i].key == key then
            idx = i
            break
        end
    end
    if not idx then return false end

    if direction == "up" then
        if idx <= 1 then return false end
        local swapKey = bucket[idx - 1].key
        local tmp = DoiteAurasDB.spells[key].order
        DoiteAurasDB.spells[key].order     = DoiteAurasDB.spells[swapKey].order
        DoiteAurasDB.spells[swapKey].order = tmp
        return true

    elseif direction == "down" then
        if idx >= n then return false end
        local swapKey = bucket[idx + 1].key
        local tmp = DoiteAurasDB.spells[key].order
        DoiteAurasDB.spells[key].order     = DoiteAurasDB.spells[swapKey].order
        DoiteAurasDB.spells[swapKey].order = tmp
        return true
    end

    return false
end

-- 限制 RefreshIcons() 以避免递归布局覆盖
local _lastRefresh = 0
local function _CanRunRefresh()
    local now = GetTime and GetTime() or 0
    if now - _lastRefresh < 0.1 then return false end
    _lastRefresh = now
    return true
end

local function RebuildOrder()
    local ordered = GetOrderedSpells()
    for i=1, table.getn(ordered) do DoiteAurasDB.spells[ordered[i].key].order = i end
end

local function FindSpellBookSlot(spellName)
    if not spellName or spellName == "" then return nil end

    -- 当可用时，优先使用 Nampower 快速查找
    if type(GetSpellSlotTypeIdForName) == "function" then
        local ok, slot, bookType = pcall(GetSpellSlotTypeIdForName, spellName)
        if ok and slot and slot > 0 and (bookType == "spell" or bookType == "pet" or bookType == "unknown") then
            if bookType == "pet" then
                return slot, BOOKTYPE_PET
            end
            return slot, BOOKTYPE_SPELL
        end
    end

    -- 备选：旧版完整法术书扫描（有 Nampower 时几乎不会运行）
    if not GetNumSpellTabs or not GetSpellTabInfo or not GetSpellName then
        return nil
    end

    for tab = 1, (GetNumSpellTabs() or 0) do
        local _, _, offset, numSlots = GetSpellTabInfo(tab)
        if numSlots and numSlots > 0 then
            for i = 1, numSlots do
                local idx  = offset + i
                local name = GetSpellName(idx, BOOKTYPE_SPELL)
                if name == spellName then
                    return idx, BOOKTYPE_SPELL
                end
            end
        end
    end

    -- 备选宠物法术书扫描
    local p = 1
    while true do
        local name = GetSpellName(p, BOOKTYPE_PET)
        if not name then break end
        if name == spellName then
            return p, BOOKTYPE_PET
        end
        p = p + 1
    end

    return nil
end

-- 辅助函数：按名称使用物品，扫描背包/装备栏
local function DA_UseItemByName(itemName)
    if not itemName or itemName == "" then return end
    if UseItemIdOrName and UseItemIdOrName(itemName) == 1 then
        return true
    end
    if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("DoiteAuras: 物品 [" .. itemName .. "] 在背包或物品栏中未找到。") end
end

local function DA_ShowDetailedItemTooltip(frame, itemName)
    if not itemName or itemName == "" then return end

    -- 智能锚点：选择一个方向使工具提示保持在屏幕上
    local anchor = "ANCHOR_RIGHT"
    if frame.GetCenter and UIParent.GetWidth then
        local cx, cy = frame:GetCenter()
        local sw = UIParent:GetWidth()
        local sh = UIParent:GetHeight()
        if cx and sw and cy and sh then
            local rightEdge = cx > (sw * 0.75)
            local topEdge   = cy > (sh * 0.75)
            if rightEdge and topEdge then
                anchor = "ANCHOR_BOTTOMLEFT"
            elseif rightEdge then
                anchor = "ANCHOR_LEFT"
            elseif topEdge then
                anchor = "ANCHOR_BOTTOM"
            end
        end
    end

    GameTooltip:SetOwner(frame, anchor)

    -- 1) 首先使用 Nampower 物品位置查找（已装备或背包）
    if FindPlayerItemSlot then
        local bag, slot = FindPlayerItemSlot(itemName)
        if slot then
            if bag == nil then
                GameTooltip:SetInventoryItem("player", slot)
                GameTooltip:Show()
                return
            elseif bag >= 0 and bag <= 4 then
                GameTooltip:SetBagItem(bag, slot)
                GameTooltip:Show()
                return
            end
        end
    end

    -- 2) 如果物品当前未持有，回退到基本信息
    local _, link = GetItemInfo(itemName)
    if link then
        GameTooltip:SetHyperlink(link)
    else
        GameTooltip:AddLine(itemName)
    end
    GameTooltip:Show()
end

-- 创建或更新图标 *仅结构*（此处不进行定位或纹理更改）
local function CreateOrUpdateIcon(key, layer)
    local globalName = "DoiteIcon_" .. key
    local f = _G[globalName]
    if not f then
        f = CreateFrame("Button", globalName, UIParent)
        f:SetFrameStrata("MEDIUM")
        -- 默认尺寸；实际尺寸在 RefreshIcons 中应用
        f:SetWidth(36)
        f:SetHeight(36)
        f:EnableMouse(false)  -- 编辑此图标时将启用
        f:SetMovable(true)    -- 拖动时允许移动
        f:RegisterForDrag("LeftButton")
        f:RegisterForClicks("LeftButtonUp", "RightButtonUp")

        -- 图标纹理（创建一次）
        f.icon = f:CreateTexture(nil, "BACKGROUND")
        f.icon:SetAllPoints(f)

        -- 如果启用，应用 pfUI 边框
        if DoiteAurasDB.pfuiBorder then
            DA_ApplyPfUIBorder(f)
        end

        -- 可选计数文本（创建一次）
        local fs = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        fs:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -2, 2)
        fs:SetText("")
        f.count = fs

        -- 为拖动处理程序存储键
        f._daKey = key

        -- 拖动开始处理程序（仅在编辑模式下活动）
        f:SetScript("OnDragStart", function()
            local frameKey = this._daKey
            local editKey = _G["DoiteEdit_CurrentKey"]

            -- 仅当此图标正在被编辑时才允许拖动
            if not editKey or editKey ~= frameKey then
                return
            end

            -- 检查这是否是组成员（非组长）- 不允许拖动
            local data = DoiteAurasDB and DoiteAurasDB.spells and DoiteAurasDB.spells[frameKey]
            if data and data.group and data.group ~= "" and data.group ~= "No" then
                if not data.isLeader then
                    -- 显示工具提示提示而不是拖动
                    GameTooltip:SetOwner(this, "ANCHOR_TOP")
                    GameTooltip:AddLine("拖动组组长来移动此组", 1, 0.8, 0)
                    GameTooltip:Show()
                    return
                end
            end

            -- 开始拖动（MoveAnything 风格：纯 StartMoving + 标志）
            _G["DoiteUI_Dragging"] = true
            this:StartMoving()
            this._daDragging = true
        end)

        -- 拖动停止处理程序
        f:SetScript("OnDragStop", function()
            this:StopMovingOrSizing()
            this._daDragging = nil
            _G["DoiteUI_Dragging"] = false
            GameTooltip:Hide()

            local frameKey = this._daKey

            -- 仅在有效键时保存
            if not frameKey then return end

            -- MoveAnything 坐标公式：
            -- 精确的屏幕中心偏差，按框架缩放归一化。

            -- 1. 屏幕中心（参考）
            local rScale = UIParent:GetEffectiveScale()
            local rX, rY = UIParent:GetCenter()
            rX, rY = rX * rScale, rY * rScale

            -- 2. 框架中心（目标）
            local pScale = this:GetEffectiveScale()
            local pX, pY = this:GetCenter()
            pX, pY = pX * pScale, pY * pScale

            -- 3. 偏移量 = (框架 - 屏幕) / 框架缩放
            local x = (pX - rX) / pScale
            local y = (pY - rY) / pScale

            -- 四舍五入以使数据库更整洁
            x = math.floor(x * 10 + 0.5) / 10
            y = math.floor(y * 10 + 0.5) / 10

            -- 更新数据库
            local data = DoiteAurasDB and DoiteAurasDB.spells and DoiteAurasDB.spells[frameKey]
            if data then
                data.point = "CENTER"
                data.relativePoint = "CENTER"
                data.offsetX = x
                data.offsetY = y
            end

            -- 同步滑块
            if DoiteEdit_SyncSlidersToPosition then
                DoiteEdit_SyncSlidersToPosition(frameKey, x, y)
            end

            if DoiteEdit_FlushHeavy then
                DoiteEdit_FlushHeavy()
            end

            -- 强制重新计算组布局，以便追随者立即捕捉到新组长位置
            if DoiteGroup and DoiteGroup.RequestReflow then
                DoiteGroup.RequestReflow()
            end
        end)
    end

    -- 精确包装 Show() 一次，使桶禁用始终胜出
    if not f._daOrigShow then
        f._daOrigShow = f.Show
        f._daOrigHide = f.Hide

        f.Show = function(self)
            local blocked = false
            if DoiteAuras_IsKeyDisabled then
                blocked = DoiteAuras_IsKeyDisabled(key)
            end

            if blocked then
                -- 即使有人试图显示，也强制隐藏
                if self._daOrigHide then
                    self._daOrigHide(self)
                else
                    self:Hide()
                end
                return
            end

            if self._daOrigShow then
                self._daOrigShow(self)
            end
        end
    end

    -- 仅当此图标正在被编辑时才启用鼠标
    local editKey = _G["DoiteEdit_CurrentKey"]
    if editKey and editKey == key then
        f:EnableMouse(true)
    else
        f:EnableMouse(false)
    end

    -- 本地缓存
    icons[key] = f
    if layer then f:SetFrameLevel(layer) end

    return f
end

-- 刷新图标（组感知）
-- 默认值的轻量级初始化（简化自 DoiteEdit EnsureDBEntry）
-- 确保关键数据结构（如条件表）在启动时存在
local function EnsureDefaults(key)
    if not DoiteAurasDB.spells[key] then return end
    local d = DoiteAurasDB.spells[key]

    -- 结构必须存在
    if not d.conditions then d.conditions = {} end

    if d.type == "Item" then
        if not d.conditions.item then d.conditions.item = {} end
        -- 注意：不要强制将 'clickable' 设为 true，尊重保存的值（或 nil）。
        -- 仅确保表存在，以便检查如 'd.conditions.item.clickable' 不会崩溃或使逻辑失败。
    elseif d.type == "Ability" then
        if not d.conditions.ability then d.conditions.ability = {} end
    end
end

local function RefreshIcons(force)
    if DA_IsHardDisabled() then
        -- 确保所有现有图标框架保持隐藏
        if icons then
            for _, f in pairs(icons) do
                if f and f.Hide then f:Hide() end
            end
        end
        return
    end
    if not _CanRunRefresh(force) then return end

    -- 编辑时，强制被编辑的键可见，以便始终可靠显示。
    local editKey   = _G["DoiteEdit_CurrentKey"]
    local editFrame = _G["DoiteEdit_Frame"] or _G["DoiteEditMain"] or _G["DoiteEdit"]
    local editOpen  = (editFrame and editFrame.IsShown and editFrame:IsShown() == 1)
    local testAll   = (_G["DoiteAuras_TestAll"] == true)
    -- 按 "order" 构建排序键列表，无需每次刷新分配 {key,data,order} 表。
    local keyList = DoiteAuras._orderedKeyList
    if not keyList then
        keyList = {}
        DoiteAuras._orderedKeyList = keyList
    end

    local oldKeyN = table.getn(keyList)
    local total = 0
    for key in pairs(DoiteAurasDB.spells) do
        total = total + 1
        keyList[total] = key
    end
    for i = total + 1, oldKeyN do
        keyList[i] = nil
    end

    if DoiteAuras._cmpSpellKeyByOrder then
        table.sort(keyList, DoiteAuras._cmpSpellKeyByOrder)
    else
        -- 备选（如果补丁 1 未应用，不应发生）
        table.sort(keyList, function(a, b)
            local da = DoiteAurasDB.spells[a]
            local db = DoiteAurasDB.spells[b]
            local oa = (da and da.order) or 999
            local ob = (db and db.order) or 999
            return oa < ob
        end)
    end

    -- 候选 + 池（仅内部使用）以避免每次刷新分配表
    local candidates = DoiteAuras._refreshCandidates
    if not candidates then
        candidates = {}
        DoiteAuras._refreshCandidates = candidates
    end
    local pool = DoiteAuras._refreshCandidatePool
    if not pool then
        pool = {}
        DoiteAuras._refreshCandidatePool = pool
    end

    local oldN = table.getn(candidates)
    local n = 0

    -- 缓存表稳定；避免每次条目都调用 DA_Cache()
    local cache = DA_Cache()

    -- 按 displayName 缓存法术书槽位（通过 _daSpellTex 在 SPELLS_CHANGED 时清除）
    local slotCache = DoiteAuras._spellSlotCache
    if not slotCache then
        slotCache = {}
        DoiteAuras._spellSlotCache = slotCache
    end

    -- 构建组长映射，以便组内追随者可以继承组长尺寸并具有合理的临时锚点
    local leaderSizeByGroup = DoiteAuras._leaderSizeByGroup
    if not leaderSizeByGroup then
        leaderSizeByGroup = {}
        DoiteAuras._leaderSizeByGroup = leaderSizeByGroup
    else
        local k
        for k in pairs(leaderSizeByGroup) do
            leaderSizeByGroup[k] = nil
        end
    end

    local leaderPosByGroup = DoiteAuras._leaderPosByGroup
    if not leaderPosByGroup then
        leaderPosByGroup = {}
        DoiteAuras._leaderPosByGroup = leaderPosByGroup
    else
        local k
        for k in pairs(leaderPosByGroup) do
            leaderPosByGroup[k] = nil
        end
    end

    for i = 1, total do
        local key  = keyList[i]
        local data = DoiteAurasDB.spells[key]
        if data and data.group and data.group ~= "" and data.group ~= "no" and data.isLeader == true then
            leaderSizeByGroup[data.group] = (data.iconSize or data.size) or 36

            local lx = (data.offsetX) or 0
            local ly = (data.offsetY) or 0
            leaderPosByGroup[data.group] = { x = lx, y = ly }
        end
    end

    -- 第 1 步：收集轻量级图标状态（无需额外战斗逻辑 – DoiteConditions 拥有该逻辑）
    for i = 1, total do
        local key  = keyList[i]

        -- 确保默认值存在，以便条件检查不会因 nil 表而失败
        EnsureDefaults(key)

        local data = DoiteAurasDB.spells[key]
        local typ  = data and data.type or "Ability"

        local displayName = (data and (data.displayName or data.name)) or key

        -- 从任何缓存的/保存的纹理开始
        local tex = cache[displayName]
        if not tex and data and data.iconTexture then
            tex = data.iconTexture
        end

        -- 仅对于技能：通过法术槽位进行一次廉价后备（Nampower 加速）
        if not tex and typ == "Ability" then
            local slot = slotCache[displayName]
            local slotBookType = BOOKTYPE_SPELL
            if slot == nil then
                slot, slotBookType = FindSpellBookSlot(displayName)
                slotCache[displayName] = slot or false
            elseif slot == false then
                slot = nil
            end

            if slot and GetSpellTexture then
                tex = GetSpellTexture(slot, slotBookType or BOOKTYPE_SPELL)
            end
        end

        -- 一旦知道纹理，将其持久化回缓存 + 数据库
        if tex then
            cache[displayName] = tex
            if data and not data.iconTexture then
                data.iconTexture = tex
            end
        end

        -- 显示/隐藏意图完全来自 DoiteConditions 通过图标标志
        local f = (DoiteAuras_GetIconFrame and DoiteAuras_GetIconFrame(key)) or _G["DoiteIcon_" .. key]
        local wants = false
        if f then
            wants = (f._daShouldShow == true) or (f._daSliding == true)
        end

        -- 编辑/全部测试应将图标视为“想要”，以便布局和桶行为可预测。
        if testAll then
            wants = true
        end
        if editOpen and editKey == key then
            wants = true
        end

        n = n + 1
        local candidate = pool[n]
        if not candidate then
            candidate = {}
            pool[n] = candidate
        end

        -- 覆盖所有下游使用的字段，以便重用不会泄漏状态
        candidate.key  = key
        candidate.data = data
        candidate.show = wants
        candidate.tex  = tex
        do
            local sz = (data and (data.iconSize or data.size)) or 36
            if data and data.group and data.group ~= "" and data.group ~= "no" and (data.isLeader ~= true) then
                local ls = leaderSizeByGroup and leaderSizeByGroup[data.group]
                if ls then
                    sz = ls
                end
            end
            candidate.size = sz
        end
        candidate._computedPos = nil

        -- 标记此图标所属的逻辑桶（组/类别/未分组）
        candidate.bucketKey = DA_GetBucketKeyForCandidate(candidate)

        candidates[n] = candidate
    end

    -- 修剪旧引用，以便 candidates[] 不会使陈旧的池条目保持活动状态
    for i = n + 1, oldN do
        candidates[i] = nil
    end

    -- 第 2 步：首先确保图标存在，然后应用一次组布局
    for _, entry in ipairs(candidates) do
        if entry.data and entry.data.type ~= "Bar" then
            if not (DoiteAuras_GetIconFrame and DoiteAuras_GetIconFrame(entry.key)) then
                CreateOrUpdateIcon(entry.key, 36)
            end
        end
    end

    -- 排除已禁用桶中的图标，以便组不考虑它们
    local layoutCandidates = candidates
    if DoiteGroup and DoiteGroup.ApplyGroupLayout then
        local lc = DoiteAuras._layoutCandidates
        if not lc then
            lc = {}
            DoiteAuras._layoutCandidates = lc
        end

        local oldLC = table.getn(lc)
        local nLC = 0
        for _, entry in ipairs(candidates) do
            local bkey = entry.bucketKey
            if not (bkey and DA_IsBucketDisabled(bkey)) then
                nLC = nLC + 1
                lc[nLC] = entry
            end
        end
        for i = nLC + 1, oldLC do
            lc[i] = nil
        end

        layoutCandidates = lc
    end

    if DoiteGroup and not _G["DoiteGroup_LayoutInProgress"] and DoiteGroup.ApplyGroupLayout then
        pcall(DoiteGroup.ApplyGroupLayout, layoutCandidates)
    end

    -- 持久化计算的布局，以便未来的刷新传递继续使用它
    do
        local map = _G["DoiteGroup_Computed"]
        local now = (GetTime and GetTime()) or 0
        for _, e in ipairs(candidates) do
            local d = e.data
            if d and d.group and d.group ~= "" and d.group ~= "no" and e._computedPos then
                map[d.group] = map[d.group] or {}
                local list = map[d.group]

                -- 就地更新以避免每次刷新分配新表
                local found = false
                for i = 1, table.getn(list) do
                    local li = list[i]
                    if li and li.key == e.key then
                        li.key = e.key
                        local p = li._computedPos
                        if not p then
                            p = {}
                            li._computedPos = p
                        end
                        p.x = e._computedPos.x
                        p.y = e._computedPos.y
                        p.size = e._computedPos.size
                        found = true
                        break
                    end
                end

                if not found then
                    -- 此键首次在该组中出现：创建一次（与之前相同的数据形状）
                    table.insert(list, { key = e.key, _computedPos = {
                        x = e._computedPos.x, y = e._computedPos.y, size = e._computedPos.size
                    }})
                end
            end
        end
        _G["DoiteGroup_LastLayoutTime"] = now
    end

    -- 第 3 步：创建/更新框架并应用位置（单一位置）
    if _G["DoiteAuras_RefreshInProgress"] then return end
    _G["DoiteAuras_RefreshInProgress"] = true

    local cache = DA_Cache()

    -- 跟踪此刷新中处理的键，以便删除的图标（以前可见）立即隐藏。
    local used = DoiteAuras._iconsUsed
    if not used then
        used = {}
        DoiteAuras._iconsUsed = used
    else
        local k
        for k in pairs(used) do
            used[k] = nil
        end
    end

    for _, entry in ipairs(candidates) do
        local key, data = entry.key, entry.data
        if key then
            used[key] = true
        end

        if data and data.type == "Bar" then
            if DoiteBars and DoiteBars.CreateOrUpdateBar and DoiteBars.RefreshBar then
                local bf = DoiteBars.CreateOrUpdateBar(key, data)
                if bf then
                    DoiteBars.RefreshBar(key, data)
                end
            end
        else

        -- 优先使用本地 icons[] 缓存，避免每个图标的字符串连接 + _G 查找
        local f = (icons and icons[key]) or nil
        if not f then
            -- 罕见回退：如果 icons[] 被重置，拾取现有的全局框架
            f = _G["DoiteIcon_" .. key]
            if f and icons then
                icons[key] = f
            end
        end

        if not f and data and data.type ~= "Bar" then
            f = CreateOrUpdateIcon(key, 36)
        end

        -- 计算最终位置/尺寸（组感知，粘性）
        local posX, posY, size
        local isGrouped = (data and data.group and data.group ~= "" and data.group ~= "no")
        local isLeader  = (data and data.isLeader == true)

        -- 1) 优先使用新计算的位置（如果此条目上存在）
        if entry._computedPos then
            posX = entry._computedPos.x
            posY = entry._computedPos.y
            size = entry._computedPos.size

        -- 2) 否则优先使用上次布局滴答中持久化的计算布局
        elseif isGrouped and _G["DoiteGroup_Computed"] and _G["DoiteGroup_Computed"][data.group] then
            local list = _G["DoiteGroup_Computed"][data.group]
            for i = 1, table.getn(list) do
                local ge = list[i]
                if ge.key == key and ge._computedPos then
                    posX = ge._computedPos.x
                    posY = ge._computedPos.y
                    size = ge._computedPos.size
                    break
                end
            end
        end

        if not posX then
            if isGrouped and not isLeader then
                -- 保持当前点；但分组时尺寸必须跟随组长
                local currentSize = (data and (data.iconSize or data.size)) or 36
                if leaderSizeByGroup and data and data.group then
                    local ls = leaderSizeByGroup[data.group]
                    if ls then
                        currentSize = ls
                    end
                end
                size = size or currentSize
                -- 对于没有计算位置的追随者，不要 SetPoint（避免回弹）
            else
                size = size or (data and (data.iconSize or data.size)) or 36
            end
        end

        local savedPoint = (data and data.point) or "CENTER"
        local savedRelPoint = (data and data.relativePoint) or "CENTER"
        local savedX = (data and data.offsetX) or 0
        local savedY = (data and data.offsetY) or 0


        f:SetScale((data and data.scale) or 1)
        f:SetAlpha((data and data.alpha) or 1)
        f:SetWidth(size); f:SetHeight(size)

        -- 当此滴答的幻灯片预览拥有框架时，不要重新锚定，并且如果此框架当前正在被拖动，也不要重新锚定（防止回弹）
        local isDraggingThis = (f._daDragging == true)
        if not f._daSliding and not isDraggingThis then
            -- 如果这是组追随者且尚未计算布局，则不要快照到其自身保存的坐标（通常为 0,0）。使用组长保存的坐标作为临时锚点。
            if isGrouped and (not isLeader) and (not posX) then
                local lp = (leaderPosByGroup and data and data.group) and leaderPosByGroup[data.group]
                if lp and lp.x and lp.y then
                    f:ClearAllPoints()
                    f:SetPoint("CENTER", UIParent, "CENTER", lp.x, lp.y)
                else
                    -- 未找到组长位置：保持当前点不变。（此处不进行 ClearAllPoints / SetPoint）
                end
            else
                f:ClearAllPoints()
                if posX and posY then
                    f:SetPoint("CENTER", UIParent, "CENTER", posX, posY)
                else
                    f:SetPoint("CENTER", UIParent, "CENTER", savedX, savedY)
                end
            end
        end


        -- 纹理处理（使用保存的 iconTexture 回退；此处不进行额外游戏查询）
        local displayName = (data and (data.displayName or data.name)) or key
        local texToUse    = entry.tex
                          or cache[displayName]
                          or (data and data.iconTexture)

        if texToUse then
            cache[displayName] = texToUse
            if data and not data.iconTexture then
                data.iconTexture = texToUse
            end
        end

        f.icon:SetTexture(texToUse or "Interface\\Icons\\INV_Misc_QuestionMark")

        -- 可见性：条件 OR 幻灯片 … 但组限制和桶禁用有最终决定权
        local wantsFromConditions = (f._daShouldShow == true)
        local wantsFromSlide      = (f._daSliding == true)
        local wantsFromEdit       = (editOpen and editKey == key)
        local wantsFromTestAll    = (testAll == true)
        local blockedByGroup      = (f._daBlockedByGroup == true)

        -- 每桶禁用（组/类别/未分组）
        local blockedByBucket = false
        if entry.bucketKey then
            blockedByBucket = DA_IsBucketDisabled(entry.bucketKey)
        end

        local shouldBeVisible = (wantsFromConditions or wantsFromSlide or wantsFromEdit or wantsFromTestAll)
                             and (not blockedByGroup)
                             and (not blockedByBucket)

        -- 移出可见性检查，以确保即使在图标最初隐藏时（例如启动竞态条件）也附加处理程序。
        -- 可见性是动态的（DoiteConditions），但处理程序必须在图标显示时准备好。

        local ic = data and data.conditions and data.conditions.item
        -- 仅在配置了可点击、未灰色且不在编辑模式下才允许点击
        -- 严格限制为物品
        local isClickable = (data and data.type == "Item" and ic and ic.clickable and (not f._daDragging) and (not _G["DoiteEdit_CurrentKey"]))
        -- 不在编辑模式时始终显示物品工具提示
        -- 仅当数据库启用且不在编辑模式时才显示物品工具提示
        local showTooltips = (data and data.type == "Item"
            and (DoiteAurasDB and DoiteAurasDB.showtooltip == true)
            and (not f._daDragging)
            and (not _G["DoiteEdit_CurrentKey"]))

        if _G["DoiteEdit_CurrentKey"] then
            showTooltips = false
        end

        if isClickable or showTooltips then
             f:EnableMouse(true)

             if isClickable then
                 f:SetScript("OnClick", function()
                     -- 编辑模式下阻止物品使用（问题 #50）
                     if _G["DoiteEdit_CurrentKey"] then return end
                     if arg1 == "LeftButton" or arg1 == "RightButton" then
                        -- 如果名称缺失，回退到 'key'（修复 nil 错误）
                        local n = (data.displayName or data.name) or key
                        if n and n ~= "" then
                             DA_UseItemByName(n)
                        end
                     end
                 end)
             else
                 f:SetScript("OnClick", nil)
             end

             if showTooltips then
                 f:SetScript("OnEnter", function()
                     local n = (data.displayName or data.name) or key
                     DA_ShowDetailedItemTooltip(this, n)
                 end)
                 f:SetScript("OnLeave", function()
                     GameTooltip:Hide()
                 end)
             else
                 f:SetScript("OnEnter", nil)
                 f:SetScript("OnLeave", nil)
             end
        elseif data and data.type == "Item" then

             -- 即使在编辑期间，也要清除工具提示脚本，使它们不会“粘住”。
             f:SetScript("OnEnter", nil)
             f:SetScript("OnLeave", nil)
             if not _G["DoiteEdit_CurrentKey"] then
                f:EnableMouse(false)
                 f:SetScript("OnClick", nil)
             end
        end

        if shouldBeVisible then
            f:Show()
        else
            f:Hide()
        end
        end
    end

    -- 如果图标在可见时被删除，它可能仍然存在于本地 icons[] 缓存中，并且否则将保持可见，直到 /reload。
    if icons and DoiteAurasDB and DoiteAurasDB.spells then
        local used = DoiteAuras._iconsUsed
        local k, f
        for k, f in pairs(icons) do
            if f and (not used or not used[k]) then
                if not DoiteAurasDB.spells[k] then
                    f:Hide()
                    -- 保留或删除缓存条目；删除可避免添加/删除循环中表无限增长
                    icons[k] = nil
                end
            end
        end
    end

    _G["DoiteAuras_RefreshInProgress"] = false

    -- 确保立即评估条件，以便启动时“灰色”状态正确
    if DoiteConditions and DoiteConditions.EvaluateAll then
        DoiteConditions:EvaluateAll()
    end
end

-- 刷新列表（组感知，但仍仅使用 .order 作为唯一真实依据）
local function RefreshList()
    if DA_IsHardDisabled() then
        return
    end

    local _, v

    -- 将所有现有行框架标记为“未使用”用于此重建，并隐藏它们。
    for _, v in pairs(spellButtons) do
        if v then
            v._daInList = false
            if v.Hide then v:Hide() end
        end
    end

    -- 隐藏所有现有标题框架（按索引重用）
    local oldHeaderN = table.getn(groupHeaders)
    local i
    for i = 1, oldHeaderN do
        local h = groupHeaders[i]
        if h and h.Hide then h:Hide() end
    end

    local ordered = GetOrderedSpells()

    -- 重复项信息，用于基于名称+类型的 "(i/N)" 后缀
    local groupCount = {}
    local groupIndex = {}

    for i, entry in ipairs(ordered) do
        local d = entry.data
        local base = BaseKeyFor(d)
        groupCount[base] = (groupCount[base] or 0) + 1
    end
    for i, entry in ipairs(ordered) do
        local d = entry.data
        local base = BaseKeyFor(d)
        groupIndex[base] = (groupIndex[base] or 0) + 1
        entry._groupCnt = groupCount[base] or 1
        entry._groupIdx = groupIndex[base] or 1
    end

    local groupMembers = {}
    for i, entry in ipairs(ordered) do
        local d = entry.data
        if DA_IsGrouped(d) then
            local g = d.group
            if not groupMembers[g] then
                groupMembers[g] = {}
            end
            table.insert(groupMembers[g], entry)
        end
    end
    for g, list in pairs(groupMembers) do
        local n = table.getn(list)
        local j
        for j = 1, n do
            local e = list[j]
            e._prioInGroup = j
            e._groupSize   = n
        end
    end

    local displayList = DA_BuildDisplayList(ordered)

    -- 根据单独的标题和行高度计算内容高度
    local headerCount, entryCount = 0, 0
    for _, entry in ipairs(displayList) do
        if entry.isHeader then
            headerCount = headerCount + 1
        else
            entryCount = entryCount + 1
        end
    end
    local totalHeight = headerCount * 25 + entryCount * 55 + 20
    listContent:SetHeight(math.max(160, totalHeight))

    -- 运行垂直偏移（标题间距更紧）
    local yOffset = 0

    local headerIndex = 0

    for _, entry in ipairs(displayList) do
        if entry.isHeader then
            headerIndex = headerIndex + 1

            -- 按索引重用标题框架
            local hdr = groupHeaders[headerIndex]
            if not hdr then
                hdr = CreateFrame("Frame", nil, listContent)
                hdr:SetWidth(320); hdr:SetHeight(22)

                hdr.bg = hdr:CreateTexture(nil, "BACKGROUND")
                hdr.bg:SetAllPoints(hdr)
                hdr.bg:SetTexture(1, 1, 1, 0.06)

                hdr.label = hdr:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                hdr.label:SetPoint("LEFT", hdr, "LEFT", 22, 0)
                -- 手风琴切换 (+ / -)
                hdr.toggleBtn = CreateFrame("Button", nil, hdr, "UIPanelButtonTemplate")
                hdr.toggleBtn:SetWidth(16); hdr.toggleBtn:SetHeight(16)
                hdr.toggleBtn:SetPoint("LEFT", hdr, "LEFT", 3, 0)
                hdr.toggleBtn:SetText("-")
                hdr.toggleBtn:SetScript("OnClick", function()
                    local p = this:GetParent()
                    local bk = p and p.bucketKey
                    if not bk then return end

                    local collapsed = DA_IsBucketCollapsed(bk)
                    DA_SetBucketCollapsed(bk, not collapsed)

                    -- 重建列表以折叠/展开
                    if DoiteAuras_RefreshList then
                        pcall(DoiteAuras_RefreshList)
                    end
                end)

                -- 禁用复选框（创建一次；每个标题显示/隐藏）
                hdr.disableCheck = CreateFrame("CheckButton", nil, hdr, "UICheckButtonTemplate")
                hdr.disableCheck:SetWidth(14); hdr.disableCheck:SetHeight(14)
                hdr.disableCheck:SetHitRectInsets(0, -40, 0, 0)

                hdr.disableCheck.text = hdr:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                hdr.disableCheck.text:SetPoint("LEFT", hdr.disableCheck, "RIGHT", 2, 0)
                hdr.disableCheck.text:SetText("禁用")
                if hdr.disableCheck.text.SetTextColor then
                    hdr.disableCheck.text:SetTextColor(0.7, 0.7, 0.7)
                end

                hdr.disableCheck:SetScript("OnClick", function()
                    local p = this:GetParent()
                    local bk = p and p.bucketKey
                    if not bk then return end

                    DoiteAurasDB.bucketDisabled = DoiteAurasDB.bucketDisabled or {}
                    if this:GetChecked() then
                        DoiteAurasDB.bucketDisabled[bk] = true
                    else
                        DoiteAurasDB.bucketDisabled[bk] = nil
                    end

                    if DoiteAuras_RefreshIcons then
                        pcall(DoiteAuras_RefreshIcons)
                    end
                end)

                -- 组模式下拉框（仅组；取代排序/固定/禁用复选框）
                hdr.groupModeDropdown = CreateFrame("Frame", "DoiteAurasGroupModeDropdown" .. tostring(headerIndex), hdr, "UIDropDownMenuTemplate")
                UIDropDownMenu_SetWidth(80, hdr.groupModeDropdown)

                hdr.groupModeLabels = {
                    prio = "按优先级排序",
                    time = "按时间排序",
                    fixed = "固定",
                    disabled = "禁用组",
                }

                local function DA_ApplyGroupModeSelection(parent, selectedMode)
                    if not parent or not parent.groupName or parent.groupName == "" then return end

                    local groupName = parent.groupName
                    local bucketKey = parent.bucketKey

                    DoiteAurasDB.groupSort = DoiteAurasDB.groupSort or {}
                    DoiteAurasDB.groupFixed = DoiteAurasDB.groupFixed or {}
                    DoiteAurasDB.bucketDisabled = DoiteAurasDB.bucketDisabled or {}

                    if bucketKey then
                        if selectedMode == "disabled" then
                            DoiteAurasDB.bucketDisabled[bucketKey] = true
                        else
                            DoiteAurasDB.bucketDisabled[bucketKey] = nil
                        end
                    end

                    if selectedMode == "time" or selectedMode == "prio" then
                        DoiteAurasDB.groupSort[groupName] = selectedMode
                        DoiteAurasDB.groupFixed[groupName] = nil
                        DoiteGroup.InvalidateSortCache(groupName)
                        _G["DoiteGroup_NeedReflow"] = true
                    elseif selectedMode == "fixed" then
                        DoiteAurasDB.groupFixed[groupName] = true
                        if DoiteGroup and DoiteGroup.RequestReflow then
                            DoiteGroup.RequestReflow()
                        else
                            _G["DoiteGroup_NeedReflow"] = true
                        end
                    end

                    UIDropDownMenu_SetSelectedValue(parent.groupModeDropdown, selectedMode)
                    UIDropDownMenu_SetText(parent.groupModeLabels[selectedMode] or parent.groupModeLabels.prio, parent.groupModeDropdown)

                    if DoiteAuras_RefreshIcons then
                        pcall(DoiteAuras_RefreshIcons)
                    end
                end

                UIDropDownMenu_Initialize(hdr.groupModeDropdown, function(level)
                    local p = hdr
                    if not p or not p.groupModeLabels then return end

                    local function addOption(modeValue)
                        local info = UIDropDownMenu_CreateInfo()
                        info.text = p.groupModeLabels[modeValue] or "按优先级排序"
                        info.value = modeValue
                        info.func = function()
                            local selected = (this and this.value) or modeValue
                            DA_ApplyGroupModeSelection(p, selected)
                        end
                        info.checked = (UIDropDownMenu_GetSelectedValue(p.groupModeDropdown) == modeValue)
                        UIDropDownMenu_AddButton(info, level or 1)
                    end

                    addOption("prio")
                    addOption("time")
                    addOption("fixed")
                    addOption("disabled")
                end)

                hdr.sepTex = hdr:CreateTexture(nil, "ARTWORK")
                hdr.sepTex:SetHeight(1)
                hdr.sepTex:SetPoint("BOTTOMLEFT", hdr, "BOTTOMLEFT", 0, -2)
                hdr.sepTex:SetPoint("BOTTOMRIGHT", hdr, "BOTTOMRIGHT", 0, -2)
                hdr.sepTex:SetTexture(0.9, 0.9, 0.9, 0.12)

                groupHeaders[headerIndex] = hdr
            end

            -- 更新动态标题文本
            hdr.groupName = entry.groupName or ""
            local hdrName = string.upper(hdr.groupName or "")
            hdr.label:SetText(hdrName)

            -- 桶键 + 禁用切换可见性/状态
            hdr.bucketKey = DA_GetBucketKeyForHeaderEntry(entry)
            DoiteAurasDB.bucketDisabled = DoiteAurasDB.bucketDisabled or {}

            if hdr.bucketKey then
                hdr.disableCheck:ClearAllPoints()
                hdr.disableCheck:SetPoint("RIGHT", hdr, "RIGHT", -45, 0)
                hdr.disableCheck:SetChecked(DoiteAurasDB.bucketDisabled[hdr.bucketKey] == true)
                if hdr.disableCheck.text then hdr.disableCheck.text:Show() end

                -- 手风琴切换文本
                if hdr.toggleBtn then
                    if DA_IsBucketCollapsed(hdr.bucketKey) then
                        hdr.toggleBtn:SetText("+")
                    else
                        hdr.toggleBtn:SetText("-")
                    end
                    hdr.toggleBtn:Show()
                end
            else
                hdr.disableCheck:Hide()
                if hdr.disableCheck.text then hdr.disableCheck.text:Hide() end
                if hdr.toggleBtn then hdr.toggleBtn:Hide() end
            end

            -- 组模式下拉框（仅用于组标题）
            if entry.kind == "group" and hdr.groupName and hdr.groupName ~= "" then
                local mode = DA_GetGroupSortMode(hdr.groupName)  -- "prio" 或 "time"
                DoiteAurasDB.groupFixed = DoiteAurasDB.groupFixed or {}
                local fixed = DoiteAurasDB.groupFixed[hdr.groupName] == true

                hdr.disableCheck:Hide()
                if hdr.disableCheck.text then hdr.disableCheck.text:Hide() end

                local selectedMode = "prio"
                if hdr.bucketKey and DoiteAurasDB.bucketDisabled[hdr.bucketKey] == true then
                    selectedMode = "disabled"
                elseif fixed then
                    selectedMode = "fixed"
                elseif mode == "time" then
                    selectedMode = "time"
                end

                hdr.groupModeDropdown:ClearAllPoints()
                hdr.groupModeDropdown:SetPoint("RIGHT", hdr, "RIGHT", 8, -2)
                UIDropDownMenu_SetSelectedValue(hdr.groupModeDropdown, selectedMode)
                UIDropDownMenu_SetText(hdr.groupModeLabels[selectedMode] or hdr.groupModeLabels.prio, hdr.groupModeDropdown)
                hdr.groupModeDropdown:Show()
            else
                hdr.disableCheck:Show()
                if hdr.disableCheck.text then hdr.disableCheck.text:Show() end
                hdr.groupModeDropdown:Hide()
            end

            -- 定位标题
            hdr:ClearAllPoints()
            hdr:SetPoint("TOPLEFT", listContent, "TOPLEFT", 0, yOffset)
            yOffset = yOffset - 25
            hdr:Show()

        else
            local key, data = entry.key, entry.data
            if key and data then
                local display = (data.shownName and data.shownName ~= "" and data.shownName) or (data.displayName or key)
                -- 仅当 N > 1（相同名称+类型的重复项）时显示 "(i/N)"
                if entry._groupCnt and entry._groupCnt > 1 then
                    display = string.format("%s (%d/%d)", display, entry._groupIdx, entry._groupCnt)
                end

                -- 按键重用行框架
                local btn = spellButtons[key]
                if not btn then
                    btn = CreateFrame("Frame", nil, listContent)
                    btn:SetWidth(320); btn:SetHeight(53)

                    btn.fontString = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                    btn.fontString:SetPoint("TOPLEFT", btn, "TOPLEFT", 15, -2)

                    btn.tag = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                    btn.tag:SetPoint("TOPLEFT", btn.fontString, "BOTTOMLEFT", 0, -2)

                    btn.removeBtn = CreateFrame("Button", nil, btn, "UIPanelButtonTemplate")
                    btn.removeBtn:SetWidth(60); btn.removeBtn:SetHeight(18)
                    btn.removeBtn:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -5, -29)
                    btn.removeBtn:SetText("移除")

                    btn.editBtn = CreateFrame("Button", nil, btn, "UIPanelButtonTemplate")
                    btn.editBtn:SetWidth(50); btn.editBtn:SetHeight(18)
                    btn.editBtn:SetPoint("RIGHT", btn.removeBtn, "LEFT", -5, 0)
                    btn.editBtn:SetText("编辑")

                    btn.downBtn = CreateFrame("Button", nil, btn)
                    btn.downBtn:SetWidth(18); btn.downBtn:SetHeight(18)
                    btn.downBtn:SetNormalTexture("Interface\\MainMenuBar\\UI-MainMenu-ScrollUpButton-Up")
                    btn.downBtn:SetPushedTexture("Interface\\MainMenuBar\\UI-MainMenu-ScrollUpButton-Down")
                    btn.downBtn:SetPoint("RIGHT", btn.editBtn, "LEFT", -5, 0)

                    btn.upBtn = CreateFrame("Button", nil, btn)
                    btn.upBtn:SetWidth(18); btn.upBtn:SetHeight(18)
                    btn.upBtn:SetNormalTexture("Interface\\MainMenuBar\\UI-MainMenu-ScrollDownButton-Up")
                    btn.upBtn:SetPushedTexture("Interface\\MainMenuBar\\UI-MainMenu-ScrollDownButton-Down")
                    btn.upBtn:SetPoint("RIGHT", btn.downBtn, "LEFT", -5, 0)

                    btn.renameBtn = CreateFrame("Button", nil, btn, "UIPanelButtonTemplate")
                    btn.renameBtn:SetWidth(55); btn.renameBtn:SetHeight(18)
                    btn.renameBtn:SetPoint("RIGHT", btn.editBtn, "LEFT", -5, 0)
                    btn.renameBtn:SetText("重命名")

                    btn.downBtn:ClearAllPoints()
                    btn.downBtn:SetPoint("RIGHT", btn.renameBtn, "LEFT", -5, 0)

                    btn.renameInput = CreateFrame("EditBox", nil, btn)
                    btn.renameInput:SetWidth(120); btn.renameInput:SetHeight(18)
                    DA_StyleRowEditBox(btn.renameInput, "LEFT")
                    -- 重命名控件行锚点
                    btn.renameInput:SetPoint("TOPLEFT", btn, "TOPLEFT", 15, -49)

                    btn.renameAddBtn = CreateFrame("Button", nil, btn, "UIPanelButtonTemplate")
                    btn.renameAddBtn:SetWidth(40); btn.renameAddBtn:SetHeight(18)
                    btn.renameAddBtn:SetPoint("LEFT", btn.renameInput, "RIGHT", 5, 0)
                    btn.renameAddBtn:SetText("添加")

                    btn.renameResetBtn = CreateFrame("Button", nil, btn, "UIPanelButtonTemplate")
                    btn.renameResetBtn:SetWidth(45); btn.renameResetBtn:SetHeight(18)
                    btn.renameResetBtn:SetPoint("LEFT", btn.renameAddBtn, "RIGHT", 5, 0)
                    btn.renameResetBtn:SetText("重置")

                    btn.renameBackBtn = CreateFrame("Button", nil, btn, "UIPanelButtonTemplate")
                    btn.renameBackBtn:SetWidth(40); btn.renameBackBtn:SetHeight(18)
                    btn.renameBackBtn:SetPoint("LEFT", btn.renameResetBtn, "RIGHT", 5, 0)
                    btn.renameBackBtn:SetText("返回")

                    btn.sep = btn:CreateTexture(nil, "ARTWORK")
                    btn.sep:SetHeight(1)
                    btn.sep:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 0, -2)
                    btn.sep:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 0, -2)
                    btn.sep:SetTexture(0.9, 0.9, 0.9, 0.12)

                    spellButtons[key] = btn
                end

                btn._daInList = true
                btn.daKey = key

                -- 更新行视觉
                btn.fontString:SetText(display)

                -- 类型 + 组/未分组优先级文本
                local baseLabel, baseColor
                if data.type == "Ability" then
                    baseLabel = "技能"
                    baseColor = "|cff4da6ff"
                elseif data.type == "Buff" then
                    baseLabel = "增益"
                    baseColor = "|cff7dff7d"
                elseif data.type == "Debuff" then
                    baseLabel = "减益"
                    baseColor = "|cffff7d7d"
                elseif data.type == "Item" then
                    baseLabel = "物品"
                    baseColor = "|cffffd27d"
                elseif data.type == "Bar" then
                    baseLabel = "条"
                    baseColor = "|cffd27dff"
                elseif data.type == "Custom" then
                    baseLabel = "自定义"
                    baseColor = "|cff7dd2ff"
                else
                    baseLabel = tostring(data.type or "未知")
                    baseColor = "|cffcccccc"
                end

                local suffix = ""
                if DA_IsGrouped(data) then
                    local groupDesc = data.group
                    local prio = entry._prioInGroup or 1
                    local leaderSuffix = ""
                    if data.isLeader then
                        leaderSuffix = " - 组组长"
                    end
                    suffix = string.format(" (%s - 优先级 %d%s)", tostring(groupDesc or "组"), prio, leaderSuffix)
                else
                    local bucketName  = entry._bucketName or "未分组"
                    local x = entry._bucketIndex or 1
                    local y = entry._bucketTotal or 1
                    local bucketLabel = string.upper(bucketName)
                    suffix = string.format(" (%s - 顺序# %d/%d)", bucketLabel, x, y)
                end

                local typeText = baseColor .. baseLabel .. "|r|cffaaaaaa" .. suffix .. "|r"
                btn.tag:SetText(typeText)

                -- 脚本在每次刷新时重新绑定（使用当前局部变量保持确切的现有逻辑）
                btn.removeBtn:SetScript("OnClick", function()
                    DA_CancelRename()

                    -- 检测这是否是最后一个使用它们的图标。
                    local groupName    = data and data.group
                    local categoryName = data and data.category

                    -- 如果此光环的编辑框架打开，则关闭它
                    local ef = _G["DoiteEdit_Frame"]
                    if ef and ef:IsShown() and _G["DoiteEdit_CurrentKey"] == key then
                        ef:Hide()
                    end

                    -- 从 DoiteAuras 数据库中移除
                    DoiteAurasDB.spells[key] = nil

                    -- 当最后一个图标被删除时，保持组/类别元数据映射同步。
                    if DoiteGroup and DoiteGroup.CleanupDanglingGroupData then
                        pcall(DoiteGroup.CleanupDanglingGroupData)
                    end

                    -- 同时删除任何遗留的 DoiteDB 条目，以便评估停止触及此键
                    if DoiteDB and DoiteDB.icons and DoiteDB.icons[key] then
                        DoiteDB.icons[key] = nil
                    end

                    -- 移除缓存的行框架引用，以便添加/删除循环不会无限制增长
                    if spellButtons and spellButtons[key] then
                        spellButtons[key]:Hide()
                        spellButtons[key] = nil
                    end

                    -- 立即隐藏图标框架，即使刷新节流可能跳过。
                    local gf = _G["DoiteIcon_" .. key]
                    if gf then
                        gf:Hide()
                        gf._daShouldShow = nil
                        gf._daSliding = nil
                    end
                    if icons and icons[key] then
                        icons[key] = nil
                    end
                    if DoiteBars and DoiteBars.DestroyBar then
                        DoiteBars.DestroyBar(key)
                    end

                    -- 重建顺序 + UI（强制图标刷新，以便删除始终立即可见）
                    RebuildOrder()
                    if DoiteGroup and DoiteGroup.InvalidateSortCache then
                        DoiteGroup.InvalidateSortCache()
                    end
                    RefreshList()
                    RefreshIcons(true)

                    if DoiteConditions_RequestEvaluate then
                        DoiteConditions_RequestEvaluate()
                    end
                end)

                btn.editBtn:SetScript("OnClick", function()
                    DA_CancelRename()
                    RefreshList()

                    local baseName = data.displayName or data.name or display

                    currentType = data.type or "Ability"
                    if abilityCB then abilityCB:SetChecked(currentType == "Ability") end
                    if buffCB    then buffCB:SetChecked(currentType == "Buff")    end
                    if debuffCB  then debuffCB:SetChecked(currentType == "Debuff") end
                    if itemsCB   then itemsCB:SetChecked(currentType == "Item")   end
                    if barsCB    then barsCB:SetChecked(currentType == "Bar")     end
                    if customCB  then customCB:SetChecked(currentType == "Custom") end

                    if currentType == "Item" then
                        DA_UpdateTypeUI()
                        if itemDropDown then
                            UIDropDownMenu_SetText(baseName, itemDropDown)
                        end

                    elseif currentType == "Bar" then
                        DA_UpdateTypeUI()
                        if barDropDown then
                            UIDropDownMenu_SetText(baseName, barDropDown)
                        end

                    else
                        DA_UpdateTypeUI()
                        if spellDropDown then
                            UIDropDownMenu_SetText(baseName, spellDropDown)
                        end
                    end

                    if DoiteConditions_Show then
                        DoiteConditions_Show(key)
                    end
                end)

                btn.downBtn:SetScript("OnClick", function()
                    DA_CancelRename()

                    local isGrouped = DA_IsGrouped(data)
                    local moved = false

                    if isGrouped then
                        -- 在组内向上移动（向第一个成员）
                        moved = DA_MoveOrderWithinGroup(key, "up")
                    else
                        -- 未分组：仅在其类别 / Ungrouped 桶内移动
                        moved = DA_MoveOrderWithinCategoryOrUngrouped(key, "up")
                    end

                    if moved then
                        RebuildOrder()
                        RefreshList()
                        RefreshIcons()
                        if DoiteConditions_RequestEvaluate then
                            DoiteConditions_RequestEvaluate()
                        end
                    end
                end)

                btn.upBtn:SetScript("OnClick", function()
                    DA_CancelRename()

                    local isGrouped = DA_IsGrouped(data)
                    local moved = false

                    if isGrouped then
                        moved = DA_MoveOrderWithinGroup(key, "down")
                    else
                        moved = DA_MoveOrderWithinCategoryOrUngrouped(key, "down")
                    end

                    if moved then
                        RebuildOrder()
                        RefreshList()
                        RefreshIcons()
                        if DoiteConditions_RequestEvaluate then
                            DoiteConditions_RequestEvaluate()
                        end
                    end
                end)

                btn.renameInput:SetScript("OnTextChanged", DA_RenameOnTextChanged)
                btn.renameBtn:SetScript("OnClick", DA_RenameStart)
                btn.renameBackBtn:SetScript("OnClick", DA_RenameBack)
                btn.renameResetBtn:SetScript("OnClick", DA_RenameReset)
                btn.renameAddBtn:SetScript("OnClick", DA_RenameAdd)

                if renameState.key == key then
                    btn.renameInput:Show()
                    btn.renameAddBtn:Show()
                    btn.renameResetBtn:Show()
                    btn.renameBackBtn:Show()
                    btn:SetHeight(78)
                    local currentShown = data.shownName or data.displayName or data.name or ""
                    if btn.renameInput:GetText() ~= currentShown and not btn.renameInput:HasFocus() then
                        btn.renameInput:SetText(currentShown)
                    end
                    DA_RenameUpdateAddState(btn)
                else
                    btn.renameInput:Hide()
                    btn.renameAddBtn:Hide()
                    btn.renameResetBtn:Hide()
                    btn.renameBackBtn:Hide()
                    btn:SetHeight(53)
                end

                -- 定位行（重用框架时 ClearAllPoints 很重要）
                btn:ClearAllPoints()
                btn:SetPoint("TOPLEFT", listContent, "TOPLEFT", 0, yOffset)
                if renameState.key == key then
                    yOffset = yOffset - 80
                else
                    yOffset = yOffset - 55
                end
                btn:Show()
            end
        end
    end

    -- 隐藏此次刷新未使用的任何行框架（覆盖已删除的键）
    for _, v in pairs(spellButtons) do
        if v and (v._daInList ~= true) then
            if v.Hide then v:Hide() end
        end
    end

    scrollFrame:SetScrollChild(listContent)
end

-- 添加按钮
addBtn:SetScript("OnClick", function()
  DA_CancelRename()

  local t = currentType
  local name

  -- 条类型：从下拉框读取选中的条种类并创建数据库条目
  if t == "Bar" then
    local barLabel = DA_GetDropDownText(barDropDown)
    if not barLabel or barLabel == "" or barLabel == "从下拉列表中选择" then
      (DEFAULT_CHAT_FRAME or ChatFrame1):AddMessage("|cff6FA8DCDoiteAuras:|r 请从下拉列表中选择一个条类型。")
      return
    end

    -- 将标签解析为种类键
    local selectedKindKey = nil
    if DoiteBars and DoiteBars.Kinds and DoiteBars.KindOrder then
      local i
      for i = 1, table.getn(DoiteBars.KindOrder) do
        local kk = DoiteBars.KindOrder[i]
        local kd = DoiteBars.Kinds[kk]
        if kd and kd.label == barLabel then
          selectedKindKey = kk
          break
        end
      end
    end

    if not selectedKindKey then
      (DEFAULT_CHAT_FRAME or ChatFrame1):AddMessage("|cff6FA8DCDoiteAuras:|r 该条类型尚未实现。")
      return
    end

    -- 生成数据库键
    local key, baseKey, instanceIdx = GenerateUniqueKey(barLabel, "Bar")
    local nextOrder = table.getn(GetOrderedSpells()) + 1

    DoiteAurasDB.spells[key] = {
      order       = nextOrder,
      type        = "Bar",
      category    = "BARS",
      barType     = selectedKindKey,
      displayName = barLabel,
      shownName   = barLabel,
      baseKey     = baseKey,
      uid         = instanceIdx,
      offsetX     = 0,
      offsetY     = 0,
      barWidth    = 200,
      barHeight   = 25,
      scale       = 1,
      alpha       = 1,
    }

    RebuildOrder(); RefreshList(); RefreshIcons()
    -- 创建并显示条框架
    if DoiteBars and DoiteBars.CreateOrUpdateBar then
      local data = DoiteAurasDB.spells[key]
      local f = DoiteBars.CreateOrUpdateBar(key, data)
      if f then
        DoiteBars.RefreshBar(key, data)
        f:Show()
      end
    end
    scrollFrame:SetVerticalScroll(math.max(0, listContent:GetHeight() - scrollFrame:GetHeight()))
    return
  end

  if t == "Item" then
      name = DA_GetDropDownText(itemDropDown)
  elseif t == "Ability" then
      name = DA_GetDropDownText(abilityDropDown)
  else
      name = input:GetText()
  end

  if not name or name == "" then return end
  if name == "从下拉列表中选择" then return end

  local isSpecialHeader = (name == "---已装备的饰品栏位---" or name == "---已装备的武器栏位---")
  if not isSpecialHeader and (t == "Buff" or t == "Debuff") then
      name = TitleCase(name)
  end

  -- 检测纯数字的 Buff/Debuff 输入作为“法术 ID 模式”
  local spellIdStr = nil
  local shownName  = nil

  if (t == "Buff" or t == "Debuff") and not isSpecialHeader then
      if string.find(name, "^(%d+)$") then
          spellIdStr = name

          -- Nampower：立即解析法术名称+等级
          local resolvedSpellName = nil
          local resolvedSpellRank = nil

          if type(GetSpellNameAndRankForId) == "function" then
              local ok, sn, sr = pcall(GetSpellNameAndRankForId, tonumber(spellIdStr))
              if ok and sn and sn ~= "" then
                  resolvedSpellName = tostring(sn)
                  if sr and sr ~= "" then
                      resolvedSpellRank = tostring(sr) -- "Rank 1"
                  end
              end
          end

          if resolvedSpellName then
              -- 匹配名称（与按名称添加相同）
              name = resolvedSpellName

              -- 漂亮的列表标签（你当前的行为，但分开存储）
              shownName = DA_GetSpellIdShownName(spellIdStr)
          else
              -- 如果解析器尚不可用，则回退
              shownName = DA_GetSpellIdShownName(spellIdStr)
              name = shownName
          end
      end
  end

  -- 技能验证保持不变
  if t == "Ability" and not FindSpellBookSlot(name) then
    (DEFAULT_CHAT_FRAME or ChatFrame1):AddMessage("|cffff0000DoiteAuras:|r 法术书中未找到该技能。")
    return
  end

  ----------------------------------------------------------------
  -- Buff/Debuff 重复项规则：
  -- 当现有的同 (name,type) 条目都还没有纹理（iconTexture 或缓存条目）时，
  -- 仅允许一个条目。
  --
  -- 对于法术 ID 条目，这仍然按可见标签分组
  -- “法术 ID: 12345（将在看到时更新）”。
  ----------------------------------------------------------------
  if t == "Buff" or t == "Debuff" then
      local cache   = DA_Cache()
      local baseKey = BaseKeyFor(name, t)

      local hasSibling         = false
      local siblingHasTexture  = false

      if DoiteAurasDB and DoiteAurasDB.spells then
          local sk, sd
          for sk, sd in pairs(DoiteAurasDB.spells) do
              if sd and BaseKeyFor(sd) == baseKey then
                  hasSibling = true

                  local nm  = sd.displayName or sd.name
                  local tex = sd.iconTexture
                  if not tex and nm then
                      tex = cache[nm]
                  end

                  if tex then
                      siblingHasTexture = true
                      break
                  end
              end
          end
      end

      -- 如果已经至少有一个具有此名称+类型的增益/减益条目，且它们都没有纹理，则阻止添加另一个。
      if hasSibling and not siblingHasTexture then
          local cf = (DEFAULT_CHAT_FRAME or ChatFrame1)
          if cf then
              cf:AddMessage("|cff6FA8DCDoiteAuras:|r 要添加另一个相同类型（增益/减益）且名称为 |cffffff00" .. name .. "|r 的重复光环，你必须至少看到/应用过它一次。")
          end
          return
      end
  end
  ----------------------------------------------------------------

  -- 生成唯一键；baseKey 按名称+类型对重复项分组
  local key, baseKey, instanceIdx = GenerateUniqueKey(name, t)

  -- 顺序 = 追加到最后
  local nextOrder = table.getn(GetOrderedSpells()) + 1

  -- 创建数据库条目（稍后由 EnsureDBEntry/DoiteEdit 填充默认值）
  DoiteAurasDB.spells[key] = {
    order       = nextOrder,
    type        = t,
    displayName = name,
    shownName   = shownName,
    baseKey     = baseKey,
    uid         = instanceIdx,
  }

  local entry = DoiteAurasDB.spells[key]
  local cache = DA_Cache()

  -- 如果这是通过法术 ID 创建的，持久化它，以便 DoiteConditions 可以通过 ID 解析它。
  if spellIdStr then
      entry.spellid = spellIdStr
      entry.Addedviaspellid = true
  end

  -- 自动预加载纹理：通过法术 ID 添加的增益/减益：立即尝试 Nampower 法术纹理查找。
  -- 如果返回 nil，此处不执行任何操作，以便现有的后备逻辑（缓存/兄弟）和 DoiteConditions 的“已见”更新保持不变。
  if spellIdStr then
      local tex = DA_GetSpellTextureById(spellIdStr)
      if tex then
          cache[name]       = tex
          entry.iconTexture = tex
      end
  end

  if t == "Ability" then
    local slot, slotBookType = FindSpellBookSlot(name)
    if slot and GetSpellTexture then
      local tex = GetSpellTexture(slot, slotBookType or BOOKTYPE_SPELL)
      if tex then
        cache[name]       = tex
        entry.iconTexture = tex
      end
    end

  elseif t == "Item" then
    -- 物品：尽可能使用真实物品图标，对于特殊装备标题使用“？”
    if isSpecialHeader then
      -- “已装备的饰品栏位” / “已装备的武器栏位” -> 后续条件的占位符
      local tex = "Interface\\Icons\\INV_Misc_QuestionMark"
      cache[name]       = tex
      entry.iconTexture = tex
    else
      -- 选择了具体物品：立即捕获其图标，以便即使以后卸下也能持久化
      local itemTex = DA_FindItemTextureByName(name)
      if itemTex then
        cache[name]       = itemTex
        entry.iconTexture = itemTex
      end
    end
  end

  -- 通用后备：如果仍然缺失，使用任何现有缓存或兄弟 iconTexture
  if not entry.iconTexture then
    local cached = DA_Cache()[name]
    if cached then
      entry.iconTexture = cached
    else
      for sk, sd in IterSiblings(name, t) do
        if sd and sd.iconTexture then
          entry.iconTexture = sd.iconTexture
          break
        end
      end
    end
  end

  if EnsureDBEntry then pcall(EnsureDBEntry, key) end
  input:SetText("")
  RebuildOrder(); RefreshList(); RefreshIcons()
  scrollFrame:SetVerticalScroll(math.max(0, listContent:GetHeight() - scrollFrame:GetHeight()))
  if DoiteConditions_RequestEvaluate then DoiteConditions_RequestEvaluate() end
end)

-- =========================
-- 小地图按钮 (DoiteAuras)
-- =========================
local function DA_GetVersion()
  local v = (GetAddOnMetadata and GetAddOnMetadata("DoiteAuras", "Version")) or (DoiteAuras_Version) or "?"
  return v or "?"
end

local function _DA_MiniSV()
  DoiteAurasDB.minimap = DoiteAurasDB.minimap or {}
  if DoiteAurasDB.minimap.angle == nil then DoiteAurasDB.minimap.angle = 45 end -- 默认角度
  return DoiteAurasDB.minimap
end

local function _DA_PlaceMini(btn)
  local ang = ((_DA_MiniSV().angle or 45) * math.pi / 180)
  local x = math.cos(ang) * 80
  local y = math.sin(ang) * 80
  btn:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function DA_CreateMinimapButton()
  if _G["DoiteAurasMinimapButton"] then return end

  local btn = CreateFrame("Button", "DoiteAurasMinimapButton", Minimap)
  btn:SetFrameStrata("MEDIUM")
  btn:SetWidth(31); btn:SetHeight(31)

  -- 环覆盖
  local overlay = btn:CreateTexture(nil, "OVERLAY")
  overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
  overlay:SetWidth(54); overlay:SetHeight(54)
  overlay:SetPoint("TOPLEFT", 0, 0)

  -- 图标 (DA tga)
  local icon = btn:CreateTexture(nil, "BACKGROUND")
  icon:SetTexture("Interface\\AddOns\\DoiteAuras\\Textures\\doiteauras-icon")
  icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
  icon:SetWidth(20); icon:SetHeight(20)
  icon:SetPoint("TOPLEFT", 6, -5)

  local hlt = btn:CreateTexture(nil, "HIGHLIGHT")
  hlt:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
  hlt:SetBlendMode("ADD")
  hlt:SetAllPoints(btn)

  btn:RegisterForDrag("LeftButton", "RightButton")
  btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")

  -- 拖动以沿小地图环移动
  btn:SetScript("OnDragStart", function()
    btn:SetScript("OnUpdate", function()
      local x, y = GetCursorPosition()
      local mx, my = Minimap:GetCenter()
      local scale = Minimap:GetEffectiveScale()
      local ang = math.deg(math.atan2(y/scale - my, x/scale - mx))
      _DA_MiniSV().angle = ang
      _DA_PlaceMini(btn)
    end)
  end)
  btn:SetScript("OnDragStop", function() btn:SetScript("OnUpdate", nil) end)

  -- 点击：打开/关闭 DoiteAuras
  btn:SetScript("OnClick", function()
    if DA_IsHardDisabled and DA_IsHardDisabled() then
      local cf = (DEFAULT_CHAT_FRAME or ChatFrame1)
      if cf then
        local missing = DA_GetMissingRequiredMods()
        local list = table.concat(missing, ", ")
        cf:AddMessage("|cff6FA8DCDoiteAuras:|r 已禁用，因为缺少所需模组（" .. list .. "）。")
      end
      return
    end

    if DoiteAurasFrame and DoiteAurasFrame:IsShown() then
      DoiteAurasFrame:Hide()
    else
      -- 居中打开逻辑（保持步骤 #1 行为）
      if DoiteAurasFrame then
        DoiteAurasFrame:ClearAllPoints()
        DoiteAurasFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        DoiteAurasFrame:Show()

        -- 重要：/da 在打开时调用 RefreshList()；小地图必须执行相同操作
        RefreshList()
      end
    end
  end)


  -- 工具提示
  btn:SetScript("OnEnter", function()
    GameTooltip:SetOwner(btn, "ANCHOR_LEFT")
    GameTooltip:AddLine("DOITEAURAS", 0.435, 0.659, 0.863) -- #6FA8DC = DoiteAuras 颜色 - 个人笔记
    GameTooltip:AddLine("点击打开 DoiteAuras", 1, 1, 1)
    GameTooltip:AddLine("版本: " .. tostring(DA_GetVersion()), 0.9, 0.9, 0.9)
    GameTooltip:Show()
  end)
  btn:SetScript("OnLeave", function()
    if GameTooltip:IsOwned(btn) then GameTooltip:Hide() end
  end)

  -- 初始放置
  _DA_PlaceMini(btn)
end

-- 在加载时创建/显示
local _daMiniInit = CreateFrame("Frame", "DoiteMiniInit")
_daMiniInit:RegisterEvent("ADDON_LOADED")
_daMiniInit:SetScript("OnEvent", function()
  if event ~= "ADDON_LOADED" or arg1 ~= "DoiteAuras" then return end
  DA_CreateMinimapButton()
end)

-- /slash 命令
SLASH_DOITEAURAS1="/da"
SLASH_DOITEAURAS2="/doiteaurs"
SLASH_DOITEAURAS3="/doiteaura"
SLASH_DOITEAURAS4="/doite"

SlashCmdList["DOITEAURAS"] = function(msg)
  -- msg 是普通字符串，没有方法
  msg = msg or ""
  msg = string.lower(msg)

  -- 拆分为第一个单词（cmd）和其余部分（参数）
  local cmd, rest
  local firstSpace = string.find(msg, " ", 1, true)
  if firstSpace then
    cmd  = string.sub(msg, 1, firstSpace - 1)
    rest = string.sub(msg, firstSpace + 1)
  else
    cmd  = msg
    rest = ""
  end

  -- 修剪 rest 周围的空白
  rest = string.gsub(rest, "^%s+", "")
  rest = string.gsub(rest, "%s+$", "")

  -- /da debug
  if cmd == "debug" then
    local fn = _G["DoiteTrack_SetNPDebug"]
    if type(fn) == "function" then
      local cur = (_G["DoiteTrack_NPDebug"] and true or false)
      fn(not cur)
    else
      local cf = (DEFAULT_CHAT_FRAME or ChatFrame1)
      if cf then
        cf:AddMessage("|cff6FA8DCDoiteAuras:|r debug 切换不可用（DoiteTrack 未加载？）。")
      end
    end
    return
  end

  -- 正常 DoiteAuras 切换
  if DA_IsHardDisabled() then
    local cf = (DEFAULT_CHAT_FRAME or ChatFrame1)
    if cf then
      local missing = DA_GetMissingRequiredMods()
      local list = table.concat(missing, ", ")
      cf:AddMessage("|cff6FA8DCDoiteAuras:|r 已禁用，因为缺少所需模组（" .. list .. "）。")
    end
    return
  end

  if frame:IsShown() then
    frame:Hide()
  else
    -- 打开时始终（重新）居中
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:Show()
    RefreshList()
  end
end

-- =========================
-- 版本 WHO (/daversionwho)
-- =========================
local DA_PREFIX = "DOITEAURAS"

local function DA_GetVersion_Safe()
  -- 如果存在，重用现有 DA_GetVersion()（小地图部分定义它）
  if type(DA_GetVersion) == "function" then
    return DA_GetVersion() or "?"
  end
  local v = (GetAddOnMetadata and GetAddOnMetadata("DoiteAuras", "Version")) or (DoiteAuras_Version) or "?"
  return v or "?"
end

local function DA_BroadcastVersionAll()
  if not SendAddonMessage then return end
  if UnitInRaid and UnitInRaid("player") then
    SendAddonMessage(DA_PREFIX, "DA_VER:" .. tostring(DA_GetVersion_Safe()), "RAID")
  elseif GetNumPartyMembers and GetNumPartyMembers() > 0 then
    SendAddonMessage(DA_PREFIX, "DA_VER:" .. tostring(DA_GetVersion_Safe()), "PARTY")
  elseif IsInGuild and IsInGuild() then
    SendAddonMessage(DA_PREFIX, "DA_VER:" .. tostring(DA_GetVersion_Safe()), "GUILD")
  end
end

-- 版本比较辅助函数
local function DA_ParseVersion(v)
  local s = tostring(v or "")
  local _, _, a, b, c = string.find(s, "^(%d+)%.(%d+)%.?(%d*)$")

  return tonumber(a) or 0, tonumber(b) or 0, tonumber(c) or 0
end

local function DA_IsNewer(v1, v2)
  local a1,b1,c1 = DA_ParseVersion(v1)
  local a2,b2,c2 = DA_ParseVersion(v2)
  if a1 ~= a2 then return a1 > a2 end
  if b1 ~= b2 then return b1 > b2 end
  return c1 > c2
end
local _daVerNotifiedOnce = false
local _daVerLastEcho = 0

-- /daversionwho：要求其他人报告其版本（静默：只有请求者打印）
SLASH_DAVERSIONWHO1 = "/daversionwho"
SlashCmdList["DAVERSIONWHO"] = function()
  local cf = (DEFAULT_CHAT_FRAME or ChatFrame1)
  local me = (UnitName and UnitName("player")) or nil

  if cf then
    cf:AddMessage("|cff6FA8DCDoiteAuras:|r 版本 WHO 已发送。正在监听回复...")
  end

  local sent = false
  if me and me ~= "" then
    local rid = tostring(((GetTime and GetTime()) or 0)) -- 请求 ID，以避免冲突

    -- 本地存储，以便只有此客户端打印匹配的回复
    _G["DoiteAuras_WhoRid"] = rid

    if UnitInRaid and UnitInRaid("player") then
      SendAddonMessage(DA_PREFIX, "DA_WHO:" .. me .. ":" .. rid, "RAID");  sent = true
    elseif GetNumPartyMembers and GetNumPartyMembers() > 0 then
      SendAddonMessage(DA_PREFIX, "DA_WHO:" .. me .. ":" .. rid, "PARTY"); sent = true
    elseif IsInGuild and IsInGuild() then
      SendAddonMessage(DA_PREFIX, "DA_WHO:" .. me .. ":" .. rid, "GUILD"); sent = true
    end
  end

  if not sent and cf then
    cf:AddMessage("|cff6FA8DCDoiteAuras:|r 没有可用的频道（团队/队伍/公会）。")
  end
end

-- 小延迟运行器
function DA_RunLater(delay, func)
  local f = CreateFrame("Frame")
  local acc = 0
  f:SetScript("OnUpdate", function()
    acc = acc + arg1
    if acc >= delay then
      f:SetScript("OnUpdate", nil)
      if type(func) == "function" then pcall(func) end
    end
  end)
end

-- 版本事件监听器（比较，通知，回显回复）
local _daVer = CreateFrame("Frame", "DoiteVersion")
_daVer:RegisterEvent("CHAT_MSG_ADDON")
_daVer:SetScript("OnEvent", function()
  if event ~= "CHAT_MSG_ADDON" then return end
  local prefix, text, channel, sender = arg1, arg2, arg3, arg4
  if prefix ~= DA_PREFIX or type(text) ~= "string" then return end

  local mine = tostring(DA_GetVersion_Safe())
  local cf   = (DEFAULT_CHAT_FRAME or ChatFrame1)

  -- WHO 请求："DA_WHO:<requesterName>:<rid>"
  if string.sub(text, 1, 7) == "DA_WHO:" then
    local payload = string.sub(text, 8) or ""
    local _, _, requester, rid = string.find(payload, "^([^:]+)%:(.+)$")

    if requester and requester ~= "" and rid and rid ~= "" and channel and SendAddonMessage then
      -- 在相同频道上回复（RAID/PARTY/GUILD）。每个人都会回复，但只有请求者会打印。
      SendAddonMessage(DA_PREFIX, "DA_ME:" .. requester .. ":" .. rid .. ":" .. mine, channel)
    end
    return
  end

  -- WHO 回复："DA_ME:<requesterName>:<rid>:<version>"
  if string.sub(text, 1, 6) == "DA_ME:" then
    local payload = string.sub(text, 7) or ""
    local _, _, requester, rid, other = string.find(payload, "^([^:]+)%:([^:]+)%:(.*)$")

    local meName = (UnitName and UnitName("player")) or ""
    local myRid  = _G["DoiteAuras_WhoRid"]

    -- 只有发起此 rid 的请求者打印。
    if requester and requester == meName and rid and myRid and rid == myRid then
      if cf then
        cf:AddMessage(string.format("|cff6FA8DCDoiteAuras:|r %s 拥有 %s（你拥有 %s）", tostring(sender or "?"), tostring(other or "?"), tostring(mine)))
      end

      -- 如果对方的版本比我的新，则通知一次（仅请求者）
      if (not _daVerNotifiedOnce) and DA_IsNewer(other, mine) then
        _daVerNotifiedOnce = true
        DA_RunLater(8, function()
          if cf then
            cf:AddMessage(string.format("|cff6FA8DCDoiteAuras:|r 有更新的版本可用（你的版本：%s，最新见到的：%s）。考虑更新：https://github.com/Player-Doite/DoiteAuras", tostring(mine), tostring(other)))
          end
        end)
      end
    end

    return
  end

  if string.sub(text, 1, 7) == "DA_VER:" then
    local other = string.sub(text, 8)
    -- 如果对方的版本比我的新，则通知一次
    if (not _daVerNotifiedOnce) and DA_IsNewer(other, mine) then
      _daVerNotifiedOnce = true
      DA_RunLater(8, function()
        if cf then
          cf:AddMessage(string.format("|cff6FA8DCDoiteAuras:|r 有更新的版本可用（你的版本：%s，最新见到的：%s）。考虑更新：https://github.com/Player-Doite/DoiteAuras", tostring(mine), tostring(other)))
        end
      end)
    end
    -- 回显我的版本（速率限制），以便其他人也看到我的版本
    if channel and SendAddonMessage then
      local now = (GetTime and GetTime()) or 0
      if now - _daVerLastEcho > 10 then
        _daVerLastEcho = now
        SendAddonMessage(DA_PREFIX, "DA_VER:" .. mine, channel)
      end
    end
    return
  end
end)


-- 加载消息 + 延迟版本广播
local _daRaidAnnounced = false

local _daLoad = CreateFrame("Frame", "DoiteLoad")
_daLoad:RegisterEvent("ADDON_LOADED")
_daLoad:RegisterEvent("PLAYER_ENTERING_WORLD")
_daLoad:RegisterEvent("RAID_ROSTER_UPDATE")

_daLoad:SetScript("OnEvent", function()
  if event == "ADDON_LOADED" and arg1 == "DoiteAuras" then
    -- 加载后 1 秒：运行现代模组检查，然后打印“已加载”或“缺失”行
    DA_RunLater(1, function()
      local cf = (DEFAULT_CHAT_FRAME or ChatFrame1)
      if not cf then return end

      local missing = DA_GetMissingRequiredMods()

      if table.getn(missing) == 0 then
        -- 所有所需模组都存在 → 正常加载消息
        local v = tostring(DA_GetVersion_Safe())
        cf:AddMessage("|cff6FA8DCDoiteAuras|r v"..v.." 已加载。使用 |cffffff00/da|r（或小地图图标）。")
      else
        -- 一个或多个缺失 → 现代客户端需求消息
        local list = table.concat(missing, ", ")
        cf:AddMessage("|cff6FA8DCDoiteAuras:|r 此插件需要 Nampower 4.1.3+。缺失：" .. list .. "。")
        -- 阻塞器：打印消息后，硬禁用插件
        _G["DoiteAuras_HardDisabled"] = true

        -- 如果存在，隐藏配置框架和任何图标
        if DoiteAurasFrame and DoiteAurasFrame.Hide then
          DoiteAurasFrame:Hide()
        end
        if icons then
          for _, f in pairs(icons) do
            if f and f.Hide then f:Hide() end
          end
        end
      end
    end)

  elseif event == "PLAYER_ENTERING_WORLD" then
    -- 进入世界后 10 秒：向可用频道广播我的版本
    DA_RunLater(10, function()
      DA_BroadcastVersionAll()
    end)

  elseif event == "RAID_ROSTER_UPDATE" then
    -- 玩家首次进入团队时：约 3 秒后在 RAID 上宣布
    if not _daRaidAnnounced and UnitInRaid and UnitInRaid("player") then
      _daRaidAnnounced = true
      DA_RunLater(3, function()
        if SendAddonMessage then
          SendAddonMessage("DOITEAURAS", "DA_VER:"..tostring(DA_GetVersion_Safe()), "RAID")
        end
      end)
    end
  end
end)

-- 频繁更新图标
local updateFrame = CreateFrame("Frame", "DoiteUpdateFrame")
updateFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
updateFrame:SetScript("OnEvent", function()
  if DA_IsHardDisabled and DA_IsHardDisabled() then return end
  if event == "PLAYER_ENTERING_WORLD" then RefreshIcons() end
end)

RebuildOrder(); RefreshList(); RefreshIcons()

DoiteAuras_RefreshList  = RefreshList
DoiteAuras_RefreshIcons = RefreshIcons

-- 可重用候选列表/池
local _daCandidates_list = {}
local _daCandidates_pool = {}

local function _daClearArray(t)
    local i = 1
    while t[i] ~= nil do
        t[i] = nil
        i = i + 1
    end
end

function DoiteAuras.GetAllCandidates()
    if DA_IsHardDisabled and DA_IsHardDisabled() then
        return {}
    end

    local list = _daCandidates_list
    local pool = _daCandidates_pool
    _daClearArray(list)

    local editKey   = _G["DoiteEdit_CurrentKey"]
    local editFrame = _G["DoiteEdit_Frame"] or _G["DoiteEditMain"] or _G["DoiteEdit"]
    local editOpen  = (editFrame and editFrame.IsShown and editFrame:IsShown() == 1)
    local testAll   = (_G["DoiteAuras_TestAll"] == true)

    local n = 0
    for key, data in pairs(DoiteAurasDB.spells or {}) do
        -- 跳过其桶被禁用的条目，除非辅助函数不存在
        if (not DoiteAuras_IsKeyDisabled) or (not DoiteAuras_IsKeyDisabled(key)) then
            local f = (DoiteAuras_GetIconFrame and DoiteAuras_GetIconFrame(key)) or _G["DoiteIcon_" .. key]

            local wants = false
            if f then
                wants = (f._daShouldShow == true) or (f._daSliding == true)
            end
          -- 全部测试时：强制将编辑的键放入池中，以便组可以放置它
            if testAll then
                wants = true
            end
            -- 编辑时：强制将编辑的键放入池中，以便组可以放置它
            if editOpen and editKey == key then
                wants = true
            end

            n = n + 1
            local e = pool[n]
            if not e then
                e = {}
                pool[n] = e
            end

            e.key  = key
            e.data = data
            e.show = wants
            e.tex  = (f and f.icon and f.icon:GetTexture()) or nil
            e.size = data.iconSize or data.size or 36

            list[n] = e
        end
    end

    return list
end

-- 确保给定键的图标框架存在（无可见性更改）
function DoiteAuras_TouchIcon(key)
  if not key then return end
  if DA_IsHardDisabled and DA_IsHardDisabled() then return end
  local name = "DoiteIcon_"..key
  if _G[name] then return end
  if CreateOrUpdateIcon then CreateOrUpdateIcon(key, 36) end
end