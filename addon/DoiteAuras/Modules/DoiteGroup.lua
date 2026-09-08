---------------------------------------------------------------
-- DoiteGroup.lua
-- 处理 DoiteAuras 图标的组布局逻辑
-- 请尊重许可说明：使用前请询问
-- WoW 1.12 | Lua 5.0
---------------------------------------------------------------

-- 使用一个全局命名的表（与旧加载器行为兼容）
local DoiteGroup = _G["DoiteGroup"] or {}
_G["DoiteGroup"] = DoiteGroup

---------------------------------------------------------------
-- 辅助函数
---------------------------------------------------------------
local function num(v, default)
  return tonumber(v) or default or 0
end

-- 快速框架获取器（避免在排序/布局热路径中进行 _G["DoiteIcon_"..key] 搅动）
local _GetIconFrame = DoiteAuras_GetIconFrame
if not _GetIconFrame then
  local G = _G
  _GetIconFrame = function(k)
    if not k then
      return nil
    end
    return G["DoiteIcon_" .. k]
  end
end

local function isValidGroupMember(entry)
  if not entry or not entry.data then
    return false
  end
  local g = entry.data.group
  return g and g ~= "" and g ~= "no"
end

local function isKnown(entry)
  -- 技能可能在另一个天赋专精中未知；那时绝不占用槽位
  return not (entry and entry.data and entry.data.isUnknown)
end

-- 解析组的排序模式："prio"（默认）或 "time"
local function GetGroupSortMode(groupName)
  if not groupName then
    return "prio"
  end

  local db = DoiteAurasDB
  if db and db.groupSort and db.groupSort[groupName] then
    local mode = db.groupSort[groupName]
    if mode == "time" then
      return "time"
    end
  end

  return "prio"
end

-- 解析组的固定布局模式（默认为 false）
local function GetGroupFixedMode(groupName, leaderData)
  if groupName and DoiteAurasDB and DoiteAurasDB.groupFixed and DoiteAurasDB.groupFixed[groupName] then
    return true
  end
  if leaderData and leaderData.groupFixed == true then
    return true
  end
  return false
end

local function _ComputeOffset(baseX, baseY, growth, pad, steps)
  local x = baseX
  local y = baseY
  if steps and steps > 0 then
    if growth == "水平向右" then
      x = x + (pad * steps)
    elseif growth == "水平向左" then
      x = x - (pad * steps)
    elseif growth == "垂直向上" then
      y = y + (pad * steps)
    elseif growth == "垂直向下" then
      y = y - (pad * steps)
    else
      x = x + (pad * steps)
    end
  end
  return x, y
end

-- 居中扩展（使整个组围绕 baseX/baseY 居中）
local function _ComputeCenteredOffset(baseX, baseY, growth, pad, index, totalVisible)
  local x = baseX
  local y = baseY

  if not totalVisible or totalVisible <= 0 then
    return x, y
  end

  if growth == "水平居中" then
    local halfCount = totalVisible / 2.0
    local offset = (index - 1) - (halfCount - 0.5)
    x = baseX + (offset * pad)

  elseif growth == "垂直居中" then
    local halfCount = totalVisible / 2.0
    local offset = (index - 1) - (halfCount - 0.5)
    y = baseY + (offset * pad)
  end

  return x, y
end

local function _ApplyPlacement(entry, x, y, size)
  if not entry then
    return
  end

  local pos = entry._computedPos
  if not pos then
    pos = {}
    entry._computedPos = pos
  end
  pos.x = x
  pos.y = y
  pos.size = size

  local f = _GetIconFrame(entry.key)
  if f then
    f._daBlockedByGroup = false
    -- 当此滴答的幻灯片拥有框架时，不要重新锚定
    if not f._daSliding then
      if f._daGroupX ~= x or f._daGroupY ~= y then
        f._daGroupX = x
        f._daGroupY = y
        f:ClearAllPoints()
        f:SetPoint("CENTER", UIParent, "CENTER", x, y)
      end
    end
    if f._daGroupSize ~= size then
      f._daGroupSize = size
      f:SetWidth(size)
      f:SetHeight(size)
    end
  end
end

-- 当前正在编辑的键
local function editingKey()
  return _G["DoiteEdit_CurrentKey"]
end

---------------------------------------------------------------
-- 排序比较器（无每次排序闭包分配）
---------------------------------------------------------------
local _DG = { editKey = nil }

local function _cmpPrio(a, b)
  local editKey = _DG.editKey
  if editKey then
    if a.key == editKey and b.key ~= editKey then
      return true
    end
    if b.key == editKey and a.key ~= editKey then
      return false
    end
  end

  local da = a.data
  local db = b.data
  local oa = (da and da.order) or 999
  local ob = (db and db.order) or 999

  if oa == ob then
    return (a._dgKeyStr or "") < (b._dgKeyStr or "")
  end
  return oa < ob
end

local function _cmpTime(a, b)
  local editKey = _DG.editKey
  if editKey then
    if a.key == editKey and b.key ~= editKey then
      return true
    end
    if b.key == editKey and a.key ~= editKey then
      return false
    end
  end

  local hasA = a._dgHasRem and true or false
  local hasB = b._dgHasRem and true or false

  if hasA ~= hasB then
    return hasA
  end

  if hasA and hasB then
    local ra = a._dgRem
    local rb = b._dgRem
    if ra ~= rb then
      return ra < rb
    end
  end

  -- 回退到 prio 行为
  return _cmpPrio(a, b)
end

---------------------------------------------------------------
-- 计算单个组的布局，由组的组长驱动
---------------------------------------------------------------
local function ComputeGroupLayout(entries, groupName)
  if not entries or table.getn(entries) == 0 then
    return {}
  end

  -- 1) 找到组长；如果没有，则退出（组配置错误）
  local leader = nil
  for _, e in ipairs(entries) do
    if e.data and e.data.isLeader then
      leader = e;
      break
    end
  end
  if not leader then
    return {}
  end

  local L = leader.data
  local baseX = num(L.offsetX, 0)
  local baseY = num(L.offsetY, 0)
  local baseSize = num(L.iconSize, 36)
  local growth = L.growth or "水平向右"
  local limit = num(L.numAuras, 50)
  local fixed = GetGroupFixedMode(groupName, L)
  local settings = (DoiteAurasDB and DoiteAurasDB.settings)
  local spacing = num(L.spacing, (settings and settings.spacing) or 8)
  local pad = baseSize + spacing

  local isCentered = (growth == "水平居中" or growth == "垂直居中")

  -- 2) 构建池：已知（用于固定槽位）和可见已知（用于实际放置）
  local fixedKnown
  if fixed then
    fixedKnown = DoiteGroup._tmpAllKnown
    if not fixedKnown then
      fixedKnown = {}
      DoiteGroup._tmpAllKnown = fixedKnown
    else
      for i = table.getn(fixedKnown), 1, -1 do
        fixedKnown[i] = nil
      end
    end
  end

  -- 构建既已知又*想要*显示的物品池（条件 OR 滑动） - 重用和缩小表而不重新分配
  local visibleKnown = DoiteGroup._tmpVisibleKnown
  if not visibleKnown then
    visibleKnown = {}
    DoiteGroup._tmpVisibleKnown = visibleKnown
  else
    for i = table.getn(visibleKnown), 1, -1 do
      visibleKnown[i] = nil
    end
  end

  local editKey = editingKey()
  local vn = 0
  local an = 0
  local i, n = 1, table.getn(entries)
  while i <= n do
    local e = entries[i]
    if e and isKnown(e) then
      if fixed and fixedKnown then
        an = an + 1
        fixedKnown[an] = e
      end
      local f = _GetIconFrame(e.key)
      -- 使用框架标志；从候选者回退到 'show'。
      -- 仅当框架标志尚未初始化时才使用 IsShown() 回退（避免阻塞折叠）。
      local wants = (f and (f._daShouldShow == true or f._daSliding == true))
          or (e.show == true)
          or (f and f._daShouldShow == nil and f._daSliding == nil and f:IsShown())

      -- 编辑时，始终将编辑的成员包含在布局池中
      if editKey and e.key == editKey then
        wants = true
      end

      if wants then
        vn = vn + 1
        visibleKnown[vn] = e
      end
    end
    i = i + 1
  end

  -- 没有可见的？清除任何先前的分配并退出
  if vn == 0 then
    local j, m = 1, table.getn(entries)
    while j <= m do
      local e = entries[j]
      if e then
        e._computedPos = nil
      end
      j = j + 1
    end
    return {}
  end

  -- 决定如何对此组进行排序："prio"（默认）或 "time"
  local groupSortCache = DoiteGroup._sortCache or {}
  DoiteGroup._sortCache = groupSortCache

  local sortMode = groupSortCache[groupName]
  if not sortMode then
    sortMode = GetGroupSortMode(groupName)
    groupSortCache[groupName] = sortMode
  end

  local sortList = fixed and fixedKnown or visibleKnown

  -- 为每个条目预先计算廉价排序键一次（避免比较器内部的框架查找/tostring 搅动）
  local j = 1
  local sn = fixed and an or vn
  while j <= sn do
    local e = sortList[j]
    local k = e.key
    if not e._dgKeyStr then
      if type(k) == "string" then
        e._dgKeyStr = k
      else
        e._dgKeyStr = tostring(k)
      end
    end

    if sortMode == "time" then
      local f = _GetIconFrame(k)
      local r = f and f._daSortRem or nil
      if r and r > 0 then
        e._dgRem = r
        e._dgHasRem = 1
      else
        e._dgRem = nil
        e._dgHasRem = nil
      end
    end

    j = j + 1
  end

  -- 3) 按保存的优先级或剩余时间排序，取决于排序模式
  _DG.editKey = editKey
  if sortMode == "time" then
    table.sort(sortList, _cmpTime)
  else
    table.sort(sortList, _cmpPrio)
  end

  -- 4) 分配最多 numAuras 个槽位，从组长的 baseXY 开始
  local placed = DoiteGroup._tmpPlaced
  if not placed then
    placed = {}
    DoiteGroup._tmpPlaced = placed
  else
    local i = 1
    while placed[i] ~= nil do
      placed[i] = nil
      i = i + 1
    end
  end

  local actualPlaced = limit
  if vn < actualPlaced then
    actualPlaced = vn
  end

  if fixed then
    -- 基于完整的已知列表分配稳定的槽位索引（无映射）。
    local s = 1
    while s <= an do
      local e = fixedKnown[s]
      if e then
        e._daFixedSlot = s
      end
      s = s + 1
    end

    -- 将可见已知条目放入其固定槽位（最多限制）。
    local p = 0
    local v = 1
    while v <= vn do
      local e = visibleKnown[v]
      local slot = e and e._daFixedSlot
      if slot and slot <= limit then
        local curX, curY
        if isCentered then
          curX, curY = _ComputeCenteredOffset(baseX, baseY, growth, pad, slot, limit)
        else
          curX, curY = _ComputeOffset(baseX, baseY, growth, pad, slot - 1)
        end

        -- 内联放置，以便我们可以尊重 _daDragging（避免与拖动所有者冲突）。
        local pos = e._computedPos
        if not pos then
          pos = {}
          e._computedPos = pos
        end
        pos.x = curX
        pos.y = curY
        pos.size = baseSize

        local f = _GetIconFrame(e.key)
        if f then
          f._daBlockedByGroup = false

          -- 滑动或拖动时不重新锚定
          if not f._daSliding and not f._daDragging then
            if f._daGroupX ~= curX or f._daGroupY ~= curY then
              f._daGroupX = curX
              f._daGroupY = curY
              f:ClearAllPoints()
              f:SetPoint("CENTER", UIParent, "CENTER", curX, curY)
            end
          end

          if f._daGroupSize ~= baseSize then
            f._daGroupSize = baseSize
            f:SetWidth(baseSize)
            f:SetHeight(baseSize)
          end
        end

        p = p + 1
        placed[p] = e
      end
      v = v + 1
    end

    actualPlaced = p
  else
    if isCentered then
      local p = 1
      while p <= actualPlaced do
        local e = visibleKnown[p]
        local curX, curY = _ComputeCenteredOffset(baseX, baseY, growth, pad, p, actualPlaced)
        _ApplyPlacement(e, curX, curY, baseSize)
        placed[p] = e
        p = p + 1
      end
    else
      local curX, curY = baseX, baseY
      local p = 1
      while p <= actualPlaced do
        local e = visibleKnown[p]

        _ApplyPlacement(e, curX, curY, baseSize)

        placed[p] = e

        if p < actualPlaced then
          curX, curY = _ComputeOffset(baseX, baseY, growth, pad, p)
        end

        p = p + 1
      end
    end
  end

  -- 5) 其他所有内容不得占据位置（如果当前显示，则隐藏）
  local placedSet = DoiteGroup._tmpPlacedSet
  if not placedSet then
    placedSet = {}
    DoiteGroup._tmpPlacedSet = placedSet
  else
    for k in pairs(placedSet) do
      placedSet[k] = nil
    end
  end

  local q = 1
  while q <= actualPlaced do
    local e = placed[q]
    placedSet[e.key] = true
    q = q + 1
  end

  local r, m = 1, table.getn(entries)
  while r <= m do
    local e = entries[r]
    if e and not placedSet[e.key] then
      e._computedPos = nil
      local f = _GetIconFrame(e.key)
      if f then
        if editKey and e.key == editKey then
          -- 编辑时：不要阻止或强制隐藏此成员
          f._daBlockedByGroup = false
        else
          f._daBlockedByGroup = true
          if f:IsShown() then
            f:Hide()
          end
        end
      end
    end
    r = r + 1
  end

  return placed

end

---------------------------------------------------------------
-- 公开：在所有候选者上应用组布局
---------------------------------------------------------------
function DoiteGroup.ApplyGroupLayout(candidates)
  if not candidates or type(candidates) ~= "table" then
    return
  end
  if _G["DoiteGroup_LayoutInProgress"] then
    return
  end
  _G["DoiteGroup_LayoutInProgress"] = true

  -- 规范化核心字段（防御性）
  for _, entry in ipairs(candidates) do
    local d = entry.data or {}
    d.offsetX = num(d.offsetX, 0)
    d.offsetY = num(d.offsetY, 0)
    d.iconSize = num(d.iconSize, 36)
    d.order = num(d.order, 999)
  end

  -- 1) 按组分隔（重用表以避免战斗分配）
  local groups = DoiteGroup._tmpGroups
  if not groups then
    groups = {}
    DoiteGroup._tmpGroups = groups
  end

  local seen = DoiteGroup._tmpGroupsSeen
  if not seen then
    seen = {}
    DoiteGroup._tmpGroupsSeen = seen
  else
    for k in pairs(seen) do
      seen[k] = nil
    end
  end

  local idx = DoiteGroup._tmpGroupsIdx
  if not idx then
    idx = {}
    DoiteGroup._tmpGroupsIdx = idx
  else
    for k in pairs(idx) do
      idx[k] = nil
    end
  end

  -- 为钩子标记成员资格（便宜地跳过非组图标）
  for _, e in ipairs(candidates) do
    local f = e and _GetIconFrame(e.key) or nil
    if f then
      if isValidGroupMember(e) then
        f._daInGroup = true
      else
        f._daInGroup = nil
      end
    end

    if isValidGroupMember(e) then
      local g = e.data.group
      local list = groups[g]
      if not list then
        list = {}
        groups[g] = list
      end

      if not seen[g] then
        -- 每次组清除列表数组一次
        local i = 1
        while list[i] ~= nil do
          list[i] = nil
          i = i + 1
        end
        seen[g] = true
        idx[g] = 0
      end

      local n = (idx[g] or 0) + 1
      idx[g] = n
      list[n] = e
    end
  end

  -- 删除此传递中不存在的组（保持发布的表干净）
  for g in pairs(groups) do
    if not seen[g] then
      groups[g] = nil
    end
  end

  _hasGroups = false
  for gName, list in pairs(groups) do
    ComputeGroupLayout(list, gName)
    _hasGroups = true
  end

  -- 构建滑动键的缓存列表（用于在滑动时运行微小的 OnUpdate）
  local slideList = DoiteGroup._tmpSlideList
  if not slideList then
    slideList = {}
    DoiteGroup._tmpSlideList = slideList
  else
    local i = 1
    while slideList[i] ~= nil do
      slideList[i] = nil
      i = i + 1
    end
  end

  local sc = 0
  for gName, list in pairs(groups) do
    local i, n = 1, table.getn(list)
    while i <= n do
      local e = list[i]
      if e then
        local f = _GetIconFrame(e.key)
        if f and f._daSliding == true then
          sc = sc + 1
          slideList[sc] = e.key
        end
      end
      i = i + 1
    end
  end
  DoiteGroup._slidingCount = sc

  -- 3) 为 ApplyVisuals 发布
  _G["DoiteGroup_Computed"] = groups
  _G["DoiteGroup_LayoutInProgress"] = false

  -- 如果有任何东西在滑动，保持一个微小的观察者活动；否则确保它关闭
  if sc > 0 and DoiteGroup._EnableSlideWatch then
    DoiteGroup._EnableSlideWatch()
  elseif DoiteGroup._DisableSlideWatch then
    DoiteGroup._DisableSlideWatch()
  end
end


-- 事件/标志驱动的重排（无周期性扫描）
local _watch = CreateFrame("Frame", "DoiteGroupWatch")

-- 后备候选列表/池（仅在 DoiteAuras.GetAllCandidates 不可用时使用）
local _fallbackList = {}
local _fallbackPool = {}

local function _clearArray(t)
  local i = 1
  while t[i] ~= nil do
    t[i] = nil
    i = i + 1
  end
end

local function _collectCandidates()
  if type(DoiteAuras) == "table" and type(DoiteAuras.GetAllCandidates) == "function" then
    return DoiteAuras.GetAllCandidates()
  end

  -- 后备：从 DB 合成（重用表）
  local out = _fallbackList
  local pool = _fallbackPool
  _clearArray(out)

  local src = (DoiteDB and DoiteDB.icons) or (DoiteAurasDB and DoiteAurasDB.spells) or {}
  local n = 0
  for k, d in pairs(src) do
    n = n + 1
    local e = pool[n]
    if not e then
      e = {}
      pool[n] = e
    end
    e.key = k
    e.data = d
    out[n] = e
  end
  return out
end

-- 仅滑动 OnUpdate：无布局工作，只是“我们缓存的滑动键中还有任何在滑动吗？”
local function _SlideTick()
  local slideList = DoiteGroup._tmpSlideList
  local sc = DoiteGroup._slidingCount or 0
  if not slideList or sc <= 0 then
    _watch:SetScript("OnUpdate", nil)
    return
  end

  local i = 1
  while i <= sc do
    local key = slideList[i]
    local f = _GetIconFrame(key)
    if f and f._daSliding == true then
      i = i + 1
    else
      -- 从列表中删除（与最后一个交换）
      slideList[i] = slideList[sc]
      slideList[sc] = nil
      sc = sc - 1
    end
  end

  DoiteGroup._slidingCount = sc

  -- 如果没有滑动剩余且没有挂起的重排，则停止滴答。
  if sc <= 0 and _G["DoiteGroup_NeedReflow"] ~= true then
    _watch:SetScript("OnUpdate", nil)
  end
end

-- 一次性重排运行器（由 RequestReflow / 钩子视觉效果调度）
local function _RunReflowOnce()
  _watch:SetScript("OnUpdate", nil)
  DoiteGroup._reflowQueued = nil

  if _G["DoiteGroup_LayoutInProgress"] then
    -- 下一帧再试（布局可能正在进行中）
    DoiteGroup._reflowQueued = 1
    _watch:SetScript("OnUpdate", _RunReflowOnce)
    return
  end

  if _G["DoiteGroup_NeedReflow"] ~= true then
    -- 如果之后有东西请求重排，将其排队。
    if _G["DoiteGroup_NeedReflow"] == true then
      DoiteGroup.RequestReflow()
      return
    end

    -- 无请求；如果存在滑动，保持滑动滴答，否则关闭。
    if (DoiteGroup._slidingCount or 0) > 0 then
      _watch:SetScript("OnUpdate", _SlideTick)
    end
    return
  end

  _G["DoiteGroup_NeedReflow"] = nil

  local candidates = _collectCandidates()
  if candidates and table.getn(candidates) > 0 then
    DoiteGroup.ApplyGroupLayout(candidates)
  else
    -- 无事可做；确保滑动观察关闭
    DoiteGroup._slidingCount = 0
    _watch:SetScript("OnUpdate", nil)
  end

  -- 如果在这次运行期间有东西请求了另一次重排，再次排队。
  if _G["DoiteGroup_NeedReflow"] == true and not _G["DoiteGroup_LayoutInProgress"] then
    DoiteGroup.RequestReflow()
    return
  end
end

-- 公开 API：请求组重排（优先于直接设置全局标志）
function DoiteGroup.RequestReflow()
  if DoiteGroup.CleanupDanglingGroupData then pcall(DoiteGroup.CleanupDanglingGroupData) end
  _G["DoiteGroup_NeedReflow"] = true
  if DoiteGroup._reflowQueued then
    return
  end
  DoiteGroup._reflowQueued = 1
  _watch:SetScript("OnUpdate", _RunReflowOnce)
end

-- 公开 API：使组的缓存排序模式失效（在排序模式更改时调用）
function DoiteGroup.InvalidateSortCache(groupName)
  if DoiteGroup._sortCache then
    if groupName then
      DoiteGroup._sortCache[groupName] = nil
    else
      -- 如果未指定组，清除整个缓存
      for k in pairs(DoiteGroup._sortCache) do
        DoiteGroup._sortCache[k] = nil
      end
    end
  end
end

-- ApplyGroupLayout 调用的内部辅助函数（补丁 1/2）
function DoiteGroup._EnableSlideWatch()
  if (DoiteGroup._slidingCount or 0) > 0 then
    _watch:SetScript("OnUpdate", _SlideTick)
  end
end

function DoiteGroup._DisableSlideWatch()
  if _G["DoiteGroup_NeedReflow"] ~= true then
    _watch:SetScript("OnUpdate", nil)
  end
end

---------------------------------------------------------------
-- 钩子视觉效果，以便在 any key 的真实名称标志（shouldShow / sliding）更改时自动请求重排
-- （无假设：仅在表和函数存在时钩子。）
---------------------------------------------------------------
local function _IsKeyGrouped(key)
  local d
  if DoiteDB and DoiteDB.icons then
    d = DoiteDB.icons[key]
  end
  if not d and DoiteAurasDB and DoiteAurasDB.spells then
    d = DoiteAurasDB.spells[key]
  end
  local g = d and d.group
  return g and g ~= "" and g ~= "no"
end

local function _HookApplyVisualsIfPresent()
  if DoiteGroup._applyVisualsHooked then
    return
  end
  if type(DoiteConditions) ~= "table" then
    return
  end
  if type(DoiteConditions.ApplyVisuals) ~= "function" then
    return
  end

  local orig = DoiteConditions.ApplyVisuals

  DoiteConditions.ApplyVisuals = function(a, b, c, d, e, f, g)
    -- 支持两种调用风格：
    --   DoiteConditions:ApplyVisuals(key, show, glow, grey, fade, fadeAlpha)
    --   DoiteConditions.ApplyVisuals(key, show, glow, grey, fade, fadeAlpha)
    local self, key, show, glow, grey, fade, fadeAlpha
    if type(a) == "table" then
      self = a
      key = b
      show = c
      glow = d
      grey = e
      fade = f
      fadeAlpha = g
    else
      self = DoiteConditions
      key = a
      show = b
      glow = c
      grey = d
      fade = e
      fadeAlpha = f
    end

    local f = _GetIconFrame(key)

    -- 快速跳过：仅跟踪分组键（甚至在第一次 ApplyGroupLayout 之前也能工作）
    if not _IsKeyGrouped(key) then
      return orig(self, key, show, glow, grey, fade, fadeAlpha)
    end

    -- 规范化 nil/false，以便初始值不会导致“虚假更改”
    local oldShould = (f and f._daShouldShow == true) and 1 or 0
    local oldSliding = (f and f._daSliding == true) and 1 or 0

    local r = orig(self, key, show, glow, grey, fade, fadeAlpha)

    f = _GetIconFrame(key)
    if f then
      local newShould = (f._daShouldShow == true) and 1 or 0
      local newSliding = (f._daSliding == true) and 1 or 0
      if oldShould ~= newShould or oldSliding ~= newSliding then
        DoiteGroup.RequestReflow()
      end
    end

    return r
  end
  DoiteGroup.RequestReflow()
  DoiteGroup._applyVisualsHooked = true
end

-- 现在尝试钩子，并在登录/插件加载时再次尝试（覆盖加载顺序）
_HookApplyVisualsIfPresent()
_watch:RegisterEvent("PLAYER_LOGIN")
_watch:RegisterEvent("ADDON_LOADED")
_watch:SetScript("OnEvent", function()
  _HookApplyVisualsIfPresent()
end)

---------------------------------------------------------------
-- 动态组/类别管理的编辑 UI 辅助函数
---------------------------------------------------------------
local function _DA_DB()
  DoiteAurasDB = DoiteAurasDB or {}
  DoiteAurasDB.spells = DoiteAurasDB.spells or {}
  DoiteAurasDB.categories = DoiteAurasDB.categories or {}
  return DoiteAurasDB
end

local function _TrimName(v)
  if not v then return "" end
  return (string.gsub(v, "^%s*(.-)%s*$", "%1"))
end

local function _IsReservedCategoryName(name)
  return string.upper(tostring(name or "")) == "BARS"
end

local function _BuildNames(kind)
  local db = _DA_DB()
  local out = {}
  local seen = {}

  if kind == "category" then
    local i = 1
    while i <= table.getn(db.categories) do
      local c = db.categories[i]
      if c and c ~= "" and not seen[c] and not _IsReservedCategoryName(c) then
        seen[c] = true
        table.insert(out, c)
      end
      i = i + 1
    end
  end

  for _, d in pairs(db.spells) do
    local n = nil
    if kind == "group" then
      n = d.group
    else
      n = d.category
    end
    if n and n ~= "" and not seen[n]
      and not (kind == "category" and _IsReservedCategoryName(n)) then
      seen[n] = true
      table.insert(out, n)
    end
  end

  table.sort(out, function(a, b)
    return string.upper(a) < string.upper(b)
  end)
  return out
end

local function _EnsureUniqueLeader(groupName)
  if not groupName or groupName == "" then return end
  local db = _DA_DB()
  local leaderKey = nil
  for k, d in pairs(db.spells) do
    if d.group == groupName and d.isLeader then
      leaderKey = k
      break
    end
  end
  if leaderKey then return end

  local bestKey = nil
  local bestOrder = nil
  for k, d in pairs(db.spells) do
    if d.group == groupName then
      local ord = tonumber(d.order) or 999
      if (not bestKey) or ord < bestOrder or (ord == bestOrder and tostring(k) < tostring(bestKey)) then
        bestKey = k
        bestOrder = ord
      end
    end
  end

  if bestKey and db.spells[bestKey] then
    db.spells[bestKey].isLeader = true
  end
end

local function _CleanupNameDataIfUnused(name)
  local db = _DA_DB()
  if not name or name == "" then return end

  local usedAsGroup = false
  local usedAsCategory = false
  for _, d in pairs(db.spells) do
    if d.group == name then usedAsGroup = true end
    if d.category == name then usedAsCategory = true end
    if usedAsGroup and usedAsCategory then break end
  end

  if not usedAsCategory then
    local i = 1
    while i <= table.getn(db.categories) do
      if db.categories[i] == name then
        table.remove(db.categories, i)
      else
        i = i + 1
      end
    end
  end

  if usedAsGroup then
    _EnsureUniqueLeader(name)
  else
    if db.groupSort then db.groupSort[name] = nil end
    if db.groupFixed then db.groupFixed[name] = nil end
    if db.bucketCollapsed then db.bucketCollapsed[name] = nil end
  end

  if not usedAsGroup and not usedAsCategory and db.bucketDisabled then
    db.bucketDisabled[name] = nil
  end
end

local function _CleanupCategoryIfEmpty(name)
  _CleanupNameDataIfUnused(name)
end

local function _CleanupGroupIfEmpty(name)
  _CleanupNameDataIfUnused(name)
end

function DoiteGroup.CleanupDanglingGroupData()
  local db = _DA_DB()
  local usedGroups = {}
  local usedCategories = {}

  for _, d in pairs(db.spells) do
    if d.group and d.group ~= "" then usedGroups[d.group] = true end
    if d.category and d.category ~= "" then usedCategories[d.category] = true end
  end

  local i = 1
  while i <= table.getn(db.categories) do
    local c = db.categories[i]
    if c and c ~= "" and not usedCategories[c] then
      table.remove(db.categories, i)
    else
      i = i + 1
    end
  end

  local function pruneGroupMap(t)
    if not t then return end
    for k in pairs(t) do
      if not usedGroups[k] then t[k] = nil end
    end
  end
  pruneGroupMap(db.groupSort)
  pruneGroupMap(db.groupFixed)
  pruneGroupMap(db.bucketCollapsed)

  if db.bucketDisabled then
    for k in pairs(db.bucketDisabled) do
      if not usedGroups[k] and not usedCategories[k] then
        db.bucketDisabled[k] = nil
      end
    end
  end

  for g in pairs(usedGroups) do
    _EnsureUniqueLeader(g)
  end
end

function DoiteGroup._DG_UI_GetData(ctx)
  if not ctx or not ctx.api or not ctx.api.Ensure then return nil end
  local key = ctx.state and ctx.state.key
  if not key or key == "" then return nil end
  return ctx.api.Ensure(key)
end

function DoiteGroup._DG_UI_RefreshAll(ctx)
  if ctx.api.SafeRefresh then ctx.api.SafeRefresh() end
  if ctx.api.SafeEvaluate then ctx.api.SafeEvaluate() end
  if ctx.api.ListRefresh then pcall(ctx.api.ListRefresh) end
  if ctx.api.UpdateEditor and ctx.state and ctx.state.key then pcall(ctx.api.UpdateEditor, ctx.state.key) end
end

function DoiteGroup._DG_UI_ResetStepForKey(ctx, key)
  local state = ctx.state
  state.rename = false
  state.renameFrom = nil
  state.mode = nil

  if not key or key == "" then
    state.step = "pick"
    return
  end

  local d = nil
  if ctx.api and ctx.api.Ensure then
    d = ctx.api.Ensure(key)
  end

  if d and d.group and d.group ~= "" then
    state.mode = "group"
    state.step = "ingroup"
  elseif d and d.category and d.category ~= "" then
    state.mode = "category"
    state.step = "incategory"
  else
    state.step = "pick"
  end
end


function DoiteGroup._DG_UI_HideAll(ctx)
  local w = ctx.w
  local i = 1
  while i <= table.getn(w._all) do
    w._all[i]:Hide()
    i = i + 1
  end
  if w.growthDD then w.growthDD:Hide() end
  if w.numDD then w.numDD:Hide() end
  if w.spaceLbl then w.spaceLbl:Hide() end
  if w.spaceS then w.spaceS:Hide() end
  if w.spaceE then w.spaceE:Hide() end
end

function DoiteGroup._DG_UI_SetAddState(ctx)
  local w = ctx.w
  local state = ctx.state
  local txt = _TrimName(w.nameIn:GetText() or "")
  local list = _BuildNames(state.mode)
  local dup = false
  local reservedCategory = (state.mode == "category" and _IsReservedCategoryName(txt))
  local i = 1
  while i <= table.getn(list) do
    if string.upper(list[i]) == string.upper(txt) and list[i] ~= state.renameFrom then
      dup = true
      break
    end
    i = i + 1
  end
  if txt == "" or dup or reservedCategory then
    w.bAdd:Disable()
  else
    w.bAdd:Enable()
  end
end

function DoiteGroup._DG_UI_Join(ctx, kind, name)
  local d = DoiteGroup._DG_UI_GetData(ctx); if not d then return end
  local state = ctx.state
  if kind == "group" then
    d.category = nil
    d.group = name
    d.isLeader = false
    _EnsureUniqueLeader(name)
    local hasLeader = false
    for _, s in pairs(_DA_DB().spells) do
      if s.group == name and s.isLeader then hasLeader = true break end
    end
    if not hasLeader then d.isLeader = true end
    state.step = "ingroup"
  else
    if _IsReservedCategoryName(name) then return end
    d.group = nil
    d.isLeader = false
    d.category = name
    local db = _DA_DB()
    local found = false
    local i = 1
    while i <= table.getn(db.categories) do
      if db.categories[i] == name then found = true break end
      i = i + 1
    end
    if not found then table.insert(db.categories, name) end
    state.step = "incategory"
  end
  DoiteGroup._DG_UI_RefreshAll(ctx)
end

function DoiteGroup._DG_UI_LeaveCurrent(ctx)
  local d = DoiteGroup._DG_UI_GetData(ctx); if not d then return end
  local state = ctx.state
  if state.mode == "category" then
    local old = d.category
    d.category = nil
    _CleanupCategoryIfEmpty(old)
    state.step = "pick"
  else
    local old = d.group
    local wasLeader = d.isLeader
    d.group = nil
    d.isLeader = false
    if wasLeader and old then _EnsureUniqueLeader(old) end
    _CleanupGroupIfEmpty(old)
    state.step = "pick"
  end
  DoiteGroup._DG_UI_RefreshAll(ctx)
end

function DoiteGroup._DG_UI_RenameAll(ctx, newName)
  local d = DoiteGroup._DG_UI_GetData(ctx); if not d then return end
  local state = ctx.state
  local from = state.renameFrom
  if not from or from == "" then return end

  if state.mode == "category" then
    for _, s in pairs(_DA_DB().spells) do
      if s.category == from then s.category = newName end
    end
    local db = _DA_DB()
    local found = false
    local i = 1
    while i <= table.getn(db.categories) do
      if db.categories[i] == from then
        db.categories[i] = newName
        found = true
      end
      i = i + 1
    end
    if not found then table.insert(db.categories, newName) end
    _CleanupCategoryIfEmpty(from)
    d.category = newName
    state.step = "incategory"
  else
    for _, s in pairs(_DA_DB().spells) do
      if s.group == from then s.group = newName end
    end
    local db = _DA_DB()
    if db.groupSort and db.groupSort[from] ~= nil then
      db.groupSort[newName] = db.groupSort[from]
      db.groupSort[from] = nil
    end
    if db.groupFixed and db.groupFixed[from] ~= nil then
      db.groupFixed[newName] = db.groupFixed[from]
      db.groupFixed[from] = nil
    end
    d.group = newName
    _CleanupGroupIfEmpty(from)
    _EnsureUniqueLeader(newName)
    state.step = "ingroup"
  end
  DoiteGroup._DG_UI_RefreshAll(ctx)
end

function DoiteGroup._DG_UI_InitExistingDD(ctx)
  local w = ctx.w
  if DoiteGroup.CleanupDanglingGroupData then pcall(DoiteGroup.CleanupDanglingGroupData) end
  if UIDropDownMenu_Initialize then
  UIDropDownMenu_Initialize(w.groupDD, function()
    local arr = _BuildNames("group")
    local i = 1
    while i <= table.getn(arr) do
      local n = arr[i]
      local info = UIDropDownMenu_CreateInfo()
      info.text = n
      info.value = n
      info.func = function() DoiteGroup._DG_UI_Join(ctx, "group", n); DoiteGroup._DG_UI_Refresh(ctx) end
      UIDropDownMenu_AddButton(info)
      i = i + 1
    end
  end)
  end
  if UIDropDownMenu_SetText then UIDropDownMenu_SetText("组", w.groupDD) end

  if UIDropDownMenu_Initialize then
  UIDropDownMenu_Initialize(w.catDD, function()
    local arr = _BuildNames("category")
    local i = 1
    while i <= table.getn(arr) do
      local n = arr[i]
      local info = UIDropDownMenu_CreateInfo()
      info.text = n
      info.value = n
      info.func = function() DoiteGroup._DG_UI_Join(ctx, "category", n); DoiteGroup._DG_UI_Refresh(ctx) end
      UIDropDownMenu_AddButton(info)
      i = i + 1
    end
  end)
  end
  if UIDropDownMenu_SetText then UIDropDownMenu_SetText("分类", w.catDD) end
end

function DoiteGroup._DG_UI_Refresh(ctx)
  local w = ctx.w
  local state = ctx.state
  DoiteGroup._DG_UI_HideAll(ctx)

  if not state.key or state.key == "" then
    state.step = "pick"
    w.line:SetText("若想将此图标编组或分类，请从下方选择选项：")
    w.bNew:Show(); w.bExisting:Show()
    return
  end

  local d = DoiteGroup._DG_UI_GetData(ctx)
  if not d then
    state.step = "pick"
    w.line:SetText("若想将此图标编组或分类，请从下方选择选项：")
    w.bNew:Show(); w.bExisting:Show()
    return
  end

  if d.type == "Bar" then
    d.group = nil
    d.isLeader = nil
    d.category = "BARS"
    state.mode = "category"
    state.step = "incategory"
    w.line:SetText("包含在分类：BARS")
    return
  end

  local detectedMode = nil
  if d.group and d.group ~= "" then
    detectedMode = "group"
    if state.step ~= "settings" and state.step ~= "newname" and state.step ~= "confirmleave" and state.step ~= "existing" and state.step ~= "newkind" then
      state.step = "ingroup"
    end
  elseif d.category and d.category ~= "" then
    detectedMode = "category"
    if state.step ~= "newname" and state.step ~= "confirmleave" and state.step ~= "existing" and state.step ~= "newkind" then
      state.step = "incategory"
    end
  elseif state.step ~= "newkind" and state.step ~= "newname" and state.step ~= "existing" then
    state.step = "pick"
  end

  if detectedMode then
    state.mode = detectedMode
  elseif state.step == "pick" then
    state.mode = nil
  end

  if state.step == "pick" then
    w.line:SetText("若想将此图标编组或分类，请从下方选择选项：")
    w.bNew:Show(); w.bExisting:Show()
  elseif state.step == "newkind" then
    w.line:SetText("您想将图标放入新的组还是新的分类？")
    w.bGroup:Show(); w.bCat:Show(); w.bBackA:Show()
  elseif state.step == "newname" then
    w.line:SetText("请在下方选择一个唯一的名称：")
    w.nameLbl:SetText(state.mode == "group" and "新组名称：" or "新分类名称：")
    w.nameLbl:Show(); w.nameIn:Show(); w.bAdd:Show(); w.bBackB:Show()
    DoiteGroup._DG_UI_SetAddState(ctx)
  elseif state.step == "incategory" then
    w.line:SetText("包含在分类：" .. tostring(d.category or ""))
    w.bRename:Show(); w.bLeave:Show()
  elseif state.step == "ingroup" then
    w.line:SetText("包含在组：" .. tostring(d.group or ""))
    w.bRename:Show(); w.bLeave:Show(); w.leaderCB:Show(); w.bSettings:Show()
    w.leaderCB:SetChecked(d.isLeader and true or false)
    if d.isLeader then w.leaderCB:Disable(); w.bSettings:Enable() else w.leaderCB:Enable(); w.bSettings:Disable() end
  elseif state.step == "confirmleave" then
    if state.mode == "group" then
      w.line:SetText("确定要让图标离开该组吗？")
    else
      w.line:SetText("确定要让图标离开该分类吗？")
    end
    w.bYes:Show(); w.bBackC:Show()
  elseif state.step == "existing" then
    w.line:SetText("选择要将图标放入的现有组或分类：")
    w.groupDD:Show(); w.catDD:Show(); w.bBackD:Show()
    DoiteGroup._DG_UI_InitExistingDD(ctx)
  elseif state.step == "settings" then
    w.line:SetText("组设置：")
    w.growthLabel:Show(); if w.growthDD then w.growthDD:Show() end
    w.numLbl:Show(); if w.numDD then w.numDD:Show() end
    if w.spaceLbl then w.spaceLbl:Show() end
    if w.spaceS then w.spaceS:Show() end
    if w.spaceE then w.spaceE:Show() end

    if w.growthDD and ctx.frame.InitGrowthDropdown then
      ctx.frame.InitGrowthDropdown(w.growthDD, d)
      if UIDropDownMenu_SetText then UIDropDownMenu_SetText(d.growth or "水平向右", w.growthDD) end
    end
    if w.numDD and ctx.frame.InitNumAurasDropdown then
      ctx.frame.InitNumAurasDropdown(w.numDD, d)
      if UIDropDownMenu_SetText then UIDropDownMenu_SetText(tostring(d.numAuras or 5), w.numDD) end
    end

    local settings = (DoiteAurasDB and DoiteAurasDB.settings)
    local s = d.spacing
    if not s then s = (settings and settings.spacing) or 8 end
    if w.spaceS then w.spaceS:SetValue(s) end
    if w.spaceE then w.spaceE:SetText(tostring(s)) end
    w.bBackSettings:Show()
  end
end

function DoiteGroup._DG_UI_WireHandlers(ctx)
  local w = ctx.w

  w.bNew:SetScript("OnClick", function() ctx.state.step = "newkind"; DoiteGroup._DG_UI_Refresh(ctx) end)
  w.bExisting:SetScript("OnClick", function() ctx.state.step = "existing"; DoiteGroup._DG_UI_Refresh(ctx) end)
  w.bGroup:SetScript("OnClick", function() ctx.state.mode = "group"; ctx.state.step = "newname"; ctx.state.rename = false; ctx.state.renameFrom = nil; w.nameIn:SetText(""); DoiteGroup._DG_UI_Refresh(ctx) end)
  w.bCat:SetScript("OnClick", function() ctx.state.mode = "category"; ctx.state.step = "newname"; ctx.state.rename = false; ctx.state.renameFrom = nil; w.nameIn:SetText(""); DoiteGroup._DG_UI_Refresh(ctx) end)
  w.bBackA:SetScript("OnClick", function() ctx.state.step = "pick"; DoiteGroup._DG_UI_Refresh(ctx) end)
  w.bBackB:SetScript("OnClick", function()
    if ctx.state.rename then
      ctx.state.step = (ctx.state.mode == "group") and "ingroup" or "incategory"
    else
      ctx.state.step = "newkind"
    end
    DoiteGroup._DG_UI_Refresh(ctx)
  end)
  w.bRename:SetScript("OnClick", function()
    local d = DoiteGroup._DG_UI_GetData(ctx)
    if not d then return end
    if d.group and d.group ~= "" then
      ctx.state.mode = "group"
      ctx.state.renameFrom = d.group
    elseif d.category and d.category ~= "" then
      ctx.state.mode = "category"
      ctx.state.renameFrom = d.category
    else
      return
    end
    ctx.state.rename = true
    w.nameIn:SetText(ctx.state.renameFrom or "")
    ctx.state.step = "newname"
    DoiteGroup._DG_UI_Refresh(ctx)
  end)
  w.bLeave:SetScript("OnClick", function()
    local d = DoiteGroup._DG_UI_GetData(ctx)
    if not d then return end
    if d.group and d.group ~= "" then
      ctx.state.mode = "group"
    elseif d.category and d.category ~= "" then
      ctx.state.mode = "category"
    else
      return
    end
    ctx.state.step = "confirmleave"
    DoiteGroup._DG_UI_Refresh(ctx)
  end)
  w.bYes:SetScript("OnClick", function() DoiteGroup._DG_UI_LeaveCurrent(ctx); DoiteGroup._DG_UI_Refresh(ctx) end)
  w.bBackC:SetScript("OnClick", function() ctx.state.step = (ctx.state.mode == "group") and "ingroup" or "incategory"; DoiteGroup._DG_UI_Refresh(ctx) end)
  w.bBackD:SetScript("OnClick", function() ctx.state.step = "pick"; DoiteGroup._DG_UI_Refresh(ctx) end)
  w.bSettings:SetScript("OnClick", function() ctx.state.step = "settings"; DoiteGroup._DG_UI_Refresh(ctx) end)
  w.bBackSettings:SetScript("OnClick", function() ctx.state.step = "ingroup"; DoiteGroup._DG_UI_Refresh(ctx) end)

  w.leaderCB:SetScript("OnClick", function(self)
    local cb = self or this or w.leaderCB
    local d = DoiteGroup._DG_UI_GetData(ctx)
    if not d or not d.group then cb:SetChecked(false); return end
    if cb:GetChecked() then
      for k, s in pairs(_DA_DB().spells) do
        if s.group == d.group and k ~= ctx.state.key then
          s.isLeader = false
        end
      end
      d.isLeader = true
      cb:SetChecked(true)
      cb:Disable()
      w.bSettings:Enable()
      DoiteGroup._DG_UI_RefreshAll(ctx)
    else
      cb:SetChecked(d.isLeader and true or false)
    end
  end)

  w.nameIn:SetScript("OnTextChanged", function() DoiteGroup._DG_UI_SetAddState(ctx) end)
  w.bAdd:SetScript("OnClick", function()
    local picked = _TrimName(w.nameIn:GetText() or "")
    if picked == "" then return end
    if ctx.state.rename then DoiteGroup._DG_UI_RenameAll(ctx, picked) else DoiteGroup._DG_UI_Join(ctx, ctx.state.mode, picked) end
    w.nameIn:SetText("")
    DoiteGroup._DG_UI_Refresh(ctx)
  end)
end

function DoiteGroup.AttachEditGroupUI(frame, api)
  if not frame or frame._dgEditorBuilt then return end
  frame._dgEditorBuilt = true

  local ctx = {
    frame = frame,
    api = api or {},
    state = { step = "pick", mode = nil, rename = false, renameFrom = nil, key = nil },
    w = {}
  }
  local w = ctx.w

  if frame.groupLabel then frame.groupLabel:Hide() end

  w.line = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  w.line:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -68)
  w.line:SetWidth(318)
  w.line:SetJustifyH("LEFT")
  frame.dgLine = w.line

  w.bNew = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  w.bNew:SetWidth(70); w.bNew:SetHeight(20); w.bNew:SetPoint("TOPLEFT", w.line, "BOTTOMLEFT", 0, -6); w.bNew:SetText("新建")
  w.bExisting = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  w.bExisting:SetWidth(70); w.bExisting:SetHeight(20); w.bExisting:SetPoint("LEFT", w.bNew, "RIGHT", 6, 0); w.bExisting:SetText("现有")

  w.bGroup = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  w.bGroup:SetWidth(70); w.bGroup:SetHeight(20); w.bGroup:SetPoint("TOPLEFT", w.line, "BOTTOMLEFT", 0, -6); w.bGroup:SetText("组")
  w.bCat = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  w.bCat:SetWidth(70); w.bCat:SetHeight(20); w.bCat:SetPoint("LEFT", w.bGroup, "RIGHT", 6, 0); w.bCat:SetText("分类")
  w.bBackA = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  w.bBackA:SetWidth(70); w.bBackA:SetHeight(20); w.bBackA:SetPoint("LEFT", w.bCat, "RIGHT", 6, 0); w.bBackA:SetText("返回")

  w.nameLbl = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  w.nameLbl:SetPoint("TOPLEFT", w.line, "BOTTOMLEFT", 0, -10)
  w.nameIn = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
  w.nameIn:SetWidth(110); w.nameIn:SetHeight(18); w.nameIn:SetAutoFocus(false); w.nameIn:SetPoint("LEFT", w.nameLbl, "RIGHT", 8, 0)
  w.bAdd = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  w.bAdd:SetWidth(35); w.bAdd:SetHeight(20); w.bAdd:SetPoint("LEFT", w.nameIn, "RIGHT", 6, 0); w.bAdd:SetText("添加")
  w.bBackB = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  w.bBackB:SetWidth(40); w.bBackB:SetHeight(20); w.bBackB:SetPoint("LEFT", w.bAdd, "RIGHT", 6, 0); w.bBackB:SetText("返回")

  w.bRename = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  w.bRename:SetWidth(70); w.bRename:SetHeight(20); w.bRename:SetPoint("TOPLEFT", w.line, "BOTTOMLEFT", 0, -6); w.bRename:SetText("重命名")
  w.bLeave = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  w.bLeave:SetWidth(70); w.bLeave:SetHeight(20); w.bLeave:SetPoint("LEFT", w.bRename, "RIGHT", 6, 0); w.bLeave:SetText("离开")
  w.leaderCB = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
  w.leaderCB:SetWidth(20); w.leaderCB:SetHeight(20); w.leaderCB:SetPoint("LEFT", w.bLeave, "RIGHT", 8, 0)
  w.leaderCB.text = w.leaderCB:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  w.leaderCB.text:SetPoint("LEFT", w.leaderCB, "RIGHT", 2, 0)
  w.leaderCB.text:SetText("组组长")

  w.bSettings = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  w.bSettings:SetWidth(90); w.bSettings:SetHeight(20); w.bSettings:SetPoint("TOPLEFT", w.bRename, "BOTTOMLEFT", 0, -4); w.bSettings:SetText("设置")

  w.bYes = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  w.bYes:SetWidth(70); w.bYes:SetHeight(20); w.bYes:SetPoint("TOPLEFT", w.line, "BOTTOMLEFT", 0, -6); w.bYes:SetText("是")
  w.bBackC = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  w.bBackC:SetWidth(70); w.bBackC:SetHeight(20); w.bBackC:SetPoint("LEFT", w.bYes, "RIGHT", 6, 0); w.bBackC:SetText("返回")

  w.groupDD = CreateFrame("Frame", "DoiteConditions_GroupPickDD", frame, "UIDropDownMenuTemplate")
  w.groupDD:SetPoint("TOPLEFT", w.line, "BOTTOMLEFT", -16, -4)
  if UIDropDownMenu_SetWidth then UIDropDownMenu_SetWidth(110, w.groupDD) end
  w.catDD = CreateFrame("Frame", "DoiteConditions_CategoryPickDD", frame, "UIDropDownMenuTemplate")
  w.catDD:SetPoint("LEFT", w.groupDD, "RIGHT", -30, 0)
  if UIDropDownMenu_SetWidth then UIDropDownMenu_SetWidth(110, w.catDD) end
  w.bBackD = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  w.bBackD:SetWidth(40); w.bBackD:SetHeight(20); w.bBackD:SetPoint("LEFT", w.catDD, "RIGHT", -10, 2); w.bBackD:SetText("返回")

  w.growthLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  w.growthLabel:SetPoint("TOPLEFT", w.line, "BOTTOMLEFT", 0, -6)
  w.growthLabel:SetText("组扩展方向：")
  w.growthDD = frame.growthDD
  if w.growthDD then w.growthDD:ClearAllPoints(); w.growthDD:SetPoint("LEFT", w.growthLabel, "RIGHT", -6, -1) end

  w.numLbl = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  w.numLbl:SetPoint("TOPLEFT", w.growthLabel, "BOTTOMLEFT", 0, -10)
  w.numLbl:SetText("可见图标数量：")
  w.numDD = frame.numAurasDD
  if w.numDD then w.numDD:ClearAllPoints(); w.numDD:SetPoint("LEFT", w.numLbl, "RIGHT", -6, -4) end

  w.spaceLbl = frame.spacingLabel
  if w.spaceLbl then w.spaceLbl:ClearAllPoints(); w.spaceLbl:SetPoint("TOPLEFT", w.numLbl, "BOTTOMLEFT", 0, -12); w.spaceLbl:SetText("图标间距：") end
  w.spaceS = frame.spacingSlider
  if w.spaceS then w.spaceS:ClearAllPoints(); w.spaceS:SetPoint("LEFT", w.spaceLbl, "RIGHT", 10, 0) end
  w.spaceE = frame.spacingEdit
  if w.spaceE then w.spaceE:ClearAllPoints(); w.spaceE:SetPoint("LEFT", w.spaceS, "RIGHT", 8, 0) end

  w.bBackSettings = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  w.bBackSettings:SetWidth(40); w.bBackSettings:SetHeight(20); w.bBackSettings:SetPoint("LEFT", w.line, "RIGHT", -230, 0); w.bBackSettings:SetText("返回")

  w._all = {
    w.bNew, w.bExisting, w.bGroup, w.bCat, w.bBackA,
    w.nameLbl, w.nameIn, w.bAdd, w.bBackB,
    w.bRename, w.bLeave, w.leaderCB, w.bSettings,
    w.bYes, w.bBackC, w.groupDD, w.catDD, w.bBackD,
    w.growthLabel, w.numLbl, w.bBackSettings
  }

  DoiteGroup._DG_UI_WireHandlers(ctx)

  frame.DoiteGroupUIRefresh = function(_, key)
    local changed = (ctx.state.key ~= key)
    ctx.state.key = key
    if changed then
      DoiteGroup._DG_UI_ResetStepForKey(ctx, key)
    end
    DoiteGroup._DG_UI_Refresh(ctx)
  end

  frame.DoiteGroupUIIsLeaderOrFree = function()
    local d = DoiteGroup._DG_UI_GetData(ctx)
    if not d then return true end
    if not d.group or d.group == "" then return true end
    return d.isLeader == true
  end

  local function _dgOnHideReset()
    ctx.state.key = nil
    DoiteGroup._DG_UI_ResetStepForKey(ctx, nil)
  end

  if frame.HookScript then
    frame:HookScript("OnHide", _dgOnHideReset)
  else
    local prevOnHide = frame.GetScript and frame:GetScript("OnHide")
    frame:SetScript("OnHide", function()
      if prevOnHide then prevOnHide() end
      _dgOnHideReset()
    end)
  end

  ctx.state.key = editingKey()
  DoiteGroup._DG_UI_ResetStepForKey(ctx, ctx.state.key)
  DoiteGroup._DG_UI_Refresh(ctx)
end