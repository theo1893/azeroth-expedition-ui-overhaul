--修正by:霍格-九像勺子
WorldBuffsTracker_SaveData = nil;
WorldBuffsTracker_Config = nil;
local WorldBuffsTracker_init = true;


local WBT_Config = {
    allow_alliance_report = true,
    allow_horde_report = true,
    allow_merge_report = true,
    report_to = 'GUILD', -- default: send report to guild
    concern = nil,
    alarm_switch_on = true,
    alarm_sound_switch_on = true,
    alarm_sound_Alliance = 'sound1',
    alarm_sound_Horde = 'sound1',
    mini_btn_position = 360,
    ShowHearthstoneAction = true
}

local WBT_Timer_Data = {
    Alliance_Onyxia = { form = nil, to = nil, active = false },
    Alliance_Nefarian = { form = nil, to = nil, active = false },
    Horde_Onyxia = { form = nil, to = nil, active = false },
    Horde_Nefarian = { form = nil, to = nil, active = false }
}

local WBT_Timer_Output = {
    Alliance_Onyxia = {
        lightning_time = 0,
        timer_bar = { bar_frame = nil, text_frame = nil },
        title = "[LM-黑龙]",
        report_text = '黑龙<$report_data>',
        remaining = 0,
        remaining_text = '暂无',
        obtain = nil,
        expire = nil,
        expire_short = nil
    },
    Alliance_Nefarian = {
        lightning_time = 0,
        timer_bar = { bar_frame = nil, text_frame = nil },
        title = "[LM-奈法]",
        report_text = '奈法<$report_data>',
        remaining = 0,
        remaining_text = '暂无',
        obtain = nil,
        expire = nil,
        expire_short = nil
    },
    Horde_Onyxia = {
        lightning_time = 0,
        timer_bar = { bar_frame = nil, text_frame = nil },
        title = "[BL-黑龙]",
        report_text = '黑龙<$report_data>',
        remaining = 0,
        remaining_text = '暂无',
        obtain = nil,
        expire = nil,
        expire_short = nil
    },
    Horde_Nefarian = {
        lightning_time = 0,
        timer_bar = { bar_frame = nil, text_frame = nil },
        title = "[BL-奈法]",
        report_text = '奈法<$report_data>',
        remaining = 0,
        remaining_text = '暂无',
        obtain = nil,
        expire = nil,
        expire_short = nil
    }
}

local WBT_Timer = {
    worldMap_Timer = {
        Alliance_Onyxia = true,
        Alliance_Nefarian = true,
        Horde_Onyxia = true,
        Horde_Nefarian = true
    },
    statusBar_Timer = {
        Alliance_Onyxia = true,
        Alliance_Nefarian = true,
        Horde_Onyxia = true,
        Horde_Nefarian = true
    },
    lightning_Timer = {
        Alliance_Onyxia = false,
        Alliance_Nefarian = false,
        Horde_Onyxia = false,
        Horde_Nefarian = false
    }
}

local caution = CreateFrame("Frame", "caution", UIParent)
caution.string = caution:CreateFontString("lushi", "BACKGROUND")
caution.string:SetPoint("CENTER", UIParent, "CENTER", 0, 2)
caution.string:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
caution.string:SetDrawLayer("ARTWORK")
caution:Hide()
caution.string:SetTextHeight(50);
-- caution.string:SetText("快回城，要挂龙头了\n还有15秒")
-- caution:Show()
-- 定义状态变量
local isFadingOut = true -- 是否正在变透明

-- 设置OnUpdate事件
caution:SetScript("OnUpdate", function()
    if not caution:IsShown() then return end
    if not self.elapsed then self.elapsed = 0 end
    if isFadingOut then
        self.elapsed = self.elapsed + arg1
    else
        self.elapsed = self.elapsed - arg1
    end
    if self.elapsed >= 1 then -- 每0.5秒更新一次颜色
        self.elapsed = 1
        isFadingOut = false
    elseif self.elapsed <= 0 then
        isFadingOut = true
        self.elapsed = 0
    end
    caution.string:SetTextColor(self.elapsed, 1, 0, self.elapsed)
end)

---------------------------------------------------------------------------------
-- 定义一个函数来查找背包中的炉石位置
-- local function FindHearthstoneLocation()
--     -- 遍历所有背包
--     for bag = 0, 4 do -- 0 表示主背包，1-4 表示其他背包
--         for slot = 1, GetContainerNumSlots(bag) do -- 遍历背包中的每个槽位
--             local itemLink = GetContainerItemLink(bag, slot) -- 获取槽位中的物品链接
--             if itemLink then -- 如果槽位中有物品
--                 local itemID = tonumber(string.match(itemLink, "item:(%d+)")) -- 提取物品ID
--                 if itemID == 6948 then -- 6948 是炉石的物品ID
--                     return bag, slot -- 返回背包编号和槽位编号
--                 end
--             end
--         end
--     end
--     return nil, nil -- 如果没有找到炉石，返回 nil
-- end

-- -- 定义一个全局变量来存储动作栏框架
-- local MyCustomActionBar = nil

-- -- 创建动作栏框架的函数
-- local function CreateCustomActionBar()
--     -- 如果动作栏已经存在，则直接返回
--     if MyCustomActionBar then return end

--     -- 创建一个新的动作栏框架
--     MyCustomActionBar = CreateFrame("Frame", "MyCustomActionBar", UIParent)
--     MyCustomActionBar:SetHeight(36)
--     MyCustomActionBar:SetWidth(36)
--     MyCustomActionBar:SetPoint("CENTER", 0, 0) -- 初始位置在屏幕中心
--     MyCustomActionBar:Hide()
    
--     -- 创建一个动作按钮
--     local button = CreateFrame("CheckButton", "MyCustomActionBarButton", MyCustomActionBar, "ActionBarButtonTemplate")
--     button:SetPoint("CENTER", MyCustomActionBar, "CENTER", 0, 0)
--     button:SetID(111) -- 设置按钮的ID为111

--      -- 将炉石放入按钮中
--     local bag, slot = FindHearthstoneLocation()
--     if slot then
--         PickupContainerItem(bag, slot) -- 捡起炉石
--         PlaceAction(button:GetID()) -- 将炉石放入按钮中
--         ClearCursor() -- 清除光标
--     end
--     -- 注册事件，更新按钮的显示
--     button:SetScript("OnEnter", function()
--         GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
--         if GameTooltip:SetAction(this:GetID()) then
--             this.updateTooltip = TOOLTIP_UPDATE_TIME;
--         else
--             this.updateTooltip = nil;
--         end
--     end)
--     button:SetScript("OnLeave", function()
--         this.updateTooltip = nil;
--         GameTooltip:Hide();
--     end)

-- end

-- -- 显示动作栏在鼠标位置
-- local function WBT_ShowActionBarAtCursor1()
--     if not MyCustomActionBar then return end
--     -- 如果动作栏已经显示，则不更新位置
--     if isActionBarDisplayed then
--         return
--     end
--     -- 获取鼠标位置
--     local x, y = GetCursorPosition()
--     local scale = UIParent:GetScale()
--     x, y = x / scale, y / scale

--     -- 设置动作栏位置到鼠标位置
--     MyCustomActionBar:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
--     MyCustomActionBar:Show()

--     -- 设置动作栏已显示的标志
--     isActionBarDisplayed = true
-- end

-- -- 计算鼠标位置在圆上的投影点
-- local function GetNearestPointOnCircle(mouseX, mouseY, centerX, centerY, radius)
--     -- 计算鼠标与圆心的相对位置
--     local dx = mouseX - centerX
--     local dy = mouseY - centerY

--     -- 计算鼠标到圆心的距离
--     local distance = math.sqrt(dx * dx + dy * dy)

--     -- 如果鼠标在圆内，直接返回鼠标位置
--     if distance <= radius then
--         return mouseX, mouseY
--     end

--     -- 计算投影点的坐标
--     local scale = radius / distance
--     local nearestX = centerX + dx * scale
--     local nearestY = centerY + dy * scale

--     return nearestX, nearestY
-- end

-- -- 显示动作栏在四分之一高度为半径,中心为圆点范围内距离鼠标最近的位置
-- local function WBT_ShowActionBarAtCursor2()
--     if not MyCustomActionBar then return end
--     -- 如果动作栏已经显示，则不更新位置
--     if isActionBarDisplayed then
--         return
--     end
--     -- 获取鼠标位置
--     local mouseX, mouseY = GetCursorPosition()
--     local scale = UIParent:GetScale()
--     -- mouseX, mouseY = mouseX / scale, mouseY / scale

--     -- 获取游戏窗口中心点
--     local centerX, centerY = UIParent:GetWidth() / 2, UIParent:GetHeight() / 2
--     -- 设置动作栏可移动范围的半径(高度的四分之一)
--     local radius = UIParent:GetHeight() / 4

--     -- 计算最近点
--     local nearestX, nearestY = GetNearestPointOnCircle(mouseX, mouseY, centerX, centerY, radius)

--     MyCustomActionBar:ClearAllPoints()
--     -- 设置动作栏位置到最近点
--     MyCustomActionBar:SetPoint("CENTER", UIParent, "BOTTOMLEFT", nearestX / scale, nearestY / scale)
--     MyCustomActionBar:Show()
--     -- 设置动作栏已显示的标志
--     isActionBarDisplayed = true
-- end

-- -- 创建动作栏
-- CreateCustomActionBar()
---------------------------------------------------------------------------------

local DomainName = 'TWB' --'TWB' --track world buffs , cause 'world' is start with 'w'， I wanna use this as a channel name
local ReportTo_List = { { 'GUILD', "公会" }, { 'PARTY', "队伍" }, { 'RAID', "团队" }, { 'SAY', "说" }, { 'YELL', "大喊" } } --, {'CHANNEL',"世界"}}
local WBT_Sounds = { { 'sound1', '音效1' }, { 'sound2', '音效2' }, { 'sound3', '音效3' }, { 'sound4', '音效4' }, { 'ForTheHorde', '为了部落' }, { 'ForTheAlliance', '为了联盟' } }
local WBT_Player = { realm = nil, name = nil, faction = nil }
local WBT_Timer_Buttons = {}
local WBT_Timer_Run_Status = false
local WBT_Server_Time = nil
--记秒器
local sec_counter = nil
local sync_send_counter = { false, nil }
local halfMin_counter = nil
local oneMin_counter = nil

local WBT_Options = {}
WBT_Options.Icons = {
    HeadOfOnyxia = 'Interface\\Icons\\INV_Misc_Head_Dragon_01',
    HeadOfNefaria = 'Interface\\Icons\\INV_Misc_Head_Dragon_Black'
}
WBT_Options.Sounds = {
    sound1 = 'Interface\\AddOns\\WorldBuffsTracker\\sounds\\sound1.ogg',
    sound2 = 'Interface\\AddOns\\WorldBuffsTracker\\sounds\\sound2.ogg',
    sound3 = 'Interface\\AddOns\\WorldBuffsTracker\\sounds\\sound3.ogg',
    sound4 = 'Interface\\AddOns\\WorldBuffsTracker\\sounds\\sound4.ogg',
    ForTheHorde = 'Interface\\AddOns\\WorldBuffsTracker\\sounds\\ForTheHorde.ogg',
    ForTheAlliance = 'Interface\\AddOns\\WorldBuffsTracker\\sounds\\ForTheAlliance.ogg'
}
WBT_Options.Consts = {
    Alliance = "【LM】",
    Horde = "【BL】",
    Onyxia = "黑龙",
    Nefarian = "奈法",
    O = "Onyxia",
    N = "Nefarian",
    A = "Alliance",
    H = "Horde"
}

WBT_Options.NPC = {
    Onyxia_Alliance = { name = "玛丁雷少校", yell = "一起庆祝英雄的诞生" },
    Nefarian_Alliance = { name = "艾法希比元帅", yell = "黑石领主已经被干掉了" },
    Onyxia_Horde = { name = "督军伦萨克", yell = "奥妮克希亚已经被斩杀了" },
    Nefarian_Horde = { name = "萨鲁法尔大王", yell = "奈法利安被杀掉了" },
}

local WBT_Handler = {
    init = function(self)
        --current realm name
        WBT_Player.realm = GetRealmName();
        --current player name
        WBT_Player.name = GetUnitName("PLAYER")

        self:Get_PlayerConfig_OrDefault(); --读取或创建基础数据
        self:Get_TimerData_OrDefault();    --读取或创建基础配置

        --指定item计时frame
        WBT_Timer_Output.Alliance_Onyxia.timer_bar = {
            bar_frame = WorldBuffsTrackerItemFrame_Item1,
            text_frame =
                WorldBuffsTrackerItemFrame_Item1_Text
        };
        WBT_Timer_Output.Alliance_Nefarian.timer_bar = {
            bar_frame = WorldBuffsTrackerItemFrame_Item2,
            text_frame =
                WorldBuffsTrackerItemFrame_Item2_Text
        };
        WBT_Timer_Output.Horde_Onyxia.timer_bar = {
            bar_frame = WorldBuffsTrackerItemFrame_Item3,
            text_frame =
                WorldBuffsTrackerItemFrame_Item3_Text
        };
        WBT_Timer_Output.Horde_Nefarian.timer_bar = {
            bar_frame = WorldBuffsTrackerItemFrame_Item4,
            text_frame =
                WorldBuffsTrackerItemFrame_Item4_Text
        };
        --设置字体大小
        WBT_Timer_Output.Alliance_Onyxia.timer_bar.text_frame:SetFont(STANDARD_TEXT_FONT, 10)
        WBT_Timer_Output.Alliance_Nefarian.timer_bar.text_frame:SetFont(STANDARD_TEXT_FONT, 10)
        WBT_Timer_Output.Horde_Onyxia.timer_bar.text_frame:SetFont(STANDARD_TEXT_FONT, 10)
        WBT_Timer_Output.Horde_Nefarian.timer_bar.text_frame:SetFont(STANDARD_TEXT_FONT, 10)

        --Config 基础配置
        WorldBuffsTrackerConfigFrame_ReportAlliance_allowed:SetChecked(WBT_Config["allow_alliance_report"])
        WorldBuffsTrackerConfigFrame_ReportHorde_allowed:SetChecked(WBT_Config["allow_horde_report"])
        WorldBuffsTrackerConfigFrame_MergeReport_allowed:SetChecked(WBT_Config["allow_merge_report"])
        WorldBuffsTrackerConfigFrame_AlarmSwitch:SetChecked(WBT_Config["alarm_switch_on"])
        WorldBuffsTrackerConfigFrame_AlarmSoundSwitch:SetChecked(WBT_Config["alarm_sound_switch_on"])
        WorldBuffsTrackerConfigFrame_Hearthstone:SetChecked(WBT_Config["ShowHearthstoneAction"])

        WorldBuffsTrackerMiniBtn_UpdatePosition();
    end,
    Get_PlayerConfig_OrDefault = function()
        WorldBuffsTracker_Config = WorldBuffsTracker_Config or {};

        if not WorldBuffsTracker_Config[WBT_Player.name] then
            WorldBuffsTracker_Config[WBT_Player.name] = WBT_Config; --赋予当前角色默认配置
        else
            WBT_Config = WorldBuffsTracker_Config[WBT_Player.name]
        end

        --后续更新补的配置
        -- if not WBT_Config.mini_btn_position then
        --     WBT_Config.mini_btn_position = 360
        -- end
        -- if not WBT_Config.alarm_sound_switch_on then
        --     WBT_Config.alarm_sound_switch_on = true
        -- end
        -- if not WBT_Config.alarm_sound_Alliance then
        --     WBT_Config.alarm_sound_Alliance = 'sound1'
        -- end
        -- if not WBT_Config.alarm_sound_Horde then
        --     WBT_Config.alarm_sound_Horde = 'sound1'
        -- end
        -- if not WBT_Config.ShowHearthstoneAction then
        --     WBT_Config.ShowHearthstoneAction = true
        -- end
    end,
    Get_TimerData_OrDefault = function()
        --存储对象为空则创建
        WorldBuffsTracker_SaveData = WorldBuffsTracker_SaveData or {}
        --当前服务器对象为空则取默认值
        WBT_Timer_Data = WorldBuffsTracker_SaveData[WBT_Player.realm] or WBT_Timer_Data;
    end,
    Get_CharacterInfo = function()
        WBT_Player.faction = UnitFactionGroup('PLAYER') --addonloaded 时间取不到角色阵营
    end,
    Set_CharacterConfig = function()
        if not WBT_Config.concern then
            WBT_Config.concern = WBT_Player.faction .. '_Onyxia' --默认设置当前阵营的黑龙MM头作为关注龙头
        end
        --选中当前关注的龙头
        local check_btn = getglobal('WorldBuffsTrackerItemFrame_Check_' .. WBT_Config.concern)
        if not check_btn:GetChecked() then
            check_btn:SetChecked(true);
        end
    end,
    Set_Timer_Data = function(key, from, to)
        WBT_Timer_Data[key].from = from;
        WBT_Timer_Data[key].to = to;
        WBT_Timer_Data[key].active = true;
        --当前服务器龙头时间持久存储
        WorldBuffsTracker_SaveData[WBT_Player.realm] = WBT_Timer_Data

        --同时打开该龙头的相关计时器
        WBT_Timer.worldMap_Timer[key] = true;
        WBT_Timer.statusBar_Timer[key] = true;
    end,
    Set_Lightning_Data = function(self, key, serverTime)
        --报警开关已开启或当前龙头闪电计时未激活，才做处理;  （另外：刚上线， 如果还没接收到服务器时间，也不处理了，没有参考时间计算）
        if WBT_Config.alarm_switch_on and not WBT_Timer.lightning_Timer[key] and WBT_Server_Time then
            WBT_Timer_Output[key].lightning_time = WBT_Server_Time + 18; --从交任务触发喊话到吃上buff 大约18秒
            if serverTime then                                           --如果是同步的服务器时间，那么以这个为准
                WBT_Timer_Output[key].lightning_time = serverTime;
            end

            WBT_Timer.lightning_Timer[key] = true; --设好时间后，开启闪电计时

            --设置龙头计时（强制设置，计时之前的龙头计时未完成；因为是新龙头，以此为准）
            self.Set_Timer_Data(key, WBT_Server_Time, WBT_Server_Time + 7200)
            --设置好报警计时器后，立即进行一次提示
            local t = split(key, "_") --faction & dragon
            DEFAULT_CHAT_FRAME:AddMessage('|cFFFF8080' .. WBT_Options.Consts[t[1]] .. WBT_Options.Consts[t[2]] .. '|r 闪电报警……|cffff2020即将释放|r')
            --如果音效提醒开启了， 就播放提醒音效
            if WBT_Config.alarm_sound_switch_on then
                PlaySoundFile(WBT_Options.Sounds[WBT_Config['alarm_sound_' .. t[1]]])
            end
        end
    end,
    Update_Timer_Output = function()
        local remaining_sec, remaining_text
        local diff_time = WBT_Server_Time - time()
        for k, v in pairs(WBT_Timer_Data) do
            if v.active and v.to - WBT_Server_Time > 0 then
                --剩余时间大于100秒则以单位'分'来计时
                remaining_sec = v.to - WBT_Server_Time
                if remaining_sec >= 100 then
                    remaining_text = math.ceil(remaining_sec / 60) .. '分'
                else
                    remaining_text = remaining_sec .. '秒'
                end

                WBT_Timer_Output[k].obtain = date("%Y-%m-%d %H:%M:%S", v.from - diff_time)
                WBT_Timer_Output[k].expire = date("%Y-%m-%d %H:%M:%S", v.to - diff_time)
                WBT_Timer_Output[k].expire_short = string.sub(date('%X', v.to - diff_time), 0, 5)
                WBT_Timer_Output[k].remaining = remaining_sec
                WBT_Timer_Output[k].remaining_text = remaining_text
            else
                --如果活跃状态还是true ， 则更新为false； 同时更新output
                if v.active then
                    WBT_Timer_Output[k].remaining = 0
                    WBT_Timer_Output[k].remaining_text = "暂无"
                    --更新龙头活跃状态
                    WBT_Timer_Data[k].active = false
                end
            end

            --如果当前龙头的闪电报警计时器活跃中， 且闪电报警已超时， 则关闭闪电报警计时器
            if WBT_Timer.lightning_Timer[k] and WBT_Timer_Output[k].lightning_time - WBT_Server_Time < 0 then
                if caution:IsShown() then
                    caution:Hide()
                end
                WBT_Timer.lightning_Timer[k] = false;
            end
        end
    end,
    Start_Timer = function(self)
        self.Update_Timer_Output()
        self:Run_Timer();
        self.Run_MainStatus_Timer(WBT_Config.concern); --主计时条直接run 一次
        WBT_Timer_Run_Status = true;
    end,
    Run_Timer = function(self)
        self.Update_Timer_Output(); --更新计时

        --世界地图按钮计时器
        for k, v in pairs(WBT_Timer.worldMap_Timer) do
            if v then
                self.Run_WorldMap_Timer(k);
            end
        end
        --主界面进度条计时器
        for k, v in pairs(WBT_Timer.statusBar_Timer) do
            if v then
                self:Run_StatusBar_Timer(k);
            end
        end

        --如果配置开启了闪电报警
        if WBT_Config.alarm_switch_on then
            for k, v in pairs(WBT_Timer.lightning_Timer) do
                if v then
                    self.Run_Lighting_Timer(k);
                end
            end
        end
    end,
    Run_WorldMap_Timer = function(key)
        --因为世界地图按钮是按需创建的， 所以要判断一下该按钮是否存在
        if WBT_Timer_Buttons[key] then
            WBT_Timer_Buttons[key]:SetText(WBT_Timer_Output[key].remaining_text);
        end
        if not WBT_Timer_Data[key].active then
            --关闭该龙头的相关计时器
            WBT_Timer.worldMap_Timer[key] = false
        end
    end,
    Run_StatusBar_Timer = function(self, key)
        WBT_Timer_Output[key].timer_bar.bar_frame:SetValue(WBT_Timer_Output[key].remaining);
        WBT_Timer_Output[key].timer_bar.text_frame:SetText(WBT_Timer_Output[key].remaining_text);
        --判断主计时器是否是当前龙头
        -- **************新增 ↓ ↓ ↓ by 夜晨***************
        if WBT_Config.concern == "Priority_display" then
            self.Run_MainStatus_Timer(WBT_Config.concern)
        else
            -- **************新增 ↑ ↑ ↑ ***************
            if WBT_Config.concern == key then
                self.Run_MainStatus_Timer(key)
            end
        end

        if not WBT_Timer_Data[key].active then
            --关闭该龙头的相关计时器
            WBT_Timer.statusBar_Timer[key] = false
        end
    end,
    Run_MainStatus_Timer = function(key)
        -- **************新增 ↓ ↓ ↓ by 夜晨***************

        -- 获取同阵营剩余时间少的那个龙头
        if key == "Priority_display" then
            local time1 = WBT_Timer_Output[WBT_Player.faction .. "_Onyxia"].remaining
            local time2 = WBT_Timer_Output[WBT_Player.faction .. "_Nefarian"].remaining
            if time1 == 0 and time2 == 0 then
                key = WBT_Player.faction .. "_Onyxia"
            else
                if time1 < time2 then
                    key = WBT_Player.faction .. "_Onyxia"
                else
                    key = WBT_Player.faction .. "_Nefarian"
                end
            end
        end
        -- **************新增 ↑ ↑ ↑ ***************
        WorldBuffsTrackerMainFrame_Timer_StatusBar:SetValue(WBT_Timer_Output[key].remaining)
        WorldBuffsTrackerMainFrame_Timer_StatusBar_Title:SetText(WBT_Timer_Output[key].title)
        WorldBuffsTrackerMainFrame_Timer_StatusBar_Text:SetText(WBT_Timer_Output[key].remaining_text)
    end,
    Run_Lighting_Timer = function(key)
        local remaining = WBT_Timer_Output[key].lightning_time - WBT_Server_Time;
        --local t = string.split(key, "_")  --faction & dragon
        local t = split(key, "_") --faction & dragon
        --如果是龙头阵营玩家就开始倒数报警， 否则只在结束时提醒
        if t[1] == WBT_Player.faction then
            if remaining >= 10 and remaining < 35 then --炉石需要10秒，所以倒数到10 就不继续了
                DEFAULT_CHAT_FRAME:AddMessage('|cFFFF8080' ..
                    WBT_Options.Consts[t[1]] .. WBT_Options.Consts[t[2]] .. '|r 闪电报警……|cffff2020' .. remaining .. '|r秒')
                caution.string:SetText("快回城，要挂龙头了\n还有" .. remaining .. "秒")
                caution:Show()
                if WBT_Config.ShowHearthstoneAction and not UnitAffectingCombat("player") then
                    WorldBuffsTracker_ShowActionBar() -- 使用炉石模块显示动作栏
                end
            else
                caution:Hide()
                WorldBuffsTracker_HideActionBar() -- 使用炉石模块隐藏动作栏
            end
        end

        if remaining == 0 then --计时结束后，提醒已完成
            DEFAULT_CHAT_FRAME:AddMessage('|cFFFF8080' .. WBT_Options.Consts[t[1]] .. WBT_Options.Consts[t[2]] .. '|r 闪电报警……|cffff2020已释放完成|r')
            caution:Hide()
            WorldBuffsTracker_HideActionBar() -- 使用炉石模块隐藏动作栏
        end
    end,
    Event_WorldMapUpdate_Handler = function(self)
        WBT_Timer_Buttons = WBT_Timer_Buttons or {};
        --hide all buttons when world map closed
        for _, v in pairs(WBT_Timer_Buttons) do
            v:Hide();
        end
        --取得当前地图名称， 根据名称决定是否显示计时按钮
        local map = GetMapInfo();
        if map == "Stormwind" then
            --Onyxia button create or show
            local btn_name_Onyxia = DomainName .. "_Alliance_Onyxia"
            WBT_Timer_Buttons["Alliance_Onyxia"] = WBT_Timer_Buttons["Alliance_Onyxia"] or
                self:CreateTimerButton(btn_name_Onyxia, 160, -290, "N/A", WBT_Options.Icons.HeadOfOnyxia)
            if not WBT_Timer_Buttons["Alliance_Onyxia"]:IsShown() then
                WBT_Timer_Buttons["Alliance_Onyxia"]:Show();
            end

            --Nefarian button create or show
            local btn_name_Nefarian = DomainName .. "_Alliance_Nefarian"
            WBT_Timer_Buttons["Alliance_Nefarian"] = WBT_Timer_Buttons["Alliance_Nefarian"] or
                self:CreateTimerButton(btn_name_Nefarian, 245, -225, "N/A", WBT_Options.Icons.HeadOfNefaria)
            if not WBT_Timer_Buttons["Alliance_Nefarian"]:IsShown() then
                WBT_Timer_Buttons["Alliance_Nefarian"]:Show();
            end
        elseif map == "Ogrimmar" then
            --Onyxia button create or show
            local btn_name_Onyxia = DomainName .. "_Horde_Onyxia"
            WBT_Timer_Buttons["Horde_Onyxia"] = WBT_Timer_Buttons["Horde_Onyxia"] or
                self:CreateTimerButton(btn_name_Onyxia, -50, -230, "N/A", WBT_Options.Icons.HeadOfOnyxia)
            if not WBT_Timer_Buttons["Horde_Onyxia"]:IsShown() then
                WBT_Timer_Buttons["Horde_Onyxia"]:Show();
            end

            --Nefarian button create or show
            local btn_name_Nefarian = DomainName .. "_Horde_Nefarian"
            WBT_Timer_Buttons["Horde_Nefarian"] = WBT_Timer_Buttons["Horde_Nefarian"] or
                self:CreateTimerButton(btn_name_Nefarian, 50, -220, "N/A", WBT_Options.Icons.HeadOfNefaria)
            if not WBT_Timer_Buttons["Horde_Nefarian"]:IsShown() then
                WBT_Timer_Buttons["Horde_Nefarian"]:Show();
            end
        end
    end,
    CreateTimerButton = function(self, name, x, y, text, texture)
        local btn = CreateFrame("Button", name .. "_Button_Frame", WorldMapFrame)
        SetSize(btn, 30, 30)
        btn:SetFont(STANDARD_TEXT_FONT, 12)
        btn:SetPoint("Center", WorldMapFrame, "Center", x, y)
        btn:SetText(text)
        btn:SetFrameLevel(255);
        btn:SetScript("OnEnter", function()
            self:ShowGameToolTip(btn);
        end)
        btn:SetScript('OnLeave', function() WorldBuffsTrackerTooltip:Hide() end)
        local btn_texture = btn:CreateTexture(nil, "ARTWORK")
        btn_texture:SetTexture(texture)
        btn_texture:SetAllPoints();

        return btn
    end,
    Event_DragonSlayer_Roaring = function(self)
        --联盟方Onyxia
        if arg2 == WBT_Options.NPC.Onyxia_Alliance.name and string.find(arg1, WBT_Options.NPC.Onyxia_Alliance.yell) then
            self:Set_Lightning_Data('Alliance_Onyxia')

            self.Sync_Send_Lightning('Alliance_Onyxia', self:Get_Roar_BuffTime()) --闪电通知
            --联盟方Nefarian
        elseif arg2 == WBT_Options.NPC.Nefarian_Alliance.name and string.find(arg1, WBT_Options.NPC.Nefarian_Alliance.yell) then
            self:Set_Lightning_Data('Alliance_Nefarian')

            self.Sync_Send_Lightning('Alliance_Nefarian', self:Get_Roar_BuffTime()) --闪电通知
            --部落方Onyxia
        elseif arg2 == WBT_Options.NPC.Onyxia_Horde.name and string.find(arg1, WBT_Options.NPC.Onyxia_Horde.yell) then
            self:Set_Lightning_Data('Horde_Onyxia')

            self.Sync_Send_Lightning('Horde_Onyxia', self:Get_Roar_BuffTime()) --闪电通知
            --部落方Nefarian
        elseif arg2 == WBT_Options.NPC.Nefarian_Horde.name and string.find(arg1, WBT_Options.NPC.Nefarian_Horde.yell) then
            self:Set_Lightning_Data('Horde_Nefarian')

            self.Sync_Send_Lightning('Horde_Nefarian', self:Get_Roar_BuffTime()) --闪电通知
        end
    end,
    Get_Roar_BuffTime = function()
        local t = nil
        if WBT_Server_Time then
            t = WBT_Server_Time + 18;
        end
        return t;
    end,
    GetReportMsg = function(self, timer_key)
        local msg = nil
        local data = WBT_Timer_Output[timer_key]

        if data.remaining == 0 then
            msg = string.gsub(data.report_text, '$report_data', '暂无')
        else
            msg = string.gsub(data.report_text, '$report_data', data.remaining_text)
        end

        return msg;
    end,
    ShowGameToolTip = function(self, button)
        local t = split(button:GetName(), "_");

        WorldBuffsTrackerTooltip:SetOwner(button, 'ANCHOR_RIGHT')
        WorldBuffsTrackerTooltip:ClearLines()

        if WBT_Timer_Data[t[2] .. '_' .. t[3]].active then
            WorldBuffsTrackerTooltip:AddLine(WBT_Options.Consts[t[2]] .. "龙头时间:\n")
            WorldBuffsTrackerTooltip:AddLine("开始:" .. WBT_Timer_Output[t[2] .. '_' .. t[3]].obtain)
            WorldBuffsTrackerTooltip:AddLine("结束:" .. WBT_Timer_Output[t[2] .. '_' .. t[3]].expire)
        else
            WorldBuffsTrackerTooltip:AddLine(WBT_Options.Consts[t[2]] .. "龙头时间:\n")
            WorldBuffsTrackerTooltip:AddLine("暂无")
        end

        WorldBuffsTrackerTooltip:Show()
    end,
    FormatAddonSyncMsg = function(self)
        local text = ""
        local f_d = nil
        for k, v in pairs(WBT_Timer_Data) do
            if WBT_Timer_Data[k].active then
                f_d = split(k, '_');
                text = text .. string.sub(f_d[1], 0, 1) .. WBT_Timer_Data[k].to .. string.sub(f_d[2], 0, 1)
            end
        end
        return text;
    end,
    Set_Config = function(name, value)
        WBT_Config[name] = value;
        WorldBuffsTracker_Config[WBT_Player.name] = WBT_Config
    end,
    ClearTimer = function(self, msg)
        if msg == "c" or msg == "c1" then
            self.Set_Timer_Data("Alliance_Onyxia", WBT_Server_Time - 7200, WBT_Server_Time)
        end

        if msg == "c" or msg == "c2" then
            self.Set_Timer_Data("Alliance_Nefarian", WBT_Server_Time - 7200, WBT_Server_Time)
        end

        if msg == "c" or msg == "c3" then
            self.Set_Timer_Data("Horde_Onyxia", WBT_Server_Time - 7200, WBT_Server_Time)
        end

        if msg == "c" or msg == "c4" then
            self.Set_Timer_Data("Horde_Nefarian", WBT_Server_Time - 7200, WBT_Server_Time)
        end
    end,
    Set_ReportToItems = function()
        local item = {}
        for i, o in ipairs(ReportTo_List) do
            item = {
                text = o[2],
                func = WorldBuffsTrackerConfig_ReportTo_OnClick
            }

            UIDropDownMenu_AddButton(item)
        end
    end,
    Set_SoundAllianceItems = function()
        local item = {}
        for i, o in ipairs(WBT_Sounds) do
            item = {
                text = o[2],
                func = WorldBuffsTrackerConfig_SoundAlliance_OnClick
            }

            UIDropDownMenu_AddButton(item)
        end
    end,
    Set_SoundHordeItems = function()
        local item = {}
        for i, o in ipairs(WBT_Sounds) do
            item = {
                text = o[2],
                func = WorldBuffsTrackerConfig_SoundHorde_OnClick
            }

            UIDropDownMenu_AddButton(item)
        end
    end,
    CheckAndJoin_TWBChannel = function()
        --如果已退出 TWB 频道， 则自动加入； 每30S 执行一次
        local quitted = true
        local chanList = { GetChannelList() }
        for k, v in next, chanList do
            if v == DomainName then
                quitted = false
                break
            end
        end

        if quitted then
            JoinChannelByName(DomainName)
        end
    end,
    Sync_Send = function(self)
        if UnitLevel('Player') >= 40 then
            self:Sync_Send_Imm()
        else
            sync_send_counter = { true, time() }
        end
    end,
    Sync_Send_Imm = function(self)
        sync_send_counter[1] = false --小号发送同步消息标记
        local msg = self:FormatAddonSyncMsg()
        --有信息才发送，没有就不发了
        if string.len(msg) > 0 then
            --SendAddonMessage(DomainName.."Resp", msg, chat_type);
            SendChatMessage('SyncS:' .. msg, 'CHANNEL', nil, GetChannelName(DomainName))
        end
    end,
    Sync_Send_Addon = function(self)
        local msg = self:FormatAddonSyncMsg()
        --有信息才发送，没有就不发了
        if string.len(msg) > 0 then
            SendAddonMessage(DomainName .. "_MSG", 'SyncS:' .. msg, 'GUILD');
            SendAddonMessage(DomainName .. "_MSG", 'SyncS:' .. msg, 'PARTY');
            SendAddonMessage(DomainName .. "_MSG", 'SyncS:' .. msg, 'RAID');
        end
    end,
    Sync_Send_Lightning = function(timer_key, ltime)
        SendChatMessage('Lightning:' .. ltime .. '@' .. timer_key, 'CHANNEL', nil, GetChannelName(DomainName))

        SendAddonMessage(DomainName .. "_MSG", 'Lightning:' .. ltime .. '@' .. timer_key, 'GUILD');
        SendAddonMessage(DomainName .. "_MSG", 'Lightning:' .. ltime .. '@' .. timer_key, 'PARTY');
        SendAddonMessage(DomainName .. "_MSG", 'Lightning:' .. ltime .. '@' .. timer_key, 'RAID');
    end,
    Sync_Receive = function(self, msg)
        if msg and string.len(msg) > 0 then
            local _, _, msg_type = string.find(msg, '(%a+):.+')

            if msg_type == 'Lightning' then --闪电报警
                local _, _, serverTime, key = string.find(msg, 'Lightning:(%d*)@(%a+_%a+)')
                if key then
                    self:Set_Lightning_Data(key, tonumber(serverTime))
                end
            elseif msg_type == 'SyncS' then --同步计时
                if sync_send_counter[1] then
                    sync_send_counter[1] = false
                end
                local list = string.gmatch(msg, '[AH]%d+[ON]')
                local f, t, d, f_, d_
                for item in list do
                    f, t, d = string.match(item, '([AH])(%d+)([ON])')
                    f_, d_ = WBT_Options.Consts[f], WBT_Options.Consts[d]
                    if not WBT_Timer_Data[f_ .. '_' .. d_].active and tonumber(t) > WBT_Server_Time and (tonumber(t) - WBT_Server_Time <= 7200) then
                        self.Set_Timer_Data(f_ .. '_' .. d_, t - 7200, t);
                    end
                end
            end
        end
    end
}


function WorldBuffsTracker_OnLoad()
    this:RegisterEvent("ADDON_LOADED")
    this:RegisterEvent("PLAYER_ENTERING_WORLD")
    this:RegisterEvent("CHAT_MSG_MONSTER_YELL");
    this:RegisterEvent("WORLD_MAP_UPDATE");
    this:RegisterEvent("CHAT_MSG_SYSTEM")
    this:RegisterEvent("CHAT_MSG_ADDON")
    this:RegisterEvent("CHAT_MSG_WHISPER")
    --this:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE"); --当角色自己进入或厉害频道
    this:RegisterEvent("CHAT_MSG_CHANNEL_JOIN") --用户进入频道
    --this:RegisterEvent("CHAT_MSG_CHANNEL_LEAVE") --用户离开频道
    this:RegisterEvent("CHAT_MSG_CHANNEL");
    --this:RegisterEvent("GUILD_ROSTER_UPDATE")

    SLASH_WorldBuffsTrackerCmd1 = "/dtdg";
    SlashCmdList["WorldBuffsTrackerCmd"] = WBT_HandleSlashCmd;
end

function WBT_HandleSlashCmd(msg)
    local msg = strlower(msg);
    if msg == "show" then
        WorldBuffsTrackerFrame:Show();
    elseif msg == "info" then
        DEFAULT_CHAT_FRAME:AddMessage("build by: 拉文郡-狂暴恶棍");
        DEFAULT_CHAT_FRAME:AddMessage("插件介绍使用可在B站搜索“彩色过客”");
    elseif string.match(msg, "^c[1234]?$") then
        WBT_Handler:ClearTimer(msg)
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF8080龙头计时插件命令：|r -show --打开插件面板");
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF8080龙头计时插件命令：|r -info --查看插件信息");
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF8080龙头计时插件命令：|r -c --清除所有龙头计时");
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF8080龙头计时插件命令：|r -c1 --清除联盟奥妮克希亚龙头计时");
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF8080龙头计时插件命令：|r -c2 --清除联盟奈法利安龙头计时");
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF8080龙头计时插件命令：|r -c3 --清除部落奥妮克希亚龙头计时");
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF8080龙头计时插件命令：|r -c4 --清除部落奈法利安龙头计时");
    end

    --debug cmd
end

function WorldBuffsTracker_OnEvent(event)
    if event == "ADDON_LOADED" and arg1 == "WorldBuffsTracker" then
        --插件加载完成时，初始化插件信息，比如读取或创建基础数据/配置数据 等等；
        WBT_Handler:init();
        -- 初始化炉石模块
        WorldBuffsTracker_Initialize()
    elseif event == "PLAYER_ENTERING_WORLD" then
        --if not LFT then
        SendChatMessage('.server info')
        --end
        --角色进入游戏时，读取角色信息，比如角色的阵营，等级，职业等等
        WBT_Handler.Get_CharacterInfo();
        WBT_Handler:Set_CharacterConfig();

        DEFAULT_CHAT_FRAME:AddMessage(event)
    elseif event == "CHAT_MSG_SYSTEM" then
        --DEFAULT_CHAT_FRAME:AddMessage(arg1)
        if string.find(arg1, 'Server Time:') then
            local _, _, dd, mm, yyyy, hh, minute, second = string.find(arg1,
                'Server Time:%s%a+,%s(%d+).(%d+).(%d+)%s(%d+):(%d+):(%d+)')
            DEFAULT_CHAT_FRAME:AddMessage(yyyy .. '-' .. mm .. '-' .. dd .. ' ' .. hh .. ':' .. minute .. ':' .. second)

            local ct = time({
                year = yyyy,
                month = mm,
                day = dd,
                hour = hh,
                min = minute,
                sec = second
            })

            WBT_Server_Time = ct;
            --角色进入游戏（或reload），且取得服务器时间后， 再开始计时（如果计时尚未开始的话）
            if not WBT_Timer_Run_Status then
                WBT_Handler:Start_Timer();
            end
        end
    elseif event == "WORLD_MAP_UPDATE" then
        WBT_Handler:Event_WorldMapUpdate_Handler();
    elseif event == "CHAT_MSG_MONSTER_YELL" then
        WBT_Handler:Event_DragonSlayer_Roaring()
    elseif event == "CHAT_MSG_CHANNEL_JOIN" and arg9 == DomainName then
        --args: text, playerName, languageName, channelName, playerName2, specialFlags, zoneChannelID, channelIndex, channelBaseName ……
        WBT_Handler:Sync_Send()
        WBT_Handler:Sync_Send_Addon()
    elseif event == "CHAT_MSG_CHANNEL" and arg9 == DomainName and arg2 ~= WBT_Player.name and WBT_Timer_Run_Status then
        --args：text, playerName, languageName, channelName, playerName2, specialFlags, zoneChannelID, channelIndex, channelBaseName ……
        WBT_Handler:Sync_Receive(arg1)
    elseif event == "CHAT_MSG_ADDON" then
        if arg1 == DomainName .. '_MSG' and arg4 ~= WBT_Player.name and WBT_Timer_Run_Status then
            --args: prefix, text, channel, sender, target
            WBT_Handler:Sync_Receive(arg2)
        end
        --elseif event == "GUILD_ROSTER_UPDATE" then
        --DEFAULT_CHAT_FRAME:AddMessage(event..':'..tostring(arg1))
    end
end

function WorldBuffsTracker_OnUpdate()
    local now = time()

    -- 每秒执行一次
    if not sec_counter or time() - sec_counter >= 1 then
        if WBT_Server_Time then
            WBT_Server_Time = WBT_Server_Time + 1 --实时计算服务器时间
        end

        sec_counter = now


        --运行计时器
        if WBT_Timer_Run_Status then
            WBT_Handler:Run_Timer()
        end
    end

    -- 每3秒执行一次，针对40级以下角色同步消息发送
    if sync_send_counter[1] and sync_send_counter[2] and time() - sync_send_counter[2] >= 3 then
        sync_send_counter[2] = nil
        WBT_Handler:Sync_Send_Imm()
    end

    --每30S执行一次
    if not halfMin_counter or now - halfMin_counter >= 30 then
        WBT_Handler:Sync_Send_Addon()
        halfMin_counter = now
        WBT_Handler:CheckAndJoin_TWBChannel(); --频道检查
    end
    --每60S执行一次
    if not oneMin_counter or now - oneMin_counter >= 60 then
        WBT_Handler:Sync_Send()
        oneMin_counter = now
    end
end

--[[报告设置]]
function WorldBuffsTracker_ReportAlliance_Click()
    --DEFAULT_CHAT_FRAME:AddMessage(getglobal(this:GetName()..'Text'):GetText())
    if this:GetChecked() then
        WBT_Handler.Set_Config("allow_alliance_report", true);
    else
        WBT_Handler.Set_Config("allow_alliance_report", false);
    end
end

function WorldBuffsTracker_ReportHorde_Click()
    if this:GetChecked() then
        WBT_Handler.Set_Config("allow_horde_report", true);
    else
        WBT_Handler.Set_Config("allow_horde_report", false);
    end
end

function WorldBuffsTracker_MergeReport_Click()
    if this:GetChecked() then
        WBT_Handler.Set_Config("allow_merge_report", true);
    else
        WBT_Handler.Set_Config("allow_merge_report", false);
    end
end

function WorldBuffsTracker_AlarmSwitch_Click()
    if this:GetChecked() then
        WBT_Handler.Set_Config("alarm_switch_on", true);
    else
        WBT_Handler.Set_Config("alarm_switch_on", false);
    end
end

function WorldBuffsTracker_Hearthstone_Click()
    if this:GetChecked() then
        WBT_Handler.Set_Config("ShowHearthstoneAction", true);
    else
        WBT_Handler.Set_Config("ShowHearthstoneAction", false);
    end
end

function WorldBuffsTracker_AlarmSound_Click()
    if this:GetChecked() then
        WBT_Handler.Set_Config("alarm_sound_switch_on", true);
    else
        WBT_Handler.Set_Config("alarm_sound_switch_on", false);
    end
end

--[[报告设置结束]]

--[[mainframe 以及 child frame 事件]]
function WorldBuffsTracker_Select_OnClick()
    if WorldBuffsTrackerConfigFrame:IsShown() then
        WorldBuffsTrackerConfigFrame:Hide()
    end
    if WorldBuffsTrackerItemFrame:IsShown() then
        WorldBuffsTrackerItemFrame:Hide()
    else
        WorldBuffsTrackerItemFrame:Show()
    end
end

function WorldBuffsTracker_Config_OnClick()
    if WorldBuffsTrackerItemFrame:IsShown() then
        WorldBuffsTrackerItemFrame:Hide()
    end

    if WorldBuffsTrackerConfigFrame:IsShown() then
        WorldBuffsTrackerConfigFrame:Hide()
    else
        WorldBuffsTrackerConfigFrame:Show()
    end
end

function WorldBuffsTracker_Report_OnClick()
    local OnyxiaMsg, NefarianMsg
    local text = ""

    if WBT_Config["allow_alliance_report"] then -- 报告联盟
        OnyxiaMsg = WBT_Handler:GetReportMsg('Alliance_Onyxia')
        NefarianMsg = WBT_Handler:GetReportMsg('Alliance_Nefarian')

        if arg1 == "LeftButton" then
            if WBT_Config["allow_merge_report"] then -- 同阵营单行报告
                SendChatMessage(WBT_Options.Consts['Alliance'] .. OnyxiaMsg .. NefarianMsg, WBT_Config.report_to, nil,
                    nil)
            else
                SendChatMessage(WBT_Options.Consts['Alliance'] .. OnyxiaMsg, WBT_Config.report_to, nil, nil)
                SendChatMessage(WBT_Options.Consts['Alliance'] .. NefarianMsg, WBT_Config.report_to, nil, nil)
            end
        elseif arg1 == "RightButton" then
            text = WBT_Options.Consts['Alliance'] .. OnyxiaMsg .. NefarianMsg
        end
    end

    if WBT_Config["allow_horde_report"] then -- 报告部落
        OnyxiaMsg = WBT_Handler:GetReportMsg('Horde_Onyxia')
        NefarianMsg = WBT_Handler:GetReportMsg('Horde_Nefarian')

        if arg1 == "LeftButton" then
            if WBT_Config["allow_merge_report"] then -- 同阵营单行报告
                SendChatMessage(WBT_Options.Consts['Horde'] .. OnyxiaMsg .. NefarianMsg, WBT_Config.report_to, nil, nil)
            else
                SendChatMessage(WBT_Options.Consts['Horde'] .. OnyxiaMsg, WBT_Config.report_to, nil, nil)
                SendChatMessage(WBT_Options.Consts['Horde'] .. NefarianMsg, WBT_Config.report_to, nil, nil)
            end
        elseif arg1 == "RightButton" then
            if text ~= "" then text = text .. "     " end
            text = text .. WBT_Options.Consts['Horde'] .. OnyxiaMsg .. NefarianMsg
        end
    end

    if arg1 == "RightButton" then
        SendChatMessage(text, "CHANNEL", nil, GetChannelName("World"))
    end
end

function WorldBuffsTrackerItemFrame_CheckButton_OnClick(item_key)
    if this:GetChecked() then
        WBT_Handler.Set_Config("concern", item_key);
        WBT_Handler.Run_MainStatus_Timer(item_key);
        for k, _ in pairs(WBT_Timer_Data) do
            if k ~= item_key then
                getglobal('WorldBuffsTrackerItemFrame_Check_' .. k):SetChecked(false)
            end
        end
        -- **************新增 ↓ ↓ ↓ by 夜晨***************
        if item_key ~= "Priority_display" then
            getglobal('WorldBuffsTrackerItemFrame_Check_Priority_display'):SetChecked(false)
        end
        -- **************新增 ↑ ↑ ↑ ***************
    else
        this:SetChecked(true)
    end
end

function WorldBuffsTrackerConfig_ReportTo_OnLoad()
    UIDropDownMenu_Initialize(this, WBT_Handler.Set_ReportToItems);

    for i, o in ipairs(ReportTo_List) do
        if WBT_Config.report_to == o[1] then
            UIDropDownMenu_SetSelectedName(this, o[2]);
            UIDropDownMenu_SetSelectedID(WorldBuffsTrackerConfigFrame_ReportTo, i);
        end
    end
    UIDropDownMenu_SetWidth(60);
    UIDropDownMenu_SetButtonWidth(24);
end

function WorldBuffsTrackerConfig_ReportTo_OnClick()
    UIDropDownMenu_SetSelectedID(WorldBuffsTrackerConfigFrame_ReportTo, this:GetID());

    for i, o in ipairs(ReportTo_List) do
        if o[2] == this:GetText() then
            WBT_Handler.Set_Config('report_to', o[1])
        end
    end
end

function WorldBuffsTrackerConfig_SoundAlliance_OnLoad()
    UIDropDownMenu_Initialize(this, WBT_Handler.Set_SoundAllianceItems);

    for i, o in ipairs(WBT_Sounds) do
        if WBT_Config.alarm_sound_Alliance == o[1] then
            UIDropDownMenu_SetSelectedName(this, o[2]);
            UIDropDownMenu_SetSelectedID(WorldBuffsTrackerConfigFrame_SoundAlliance_List, i);
        end
    end
    UIDropDownMenu_SetWidth(120);
    UIDropDownMenu_SetButtonWidth(24);
end

function WorldBuffsTrackerConfig_SoundAlliance_OnClick()
    UIDropDownMenu_SetSelectedID(WorldBuffsTrackerConfigFrame_SoundAlliance_List, this:GetID());

    for i, o in ipairs(WBT_Sounds) do
        if o[2] == this:GetText() then
            WBT_Handler.Set_Config('alarm_sound_Alliance', o[1])
        end
    end
end

function WorldBuffsTrackerConfig_SoundHorde_OnLoad()
    UIDropDownMenu_Initialize(this, WBT_Handler.Set_SoundHordeItems);

    for i, o in ipairs(WBT_Sounds) do
        if WBT_Config.alarm_sound_Horde == o[1] then
            UIDropDownMenu_SetSelectedName(this, o[2]);
            UIDropDownMenu_SetSelectedID(WorldBuffsTrackerConfigFrame_SoundHorde_List, i);
        end
    end
    UIDropDownMenu_SetWidth(120);
    UIDropDownMenu_SetButtonWidth(24);
end

function WorldBuffsTrackerConfig_SoundHorde_OnClick()
    UIDropDownMenu_SetSelectedID(WorldBuffsTrackerConfigFrame_SoundHorde_List, this:GetID());

    for i, o in ipairs(WBT_Sounds) do
        if o[2] == this:GetText() then
            WBT_Handler.Set_Config('alarm_sound_Horde', o[1])
        end
    end
end

function WorldBuffsTracker_PlaySound_OnClick(f)
    PlaySoundFile(WBT_Options.Sounds[WBT_Config['alarm_sound_' .. f]])
end

--[[main frame and child frames 事件结束]]


--[[
    以下是小地图按钮拖动代码
    感谢有 Atlas 插件
    我直接抄了，很多数值我懒得搞，直接拿过来写死了
]]
function WorldBuffsTrackerMiniBtn_BeingDragged()
    local xpos, ypos = GetCursorPosition()
    local xmin, ymin = Minimap:GetLeft(), Minimap:GetBottom()

    xpos = xmin - xpos / UIParent:GetScale() + 70
    ypos = ypos / UIParent:GetScale() - ymin - 70

    WorldBuffsTrackerMiniBtn_SetPosition(math.deg(math.atan2(ypos, xpos)));
end

function WorldBuffsTrackerMiniBtn_SetPosition(v)
    if (v < 0) then
        v = v + 360;
    end

    WBT_Handler.Set_Config("mini_btn_position", v);
    WorldBuffsTrackerMiniBtn_UpdatePosition();
end

function WorldBuffsTrackerMiniBtn_UpdatePosition()
    WorldBuffsTrackerMiniBtnFrame:SetPoint(
        "TOPLEFT",
        "Minimap",
        "TOPLEFT",
        54 - (78 * cos(WBT_Config.mini_btn_position)),
        (78 * sin(WBT_Config.mini_btn_position)) - 55
    );
end

--新的split
function split(str, separator)
    local str = tostring(str)
    local separator = tostring(separator)
    local strB, arrayIndex = 1, 1
    local targetArray = {}
    if (separator == nil)
    then
        return false
    end
    local condition = true
    while (condition)
    do
        si, sd = string.find(str, separator, strB)
        if (si)
        then
            targetArray[arrayIndex] = string.sub(str, strB, si - 1)
            arrayIndex = arrayIndex + 1
            strB = sd + 1
        else
            targetArray[arrayIndex] = string.sub(str, strB, string.len(str))
            condition = false
        end
    end
    return targetArray
end
