---------------------------------------------------------------
-- DoiteLogic.lua
-- 用于“编辑中”技能/光环条件的通用布尔组合器
-- 请尊重许可说明：使用前请询问
-- WoW 1.12 | Lua 5.0
---------------------------------------------------------------

local DoiteLogic = _G["DoiteLogic"] or {}
_G["DoiteLogic"] = DoiteLogic

---------------------------------------------------------------
-- 小辅助函数
---------------------------------------------------------------
-- 逻辑编辑器和 DoiteEdit 使用的全局辅助函数

function _DA_Logic_GetAuraListForType(typeKey)
  if not DoiteAurasDB or not DoiteAurasDB.spells then
    return nil
  end
  if not DoiteEdit_CurrentKey then
    return nil
  end

  local key = DoiteEdit_CurrentKey
  local d = DoiteAurasDB.spells[key]
  if not d then
    return nil
  end
  d.conditions = d.conditions or {}

  if d.type == "Ability" or typeKey == "ability" then
    d.conditions.ability = d.conditions.ability or {}
    d.conditions.ability.auraConditions = d.conditions.ability.auraConditions or {}
    return d.conditions.ability.auraConditions

  elseif d.type == "Item" or typeKey == "item" then
    d.conditions.item = d.conditions.item or {}
    d.conditions.item.auraConditions = d.conditions.item.auraConditions or {}
    return d.conditions.item.auraConditions

  else
    -- Buff/Debuff / "aura"
    d.conditions.aura = d.conditions.aura or {}
    d.conditions.aura.auraConditions = d.conditions.aura.auraConditions or {}
    return d.conditions.aura.auraConditions
  end
end

local function _len(t)
  if not t then
    return 0
  end
  local n = 0
  while t[n + 1] ~= nil do
    n = n + 1
  end
  return n
end

local function _push(t, v)
  t[_len(t) + 1] = v
end

local function _GetOpForEntry(entry)
  if not entry or not entry.logicOp then
    return "AND"
  end
  local op = entry.logicOp
  if op == "OR" or op == "or" then
    return "OR"
  end
  return "AND"
end

local function _HasAnyLogicHints(list)
  local n = _len(list)
  if n == 0 then
    return false
  end
  local i = 1
  while i <= n do
    local e = list[i]
    if e and (e.logicOp or e.parenOpen or e.parenClose) then
      return true
    end
    i = i + 1
  end
  return false
end

-- 括号专用辅助函数
local function _HasAnyParenHints(list)
  local n = _len(list)
  if n == 0 then
    return false
  end
  local i = 1
  while i <= n do
    local e = list[i]
    if e and (e.parenOpen or e.parenClose) then
      return true
    end
    i = i + 1
  end
  return false
end

local function _IsParenStructureValid(list)
  local n = _len(list)
  local openCount = 0
  local i = 1
  local valid = true

  while i <= n do
    local e = list[i]

    if e and e.parenOpen then
      openCount = openCount + 1
    end

    if e and e.parenClose then
      if openCount <= 0 then
        valid = false
        break
      else
        openCount = openCount - 1
      end
    end

    i = i + 1
  end

  if openCount ~= 0 then
    valid = false
  end

  return valid
end

local function _ResetLogicToStrictAnd(list)
  -- 清除所有 AND/OR 和括号提示；评估将回退到纯 AND
  local n = _len(list)
  local i = 1
  while i <= n do
    local e = list[i]
    if e then
      e.logicOp = nil
      e.parenOpen = nil
      e.parenClose = nil
    end
    i = i + 1
  end
end

local function _NotifyLogicResetForCurrentSpell()
  if not DEFAULT_CHAT_FRAME or not DEFAULT_CHAT_FRAME.AddMessage then
    return
  end
  if not DoiteAurasDB or not DoiteAurasDB.spells or not DoiteEdit_CurrentKey then
    return
  end

  local d = DoiteAurasDB.spells[DoiteEdit_CurrentKey]
  if not d then
    return
  end

  local displayName = d.displayName or DoiteEdit_CurrentKey

  -- DoiteAuras 蓝色：#6FA8DC -> FF6FA8DC
  local prefix = "|cFF6FA8DCDoiteAuras:|r "
  local body = "|cFFFFFFFF通过删除具有依赖 AND/OR 逻辑的条件，所有逻辑已重置为|r"
  local name = ""
  if displayName then
    name = " |cFFFFFF00" .. displayName .. "|r."
  end

  DEFAULT_CHAT_FRAME:AddMessage(prefix .. body .. name)
end

-- 公开辅助函数：由 DoiteEdit 在删除条件行后使用。
function DoiteLogic.ValidateOrResetCurrentLogic(typeKey)
  if not typeKey then
    return
  end
  local list = _DA_Logic_GetAuraListForType(typeKey)
  if not list then
    return
  end

  if _HasAnyParenHints(list) and not _IsParenStructureValid(list) then
    _ResetLogicToStrictAnd(list)
    _NotifyLogicResetForCurrentSpell()
  end
end

---------------------------------------------------------------
-- 调度场算法：中缀 -> RPN
---------------------------------------------------------------
local _precedence = {
  AND = 2,
  OR = 1,
}

-- 临时表，以消除每次评估的分配（tokens/RPN/栈）
local _DA_TMP_RPN_OUT = {}
local _DA_TMP_OP_STACK = {}
local _DA_TMP_EVAL_STACK = {}
local _DA_TMP_TOKENS = {}

local function _DA_WipeArray(t)
  local i = _len(t)
  while i > 0 do
    t[i] = nil
    i = i - 1
  end
end

local function _ToRpn(tokens, output, stack)
  output = output or _DA_TMP_RPN_OUT
  stack = stack or _DA_TMP_OP_STACK

  _DA_WipeArray(output)
  _DA_WipeArray(stack)

  local n = _len(tokens)
  local i = 1
  while i <= n do
    local tok = tokens[i]

    if tok == true or tok == false then
      _push(output, tok)

    elseif tok == "AND" or tok == "OR" then
      local pTok = _precedence[tok] or 1

      while _len(stack) > 0 do
        local top = stack[_len(stack)]
        if top == "AND" or top == "OR" then
          local pTop = _precedence[top] or 1
          if pTop >= pTok then
            _push(output, top)
            stack[_len(stack)] = nil
          else
            break
          end
        else
          break
        end
      end

      _push(stack, tok)

    elseif tok == "(" then
      _push(stack, tok)

    elseif tok == ")" then
      local found = false
      while _len(stack) > 0 do
        local top = stack[_len(stack)]
        stack[_len(stack)] = nil

        if top == "(" then
          found = true
          break
        else
          _push(output, top)
        end
      end
      if not found then
        error("DoiteLogic: 不匹配的 ')'")
      end
    end

    i = i + 1
  end

  while _len(stack) > 0 do
    local top = stack[_len(stack)]
    stack[_len(stack)] = nil

    if top == "(" or top == ")" then
      error("DoiteLogic: 不匹配的 '('")
    end

    _push(output, top)
  end

  return output
end

---------------------------------------------------------------
-- RPN 评估
---------------------------------------------------------------
local function _EvalRpn(rpn, st)
  st = st or _DA_TMP_EVAL_STACK
  _DA_WipeArray(st)

  local n = _len(rpn)
  local i = 1

  while i <= n do
    local tok = rpn[i]

    if tok == true or tok == false then
      _push(st, tok)

    elseif tok == "AND" or tok == "OR" then
      local sb = _len(st)
      if sb < 2 then
        error("DoiteLogic: 操作数不足")
      end
      local b = st[sb];
      st[sb] = nil
      local a = st[sb - 1];
      st[sb - 1] = nil

      local v
      if tok == "AND" then
        v = (a and b) and true or false
      else
        v = (a or b) and true or false
      end

      _push(st, v)
    end

    i = i + 1
  end

  if _len(st) ~= 1 then
    error("DoiteLogic: RPN 栈状态错误")
  end

  return (st[1] == true)
end

local function _EvaluateStrictAnd(list, n, evalFunc)
  local i = 1
  while i <= n do
    if not evalFunc(list[i]) then
      return false
    end
    i = i + 1
  end
  return true
end

---------------------------------------------------------------
-- 通用评估器
---------------------------------------------------------------
function DoiteLogic.EvaluateGeneric(list, evalFunc)
  if not list then
    return true
  end

  local n = _len(list)
  if n == 0 then
    return true
  end

  evalFunc = evalFunc or function(e)
    return e ~= nil
  end

  if not _HasAnyLogicHints(list) then
    return _EvaluateStrictAnd(list, n, evalFunc)
  end

  if _HasAnyParenHints(list) and not _IsParenStructureValid(list) then
    _ResetLogicToStrictAnd(list)
    _NotifyLogicResetForCurrentSpell()

    -- 重置后不再有逻辑提示，因此回退到简单的 AND 行为。
    return _EvaluateStrictAnd(list, n, evalFunc)
  end

  -- 重用临时令牌缓冲区，以避免每次调用分配
  local tokens = _DA_TMP_TOKENS
  _DA_WipeArray(tokens)

  local i = 1
  while i <= n do
    local e = list[i]
    local val = (evalFunc(e) == true)

    if e and e.parenOpen then
      _push(tokens, "(")
    end

    _push(tokens, val)

    if e and e.parenClose then
      _push(tokens, ")")
    end

    if i < n then
      local op = _GetOpForEntry(e)
      _push(tokens, op)
    end

    i = i + 1
  end

  local ok, rpn = pcall(_ToRpn, tokens, _DA_TMP_RPN_OUT, _DA_TMP_OP_STACK)
  if not ok or not rpn then
    return _EvaluateStrictAnd(list, n, evalFunc)
  end

  local ok2, res = pcall(_EvalRpn, rpn, _DA_TMP_EVAL_STACK)
  if not ok2 then
    return _EvaluateStrictAnd(list, n, evalFunc)
  end

  return (res == true)
end

---------------------------------------------------------------
-- 光环专用辅助函数
---------------------------------------------------------------
function DoiteLogic.EvaluateAuraList(list, evalFunc)
  return DoiteLogic.EvaluateGeneric(list, evalFunc)
end

---------------------------------------------------------------
-- 标签 + 预览辅助函数（由 DoiteEdit 使用）
---------------------------------------------------------------
local function _BuildLabelForEntry(entry, index)
  if not entry then
    return "#" .. tostring(index or 0)
  end

  local kind = entry.buffType or "BUFF"
  local mode = entry.mode or ""
  local unit = entry.unit or ""
  local name = entry.name or ("#" .. tostring(index or 0))

  local kindText
  if kind == "ABILITY" then
    kindText = "技能"
  elseif kind == "DEBUFF" then
    kindText = "减益"
  elseif kind == "TALENT" then
    kindText = "天赋"
  else
    kindText = "增益"
  end

  local modeText = ""
  if mode == "oncd" then
    modeText = "冷却中"
  elseif mode == "notcd" then
    modeText = "未冷却"
  elseif mode == "missing" then
    modeText = "缺失"
  elseif mode == "both" then
    modeText = "存在或缺失"
  elseif mode == "found" or mode == "" or mode == nil then
    modeText = "已找到"
  else
    -- 规范化天赋模式等。
    local m = tostring(mode or "")
    local lower = string.lower(m)
    if lower == "known" then
      modeText = "已知"
    elseif lower == "notknown" or lower == "not known" then
      modeText = "未知"
    else
      modeText = m
    end
  end

  local unitText = ""
  local selfKind = (kind == "ABILITY" or kind == "TALENT")

  if selfKind then
    unitText = "玩家"
  else
    if unit == "target" then
      unitText = "对目标"
    elseif unit == "player" or unit == "" or unit == nil then
      unitText = "对玩家"
    end
  end

  local parts = {}
  _push(parts, kindText .. ": " .. name)
  if modeText ~= "" then
    _push(parts, "(" .. modeText .. ")")
  end
  if unitText ~= "" then
    _push(parts, "(" .. unitText .. ")")
  end

  return table.concat(parts, " ")
end

-- 导出：由逻辑编辑器行使用
function DoiteLogic.BuildAuraLabel(entry, index)
  return _BuildLabelForEntry(entry, index)
end

-- 导出：漂亮打印整个表达式
function DoiteLogic.BuildAuraPreview(list)
  if not list then
    return ""
  end
  local n = _len(list)
  if n == 0 then
    return ""
  end

  local parts = {}

  -- 仅用于逻辑括号的颜色（外部 + 用户添加），WoW 颜色转义
  local parenOpenColored = "|cFFFFFF00(|r"
  local parenCloseColored = "|cFFFFFF00)|r"

  -- 始终将整个表达式包裹在一对外部彩色括号中
  _push(parts, parenOpenColored)

  local i = 1
  while i <= n do
    local e = list[i]
    local label = _BuildLabelForEntry(e, i)

    -- 此条件前的用户添加的左括号
    if e and e.parenOpen then
      _push(parts, parenOpenColored)
    end

    -- 标签本身
    _push(parts, label)

    -- 此条件后的用户添加的右括号
    if e and e.parenClose then
      _push(parts, parenCloseColored)
    end

    if i < n then
      local op = _GetOpForEntry(e)
      -- 将 AND/OR 着色为绿色
      local opColored = "|cFF00FF00" .. op .. "|r"
      _push(parts, opColored)
    end

    i = i + 1
  end

  -- 关闭外部彩色括号
  _push(parts, parenCloseColored)

  return table.concat(parts, " ")
end

---------------------------------------------------------------
-- 光环逻辑编辑器 UI
---------------------------------------------------------------

-- 本地辅助函数，以便 DoiteLogic 不硬性要求 SafeRefresh/SafeEvaluate
local function _DA_Logic_SafeRefreshAndEvaluate()
  if type(SafeRefresh) == "function" then
    SafeRefresh()
  end
  if type(SafeEvaluate) == "function" then
    SafeEvaluate()
  end
end

-- 局部变量，模块作用域
local DoiteAuraLogicFrame = nil
local DoiteAuraLogic_CurrentType = nil
local DoiteAuraLogic_BackupList = nil

-- 列表的浅拷贝（基于索引）
local function _DeepCopyAuraList(list)
  if not list then
    return nil
  end
  local out = {}
  local i = 1
  while list[i] do
    local src = list[i]
    if type(src) == "table" then
      local dst = {}
      for k, v in pairs(src) do
        dst[k] = v
      end
      out[i] = dst
    else
      out[i] = src
    end
    i = i + 1
  end
  return out
end

local function DoiteAuraLogic_UpdatePreview()
  if not DoiteAuraLogicFrame or not DoiteAuraLogic_CurrentType then
    return
  end

  local list = _DA_Logic_GetAuraListForType(DoiteAuraLogic_CurrentType)
  if not list then
    DoiteAuraLogicFrame.preview:SetText("")
    return
  end

  local txt = ""
  if DoiteLogic.BuildAuraPreview then
    txt = DoiteLogic.BuildAuraPreview(list) or ""
  end
  DoiteAuraLogicFrame.preview:SetText(txt)
end

-- 重新计算括号有效性，将无效的 ')' 变灰，并启用/禁用应用按钮
local function DoiteAuraLogic_RecomputeParenAndApplyState()
  if not DoiteAuraLogicFrame or not DoiteAuraLogic_CurrentType then
    return
  end

  local list = _DA_Logic_GetAuraListForType(DoiteAuraLogic_CurrentType)
  if not list then
    if DoiteAuraLogicFrame.okButton then
      DoiteAuraLogicFrame.okButton:Disable()
    end
    return
  end

  local n = _len(list)
  local openCount = 0
  local valid = true
  local rows = DoiteAuraLogicFrame.rows or {}

  local i = 1
  while i <= n do
    local e = list[i]
    local row = rows[i]

    -- 先计数左括号
    if e and e.parenOpen then
      openCount = openCount + 1
    end

    local hasUnmatchedOpen = (openCount > 0)

    -- 为此行灰显/启用右括号按钮
    if row and row.parenClose then
      if hasUnmatchedOpen then
        row.parenClose:Enable()
        if row.parenClose.text then
          row.parenClose.text:SetTextColor(1, 0.82, 0)
        end
      else
        row.parenClose:Disable()
        if row.parenClose.text then
          row.parenClose.text:SetTextColor(0.4, 0.4, 0.4)
        end
      end
    end

    -- 然后处理实际的右括号以进行有效性检查
    if e and e.parenClose then
      if openCount <= 0 then
        -- 此时右括号多于左括号 -> 无效
        valid = false
      else
        openCount = openCount - 1
      end
    end

    i = i + 1
  end

  -- 最后一个条件之后，左括号必须完全关闭
  if openCount ~= 0 then
    valid = false
  end

  -- 根据有效性切换应用按钮
  if DoiteAuraLogicFrame.okButton then
    if valid then
      DoiteAuraLogicFrame.okButton:Enable()
    else
      DoiteAuraLogicFrame.okButton:Disable()
    end
  end
end

local function DoiteAuraLogic_BuildRow(frame, index)
  local row = frame.rows[index]
  if row then
    return row
  end

  -- 将行父级设置为滚动子级（如果存在），否则设置为框架本身
  local parent = frame.scrollChild or frame

  row = CreateFrame("Frame", nil, parent)
  row:SetHeight(18)

  -- 在可滚动区域内定位
  local y = -4 - (index - 1) * 20
  row:SetPoint("TOPLEFT", parent, "TOPLEFT", 4, y)
  row:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -4, y)

  -- "(" 复选框
  row.parenOpen = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
  row.parenOpen:SetWidth(18);
  row.parenOpen:SetHeight(18)
  row.parenOpen:SetPoint("LEFT", row, "LEFT", 0, 0)
  row.parenOpen.text = row.parenOpen:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  row.parenOpen.text:SetPoint("LEFT", row.parenOpen, "RIGHT", 2, 0)
  row.parenOpen.text:SetText("(")

  -- ")" 复选框
  row.parenClose = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
  row.parenClose:SetWidth(18);
  row.parenClose:SetHeight(18)
  row.parenClose:SetPoint("LEFT", row.parenOpen.text, "RIGHT", 12, 0)
  row.parenClose.text = row.parenClose:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  row.parenClose.text:SetPoint("LEFT", row.parenClose, "RIGHT", 2, 0)
  row.parenClose.text:SetText(")")

  -- AND
  row.andCB = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
  row.andCB:SetWidth(18);
  row.andCB:SetHeight(18)
  row.andCB:SetPoint("LEFT", row.parenClose.text, "RIGHT", 12, 0)
  row.andFS = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  row.andFS:SetPoint("LEFT", row.andCB, "RIGHT", 2, 0)
  row.andFS:SetText("AND")

  -- OR
  row.orCB = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
  row.orCB:SetWidth(18);
  row.orCB:SetHeight(18)
  row.orCB:SetPoint("LEFT", row.andFS, "RIGHT", 12, 0)
  row.orFS = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  row.orFS:SetPoint("LEFT", row.orCB, "RIGHT", 2, 0)
  row.orFS:SetText("OR")

  -- 标签
  row.labelFS = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  row.labelFS:SetPoint("LEFT", row.orFS, "RIGHT", 12, 0)
  row.labelFS:SetPoint("RIGHT", row, "RIGHT", 0, 0)
  row.labelFS:SetJustifyH("LEFT")
  row.labelFS:SetNonSpaceWrap(false)

  -- 脚本（使用在 OpenAuraLogicEditor 中设置的 row._index）
  row.parenOpen:SetScript("OnClick", function()
    if not DoiteAuraLogic_CurrentType then
      return
    end
    local list = _DA_Logic_GetAuraListForType(DoiteAuraLogic_CurrentType)
    if not list or not row._index or not list[row._index] then
      return
    end

    list[row._index].parenOpen = this:GetChecked() and true or nil
    DoiteAuraLogic_UpdatePreview()
    DoiteAuraLogic_RecomputeParenAndApplyState()
    _DA_Logic_SafeRefreshAndEvaluate()
  end)

  row.parenClose:SetScript("OnClick", function()
    if not DoiteAuraLogic_CurrentType then
      return
    end
    local list = _DA_Logic_GetAuraListForType(DoiteAuraLogic_CurrentType)
    if not list or not row._index or not list[row._index] then
      return
    end

    list[row._index].parenClose = this:GetChecked() and true or nil
    DoiteAuraLogic_UpdatePreview()
    DoiteAuraLogic_RecomputeParenAndApplyState()
    _DA_Logic_SafeRefreshAndEvaluate()
  end)

  row.andCB:SetScript("OnClick", function()
    if not DoiteAuraLogic_CurrentType then
      return
    end
    local list = _DA_Logic_GetAuraListForType(DoiteAuraLogic_CurrentType)
    if not list or not row._index or not list[row._index] then
      return
    end

    local idx = row._index
    local n = _len(list)
    if idx >= n then
      this:SetChecked(false)
      return
    end

    if this:GetChecked() then
      row.orCB:SetChecked(false)
      list[idx].logicOp = "AND"
    else
      -- 至少保留一个操作符；默认为 AND
      this:SetChecked(true)
      list[idx].logicOp = "AND"
    end
    DoiteAuraLogic_UpdatePreview()
    _DA_Logic_SafeRefreshAndEvaluate()
  end)

  row.orCB:SetScript("OnClick", function()
    if not DoiteAuraLogic_CurrentType then
      return
    end
    local list = _DA_Logic_GetAuraListForType(DoiteAuraLogic_CurrentType)
    if not list or not row._index or not list[row._index] then
      return
    end

    local idx = row._index
    local n = _len(list)
    if idx >= n then
      this:SetChecked(false)
      return
    end

    if this:GetChecked() then
      row.andCB:SetChecked(false)
      list[idx].logicOp = "OR"
    else
      -- 至少保留一个操作符；默认为 AND
      this:SetChecked(true)
      list[idx].logicOp = "AND"
    end
    DoiteAuraLogic_UpdatePreview()
    _DA_Logic_SafeRefreshAndEvaluate()
  end)

  frame.rows[index] = row
  return row
end

-- 公开：编辑器入口点（DoiteEdit 将调用）
function DoiteLogic.OpenAuraLogicEditor(typeKey)
  if typeKey ~= "ability" and typeKey ~= "aura" and typeKey ~= "item" then
    return
  end

  local list = _DA_Logic_GetAuraListForType(typeKey)
  local count = _len(list)
  if count < 2 then
    -- 没有要组合的内容
    return
  end

  if not DoiteAuraLogicFrame then
    local f = CreateFrame("Frame", "DoiteAuraLogicFrame", UIParent)

    -- 全屏覆盖
    f:SetAllPoints(UIParent)

    -- 强制此窗口在最前面
    if f.SetFrameStrata then
      f:SetFrameStrata("TOOLTIP")
    end
    if UIParent and UIParent.GetFrameLevel and f.SetFrameLevel then
      local lvl = UIParent:GetFrameLevel() or 0
      f:SetFrameLevel(lvl + 1000)
    end

    -- 覆盖整个屏幕的深色背景
    local bg = f:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(f)
    bg:SetTexture(0, 0, 0, 0.90)

    -- 内部内容面板（实际逻辑编辑器 UI）
    local content = CreateFrame("Frame", nil, f)

    -- 使逻辑窗口约为屏幕宽度的 3/4
    local screenWidth = UIParent:GetWidth()
    if not screenWidth or screenWidth <= 0 then
      if type(GetScreenWidth) == "function" then
        screenWidth = GetScreenWidth()
      else
        screenWidth = 1024
      end
    end
    local contentWidth = math.floor(screenWidth * 0.75)

    content:SetWidth(contentWidth)
    content:SetHeight(275)
    content:SetPoint("CENTER", f, "CENTER", 0, 0)
    content:SetBackdrop({
      bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
      edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
      tile = true, tileSize = 16, edgeSize = 16,
    })
    content:SetBackdropColor(0, 0, 0, 0.9)
    f.content = content

    -- 标题
    f.title = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.title:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -10)
    f.title:SetText("添加的技能/增益/减益逻辑")
    -- DoiteAuras 蓝色：#6FA8DC
    f.title:SetTextColor(111 / 255, 168 / 255, 220 / 255)

    -- 提示
    f.hint = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.hint:SetPoint("TOPLEFT", f.title, "BOTTOMLEFT", 0, -6)
    f.hint:SetWidth(contentWidth - 20)
    f.hint:SetJustifyH("LEFT")
    f.hint:SetText("配置你的图标中技能、增益和减益条件之间的与/或关系及括号。你可以在底部看到所选逻辑的预览。")
    f.hint:SetTextColor(1, 1, 1)

    -- === 逻辑行的可滚动容器 ===
    local listContainer = CreateFrame("Frame", nil, content)
    listContainer:SetWidth(content:GetWidth() - 35)
    listContainer:SetHeight(140)
    listContainer:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -50)
    listContainer:SetBackdrop({
      bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
      edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
      tile = true, tileSize = 16, edgeSize = 16,
    })
    listContainer:SetBackdropColor(0, 0, 0, 0.7)

    local scrollFrame = CreateFrame("ScrollFrame", "DoiteAuraLogicScroll", listContainer, "UIPanelScrollFrameTemplate")
    scrollFrame:SetWidth(listContainer:GetWidth() - 24)
    scrollFrame:SetHeight(listContainer:GetHeight() - 15)
    scrollFrame:SetPoint("TOPLEFT", listContainer, "TOPLEFT", 4, -8)

    local scrollChild = CreateFrame("Frame", "DoiteAuraLogicScrollChild", scrollFrame)
    scrollChild:SetWidth(scrollFrame:GetWidth())
    scrollChild:SetHeight(listContainer:GetHeight())
    scrollFrame:SetScrollChild(scrollChild)

    -- 将实际滚动条向右移动一点，离开内部框架边缘
    local scrollBar = _G["DoiteAuraLogicScrollScrollBar"]
    if scrollBar then
      scrollBar:ClearAllPoints()
      scrollBar:SetPoint("TOPLEFT", listContainer, "TOPRIGHT", -4, -18)
      scrollBar:SetPoint("BOTTOMLEFT", listContainer, "BOTTOMRIGHT", -4, 18)
    end

    f.listContainer = listContainer
    f.scrollFrame = scrollFrame
    f.scrollChild = scrollChild

    -- 确保视觉堆叠使背景保持在控件下方
    local baseLevel = content:GetFrameLevel() or 1
    listContainer:SetFrameLevel(baseLevel + 0)
    scrollFrame:SetFrameLevel(baseLevel + 1)
    scrollChild:SetFrameLevel(baseLevel + 2)

    -- 预览文本（顶部对齐，列表下方，更宽）
    f.previewLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.previewLabel:SetPoint("TOPLEFT", listContainer, "BOTTOMLEFT", 10, -8)
    f.previewLabel:SetText("预览：")

    f.preview = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.preview:SetPoint("TOPLEFT", f.previewLabel, "TOPLEFT", 56, 0)
    f.preview:SetWidth(contentWidth - 86)
    f.preview:SetJustifyH("LEFT")

    -- 灰色预览颜色
    f.previewLabel:SetTextColor(0.7, 0.7, 0.7)
    f.preview:SetTextColor(0.7, 0.7, 0.7)

    -- 应用 / 取消
    f.okButton = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    f.okButton:SetWidth(80);
    f.okButton:SetHeight(20)
    f.okButton:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -10, 8)
    f.okButton:SetText("应用")

    f.cancelButton = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    f.cancelButton:SetWidth(80);
    f.cancelButton:SetHeight(20)
    f.cancelButton:SetPoint("RIGHT", f.okButton, "LEFT", -6, 0)
    f.cancelButton:SetText("取消")

    f.rows = {}

    -- Esc 关闭
    if UISpecialFrames then
      table.insert(UISpecialFrames, "DoiteAuraLogicFrame")
    end

    -- 应用：保留更改
    f.okButton:SetScript("OnClick", function()
      if DoiteAuraLogic_CurrentType and AuraCond_RefreshFromDB then
        AuraCond_RefreshFromDB(DoiteAuraLogic_CurrentType)
      end
      _DA_Logic_SafeRefreshAndEvaluate()
      f:Hide()
    end)

    -- 取消：恢复备份列表
    f.cancelButton:SetScript("OnClick", function()
      if DoiteAuraLogic_CurrentType and DoiteAuraLogic_BackupList then
        local list2 = _DA_Logic_GetAuraListForType(DoiteAuraLogic_CurrentType)
        if list2 then
          -- 清除当前
          local i = 1
          while list2[i] do
            list2[i] = nil
            i = i + 1
          end
          -- 复制回来
          i = 1
          while DoiteAuraLogic_BackupList[i] do
            local src = DoiteAuraLogic_BackupList[i]
            local dst = {}
            for k, v in pairs(src) do
              dst[k] = v
            end
            list2[i] = dst
            i = i + 1
          end
        end
        if AuraCond_RefreshFromDB then
          AuraCond_RefreshFromDB(DoiteAuraLogic_CurrentType)
        end
        _DA_Logic_SafeRefreshAndEvaluate()
      end
      f:Hide()
    end)

    DoiteAuraLogicFrame = f
  end

  DoiteAuraLogic_CurrentType = typeKey
  DoiteAuraLogic_BackupList = _DeepCopyAuraList(list)

  -- 构建行
  local i = 1
  while i <= count do
    local entry = list[i]
    local row = DoiteAuraLogic_BuildRow(DoiteAuraLogicFrame, i)
    row._index = i
    row:Show()

    -- 标签
    local label = ""
    if DoiteLogic.BuildAuraLabel then
      label = DoiteLogic.BuildAuraLabel(entry, i) or ""
    else
      label = entry and (entry.name or ("#" .. tostring(i))) or ("#" .. tostring(i))
    end
    row.labelFS:SetText(label)

    -- 括号
    row.parenOpen:SetChecked(entry and entry.parenOpen and true or false)
    row.parenClose:SetChecked(entry and entry.parenClose and true or false)

    -- AND/OR：仅用于行 < 最后一行
    if i < count then
      row.andCB:Enable()
      row.orCB:Enable()
      row.andFS:SetTextColor(1, 0.82, 0)
      row.orFS:SetTextColor(1, 0.82, 0)

      local op = (entry and entry.logicOp) or "AND"
      if op == "OR" or op == "or" then
        row.andCB:SetChecked(false)
        row.orCB:SetChecked(true)
      else
        row.andCB:SetChecked(true)
        row.orCB:SetChecked(false)
      end
    else
      -- 最后一行：无操作符
      row.andCB:SetChecked(false)
      row.orCB:SetChecked(false)
      row.andCB:Disable()
      row.orCB:Disable()
      row.andFS:SetTextColor(0.4, 0.4, 0.4)
      row.orFS:SetTextColor(0.4, 0.4, 0.4)
    end

    i = i + 1
  end

  -- 隐藏未使用的行
  local j = count + 1
  while DoiteAuraLogicFrame.rows[j] do
    DoiteAuraLogicFrame.rows[j]:Hide()
    j = j + 1
  end

  -- 基于行数的滚动子高度（控制滚动条范围）
  local h = 20 + count * 20
  if h < 60 then
    h = 60
  end
  if DoiteAuraLogicFrame.scrollChild then
    DoiteAuraLogicFrame.scrollChild:SetHeight(h)
  end

  -- 确保滚动框架反映高度并从顶部开始
  if DoiteAuraLogicFrame.scrollFrame and DoiteAuraLogicFrame.scrollFrame.UpdateScrollChildRect then
    DoiteAuraLogicFrame.scrollFrame:UpdateScrollChildRect()
    DoiteAuraLogicFrame.scrollFrame:SetVerticalScroll(0)
  end

  DoiteAuraLogic_UpdatePreview()
  DoiteAuraLogic_RecomputeParenAndApplyState()
  DoiteAuraLogicFrame:Show()
end