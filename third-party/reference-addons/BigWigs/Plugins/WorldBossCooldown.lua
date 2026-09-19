--[[
WorldBossCooldown — 世界Boss冷却追踪
by WorkBugs

服务器限制：同一世界Boss（户外Boss）每 7 天只能击杀一次，但游戏内看不到冷却时间。
本插件通过两种方式检测冷却：
  1) 击杀时 BigWigs EndBossfight 钩子 → 记录精确时间 → 显示倒计时
  2) 系统提示"个人锁定权限" → 标记为 CD 中（时间不明）

记录存储：
  self.db.profile.worldBossKills = { [bossName] = <time()秒数> }   -- 精确时间
  self.db.profile.worldBossLocked = { [bossName] = true }          -- 仅知在CD，时间不明
识别方式：module.zonename 包含 "Outdoor Raid Bosses Zone"（即户外/世界Boss）。
--]]

------------------------------
--      Are you local?      --
------------------------------
local LC = AceLibrary("AceLocale-2.2"):new("BigWigs")

local prefix = "|cff33ffcc[BigWigs]|r - "
local COOLDOWN = 7 * 24 * 3600 -- 7 天冷却（秒）

-- 户外/世界Boss 标识
local OUTDOOR_ZONE = LC["Outdoor Raid Bosses Zone"]

-- 兼容：table.getn / # 运算符
local tgetn = table.getn
if not tgetn then
    tgetn = function(t)
        local n = 0
        while t[n + 1] ~= nil do n = n + 1 end
        return n
    end
end

local function tcount(t)
    local n = 0
    for _ in pairs(t) do n = n + 1 end
    return n
end

----------------------------
--      Localization      --
----------------------------
local L = AceLibrary("AceLocale-2.2"):new("BigWigsWorldBossCooldown")
L:RegisterTranslations("zhCN", function() return {
    KILLED          = "%s 已击杀！下次可击杀：还剩 %d 天 %d 时",
    READY           = "[OK] %s 已可击杀（%d天前击杀）",
    NOTREADY        = "[CD] %s 冷却中 -- 还需 %d 天 %d 时（%d天前击杀）",
    LOCKED_UNKNOWN  = "[CD?] %s 冷却中 -- 时间不明（检测到锁定）",
    NORECORD        = "* %s：从未击杀（随时可打）",
    HEADER          = "世界Boss 冷却状态",
    EMPTY           = "暂无世界Boss记录。击杀世界Boss后自动记录。",
    PANEL_TITLE     = "世界Boss 冷却追踪",
    COL_BOSS        = "Boss 名称",
    COL_STATUS      = "状态",
    COL_KILLED      = "上次击杀 / 检测",
    CLOSE_TIP       = "关闭面板",
    REFRESH_TIP     = "刷新",
} end)

L:RegisterTranslations("enUS", function() return {
    KILLED          = "%s defeated! Next available in %d day(s) %d hr",
    READY           = "[OK] %s ready (killed %d day(s) ago)",
    NOTREADY        = "[CD] %s on cooldown -- %d day(s) %d hr left (killed %d day(s) ago)",
    LOCKED_UNKNOWN  = "[CD?] %s on cooldown -- time unknown (lockout detected)",
    NORECORD        = "* %s: never killed (available anytime)",
    HEADER          = "WorldBoss Cooldown Status",
    EMPTY           = "No world boss records yet. Auto-records on kill.",
    PANEL_TITLE     = "WorldBoss Cooldown Tracker",
    COL_BOSS        = "Boss Name",
    COL_STATUS      = "Status",
    COL_KILLED      = "Last Kill / Detected",
    CLOSE_TIP       = "Close panel",
    REFRESH_TIP     = "Refresh",
} end)

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsWorldBossCooldown = BigWigs:NewModule("WorldBossCooldown")
local mod = BigWigsWorldBossCooldown

-- 最近一次击杀缓存（用于与锁定提示联动：若击杀后立即弹出锁定提示，则该次击杀无效）
local lastKill = { name = nil, time = 0, prev = nil }

-- 注册查询命令（放在模块作用域）
SLASH_BWCD1 = "/bwcd"
SLASH_BWCD2 = "/worldbosscd"
SlashCmdList["BWCD"] = function(msg)
    mod:HandleCommand(msg or "")
end

------------------------------
--      Local Helpers      --
------------------------------

local function IsWorldBoss(module)
    local zn = module and module.zonename
    if type(zn) == "table" then
        for _, z in pairs(zn) do
            if z == OUTDOOR_ZONE then return true end
        end
    elseif type(zn) == "string" then
        return zn == OUTDOOR_ZONE
    end
    return false
end

local function remaining(t)
    local left = t + COOLDOWN - time()
    if left <= 0 then return 0, 0 end
    local days = math.floor(left / 86400)
    local hours = math.floor(math.mod(left, 86400) / 3600)
    return days, hours
end

local function elapsed(t)
    local diff = time() - t
    if diff < 0 then diff = 0 end
    local days = math.floor(diff / 86400)
    local hours = math.floor(math.mod(diff, 86400) / 3600)
    return days, hours
end

------------------------------
--      Initialization      --
------------------------------

function BigWigsWorldBossCooldown:OnEnable()
    -- 确保存储表存在
    if not self.db.profile.worldBossKills then
        self.db.profile.worldBossKills = {}
    end
    if not self.db.profile.worldBossLocked then
        self.db.profile.worldBossLocked = {}
    end

    -- 进服时提醒已冷却的Boss
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "RemindOnLogin")

    -- 监听系统消息：个人锁定提示
    self:RegisterEvent("CHAT_MSG_SYSTEM", "OnSystemMessage")

    -- 创建面板（只创建一次）
    self:EnsurePanel()

    -- 定时刷新（每分钟）
    self.ticker = nil
    if C_Timer and C_Timer.NewTicker then
        self.ticker = C_Timer.NewTicker(60, function() self:RefreshPanel() end)
    end
end

function BigWigsWorldBossCooldown:OnDisable()
    if self.ticker then
        self.ticker:Cancel()
        self.ticker = nil
    end
    if self.ui and self.ui.panel then
        self.ui.panel:Hide()
    end
end

------------------------------
--   System Message Hook     --
------------------------------

-- 系统提示模式（中英文，宽容标点差异）
-- 触发场景：击杀世界Boss后，若本周已有CD，系统判定你无战利品，弹出此提示
local LOCKOUT_PATTERN_ZHCN = "你绝对不允许从 (.+) 处获得战利品.*个人锁定权限"
local LOCKOUT_PATTERN_ENUS = "You are not allowed to loot (.+) .* personal lock"

function BigWigsWorldBossCooldown:OnSystemMessage(event, msg)
    if not msg then return end

    local bossName = nil

    -- 尝试中文匹配
    bossName = string.match(msg, LOCKOUT_PATTERN_ZHCN)
    if not bossName then
        bossName = string.match(msg, LOCKOUT_PATTERN_ENUS)
    end

    if not bossName then return end

    -- 如果这次锁定提示紧跟一次击杀记录（5秒内），说明该次击杀无效（已有CD）
    -- 撤销刚刚写入的精确时间，恢复为之前的有效记录；若无记录则标记为"时间不明"
    if lastKill.name == bossName and (time() - lastKill.time) <= 5 then
        local kills = self.db.profile.worldBossKills
        local locked = self.db.profile.worldBossLocked

        kills[bossName] = lastKill.prev  -- 恢复上一个有效值（可能是旧精确时间或 nil）

        if not kills[bossName] then
            locked[bossName] = true      -- 原本无记录 → 标记 CD 中（时间不明）
        end

        DEFAULT_CHAT_FRAME:AddMessage(prefix .. string.format(L["LOCKED_UNKNOWN"], bossName))
        self:RefreshPanel()
    end
end

function BigWigsWorldBossCooldown:RemindOnLogin()
    local kills = self.db.profile.worldBossKills
    local locked = self.db.profile.worldBossLocked
    local ready = {}

    -- 检查精确记录中已冷却的
    for name, last in pairs(kills) do
        if type(last) == "number" then
            local d, h = remaining(last)
            if d == 0 and h == 0 then
                table.insert(ready, {name = name, last = last})
            end
        end
    end

    if tgetn(ready) == 0 then return end
    table.sort(ready, function(a, b) return a.name < b.name end)
    DEFAULT_CHAT_FRAME:AddMessage(prefix .. L["HEADER"])
    for _, entry in ipairs(ready) do
        local ed = elapsed(entry.last)
        DEFAULT_CHAT_FRAME:AddMessage(prefix .. string.format(L["READY"], entry.name, ed))
    end
end

------------------------------
--      Command Handler      --
------------------------------

function BigWigsWorldBossCooldown:HandleCommand(msg)
    msg = string.lower(msg)
    msg = string.gsub(msg, "^%s+", "")
    msg = string.gsub(msg, "%s+$", "")

    if msg == "show" or msg == "" then
        self:ShowPanel()
    elseif msg == "hide" then
        if self.ui and self.ui.panel then self.ui.panel:Hide() end
    else
        self:TogglePanel()
    end
end

------------------------------
--      Kill Recording      --
------------------------------

function BigWigsWorldBossCooldown:EndBossfight(module)
    if not IsWorldBoss(module) then return end

    local kills = self.db.profile.worldBossKills
    local locked = self.db.profile.worldBossLocked
    local name = module:ToString()
    local now = time()

    -- 备份之前的有效记录（防止覆盖旧精确时间）
    local prev = kills[name]

    -- 记录这次击杀（候选时间，可能被锁定提示撤销）
    kills[name] = now
    locked[name] = nil  -- 先清掉"时间不明"标记

    -- 缓存本次击杀，供锁定提示联动判断
    lastKill.name = name
    lastKill.time = now
    lastKill.prev = prev

    local d, h = remaining(now)
    DEFAULT_CHAT_FRAME:AddMessage(prefix .. string.format(L["KILLED"], name, d, h))

    -- 如果面板开着就刷新
    self:RefreshPanel()
end

------------------------------
--      Visual Panel      --
------------------------------

function BigWigsWorldBossCooldown:EnsurePanel()
    if self.ui and self.ui.panel then return end
    self.ui = {}
    self:CreatePanel()
end

function BigWigsWorldBossCooldown:CreatePanel()
    local ui = self.ui

    -- 主面板
    local panel = CreateFrame("Frame", "BigWigs_WorldBossCD_Panel", UIParent)
    panel:SetWidth(480)
    panel:SetHeight(320)
    panel:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    panel:SetFrameStrata("DIALOG")
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", function() panel:StartMoving() end)
    panel:SetScript("OnDragStop", function() panel:StopMovingOrSizing() end)
    panel:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    panel:SetBackdropColor(0.06, 0.08, 0.12, 0.95)
    panel:SetBackdropBorderColor(0.3, 0.35, 0.45, 1.0)
    panel:Hide()

    -- 标题栏背景
    local titleBg = panel:CreateTexture(nil, "ARTWORK")
    titleBg:SetTexture(0.15, 0.18, 0.25, 1.0)
    titleBg:SetHeight(24)
    titleBg:SetPoint("TOPLEFT", panel, "TOPLEFT", 2, -2)
    titleBg:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -2, -2)

    -- 标题文字
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
    title:SetTextColor(1.0, 0.85, 0.2)
    title:SetPoint("CENTER", titleBg, "CENTER", 0, 0)
    title:SetText(L["PANEL_TITLE"])

    -- 关闭按钮
    local closeBtn = CreateFrame("Button", nil, panel)
    closeBtn:SetWidth(20)
    closeBtn:SetHeight(20)
    closeBtn:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -8, -8)
    closeBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\UI-Quickslot-Depress",
        edgeFile = "Interface\\Buttons\\UI-Quickslot-Border",
        tile = false, tileSize = 0, edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    closeBtn:SetBackdropColor(0.6, 0.1, 0.1, 0.9)
    closeBtn:EnableMouse(true)
    closeBtn:RegisterForClicks("LeftButtonUp")
    closeBtn:SetScript("OnClick", function() panel:Hide() end)
    closeBtn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(closeBtn, "ANCHOR_TOPRIGHT")
        GameTooltip:SetText(L["CLOSE_TIP"])
        GameTooltip:Show()
    end)
    closeBtn:SetScript("OnLeave", function()
        if GameTooltip:IsOwned(closeBtn) then
            GameTooltip:Hide()
        end
    end)
    local closeLabel = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    closeLabel:SetFont(STANDARD_TEXT_FONT, 13)
    closeLabel:SetTextColor(1, 0.7, 0.7)
    closeLabel:SetText("X")
    closeLabel:SetAllPoints(closeBtn)

    -- 刷新按钮
    local refreshBtn = CreateFrame("Button", nil, panel)
    refreshBtn:SetWidth(50)
    refreshBtn:SetHeight(18)
    refreshBtn:SetPoint("TOPRIGHT", closeBtn, "TOPLEFT", -4, 2)
    refreshBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\UI-Quickslot-Depress",
        edgeFile = "Interface\\Buttons\\UI-Quickslot-Border",
        tile = false, tileSize = 0, edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    refreshBtn:SetBackdropColor(0.15, 0.25, 0.35, 0.9)
    refreshBtn:EnableMouse(true)
    refreshBtn:RegisterForClicks("LeftButtonUp")
    local refreshLabel = refreshBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    refreshLabel:SetFont(STANDARD_TEXT_FONT, 11)
    refreshLabel:SetTextColor(0.9, 0.9, 0.9)
    refreshLabel:SetText(L["REFRESH_TIP"])
    refreshLabel:SetAllPoints(refreshBtn)

    -- 点击刷新 + 短暂文字反馈（确认按钮有响应）
    local refreshFlashUntil = 0
    refreshBtn:SetScript("OnClick", function()
        BigWigsWorldBossCooldown:RefreshPanel()
        refreshLabel:SetText("已刷新!")
        refreshFlashUntil = GetTime() + 1
    end)
    refreshBtn:SetScript("OnUpdate", function()
        if refreshFlashUntil > 0 and GetTime() >= refreshFlashUntil then
            refreshLabel:SetText(L["REFRESH_TIP"])
            refreshFlashUntil = 0
        end
    end)

    -- 列头
    local headerY = -38
    local colX_boss = 20
    local colX_status = 200
    local colX_killed = 370
    local rowH = 22
    local firstRowY = -60

    local h_boss = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    h_boss:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
    h_boss:SetTextColor(1.0, 0.82, 0.2)
    h_boss:SetPoint("TOPLEFT", panel, "TOPLEFT", colX_boss, headerY)
    h_boss:SetText(L["COL_BOSS"])

    local h_status = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    h_status:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
    h_status:SetTextColor(1.0, 0.82, 0.2)
    h_status:SetPoint("TOPLEFT", panel, "TOPLEFT", colX_status, headerY)
    h_status:SetText(L["COL_STATUS"])

    local h_killed = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    h_killed:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
    h_killed:SetTextColor(1.0, 0.82, 0.2)
    h_killed:SetPoint("TOPLEFT", panel, "TOPLEFT", colX_killed, headerY)
    h_killed:SetText(L["COL_KILLED"])

    -- 空状态提示
    local emptyText = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    emptyText:SetFont(STANDARD_TEXT_FONT, 12)
    emptyText:SetTextColor(0.6, 0.6, 0.6)
    emptyText:SetPoint("CENTER", panel, "CENTER", 0, 10)
    emptyText:SetText(L["EMPTY"])
    emptyText:Hide()

    -- 数据行容器（动态创建）
    ui.panel = panel
    ui.emptyText = emptyText
    ui.rows = {}
    ui.rowPool = {} -- 对象池复用 FontString

    -- 预创建行对象池（最多12个Boss够用）
    for i = 1, 12 do
        local row = {}
        row.bossText = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        row.bossText:SetFont(STANDARD_TEXT_FONT, 11)
        row.bossText:SetTextColor(1.0, 1.0, 1.0)
        row.bossText:SetPoint("TOPLEFT", panel, "TOPLEFT", colX_boss, firstRowY - ((i - 1) * rowH))
        row.bossText:SetWidth(colX_status - colX_boss - 10)
        row.bossText:SetJustifyH("LEFT")
        row.bossText:Hide()

        row.statusText = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        row.statusText:SetFont(STANDARD_TEXT_FONT, 11)
        row.statusText:SetTextColor(1.0, 1.0, 1.0)
        row.statusText:SetPoint("TOPLEFT", panel, "TOPLEFT", colX_status, firstRowY - ((i - 1) * rowH))
        row.statusText:SetWidth(colX_killed - colX_status - 10)
        row.statusText:SetJustifyH("LEFT")
        row.statusText:Hide()

        row.killedText = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        row.killedText:SetFont(STANDARD_TEXT_FONT, 11)
        row.killedText:SetTextColor(0.75, 0.75, 0.75)
        row.killedText:SetPoint("TOPLEFT", panel, "TOPLEFT", colX_killed, firstRowY - ((i - 1) * rowH))
        row.killedText:SetJustifyH("LEFT")
        row.killedText:Hide()

        table.insert(ui.rowPool, row)
    end
end

function BigWigsWorldBossCooldown:ShowPanel()
    self:EnsurePanel()
    if self.ui.panel then
        self.ui.panel:Show()
    end
    self:RefreshPanel()  -- 必须在 Show() 之后调用，否则面板未显示会被跳过渲染
end

function BigWigsWorldBossCooldown:TogglePanel()
    self:EnsurePanel()
    if not self.ui.panel then return end
    if self.ui.panel:IsShown() then
        self.ui.panel:Hide()
    else
        self:ShowPanel()
    end
end

function BigWigsWorldBossCooldown:RefreshPanel()
    if not self.ui or not self.ui.panel then return end
    if not self.ui.panel:IsShown() then return end

    local kills = self.db.profile.worldBossKills or {}
    local locked = self.db.profile.worldBossLocked or {}

    -- 合并两个来源：精确击杀 + 锁定检测（去重）
    local allNames = {}
    for k in pairs(kills) do
        if type(kills[k]) == "number" then
            table.insert(allNames, k)
        end
    end
    for k in pairs(locked) do
        if locked[k] and not kills[k] then
            table.insert(allNames, k)
        end
    end
    table.sort(allNames)

    -- 隐藏所有行
    for _, row in ipairs(self.ui.rowPool) do
        row.bossText:Hide()
        row.statusText:Hide()
        row.killedText:Hide()
    end

    local count = tgetn(allNames)

    if count == 0 then
        self.ui.emptyText:Show()
        return
    end

    self.ui.emptyText:Hide()

    -- 填充数据行
    for i, name in ipairs(allNames) do
        local row = self.ui.rowPool[i]
        if not row then break end

        row.bossText:SetText(name)
        row.bossText:Show()

        local killTime = kills[name]
        local isLockedOnly = locked[name] and (not killTime)

        if isLockedOnly then
            -- 仅知在CD，时间不明
            row.statusText:SetText(string.format(L["LOCKED_UNKNOWN"], name))
            row.statusText:SetTextColor(1.0, 0.5, 0.2) -- 橙色=CD中
            row.statusText:Show()
            row.killedText:SetText("<locked>")
            row.killedText:SetTextColor(0.8, 0.5, 0.2)
            row.killedText:Show()
        elseif type(killTime) == "number" then
            -- 有精确击杀时间
            local d, h = remaining(killTime)
            local ed, eh = elapsed(killTime)

            if d == 0 and h == 0 then
                row.statusText:SetText(string.format(L["READY"], name, ed))
                row.statusText:SetTextColor(0.2, 1.0, 0.3) -- 绿色=可打
            else
                row.statusText:SetText(string.format(L["NOTREADY"], name, d, h, ed))
                row.statusText:SetTextColor(1.0, 0.5, 0.2) -- 橙色=冷却中
            end
            row.statusText:Show()

            local elapsedStr = tostring(ed) .. "d " .. tostring(eh) .. "h ago"
            row.killedText:SetText(elapsedStr)
            row.killedText:SetTextColor(0.75, 0.75, 0.75)
            row.killedText:Show()
        end
    end
end
