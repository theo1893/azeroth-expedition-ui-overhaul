-- 创建密语盒子按钮
boxButton = CreateFrame("Button", "WIMBoxButton", UIParent)
boxButton:SetWidth(32)
boxButton:SetHeight(32)
boxButton:SetText("") -- 不显示文字
boxButton:SetPoint("BOTTOMRIGHT", ChatFrame1, "TOPRIGHT", 33, 0)
boxButton:SetMovable(true)
boxButton:RegisterForDrag("LeftButton")
boxButton:SetScript("OnDragStart", function(self)
    if IsShiftKeyDown() then
        boxButton:StartMoving()
    end
end)
boxButton:SetScript("OnDragStop", function(self)
    boxButton:StopMovingOrSizing()
end)

-- 鼠标悬停高亮贴图
if not boxButton.highlight then
    boxButton.highlight = boxButton:CreateTexture(nil, "HIGHLIGHT")
    boxButton.highlight:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-BlinkHilight.blp")
    boxButton.highlight:SetAllPoints(boxButton)
    boxButton.highlight:Hide()
end
boxButton:SetScript("OnEnter", function()
        GameTooltip:SetOwner(boxButton, "ANCHOR_RIGHT")
        GameTooltip:AddLine("WIM密语管理")
        GameTooltip:AddLine("左键点击打开联系人")
	GameTooltip:AddLine("按住Shift+左键拖动盒子")
	GameTooltip:AddLine("按住Shift+左键单击复位盒子")
	GameTooltip:AddLine("/wim打开设置面板")
        GameTooltip:Show()
    if boxButton.highlight then
        boxButton.highlight:Show()
    end
end)
boxButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
    if boxButton.highlight then
        boxButton.highlight:Hide()
    end
end)


-- 聊天图标
if not boxButton.icon then
    boxButton.icon = boxButton:CreateTexture(nil, "OVERLAY", nil, 7)
    boxButton.icon:SetTexture("Interface\\AddOns\\WIM\\Images\\Say")
    boxButton.icon:SetAllPoints(boxButton)
end



-- 添加未读消息计数泡泡
if not boxButton.bubbleBg then
    boxButton.bubbleBg = boxButton:CreateTexture(nil, "OVERLAY")
    boxButton.bubbleBg:SetTexture("Interface\\AddOns\\WIM\\Images\\Aura72")
    boxButton.bubbleBg:SetWidth(23)
    boxButton.bubbleBg:SetHeight(23)
    boxButton.bubbleBg:SetVertexColor(1, 0, 0, 1) -- 红色
    boxButton.bubbleBg:SetPoint("BOTTOMRIGHT", boxButton, "TOPRIGHT", 9, -10)
    boxButton.bubbleBg:Hide()
end

boxButton.bubble = boxButton:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
boxButton.bubble:SetPoint("CENTER", boxButton.bubbleBg, "CENTER", -1, 2)
boxButton.bubble:SetText("")
boxButton.bubble:Hide()

-- 更新未读消息计数显示
WIM_contact_Unread = WIM_contact_Unread or {} -- 未读消息计数
function UpdateUnreadBubble()
    local totalUnread = 0
    for _, count in pairs(WIM_contact_Unread) do
        totalUnread = totalUnread + count
    end

    if totalUnread > 0 then
        if boxButton.bubbleBg then
            boxButton.bubbleBg:Show()
        end
        boxButton.bubble:SetText(totalUnread)
        boxButton.bubble:Show()
    else
        if boxButton.bubbleBg then
            boxButton.bubbleBg:Hide()
        end
        boxButton.bubble:Hide()
    end
end
function RefreshUnread(user) --刷新未读信息计数
	if WIM_contact_Unread and WIM_contact_Unread[user] then
		WIM_contact_Unread[user] = 0 --清除当前联系人未读计数
	end
        UpdateUnreadBubble() --更新未读计数
        UpdateWIMContactList() --更新联系人列表
end

-- 创建密语盒子窗口
boxFrame = CreateFrame("Frame", "WIMBoxFrame", UIParent)
boxFrame:SetBackdrop{
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", -- 黑色半透明背景
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", -- 纯白线条
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
}
boxFrame:SetBackdropColor(0, 0, 0, 1) -- 黑色半透明
boxFrame:SetBackdropBorderColor(1, 1, 1, 1) -- 黑色线条
boxFrame:SetWidth(180)
boxFrame:SetHeight(256)
boxFrame:SetPoint("CENTER", UIParent, "CENTER", 0, -50)
boxFrame:Hide()
--可拖动
boxFrame:SetMovable(true)
boxFrame:EnableMouse(true)
boxFrame:RegisterForDrag("LeftButton")
boxFrame:SetScript("OnDragStart", function()
    	boxFrame:StartMoving()
end)
boxFrame:SetScript("OnDragStop", function()
    	boxFrame:StopMovingOrSizing()
end)
--标题背景
boxFrame.tex = boxFrame:CreateTexture(nil, "OVERLAY")
boxFrame.tex:SetTexture(0,0,0,0.5)
boxFrame.tex:SetPoint("TOP",0,-5)
boxFrame.tex:SetWidth(170)
boxFrame.tex:SetHeight(17)
--标题文字
boxFrame.text = boxFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
boxFrame.text:SetText("联系人")
boxFrame.text:SetPoint("CENTER",boxFrame.tex,"CENTER",0,0)
--关闭按钮
if not boxFrame.closeBtn then
    boxFrame.closeBtn = CreateFrame("Button", nil, boxFrame)
    boxFrame.closeBtn:SetWidth(30)
    boxFrame.closeBtn:SetHeight(30)
    boxFrame.closeBtn:SetPoint("TOPRIGHT", boxFrame, "TOPRIGHT", 2, 2)
    boxFrame.closeBtn:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
    boxFrame.closeBtn:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
    boxFrame.closeBtn:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
    boxFrame.closeBtn:SetScript("OnClick", function() boxFrame:Hide() end)
end

-- 创建联系人列表框
local contactFrame = CreateFrame("Frame", "WIMContactFrame", boxFrame)
contactFrame:SetWidth(180)
contactFrame:SetHeight(boxFrame:GetHeight()-10)
--("TOPLEFT", boxFrame, "TOPLEFT", 0, -40)
contactFrame:SetBackdrop{
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
}
contactFrame:SetBackdropColor(0.1,0.1,0.1,0)
--边框透明度设置
contactFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 0)

-- 创建滚动区域
local contactScroll = CreateFrame("ScrollFrame", "SimpleWhisperContactScroll", boxFrame, "UIPanelScrollFrameTemplate")
contactScroll:SetWidth(155)
contactScroll:SetHeight(boxFrame:GetHeight()-30)
contactScroll:SetPoint("TOPLEFT", boxFrame, "TOPLEFT", -3, -24)

-- 让联系人列表成为滚动区域的内容
contactFrame:SetParent(contactScroll)
contactScroll:SetScrollChild(contactFrame)
contactFrame:SetPoint("TOPLEFT", contactScroll, "TOPLEFT", 10, 0)

-- 联系人按钮池
local contactButtons = {}

-- 计算表长度（兼容Lua 5.0）
local function tableLength(t)
    if not t then return 0 end
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

--更新联系人列表
local btnlastuser
function UpdateWIMContactList()
    -- 清理旧按钮
    for _, btn in ipairs(contactButtons) do
        btn:Hide()
        -- 移除旧的个别清除按钮
        if btn.clearBtn then
            btn.clearBtn:Hide()
        end
    end

    local idx = 1
    local HistoryNames = {};


    if WIM_History then
        for key, _ in pairs(WIM_History) do
            table.insert(HistoryNames, key);
        end
	--按最近消息时间排序
	 
        table.sort(HistoryNames, function(a, b)
            local function getLastTime(key)
                local box = WIM_History[key]
                if type(box) == "table" and tableLength(box) > 0 then
                    local last = box[tableLength(box)]
                    return last and last.date.." "..last.time or ""
                end
                return ""
            end
            return getLastTime(b) < getLastTime(a)
        end)
    end

    for _, HistoryName in ipairs(HistoryNames) do
        local btn = contactButtons[idx]
        if not btn then
            btn = CreateFrame("Button", "btn"..idx, contactFrame)
            btn:SetWidth(110)
            btn:SetHeight(18)
            btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
            --btn往左边偏移一点
            btn:SetPoint("LEFT", contactFrame, "LEFT", -5, 0)
            
            if not btn.text then
                btn.text = btn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
                btn.text:SetPoint("LEFT", btn, "LEFT", 5, 0)
                btn.text:SetJustifyH("LEFT")
                btn.text:SetWidth(110)
            end
		--显示未读计数
            if not btn.unread then
                btn.unread = btn:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
                btn.unread:SetPoint("RIGHT", btn, "RIGHT", -5, 0)
                btn.unread:SetTextColor(1, 0.2, 0.2)
            end

            -- 添加删除按钮
            if not btn.clearBtn then
                btn.clearBtn = CreateFrame("Button", nil, btn)
                btn.clearBtn:SetWidth(20)
                btn.clearBtn:SetHeight(20)
                btn.clearBtn:SetPoint("RIGHT", btn, "RIGHT", 6, 0)
                btn.clearBtn:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
                btn.clearBtn:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
                btn.clearBtn:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
                -- 修改删除按钮的点击事件
		btn.clearBtn:SetScript("OnClick", function()
			PlaySound("igMainMenuClose");
			local senderName = btn.text and btn.text:GetText() or ""
			if senderName ~= "" then
				WIM_History[senderName] = nil;
				RefreshUnread(senderName) --刷新未读信息计数
				if getglobal('WIM_msgFrame'..senderName) then
					getglobal('WIM_msgFrame'..senderName):Hide()
				end
			end
		end)
                -- 添加悬停提示
                btn.clearBtn:SetScript("OnEnter", function()
                    GameTooltip:SetOwner(btn.clearBtn, "ANCHOR_RIGHT")
                    GameTooltip:AddLine("删除此联系人的聊天记录")
                    GameTooltip:Show()
                end)
                btn.clearBtn:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
            end

            contactButtons[idx] = btn
        end
        btn.text:SetText(HistoryName)

        -- 显示未读计数
        local unread = (WIM_contact_Unread and WIM_contact_Unread[HistoryName]) or 0
        if unread > 0 then
            btn.unread:SetText("("..unread..")")
            btn.unread:Show()
            btn.text:SetTextColor(1, 1, 0.5)  -- 高亮未读联系人
        else
            btn.unread:Hide()
            btn.text:SetTextColor(1, 0.82, 0)  -- 普通颜色
        end
        btn.unread:ClearAllPoints()
        btn.unread:SetPoint("LEFT", btn, "LEFT", -10, 0)

        -- 显示删除按钮
        if btn.clearBtn then
            btn.clearBtn:Show()
        end

	--列表按钮排序
        btn:SetPoint("TOPLEFT", contactFrame, "TOPLEFT", 20, -5 - (idx-1)*20)
        btn:Show()
        btn.sender = HistoryName
        btn.lastClickTime = 0

        btn:SetScript("OnClick", function()
		local thisuser = getglobal("btn1").text:GetText()
		DEFAULT_CHAT_FRAME.editBox:SetText("/w "..btn.text:GetText())
		ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
		--RefreshUnread(btn.text:GetText()) --刷新未读信息计数
        end)

        idx = idx + 1
    end
    -- 每个按钮高度约20，最小高度200
    local totalHeight = math.max(200, (idx - 1) * 20)
    contactFrame:SetHeight(totalHeight)
end

-- 打开盒子时刷新联系人列表
boxButton:SetScript("OnClick", function()
	if not IsShiftKeyDown() then
		UpdateWIMContactList()
		if boxFrame:IsShown() then
			boxFrame:Hide()
		else
			boxFrame:Show()
			if getglobal("btn1") then
				local thisuser = getglobal("btn1").text:GetText()
				DEFAULT_CHAT_FRAME.editBox:SetText("/w "..thisuser)
				ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
				--RefreshUnread(thisuser) --刷新未读信息计数
			end
		end
	else
		boxButton:ClearAllPoints()
		boxButton:SetPoint("BOTTOMRIGHT", ChatFrame1, "TOPRIGHT", 33, 0)
	end
end)

--聊天框位置--25.10.22修改新增
function WIM_SetWindowLocation(theWin,ttype)
	if boxFrame then
		theWin:SetPoint("TOPLEFT",boxFrame,"TOPLEFT",-theWin:GetWidth(), 0);
	else
		theWin:SetPoint("TOPLEFT",UIParent,"BOTTOMLEFT",WIM_Data.winLoc.left+WIM_CascadeDirection[WIM_Data.winCascade.direction].left, WIM_Data.winLoc.top+WIM_CascadeDirection[WIM_Data.winCascade.direction].top);
	end
	theWin:SetScript("OnDragStart", function()
    		boxFrame:StartMoving()
		theWin:SetPoint("TOPLEFT",boxFrame,"TOPLEFT",-theWin:GetWidth(), 0)
	end)
	theWin:SetScript("OnDragStop", function()
    		boxFrame:StopMovingOrSizing()
	end)
	boxFrame:SetScript("OnDragStart", function()
    		boxFrame:StartMoving()
		theWin:SetPoint("TOPLEFT",boxFrame,"TOPLEFT",-theWin:GetWidth(), 0);
	end)
	boxFrame:SetScript("OnDragStop", function()
    		boxFrame:StopMovingOrSizing()
	end)
end
-- 初始化未读气泡
UpdateUnreadBubble()