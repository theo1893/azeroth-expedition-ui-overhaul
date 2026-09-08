local WBT_Darkmoon = {}
WBT_Darkmoon.Static = {
    DarkmoonIcon = 'Interface\\Icons\\INV_Misc_Ticket_Darkmoon_01',
    Open = "正在营业",
    Close = "即将到来",
    Vacation = "正在休假",
    Elwynn_Pos = {-80,-170},
    Mulgore_Pos = {-130,60}
}
WBT_Darkmoon.BaseData = {
    Init_Value = time({year=2023,month=12, day=31, hour=8}), --马戏团初始设定值，以此为参考，7天轮换
    Buff_Option = {
        {'伤害','+10%','[1-1]','[___]','DPS'},
        {'全抗','+25_','[1-2]','[2-3]','T'},
        {'护甲','+10%','[1-3]','[4-3]','T'},
        {'精神','+10%','[2-1]','[4-2]','治疗'},
        {'智力','+10%','[2-2]','[4-1]','法系'},
        {'耐力','+10%','[3-1]','[___]','全职业'},
        {'力量','+10%','[3-2]','[___]','近战'},
        {'敏捷','+10%','[3-3]','[___]','物理'}
    }
}  

WBT_Darkmoon.Buttons = {}

WBT_Darkmoon.ShowBtns = function()
    --DEFAULT_CHAT_FRAME:AddMessage(getn(WBT_Darkmoon.Buttons))

    local map = GetMapInfo();
    for _,b in next, WBT_Darkmoon.Buttons do
        b:Hide();
    end

    if map == "Elwynn" or map == "Mulgore" then 
        WBT_Darkmoon.Buttons[map] = WBT_Darkmoon.Buttons[map] or WBT_Darkmoon.CreateButton(map, WBT_Darkmoon.Static[map.."_Pos"][1], WBT_Darkmoon.Static[map.."_Pos"][2], WBT_Darkmoon.Static.DarkmoonIcon);
        WBT_Darkmoon.Update_ButtonText(map);
        if not WBT_Darkmoon.Buttons[map]:IsShown() then 
            WBT_Darkmoon.Buttons[map]:Show();
        end
    end  
end

WBT_Darkmoon.CreateButton = function(map, x, y, texture)
    local btn = CreateFrame("Button","WBT_Button_"..map,WorldMapFrame)        
    SetSize(btn, 30, 30)
    btn:SetFont(STANDARD_TEXT_FONT, 12)
    btn:SetPoint("Center", WorldMapFrame, "Center", x, y)
    btn:SetFrameLevel(255);  
    btn:SetScript("OnEnter", function() 
        WBT_Darkmoon.Show_DarkmoonDetails(btn)
    end)
    btn:SetScript('OnLeave', function() WorldBuffsTrackerTooltip:Hide() end)
    local btn_texture = btn:CreateTexture(nil, "ARTWORK")
    btn_texture:SetTexture(texture)    
    btn_texture:SetAllPoints();

    return btn
end

WBT_Darkmoon.Update_ButtonText = function(map)
    local text = nil;
    local mValue = map == "Elwynn" and 0 or 1; --以7天（一周）计算，能被整除则在艾尔文，否则在莫高雷
    local diff_time = time() - WBT_Darkmoon.BaseData.Init_Value;
    --取weekday 来计算， 周三 8点到周四8点是休息日
    local week_day_value = tonumber(date('%w',time()))
    local hour_value = tonumber(date('%H', time()))
    --计算位置
    if math.fmod(math.floor(diff_time/604800),2) == mValue then
        text = (7 - week_day_value) .. "天\n";            
        if (week_day_value == 3 and hour_value >=8) or (week_day_value == 4 and hour_value < 8) then
            text = text .. WBT_Darkmoon.Static.Vacation
        else
            text = text .. WBT_Darkmoon.Static.Open
        end
    else
        text = (week_day_value - 7) .. "天\n" .. WBT_Darkmoon.Static.Close
    end
    
    if WBT_Darkmoon.Buttons[map] then 
        WBT_Darkmoon.Buttons[map]:SetText(text);
    end
end

WBT_Darkmoon.Show_DarkmoonDetails = function(button)
    WorldBuffsTrackerTooltip:SetOwner(button,'ANCHOR_RIGHT')
    WorldBuffsTrackerTooltip:ClearLines();
    WorldBuffsTrackerTooltip:AddLine('暗月马戏团buff选项')            
    WorldBuffsTrackerTooltip:AddLine('buff   效果    选项1   选项2   推荐')
    for _,v in ipairs(WBT_Darkmoon.BaseData.Buff_Option) do
        WorldBuffsTrackerTooltip:AddLine(v[1]..' '..v[2]..'    '..v[3]..'     '..v[4]..'    '..v[5])
    end

    WorldBuffsTrackerTooltip:Show()
end

function WorldBuffsTracker_Darkmoon_OnLoad()
    this:RegisterEvent("WORLD_MAP_UPDATE");    
end

function WorldBuffsTracker_Darkmoon_OnEvent(event)
    if event == "WORLD_MAP_UPDATE" then
        WBT_Darkmoon.ShowBtns()
    end
end
