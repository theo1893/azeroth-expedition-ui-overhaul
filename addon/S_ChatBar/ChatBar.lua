S_ChatBarDB = S_ChatBarDB or {
    showFrame = true,
    buttons = {
        Say = true,
        Yell = true,
        Whisper = true,
        Party = true,
        Guild = true,
        Officer = false,
        Raid = true,
        RaidWarns = false,
        Battlefield = false,
        General = true,
        Trade = false,
        World = true,
        HC = false,
        Meeting = false,
        XyTracker = false,
        AtlasLoot = false,
        SuperMacro = false,
        ActionBarProfiles = false,
        TrinketMenu = false,
        Tracking = false,
        QuestAnnouncer = true,
    }
}

local BUTTON_ORDER = {
    "Say", "Yell", "Whisper", "Party", "Guild", "Officer",
    "Raid", "RaidWarns", "Battlefield", "General", "Trade",
    "World", "HC", "Meeting", "XyTracker", "AtlasLoot",
    "SuperMacro", "ActionBarProfiles", "TrinketMenu", "QuestAnnouncer", "Tracking"
}


local buttonFrames      = {}
local lastVisibleButton = nil

-- Chatbar主框体 --
COLORSCHEME_BORDER      = { 0.3, 0.3, 0.3, 1 }

-- 更新按钮布局函数
function UpdateButtonLayout()
    lastVisibleButton = nil
    local totalWidth = 1 -- 初始边距

    -- 计算可见按钮总宽度
    for _, btnName in ipairs(BUTTON_ORDER) do
        local btn = buttonFrames[btnName]
        if btn and S_ChatBarDB.buttons[btnName] then
            totalWidth = totalWidth + btn:GetWidth() + 1 -- 按钮宽度 + 间距
        end
    end

    -- 动态调整主框体宽度
    chatbar:SetWidth(totalWidth + 5) -- 留出骰子按钮空间

    -- 重新排列按钮
    for _, btnName in ipairs(BUTTON_ORDER) do
        local btn = buttonFrames[btnName]
        if btn then
            btn:ClearAllPoints()
            if S_ChatBarDB.buttons[btnName] then
                if lastVisibleButton then
                    btn:SetPoint("LEFT", lastVisibleButton, "RIGHT", 1, 0)
                else
                    btn:SetPoint("LEFT", chatbar, "LEFT", 1, 0)
                end
                btn:Show()
                lastVisibleButton = btn
            else
                btn:Hide()
            end
        end
    end
end

function Getchannel_name()
    local localtime, servertime = tonumber(date("%H", time())), tonumber(format("%02d", GetGameTime()))
    print(localtime .. "    " .. servertime)
    if abs(localtime - servertime) > 2 then
        channel_name = "World"
    else
        channel_name = "世界频道"
    end
    return channel_name
end

local chatbar = CreateFrame("Frame", "chatbar", UIParent)
chatbar:SetWidth(420)
chatbar:SetHeight(40)
chatbar:SetPoint("BOTTOMLEFT", ChatFrame3, "TOPLEFT", 10, 24)
chatbar:RegisterEvent("PLAYER_LOGIN")
chatbar:SetMovable(true)    -- 启用移动
chatbar:SetUserPlaced(true) -- 允许用户放置

chatbar:SetScript("OnEvent", function()
    -- 如果默认是显示状态,那么根据对应插件加载状态设置
    for k, btnName in pairs(BUTTON_ORDER) do
        if k >= 14 and btnName ~= "Tracking" and S_ChatBarDB.buttons[btnName] then
            S_ChatBarDB.buttons[btnName] = IsAddOnLoaded(btnName)
        end
    end
    if S_MiniMap then
        MiniMapTrackingFrame:SetScale(0.4)
    end
    JoinChannelByName(Getchannel_name(), nil, 1)
    ChatFrame_RemoveMessageGroup(ChatFrame1, "CHANNEL")
    UpdateButtonLayout()
end)

-- 创建按钮的通用函数
local function CreateChatButton(name, text, tooltip, color, onClick)
    local button = CreateFrame("Button", "Channel" .. name, chatbar)
    button:SetWidth(20)
    button:SetHeight(20)
    button:RegisterForClicks("LeftButtonUp")

    button.t = button:CreateTexture()
    button.t:SetAllPoints()

    button.text = button:CreateFontString(nil, "OVERLAY")
    button.text:SetFont(STANDARD_TEXT_FONT, 15, "OUTLINE")
    button.text:SetJustifyH("CENTER")
    button.text:SetWidth(25)
    button.text:SetHeight(25)
    button.text:SetPoint("CENTER", 0, 1)
    button.text:SetText(text)
    button.text:SetTextColor(unpack(color))
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:SetScript("OnClick", onClick)
    button:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_TOP", 0, 6)
        GameTooltip:AddLine(tooltip)
        if name == "Tracking" then
            GameTooltip:AddLine("点击|cFF00CCFF 左键 |r可选择追踪类型", 1, 1, 0)
            GameTooltip:AddLine("点击|cFF00CCFF 右键 |r可选择启用/关闭/切换可移动追踪图标", 1, 1, 0)
        end
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)

    buttonFrames[name] = button
    return button
end

local function GetChannelID(channelname)
    for i = 1, 10 do
        local id, name = GetChannelName(i);
        if name and string.find(name, channelname) then
            return id
        end
    end
    return false
end

local function ChannelMeeting_OnClick()
    if Meeting then
        Meeting:Toggle()
    end
end

local function ChannelXyTracker_OnClick()
    if XyTrackerFrame then
        if not XyTrackerFrame:IsShown() then
            XyTracker_ShowXyWindow()
        else
            XyTracker_HideXyWindow()
        end
    end
end

local function AtlasLoot_OnClick()
    if AtlasLoot_ShowMenu then
        if not AtlasLootDefaultFrame:IsShown() then
            AtlasLootDefaultFrame:Show()
        else
            AtlasLootDefaultFrame:Hide()
        end
    end
end

local function SuperMacro_OnClick()
    if SuperMacroFrame then
        if not SuperMacroFrame:IsShown() then
            SuperMacroFrame:Show()
        else
            SuperMacroFrame:Hide()
        end
    else
        if not MacroFrame:IsShown() then
            MacroFrame:Show()
        else
            MacroFrame:Hide()
        end
    end
end

local function TrackingButton_OnClick()
    local button = arg1 -- 使用arg1获取点击按钮
    if button == "LeftButton" then
        if TrackingFrame or MiniMapTrackingFrame then
            TrackingFrame:InitMenu()
            ToggleDropDownMenu(1, nil, TrackingFrame.menu, this, 0, 0)
        end
    elseif button == "RightButton" then
        -- 三种模式循环切换: native → modern → hide → native
        if S_ChatBarDB.trackingMode == "native" then
            S_ChatBarDB.trackingMode = "modern"
            DEFAULT_CHAT_FRAME:AddMessage("|cffffff00追踪按钮模式: 现代 (modern)|r")
        elseif S_ChatBarDB.trackingMode == "modern" then
            S_ChatBarDB.trackingMode = "hide"
            DEFAULT_CHAT_FRAME:AddMessage("|cffffff00追踪按钮模式: 隐藏 (hide)|r")
        else
            S_ChatBarDB.trackingMode = "native"
            DEFAULT_CHAT_FRAME:AddMessage("|cffffff00追踪按钮模式: 原生 (native)|r")
        end

        -- 根据新模式立即刷新显示
        if S_ChatBarDB.trackingMode == "native" then
            TrackingFrame:Hide()
            MiniMapTrackingFrame:Show()
        elseif S_ChatBarDB.trackingMode == "modern" then
            TrackingFrame:Show()
            MiniMapTrackingFrame:Hide()
        elseif S_ChatBarDB.trackingMode == "hide" then
            TrackingFrame:Hide()
            MiniMapTrackingFrame:Hide()
        end
    end
end

local function TrinketMenu_OnClick()
    if TrinketMenu_OptFrame then
        if not TrinketMenu_OptFrame:IsShown() then
            TrinketMenu_OptFrame:Show()
        else
            TrinketMenu_OptFrame:Hide()
        end
    end
end

local function ActionBarProfiles_OnClick()
    if ABP_SlashCommand then
        ToggleDropDownMenu(1, nil, ABP_DropDownMenu, this, 0, 0)
    end
end

local function QuestAnnouncer_OnClick()
    DEFAULT_CHAT_FRAME.editBox:SetText("/QuestAnnouncer standby")
    ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
end

-- 重写的按钮点击事件的函数(切换频道时编辑框中的文本不会消失)--夜晨
local function Channel_OnClick(chatType, isChannel)
    local chatFrame = SELECTED_DOCK_FRAME

    local ButtonName = this:GetName()

    if (not chatFrame) then
        chatFrame = DEFAULT_CHAT_FRAME;
    end
    if not isChannel then
        chatFrame.editBox:Show();
        if (chatFrame.editBox.chatType == chatType) then
            ChatFrame_OpenChat("", chatFrame);
        else
            chatFrame.editBox.chatType = chatType;
        end
    else
        if arg1 == "LeftButton" then
            if type(chatType) == "number" then
                chatFrame.editBox.chatType = "CHANNEL";
                chatFrame.editBox.channelTarget = chatType
            else
                local id, name = GetChannelName(chatType)
                if id and name == chatType then
                    ChatFrameEditBox:Show()
                    ChatFrame_AddChannel(DEFAULT_CHAT_FRAME, chatType)
                    if (chatFrame.editBox.chatType == "CHANNEL") and (chatFrame.editBox.channelTarget == id) then
                        ChatFrame_OpenChat("", chatFrame);
                    else
                        chatFrame.editBox.chatType = "CHANNEL";
                        chatFrame.editBox.channelTarget = id
                    end
                else
                    JoinChannelByName(chatType, nil, 1)
                end
            end
        end
    end
    local text = chatFrame.editBox:GetText()
    text = processString(text)
    chatFrame.editBox:SetText(text)
    ChatEdit_UpdateHeader(chatFrame.editBox);
end

local function ChannelWhisper_OnClick()
    local chatFrame = SELECTED_DOCK_FRAME
    if (not chatFrame) then
        chatFrame = DEFAULT_CHAT_FRAME;
    end
    if arg1 == "LeftButton" then
        local lastTell = ChatEdit_GetLastTellTarget(chatFrame.editBox)
        ChatFrame_OpenChat("/w " .. lastTell, chatFrame)
    else
        if IsAddOnLoaded("WhisperTable") then
            ToggleFrame(WhisperTable_Main)
        end
    end
end

-- 创建各个按钮
CreateChatButton("Say", "说", "说", { 1, 1, 1 }, function() Channel_OnClick("SAY") end)
CreateChatButton("Yell", "喊", "喊话", { 255 / 255, 64 / 255, 64 / 255 }, function() Channel_OnClick("YELL") end)
CreateChatButton("Whisper", "密", "悄悄话", { 240 / 255, 128 / 255, 128 / 255 }, function() ChannelWhisper_OnClick() end)
CreateChatButton("Party", "队", "队伍", { 170 / 255, 170 / 255, 255 / 255 }, function() Channel_OnClick("PARTY") end)
CreateChatButton("Guild", "会", "公会", { 64 / 255, 255 / 255, 64 / 255 }, function() Channel_OnClick("GUILD") end)
CreateChatButton("Officer", "官", "官员", { 64 / 255, 255 / 255, 64 / 255 }, function() Channel_OnClick("OFFICER") end)
CreateChatButton("Raid", "团", "团队", { 255 / 255, 127 / 255, 0 }, function() Channel_OnClick("RAID") end)
CreateChatButton("RaidWarns", "告", "团队通知", { 1, .8, .6 }, function() Channel_OnClick("RAID_WARNING") end)
CreateChatButton("Battlefield", "战", "战场频道", { 255 / 255, 127 / 255, 0 }, function() Channel_OnClick("BATTLEGROUND") end)
CreateChatButton("General", "综", "综合", { 1, .6, .5 }, function() Channel_OnClick(GetChannelID("综合"), true) end)
CreateChatButton("Trade", "易", "交易频道", { 1, .6, .6 }, function() Channel_OnClick(GetChannelID("交易"), true) end)
CreateChatButton("World", "世", "世界频道", { 1, .8, .6 }, function() Channel_OnClick(Getchannel_name(), true) end)
CreateChatButton("HC", "硬", "硬核", { 230 / 255, 204 / 255, 100 / 255 }, function() Channel_OnClick("HARDCORE") end)
CreateChatButton("Meeting", "集", "集合石", { 255 / 255, 165 / 255, 0 }, ChannelMeeting_OnClick)
CreateChatButton("XyTracker", "愿", "许愿", { 147 / 255, 112 / 255, 219 / 255 }, ChannelXyTracker_OnClick)
CreateChatButton("AtlasLoot", "落", "掉落查询", { 180 / 255, 160 / 255, 230 / 255 }, AtlasLoot_OnClick)
CreateChatButton("SuperMacro", "宏", "宏设置", { 120 / 255, 160 / 255, 230 / 255 }, SuperMacro_OnClick)
CreateChatButton("ActionBarProfiles", "动", "动作条配置", { 200 / 255, 160 / 255, 230 / 255 }, ActionBarProfiles_OnClick)
CreateChatButton("TrinketMenu", "饰", "饰品设置", { 120 / 255, 200 / 255, 200 / 255 }, TrinketMenu_OnClick)
CreateChatButton("QuestAnnouncer", "报", "任务通报", { 60 / 255, 160 / 255, 250 / 255 }, QuestAnnouncer_OnClick)
CreateChatButton("Tracking", "追", "追踪设置", { 60 / 255, 160 / 255, 250 / 255 }, TrackingButton_OnClick)

-- Roll按钮和配置菜单
local roll = CreateFrame("Button", "rollMacro", chatbar)
roll:SetWidth(20)
roll:SetHeight(20)
roll:SetPoint("LEFT", chatbar, "RIGHT", 2, 0)
roll:RegisterForClicks("LeftButtonUp", "RightButtonUp")

roll.t = roll:CreateTexture()
roll.t:SetAllPoints()
roll.t:SetTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Up")

roll:SetScript("OnClick", function()
    local button = arg1
    if button == "LeftButton" then
        DEFAULT_CHAT_FRAME.editBox:SetText("/roll")
        ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
    else
        ToggleDropDownMenu(1, nil, S_ChatBar_Menu, this:GetName(), 0, 0) -- 修正锚点参数
    end
end)
roll:SetScript("OnEnter", function()
    GameTooltip:SetOwner(this, "ANCHOR_TOP", 0, 6)
    GameTooltip:AddLine("Roll")
    GameTooltip:AddLine("按住|cFF00CCFF Shift |r可移动聊天快捷按钮", 1, 1, 0)
    GameTooltip:AddLine("点击|cFF00CCFF 右键 |r可选择关闭/显示部分快捷按钮", 1, 1, 0)
    GameTooltip:Show()
end)
roll:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)
roll:SetScript("OnDragStart", function()
    if IsShiftKeyDown() then
        chatbar:StartMoving()
    end
end)
roll:SetScript("OnDragStop", function()
    chatbar:StopMovingOrSizing()
end)
roll:RegisterForDrag("LeftButton")

--是否乌龟服
local function IsTurtleServer()
    local _, build = GetBuildInfo()
    if build and tonumber(build) > 6141 then
        return true
    end
    return false
end

-- 创建配置菜单
S_ChatBar_Menu = CreateFrame("Frame", "S_ChatBar_Menu", UIParent, "UIDropDownMenuTemplate")
UIDropDownMenu_Initialize(S_ChatBar_Menu, function()
    UIDropDownMenu_AddButton {
        text = "显示频道按钮",
        isTitle = true,
        notCheckable = true
    }
    for k, btnName in ipairs(BUTTON_ORDER) do
        if buttonFrames[btnName] and buttonFrames[btnName].text then
            -- 判断对应名字的插件是否加载，如果没有加载，不显示此项的菜单选项
            if k <= 12 or (k == 13 and IsTurtleServer()) or (k >= 14 and IsAddOnLoaded(btnName)) or btnName == "Tracking" then
                local r, g, b = buttonFrames[btnName].text:GetTextColor()
                -- 使用闭包捕获当前按钮名称
                local currentBtnName = btnName -- 显式捕获循环变量
                UIDropDownMenu_AddButton {
                    text = buttonFrames[btnName].text:GetText(),
                    colorCode = string.format("|cFF%02x%02x%02x",
                        math.floor(r * 255 + 0.5),
                        math.floor(g * 255 + 0.5),
                        math.floor(b * 255 + 0.5)),
                    checked = S_ChatBarDB.buttons[currentBtnName],
                    func = function()
                        -- 切换状态并强制立即保存
                        S_ChatBarDB.buttons[currentBtnName] = not S_ChatBarDB.buttons[currentBtnName]
                        UpdateButtonLayout()
                        CloseDropDownMenus()
                        -- 强制刷新菜单
                        ToggleDropDownMenu(1, nil, S_ChatBar_Menu, "cursor", 0, 0)
                    end
                }
            end
        end
    end
end, "MENU")
