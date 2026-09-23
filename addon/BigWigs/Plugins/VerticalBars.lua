assert(BigWigs, "BigWigs not found!")

------------------------------
-- 竖行条 (Vertical Icon Timeline Bar)
-- 逻辑参考 EasyDBM：图标按剩余时间排序，
-- 剩余 >10s 驻留顶部，<=10s 沿竖轨匀速下落，
-- <=5s 放大并显示特效圈，中线标记最近将到期的技能。
-- 适配 WoW 1.12 / Lua 5.0（table.getn、this、无 C_Timer/BackdropTemplate/SetGradientAlpha）
------------------------------

local L = AceLibrary("AceLocale-2.2"):new("BigWigsVerticalBars")

L:RegisterTranslations("enUS", function()
	return {
		["VerticalBars"] = true,
		["Vertical Timeline"] = true,
		["verticalbars"] = true,
		["Options for the vertical icon timeline bar."] = true,
		["Enable"] = true,
		["Enables the vertical icon timeline bar."] = true,
		["Test"] = true,
		["Start/stop a test of the vertical bar."] = true,
		["Max icons"] = true,
		["Maximum number of icons waiting above the track."] = true,
		["Icon size"] = true,
		["Size of each icon."] = true,
		["Track height"] = true,
		["Total height of the vertical track (top half 40s-10s compressed, bottom half 10s-0)."] = true,
		["Reset position"] = true,
		["Reset the vertical bar anchor to the center-right of the screen."] = true,
		["Vertical bar enabled"] = true,
		["Vertical bar disabled"] = true,
		["Locked"] = true,
		["Draggable"] = true,
		["Bar position locked"] = true,
		["Bar unlocked, can be dragged"] = true,
		["Background shown"] = true,
		["Background hidden (right-click the track to show again)"] = true,
		["Click to unlock, you can drag the bar"] = true,
		["Click to lock, forbid dragging"] = true,
		["Lock position"] = true,
		["Lock the vertical bar anchor so it cannot be dragged."] = true,
		["Show labels"] = true,
		["Show the spell name text next to each icon."] = true,
		["Show background"] = true,
		["Show the vertical track background."] = true,
	}
end)

L:RegisterTranslations("zhCN", function()
	return {
		["VerticalBars"] = "竖行条",
		["Vertical Timeline"] = "竖向时间轴",
		["verticalbars"] = "竖行条",
		["Options for the vertical icon timeline bar."] = "竖行图标时间轴条选项.",
		["Enable"] = "启用",
		["Enables the vertical icon timeline bar."] = "启用竖向图标时间轴；默认关闭。",
		["Test"] = "测试",
		["Start/stop a test of the vertical bar."] = "开始/停止竖行条测试.",
		["Max icons"] = "等待数量",
		["Maximum number of icons waiting above the track."] = "轨道上方等待队列的最大图标数量.",
		["Icon size"] = "图标大小",
		["Size of each icon."] = "每个图标的尺寸.",
		["Track height"] = "轨道高度",
		["Total height of the vertical track (top half 40s-10s compressed, bottom half 10s-0)."] = "竖直轨道总高度（上半段 40s→10s 压缩显示，下半段 10s→0 精确下落）.",
		["Reset position"] = "复位位置",
		["Reset the vertical bar anchor to the center-right of the screen."] = "将竖行条锚点重置到屏幕右侧居中.",
		["Vertical bar enabled"] = "竖行条已开启",
		["Vertical bar disabled"] = "竖行条已关闭",
		["Locked"] = "已锁定",
		["Draggable"] = "可拖动",
		["Bar position locked"] = "已锁定竖行条位置",
		["Bar unlocked, can be dragged"] = "已解锁，可拖动竖行条",
		["Background shown"] = "背景已显示",
		["Background hidden (right-click the track to show again)"] = "背景已隐藏（右键轨道再次显示）",
		["Click to unlock, you can drag the bar"] = "点击解锁，可拖动竖行条",
		["Click to lock, forbid dragging"] = "点击锁定，禁止拖动",
		["Lock position"] = "锁定位置",
		["Lock the vertical bar anchor so it cannot be dragged."] = "锁定竖行条锚点，禁止拖动.",
		["Show labels"] = "显示名称",
		["Show the spell name text next to each icon."] = "在图标旁显示技能名称.",
		["Show background"] = "显示轨道背景",
		["Show the vertical track background."] = "显示竖向轨道背景；关闭后完全透明。",
	}
end)

------------------------------
-- Module Declaration
------------------------------

BigWigsVerticalBars = BigWigs:NewModule(L["VerticalBars"])
BigWigsVerticalBars.revision = tonumber(string.sub("$Revision: 20005 $", 12, -3))
BigWigsVerticalBars.defaultDB = {
	enabled = false,
	maxIcons = 5,
	iconSize = 32,
	trackHeight = 300,
	scale = 1.0,
	showLabels = false,
	locked = false,
	bgVisible = false,
	posx = nil,
	posy = nil,
}
BigWigsVerticalBars.consoleCmd = L["verticalbars"]

BigWigsVerticalBars.consoleOptions = {
	type = "group",
	name = L["Vertical Timeline"],
	desc = L["Options for the vertical icon timeline bar."],
	args = {
		enable = {
			type = "toggle",
			name = L["Enable"],
			desc = L["Enables the vertical icon timeline bar."],
			order = 1,
			get = function()
				return BigWigsVerticalBars.db.profile.enabled
			end,
			set = function(v)
				BigWigsVerticalBars:SetEnabled(v)
			end,
		},
		test = {
			type = "execute",
			name = L["Test"],
			desc = L["Start/stop a test of the vertical bar."],
			order = 2,
			func = function()
				BigWigsVerticalBars:RunTest()
			end,
		},
		maxIcons = {
			type = "range",
			name = L["Max icons"],
			desc = L["Maximum number of icons waiting above the track."],
			order = 3,
			min = 1,
			max = 8,
			step = 1,
			get = function()
				return BigWigsVerticalBars.db.profile.maxIcons
			end,
			set = function(v)
				BigWigsVerticalBars.db.profile.maxIcons = v
				BigWigsVerticalBars:ApplyLayout()
			end,
		},
		iconSize = {
			type = "range",
			name = L["Icon size"],
			desc = L["Size of each icon."],
			order = 4,
			min = 16,
			max = 64,
			step = 2,
			get = function()
				return BigWigsVerticalBars.db.profile.iconSize
			end,
			set = function(v)
				BigWigsVerticalBars.db.profile.iconSize = v
				BigWigsVerticalBars:ApplyLayout()
			end,
		},
		trackHeight = {
			type = "range",
			name = L["Track height"],
			desc = L["Track height"],
			order = 5,
			min = 100,
			max = 600,
			step = 10,
			get = function()
				return BigWigsVerticalBars.db.profile.trackHeight
			end,
			set = function(v)
				BigWigsVerticalBars.db.profile.trackHeight = v
				BigWigsVerticalBars:ApplyLayout()
			end,
		},
		showLabels = {
			type = "toggle",
			name = L["Show labels"],
			desc = L["Show the spell name text next to each icon."],
			order = 6,
			get = function()
				return BigWigsVerticalBars.db.profile.showLabels
			end,
			set = function(v)
				BigWigsVerticalBars.db.profile.showLabels = v
			end,
		},
		bgVisible = {
			type = "toggle",
			name = L["Show background"],
			desc = L["Show the vertical track background."],
			order = 6.5,
			get = function()
				return BigWigsVerticalBars.db.profile.bgVisible
			end,
			set = function(v)
				BigWigsVerticalBars.db.profile.bgVisible = v
				BigWigsVerticalBars:UpdateBackground()
			end,
		},
		locked = {
			type = "toggle",
			name = L["Lock position"],
			desc = L["Lock the vertical bar anchor so it cannot be dragged."],
			order = 7,
			get = function()
				return BigWigsVerticalBars.db.profile.locked
			end,
			set = function(v)
				BigWigsVerticalBars.db.profile.locked = v
				BigWigsVerticalBars:UpdateLockState()
			end,
		},
		reset = {
			type = "execute",
			name = L["Reset position"],
			desc = L["Reset the vertical bar anchor to the center-right of the screen."],
			order = 10,
			func = function()
				BigWigsVerticalBars:ResetAnchor()
			end,
		},
	},
}

------------------------------
-- Timeline state
------------------------------

local candybar = AceLibrary("CandyBar-2.2")
local timeline = {}      -- { {text, icon, key, start, dur, endTime} }
local iconPool = {}      -- created icon frames
local testRunning = false
local testBars = nil

local FONT = STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.ttf"
local WHITE = "Interface\\Tooltips\\UI-Tooltip-Background"
local DEFAULT_ICON = "Interface\\Icons\\INV_Misc_PocketWatch_01"
local OVERLAY_TEX = "Interface\\Buttons\\UI-AutoCastableOverlay"

local function TimeLeftText(remain)
	if remain >= 60 then
		return string.format("%d:%02d", math.floor(remain / 60), math.floor(math.mod(remain, 60)))
	elseif remain >= 10 then
		return string.format("%d", math.floor(remain))
	else
		return string.format("%.1f", remain)
	end
end

local function RemainColor(remain)
	-- EasyDBM 配色：>10s 白色；10~5s 白->黄过渡；<5s 黄->红过渡
	if remain > 5 then
		if remain >= 10 then
			return 1, 1, 1, 1
		end
		local t = (remain - 5) / 5
		return 1, 1, t, 1
	else
		local t = remain / 5
		return 1, t, 0, 1
	end
end

local function SortTimeline()
	table.sort(timeline, function(a, b)
		return a.endTime < b.endTime
	end)
end

local function AddTimelineBar(text, timer, icon, key)
	if type(timer) ~= "number" or timer <= 0 then
		return
	end
	local now = GetTime()
	key = key or text
	-- EasyDBM 去重：同 key、同时长、且仍在进行中的不重复添加
	for _, entry in ipairs(timeline) do
		if entry.key == key and math.abs(entry.dur - timer) < 0.1 and entry.endTime > now then
			return
		end
	end
	-- 同 key 但时长不同：视为重启/刷新，更新结束时间
	for _, entry in ipairs(timeline) do
		if entry.key == key then
			entry.start = now
			entry.dur = timer
			entry.endTime = now + timer
			entry.text = text
			entry.icon = icon or entry.icon
			SortTimeline()
			return
		end
	end
	table.insert(timeline, {
		text = text,
		icon = icon or DEFAULT_ICON,
		key = key,
		start = now,
		dur = timer,
		endTime = now + timer,
	})
	SortTimeline()
end

local function RemoveTimelineBarByKey(key)
	for i = table.getn(timeline), 1, -1 do
		if timeline[i].key == key then
			table.remove(timeline, i)
		end
	end
end

local function WipeTimeline()
	for i = table.getn(timeline), 1, -1 do
		table.remove(timeline, i)
	end
end

------------------------------
-- Icon frames
------------------------------

local function ShowIconTooltip(frame)
	if not frame.tooltipText then return end
	GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
	GameTooltip:SetText(frame.tooltipText, 1, 1, 1)
	GameTooltip:Show()
end

local function HideIconTooltip(frame)
	if GameTooltip:IsOwned(frame) then
		GameTooltip:Hide()
	end
end

local function CreateIconFrame(self)
	local f = CreateFrame("Button", nil, self.frames.anchor)
	f:SetFrameLevel(self.frames.anchor:GetFrameLevel() + 2)
	f:EnableMouse(true)
	f:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	f:SetScript("OnClick", function()
		local bar = this.barId and candybar.var.handlers[this.barId]
		if bar and bar.onclick then
			bar.onclick(this.barId, arg1, bar.onclick1, bar.onclick2, bar.onclick3, bar.onclick4, bar.onclick5, bar.onclick6, bar.onclick7, bar.onclick8, bar.onclick9, bar.onclick10)
		end
	end)
	f:SetScript("OnEnter", function()
		ShowIconTooltip(this)
	end)
	f:SetScript("OnLeave", function()
		HideIconTooltip(this)
	end)
	f:SetScript("OnHide", function()
		local frame = this
		HideIconTooltip(frame)
		frame.tooltipText = nil
	end)
	f:SetWidth(self.db.profile.iconSize)
	f:SetHeight(self.db.profile.iconSize)

	f.icon = f:CreateTexture(nil, "ARTWORK")
	f.icon:SetAllPoints(f)
	f.icon:SetTexture(DEFAULT_ICON)

	f.autocastAnim = f:CreateTexture(nil, "OVERLAY")
	f.autocastAnim:SetTexture(OVERLAY_TEX)
	f.autocastAnim:SetWidth(self.db.profile.iconSize * 1.7)
	f.autocastAnim:SetHeight(self.db.profile.iconSize * 1.7)
	f.autocastAnim:SetPoint("CENTER", f, "CENTER")
	f.autocastAnim:SetBlendMode("ADD")
	f.autocastAnim:Hide()

	f.cooldown = f:CreateFontString(nil, "OVERLAY")
	f.cooldown:SetPoint("CENTER", f, "CENTER")
	f.cooldown:SetJustifyH("CENTER")
	f.cooldown:SetJustifyV("MIDDLE")
	f.cooldown:SetFont(FONT, math.floor(self.db.profile.iconSize * 0.45), "OUTLINE")
	f.cooldown:SetTextColor(1, 1, 1, 1)

	f.text = f:CreateFontString(nil, "OVERLAY")
	f.text:SetFont(FONT, 13, "OUTLINE")
	f.text:SetPoint("LEFT", f, "RIGHT", 6, 0)
	f.text:SetJustifyH("LEFT")

	f:Hide()
	return f
end

local function GetIcon(self, i)
	if not iconPool[i] then
		iconPool[i] = CreateIconFrame(self)
	end
	return iconPool[i]
end

------------------------------
-- Rendering（单轨道分段刻度）
-- 轨道上半段（40s→10s）：压缩显示，长度只有自然比例的一半，
--   剩余 >10s 的技能在此缓慢移动（等待），最多 maxIcons 个
-- 轨道下半段（10s→0）：精确下落段，位置 = 剩余时间线性映射
-- 所有图标始终在轨道内
------------------------------

local TRACK_CAP = 40   -- 轨道顶对应的剩余秒数
local FALL_AT = 10     -- 10s 以下为精确下落段（下半段）
local QUEUE_GAP = 6    -- 等待堆叠最小间距

-- 剩余时间 → 图标中心相对锚点顶部的 y 偏移（向下为负）
-- 上半段 40s→10s 占 trackH/2，下半段 10s→0 占 trackH/2
local function TimeToY(remain, trackH, iconSize)
	local half = trackH / 2
	local span = half - iconSize / 2
	if remain >= FALL_AT then
		local t = (remain - FALL_AT) / (TRACK_CAP - FALL_AT)
		if t < 0 then t = 0 end
		if t > 1 then t = 1 end
		return -(half - t * span)
	else
		local t = (FALL_AT - remain) / FALL_AT
		if t > 1 then t = 1 end
		return -(half + t * span)
	end
end

function BigWigsVerticalBars:UpdateAllIcons()
	if not self.frames.anchor or not self.db.profile.enabled then
		return
	end
	local db = self.db.profile
	local iconSize = db.iconSize
	local trackH = db.trackHeight
	local maxWait = db.maxIcons
	local now = GetTime()

	-- 图标与轨道背景/刻度线共用同一 x（ApplyLayout 里的 anchor.trackX），
	-- 保证图标始终居中在轨道内
	local x_track = self.frames.anchor.trackX or 25

	-- 过期清理
	for i = table.getn(timeline), 1, -1 do
		if (timeline[i].expires or timeline[i].endTime) <= now then
			table.remove(timeline, i)
		end
	end

	-- 分桶：等待(>10s) / 下落(<=10s)，各自按到期时间升序
	local waiting, falling = {}, {}
	for _, data in ipairs(timeline) do
		if data.endTime - now > FALL_AT then
			table.insert(waiting, data)
		else
			table.insert(falling, data)
		end
	end
	table.sort(waiting, function(a, b) return a.endTime < b.endTime end)
	table.sort(falling, function(a, b) return a.endTime < b.endTime end)
	if table.getn(waiting) > maxWait then
		-- 只显示最先将到期的 maxWait 个
		while table.getn(waiting) > maxWait do
			table.remove(waiting)
		end
	end

	local function DrawIcon(slot, data, y, curScale)
		local remain = math.max(0, data.endTime - now)
		local iconFrame = GetIcon(self, slot)
		iconFrame:ClearAllPoints()
		iconFrame:SetScale(curScale)
		iconFrame:SetPoint("CENTER", self.frames.anchor, "TOPLEFT",
			(x_track + iconSize / 2) / curScale,
			y / curScale)
		iconFrame.barId = data.barId
		local tooltipText = data.text or "?"
		local tooltipChanged = iconFrame.tooltipText ~= tooltipText
		iconFrame.tooltipText = tooltipText
		iconFrame:Show()
		iconFrame.icon:SetTexture(data.icon or DEFAULT_ICON)
		-- Pooled icons can change timers while the mouse remains over them.
		if tooltipChanged and GameTooltip:IsOwned(iconFrame) and GameTooltip:IsShown() then
			ShowIconTooltip(iconFrame)
		end

		local fontSize = math.floor(iconSize * curScale * 0.45)
		iconFrame.cooldown:SetFont(FONT, fontSize, "OUTLINE")
		iconFrame.cooldown:SetText(TimeLeftText(remain))
		local r, g, b, a = RemainColor(remain)
		iconFrame.cooldown:SetTextColor(r, g, b, a)

		if remain <= 5 then
			-- 1.12 没有 SetRotation，用透明度脉冲模拟特效圈闪烁
			iconFrame.autocastAnim:SetWidth(iconSize * 1.7)
			iconFrame.autocastAnim:SetHeight(iconSize * 1.7)
			iconFrame.autocastAnim:Show()
			local pulse = 0.55 + 0.45 * math.abs(math.sin(now * 4))
			iconFrame.autocastAnim:SetAlpha(pulse)
		else
			iconFrame.autocastAnim:Hide()
		end

		if db.showLabels then
			iconFrame.text:SetText(tooltipText)
		else
			iconFrame.text:SetText("")
		end
	end

	local count = 0

	-- 下落区（下半段）：位置严格对应剩余时间，10s 在轨道中点，0 在轨道底
	for i = 1, table.getn(falling) do
		local data = falling[i]
		local remain = math.max(0, data.endTime - now)
		count = count + 1
		local y = TimeToY(remain, trackH, iconSize)
		local curScale = (remain <= 5) and 1.3 or 1
		DrawIcon(count, data, y, curScale)
	end

	-- 等待区（上半段）：按剩余时间排布，从 10s 刻度向上堆叠，
	-- 保证不重叠且不超出轨道顶；40s 以上停在轨道顶
	local minGap = (trackH / 2 - iconSize / 2) / math.max(maxWait - 1, 1)
	if minGap > iconSize + QUEUE_GAP then
		minGap = iconSize + QUEUE_GAP
	end
	local prevY = nil
	for i = 1, table.getn(waiting) do
		local data = waiting[i]
		local remain = math.max(0, data.endTime - now)
		count = count + 1
		local y = TimeToY(remain, trackH, iconSize)
		if prevY then
			-- 必须在前一个（更先将到期）图标的上方，保持最小间距
			if y < prevY + minGap then
				y = prevY + minGap
			end
		end
		-- 不超出轨道顶（y 上限 = iconSize/2）
		if y > iconSize / 2 then
			y = iconSize / 2
		end
		prevY = y
		DrawIcon(count, data, y, 1)
	end

	-- 隐藏多余图标池
	for i = count + 1, table.getn(iconPool) do
		if iconPool[i] then
			iconPool[i]:Hide()
		end
	end

	-- 全部条到期后自动隐藏锚点（EasyDBM 行为）
	self:RefreshShownState()
end

------------------------------
-- Anchor frame
------------------------------

function BigWigsVerticalBars:ApplyLayout()
	local db = self.db.profile
	if not self.frames.anchor then
		return
	end
	local anchor = self.frames.anchor
	local iconSize = db.iconSize
	local trackH = db.trackHeight
	local x = 25  -- 轨道在锚点内偏左，右侧留名称/刻度文字空间
	anchor.trackX = x  -- UpdateAllIcons 用同一 x 定位图标，保证居中在轨道内

	-- 锚点总高 = 轨道 + 底部余量（整条轨道一列，无独立等待区）
	anchor:SetWidth(iconSize + 150)
	anchor:SetHeight(trackH + 8)

	-- 锁定按钮（悬停可见，置于最顶部）
	anchor.lockBtn:SetWidth(iconSize)
	anchor.lockBtn:SetHeight(18)
	anchor.lockBtn:ClearAllPoints()
	anchor.lockBtn:SetPoint("TOPLEFT", anchor, "TOPLEFT", x, 0)

	-- 轨道背景：覆盖整条轨道（上半段等待 + 下半段下落）
	local totalH = trackH + 8
	anchor.pathBG:SetWidth(iconSize)
	anchor.pathBG:SetHeight(totalH)
	anchor.pathBG:ClearAllPoints()
	anchor.pathBG:SetPoint("TOPLEFT", anchor, "TOPLEFT", x, 0)

	-- 轨道鼠标热区（与轨道背景重合）
	anchor.trackHit:SetWidth(iconSize)
	anchor.trackHit:SetHeight(totalH)
	anchor.trackHit:ClearAllPoints()
	anchor.trackHit:SetPoint("TOPLEFT", anchor, "TOPLEFT", x, 0)

	-- Reuse existing frames; discarding the references leaves old icons visible.
	for _, iconFrame in pairs(iconPool) do
		iconFrame:SetWidth(iconSize)
		iconFrame:SetHeight(iconSize)
	end
end

function BigWigsVerticalBars:UpdateBackground()
	if self.frames and self.frames.anchor then
		self.frames.anchor.pathBG:SetAlpha(self.db.profile.bgVisible and 1 or 0)
	end
end

function BigWigsVerticalBars:UpdateLockState()
	local db = self.db.profile
	if not self.frames.anchor then
		return
	end
	local anchor = self.frames.anchor
	local lockBtn = anchor.lockBtn
	-- Only the track handles dragging; the empty label area must pass mouse input through.
	anchor:EnableMouse(false)
	if db.locked then
		anchor.trackHit:EnableMouse(false)
		lockBtn:SetBackdropColor(0.7, 0.2, 0.2, 0.85)
		lockBtn:SetBackdropBorderColor(1, 0.5, 0.5, 1)
		lockBtn.text:SetText(L["Locked"])
	else
		anchor.trackHit:EnableMouse(true)
		lockBtn:SetBackdropColor(0.2, 0.7, 1, 0.7)
		lockBtn:SetBackdropBorderColor(0.2, 0.7, 1, 0.9)
		lockBtn.text:SetText(L["Draggable"])
	end
end

function BigWigsVerticalBars:SavePosition()
	if not self.frames.anchor then
		return
	end
	local s = self.frames.anchor:GetEffectiveScale()
	self.db.profile.posx = self.frames.anchor:GetLeft() * s
	self.db.profile.posy = self.frames.anchor:GetTop() * s
end

function BigWigsVerticalBars:RestorePosition()
	if not self.frames.anchor then
		return
	end
	local db = self.db.profile
	local f = self.frames.anchor
	local s = f:GetEffectiveScale()
	f:ClearAllPoints()
	if db.posx and db.posy then
		f:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", db.posx / s, db.posy / s)
	else
		f:SetPoint("CENTER", UIParent, "CENTER", 400, 0)
	end
end

function BigWigsVerticalBars:ResetAnchor()
	self.db.profile.posx = nil
	self.db.profile.posy = nil
	if self.frames.anchor then
		self.frames.anchor:ClearAllPoints()
		self.frames.anchor:SetPoint("CENTER", UIParent, "CENTER", 400, 0)
	end
end

-- 按需显示：竖行条启用且轨道上有进行中的计时条时才显示锚点，
-- 没有任何条时整体隐藏（与 EasyDBM 一致，进团队不会空轨道挂着）
function BigWigsVerticalBars:RefreshShownState()
	local db = self.db.profile
	if not self.frames or not self.frames.anchor then
		return
	end
	if self.active and db.enabled and table.getn(timeline) > 0 then
		self.frames.anchor:Show()
	else
		self.frames.anchor:Hide()
	end
end

-- CandyBar remains responsible for duration, interval tails and per-module cleanup.
function BigWigsVerticalBars:SyncBars()
    local enabled = self.active and self.db.profile.enabled
    local handlers = candybar.var.handlers
    for i = table.getn(timeline), 1, -1 do
        if timeline[i].barId then table.remove(timeline, i) end
    end
    local groups = {}
    for id, bar in pairs(handlers) do
        if bar.bwType == "timer" then
            local visible = bar.running or bar.fading or bar.paused
            if enabled and visible and not bar.paused then
                local now = GetTime()
                table.insert(timeline, {
                    key = id, barId = id, text = bar.text, icon = bar.icon,
                    start = bar.starttime, dur = bar.time, endTime = bar.endtime,
                    expires = bar.endtime + (bar.fadetime or 0),
                })
                if bar.frame:IsShown() then
                    bar.frame:Hide()
                    bar.bwVerticalHidden = true
                    if bar.group then groups[bar.group] = true end
                end
            elseif bar.bwVerticalHidden then
                if visible then bar.frame:Show() end
                bar.bwVerticalHidden = nil
                if bar.group then groups[bar.group] = true end
            end
        end
    end
    for group in pairs(groups) do candybar:UpdateGroup(group) end
    SortTimeline()
end

function BigWigsVerticalBars:RefreshBars()
    self:SyncBars()
    self:RefreshShownState()
end

function BigWigsVerticalBars:UpdateVisibility()
    self:RefreshBars()
end

function BigWigsVerticalBars:SetEnabled(enabled)
    self.db.profile.enabled = enabled and true or false
    if self.db.profile.enabled and not self.active then
        BigWigs:EnableModule(self:ToString())
    end
    self:UpdateVisibility()
end

function BigWigsVerticalBars:SetupFrames()
	if self.frames.anchor then
		return
	end
	local db = self.db.profile

	local anchor = CreateFrame("Frame", "BigWigsVerticalBarAnchor", UIParent)
	anchor:SetFrameStrata("MEDIUM")
	anchor:SetWidth(db.iconSize + 100)
	anchor:SetHeight(db.trackHeight)
	anchor:SetMovable(true)
	anchor:EnableMouse(false)
	anchor:SetPoint("CENTER", UIParent, "CENTER", 400, 0)

	anchor:SetScript("OnHide", function()
		this:StopMovingOrSizing()
	end)

	-- 锁定按钮（悬停可见，点击切换锁定）
	local lockBtn = CreateFrame("Button", nil, anchor)
	lockBtn:SetFrameLevel(anchor:GetFrameLevel() + 3)
	lockBtn:SetBackdrop({
		bgFile = WHITE,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 8,
	})
	lockBtn:SetAlpha(0)
	lockBtn.text = lockBtn:CreateFontString(nil, "OVERLAY")
	lockBtn.text:SetPoint("CENTER", lockBtn, "CENTER")
	lockBtn.text:SetFont(FONT, 13, "OUTLINE")
	lockBtn:SetScript("OnClick", function()
		if arg1 == "LeftButton" then
			local db = BigWigsVerticalBars.db.profile
			db.locked = not db.locked
			BigWigsVerticalBars:UpdateLockState()
			if db.locked then
				BigWigs:Print(L["Bar position locked"])
			else
				BigWigs:Print(L["Bar unlocked, can be dragged"])
			end
		end
	end)
	lockBtn:SetScript("OnEnter", function()
		this:SetAlpha(0.92)
		GameTooltip:SetOwner(this, "ANCHOR_TOP")
		GameTooltip:SetText(BigWigsVerticalBars.db.profile.locked and L["Click to unlock, you can drag the bar"] or L["Click to lock, forbid dragging"])
		GameTooltip:Show()
	end)
	lockBtn:SetScript("OnLeave", function()
		this:SetAlpha(0)
		GameTooltip:Hide()
	end)

	-- 竖轨背景
	local pathBG = anchor:CreateTexture(nil, "BACKGROUND")
	pathBG:SetTexture(WHITE)
	pathBG:SetVertexColor(0.0588, 0.0588, 0.0588, 0.8)

	-- 轨道鼠标热区：1.12 的 Texture 没有 EnableMouse/鼠标事件，
	-- 用一个透明 Frame 覆盖轨道来捕获拖动与右键
	local trackHit = CreateFrame("Frame", nil, anchor)
	trackHit:EnableMouse(true)
	trackHit:SetFrameLevel(anchor:GetFrameLevel() + 1)
	trackHit:SetScript("OnMouseDown", function()
		if arg1 == "LeftButton" and not BigWigsVerticalBars.db.profile.locked then
			anchor:StartMoving()
		end
	end)
	trackHit:SetScript("OnMouseUp", function()
		anchor:StopMovingOrSizing()
		BigWigsVerticalBars:SavePosition()
		if arg1 == "RightButton" then
			local db = BigWigsVerticalBars.db.profile
			db.bgVisible = not db.bgVisible
			BigWigsVerticalBars:UpdateBackground()
			if db.bgVisible then
				BigWigs:Print(L["Background shown"])
			else
				BigWigs:Print(L["Background hidden (right-click the track to show again)"])
			end
		end
	end)

	self.frames.anchor = anchor
	anchor.lockBtn = lockBtn
	anchor.pathBG = pathBG
	anchor.trackHit = trackHit

	self:UpdateBackground()
	self:ApplyLayout()
	self:UpdateLockState()
	self:RestorePosition()

	anchor:SetScript("OnUpdate", function()
		this.elapsed = (this.elapsed or 0) + (arg1 or 0)
		if this.elapsed < 0.05 then return end
		this.elapsed = 0
		BigWigsVerticalBars:SyncBars()
		BigWigsVerticalBars:UpdateAllIcons()
	end)

	self:RefreshShownState()
end

------------------------------
-- Test
------------------------------

function BigWigsVerticalBars:RunTest()
	self:SetEnabled(true)
	if testRunning then
		testRunning = false
		if testBars then
			for i = 1, table.getn(testBars) do
				RemoveTimelineBarByKey(testBars[i])
			end
		end
		testBars = nil
		return
	end
	testRunning = true
	testBars = {
		"VBTestA",
		"VBTestB",
		"VBTestC",
	}
	AddTimelineBar("测试技能 A", 20, "Interface\\Icons\\Spell_Frost_FrostBolt", testBars[1])
	AddTimelineBar("测试技能 B", 30, "Interface\\Icons\\Spell_Fire_FlameBolt", testBars[2])
	AddTimelineBar("测试技能 C", 40, "Interface\\Icons\\Spell_Nature_WispSplode", testBars[3])
	-- 空轨道时锚点是隐藏的，测试要主动唤起（也可借此拖动定位）
	self:RefreshShownState()
end

------------------------------
-- Event Handlers
------------------------------

function BigWigsVerticalBars:OnEnable()
    self.active = true
    self.frames = self.frames or {}
    self:RegisterEvent("BigWigs_BarsChanged", "RefreshBars")
    self:SetupFrames()
    self:UpdateVisibility()
end

function BigWigsVerticalBars:OnDisable()
    self.active = false
    self:SyncBars()
    WipeTimeline()
    testRunning, testBars = false, nil
    if self.frames and self.frames.anchor then self.frames.anchor:Hide() end
end

------------------------------
-- Slash command
------------------------------

SLASH_BIGWIGSVERTICAL1 = "/bwv"
SlashCmdList["BIGWIGSVERTICAL"] = function(msg)
	msg = string.lower(msg or "")
	if msg == "test" then
		BigWigsVerticalBars:RunTest()
		return
	end
	local db = BigWigsVerticalBars.db.profile
	local enabled = not db.enabled
	if msg == "on" then enabled = true
	elseif msg == "off" then enabled = false end
	BigWigsVerticalBars:SetEnabled(enabled)
	if db.enabled then
		BigWigs:Print(L["Vertical bar enabled"])
	else
		BigWigs:Print(L["Vertical bar disabled"])
	end
end
