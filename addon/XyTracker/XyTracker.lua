
-- 全局变量定义
-- 快捷键分类标题
BINDING_HEADER_XYTRACKER = "|cffFF0000----许愿团快捷键----|r"
local XyInProgress, NewDKP, IsLeader, NoXyList,curItem,rollEndTime,rollData,isRolling = false
local Xys = 0 -- 单独初始化Xys变量为0，避免nil值错误
local LeaderName = ""  -- 存储许愿权限拥有者名称
DefaultDKP = 4  -- 初始化DefaultDKP变量，避免nil值错误

-- 统一的XyTrackerOptions初始化函数
function InitializeXyTrackerOptions()
    -- 确保XyTrackerOptions表存在
    if not XyTrackerOptions then
        XyTrackerOptions = {}
        -- 重新初始化必要的默认值
        XyTrackerOptions.dkpTime = XyTrackerOptions.dkpTime or 30
        XyTrackerOptions.rollTime = XyTrackerOptions.rollTime or 30
    end
    
    -- 初始化QualityFilters（物品品质筛选设置）
    if not XyTrackerOptions.QualityFilters then
        XyTrackerOptions.QualityFilters = {
            [5] = true,  -- 橙色(传说)
            [4] = true,  -- 紫色(史诗)
            [3] = false, -- 蓝色(精良)
            [2] = false, -- 绿色(优秀)
            [1] = false, -- 白色(普通)
            [0] = false  -- 灰色(粗糙)
        }
    end
    
    -- 初始化宣言设置
    if not XyTrackerOptions.Declaration then
        XyTrackerOptions.Declaration = ""
    end
    
    -- 初始化欢迎文本设置
    if not XyTrackerOptions.CustomStarttext then
        XyTrackerOptions.CustomStarttext = nil  -- 使用默认值
    end
    
    -- 初始化DKP和Roll相关的时间设置
    if not XyTrackerOptions.dkpTime then
        XyTrackerOptions.dkpTime = 30
    else
        -- 确保dkpTime是数字类型
        XyTrackerOptions.dkpTime = tonumber(XyTrackerOptions.dkpTime) or 30
    end
    
    if not XyTrackerOptions.rollTime then
        XyTrackerOptions.rollTime = 30
    else
        -- 确保rollTime是数字类型
        XyTrackerOptions.rollTime = tonumber(XyTrackerOptions.rollTime) or 30
    end
    
    -- 初始化其他设置
    if XyTrackerOptions.AutoAnnounce == nil then
        XyTrackerOptions.AutoAnnounce = false
    end
    
    if XyTrackerOptions.greenModeEnabled == nil then
        XyTrackerOptions.greenModeEnabled = false
    end
    
    if XyTrackerOptions.blueModeEnabled == nil then
        XyTrackerOptions.blueModeEnabled = false
    end
    
    if XyTrackerOptions.purpleModeEnabled == nil then
        XyTrackerOptions.purpleModeEnabled = true  -- 默认紫色开启
    end
    
    if XyTrackerOptions.XyOnlyMode == nil then
        XyTrackerOptions.XyOnlyMode = 0
    end
    
    if XyTrackerOptions.autoMinDkp == nil then
        XyTrackerOptions.autoMinDkp = false
    end
end

-- 统一的物品获取函数
function XYT_GetCurrentLootItem()
    -- 获取当前物品完整链接，检查LootFrame.selectedSlot是否有效
    local item = nil;
    if LootFrame.selectedSlot then
        item = GetLootSlotLink(LootFrame.selectedSlot);
    end
    
    -- 如果没有获取到物品链接，使用带颜色的物品名称作为备选
    if not item and LootFrame.selectedQuality and LootFrame.selectedItemName then
        item = ITEM_QUALITY_COLORS[LootFrame.selectedQuality].hex .. LootFrame.selectedItemName .. FONT_COLOR_CODE_CLOSE;
    end
    
    return item or "未知物品";
end

-- 延迟调用函数
-- 快速出分拍卖快捷键处理函数
function XyTracker_FastAuction()
    -- 优先从XyTrackerOptions获取保存的时间值，然后再尝试从编辑框获取
    local timeInfo = tonumber(XyTrackerOptions.dkpTime) or 
                   (xytDKPTime and xytDKPTime:GetNumber()) or 
                   30
    -- 调用XYTMacro函数进行快速出分拍卖
    XYTMacro("f", timeInfo)
end

-- 快速ROLL点拍卖快捷键处理函数
function XyTracker_FastRoll()
    -- 优先从XyTrackerOptions获取保存的时间值，然后再尝试从编辑框获取
    local timeInfo = tonumber(XyTrackerOptions.rollTime) or 
                   (xytRollTime2 and xytRollTime2:GetNumber()) or 
                   30
    -- 调用XYTMacro函数进行快速ROLL点拍卖
    XYTMacro("r", timeInfo)
end

-- 确保快捷键函数在全局作用域中可用
_G["XyTracker_FastAuction"] = XyTracker_FastAuction
_G["XyTracker_FastRoll"] = XyTracker_FastRoll
_G["XyTracker_Toggle"] = XyTracker_Toggle

-- 切换XyTracker窗口显示状态的函数
function XyTracker_Toggle()
    if getglobal("XyTrackerFrame") then
        if getglobal("XyTrackerFrame"):IsVisible() then
            getglobal("XyTrackerFrame"):Hide()
        else
            getglobal("XyTrackerFrame"):Show()
        end
    end
end

function XyTracker_DelayCall(func, delay)
    local frame = CreateFrame("Frame")
    frame:Hide()
    frame:SetScript("OnUpdate", function()
        delay = delay - arg1
        if delay <= 0 then
            frame:SetScript("OnUpdate", nil)
            frame:Hide()
            func()
        end
    end)
    frame:Show()
end

-- 出分拍卖相关变量
XYT_Auction_IsActive = false; -- 是否正在进行出分拍卖
XYT_Auction_Item = ""; -- 当前拍卖物品
XYT_Auction_EndTime = 0; -- 拍卖结束时间
XYT_Auction_Scores = {}; -- 玩家出分记录 {玩家名 = 分数}
XYT_Auction_History = {}; -- 出分历史记录，最多5条

-- ROLL点监控相关变量
XYT_Roll_Scores = {};
XYT_Roll_Wishes = {};
XYT_IsRecordingRoll = false;

-- DKP出分记录相关变量
XYT_DKP_Scores = {}; -- DKP出分记录 {玩家名 = 分数}
XYT_DKP_Wishes = {}; -- DKP许愿记录 {玩家名 = 许愿内容}
XYT_IsRecordingDKP = false; -- 是否正在记录DKP出分

-- 出分拍卖相关函数
function XYT_StartAuction(item, duration)
    if XYT_Auction_IsActive then
        DEFAULT_CHAT_FRAME:AddMessage("重新开始出分拍卖");
    end
    
    -- 清除之前的分数数据，开始新拍卖
    XYT_Auction_Scores = {};
    -- 重置扣分标记
    XYT_HasDeductedScore = false;
    
    -- 清除所有玩家的聊天记录，确保本次拍卖只记录新的发言
    raidMessages = {};
    
    -- 设置拍卖参数
    XYT_Auction_IsActive = true;
    -- 如果没有提供新物品，则使用上一次拍卖的物品
    if item and item ~= "未知物品" then
        XYT_Auction_Item = item;
    elseif XYT_Auction_Item then
        -- 保留上一次拍卖的物品
    else
        XYT_Auction_Item = "未知物品";
    end
    
    -- 确保duration有值，并更新XyTrackerOptions.dkpTime（确保数字类型）
    local actualDuration = tonumber(duration) or tonumber(XyTrackerOptions.dkpTime) or 30;
    -- 确保以数字类型保存到XyTrackerOptions
    XyTrackerOptions.dkpTime = actualDuration;
    
    -- 更新输入框显示当前使用的时间值
    if getglobal("xytDKPTime") then
        getglobal("xytDKPTime"):SetText(tostring(actualDuration));
    end
    
    XYT_Auction_EndTime = time() + actualDuration;
    
    -- 显示拍卖窗口
    XYT_ShowAuctionWindow();
    
    -- 发送团队喊话
    SendChatMessage("开始出分拍卖：" .. XYT_Auction_Item .. "，请出分（0-9分），时间" .. actualDuration .. "秒", "RAID");
    
    -- 启动倒计时
    XYT_StartAuctionTimer();
    
    -- DEFAULT_CHAT_FRAME:AddMessage("出分拍卖已开始：" .. XYT_Auction_Item);
end

-- 显示出分拍卖窗口
function XYT_ShowAuctionWindow()
    -- 更新窗口标题
    getglobal("DKPMonitorFrameTitle"):SetText("出分拍卖监控：" .. XYT_Auction_Item);
    
    -- 显示窗口
    getglobal("DKPMonitorFrame"):Show();
    
    -- 更新显示
    XYT_UpdateAuctionDisplay();
end


function XYT_UpdateAuctionDisplay()
    if not XYT_Auction_IsActive then
        getglobal("DKPMonitorFrameTimerText"):SetText("拍卖已结束");
        getglobal("DKPMonitorFrameText"):SetText("");
        
        -- 拍卖结束后仍然显示分数数据，不隐藏按钮
        -- 显示最后的出分结果
        local sortedScores = {};
        
        -- 对分数进行排序
        for name, score in pairs(XYT_Auction_Scores) do
            table.insert(sortedScores, {name = name, score = score});
        end
        table.sort(sortedScores, function(a, b) return a.score > b.score end);
        
        -- 显示前5名
        for i = 1, 15 do
            local button = getglobal("DKPFrameListButton" .. i);
            if button then
                if i <= table.getn(sortedScores) then
                    local entry = sortedScores[i];
                    local playerInfo = getXyInfo(entry.name);
                    local class = playerInfo and playerInfo["class"] or "未知";
                    local wish = playerInfo and playerInfo["xy"] or "---未许愿---";
                    local dkp = playerInfo and playerInfo["dkp"] or DefaultDKP;
                    
                    -- 设置表单显示格式：2-名字带职业染色[剩余分数] 许愿：【物品链接】
                    local displayText = i .. "-" .. entry.name;
                    
                    -- 根据职业设置颜色
                    local color = "|cFFFFFFFF"; -- 默认白色
                    if class == "战士" then color = "|cFFC79C6E";
                    elseif class == "圣骑士" then color = "|cFFF58CBA";
                    elseif class == "猎人" then color = "|cFFABD473";
                    elseif class == "盗贼" then color = "|cFFFFF569";
                    elseif class == "牧师" then color = "|cFFFFFFFF";
                    elseif class == "死亡骑士" then color = "|cFFC41F3B";
                    elseif class == "萨满祭司" then color = "|cFF0070DE";
                    elseif class == "法师" then color = "|cFF69CCF0";
                    elseif class == "术士" then color = "|cFF9482C9";
                    elseif class == "德鲁伊" then color = "|cFFFF7D0A";
                    end
                    
                    displayText = color .. entry.name .. "|r";
                    
                    -- 将职业信息并入许愿列
                    local wishWithClass = wish;
                    
                    -- 设置表单显示
                getglobal(button:GetName() .. "Name"):SetText(displayText);
                getglobal(button:GetName() .. "Wish"):SetText(wishWithClass);
                getglobal(button:GetName() .. "Score"):SetText(dkp);  -- 分数列显示DKP值

                if getglobal(button:GetName() .. "Bid") then
                    -- 获取设置的许愿分，默认为2（测试用）
                    local wishScore = XyTrackerOptions and (XyTrackerOptions.WishScore or 2) or 2;
                    local displayScore = entry.score;
                    
                    -- 获取当前拍卖的物品
                    local currentItem = XYT_Auction_Item or "";
                    
                    -- 确保许愿分不大于9且至少为0
                    if wishScore > 9 then
                        wishScore = 9;
                    elseif wishScore < 0 then
                        wishScore = 0;
                    end
                    
                    -- 检查玩家是否许愿了当前拍卖的物品
                    -- 使用与XYT_SetRoll函数相同的方式获取和检查玩家许愿内容
                    local playerWish = XY_GetPlayerWish(entry.name);
                    local isWishCurrentItem = false;
                    
                    -- 添加调试信息
                    -- DEFAULT_CHAT_FRAME:AddMessage("[XYT调试] 玩家:"..entry.name.." 拍卖物品:"..(currentItem or "nil").." 玩家许愿:"..(playerWish or "nil"));
                    
                    -- 确保正确检查玩家是否许愿了当前物品
                    if playerWish and currentItem and currentItem ~= "" and playerWish ~= "" then
                        -- 检查玩家是否已完成许愿，如果是则不视为许愿当前物品
                        if string.find(string.lower(playerWish), "已完成") then
                            isWishCurrentItem = false;
                        else
                            -- 移除方括号并转换为小写进行比较
                            local cleanWish = string.lower(string.gsub(playerWish, "%[%]", ""));
                            local cleanItem = string.lower(string.gsub(currentItem, "%[%]", ""));
                            -- 使用三种匹配方式：完全相等、许愿包含物品、物品包含许愿
                            isWishCurrentItem = (cleanWish == cleanItem) or 
                                              (string.find(cleanWish, cleanItem) ~= nil) or 
                                              (string.find(cleanItem, cleanWish) ~= nil);
                        end
                        -- DEFAULT_CHAT_FRAME:AddMessage("[XYT调试] 玩家:"..entry.name.." 匹配结果:"..(isWishCurrentItem and "是" or "否"));
                    end
                    

                    
                    -- 当许愿分设置为0时，如果玩家许愿了当前物品，显示"已许愿"，否则显示原始分数
                    if wishScore == 0 then
                        if isWishCurrentItem then
                            displayScore = "已许愿";
                        else
                            displayScore = entry.score;
                        end
                    -- 当许愿分设置为1-9时，只有许愿了当前物品的玩家才显示加分格式
                    elseif wishScore >= 1 and wishScore <= 9 and isWishCurrentItem then
                        local actualDeduct = math.max(0, entry.score - wishScore);
                        displayScore = actualDeduct .. "+" .. wishScore;
                    else
                        -- 当玩家没有许愿当前物品时，直接显示原始分数值
                        displayScore = entry.score;
                    end
                    
                    getglobal(button:GetName() .. "Bid"):SetText(displayScore);  -- 出分列显示格式化的分数
                end
                button:Show();
                else
                    -- 清空未使用的行
                getglobal(button:GetName() .. "Score"):SetText("");
                getglobal(button:GetName() .. "Name"):SetText("");
                getglobal(button:GetName() .. "Wish"):SetText("");

                if getglobal(button:GetName() .. "Bid") then
                    getglobal(button:GetName() .. "Bid"):SetText("");
                end
                button:Hide();
                end
            end
        end
        return;
    end
    
    -- 更新倒计时
    local remainingTime = XYT_Auction_EndTime - time();
    if remainingTime > 0 then
        getglobal("DKPMonitorFrameTimerText"):SetText("时间: " .. remainingTime .. "秒");
    else
        getglobal("DKPMonitorFrameTimerText"):SetText("时间到");
    end
    
    -- 更新出分列表
    local sortedScores = {};
    
    -- 对分数进行排序
    for name, score in pairs(XYT_Auction_Scores) do
        table.insert(sortedScores, {name = name, score = score});
    end
    table.sort(sortedScores, function(a, b) return a.score > b.score end);
    
    -- 显示前5名
    for i = 1, 5 do
        local button = getglobal("DKPFrameListButton" .. i);
        if button then
            if i <= table.getn(sortedScores) then
                local entry = sortedScores[i];
                local playerInfo = getXyInfo(entry.name);
                local class = playerInfo and playerInfo["class"] or "未知";
                local wish = playerInfo and playerInfo["xy"] or "---未许愿---";
                local dkp = playerInfo and playerInfo["dkp"] or DefaultDKP;
                
                -- 设置表单显示格式：2-名字带职业染色[剩余分数] 许愿：【物品链接】
                local displayText = i .. "-" .. entry.name;
                
                -- 根据职业设置颜色
                local color = "|cFFFFFFFF"; -- 默认白色
                if class == "战士" then color = "|cFFC79C6E";
                elseif class == "圣骑士" then color = "|cFFF58CBA";
                elseif class == "猎人" then color = "|cFFABD473";
                elseif class == "盗贼" then color = "|cFFFFF569";
                elseif class == "牧师" then color = "|cFFFFFFFF";
                elseif class == "死亡骑士" then color = "|cFFC41F3B";
                elseif class == "萨满祭司" then color = "|cFF0070DE";
                elseif class == "法师" then color = "|cFF69CCF0";
                elseif class == "术士" then color = "|cFF9482C9";
                elseif class == "德鲁伊" then color = "|cFFFF7D0A";
                end
                
                displayText = color .. entry.name .. "|r";
                
                -- 将职业信息并入许愿列
                local wishWithClass = wish;
                
                -- 设置表单显示
                getglobal(button:GetName() .. "Name"):SetText(displayText);
                getglobal(button:GetName() .. "Wish"):SetText(wishWithClass);
                getglobal(button:GetName() .. "Score"):SetText(dkp);  -- 分数列显示DKP值

                if getglobal(button:GetName() .. "Bid") then
                    -- 获取设置的许愿分，默认为2（测试用）
                    local wishScore = XyTrackerOptions and (XyTrackerOptions.WishScore or 2) or 2;
                    local displayScore = entry.score;
                    
                    -- 获取当前拍卖的物品
                    local currentItem = XYT_Auction_Item or "";
                    
                    -- 确保许愿分不大于9且至少为0
                    if wishScore > 9 then
                        wishScore = 9;
                    elseif wishScore < 0 then
                        wishScore = 0;
                    end
                    
                    -- 检查玩家是否许愿了当前拍卖的物品
                    -- 使用与XYT_SetRoll函数相同的方式获取和检查玩家许愿内容
                    local playerWish = XY_GetPlayerWish(entry.name);
                    local isWishCurrentItem = false;
                    
                    -- 添加调试信息
                    -- DEFAULT_CHAT_FRAME:AddMessage("[XYT调试] 玩家:"..entry.name.." 拍卖物品:"..(currentItem or "nil").." 玩家许愿:"..(playerWish or "nil"));
                    
                    -- 确保正确检查玩家是否许愿了当前物品
                    if playerWish and currentItem and currentItem ~= "" and playerWish ~= "" then
                        -- 检查玩家是否已完成许愿，如果是则不视为许愿当前物品
                        if string.find(string.lower(playerWish), "已完成") then
                            isWishCurrentItem = false;
                        else
                            -- 移除方括号并转换为小写进行比较
                            local cleanWish = string.lower(string.gsub(playerWish, "%[%]", ""));
                            local cleanItem = string.lower(string.gsub(currentItem, "%[%]", ""));
                            -- 使用三种匹配方式：完全相等、许愿包含物品、物品包含许愿
                            isWishCurrentItem = (cleanWish == cleanItem) or 
                                              (string.find(cleanWish, cleanItem) ~= nil) or 
                                              (string.find(cleanItem, cleanWish) ~= nil);
                        end
                        -- DEFAULT_CHAT_FRAME:AddMessage("[XYT调试] 玩家:"..entry.name.." 匹配结果:"..(isWishCurrentItem and "是" or "否"));
                    end
                    

                    
                    -- 当许愿分设置为0时，如果玩家许愿了当前物品，显示"已许愿"，否则显示原始分数
                    if wishScore == 0 then
                        if isWishCurrentItem then
                            displayScore = "已许愿";
                        else
                            displayScore = entry.score;
                        end
                    -- 当许愿分设置为1-9时，只有许愿了当前物品的玩家才显示加分格式
                    elseif wishScore >= 1 and wishScore <= 9 and isWishCurrentItem then
                        local actualDeduct = math.max(0, entry.score - wishScore);
                        displayScore = actualDeduct .. "+" .. wishScore;
                    else
                        -- 当玩家没有许愿当前物品时，直接显示原始分数值
                        displayScore = entry.score;
                    end
                    
                    getglobal(button:GetName() .. "Bid"):SetText(displayScore);  -- 出分列显示格式化的分数
                end
                button:Show();
            else
                -- 清空未使用的行
                getglobal(button:GetName() .. "Score"):SetText("");
                getglobal(button:GetName() .. "Name"):SetText("");
                getglobal(button:GetName() .. "Wish"):SetText("");

                if getglobal(button:GetName() .. "Bid") then
                    getglobal(button:GetName() .. "Bid"):SetText("");
                end
                button:Hide();
            end
        end
    end
    
    -- 删除文本显示，只保留表单显示
    getglobal("DKPMonitorFrameText"):SetText("");
end

-- 启动出分拍卖倒计时
function XYT_StartAuctionTimer()
    if XYT_Auction_IsActive then
        local remainingTime = XYT_Auction_EndTime - time();
        if remainingTime > 0 then
            -- 1秒后再次更新
            XyTracker_DelayCall(XYT_StartAuctionTimer, 1);
        else
            -- 时间到了，自动结束拍卖
            XYT_EndAuction();
        end
        XYT_UpdateAuctionDisplay();
    end
end

-- 结束出分拍卖
function XYT_EndAuction()
    if not XYT_Auction_IsActive then
        -- DEFAULT_CHAT_FRAME:AddMessage("没有进行中的出分拍卖");
        return;
    end
    
    -- 停止拍卖但不清除分数数据和物品信息
    XYT_Auction_IsActive = false;
    
    -- 重置扣分标记
    XYT_HasDeductedScore = false;
    
    -- 准备结果消息
    local resultMsg = "出分拍卖结束，物品：" .. XYT_Auction_Item .. "，";
    
    -- 检查是否有玩家出分
    if next(XYT_Auction_Scores) then
        -- 对分数进行排序
        local sortedScores = {};
        for name, score in pairs(XYT_Auction_Scores) do
            table.insert(sortedScores, {name = name, score = score});
        end
        table.sort(sortedScores, function(a, b) return a.score > b.score end);
        
        -- 找出最高分
        local highestScore = sortedScores[1].score;
        
        -- 找出所有最高分的玩家
        local winners = {};
        for _, entry in ipairs(sortedScores) do
            if entry.score == highestScore then
                table.insert(winners, entry.name);
            end
        end
        
        -- 获取获胜者数量
        local winnerCount = 0;
        for _ in pairs(winners) do winnerCount = winnerCount + 1 end;
        
        -- 构建胜利消息
        if winnerCount == 1 then
            resultMsg = resultMsg .. "胜利者为" .. winners[1] .. "，出分[" .. highestScore .. "]";
        else
            -- 分数并列的情况
            resultMsg = resultMsg .. "最高分并列：";
            local i = 0;
            for _, winner in pairs(winners) do
                i = i + 1;
                resultMsg = resultMsg .. winner .. "[" .. highestScore .. "]";
                if i < winnerCount then
                    resultMsg = resultMsg .. "、";
                end
            end
        end
        
        -- 添加到历史记录
        local historyEntry = {
            item = XYT_Auction_Item,
            winner = winners[1] or "无人",
            score = highestScore,
            time = date("%H:%M:%S")
        };
        table.insert(XYT_Auction_History, 1, historyEntry);
        
        -- 保持最多5条历史记录
        if table.getn(XYT_Auction_History) > 5 then
            table.remove(XYT_Auction_History, 6);
        end
        
        -- 移除自动扣分逻辑，改为手动扣分
        -- 保持历史记录和结果消息不变
    else
        resultMsg = resultMsg .. "无人出分";
    end
    
    -- 发送团队消息
    SendChatMessage(resultMsg, "RAID");
    
    -- 更新显示
    XYT_UpdateAuctionDisplay();
    
    -- 不隐藏窗口，保持显示状态
    -- DKPMonitorFrame:Show();
    
    -- DEFAULT_CHAT_FRAME:AddMessage("出分拍卖已结束，数据已保留");
end

-- 手动扣除玩家分数函数
-- 添加扣分记录标记，防止重复扣分
XYT_HasDeductedScore = false;

function XYT_DeductPlayerScore(playerName, bidScore)
    -- 移除全局扣分标记检查，允许为多个玩家扣分
    -- 但仍需保留其他有效性检查
    
    if not playerName then
        DEFAULT_CHAT_FRAME:AddMessage("无效的玩家名称");
        return;
    end
    if bidScore == nil then
        DEFAULT_CHAT_FRAME:AddMessage("无效的分数");
        return;
    end
    
    -- 检查XyArray是否存在
    if not XyArray then
        DEFAULT_CHAT_FRAME:AddMessage("玩家数据未初始化");
        return;
    end
    
    -- 查找玩家信息
    local found = false
    for i = 1, table.getn(XyArray) do
        local info = XyArray[i];
        if info["name"] == playerName then
            found = true
            
            -- 获取设置的许愿分，默认为0
            local wishScore = XyTrackerOptions and XyTrackerOptions.WishScore or 0;
            
            -- 确保许愿分不大于9
            if wishScore > 9 then
                wishScore = 9;
            end
            
            -- 检查玩家许愿是否已完成
            local isWishCompleted = info["xy"] and string.find(string.lower(info["xy"]), "已完成");
            
            -- 检查玩家是否真的许愿了当前物品
            local isWishCurrentItem = false;
            if info["xy"] and XYT_Auction_Item and not isWishCompleted and info["xy"] ~= "---未许愿---" then
                -- 移除方括号并转换为小写进行比较
                local cleanWish = string.lower(string.gsub(info["xy"], "%[%]", ""));
                local cleanItem = string.lower(string.gsub(XYT_Auction_Item, "%[%]", ""));
                -- 使用三种匹配方式：完全相等、许愿包含物品、物品包含许愿
                isWishCurrentItem = (cleanWish == cleanItem) or 
                                  (string.find(cleanWish, cleanItem) ~= nil) or 
                                  (string.find(cleanItem, cleanWish) ~= nil);
            end
            
            -- 处理不同分数情况的扣分逻辑
            if bidScore == 0 then
                -- 0分情况：可能是许愿玩家的特殊处理
                if isWishCurrentItem and not isWishCompleted then
                    -- 标记物品为已完成
                    info["xy"] = MarkItemAsCompleted(info["xy"], XYT_Auction_Item);
                    SendChatMessage(playerName .. " 已完成当前物品许愿（出0分），扣除0分，当前剩余分数：[" .. info["dkp"] .. "]", "RAID");
                else
                    -- 非许愿玩家0分
                    SendChatMessage(playerName .. " 出0分，无需扣分，当前剩余分数：[" .. info["dkp"] .. "]", "RAID");
                end
            elseif bidScore == 5 then
                -- 5分情况：不扣分，但标记物品为已完成（如果有许愿）
                if info["xy"] and info["xy"] ~= "---未许愿---" then
                    info["xy"] = MarkItemAsCompleted(info["xy"], XYT_Auction_Item);
                    SendChatMessage(playerName .. " 已完成当前物品许愿（出" .. bidScore .. "分），当前剩余分数：[" .. info["dkp"] .. "]", "RAID");
                else
                    SendChatMessage(playerName .. " 出" .. bidScore .. "分，当前剩余分数：[" .. info["dkp"] .. "]", "RAID");
                end
            else
                -- 标记物品为已完成（如果有许愿且未完成且匹配当前物品）
                if isWishCurrentItem and not isWishCompleted then
                    info["xy"] = MarkItemAsCompleted(info["xy"], XYT_Auction_Item);
                end
                
                -- 根据许愿分设置计算实际扣除分数
                if isWishCompleted then
                    -- 已完成许愿的玩家，正常扣除出分数值
                    info["dkp"] = tonumber(info["dkp"]) - bidScore;
                    SendChatMessage(playerName .. " 出" .. bidScore .. "分，扣除" .. bidScore .. "分，当前剩余分数：[" .. info["dkp"] .. "]", "RAID");
                elseif not isWishCurrentItem then
                    -- 不是许愿当前物品的玩家，正常扣除出分数值
                    info["dkp"] = tonumber(info["dkp"]) - bidScore;
                    SendChatMessage(playerName .. " 出" .. bidScore .. "分，扣除" .. bidScore .. "分，当前剩余分数：[" .. info["dkp"] .. "]", "RAID");
                elseif wishScore == 0 then
                    -- 当许愿分设置为0时，扣0分
                    SendChatMessage(playerName .. " 已完成当前物品许愿（许愿分0），扣除0分，当前剩余分数：[" .. info["dkp"] .. "]", "RAID");
                elseif wishScore >= 1 and wishScore <= 9 then
                    -- 当许愿分设置为1-9时，扣除分数为出分减去许愿分
                    local deductPoints = math.max(0, bidScore - wishScore);
                    info["dkp"] = tonumber(info["dkp"]) - deductPoints;
                    SendChatMessage(playerName .. " 已完成当前物品许愿，并扣除" .. deductPoints .. "分（出" .. bidScore .. "分-" .. wishScore .. "分许愿分），当前剩余分数：[" .. info["dkp"] .. "]", "RAID");
                end
            end
            
            -- 更新列表和同步数据
            XyTracker_UpdateList();
            syncXy();
            break;
        end
    end
    
    if not found then
        DEFAULT_CHAT_FRAME:AddMessage("未找到玩家 " .. playerName .. " 的信息");
    else

        -- 移除立即停止拍卖的设置，允许为多个玩家依次扣分
        -- XYT_Auction_IsActive = false;
        
        -- 结束ROLL点拍卖计时
        XYT_Roll_EndTime = nil;
        
        -- 发送拍卖结束消息
        SendChatMessage("出分拍卖已手动结束", "RAID");
    end
end

-- 处理团队聊天中的出分消息
function XYT_ProcessAuctionMessage(message, player)
    if not XYT_Auction_IsActive then
        return false;
    end
    
    -- 检查消息是否为0-9的数字
    local score = tonumber(message);
    if score and score >= 0 and score <= 9 then
        -- 记录玩家出分（只记录最高分）
        if not XYT_Auction_Scores[player] or score > XYT_Auction_Scores[player] then
            XYT_Auction_Scores[player] = score;
            
            -- 更新显示
            XYT_UpdateAuctionDisplay();
            
            -- 在聊天框显示出分信息
            -- DEFAULT_CHAT_FRAME:AddMessage(player .. " 出分：" .. score);
            
            return true;
        end
    end
    
    return false;
end

-- 清除出分拍卖数据（重新开始拍卖时调用）
function XYT_ClearAuction()
    XYT_Auction_IsActive = false;
    XYT_Auction_Item = nil;
    XYT_Auction_EndTime = nil;
    XYT_Auction_Scores = {};
    XYT_Auction_History = {};
    
    -- 更新显示
    XYT_UpdateAuctionDisplay();
    
    DEFAULT_CHAT_FRAME:AddMessage("出分拍卖数据已清除");
end

-- ROLL点监控操作按钮事件处理
function RollStart(item, time)
	if XYT_IsRecordingRoll then
		DEFAULT_CHAT_FRAME:AddMessage("ROLL点监控已经在进行中");
		return;
	end
	
	-- 清除之前的ROLL点数据，开始新监控
	XYT_Roll_Scores = {};
	XYT_Roll_Wishes = {};
	-- 重置扣分标记
	XYT_HasDeductedScore = false;
	
	-- 修复：从XyArray预先填充许愿内容，确保数据正确初始化
	local totalMembers = GetNumRaidMembers();
	if totalMembers and type(totalMembers) == "number" then
		for i = 1, totalMembers do
			local name = GetRaidRosterInfo(i);
			if name and type(name) == "string" then
				local playerInfo = getXyInfo(name);
				if playerInfo and playerInfo["xy"] and type(playerInfo["xy"]) == "string" and playerInfo["xy"] ~= "" and playerInfo["xy"] ~= "---未许愿---" then
					XYT_Roll_Wishes[name] = playerInfo["xy"];
				end
			end
		end
	end
	
	-- 设置ROLL点监控参数
	XYT_IsRecordingRoll = true;
	XYT_CurrentItem = item or "未知物品";
	XYT_Roll_EndTime = GetTime() + (time or 30); -- 默认30秒
	
	-- 显示ROLL点监控窗口
	getglobal("RollMonitorFrameTitle"):SetText("ROLL点监控：" .. XYT_CurrentItem);
	getglobal("RollMonitorFrame"):Show();
	
	-- 发送团队喊话
	SendChatMessage("开始ROLL点拍卖：" .. XYT_CurrentItem .. "，请ROLL点，时间" .. (time or 30) .. "秒", "RAID");
	
	-- 启动倒计时
	XYT_StartRollTimer();
	
	-- DEFAULT_CHAT_FRAME:AddMessage("ROLL点拍卖已开始：" .. XYT_CurrentItem);
end

function RollEnd()
	if not XYT_IsRecordingRoll then
		DEFAULT_CHAT_FRAME:AddMessage("没有进行中的ROLL点监控");
		return;
	end
	
	-- 停止记录
	XYT_IsRecordingRoll = false;

	-- 发送团队消息
	SendChatMessage("ROLL点拍卖结束", "RAID");
end

-- 启动ROLL点倒计时
function XYT_StartRollTimer()
    if XYT_IsRecordingRoll then
        -- 检查XYT_Roll_EndTime是否为nil
        if not XYT_Roll_EndTime then
            -- 如果没有设置结束时间，使用保存的rollTime设置，默认30秒
            local timeValue = tonumber(XyTrackerOptions.rollTime) or 30;
            XYT_Roll_EndTime = GetTime() + timeValue;
        end
        
        local remainingTime = XYT_Roll_EndTime - GetTime();
        if remainingTime > 0 then
            -- 1秒后再次更新
            XyTracker_DelayCall(XYT_StartRollTimer, 1);
        else
            -- 时间到了，自动结束ROLL点监控
            XYT_EndRoll();
        end
        XYT_UpdateRollDisplay();
    end
end

-- 结束ROLL点监控
function XYT_EndRoll()
    if not XYT_IsRecordingRoll then
        DEFAULT_CHAT_FRAME:AddMessage("没有进行中的ROLL点监控");
        return;
    end
    
    -- 停止监控但不清除ROLL点数据
    XYT_IsRecordingRoll = false;
    
    -- 重置ROLL点结束时间
    XYT_Roll_EndTime = nil;
    
    -- 重置扣分标记
    XYT_HasDeductedScore = false;
    
    -- 恢复xytRollTime显示为原始设定值，而不是0
    local originalTime = XyTrackerOptions.rollTime or 30;
    if getglobal("xytRollTime2") then
        getglobal("xytRollTime2"):SetText(tostring(originalTime));
    end
    
    -- 准备结果消息
    local resultMsg = "ROLL点拍卖结束，物品：" .. (XYT_CurrentItem or "未知物品") .. "，";
    
    -- 检查是否有玩家ROLL点
    if next(XYT_Roll_Scores) then
        -- 对ROLL点进行排序
        local sortedRolls = {};
        for name, roll in pairs(XYT_Roll_Scores) do
            -- 查找是否有原始ROLL点信息（来自CML_Vars.Rolls）
            local baseRoll = roll;
            if CML_Vars and CML_Vars.Rolls then
                for _, rollEntry in ipairs(CML_Vars.Rolls) do
                    if rollEntry.name == name and rollEntry.baseRoll then
                        baseRoll = rollEntry.baseRoll;
                        break;
                    end
                end
            end
            table.insert(sortedRolls, {name = name, roll = roll, baseRoll = baseRoll});
        end
        table.sort(sortedRolls, function(a, b) return a.roll > b.roll end);
        
        -- 找出最高ROLL点
        local highestRoll = sortedRolls[1].roll;
        
        -- 找出所有最高ROLL点的玩家
        local winners = {};
        for _, entry in ipairs(sortedRolls) do
            if entry.roll == highestRoll then
                table.insert(winners, entry.name);
            end
        end
        
        -- 获取获胜者数量
        local winnerCount = 0;
        for _ in pairs(winners) do winnerCount = winnerCount + 1 end;
        
        -- 构建胜利消息
        if winnerCount == 1 then
            -- 单人获胜，获取职业信息和详细ROLL点
            local winnerName = winners[1];
            local winnerInfo = nil;
            -- 从sortedRolls中找到详细信息
            for _, entry in ipairs(sortedRolls) do
                if entry.name == winnerName then
                    winnerInfo = entry;
                    break;
                end
            end
            
            local playerInfo = getXyInfo(winnerName);
            local class = playerInfo and playerInfo["class"] or "未知";
            local classColor = XYT_GetClassColor(class) or "";
            local coloredName = classColor .. winnerName .. "\124r";
            
            -- 检查获胜者是否对当前物品有许愿
            local hasWish = false;
            if XYT_CurrentItem then
                local playerWish = XY_GetPlayerWish(winnerName);
                hasWish = XYT_CheckItemInWish(playerWish, XYT_CurrentItem);
            end
            
            -- 显示详细的ROLL点信息
            local rollText;
            if hasWish and winnerInfo and winnerInfo.baseRoll and winnerInfo.baseRoll ~= winnerInfo.roll then
                local bonus = winnerInfo.roll - winnerInfo.baseRoll;
                rollText = winnerInfo.roll .. "(" .. winnerInfo.baseRoll .. "+" .. bonus .. ")";
            else
                rollText = highestRoll;
            end
            
            resultMsg = resultMsg .. "胜利者为" .. coloredName .. "，ROLL点[" .. rollText .. "]";
        else
            -- ROLL点并列的情况
            resultMsg = resultMsg .. "最高ROLL点并列：";
            local i = 0;
            for _, winnerName in pairs(winners) do
                i = i + 1;
                -- 获取职业信息和颜色
                local playerInfo = getXyInfo(winnerName);
                local class = playerInfo and playerInfo["class"] or "未知";
                local classColor = XYT_GetClassColor(class) or "";
                local coloredName = classColor .. winnerName .. "\124r";
                
                -- 从sortedRolls中找到详细信息
                local winnerInfo = nil;
                for _, entry in ipairs(sortedRolls) do
                    if entry.name == winnerName then
                        winnerInfo = entry;
                        break;
                    end
                end
                
                -- 检查获胜者是否对当前物品有许愿
                local hasWish = false;
                if XYT_CurrentItem then
                    local playerWish = XY_GetPlayerWish(winnerName);
                    hasWish = XYT_CheckItemInWish(playerWish, XYT_CurrentItem);
                end
                
                -- 显示详细的ROLL点信息
                local rollText;
                if hasWish and winnerInfo and winnerInfo.baseRoll and winnerInfo.baseRoll ~= winnerInfo.roll then
                    local bonus = winnerInfo.roll - winnerInfo.baseRoll;
                    rollText = winnerInfo.roll .. "(" .. winnerInfo.baseRoll .. "+" .. bonus .. ")";
                else
                    rollText = highestRoll;
                end
                
                resultMsg = resultMsg .. coloredName .. "[" .. rollText .. "]";
                if i < winnerCount then
                    resultMsg = resultMsg .. "、";
                end
            end
            resultMsg = resultMsg .. "，请重新ROLL点决定归属";
        end
        
        -- 添加统计信息
        local totalPlayers = 0;
        for _ in pairs(XYT_Roll_Scores) do totalPlayers = totalPlayers + 1 end;
        resultMsg = resultMsg .. "（共" .. totalPlayers .. "人参与）";
    else
        resultMsg = resultMsg .. "无人ROLL点";
    end
    
    -- 发送团队消息
    SendChatMessage(resultMsg, "RAID");
    
    -- 更新显示
    XYT_UpdateRollDisplay();
    
    -- 本地确认消息
    -- DEFAULT_CHAT_FRAME:AddMessage("ROLL点拍卖已停止");
end

-- 显示出分拍卖窗口
function XYT_ShowROLLWindow()
    -- 更新窗口标题
    if getglobal("RollMonitorFrameTitle") then
        getglobal("RollMonitorFrameTitle"):SetText("ROLL点监控:" .. (XYT_CurrentItem or "未知物品"));
    end
    if getglobal("RollMonitorFrame") then
        getglobal("RollMonitorFrame"):Show();
    end
    
    -- 更新显示
    XYT_UpdateRollDisplay();
end

    

-- ROLL点监控相关函数
-- 从出分拍卖界面调用的ROLL点监控启动函数
function XYT_StartRollMonitor(itemInfo, timeInfo)
    -- 如果当前有出分拍卖正在进行，可以选择先结束它
    if XYT_Auction_IsActive then
        XYT_EndAuction()
    end
    
    -- 保存当前的出分信息，以便在ROLL点窗口中使用
    XYT_Roll_DKPInfo = {} -- 重置出分信息表
    if XyArray and table.getn(XyArray) > 0 then
        for i = 1, table.getn(XyArray) do
            if XyArray[i] and XyArray[i].name and XyArray[i].bid and XyArray[i].bid > 0 then
                XYT_Roll_DKPInfo[XyArray[i].name] = XyArray[i].bid
            end
        end
    end
    
    -- 调用现有的ROLL点记录函数，传递物品信息和时间信息
    local success = XYT_StartRollRecording(itemInfo, timeInfo)
    
    -- 如果成功启动了ROLL点监控，可以发送系统消息通知
    if success ~= false then
        -- 添加安全检查，确保nil值不会导致字符串连接错误
        -- DEFAULT_CHAT_FRAME:AddMessage("开始ROLL点监控：" .. (itemInfo or "未知物品") .. "，时间" .. (timeInfo or "30") .. "秒")
        -- 如果有出分信息，也进行提示
        if next(XYT_Roll_DKPInfo) then
            DEFAULT_CHAT_FRAME:AddMessage("已同步出分信息到ROLL点监控")
        end
    end
end

function XYT_StartRollRecording(item, duration)
	-- 检查是否有正在进行的ROLL点拍卖
	if XYT_IsRecordingRoll then
		DEFAULT_CHAT_FRAME:AddMessage("ROLL点拍卖已经在进行中");
		-- 确保窗口显示
		if RollMonitorFrame then
			RollMonitorFrame:Show();
		end
		return false;
	end
	
	XYT_Roll_Scores = {};
	XYT_Roll_Wishes = {};
	
	-- 记住上一次ROLL点的物品，如果没有提供新物品，则使用之前的物品
	if item and item ~= "未知物品" and item ~= "" then
		XYT_PreviousRollItem = item; -- 保存当前物品为上一次物品
		XYT_CurrentItem = item;
	elseif XYT_PreviousRollItem then
		-- 如果没有提供新物品但有上一次的物品，则使用上一次的物品
		XYT_CurrentItem = XYT_PreviousRollItem;
		DEFAULT_CHAT_FRAME:AddMessage("继续ROLL点之前的物品：" .. XYT_CurrentItem);
	else
		XYT_CurrentItem = item or "未知物品";
	end
	
	-- 提前确保窗口存在并显示
	if not RollMonitorFrame then
		XyTracker_CreateRollMonitor();
	end
	if RollMonitorFrame then
		RollMonitorFrame:Show();
	end
	
	XYT_IsRecordingRoll = true;
	
	-- 确保duration有值，并更新XyTrackerOptions.rollTime（确保数字类型）
	local actualDuration = tonumber(duration) or tonumber(XyTrackerOptions.rollTime) or 30;
	-- 确保以数字类型保存到XyTrackerOptions
	XyTrackerOptions.rollTime = actualDuration;
	
	-- 更新输入框显示当前使用的时间值
	if getglobal("xytRollTime2") then
		getglobal("xytRollTime2"):SetText(tostring(actualDuration));
	end
	
	XYT_Roll_EndTime = GetTime() + actualDuration;
	
	-- 发送ROLL点拍卖开始的广播消息
	SendChatMessage("开始ROLL点拍卖：" .. XYT_CurrentItem .. "，请ROLL点，时间" .. actualDuration .. "秒", "RAID");
	
	-- 确保RollMonitorFrame有OnUpdate脚本用于动态更新剩余时间
	local rollFrame = getglobal("RollMonitorFrame");
	if rollFrame and not rollFrame:GetScript("OnUpdate") then
		rollFrame:SetScript("OnUpdate", function()
			if XYT_IsRecordingRoll then
				XYT_UpdateRollDisplay();
			end
		end);
	end
	
	-- 更新标题文本，格式：ROLL点监控:物品名 时间:剩余时间
	if getglobal("RollMonitorFrameTitle") then
		-- 计算剩余时间并确保是有效数字
		local timeValue = XYT_Roll_EndTime and (XYT_Roll_EndTime - GetTime()) or 0;
		timeValue = math.max(0, timeValue); -- 确保时间不为负数
		getglobal("RollMonitorFrameTitle"):SetText("ROLL点监控:" .. (item or "未知物品") .. " 时间:" .. math.floor(timeValue) .. "秒");
	end
	
	XYT_UpdateRollDisplay();
end

function XYT_UpdateRollDisplay()
	-- 确保ROLL点监控窗口存在
	if not RollMonitorFrame then
		XyTracker_CreateRollMonitor();
	end
	
	local sortedRolls = {};
	for name, roll in pairs(XYT_Roll_Scores) do
		local playerInfo = getXyInfo(name);
		local class = playerInfo and playerInfo["class"] or "未知";
		-- 修复：确保dkp值转换为数字并处理nil情况
		local dkp = tonumber(playerInfo and playerInfo["dkp"] or DefaultDKP) or 0;
		-- 修复：优先从XyArray获取许愿内容，如果为空则从XYT_Roll_Wishes获取
		local wish = "";
		if playerInfo and playerInfo["xy"] and playerInfo["xy"] ~= "" and playerInfo["xy"] ~= "---未许愿---" then
			wish = playerInfo["xy"];
		elseif XYT_Roll_Wishes and XYT_Roll_Wishes[name] and XYT_Roll_Wishes[name] ~= "" then
			wish = XYT_Roll_Wishes[name];
		end
		-- 确保roll值转换为数字
		local rollValue = tonumber(roll) or 0;
		table.insert(sortedRolls, {name = name, roll = rollValue, class = class, dkp = dkp, wish = wish});
	end
	table.sort(sortedRolls, function(a, b) return a.roll > b.roll end);
	
	-- 更新标题显示剩余时间
	local remainingTimeDisplay = "";
	if XYT_Roll_EndTime then
		local remainingTime = XYT_Roll_EndTime - GetTime();
		if remainingTime > 0 then
			remainingTimeDisplay = "时间:" .. math.floor(remainingTime) .. "秒";
		else
			remainingTimeDisplay = "已结束";
			-- 如果时间到了但还在记录状态，自动结束ROLL点监控
			if XYT_IsRecordingRoll then
				XYT_EndRoll();
				return; -- 避免重复更新
			end
		end
	else
		-- 如果没有ROLL点结束时间，说明是查看历史记录
		if table.getn(sortedRolls) > 0 then
			remainingTimeDisplay = table.getn(sortedRolls) .. "人";
		else
			remainingTimeDisplay = "无记录";
		end
	end
	
	-- 设置标题，格式为"ROLL点监控:物品名 时间:剩余时间"
	getglobal("RollMonitorFrameTitle"):SetText("ROLL点监控:" .. (XYT_CurrentItem or "") .. " " .. remainingTimeDisplay);
	
	-- 更新列表显示
	RollMonitor_UpdateList(sortedRolls);
	-- 移除强制显示窗口的代码，让窗口可以保持关闭状态
	-- 这样roll点拍卖和出分拍卖一样，只有用户主动点击时才显示窗口
end

-- DKP出分记录显示更新函数
function XYT_UpdateDKPDisplay()
	-- 确保DKP监控窗口存在
	if not DKPMonitorFrame then
		return;
	end
	
	local sortedScores = {};
	for name, score in pairs(XYT_DKP_Scores) do
		local playerInfo = getXyInfo(name);
		local class = playerInfo and playerInfo["class"] or "未知";
		local dkp = tonumber(playerInfo and playerInfo["dkp"] or DefaultDKP) or 0;
		local wish = "";
		if playerInfo and playerInfo["xy"] and playerInfo["xy"] ~= "" and playerInfo["xy"] ~= "---未许愿---" then
			wish = playerInfo["xy"];
		elseif XYT_DKP_Wishes and XYT_DKP_Wishes[name] and XYT_DKP_Wishes[name] ~= "" then
			wish = XYT_DKP_Wishes[name];
		end
		local scoreValue = tonumber(score) or 0;
		table.insert(sortedScores, {name = name, score = scoreValue, class = class, dkp = dkp, wish = wish});
	end
	table.sort(sortedScores, function(a, b) return a.score > b.score end);
	
	-- 更新标题显示
	local titleText = "DKP出分记录";
	if XYT_IsRecordingDKP then
		titleText = "DKP出分监控";
	end
	getglobal("DKPMonitorFrameTitle"):SetText(titleText);
	
	-- 更新列表显示
	for i = 1, 15 do
		local button = getglobal("DKPFrameListButton" .. i);
		if button then
			if i <= table.getn(sortedScores) then
				local entry = sortedScores[i];
				
				-- 根据职业设置颜色
				local color = "|cFFFFFFFF"; -- 默认白色
				if entry.class == "战士" then color = "|cFFC79C6E";
				elseif entry.class == "圣骑士" then color = "|cFFF58CBA";
				elseif entry.class == "猎人" then color = "|cFFABD473";
				elseif entry.class == "盗贼" then color = "|cFFFFF569";
				elseif entry.class == "牧师" then color = "|cFFFFFFFF";
				elseif entry.class == "死亡骑士" then color = "|cFFC41F3B";
				elseif entry.class == "萨满祭司" then color = "|cFF0070DE";
				elseif entry.class == "法师" then color = "|cFF69CCF0";
				elseif entry.class == "术士" then color = "|cFF9482C9";
				elseif entry.class == "德鲁伊" then color = "|cFFFF7D0A";
				end
				
				-- 设置带职业染色的名字
				local displayName = color .. entry.name .. "|r";
				
				-- 设置表单显示
				getglobal(button:GetName() .. "Score"):SetText(entry.score);
				getglobal(button:GetName() .. "Name"):SetText(displayName);
				getglobal(button:GetName() .. "Wish"):SetText(entry.wish or "---未许愿---");

				button:Show();
			else
				-- 清空未使用的行
				getglobal(button:GetName() .. "Score"):SetText("");
				getglobal(button:GetName() .. "Name"):SetText("");
				getglobal(button:GetName() .. "Wish"):SetText("");

				button:Hide();
			end
		end
	end
	
	-- 显示窗口
	getglobal("DKPMonitorFrame"):Show();
end

-- 获取唯一的ROLL点记录（单人只选第一次）
function XYT_GetUniqueRolls(limit)
	local rolls = {};
	local nameMap = {};
	
	-- 首先检查XYT_Roll_Scores（从之前的函数可以看到这是ROLL点记录的主要存储位置）
	if XYT_Roll_Scores and type(XYT_Roll_Scores) == "table" then
		for name, roll in pairs(XYT_Roll_Scores) do
			if name and roll and not nameMap[name] then
				nameMap[name] = true;
				local id = XYT_GetIDbyName(name);
				local class = "未知";
				if id then
					class = UnitClass(id) or "未知";
				end
				-- 获取玩家信息、分数和许愿
				local playerInfo = getXyInfo(name);
				local dkp = tonumber(playerInfo and playerInfo["dkp"] or DefaultDKP) or 0;
				-- 修复：优先从XYT_Roll_Wishes获取许愿内容，如果为空则从XyArray获取
				local wish = "";
				if XYT_Roll_Wishes and XYT_Roll_Wishes[name] and XYT_Roll_Wishes[name] ~= "" and XYT_Roll_Wishes[name] ~= "---未许愿---" then
					wish = XYT_Roll_Wishes[name];
				elseif playerInfo and playerInfo["xy"] and playerInfo["xy"] ~= "" and playerInfo["xy"] ~= "---未许愿---" then
					wish = playerInfo["xy"];
				end
				-- 确保roll值是数字类型
				local rollValue = tonumber(roll) or 0;
				table.insert(rolls, {name = name, roll = rollValue, class = class, dkp = dkp, wish = wish});
			end
		end
	end
	
	-- 同时检查CML_Vars.Rolls作为备用数据源
	if CML_Vars and CML_Vars.Rolls and type(CML_Vars.Rolls) == "table" then
		local count = table.getn(CML_Vars.Rolls);
		for i = 1, count do
			local rollData = CML_Vars.Rolls[i];
			if rollData and rollData.name and rollData.roll and not nameMap[rollData.name] then
				nameMap[rollData.name] = true;
				local id = XYT_GetIDbyName(rollData.name);
				local class = "未知";
				if id then
					class = UnitClass(id) or "未知";
				end
				-- 获取玩家信息、分数和许愿
				local playerInfo = getXyInfo(rollData.name);
				local dkp = tonumber(playerInfo and playerInfo["dkp"] or DefaultDKP) or 0;
				-- 修复：优先从XYT_Roll_Wishes获取许愿内容，如果为空则从XyArray获取
				local wish = "";
				if XYT_Roll_Wishes and XYT_Roll_Wishes[rollData.name] and XYT_Roll_Wishes[rollData.name] ~= "" and XYT_Roll_Wishes[rollData.name] ~= "---未许愿---" then
					wish = XYT_Roll_Wishes[rollData.name];
				elseif playerInfo and playerInfo["xy"] and playerInfo["xy"] ~= "" and playerInfo["xy"] ~= "---未许愿---" then
					wish = playerInfo["xy"];
				end
				-- 确保roll值是数字类型
				local rollValue = tonumber(rollData.roll) or 0;
				table.insert(rolls, {name = rollData.name, roll = rollValue, class = class, dkp = dkp, wish = wish});
			end
		end
	end
	
	-- 按ROLL点降序排序
	table.sort(rolls, function(a, b) 
		local rollA = tonumber(a.roll) or 0;
		local rollB = tonumber(b.roll) or 0;
		return rollA > rollB;
	end);
	
	-- 返回前N个
	local result = {};
	local actualLimit = math.min(limit or 5, table.getn(rolls));
	for i = 1, actualLimit do
		table.insert(result, rolls[i]);
	end
	
	return result;
end

function RollMonitor_UpdateList(sortedRolls)
	-- 如果没有传入参数，从全局变量获取
	if not sortedRolls then
		sortedRolls = {};
		for name, roll in pairs(XYT_Roll_Scores) do
			local playerInfo = getXyInfo(name);
			local class = playerInfo and playerInfo["class"] or "未知";
			local dkp = tonumber(playerInfo and playerInfo["dkp"] or DefaultDKP) or 0;
			-- 修复：优先从XYT_Roll_Wishes获取许愿内容，如果为空则从XyArray获取
			local wish = "";
			if XYT_Roll_Wishes and XYT_Roll_Wishes[name] and XYT_Roll_Wishes[name] ~= "" and XYT_Roll_Wishes[name] ~= "---未许愿---" then
				wish = XYT_Roll_Wishes[name];
			elseif playerInfo and playerInfo["xy"] and playerInfo["xy"] ~= "" and playerInfo["xy"] ~= "---未许愿---" then
				wish = playerInfo["xy"];
			end
			table.insert(sortedRolls, {name = name, roll = roll, class = class, dkp = dkp, wish = wish});
		end
		table.sort(sortedRolls, function(a, b) return a.roll > b.roll end);
	end
	
	-- 更新滚动条
	FauxScrollFrame_Update(RollListScrollFrame, table.getn(sortedRolls), 10, 25);
	
	-- 更新列表按钮
	for i = 1, 15 do
		if i > table.getn(sortedRolls) then
			getglobal("RollFrameListButton" .. i):Hide();
		else
			local entry = sortedRolls[i];
			local nameText = getglobal("RollFrameListButton" .. i .. "Name")
			
			-- 根据职业设置颜色
			local color = "|cFFFFFFFF"; -- 默认白色
			if entry.class == "战士" then color = "|cFFC79C6E";
			elseif entry.class == "圣骑士" then color = "|cFFF58CBA";
			elseif entry.class == "猎人" then color = "|cFFABD473";
			elseif entry.class == "盗贼" then color = "|cFFFFF569";
			elseif entry.class == "牧师" then color = "|cFFFFFFFF";
			elseif entry.class == "死亡骑士" then color = "|cFFC41F3B";
			elseif entry.class == "萨满祭司" then color = "|cFF0070DE";
			elseif entry.class == "法师" then color = "|cFF69CCF0";
			elseif entry.class == "术士" then color = "|cFF9482C9";
			elseif entry.class == "德鲁伊" then color = "|cFFFF7D0A";
			end
			
			-- 设置带职业染色的名字
			local displayName = color .. entry.name .. "|r";
			
			-- 如果是第一名（获胜者），添加额外的高亮效果
			if i == 1 and table.getn(sortedRolls) > 0 then
				-- 使用颜色标签来实现高亮，不会覆盖职业染色
				displayName = "|cFF00FF00" .. displayName .. "|r";
			end
			
			nameText:SetText(displayName);
			
			-- 修复：确保许愿内容正确显示
			local wishWithClass = entry.wish or "";
			if wishWithClass == "" then
				wishWithClass = "---未许愿---";
			end
			getglobal("RollFrameListButton" .. i .. "Xy"):SetText(wishWithClass);
		
			-- 修复：确保分数正确显示，转换为数字并处理nil情况
			local dkpValue = tonumber(entry.dkp) or tonumber(DefaultDKP) or 0;
			getglobal("RollFrameListButton" .. i .. "DKP"):SetText(dkpValue);
			
			-- 修复：确保ROLL点正确显示，转换为数字处理
			local rollValue = tonumber(entry.roll) or 0;
			getglobal("RollFrameListButton" .. i .. "Roll"):SetText(rollValue);
			getglobal("RollFrameListButton" .. i):Show();
			
			-- 使用XML模板中定义的扣按钮（DeductButton）
			local deductButton = getglobal("RollFrameListButton" .. i .. "DeductButton");
			if deductButton then
				-- 确保按钮文本始终为"扣"
				deductButton:SetText("扣")
				
				-- 从出分拍卖表中检查该玩家是否有出分记录
				local hasBid = false;
				local playerName = entry.name; -- 直接使用原始玩家名称，不带颜色标签
				if XYT_Auction_Scores and XYT_Auction_Scores[playerName] then
					hasBid = true;
				end
				
				-- 显示条件：玩家有出分记录且拍卖仍在进行中
				if hasBid and (not XYT_HasDeductedScore or not XYT_Auction_IsActive) then
					-- 重新设置点击事件，确保与创建时的逻辑一致
					deductButton:SetScript("OnClick", function()
						local playerName = entry.name; -- 直接使用原始玩家名称
						local bidScore = 5; -- 默认5分
						
						-- 优先使用玩家在出分拍卖中的出分记录
						if XYT_Auction_Scores and XYT_Auction_Scores[playerName] then
							bidScore = tonumber(XYT_Auction_Scores[playerName]) or 5;
						end
						
						if playerName then
							XYT_DeductPlayerScore(playerName, bidScore);
							-- 移除按钮禁用，允许按钮回弹，但通过XYT_HasDeductedScore变量防止重复扣分
							-- 刷新出分拍卖和ROLL点拍卖窗口数据
							XYT_UpdateAuctionDisplay();
							RollMonitor_UpdateList();
						end
					end);
					
					deductButton:Enable();
					deductButton:Show();
				else
					deductButton:Hide();
				end
			end
		end
	end
end



local XyItemCount = {}  -- 新增：用于记录物品许愿次数
LootList = {}  -- 存储拾取列表数据（全局变量，用于保存）
LootSortField = "itemName"  -- 默认排序字段（改为全局变量）
LootSortOrder = 1  -- 1为升序，-1为降序（改为全局变量）
XY_BUTTON_HEIGHT = 25;
Xy_SortOptions = { ["method"] = "", ["itemway"] = "" };
UnitPopupButtons["GET_XY"] = { text = "查询许愿", dist = 0 };
-- 同步控制变量
local lastAutoSyncTime = nil  -- 上次自动同步时间（团长用）
local lastSyncRequestTime = nil  -- 上次请求同步时间（团员用）
-- 已移除加减分数按钮
UnitPopupButtons["ADD_DKP"] = { text = "增加分数", dist = 0, nested = 1 };
UnitPopupButtons["Minus_DKP"] = { text = "扣除分数", dist = 0, nested = 1 };


-- 已移除加减分数子菜单按钮
UnitPopupButtons["ADD_DKP_1"] = { text = "增加1分", dist = 0 };
UnitPopupButtons["ADD_DKP_2"] = { text = "增加2分", dist = 0 };
UnitPopupButtons["ADD_DKP_3"] = { text = "增加3分", dist = 0 };
UnitPopupButtons["ADD_DKP_4"] = { text = "增加4分", dist = 0 };
UnitPopupButtons["MINUS_DKP_1"] = { text = "扣除1分", dist = 0 };
UnitPopupButtons["MINUS_DKP_2"] = { text = "扣除2分", dist = 0 };
UnitPopupButtons["MINUS_DKP_3"] = { text = "扣除3分", dist = 0 };
UnitPopupButtons["MINUS_DKP_4"] = { text = "扣除4分", dist = 0 };


NewDKP = false

-- 宣言相关变量
local playerDeclaration = ""

-- 宣言功能函数
function XyTracker_OnDeclarationButtonClick()
    -- 打开独立宣言窗口
    local declarationWindow = getglobal("XyTrackerDeclarationFrame")
    local declarationEditBox = getglobal("XyTrackerDeclarationLargeEditBox")
    
    -- 确保宣言内容正确加载，优先使用XyTrackerOptions中的值
    if XyTrackerOptions and XyTrackerOptions.Declaration and XyTrackerOptions.Declaration ~= "" then
        declarationEditBox:SetText(XyTrackerOptions.Declaration)
    elseif playerDeclaration and playerDeclaration ~= "" then
        declarationEditBox:SetText(playerDeclaration)
    else
        declarationEditBox:SetText("")
    end
    
    declarationEditBox:SetFocus()
    
    -- 显示窗口
    declarationWindow:Show()
    
    -- 已移除调试信息
end

-- 保存宣言内容的函数
function XyTracker_SaveDeclaration()
    local declarationEditBox = getglobal("XyTrackerDeclarationLargeEditBox")
    local declarationWindow = getglobal("XyTrackerDeclarationFrame")
    
    -- 获取输入框中的内容
    local newDeclaration = declarationEditBox:GetText()
    
    -- 确保保存宣言内容到两个变量，确保通告功能能够正确读取
    playerDeclaration = newDeclaration
    
    -- 持久化保存到设置中，下次开团时自动加载
 InitializeXyTrackerOptions()
   DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 宣言文本已更新并保存")

 XyTrackerOptions.Declaration = newDeclaration
    
    -- 已移除确认消息和调试信息
    
    -- 隐藏窗口
    declarationWindow:Hide()
end

function XyTracker_OnAnnounceDeclarationButtonClick()
    -- 优先从XyTrackerOptions获取宣言内容，确保使用最新保存的值
    local declarationText = XyTrackerOptions and XyTrackerOptions.Declaration or playerDeclaration
    
    if declarationText and declarationText ~= "" then
        local lineCount = 0
        local startPos = 1
        local textLength = string.len(declarationText)
        
        while startPos <= textLength do
            -- 查找下一个换行符或字符串结束位置
            local endPos = string.find(declarationText, "\n", startPos)
            if not endPos then
                endPos = textLength + 1
            end
            
            -- 提取当前行文本
            local line = string.sub(declarationText, startPos, endPos - 1)
            if line and line ~= "" then
                lineCount = lineCount + 1
                if lineCount == 1 then
                    -- 第一行添加前缀
                    SendChatMessage("【团队宣言】" .. line, "RAID_WARNING", nil, nil)
                else
                    -- 后续行直接发送
                    SendChatMessage(line, "RAID_WARNING", nil, nil)
                end
            end
            
            -- 移动到下一行起始位置
            startPos = endPos + 1
        end
        
        -- 已移除确认消息
    else
        -- 已移除提示消息
    end
end



function RollMonitor_Clear()
	-- 使用新的数据结构XYT_Roll_Scores
	XYT_Roll_Scores = {}
	XYT_Roll_Wishes = {}
	XYT_Roll_EndTime = nil
	XYT_CurrentItem = nil
	
	-- -- 更新xytRollTime显示为0，表示ROLL点已清除
	-- if getglobal("xytRollTime") then
	-- 	getglobal("xytRollTime"):SetText("0");
	-- end
DEFAULT_CHAT_FRAME:AddMessage("ROLL点拍卖数据已清除");
	RollMonitor_UpdateList()
	-- getglobal("RollMonitorFrame"):Hide();
end

-- 测试函数：用于验证ROLL点监控修复效果
function TestRollMonitor()
	-- 测试RollStart函数
	DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 开始测试ROLL点监控功能...")
	RollStart("测试物品")
	
	-- 模拟一些ROLL点数据
	local testPlayers = {"玩家1", "玩家2", "玩家3"}
	local testRolls = {85, 92, 73}
	
	-- 使用新的数据结构XYT_Roll_Scores
	for i = 1, 3 do
		XYT_Roll_Scores[testPlayers[i]] = testRolls[i]
		XYT_Roll_Wishes[testPlayers[i]] = "测试许愿" .. i
	end
	
	-- 更新显示
	RollMonitor_UpdateList()
	DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 测试数据已添加，请检查ROLL点监控窗口")
end

-- 修改为记录多个玩家的发言
local raidMessages = {}  -- 用于存储所有玩家的发言记录
--自动扣分开关
function autoMin_OnClick()
    XyTrackerOptions.autoMinDkp = this:GetChecked()
end
-- 添加颜色模式切换函数
function greenMode_OnClick()
    XyTrackerOptions.greenModeEnabled = this:GetChecked()
end

function blueMode_OnClick()
    XyTrackerOptions.blueModeEnabled = this:GetChecked()
end

function purpleMode_OnClick()
    XyTrackerOptions.purpleModeEnabled = this:GetChecked()
end

function autoMode_OnClick()
    if this:GetChecked() then
        XyTrackerOptions.XyOnlyMode = 1
    else
        XyTrackerOptions.XyOnlyMode = 0
    end
end

function autoAnnounce_OnClick()
    if this:GetChecked() then
        XyTrackerOptions.AutoAnnounce = true
    else
        XyTrackerOptions.AutoAnnounce = false
    end
end

-- 调用默认DKP
function printDefaultDKP()
    getglobal("allDKPFrameTXT"):SetText(DefaultDKP);
end
-- 更新默认DKP
function NEWDefaultDKP()
    DefaultDKP = getglobal("allDKPFrameTXT"):GetNumber();
    NewDKP = true
    XyTracker_OnRefreshButtonClick()
    XyTracker_UpdateList() -- 更新DKP列表
    SendChatMessage("通知：当前默认DKP为每人" .. DefaultDKP .. "分，分数已初始化", "RAID", this.language, nil)
end
-- 检查列表中是否包含指定元素
function contain(v, l)
    if not l then
        return false
    end
    local n = table.getn(l)
    if n > 0 then
        for i = 1, n do
            local lv = l[i]
            if v == lv then
                return true
            end
        end
    end


    return false
end
-- 注册右键菜单权限控制按钮
function XyTracker_RegisterRightClickMenuButtons()
    if UnitPopupMenus["PARTY"] then
        if IsLeader then
            if not contain("ADD_DKP", UnitPopupMenus["PARTY"]) then
                table.insert(UnitPopupMenus["PARTY"], "ADD_DKP")
            end
            if not contain("Minus_DKP", UnitPopupMenus["PARTY"]) then
                table.insert(UnitPopupMenus["PARTY"], "Minus_DKP")
            end
            -- -- 已移除：添加ROLL点拍卖按钮（仅团长可见）
            -- if not contain("ROLL_AUCTION", UnitPopupMenus["PARTY"]) then
            --     table.insert(UnitPopupMenus["PARTY"], "ROLL_AUCTION")
            -- end
        else
            -- 如果不是团长，移除这些按钮
            local index1 = nil
            local index2 = nil
            -- local index3 = nil  -- 已移除：ROLL点拍卖按钮索引
            for i, v in ipairs(UnitPopupMenus["PARTY"]) do
                if v == "ADD_DKP" then
                    index1 = i
                elseif v == "Minus_DKP" then
                    index2 = i
                -- elseif v == "ROLL_AUCTION" then  -- 已移除：查找ROLL点拍卖按钮
                --     index3 = i
                end
            end
            if index1 then
                table.remove(UnitPopupMenus["PARTY"], index1)
            end
            if index2 then
                table.remove(UnitPopupMenus["PARTY"], index2)
            end
            -- if index3 then  -- 已移除：移除ROLL点拍卖按钮
            --     table.remove(UnitPopupMenus["PARTY"], index3)
            -- end
        end
        if not contain("GET_XY", UnitPopupMenus["PARTY"]) then
            table.insert(UnitPopupMenus["PARTY"], "GET_XY")
        end
    end
end

-- 发送所有人的许愿
function XyTracker_AnnounceAllWishes()
    local n = table.getn(XyArray)
    if n > 0 then
        for i = 1, n do
            local info = XyArray[i]
            local name = info["name"]
            local xy = info["xy"] or "---未许愿---"
            if xy ~= "---未许愿---" and xy ~= "" then
                SendChatMessage(name .. " 许愿：" .. xy, "RAID", this.language, nil)
            end
        end
    end
end

-- 插件加载时的初始化函数
function XyTracker_OnLoad()
    -- 初始化IsLeader变量
    IsLeader = false
    
    -- 初始化拾取列表排序变量
    LootSortField = "timestamp" -- 默认按拾取时间排序
    LootSortOrder = 1 -- 默认升序（1表示升序，-1表示降序）
    
    -- 在单位弹出菜单中添加按钮
    XyTracker_RegisterRightClickMenuButtons()
    
    -- 初始化LootList为空表（如果不存在）
    if LootList == nil then
        LootList = {}
    end
    
    -- 初始化SavedLootList为空表（如果不存在）
    if SavedLootList == nil then
        SavedLootList = {}
    end
    
    -- 初始化SavedWishList为空表（如果不存在）
    if SavedWishList == nil then
        SavedWishList = {}
    end
    
    -- 初始化许愿分设置
    if not XyTrackerOptions then XyTrackerOptions = {} end
    if not XyTrackerOptions.WishScore then XyTrackerOptions.WishScore = 0 end
    
    -- 加载保存的宣言内容 - 增强版，确保内容能够正确加载
    if XyTrackerOptions and XyTrackerOptions.Declaration and XyTrackerOptions.Declaration ~= "" then
        playerDeclaration = XyTrackerOptions.Declaration
    -- 否则回退到旧的存储方式
    elseif XyTrackerDeclaration and XyTrackerDeclaration ~= "" then
        playerDeclaration = XyTrackerDeclaration
    else
        -- 初始化默认宣言内容
        playerDeclaration = " 参与本次副本必须同意以下副本规则，参与活动表示接受：\n 1. 本次副本内装备分配以许愿为准。歪歪1453862000\n 2. 考核数据以第一名的70%记减ROLL点每低1点减1ROLL点。有任务除外或按情况降低要求。\n 3. 打本有事离开打字请假，不得划水，挂机，多开。完成分配任务。必须上YY服从指挥，多次点名没反应，不能完成任务的 踢出队伍或减ROLL点。\n 4. ADD或中常规技能死亡（裂隙，瓦解，黑水，冰龙炸弹等）扣ROLL点。\n 5. 本次副本内所有物品，不能代roll，不能roll中之后让给他人。\n 6. 在团长拍物品时专心出分ROLL点，错过拍分自负，如有分配出错请及时打字提醒，或者开麦指出。\n 7. 文明打本不得辱骂他人与团员发生争执，有问题在准备战斗前或者战斗结束后指出，不要打断指挥。\n 8. 如有违反，自愿接受GM处罚（包括不限于装备销毁/账号冻结）"
        InitializeXyTrackerOptions()
        XyTrackerOptions.Declaration = playerDeclaration
    end
    
    -- 已移除加载记录调试信息

    -- 设置命令行指令
    SlashCmdList["XYTRACKER"] = XyTracker_OnSlashCommand
    SLASH_XYTRACKER1 = "/xyt"
    SLASH_XYTRACKER2 = "/Xytrack"
    SLASH_XYTRACKER3 = "/xy"
    -- 注册事件监听
    this:RegisterEvent("VARIABLES_LOADED")
    this:RegisterEvent("CHAT_MSG_SYSTEM")
    this:RegisterEvent("CHAT_MSG_PARTY")
    this:RegisterEvent("CHAT_MSG_RAID")
    this:RegisterEvent("CHAT_MSG_RAID_LEADER")
    this:RegisterEvent("CHAT_MSG_RAID_WARNING")
    this:RegisterEvent("CHAT_MSG_ADDON")
    this:RegisterEvent("CHAT_MSG_WHISPER")
    this:RegisterEvent("PLAYER_LOGOUT")
    this:RegisterEvent("CHAT_MSG_LOOT")
    this:RegisterEvent("LOOT_OPENED")
    this:RegisterEvent("LOOT_CLOSED")
    
    -- 窗口颜色和拖动功能已在XML中设置，避免重复设置导致冲突
    -- 备份原始单位弹出窗口点击处理函数
    ori_unitpopup1 = UnitPopup_OnClick;
    -- 替换单位弹出窗口点击处理函数
    UnitPopup_OnClick = ple_unitpopup1;
    -- 初始化变量
    InitializeXyTrackerOptions()
    if XyArray == nil then
        XyArray = {}
    end
    XyInProgress = false
    NoXyList = ""
    Xys = 0
    -- 用于控制接收同步数据时不发送公告
    IsReceivingSync = false


-- 更新许愿分输入框的值
function XyTracker_UpdateWishScoreEditBox()
    local wishScoreEditBox = getglobal("XyTrackerWishScoreEditBox")
    local currentWishScoreText = getglobal("XyTrackerCurrentWishScore")
    local currentScore = XyTrackerOptions and (XyTrackerOptions.WishScore or 0) or 0
    
    if wishScoreEditBox then
        wishScoreEditBox:SetText(tostring(currentScore))
    end
    
    if currentWishScoreText then
        currentWishScoreText:SetText("(当前设置: " .. tostring(currentScore) .. ")")
    end
end

-- 保存许愿分设置
function XyTracker_SaveWishScore(scoreText)
    local editBox = getglobal("XyTrackerWishScoreEditBox")
    local score = tonumber(scoreText) or 0
    
    -- 使用Lua的比较运算符，而不是在XML中直接使用
    if score > 9 then 
        score = 9 
    end
    
    if score < 0 then 
        score = 0 
    end
    
    -- 更新输入框显示
    if editBox then
        editBox:SetText(tostring(score))
    end
    
    -- 保存设置
    if not XyTrackerOptions then 
        XyTrackerOptions = {} 
    end
    XyTrackerOptions.WishScore = score
    
    -- 清除焦点
    if editBox then
        editBox:ClearFocus()
    end
end

-- 全局安全字符串清理函数
-- 添加消息去重缓存，存储最近播报的消息和时间戳
sentMessages = {}  -- 键为消息内容，值为发送时间戳

-- 临时调试函数：重置指定玩家的许愿数据
slashcommands = {}
function slashcommands.resetxy(name, params)
    if not XyArray then
        DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 没有找到许愿数据")
        return
    end
    
    -- 如果没有提供参数，重置所有数据
    if not params or params == "" then
        XyArray = {}
        DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 已重置所有许愿数据")
        XyTracker_UpdateList()
        return
    end
    
    -- 重置指定玩家的数据
    local found = false
    for i = 1, table.getn(XyArray) do
        if XyArray[i]["name"] == params then
            XyArray[i]["xy"] = "---未许愿---"
            DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 已重置玩家 "..params.." 的许愿数据")
            found = true
            break
        end
    end
    
    -- 也检查displayArray（如果存在）
    if displayArray and type(displayArray) == "table" then
        for i = 1, table.getn(displayArray) do
            if displayArray[i]["name"] == params then
                displayArray[i]["xy"] = "---未许愿---"
                break
            end
        end
    end
    
    if not found then
        DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 未找到玩家 "..params)
    else
        XyTracker_UpdateList()
    end
end

function safeCleanString(str)
    if not str or type(str) ~= "string" then
        return ""
    end

    local cleanStr = string.gsub(str, "|c%x%x%x%x%x%x%x%x", "")
    cleanStr = string.gsub(cleanStr, "|r", "")
    
    -- 移除空格和特殊字符
    cleanStr = string.gsub(cleanStr, "%s+", "")
    cleanStr = string.lower(cleanStr)
    
    return cleanStr
end
    local autoModeButtons = getglobal("autoModeButtons");
    autoModeButtons:SetChecked(XyTrackerOptions.XyOnlyMode);
    getglobal("autoAnnounceButton"):SetChecked(XyTrackerOptions.AutoAnnounce); -- 设置勾选框状态
    XyTracker_UpdateList()
    SendAddonMessage("XY_SYNC_NEW", "", "RAID")
    -- 加载存储的数据
    if XyTrackerDB then
        for name, data in pairs(XyTrackerDB) do
            local info = getXyInfo(name)
            if info then
                info.dkp = data.dkp
            end
        end
    end

   
    
    -- 添加加减分数子菜单定义
    if not UnitPopupMenus["ADD_DKP"] then
        UnitPopupMenus["ADD_DKP"] = {
            "ADD_DKP_1",
            "ADD_DKP_2", 
            "ADD_DKP_3",
            "ADD_DKP_4"
        };
    end
    
    if not UnitPopupMenus["Minus_DKP"] then
        UnitPopupMenus["Minus_DKP"] = {
            "MINUS_DKP_1",
            "MINUS_DKP_2",
            "MINUS_DKP_3", 
            "MINUS_DKP_4"
        };
    end

	
	--增强CML拾取大师
	-- 直接初始化自定义下拉菜单，不使用原始的GroupLootDropDown_Initialize函数
	UIDropDownMenu_Initialize(GroupLootDropDown, XYT_InitDropDown, "MENU");
	
	-- 初始化DKP和ROLL点监控窗口状态
	if DKPMonitorFrame then
		DKPMonitorFrame:Hide();
	end
	if RollMonitorFrame then
		RollMonitorFrame:Hide();
	end
end

-- 定义CML相关的本地化字符串
CML_Classes = {
    Druid = "德鲁伊",
    Hunter = "猎人",
    Mage = "法师",
    Paladin = "圣骑士",
    Priest = "牧师",
    Rogue = "盗贼",
    Shaman = "萨满祭司",
    Warlock = "术士",
    Warrior = "战士",
    Unknown = "未知",
    Random = "随机成员",
    Self = "自我拾取",
}

CML_ROLL_DROPDOWNMENU = "最佳(%d)个Roll点";
CML_RANDOMLOOT = "Roll点 %d -> 胜利者是 %s";
CML_ROLL_ANOUNCE_MESSAGE = "%s Roll点奖励开始,请大家输入 /random %d-%d ,或者/roll 进行roll点";
CML_ROLL_TABLE_HEADER = "最佳Roll点(点数 - 名字)";
CML_BIDBOT_DROPDOWNMENU = "BidBot 竞拍";
CML_ROLL_SEARCHPATTERN = "(.+)掷出(%d+)（(%d+)-(%d+)）";

-- 初始化CML变量
CML_Vars = CML_Vars or {};
CML_Vars.Enabled = CML_Vars.Enabled or true;
CML_Vars.PostRandom = CML_Vars.PostRandom or true;
CML_Vars.Ask = CML_Vars.Ask or false;
CML_Vars.Quickloot = CML_Vars.Quickloot or "";
CML_Vars.ShowRolls = CML_Vars.ShowRolls or 5;
CML_Vars.RollStartTime = CML_Vars.RollStartTime or 0;
CML_Vars.RollTimeout = CML_Vars.RollTimeout or 60;
CML_Vars.Rolls = CML_Vars.Rolls or {};
CML_Vars.Roll_Min = CML_Vars.Roll_Min or 1;
CML_Vars.Roll_Max = CML_Vars.Roll_Max or 100;
CML_Vars.BidBodSupport = CML_Vars.BidBodSupport or false;

-- 帮助函数：根据名字获取玩家ID（支持团队、队伍和自己）
function XYT_GetIDbyName(name)
    -- 首先在团队中查找
    for i = 1, GetNumRaidMembers() do
        if (UnitName("raid" .. i) == name) then
            return "raid" .. i;
        end
    end
    
    -- 如果团队中没找到，在队伍中查找
    for i = 1, GetNumPartyMembers() do
        if (UnitName("party" .. i) == name) then
            return "party" .. i;
        end
    end
    
    -- 检查是否是自己
    if (UnitName("player") == name) then
        return "player";
    end
    
    -- 如果都没找到，返回nil
    return nil;
end

-- 重置小地图图标位置的函数
function XyTracker_ResetMinimapButtonPosition()
    -- 获取小地图图标按钮
    local button = getglobal("XyTrackerMinimapButton")
    if button then
        -- 清除当前位置设置
        button:ClearAllPoints()
        
        -- 设置默认位置（小地图右侧）
        button:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -5, -5)
        
        -- 重置为默认尺寸
        button:SetWidth(26)
        button:SetHeight(26)
        local normalTex = button:GetNormalTexture()
        if normalTex then
            normalTex:SetWidth(20)
            normalTex:SetHeight(20)
        end
        local highlightTex = button:GetHighlightTexture()
        if highlightTex then
            highlightTex:SetWidth(26)
            highlightTex:SetHeight(26)
        end
        
        -- 更新数据库中的位置信息
        if XyTrackerOptions then
            XyTrackerOptions.minimapPos = {x = -5, y = -5}
            XyTrackerOptions.minimapIsFree = false  -- 重置为围绕小地图模式
        end
        
        DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 小地图图标已重置到默认位置")
    else
        DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 小地图图标未找到，可能尚未创建")
    end
end

-- 注册XY主命令
SLASH_XY1 = "/xy"
function SlashCmdList.XY(msg)
    -- 将命令转换为小写以忽略大小写
    local cmd = string.lower(msg)
    
    -- 处理RL子命令（重置小地图图标位置）
    if cmd == "rl" then
        XyTracker_ResetMinimapButtonPosition()
    else
        -- 显示帮助信息
        DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 命令列表：")
        DEFAULT_CHAT_FRAME:AddMessage("  /xy rl - 重置小地图图标位置")
    end
end

-- 帮助函数：获取队伍类型
function XYT_GetGroupType()
    if (GetNumRaidMembers() > 0) then
        return "RAID";
    else
        return "PARTY";
    end
end

-- 帮助函数：隐藏下拉菜单
function XYT_HideDropDownMenu()
    for i = 1, UIDROPDOWNMENU_MAXLEVELS do
        getglobal("DropDownList" .. i):Hide();
    end
end

-- 分配物品给指定玩家
function XYT_GiveItTo(self, sourceMenu)
    local value = self and self.value or 0;
    value = tonumber(value) or 0;  -- 确保value是数字类型
    local isAuctionMenu = sourceMenu == "AUCTIONLIST";
    local isRollMenu = sourceMenu == "ROLLLIST";
    local playerName;
    
    -- 分配物品并获取玩家名称
    if value > 0 then
        playerName = GetMasterLootCandidate(value);
        local showDialog = false;
        
        if (CML_Vars.Ask) then
            showDialog = true;
        else
            if (LootFrame.selectedQuality) then
                if (LootFrame.selectedQuality >= 3) then -- 3表示蓝色品质
                    showDialog = true;
                end
            end
        end
        
        -- 分配物品
        if (showDialog) then
            local dialog = StaticPopup_Show("CONFIRM_LOOT_DISTRIBUTION",
            (LootFrame.selectedQuality and ITEM_QUALITY_COLORS[LootFrame.selectedQuality].hex or "") .. (LootFrame.selectedItemName or "") .. FONT_COLOR_CODE_CLOSE,
            playerName);
            if (dialog) then
                dialog.data = value;
            end
        else
            GiveMasterLoot(LootFrame.selectedSlot, value);
        end
        
        -- 自动扣除分数：只在从出分拍卖菜单或ROLL点拍卖菜单调用时执行
        local shouldDeduct = false;
        local bidScore = 0;
        
        -- 只有从出分拍卖菜单调用且玩家有出分记录时才扣分
        if isAuctionMenu and XYT_Auction_Scores and XYT_Auction_Scores[playerName] then
            bidScore = tonumber(XYT_Auction_Scores[playerName]) or 0;
            shouldDeduct = bidScore > 0;
        
        -- 只有从ROLL点拍卖菜单调用且玩家有ROLL点记录时才扣分
        elseif isRollMenu and XYT_Roll_Scores and XYT_Roll_Scores[playerName] then
            -- 只有当玩家在出分拍卖中有出分记录时才扣分
            if XYT_Auction_Scores and XYT_Auction_Scores[playerName] then
                -- 如果玩家在出分拍卖中有出分记录，使用该分数
                bidScore = tonumber(XYT_Auction_Scores[playerName]) or 0;
                shouldDeduct = bidScore > 0;
            else
                -- 没有出分信息时，不进行扣分操作
                shouldDeduct = false;
            end
        end
        
        -- 执行扣分操作
        if shouldDeduct then
            -- 调用扣除分数函数
            XYT_DeductPlayerScore(playerName, bidScore);
        end
        
        -- 无论是否扣分，只要从出分拍卖或ROLL点拍卖菜单分配物品，都清除数据
        if isAuctionMenu or isRollMenu then
            -- 更新显示
            XYT_UpdateAuctionDisplay();
            RollMonitor_UpdateList();
            
            -- 清除拍卖数据
            XYT_Auction_Scores = {};
            XYT_Roll_Scores = {};
        end
    end
    
    -- 添加许愿完成处理逻辑：当物品分配给玩家后，检查并更新玩家的许愿状态
    if playerName then
        -- 获取当前分配的物品名称
        local itemName = LootFrame.selectedItemName or "未知物品"
        
        -- 遍历许愿列表，查找该玩家并更新许愿状态
        for i = 1, getn(XyArray) do
            local info = XyArray[i]
            if info and info["name"] == playerName and info["xy"] and info["xy"] ~= "---未许愿---" then
                -- 调用MarkItemAsCompleted函数更新许愿状态
                local newWish = MarkItemAsCompleted(info["xy"], itemName)
                
                -- 如果许愿状态发生变化
                if newWish ~= info["xy"] then
                    info["xy"] = newWish
                    
                    -- 发送团队消息播报许愿完成
                    -- local currentLanguage = GetDefaultLanguage("player")
                    -- SendChatMessage(playerName .. " 已完成物品 '" .. itemName .. "' 的许愿", "RAID", currentLanguage, nil)
                    
                    -- 更新列表和同步数据
                    XyTracker_UpdateList()
                    syncXy()
                else
                    -- 即使许愿状态未变，也发送物品分配消息，确保记录
                    -- local currentLanguage = GetDefaultLanguage("player")
                    -- SendChatMessage(playerName .. " 获得了物品 '" .. itemName .. "'", "RAID", currentLanguage, nil)
                end
                break
            end
        end
    end
    
    -- 立即刷新界面，确保许愿玩家显示最新状态
    XyTracker_UpdateLootList();
end

-- 分配物品给自己
function XYT_GiveToSelf()
    local myplayerid = 0;
    for i = 1, 40 do
        if (GetMasterLootCandidate(i) == UnitName("player")) then
            myplayerid = i;
        end
    end
    if (myplayerid > 0) then
        local showDialog = false;
        
        if (CML_Vars.Ask) then
            showDialog = true;
        else
            if (LootFrame.selectedQuality) then
                if (LootFrame.selectedQuality >= 3) then
                    showDialog = true;
                end
            end
        end
        
        if (showDialog) then
            LootFrame.value = myplayerid;
            LootFrame.text = GetMasterLootCandidate(myplayerid);

            local dialog = StaticPopup_Show("CONFIRM_LOOT_DISTRIBUTION",
            (LootFrame.selectedQuality and ITEM_QUALITY_COLORS[LootFrame.selectedQuality].hex or "") .. (LootFrame.selectedItemName or "") .. FONT_COLOR_CODE_CLOSE,
            LootFrame.text);
            if (dialog) then
                dialog.data = LootFrame.value;
            end
        else
            GiveMasterLoot(LootFrame.selectedSlot, myplayerid);
        end
        
        -- 添加许愿完成处理逻辑：当分配物品给自己后，检查并更新自己的许愿状态
        if myplayerid > 0 then
            -- 获取当前分配的物品名称
            local itemName = LootFrame.selectedItemName or "未知物品"
            local playerName = UnitName("player")
            
            -- 遍历许愿列表，查找自己并更新许愿状态
            for i = 1, getn(XyArray) do
                local info = XyArray[i]
                if info and info["name"] == playerName and info["xy"] and info["xy"] ~= "---未许愿---" then
                    -- 调用MarkItemAsCompleted函数更新许愿状态
                    local newWish = MarkItemAsCompleted(info["xy"], itemName)
                    
                    -- 如果许愿状态发生变化
                    if newWish ~= info["xy"] then
                        info["xy"] = newWish
                        
                        -- 发送团队消息播报许愿完成
                        -- local currentLanguage = GetDefaultLanguage("player")
                        -- SendChatMessage(playerName .. " 已完成物品 '" .. itemName .. "' 的许愿", "RAID", currentLanguage, nil)
                    else
                        -- 即使许愿状态未变，也发送物品分配消息，确保记录
                        -- local currentLanguage = GetDefaultLanguage("player")
                        -- SendChatMessage(playerName .. " 获得了物品 '" .. itemName .. "'", "RAID", currentLanguage, nil)
                        
                        -- 更新列表和同步数据
                        XyTracker_UpdateList()
                        syncXy()
                    end
                    break
                end
            end
        end
    end
end

-- 随机分配物品
function XYT_GiveToRandomTarget()
    if (GetNumRaidMembers() <= 0) then return; end
    
    local list_players = {};
    local winner = 0;
    local raidmembers = GetNumRaidMembers();
    local donotloopuntilworldexplode = time();

    for i = 1, raidmembers do
        list_players[i] = {};
        list_players[i]["rid"] = "raid" .. i;
        list_players[i]["name"] = UnitName(list_players[i]["rid"]);
        list_players[i]["lootid"] = 0;

        if (string.len(list_players[i]["name"]) > 0) then
            for x = 1, 40 do
                local candidate = GetMasterLootCandidate(x);
                if (candidate == list_players[i]["name"]) then
                    list_players[i]["lootid"] = x;
                end
            end
        end
    end

    winner = math.random(1, raidmembers);

    while (list_players[winner]["lootid"] == 0) do
        winner = math.random(1, raidmembers);
        if (donotloopuntilworldexplode > (time() - 2)) then
            return false;
        end
    end

    if (CML_Vars.PostRandom == true) then
        SendChatMessage(string.format(CML_RANDOMLOOT, winner, GetMasterLootCandidate(list_players[winner]["lootid"])), XYT_GetGroupType());
    end

    if (CML_Vars.Ask or (LootFrame.selectedQuality and LootFrame.selectedQuality >= 3)) then
        LootFrame.value = list_players[winner]["lootid"];
        LootFrame.text = GetMasterLootCandidate(list_players[winner]["lootid"]);

        local dialog = StaticPopup_Show("CONFIRM_LOOT_DISTRIBUTION",
        (LootFrame.selectedQuality and ITEM_QUALITY_COLORS[LootFrame.selectedQuality].hex or "") .. (LootFrame.selectedItemName or "") .. FONT_COLOR_CODE_CLOSE,
        LootFrame.text);
        if (dialog) then
            dialog.data = LootFrame.value;
        end
    else
        GiveMasterLoot(LootFrame.selectedSlot, list_players[winner]["lootid"]);
    end
end

-- 宣布Roll点
function XYT_AnnounceRoll()
    if (GetLootSlotLink(LootFrame.selectedSlot) == nil) then
        return false;
    end

    CML_Vars.Rolls = {};
    CML_Vars.RollStartTime = time();
    local msg = string.format(CML_ROLL_ANOUNCE_MESSAGE, GetLootSlotLink(LootFrame.selectedSlot), CML_Vars.Roll_Min, CML_Vars.Roll_Max);

    SendChatMessage(msg, XYT_GetGroupType());
end

-- 检查玩家是否已经Roll点
function XYT_CheckRoll(player)
    if not CML_Vars or not CML_Vars.Rolls then
        return false;
    end
    
    for i = 1, table.getn(CML_Vars.Rolls) do
        local rollData = CML_Vars.Rolls[i];
        if (rollData ~= nil and rollData.name == player) then
            return true;
        end
    end
    return false;
end

-- 设置玩家Roll点
function XYT_SetRoll(player, roll)
    local baseRoll = tonumber(roll);
    local finalRoll = baseRoll;
    
    -- 应用许愿分逻辑
    if XyTrackerOptions and XyTrackerOptions.WishScore and XyTrackerOptions.WishScore > 0 then
        -- 检查玩家是否有对当前物品的许愿
        if XYT_CurrentItem then
            -- 获取玩家的许愿内容
            local playerWish = XY_GetPlayerWish(player);
            -- 检查玩家许愿内容是否包含当前物品名称
            if playerWish and XYT_CheckItemInWish(playerWish, XYT_CurrentItem) then
                finalRoll = finalRoll + XyTrackerOptions.WishScore;
                -- 在聊天窗口显示带有许愿分的信息
                DEFAULT_CHAT_FRAME:AddMessage(player .. " 触发许愿加分，基础ROLL点: " .. baseRoll .. " + 许愿分: " .. XyTrackerOptions.WishScore .. " = 最终ROLL点: " .. finalRoll);
            end
        end
    end
    
    local TheRoll = {};
    TheRoll["name"] = player;
    TheRoll["roll"] = finalRoll;
    TheRoll["baseRoll"] = baseRoll; -- 保存原始ROLL点便于查看
    TheRoll["time"] = time();

    table.insert(CML_Vars.Rolls, TheRoll);
    table.sort(CML_Vars.Rolls, function(elem1, elem2) return elem1.roll > elem2.roll end);
end

-- 检查物品是否在玩家的许愿内容中
function XYT_CheckItemInWish(wishContent, itemName)
    if not wishContent or not itemName then
        return false;
    end
    
    -- 转换为小写进行不区分大小写的比较
    local lowerWish = string.lower(wishContent);
    local lowerItem = string.lower(itemName);
    
    -- 简单的字符串匹配
    local found = string.find(lowerWish, lowerItem) ~= nil;
    
    return found;
end

-- 显示Roll点表格
function XYT_ShowRollTable()
    -- 如果CML_Vars.Rolls不存在或为空，使用XYT_Roll_Scores
    local rolls = CML_Vars.Rolls;
    if not rolls or table.getn(rolls) == 0 then
        rolls = {};
        for name, roll in pairs(XYT_Roll_Scores) do
            table.insert(rolls, {name = name, roll = roll, baseRoll = roll});
        end
    end
    
    local maxrolls = table.getn(rolls);
    if (maxrolls > CML_Vars.ShowRolls) then
        maxrolls = CML_Vars.ShowRolls;
    end

    SendChatMessage(CML_ROLL_TABLE_HEADER, XYT_GetGroupType());

    -- 按ROLL点数降序排序
    table.sort(rolls, function(a, b) return a.roll > b.roll end);
    
    for i = 1, math.min(maxrolls, table.getn(rolls)) do
        local rollInfo = rolls[i];
        local msg;
        
        -- 检查玩家是否对当前物品有许愿
        local hasWish = false;
        if XYT_CurrentItem then
            local playerWish = XY_GetPlayerWish(rollInfo.name);
            hasWish = XYT_CheckItemInWish(playerWish, XYT_CurrentItem);
        end
        
        -- 只有许愿玩家才显示原始ROLL点和加分信息
        if hasWish and rollInfo.baseRoll and rollInfo.baseRoll ~= rollInfo.roll then
            local bonus = rollInfo.roll - rollInfo.baseRoll;
            msg = rollInfo.roll .. "(" .. rollInfo.baseRoll .. "+" .. bonus .. ") - " .. rollInfo.name;
        else
            msg = rollInfo.roll .. " - " .. rollInfo.name;
        end
        
        SendChatMessage(msg, XYT_GetGroupType());
    end
end

-- 主下拉菜单初始化函数
function XYT_InitDropDown()
	-- 不调用原始下拉菜单函数，避免与GroupRoster表交互导致的nil值错误
	-- 按照用户要求实现动态显示和鼠标滑过功能
	local menuValueDisplay = "nil";
	if UIDROPDOWNMENU_MENU_VALUE then
		if type(UIDROPDOWNMENU_MENU_VALUE) == "table" then
			menuValueDisplay = "[table]";
		else
			menuValueDisplay = tostring(UIDROPDOWNMENU_MENU_VALUE);
		end
	end
	-- 菜单初始化调试（需要时取消注释）
	-- ChatFrame1:AddMessage("[菜单] 层级: " .. UIDROPDOWNMENU_MENU_LEVEL .. ", 值: " .. menuValueDisplay);
	
	if UIDROPDOWNMENU_MENU_LEVEL == 1 then
		-- 1. 增强拾取菜单（标题）
		UIDropDownMenu_AddButton {
			text = "增强拾取菜单",
			notCheckable = 1,
			isTitle = 1,
		}
		
		-- 自我拾取
		UIDropDownMenu_AddButton {
			text = "自我拾取",
			func = XYT_GiveToSelf,
		}
		
		-- 指定拾取：动态显示（设置了显示名字，没设置显示未设置）
		local quickLootText = "指定拾取：未设置";
		local quickLootHasArrow = true;
		local quickLootFunc = function()
			-- 点击时分配给快速拾取人（如果有设置）
			if (CML_Vars.Quickloot ~= "") then
				for i = 1, 40 do
					if (GetMasterLootCandidate(i) == CML_Vars.Quickloot) then
						XYT_GiveItTo({value = i});
						break;
					end
				end
			end
		end;
		
		-- 动态计算指定拾取文本（每次菜单初始化时重新计算）
		if (CML_Vars.Quickloot ~= "") then
			local id = XYT_GetIDbyName(CML_Vars.Quickloot);
			local class = "未知";
			if id then
				class = UnitClass(id) or "未知";
			end
			local classColor = XYT_GetClassColor(class);
			if classColor then
				quickLootText = "指定拾取：" .. classColor .. CML_Vars.Quickloot .. "\124r";
			else
				quickLootText = "指定拾取：" .. CML_Vars.Quickloot;
			end
		end
		
		-- 指定拾取
		UIDropDownMenu_AddButton({
			text = quickLootText,
			value = "QUICKLOOT",
			hasArrow = true,
			func = function()
					-- 先关闭之前的子菜单
					CloseDropDownMenus(2);
					-- 然后执行原有的快速拾取逻辑
					if (CML_Vars.Quickloot ~= "") then
						for i = 1, 40 do
							if (GetMasterLootCandidate(i) == CML_Vars.Quickloot) then
								XYT_GiveItTo({value = i});
								break;
							end
						end
					end
			end,
			onLeave = function()
				GameTooltip:Hide();
			end
		}, UIDROPDOWNMENU_MENU_LEVEL);

		-- 随机分配
		UIDropDownMenu_AddButton {
			text = "随机分配",
			func = XYT_GiveToRandomTarget,
		}
			
		-- 职业分配（支持团队和小队）
		if (GetNumRaidMembers() > 0 or GetNumPartyMembers() > 0) then
			UIDropDownMenu_AddButton {
				text = "职业分配",
				value = "CLASSLIST",
				hasArrow = 1,
				notCheckable = 1,
				func = function()
					CloseDropDownMenus(2);
					ToggleDropDownMenu(2, this.value, XYT_DropDownMenu, this:GetName(), 10, 0, nil, nil, 2);
				end,
				-- 添加鼠标悬停提示
				onLeave = function()
					GameTooltip:Hide();
				end
			}
		end
			if IsLeader then
		-- 添加分隔线
		UIDropDownMenu_AddButton {};
		
		-- 2. 许愿团菜单（标题）- 仅在团队领袖时显示
	
			UIDropDownMenu_AddButton {
				text = "许愿团菜单",
				notCheckable = 1,
				isTitle = 1,
			}
		
			-- 出分拍卖 - 仅在团队领袖时显示
		UIDropDownMenu_AddButton {
			text = "出分拍卖",
			value = "AUCTIONLIST",
			hasArrow = 1,
			func = function()
				CloseDropDownMenus(2);
				-- 获取当前物品
				local item = XYT_GetCurrentLootItem();
				
				-- 如果出分拍卖已在进行中，显示提示消息并显示窗口
				if XYT_Auction_IsActive then
					DEFAULT_CHAT_FRAME:AddMessage("出分拍卖已经在进行中");
					-- 显示出分拍卖窗口
					getglobal("DKPMonitorFrame"):Show();
					return;
				end
				
				-- 开始新的出分拍卖，使用保存的时间值
			local dkpTimeValue = tonumber(XyTrackerOptions.dkpTime) or 30;
			XYT_StartAuction(item, dkpTimeValue);
			end,
		}
	
		-- ROLL点拍卖 - 仅在团队领袖时显示
		UIDropDownMenu_AddButton {
			text = "ROLL点拍卖",
		value = "ROLLLIST",
		hasArrow = 1,
		func = function()
			CloseDropDownMenus(2);
				-- 获取当前物品
				local item = XYT_GetCurrentLootItem();
				
				-- 检查是否有正在进行的ROLL点拍卖
			if XYT_IsRecordingRoll then
				DEFAULT_CHAT_FRAME:AddMessage("ROLL点拍卖已经在进行");
				-- 显示窗口，这样用户关闭后可以重新打开
				if getglobal("RollMonitorFrame") then
					getglobal("RollMonitorFrame"):Show();
				end
				return;
			end
				
				-- 开始新的ROLL点记录，设置计时器
				XYT_CurrentItem = item;
				XYT_Roll_Scores = {};
				XYT_Roll_Wishes = {};
				XYT_IsRecordingRoll = true;
				-- 使用保存的rollTime设置，如果没有则默认30秒
				local timeValue = tonumber(XyTrackerOptions.rollTime) or 30;
				XYT_Roll_EndTime = GetTime() + timeValue;
				
				-- 确保ROLL点监控窗口显示
				getglobal("RollMonitorFrameTitle"):SetText("ROLL点监控:"..item);
				getglobal("RollMonitorFrame"):Show();
				
				-- 确保有OnUpdate脚本用于动态更新剩余时间
				local rollFrame = getglobal("RollMonitorFrame");
				if rollFrame and not rollFrame:GetScript("OnUpdate") then
					rollFrame:SetScript("OnUpdate", function()
						if XYT_IsRecordingRoll then
							XYT_UpdateRollDisplay();
						end
					end);
				end
				
				-- 使用保存的rollTime设置，如果没有则默认30秒
				local timeValue = tonumber(XyTrackerOptions.rollTime) or 30;
				if getglobal("xytRollTime2") then
					getglobal("xytRollTime2"):SetText(tostring(timeValue));
				end
				
				-- 发送ROLL点开始消息
				SendChatMessage("开始ROLL点拍卖：" .. (item or "未知物品") .. "，请ROLL点，时间" .. timeValue .. "秒", "RAID");
				
				-- 启动倒计时
				XYT_StartRollTimer();
				
				-- DEFAULT_CHAT_FRAME:AddMessage("ROLL点拍卖已开始：" .. item);
			end,
		}
		end
		-- 显示许愿人数和玩家剩余分数
		local wishPlayers = XYT_GetWishPlayers();
		if table.getn(wishPlayers) > 0 then
			-- 添加分隔线
			UIDropDownMenu_AddButton {};
			
			-- 显示许愿人数
			UIDropDownMenu_AddButton {
				text = "【" .. table.getn(wishPlayers) .. "人许愿】",
				notCheckable = 1,
				isTitle = 1,
			}
			
			-- 显示所有许愿玩家（带职业染色）
			for i = 1, table.getn(wishPlayers) do
				local player = wishPlayers[i];
				local classColor = XYT_GetClassColor(player.class);
				local coloredName = player.name;
				if classColor then
					coloredName = classColor .. player.name .. "\124r";
				end
				
				-- 尝试找到玩家的索引（如果在团队中）
				local playerIndex = nil;
				for j = 1, 40 do
					if (GetMasterLootCandidate(j) == player.name) then
						playerIndex = j;
						break;
					end
				end
				
				-- 添加许愿玩家按钮，带鼠标悬停提示
				UIDropDownMenu_AddButton {
					text = "【" .. player.score .. "分】" .. coloredName,
					value = playerIndex,
					notCheckable = 0,
					func = function()
							if this.value and tonumber(this.value) and tonumber(this.value) > 0 then
								-- 直接分配物品给该玩家
								XYT_GiveItTo({value = this.value});
							else
								DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 无法分配物品：玩家" .. player.name .. "不在拾取候选人列表中");
							end
						end,
	
					onLeave = function()
						GameTooltip:Hide();
					end
				}
			end
		end
		
	elseif UIDROPDOWNMENU_MENU_LEVEL == 2 then
		-- 第二层菜单处理
		

		
		-- 指定拾取菜单：显示许愿地板玩家 + 9职业分类
		if (UIDROPDOWNMENU_MENU_VALUE == "QUICKLOOT") then
			-- 首先显示许愿地板玩家（如果有）
				local wishPlayers = XYT_GetWishPlayers(true); -- 只获取许愿"地板"的玩家
			local hasWishPlayers = false;
			
			for i = 1, table.getn(wishPlayers) do
					local player = wishPlayers[i];
					-- 显示符合当前模式匹配的许愿玩家
					hasWishPlayers = true;
					local classColor = XYT_GetClassColor(player.class);
				local coloredName = player.name;
				if classColor then
					coloredName = classColor .. player.name .. "\124r";
				end
				
				-- 尝试找到玩家的索引（如果在团队中）
				local playerIndex = nil;
				for j = 1, 40 do
					if (GetMasterLootCandidate(j) == player.name) then
						playerIndex = j;
						break;
					end
				end
				
				-- 准备显示文本：显示玩家的实际许愿内容
						local displayText = coloredName;
						-- 如果有许愿内容，并且不是空的，添加到显示文本中
						if player.wishContent and player.wishContent ~= "" then
							-- 清理许愿内容，移除多余空格
							local cleanWishContent = string.gsub(string.gsub(player.wishContent, "^%s+", ""), "%s+$", "");
							-- 如果许愿内容不是数字（避免显示分数），则添加到显示文本
							if cleanWishContent ~= tostring(player.score) then
								displayText = displayText .. " ：" .. cleanWishContent;
							end
						end
						
						-- 如果找到索引，正常分配；否则设置为0作为特殊标记
						UIDropDownMenu_AddButton({
							text = displayText,
							value = playerIndex or 0,
							notCheckable = 1,
							func = function()
								if this.value and tonumber(this.value) and tonumber(this.value) > 0 then
									-- 找到索引的情况
									CML_Vars.Quickloot = player.name;
									XYT_GiveItTo(this);
								else
									-- 没找到索引的情况，至少可以设置为快速拾取人
									CML_Vars.Quickloot = player.name;
									DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] " .. player.name .. " 已设置为快速拾取人，但当前不在拾取候选人列表中");
								end
								-- 立即刷新拾取菜单，显示当前选定的玩家
								CloseDropDownMenus();
								-- 强制重新初始化菜单
								UIDropDownMenu_Initialize(GroupLootDropDown, XYT_InitDropDown, "MENU");
								ToggleDropDownMenu(1, nil, GroupLootDropDown, "cursor", 0, 0, nil, nil, 1);
							end,
			
		
							onLeave = function()
								GameTooltip:Hide();
							end
						}, UIDROPDOWNMENU_MENU_LEVEL);
			end
			
			
			-- 如果没有许愿地板玩家，添加一个提示
			if not hasWishPlayers then
				UIDropDownMenu_AddButton({
					text = "暂无许愿地板玩家",
					notCheckable = 1,
					isTitle = 1,
				}, UIDROPDOWNMENU_MENU_LEVEL);
			else
				-- 添加分隔线
				UIDropDownMenu_AddButton({}, UIDROPDOWNMENU_MENU_LEVEL);
			end
			
			-- 然后显示9职业带染色
			local allClasses = {"战士", "圣骑士", "猎人", "盗贼", "牧师", "萨满祭司", "法师", "术士", "德鲁伊"};
			for _, class in ipairs(allClasses) do
				local classColor = XYT_GetClassColor(class);
				local coloredClass = class;
				if classColor then
					coloredClass = classColor .. class .. "\124r";
				end
				
				-- 为指定拾取下的职业添加鼠标悬停提示，显示该职业的所有角色名
				local menuLevel = UIDROPDOWNMENU_MENU_LEVEL;
				
				-- 先创建按钮
										UIDropDownMenu_AddButton({
						text = coloredClass,
						value = class,
						hasArrow = 1,
						notCheckable = 1,
						-- 保留func以便点击时也能工作
						func = function()
												-- 调试输出
												DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 打开指定拾取职业子菜单: " .. this.value);
												
												-- 关闭当前层级以上的菜单
												CloseDropDownMenus(UIDROPDOWNMENU_MENU_LEVEL);
												-- 打开下一层级的菜单，层级设置为2
												ToggleDropDownMenu(1, this.value, GroupLootDropDown, this:GetName(), 10, 0, nil, nil, 2);
												-- 确保子菜单获得焦点
												local subMenuFrame = getglobal("DropDownList"..(UIDROPDOWNMENU_MENU_LEVEL+1));
												if subMenuFrame then
													subMenuFrame:SetFrameStrata("HIGH");
													subMenuFrame:SetFrameLevel(100);
												end
						end,
					-- 移除自动悬停触发子菜单，避免菜单堆叠时的冲突
					OnEnter = function()
						-- 只显示工具提示，不自动打开子菜单
						local roleNames = "";
						local memberCount = GetNumRaidMembers();
						if memberCount > 0 then
							-- 团队状态
							for i = 1, memberCount do
								local name, _, _, _, unitClass = GetRaidRosterInfo(i);
								if name and unitClass == class then
									if roleNames ~= "" then
										roleNames = roleNames .. ", ";
									end
									roleNames = roleNames .. name;
								end
							end
						else
							-- 小队状态
							local partyCount = GetNumPartyMembers();
							for i = 1, partyCount do
								local name = UnitName("party" .. i);
								local unitClass = UnitClass("party" .. i);
								if name and unitClass == class then
									if roleNames ~= "" then
										roleNames = roleNames .. ", ";
									end
									roleNames = roleNames .. name;
								end
							end
							-- 检查玩家自己
							local playerName = UnitName("player");
							local playerClass = UnitClass("player");
							if playerClass == class then
								if roleNames ~= "" then
									roleNames = roleNames .. ", ";
								end
								roleNames = roleNames .. playerName;
							end
						end
						if roleNames ~= "" then
							GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
							GameTooltip:SetText(class .. "角色：" .. roleNames);
							GameTooltip:Show();
						end
					end
					}, menuLevel);
				
				-- 获取当前按钮索引（从1开始）
				local buttonCount = 0;
				for i = 1, 12 do
					local button = getglobal("DropDownList"..menuLevel.."Button"..i);
					if button and button:IsVisible() then
						buttonCount = i;
					end
				end
				
				-- 如果找到可见按钮，设置其OnEnter和OnLeave脚本
				if buttonCount > 0 then
					local targetButton = getglobal("DropDownList"..menuLevel.."Button"..buttonCount);
					if targetButton then
						-- 使用闭包保存class信息
								targetButton:SetScript("OnEnter", function()

									local roleNames = "";
							local memberCount = GetNumRaidMembers();
							if memberCount > 0 then
								-- 团队状态
								for i = 1, memberCount do
									local name, _, _, _, unitClass = GetRaidRosterInfo(i);
									if name and unitClass then
										if unitClass == class then
											if roleNames ~= "" then
												roleNames = roleNames .. ", ";
											end
											roleNames = roleNames .. name;
										end
									end
								end
							else
								-- 小队状态
								local partyCount = GetNumPartyMembers();
								for i = 1, partyCount do
									local name = UnitName("party" .. i);
									local unitClass = UnitClass("party" .. i);
									if name and unitClass then
										if unitClass == class then
											if roleNames ~= "" then
												roleNames = roleNames .. ", ";
											end
											roleNames = roleNames .. name;
										end
									end
								end
								-- 检查玩家自己
								local playerName = UnitName("player");
								local playerClass = UnitClass("player");
								if playerClass == class then
									if roleNames ~= "" then
										roleNames = roleNames .. ", ";
									end
									roleNames = roleNames .. playerName;
								end
							end
									if roleNames ~= "" then
		
										GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
										GameTooltip:SetText(class .. "角色：" .. roleNames);
										GameTooltip:Show();
									else
		
									end
								end);
						targetButton:SetScript("OnLeave", function()
							GameTooltip:Hide();
						end);
					end
				end
			end
			-- 获取正确的菜单值
			local menuValue = UIDROPDOWNMENU_MENU_VALUE;
			-- 在魔兽世界1.12中，值可能通过this参数传递
			if not menuValue and this and this.value then
				menuValue = this.value;
				
            end
			-- 职业菜单（三级菜单） - 修改为直接显示玩家列表
			elseif (menuValue and string.sub(menuValue, 1, 13) == "CLASS_PLAYERS_") then
				local targetClass = string.sub(menuValue, 14);
				local hasPlayers = false;
				
				-- 标准化目标职业名称
				local normalizedTargetClass = XyTracker_GetNormalizedClassName(targetClass);
				
				-- 根据团队/小队状态获取成员列表
				local memberCount = GetNumRaidMembers();
				if memberCount > 0 then
					-- 团队状态：使用GetRaidRosterInfo
					for i = 1, memberCount do
					local name, _, _, _, unitClass = GetRaidRosterInfo(i);
					
					-- 标准化职业名称
					local normalizedUnitClass = XyTracker_GetNormalizedClassName(unitClass);
					
					if name and normalizedUnitClass then
						if normalizedUnitClass == normalizedTargetClass then
							hasPlayers = true;
							local classColor = XYT_GetClassColor(normalizedUnitClass);
							local coloredName = name;
							if classColor then
								coloredName = classColor .. name .. "\124r";
							end
								
							UIDropDownMenu_AddButton({
							text = coloredName,
							value = name,
							notCheckable = 1,
							func = function()
									-- 只分配物品，不修改指定拾取设置
									XYT_GiveItTo(this);
										-- 立即刷新拾取菜单，显示当前选定的玩家
										CloseDropDownMenus();
										-- 强制重新初始化菜单
										UIDropDownMenu_Initialize(GroupLootDropDown, XYT_InitDropDown, "MENU");
										ToggleDropDownMenu(1, nil, GroupLootDropDown, "cursor", 0, 0, nil, nil, 1);
				end,
								-- 添加鼠标悬停提示
			
								onLeave = function()
									GameTooltip:Hide();
								end
							}, UIDROPDOWNMENU_MENU_LEVEL);
						end
					end
				end
				else
					-- 小队状态：使用UnitName和UnitClass
					local partyCount = GetNumPartyMembers();
					for i = 1, partyCount do
						local name = UnitName("party" .. i);
						local unitClass = UnitClass("party" .. i);
						
						if name and unitClass then
							local normalizedUnitClass = XyTracker_GetNormalizedClassName(unitClass);
							if normalizedUnitClass == normalizedTargetClass then
								hasPlayers = true;
								local classColor = XYT_GetClassColor(normalizedUnitClass);
								local coloredName = name;
								if classColor then
									coloredName = classColor .. name .. "\124r";
								end
									
								UIDropDownMenu_AddButton({
								text = coloredName,
								value = name,
								notCheckable = 1,
								func = function()
										-- 只分配物品，不修改指定拾取设置
										XYT_GiveItTo(this);
											-- 立即刷新拾取菜单，显示当前选定的玩家
											CloseDropDownMenus();
											-- 强制重新初始化菜单
											UIDropDownMenu_Initialize(GroupLootDropDown, XYT_InitDropDown, "MENU");
											ToggleDropDownMenu(1, nil, GroupLootDropDown, "cursor", 0, 0, nil, nil, 1);
						end,
									-- 添加鼠标悬停提示
					
								onLeave = function()
									GameTooltip:Hide();
								end
								}, UIDROPDOWNMENU_MENU_LEVEL);
							end
						end
					end
					
					-- 检查玩家自己
					local playerName = UnitName("player");
					local playerClass = UnitClass("player");
					if playerName and playerClass then
						local normalizedPlayerClass = XyTracker_GetNormalizedClassName(playerClass);
						if normalizedPlayerClass == normalizedTargetClass then
							hasPlayers = true;
							local classColor = XYT_GetClassColor(normalizedPlayerClass);
							local coloredName = playerName;
							if classColor then
								coloredName = classColor .. playerName .. "\124r";
							end
								
							UIDropDownMenu_AddButton({
							text = coloredName,
							value = playerName,
							notCheckable = 1,
							func = function()
									-- 只分配物品，不修改指定拾取设置
									XYT_GiveItTo(this);
										-- 立即刷新拾取菜单，显示当前选定的玩家
											CloseDropDownMenus();
											-- 强制重新初始化菜单
											UIDropDownMenu_Initialize(GroupLootDropDown, XYT_InitDropDown, "MENU");
											ToggleDropDownMenu(1, nil, GroupLootDropDown, "cursor", 0, 0, nil, nil, 1);
						end,
									-- 添加鼠标悬停提示
					
								onLeave = function()
									GameTooltip:Hide();
								end
							}, UIDROPDOWNMENU_MENU_LEVEL);
						end
					end
				end
				
				-- 如果没有该职业的玩家，显示提示
				if not hasPlayers then
					UIDropDownMenu_AddButton({
						text = "该职业暂无可拾取的玩家",
						notCheckable = 1,
						isTitle = 1
					}, UIDROPDOWNMENU_MENU_LEVEL);
				end
			-- 显示指定职业的可拾取玩家
			elseif (menuValue and string.sub(menuValue, 1, 13) == "CLASS_LOOTERS_") then
				local targetClass = string.sub(menuValue, 14);
				local hasPlayers = false;
				
				-- 添加该职业的所有可拾取玩家
				for i = 1, 40 do
					local candidate = GetMasterLootCandidate(i);
					if candidate then
						local id = XYT_GetIDbyName(candidate);
						if id then
							local unitClass = UnitClass(id);
							if unitClass then
								if unitClass == targetClass then
									hasPlayers = true;
									local classColor = XYT_GetClassColor(unitClass);
									local coloredName = candidate;
									if classColor then
										coloredName = classColor .. candidate .. "\124r";
									end
									
									UIDropDownMenu_AddButton({
										text = coloredName,
										value = candidate,
										notCheckable = 1,
										func = function()
											for j = 1, 40 do
												if GetMasterLootCandidate(j) == this.value then
													GiveMasterLootItem(GetLootSlotIndex(GetMouseFocus():GetID()), j);
												CloseDropDownMenus();
												return;
											end
										end
									end,
									-- 添加鼠标悬停提示
							
									onLeave = function()
										GameTooltip:Hide();
									end
									}, UIDROPDOWNMENU_MENU_LEVEL);
								end
							end
						end
					end
				end
				
				-- 如果没有该职业的可拾取玩家，显示提示
				if not hasPlayers then
					UIDropDownMenu_AddButton({
						text = targetClass .. "职业暂无可拾取玩家",
						notCheckable = 1,
						isTitle = 1
					}, UIDROPDOWNMENU_MENU_LEVEL);
				end
			

			-- 职业分类列表
		elseif (UIDROPDOWNMENU_MENU_VALUE == "CLASSLIST") then
			-- 显示所有有拾取权限的职业（带染色）
			local raidmembers = {};
			
			-- 收集所有职业信息（支持团队和小队）
			local memberCount = GetNumRaidMembers();
			if memberCount > 0 then
				-- 团队状态
				for i = 1, 40 do
					local candidate = GetMasterLootCandidate(i);
					if (candidate) then
						local id = XYT_GetIDbyName(candidate);
						if (id) then
							local classx = UnitClass(id);
							if (classx) then
								local normalizedClass = XyTracker_GetNormalizedClassName(classx);
								if normalizedClass then
									raidmembers[normalizedClass] = true;
								end
							end
						end
					end
				end
			else
				-- 小队状态
				local partyCount = GetNumPartyMembers();
				for i = 1, partyCount do
					local name = UnitName("party" .. i);
					local unitClass = UnitClass("party" .. i);
					if name and unitClass then
						local normalizedClass = XyTracker_GetNormalizedClassName(unitClass);
						if normalizedClass then
							raidmembers[normalizedClass] = true;
						end
					end
				end
				-- 检查玩家自己
				local playerName = UnitName("player");
				local playerClass = UnitClass("player");
				if playerName and playerClass then
					local normalizedPlayerClass = XyTracker_GetNormalizedClassName(playerClass);
					if normalizedPlayerClass then
						raidmembers[normalizedPlayerClass] = true;
					end
				end
			end
			
			-- 按职业排序并添加到菜单
			local classes = {}
			for class in pairs(raidmembers) do
				table.insert(classes, class);
			end
			table.sort(classes)
			
			for i = 1, table.getn(classes) do
					local class = classes[i];
					local classColor = XYT_GetClassColor(class);
					local coloredClass = class;
					if classColor then
						coloredClass = classColor .. class .. "\124r";
					end
					
					-- 完全照搬ClassMasterLoot的实现方式
					UIDropDownMenu_AddButton({
							text = coloredClass,
							value = "CLASS_" .. class, -- 使用固定格式的value
							hasArrow = 1,
							notCheckable = 1,

							onLeave = function()
								GameTooltip:Hide();
							end
						}, UIDROPDOWNMENU_MENU_LEVEL);
				

			end
		-- 出分拍卖列表（显示当前出分情况）
		elseif (UIDROPDOWNMENU_MENU_VALUE == "AUCTIONLIST") then
			-- 显示当前出分拍卖的玩家分数（最多5条）
			-- 修改：倒计时结束后也显示数据，不检查XYT_Auction_IsActive状态
			if XYT_Auction_Scores then
				-- 对分数进行排序
				local sortedScores = {};
				for name, score in pairs(XYT_Auction_Scores) do
					table.insert(sortedScores, {name = name, score = score});
				end
				table.sort(sortedScores, function(a, b) return a.score > b.score end);
				
				-- 显示前5名
				for i = 1, math.min(5, table.getn(sortedScores)) do
					local entry = sortedScores[i];
					local playerInfo = getXyInfo(entry.name);
					local class = playerInfo and playerInfo["class"] or "未知";
					local wish = playerInfo and playerInfo["xy"] or "";
					local dkp = playerInfo and playerInfo["dkp"] or DefaultDKP;
					local classColor = XYT_GetClassColor(class);
					local coloredName = entry.name;
					if classColor then
						coloredName = classColor .. entry.name .. "\124r";
					end
					
					-- 尝试找到玩家的索引（如果在拾取候选人中）
					local playerIndex = nil;
					for j = 1, 40 do
						if (GetMasterLootCandidate(j) == entry.name) then
							playerIndex = j;
							break;
						end
					end
					
					UIDropDownMenu_AddButton({
						text = entry.score .. "--" .. coloredName .. "[" .. dkp .. "分]" .. (wish and wish ~= "" and " 许愿" .. wish  or ""),
						value = playerIndex or 0,
						notCheckable = 1,
						func = function()
							-- 如果玩家在拾取列表中，直接分配物品
							if this.value and tonumber(this.value) and tonumber(this.value) > 0 then
								XYT_GiveItTo(this, "AUCTIONLIST");
								-- 结束出分拍卖
								XYT_EndAuction();
							else
								DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 无法分配物品：玩家" .. entry.name .. "不在拾取候选人列表中");
							end
						end,
	
						onLeave = function()
							GameTooltip:Hide();
						end
					}, UIDROPDOWNMENU_MENU_LEVEL);
				end
				
				-- 如果出分玩家少于5个，显示提示
				if table.getn(sortedScores) == 0 then
					UIDropDownMenu_AddButton({
						text = "暂无出分记录",
						notCheckable = 1,
						disabled = 1,
					}, UIDROPDOWNMENU_MENU_LEVEL);
				end
			else
				UIDropDownMenu_AddButton({
					text = "出分拍卖未开始",
					notCheckable = 1,
				}, UIDROPDOWNMENU_MENU_LEVEL);
			end
		-- ROLL点列表（显示ROLL点最高的五个人）
		elseif (UIDROPDOWNMENU_MENU_VALUE == "ROLLLIST") then
			-- 检查是否有ROLL点记录 - 检查所有可能的数据源
			local hasRollRecords = false;
			
			-- 检查XYT_Roll_Scores
			if XYT_Roll_Scores and next(XYT_Roll_Scores) then
				hasRollRecords = true;
			-- 检查CML_Vars.Rolls
			elseif CML_Vars and CML_Vars.Rolls and next(CML_Vars.Rolls) then
				hasRollRecords = true;
			-- 检查rollData（这是实际存储ROLL点记录的地方）
			elseif rollData and table.getn(rollData) > 0 then
				hasRollRecords = true;
			end
			
			-- 如果没有ROLL点记录，显示提示信息
			if not hasRollRecords then
				UIDropDownMenu_AddButton({
					text = "暂无ROLL点记录",
					notCheckable = 1,
					disabled = 1,
				}, UIDROPDOWNMENU_MENU_LEVEL);
			else
				-- 有ROLL点记录，显示ROLL点结果
				-- 获取ROLL点记录，优先使用rollData，其次使用XYT_Roll_Scores，最后使用CML_Vars.Rolls
				local uniqueRolls = {};
				
				-- 优先使用rollData
				if rollData and table.getn(rollData) > 0 then
					for i = 1, table.getn(rollData) do
						if rollData[i] and rollData[i]["name"] and rollData[i]["roll"] then
							-- 获取玩家信息，确保dkp和wish值正确
							local playerInfo = getXyInfo(rollData[i]["name"]);
							local dkpValue = rollData[i]["dkp"];
							if not dkpValue or dkpValue == "" then
								dkpValue = playerInfo and playerInfo["dkp"] or DefaultDKP;
							end
							dkpValue = tonumber(dkpValue) or tonumber(DefaultDKP) or 0;
							
							-- 从playerInfo获取dkp、xy和class信息
								local playerInfo = getXyInfo(rollData[i]["name"]);
								local classValue = playerInfo and playerInfo["class"] or "未知";
								local xyValue = playerInfo and playerInfo["xy"] or "";
								
								-- 重新获取dkp值，确保使用最新的playerInfo
								local dkpValue = playerInfo and playerInfo["dkp"] or DefaultDKP;
								dkpValue = tonumber(dkpValue) or tonumber(DefaultDKP) or 0;
								
								-- 优先使用XYT_Roll_Wishes中的许愿内容，如果没有则使用playerInfo中的xy值
								local wishValue = "";
								if XYT_Roll_Wishes and XYT_Roll_Wishes[rollData[i]["name"]] then
									wishValue = XYT_Roll_Wishes[rollData[i]["name"]];
								elseif xyValue and xyValue ~= "" and xyValue ~= "---未许愿---" then
									wishValue = xyValue;
								end
							
							table.insert(uniqueRolls, {
								name = rollData[i]["name"],
								roll = tonumber(rollData[i]["roll"]) or 0,
								class = classValue,
								dkp = dkpValue,
								wish = wishValue
							});
						end
					end
				-- 其次使用XYT_Roll_Scores
				elseif XYT_Roll_Scores and next(XYT_Roll_Scores) then
					uniqueRolls = XYT_GetUniqueRolls(10);
				-- 最后使用CML_Vars.Rolls
				elseif CML_Vars and CML_Vars.Rolls and next(CML_Vars.Rolls) then
					uniqueRolls = XYT_GetUniqueRolls(10);
				end
				
				-- 按ROLL点从高到低排序
				table.sort(uniqueRolls, function(a, b)
					return a.roll > b.roll;
				end);
				
				if table.getn(uniqueRolls) > 0 then
					-- 只显示前5条最高的ROLL点记录
					local maxDisplay = math.min(5, table.getn(uniqueRolls));
					for i = 1, maxDisplay do
						local rollInfo = uniqueRolls[i];
						local classColor = XYT_GetClassColor(rollInfo.class);
						local coloredName = rollInfo.name;
						if classColor then
							coloredName = classColor .. rollInfo.name .. "\124r";
						end
						
						-- 与出分拍卖一致的格式：ROLL点--角色名[分数]许愿道具链接（职业信息并入许愿）
			local displayText = rollInfo.roll .. "--" .. coloredName .. "[" .. (rollInfo.dkp or 0) .. "分]" .. (rollInfo.wish and rollInfo.wish ~= "" and rollInfo.wish ~= "---未许愿---" and " 许愿" .. rollInfo.wish or "");
					
					-- 尝试找到玩家的索引（如果在拾取候选人中）
					local playerIndex = nil;
					for j = 1, 40 do
						if (GetMasterLootCandidate(j) == rollInfo.name) then
							playerIndex = j;
							break;
						end     
					end
					
					-- 为第一名添加特殊标记
					if i == 1 then
						displayText = "\124cFF00FF00[获胜]\124r " .. displayText;
					end
					
					UIDropDownMenu_AddButton({
						text = displayText,
						value = playerIndex or 0,
						notCheckable = 1,
						func = function()
								if this.value and tonumber(this.value) and tonumber(this.value) > 0 then
									-- 直接分配物品给该玩家
									XYT_GiveItTo(this, "ROLLLIST");
								else
									DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 无法分配物品：玩家" .. rollInfo.name .. "不在拾取候选人列表中");
								end
							end,
	
						onLeave = function()
							GameTooltip:Hide();
						end
					}, UIDROPDOWNMENU_MENU_LEVEL);
					end
				else
					UIDropDownMenu_AddButton({
						text = "暂无ROLL点记录",
						notCheckable = 1,
					}, UIDROPDOWNMENU_MENU_LEVEL);
				end
			end
		-- 职业玩家列表（处理职业分类）
		elseif (strfind(UIDROPDOWNMENU_MENU_VALUE, "CLASS_") == 1) then
			local targetClass = strsub(UIDROPDOWNMENU_MENU_VALUE, 7); -- 移除CLASS_前缀
			local hasPlayers = false;
			

			
			-- 显示所有团队成员中对应职业的玩家，不验证任何条件
			for i = 1, GetNumRaidMembers() do
				local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(i);
				if name and class == targetClass then
					hasPlayers = true;
					local classColor = XYT_GetClassColor(targetClass);
					local coloredName = name;
					if classColor then
						coloredName = classColor .. name .. "\124r";
					end
					
					-- 尝试找到玩家的索引（如果在拾取候选人中）
					local playerIndex = nil;
					for j = 1, 40 do
						if (GetMasterLootCandidate(j) == name) then
							playerIndex = j;
							break;
						end
					end
					
					UIDropDownMenu_AddButton({
						text = coloredName,
						value = playerIndex or 0,
						notCheckable = 1,
						func = function()
							-- 设置为快速拾取人并分配物品
							CML_Vars.Quickloot = name;
							if this.value and tonumber(this.value) and tonumber(this.value) > 0 then
								XYT_GiveItTo(this);
							else
								DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] " .. name .. " 已设置为快速拾取人，但当前不在拾取候选人列表中");
								XyTracker_UpdateLootList();
							end
						end,
					}, UIDROPDOWNMENU_MENU_LEVEL);
				end
			end
			
			-- 只显示团队成员，不验证拾取权限
			

			
			-- 如果该职业没有可拾取的玩家，添加提示
			if not hasPlayers then
				UIDropDownMenu_AddButton({
					text = "该职业暂无可拾取的玩家",
					notCheckable = 1,
				}, UIDROPDOWNMENU_MENU_LEVEL);
			end
			

		end
		
	elseif UIDROPDOWNMENU_MENU_LEVEL == 3 then
		-- 第三层菜单处理
		
		
		-- 处理指定拾取下的职业子菜单 - 显示该职业的所有角色
		if UIDROPDOWNMENU_MENU_VALUE and type(UIDROPDOWNMENU_MENU_VALUE) == "string" then
			local targetClass = UIDROPDOWNMENU_MENU_VALUE;
			local hasPlayers = false;
			
			-- 检查是否是职业分配下的CLASS_前缀
			local isClassLooters = false;
			if (strfind(targetClass, "CLASS_") == 1) then
				targetClass = strsub(targetClass, 7); -- 移除CLASS_前缀
				isClassLooters = true; -- 标记这是职业分配菜单
			end
			

			
			if isClassLooters then
				-- 职业分配菜单：只显示有拾取权限的玩家
				for i = 1, 40 do
					local candidate = GetMasterLootCandidate(i);
					if (candidate) then
						local playerClass = nil;
						local id = XYT_GetIDbyName(candidate);
						
						-- 尝试通过UnitClass获取职业
						if (id) then
							playerClass = UnitClass(id);
						end
						
						-- 如果UnitClass失败，从XyArray中查找
						if not playerClass and XyArray and type(XyArray) == "table" then
							for _, info in ipairs(XyArray) do
								if info and info["name"] == candidate and info["class"] then
									playerClass = info["class"];
									break;
								end
							end
						end
						
						-- 如果找到匹配的职业，添加到菜单
						if (playerClass == targetClass) then
							hasPlayers = true;
							local classColor = XYT_GetClassColor(targetClass);
							local coloredName = candidate;
							if classColor then
								coloredName = classColor .. candidate .. "\124r";
							end
							
							UIDropDownMenu_AddButton({
									text = coloredName,
									value = i,
									notCheckable = 1,
									func = function()
									-- 职业分配：直接分配物品，不设置快速拾取人
									XYT_GiveItTo(this);
									-- 记录分配成功的消息
									DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 物品已分配给 " .. candidate);
									-- 关闭菜单
									CloseDropDownMenus();
							end,
									onLeave = function()
										GameTooltip:Hide();
									end
							}, UIDROPDOWNMENU_MENU_LEVEL);
						end
					end
				end
			else
				-- 指定拾取菜单：根据团队/小队状态显示该职业的所有成员
				local memberCount = GetNumRaidMembers();
				if memberCount > 0 then
					-- 团队状态：使用GetRaidRosterInfo
					for i = 1, memberCount do
						local name, _, _, _, unitClass = GetRaidRosterInfo(i);
						
						-- 标准化职业名称
						local normalizedUnitClass = XyTracker_GetNormalizedClassName(unitClass);
						local normalizedTargetClass = XyTracker_GetNormalizedClassName(targetClass);
						
						if name and normalizedUnitClass and normalizedUnitClass == normalizedTargetClass then
							hasPlayers = true;
							local classColor = XYT_GetClassColor(normalizedUnitClass);
							local coloredName = name;
							if classColor then
								coloredName = classColor .. name .. "\124r";
							end
							
							UIDropDownMenu_AddButton({
								text = coloredName,
								value = name,
								notCheckable = 1,
								func = function()
											-- 设置为快速拾取人
											CML_Vars.Quickloot = name;
											-- 记录设置成功的消息
											DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] " .. name .. " 已设置为快速拾取人");
											-- 关闭菜单
											CloseDropDownMenus();
											-- 立即刷新主菜单，显示当前选定的玩家
											if GroupLootDropDown and XYT_InitDropDown then
												UIDropDownMenu_Initialize(GroupLootDropDown, XYT_InitDropDown, "MENU");
											end
								end,

								onLeave = function()
									GameTooltip:Hide();
								end
							}, UIDROPDOWNMENU_MENU_LEVEL);
						end
					end
				else
					-- 小队状态：使用UnitName和UnitClass
					local partyCount = GetNumPartyMembers();
					for i = 1, partyCount do
						local name = UnitName("party" .. i);
						local unitClass = UnitClass("party" .. i);
						
						if name and unitClass then
							local normalizedUnitClass = XyTracker_GetNormalizedClassName(unitClass);
							local normalizedTargetClass = XyTracker_GetNormalizedClassName(targetClass);
							
							if normalizedUnitClass and normalizedUnitClass == normalizedTargetClass then
								hasPlayers = true;
								local classColor = XYT_GetClassColor(normalizedUnitClass);
								local coloredName = name;
								if classColor then
									coloredName = classColor .. name .. "\124r";
								end
								
								UIDropDownMenu_AddButton({
									text = coloredName,
									value = name,
									notCheckable = 1,
									func = function()
												-- 设置为快速拾取人
												CML_Vars.Quickloot = name;
												-- 记录设置成功的消息
												DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] " .. name .. " 已设置为快速拾取人");
												-- 关闭菜单
												CloseDropDownMenus();
												-- 立即刷新主菜单，显示当前选定的玩家
												if GroupLootDropDown and XYT_InitDropDown then
													UIDropDownMenu_Initialize(GroupLootDropDown, XYT_InitDropDown, "MENU");
												end
									end,

									onLeave = function()
										GameTooltip:Hide();
									end
								}, UIDROPDOWNMENU_MENU_LEVEL);
							end
						end
					end
					
					-- 检查玩家自己
					local playerName = UnitName("player");
					local playerClass = UnitClass("player");
					if playerName and playerClass then
						local normalizedPlayerClass = XyTracker_GetNormalizedClassName(playerClass);
						local normalizedTargetClass = XyTracker_GetNormalizedClassName(targetClass);
						
						if normalizedPlayerClass and normalizedPlayerClass == normalizedTargetClass then
							hasPlayers = true;
							local classColor = XYT_GetClassColor(normalizedPlayerClass);
							local coloredName = playerName;
							if classColor then
								coloredName = classColor .. playerName .. "\124r";
							end
							
							UIDropDownMenu_AddButton({
								text = coloredName,
								value = playerName,
								notCheckable = 1,
								func = function()
											-- 设置为快速拾取人
											CML_Vars.Quickloot = playerName;
											-- 记录设置成功的消息
											DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] " .. playerName .. " 已设置为快速拾取人");
											-- 关闭菜单
											CloseDropDownMenus();
											-- 立即刷新主菜单，显示当前选定的玩家
											if GroupLootDropDown and XYT_InitDropDown then
												UIDropDownMenu_Initialize(GroupLootDropDown, XYT_InitDropDown, "MENU");
											end
								end,

							onLeave = function()
									GameTooltip:Hide();
								end
							}, UIDROPDOWNMENU_MENU_LEVEL);
						end
					end
				end
			end
			
			-- 如果该职业没有玩家，添加提示
			if not hasPlayers then
				local tipText;
				if isClassLooters then
					tipText = "该职业暂无可拾取的玩家";
				else
					tipText = "该职业暂无团队成员";
				end
				
				UIDropDownMenu_AddButton({
					text = tipText,
					notCheckable = 1,
					disabled = 1,
				}, UIDROPDOWNMENU_MENU_LEVEL);
			end
		end
	end
end

-- 获取最高出分的玩家（单人只选最高）
function XYT_GetHighestDKPScores(limit)
	local scores = {};
	local nameMap = {};
	
	-- 使用XyArray中的数据而不是xytDKPData
	if XyArray and type(XyArray) == "table" then
		for i = 1, table.getn(XyArray) do
			local playerData = XyArray[i];
			if playerData and playerData.name and playerData.dkp then
				local name = playerData.name;
				local score = tonumber(playerData.dkp) or 0;
				if not nameMap[name] or score > nameMap[name] then
					nameMap[name] = score;
				end
			end
		end
	end
	
	-- 转换为数组并排序
	for name, score in pairs(nameMap) do
		local id = XYT_GetIDbyName(name);
		local class = "未知";
		if id then
			class = UnitClass(id) or "未知";
		end
		table.insert(scores, {name = name, score = score, class = class});
	end
	
	-- 按分数降序排序
	table.sort(scores, function(a, b) return a.score > b.score; end);
	
	-- 返回前N个
	local result = {};
	for i = 1, math.min(limit, table.getn(scores)) do
		table.insert(result, scores[i]);
	end
	
	return result;
end

-- 获取唯一的ROLL点记录（单人只选第一次）
function XYT_GetUniqueRolls(limit)
	local rolls = {};
	local nameMap = {};
	
	-- 首先检查XYT_Roll_Scores（从之前的函数可以看到这是ROLL点记录的主要存储位置）
	if XYT_Roll_Scores and type(XYT_Roll_Scores) == "table" then
		for name, roll in pairs(XYT_Roll_Scores) do
			if name and roll and not nameMap[name] then
				nameMap[name] = true;
				local id = XYT_GetIDbyName(name);
				local class = "未知";
				if id then
					class = UnitClass(id) or "未知";
				end
				-- 获取玩家信息以获取dkp和许愿内容
				local playerInfo = getXyInfo(name);
				local dkp = playerInfo and playerInfo["dkp"] or DefaultDKP;
				dkp = tonumber(dkp) or tonumber(DefaultDKP) or 0;
				
				-- 获取许愿内容：优先使用XYT_Roll_Wishes，其次使用playerInfo中的xy
				local wish = "";
				if XYT_Roll_Wishes and XYT_Roll_Wishes[name] then
					wish = XYT_Roll_Wishes[name];
				elseif playerInfo and playerInfo["xy"] and playerInfo["xy"] ~= "" and playerInfo["xy"] ~= "---未许愿---" then
					wish = playerInfo["xy"];
				end
				
				-- 确保roll值是数字类型
				local rollValue = tonumber(roll) or 0;
				table.insert(rolls, {name = name, roll = rollValue, class = class, dkp = dkp, wish = wish});
			end
		end
	end
	
	-- 同时检查CML_Vars.Rolls作为备用数据源
	if CML_Vars and CML_Vars.Rolls and type(CML_Vars.Rolls) == "table" then
		local count = table.getn(CML_Vars.Rolls);
		for i = 1, count do
			local rollData = CML_Vars.Rolls[i];
			if rollData and rollData.name and rollData.roll and not nameMap[rollData.name] then
				nameMap[rollData.name] = true;
				local id = XYT_GetIDbyName(rollData.name);
				local class = "未知";
				if id then
					class = UnitClass(id) or "未知";
				end
				-- 获取玩家信息以获取dkp和许愿内容
				local playerInfo = getXyInfo(rollData.name);
				local dkp = playerInfo and playerInfo["dkp"] or DefaultDKP;
				dkp = tonumber(dkp) or tonumber(DefaultDKP) or 0;
				
				-- 获取许愿内容：优先使用XYT_Roll_Wishes，其次使用playerInfo中的xy
				local wish = "";
				if XYT_Roll_Wishes and XYT_Roll_Wishes[rollData.name] then
					wish = XYT_Roll_Wishes[rollData.name];
				elseif playerInfo and playerInfo["xy"] and playerInfo["xy"] ~= "" and playerInfo["xy"] ~= "---未许愿---" then
					wish = playerInfo["xy"];
				end
				
				-- 确保roll值是数字类型
				local rollValue = tonumber(rollData.roll) or 0;
				table.insert(rolls, {name = rollData.name, roll = rollValue, class = class, dkp = dkp, wish = wish});
			end
		end
	end
	
	-- 按ROLL点降序排序
	table.sort(rolls, function(a, b) 
		local rollA = tonumber(a.roll) or 0;
		local rollB = tonumber(b.roll) or 0;
		return rollA > rollB;
	end);
	
	-- 返回前N个
	local result = {};
	local actualLimit = math.min(limit or 5, table.getn(rolls));
	for i = 1, actualLimit do
		table.insert(result, rolls[i]);
	end
	
	return result;
end

-- 获取许愿玩家列表
-- 调试模式开关
local XYT_DebugMode = false;

-- 兼容Lua 5.0的unpack替代函数
function XYT_Unpack(tbl, startIdx, endIdx)
    startIdx = startIdx or 1;
    endIdx = endIdx or table.getn(tbl);
    
    if startIdx > endIdx then
        return;
    end
    
    return tbl[startIdx], XYT_Unpack(tbl, startIdx + 1, endIdx);
end

-- 调试函数：记录API调用和返回值 - 兼容Lua 5.0
function XYT_DebugAPI(apiName, arg1, arg2, arg3, arg4, arg5)
	-- 记录调用参数
	local argsStr = "";
	local hasArgs = false;
	
	-- 手动处理最多5个参数
	if arg1 ~= nil then
		argsStr = argsStr .. tostring(arg1);
		hasArgs = true;
	end
	
	if arg2 ~= nil then
		argsStr = argsStr .. ", " .. tostring(arg2);
		hasArgs = true;
	end
	
	if arg3 ~= nil then
		argsStr = argsStr .. ", " .. tostring(arg3);
		hasArgs = true;
	end
	
	if arg4 ~= nil then
		argsStr = argsStr .. ", " .. tostring(arg4);
		hasArgs = true;
	end
	
	if arg5 ~= nil then
		argsStr = argsStr .. ", " .. tostring(arg5);
		hasArgs = true;
	end
	
	-- 执行原始API调用
	local func = _G[apiName];
	if type(func) ~= "function" then
		-- 返回原始参数
		return arg1, arg2, arg3, arg4, arg5;
	end
	
	-- 获取返回值 - 根据参数数量调用函数
	local ret1, ret2, ret3, ret4, ret5 = nil, nil, nil, nil, nil;
	
	if arg1 == nil then
		ret1, ret2, ret3, ret4, ret5 = func();
	elseif arg2 == nil then
		ret1, ret2, ret3, ret4, ret5 = func(arg1);
	elseif arg3 == nil then
		ret1, ret2, ret3, ret4, ret5 = func(arg1, arg2);
	elseif arg4 == nil then
		ret1, ret2, ret3, ret4, ret5 = func(arg1, arg2, arg3);
	elseif arg5 == nil then
		ret1, ret2, ret3, ret4, ret5 = func(arg1, arg2, arg3, arg4);
	else
		ret1, ret2, ret3, ret4, ret5 = func(arg1, arg2, arg3, arg4, arg5);
	end
	
	-- 记录返回值
	local returnsStr = "";
	local retValues = {ret1, ret2, ret3, ret4, ret5};
	local hasReturns = false;
	
	for i, ret in ipairs(retValues) do
		if ret ~= nil then
			local retType = type(ret);
			local retStr = "";
			
			if retType == "string" then
				retStr = "\"" .. ret .. "\"";
			elseif retType == "table" then
				retStr = "table[" .. table.getn(ret) .. "]";
			else
				retStr = tostring(ret);
			end
			
			if hasReturns then
				returnsStr = returnsStr .. ", ";
			end
			returnsStr = returnsStr .. retStr .. "(" .. retType .. ")";
			hasReturns = true;
		else
			break; -- 遇到nil就停止
		end
	end
	
	return ret1, ret2, ret3, ret4, ret5; -- 返回原始返回值
end

-- 启用/禁用调试模式
XYT_DebugMode = false; -- 设置为false禁用调试

function XYT_GetWishPlayers(onlyFloorWish)
	local players = {};
	local checkedPlayers = {}; -- 用于去重
	local isQuickLootMode = (onlyFloorWish == true); -- 是否只匹配"地板"许愿的玩家，不匹配任何物品许愿
	
	-- 函数开始执行
	
	-- 方法1：尝试从xytWishData或XYT_WishData获取许愿信息
	local wishData = xytWishData or XYT_WishData;
	
	-- 快速拾取模式下不需要获取当前物品信息，只关注地板许愿
	local currentItem = nil;
	local currentItemName = nil;
	local cleanCurrentItemName = "";
	
	-- 非快速拾取模式下才获取当前物品信息
	if not isQuickLootMode then
		-- 简化处理，只获取第一个可用的拾取槽位物品
		local numItems = GetNumLootItems();
		
		if numItems > 0 then
			-- 尝试获取第一个非货币类物品
			for i = 1, numItems do
				local icon, name, quantity, quality, locked, isQuestItem = GetLootSlotInfo(i);
				
				if quality and quality >= 0 then -- 确保物品质量有效
					currentItem = GetLootSlotLink(i);
					break;
				end
			end
		end
		
		if currentItem then
			-- 从当前物品链接中提取物品名称
			currentItemName = currentItem and string.match(currentItem, "|h%[(.-)%]|h") or currentItem;
			cleanCurrentItemName = currentItemName and safeCleanString(currentItemName) or "";
		end
	end
	
	if wishData and type(wishData) == "table" then
		for name, data in pairs(wishData) do
			if data and not checkedPlayers[name] then
				-- 检查是否有具体的许愿物品信息可以进行匹配
					local isMatched = false; -- 默认不匹配
					
					-- 如果有物品名称信息，则根据调用模式进行匹配检查
					if data.itemName or data.wishItem then
						local wishItemName = data.itemName or data.wishItem;
						local cleanWishItemName = safeCleanString(wishItemName);
						
						if isQuickLootMode then
							-- 快速拾取模式：严格只匹配纯"地板"许愿的玩家，排除任何物品许愿
							isMatched = (cleanWishItemName == "地板");
						else
							-- 正常模式：匹配具体物品
							isMatched = (cleanWishItemName == cleanCurrentItemName or 
							           string.find(cleanWishItemName, cleanCurrentItemName) or 
							           string.find(cleanCurrentItemName, cleanWishItemName));
						end
					end
				
				if isMatched then
					local id = XYT_GetIDbyName(name);
					local class = "未知";
					if id then
						class = UnitClass(id) or "未知";
					end
					local score = tonumber(data.score) or tonumber(data.dkp) or 0;
					-- 添加许愿内容信息
					local wishContent = data.itemName or data.wishItem or "";
					table.insert(players, {name = name, score = score, class = class, wishContent = wishContent});
					checkedPlayers[name] = true;
				end
			end
		end
	end
	
	-- 方法2：尝试从XyArray获取地板许愿信息和物品许愿信息
	if XyArray and type(XyArray) == "table" then
		for _, playerData in ipairs(XyArray) do
			if playerData and playerData["name"] and not checkedPlayers[playerData["name"]] and playerData["xy"] and playerData["xy"] ~= "" and playerData["xy"] ~= "---未许愿---" then
				-- 检查玩家的许愿内容是否与当前物品匹配，或者是否许愿了"地板"
						local isMatched = false;
						local wishContent = playerData["xy"];
						
						if wishContent then
							local cleanWishContent = safeCleanString(wishContent);
							
							if isQuickLootMode then
						-- 快速拾取模式：严格只匹配纯"地板"许愿的玩家，排除任何物品许愿
						isMatched = (cleanWishContent == "地板");
							elseif currentItem then
								-- 正常模式：匹配具体物品
								isMatched = (cleanWishContent == cleanCurrentItemName or 
								           string.find(cleanWishContent, cleanCurrentItemName) or 
								           string.find(cleanCurrentItemName, cleanWishContent));
							end
						
					-- 在快速拾取模式下，不进行任何额外的物品匹配尝试
					if not isMatched and not isQuickLootMode and currentItem then
						local success, primaryWishItem, allWishItems = pcall(ExtractItemName, wishContent);
						if success then
							-- 检查主物品名称
							if primaryWishItem then
								local cleanPrimaryWishItem = safeCleanString(primaryWishItem);
								isMatched = (cleanPrimaryWishItem == cleanCurrentItemName or 
								           string.find(cleanPrimaryWishItem, cleanCurrentItemName) or 
								           string.find(cleanCurrentItemName, cleanPrimaryWishItem));
							end
							
							-- 如果主物品不匹配，检查其他物品名称
							if not isMatched and type(allWishItems) == "table" then
								for _, wishItem in ipairs(allWishItems) do
									local cleanWishItem = safeCleanString(wishItem);
									if cleanWishItem == cleanCurrentItemName or 
									   string.find(cleanWishItem, cleanCurrentItemName) or 
									   string.find(cleanCurrentItemName, cleanWishItem) then
										isMatched = true;
										break;
									end
								end
							end
						end
					end
				end
						if isMatched then
						local name = playerData["name"];
						local class = playerData["class"] or "未知";
						local score = tonumber(playerData["score"]) or tonumber(playerData["dkp"]) or 0;
						local wishContent = playerData["xy"] or "";
						table.insert(players, {name = name, score = score, class = class, wishContent = wishContent});
						checkedPlayers[name] = true;
					end
					end
				end
	end
	
	-- 方法3：检查当前物品是否有特定的许愿记录（只在有currentItem且非快速拾取模式时执行）
	-- 快速拾取模式下完全跳过LootList处理，因为它只包含物品许愿
	if not isQuickLootMode and currentItem and LootList and type(LootList) == "table" then
		for _, lootData in ipairs(LootList) do
			if lootData and lootData["isWish"] and lootData["playerName"] and not checkedPlayers[lootData["playerName"]] then
				-- 检查该记录是否与当前物品相关
						local isMatched = false; -- 默认不匹配
						
						if lootData["itemName"] and currentItem then
							local lootItemName = lootData["itemName"];
							local cleanLootItemName = safeCleanString(lootItemName);
							isMatched = (cleanLootItemName == cleanCurrentItemName or 
							           string.find(cleanLootItemName, cleanCurrentItemName) or 
							           string.find(cleanCurrentItemName, cleanLootItemName));
						end
				
				if isMatched then
				local name = lootData["playerName"];
				local id = XYT_GetIDbyName(name);
				local class = "未知";
				if id then
					class = UnitClass(id) or "未知";
				end
				local score = tonumber(lootData["score"]) or 0;
				local wishContent = lootData["itemName"] or "";
				table.insert(players, {name = name, score = score, class = class, wishContent = wishContent});
				checkedPlayers[name] = true;
			end
			end
		end
	end
	
	-- 按分数降序排序
	table.sort(players, function(a, b) return a.score > b.score; end);
	
	return players;
end

-- 职业名称标准化函数
function XyTracker_GetNormalizedClassName(className)
    -- 职业名称映射表 - 支持中英文
    local classNames = {
        -- 中文职业名称
        ["战士"] = "战士",
        ["圣骑士"] = "圣骑士",
        ["猎人"] = "猎人",
        ["盗贼"] = "盗贼",
        ["牧师"] = "牧师",
        ["萨满祭司"] = "萨满祭司", 
        ["法师"] = "法师",
        ["术士"] = "术士",
        ["德鲁伊"] = "德鲁伊",

        ["Warrior"] = "战士",
        ["Paladin"] = "圣骑士",
        ["Hunter"] = "猎人",
        ["Rogue"] = "盗贼",
        ["Priest"] = "牧师",
        ["Shaman"] = "萨满祭司",
        ["Mage"] = "法师",
        ["Warlock"] = "术士",
        ["Druid"] = "德鲁伊",
        ["未知"] = "未知",
        ["Unknown"] = "未知",
    };
    
    -- 安全检查className是否为字符串
    if type(className) == "string" then
        return classNames[className] or "未知";
    end
    return "未知";
end

-- 获取职业颜色
function XYT_GetClassColor(className)
	-- Lua 5.0兼容的职业颜色映射表 - 支持中英文
	local classColors = {
		-- 中文职业名称
		["战士"] = "\124cFFC79C6E",
		["圣骑士"] = "\124cFFF58CBA",
		["猎人"] = "\124cFFABD473",
		["盗贼"] = "\124cFFFFF569",
		["牧师"] = "\124cFFFFFFFF",
		["萨满祭司"] = "\124cFF0070DE", -- 添加萨满祭司的完整名称
		["法师"] = "\124cFF69CCF0",
		["术士"] = "\124cFF9482C9",
		["德鲁伊"] = "\124cFFFF7D0A",
		-- 英文职业名称 (魔兽世界1.12经典版)
		["Warrior"] = "\124cFFC79C6E",
		["Paladin"] = "\124cFFF58CBA",
		["Hunter"] = "\124cFFABD473",
		["Rogue"] = "\124cFFFFF569",
		["Priest"] = "\124cFFFFFFFF",
		["Shaman"] = "\124cFF0070DE",
		["Mage"] = "\124cFF69CCF0",
		["Warlock"] = "\124cFF998EC3",
		["Druid"] = "\124cFFFF7D0A",
		["未知"] = "\124cFF808080",
		["Unknown"] = "\124cFF808080",
	};
	
	-- 安全检查className是否为字符串
	if type(className) == "string" then
		return classColors[className] or classColors["未知"];
	end
	return classColors["未知"];
end

-- 选择快速拾取人
function XYT_SelectQuickLoot()
	-- 切换到第二层菜单显示玩家列表
	ToggleDropDownMenu(1, nil, GroupLootDropDown, "cursor", 0, 0, nil, nil, 1);
	CloseDropDownMenus(2);
	ToggleDropDownMenu(2, {value = "QUICKLOOT"}, GroupLootDropDown, "DropDownList1", 10, 0, nil, nil, 2);
end

-- 注册CHAT_MSG_SYSTEM事件以监听Roll点
local function XYT_OnEvent(self, event, ...)
    if (event == "CHAT_MSG_SYSTEM") then
        local msg = arg1;
        if (CML_Vars.RollStartTime and CML_Vars.RollTimeout and time() <= (CML_Vars.RollStartTime + CML_Vars.RollTimeout)) then
            local _, _, player, roll, min_roll, max_roll = string.find(msg, CML_ROLL_SEARCHPATTERN);
            if (player and tonumber(min_roll) == CML_Vars.Roll_Min and tonumber(max_roll) == CML_Vars.Roll_Max) then
                if (not XYT_CheckRoll(player)) then
                    XYT_SetRoll(player, roll);
                end
            end
        end
    elseif (event == "CHAT_MSG_RAID" or event == "CHAT_MSG_RAID_LEADER" or event == "CHAT_MSG_RAID_WARNING") then
        local msg = arg1;
        local sender = arg2;
        
        -- 处理DKP出分记录
        if (XYT_IsRecordingDKP) then
            -- 匹配消息中的数字（0-9）
            -- 从聊天消息中提取任何数字作为出分
            -- 如果有多个数字，选择第一个出现的数字
            local _, _, score = string.find(msg, "(%d+)");
            
            if score and tonumber(score) >= 0 then
                -- 获取玩家的许愿信息
                local playerInfo = getXyInfo(sender);
                -- 即使没有玩家许愿信息也要记录出分
                XYT_DKP_Scores[sender] = tonumber(score);
                if playerInfo then
                    XYT_DKP_Wishes[sender] = playerInfo["xy"] or "";
                else
                    XYT_DKP_Wishes[sender] = "";
                end
                XYT_UpdateDKPDisplay();
            end
        end
        
        -- 处理Roll点记录
        if (XYT_IsRecordingRoll) then
            -- 改进的Roll点匹配逻辑：尝试多种可能的Roll点消息格式
            local rollResult = nil;
            
            -- 首先尝试匹配标准格式: 玩家 掷出了 1-100 的点数，结果是 XX
            local _, _, result = string.find(msg, "掷出了 %d+-%d+ 的点数，结果是 (%d+)");
            if result then
                rollResult = result;
            end
            
            -- 如果没有匹配到，尝试匹配简化格式: 结果是 XX
            if not rollResult then
                _, _, result = string.find(msg, "结果是 (%d+)");
            end
            
            -- 如果没有匹配到，尝试匹配纯数字格式（可能玩家直接发送了数字）
            if not rollResult then
                _, _, result = string.find(msg, "^(%d+)$");
            end
            
            -- 如果没有匹配到，尝试匹配任意位置的数字（更宽松的匹配）
            if not rollResult then
                _, _, result = string.find(msg, "(%d+)");
            end
            
            if result and tonumber(result) >= 0 then
                rollResult = result;
                -- 获取玩家的许愿信息
                local playerInfo = getXyInfo(sender);
                if playerInfo then
                    XYT_Roll_Scores[sender] = tonumber(rollResult);
                    XYT_Roll_Wishes[sender] = playerInfo["xy"] or "";
                    XYT_UpdateRollDisplay();
                else
                    -- 即使没有玩家许愿信息也要记录roll点
                    XYT_Roll_Scores[sender] = tonumber(rollResult);
                    XYT_Roll_Wishes[sender] = "";
                    XYT_UpdateRollDisplay();
                end
            end
        end
    end
end

-- 创建并注册事件监听帧
if (not XYT_EventFrame) then
    XYT_EventFrame = CreateFrame("Frame");
    XYT_EventFrame:SetScript("OnEvent", XYT_OnEvent);
    -- 注释掉重复的事件注册，避免与XyTracker_OnLoad中的注册冲突
    -- XYT_EventFrame:RegisterEvent("CHAT_MSG_SYSTEM");
end

function xytShowDKP()
	-- 检查是否有正在进行的出分拍卖
	if XYT_Auction_IsActive then
		DEFAULT_CHAT_FRAME:AddMessage("出分拍卖已经在进行中");
		-- 显示出分拍卖窗口
		getglobal("DKPMonitorFrame"):Show();
		return;
	end
	
	-- 获取当前选中的物品完整链接
	local item = GetLootSlotLink(LootFrame.selectedSlot);
	
	-- 如果没有获取到物品链接，使用带颜色的物品名称作为备选
	if not item then
		item = ITEM_QUALITY_COLORS[LootFrame.selectedQuality].hex .. LootFrame.selectedItemName .. FONT_COLOR_CODE_CLOSE;
	end
	
	SendChatMessage("开始出分拍卖：" .. item .. "，请出分", "RAID");
	XYT_StartDKPRecording(item);
end

-- 开始DKP出分记录
function XYT_StartDKPRecording(item)
	-- 清除之前的记录
	XYT_DKP_Scores = {};
	XYT_DKP_Wishes = {};
	
	-- 设置记录状态
	XYT_IsRecordingDKP = true;
	
	-- 显示窗口
	getglobal("DKPMonitorFrameTitle"):SetText("DKP出分监控：" .. (item or "未知物品"));
	getglobal("DKPMonitorFrame"):Show();
	
	-- 更新显示
	XYT_UpdateDKPDisplay();
end

-- 结束DKP出分记录
function XYT_EndDKPRecording()
	XYT_IsRecordingDKP = false;
	
	-- 更新标题显示
	getglobal("DKPMonitorFrameTitle"):SetText("DKP出分记录");
	
	-- 更新显示
	XYT_UpdateDKPDisplay();
end

-- 清除DKP出分记录
function XYT_ClearDKPScores()
	XYT_DKP_Scores = {};
	XYT_DKP_Wishes = {};
	XYT_UpdateDKPDisplay();
end

function xytRoll()	-- 检查是否已有ROLL点拍卖在进行中
	if XYT_IsRecordingRoll then
		-- 显示提示消息
		SendChatMessage("ROLL点拍卖已经在进行中", "RAID");
		-- 仍然显示窗口
		getglobal("RollMonitorFrame"):Show();
		return;
	end
	
	-- 获取当前选中的物品完整链接
	curItem = GetLootSlotLink(LootFrame.selectedSlot);
	
	-- 如果没有获取到物品链接，使用带颜色的物品名称作为备选
	if not curItem then
		curItem = ITEM_QUALITY_COLORS[LootFrame.selectedQuality].hex .. LootFrame.selectedItemName .. FONT_COLOR_CODE_CLOSE;
	end
	
	getglobal("RollMonitorFrameTitle"):SetText("ROLL点监控:"..curItem);
	getglobal("xytRollTime"):SetText(XyTrackerOptions.rollTime);
	getglobal("RollMonitorFrame"):Show();
	XYT_Roll_Scores = {}; -- 初始化ROLL点记录表
	XYT_Roll_Wishes = {}; -- 初始化许愿记录表
	
	-- 修复：从XyArray预先填充许愿内容
	local totalMembers = GetNumRaidMembers();
	if totalMembers then
		for i = 1, totalMembers do
			local name = GetRaidRosterInfo(i);
			if name then
				local playerInfo = getXyInfo(name);
				if playerInfo and playerInfo["xy"] and playerInfo["xy"] ~= "" and playerInfo["xy"] ~= "---未许愿---" then
					XYT_Roll_Wishes[name] = playerInfo["xy"];
				end
			end
		end
	end
	
	XYT_StartRollRecording(curItem); -- 开始记录ROLL点
	
	-- 自动执行开始按钮的功能
	RollStart();
end


-- 替换后的单位弹出窗口点击处理函数
function ple_unitpopup1()
    local dropdownFrame = getglobal(UIDROPDOWNMENU_INIT_MENU);
    local button = this.value;
    local unit = dropdownFrame.unit;
    local name = dropdownFrame.name;
    local server = dropdownFrame.server;

    if (button == "GET_XY") then
        XyQuery(name);
    -- 处理增加分数的子菜单
    elseif button == "ADD_DKP_1" then
        XyAddDkp(name, 1);
    elseif button == "ADD_DKP_2" then
        XyAddDkp(name, 2);
    elseif button == "ADD_DKP_3" then
        XyAddDkp(name, 3);
    elseif button == "ADD_DKP_4" then
        XyAddDkp(name, 4);
    -- 处理扣除分数的子菜单
    elseif button == "MINUS_DKP_1" then
        XyMinusDkp(name, 1);
    elseif button == "MINUS_DKP_2" then
        XyMinusDkp(name, 2);
    elseif button == "MINUS_DKP_3" then
        XyMinusDkp(name, 3);
    elseif button == "MINUS_DKP_4" then
        XyMinusDkp(name, 4);
    -- 已移除：ROLL点拍卖子菜单处理
    -- elseif button == "ROLL_AUCTION_30" then
    --     -- 获取当前选中的物品信息
    --     local item = GetLootSlotLink(LootFrame.selectedSlot);
    --     if not item then
    --         item = ITEM_QUALITY_COLORS[LootFrame.selectedQuality].hex .. LootFrame.selectedItemName .. FONT_COLOR_CODE_CLOSE;
    --     end
    --     
    --     -- 检查是否是新的拍卖（物品不同或已结束）
    --     local isNewAuction = (XYT_CurrentItem ~= item) or (not XYT_IsRecordingRoll);
    --     
    --     if isNewAuction then
    --         -- 如果ROLL点拍卖已在进行中，先结束当前拍卖
    --         if XYT_IsRecordingRoll then
    --             XYT_EndRoll();
    --         end
    --         -- 设置30秒ROLL点时间并开始
    --         XyTrackerOptions.rollTime = 30;
    --         XYT_CurrentItem = item;
    --         XYT_Roll_EndTime = GetTime() + 30;
    --         XYT_IsRecordingRoll = true;
    --         getglobal("xytRollTime"):SetText("30");
    --         getglobal("RollMonitorFrameTitle"):SetText("ROLL点监控：" .. item);
    --         getglobal("RollMonitorFrame"):Show();
    --         -- 初始化ROLL点记录数据
    --         XYT_Roll_Scores = {};
    --         XYT_Roll_Wishes = {};
    --         XYT_StartRollRecording(item);
    --         SendChatMessage("开始ROLL点拍卖：" .. item .. "，时间30秒", "RAID");
    --     else
    --         -- 同一物品的重复点击，只显示窗口不重新开始
    --         if getglobal("RollMonitorFrameTitle") then
    --         getglobal("RollMonitorFrameTitle"):SetText("ROLL点监控：" .. item);
    --     end
    --     if getglobal("RollMonitorFrame") then
    --         getglobal("RollMonitorFrame"):Show();
    --     end
    --     if RollMonitor_UpdateList then
    --         RollMonitor_UpdateList();
    --     end
    --     end
    -- elseif button == "ROLL_AUCTION_60" then
    --     -- 获取当前选中的物品信息
    --     local item = GetLootSlotLink(LootFrame.selectedSlot);
    --     if not item then
    --         item = ITEM_QUALITY_COLORS[LootFrame.selectedQuality].hex .. LootFrame.selectedItemName .. FONT_COLOR_CODE_CLOSE;
    --     end
    --     
    --     -- 检查是否是新的拍卖（物品不同或已结束）
    --     local isNewAuction = (XYT_CurrentItem ~= item) or (not XYT_IsRecordingRoll);
    --     
    --     if isNewAuction then
    --         -- 如果ROLL点拍卖已在进行中，先结束当前拍卖
    --         if XYT_IsRecordingRoll then
    --             XYT_EndRoll();
    --         end
    --         -- 设置60秒ROLL点时间并开始
    --         XyTrackerOptions.rollTime = 60;
    --         XYT_CurrentItem = item;
    --         XYT_Roll_EndTime = GetTime() + 60;
    --         XYT_IsRecordingRoll = true;
    --         getglobal("xytRollTime"):SetText("60");
    --         getglobal("RollMonitorFrameTitle"):SetText("ROLL点监控：" .. item);
    --         getglobal("RollMonitorFrame"):Show();
    --         -- 初始化ROLL点记录数据
    --         XYT_Roll_Scores = {};
    --         XYT_Roll_Wishes = {};
    --         XYT_StartRollRecording(item);
    --         SendChatMessage("开始ROLL点拍卖：" .. item .. "，时间60秒", "RAID");
    --     else
    --         -- 同一物品的重复点击，只显示窗口不重新开始
    --         if getglobal("RollMonitorFrameTitle") then
    --             getglobal("RollMonitorFrameTitle"):SetText("ROLL点监控：" .. item);
    --         end
    --         if getglobal("RollMonitorFrame") then
    --             getglobal("RollMonitorFrame"):Show();
    --         end
    --         if RollMonitor_UpdateList then
    --             RollMonitor_UpdateList();
    --         end
    --     end
    -- elseif button == "ROLL_AUCTION_90" then
    --     -- 获取当前选中的物品信息
    --     local item = GetLootSlotLink(LootFrame.selectedSlot);
    --     if not item then
    --         item = ITEM_QUALITY_COLORS[LootFrame.selectedQuality].hex .. LootFrame.selectedItemName .. FONT_COLOR_CODE_CLOSE;
    --     end
    --     
    --     -- 检查是否是新的拍卖（物品不同或已结束）
    --     local isNewAuction = (XYT_CurrentItem ~= item) or (not XYT_IsRecordingRoll);
    --     
    --     if isNewAuction then
    --         -- 如果ROLL点拍卖已在进行中，先结束当前拍卖
    --         if XYT_IsRecordingRoll then
    --             XYT_EndRoll();
    --         end
    --         -- 设置90秒ROLL点时间并开始
    --         XyTrackerOptions.rollTime = 90;
    --         XYT_CurrentItem = item;
    --         XYT_Roll_EndTime = GetTime() + 90;
    --         XYT_IsRecordingRoll = true;
    --         getglobal("xytRollTime"):SetText("90");
    --         getglobal("RollMonitorFrameTitle"):SetText("ROLL点监控：" .. item);
    --         getglobal("RollMonitorFrame"):Show();
    --         -- 初始化ROLL点记录数据
    --         XYT_Roll_Scores = {};
    --         XYT_Roll_Wishes = {};
    --         XYT_StartRollRecording(item);
    --         SendChatMessage("开始ROLL点拍卖：" .. item .. "，时间90秒", "RAID");
    --     else
    --         -- 同一物品的重复点击，只显示窗口不重新开始
    --         if getglobal("RollMonitorFrameTitle") then
    --             getglobal("RollMonitorFrameTitle"):SetText("ROLL点监控：" .. item);
    --         end
    --         if getglobal("RollMonitorFrame") then
    --             getglobal("RollMonitorFrame"):Show();
    --         end
    --         if RollMonitor_UpdateList then
    --             RollMonitor_UpdateList();
    --         end
    --     end
    -- elseif button == "ROLL_AUCTION_SHOW_RESULTS" then
    --     -- 显示ROLL点结果，只显示窗口不重新开始
    --     if XYT_CurrentItem then
    --         getglobal("RollMonitorFrameTitle"):SetText("ROLL点监控：" .. XYT_CurrentItem);
    --     else
    --         getglobal("RollMonitorFrameTitle"):SetText("ROLL点监控");
    --     end
    --     getglobal("RollMonitorFrame"):Show();
    --     RollMonitor_UpdateList();

    else
        return ori_unitpopup1();
    end
    
    PlaySound("UChatScrollButton");
end

-- 获取指定名字的许愿信息
function getXyInfo(name)
    local n = table.getn(XyArray)
    if n > 0 then
        for i = 1, n do
            local info = XyArray[i]
            if info["name"] == name then
                -- 修复：确保dkp值转换为数字并处理nil情况
                info["dkp"] = tonumber(info["dkp"]) or tonumber(DefaultDKP) or 0
                return info
            end
        end
    end
    --如果是新加入的成员。初始化该成员信息并返回 by 无道暴君20250217
    local totalMembers = GetNumRaidMembers()
    if totalMembers then
        for i = 1, totalMembers do
            local player, rank, subgroup, level, class, fileName, zone, online = GetRaidRosterInfo(i);
            if name==player then
                local info = {}
                info["name"] = name
                info["class"] = class
                info["xy"] = "---未许愿---"
                info["dkp"] = tonumber(DefaultDKP) or 0
                table.insert(XyArray, info)
                NoXyList = NoXyList .. name .. " "
                return info;
            end
        end
    end
    return nil
end

-- Xy_CompareRolls函数已移至XYT_UpdateRollDisplay函数附近



-- 更新许愿者列表
function XyTracker_UpdateList()
    NoXyList = ""
    Xys = 0
    local totalMembers = GetNumRaidMembers()
    local currentRaidMembers = {}
    
    -- 获取当前团队成员列表
    if totalMembers then
        for i = 1, totalMembers do
            local name = GetRaidRosterInfo(i)
            if name then
                currentRaidMembers[name] = true
            end
        end
        
        -- 更新未许愿列表和许愿人数
        -- 先创建一个名字到索引的映射，用于快速查找
        local nameToIndex = {}
        local n = table.getn(XyArray)
        for i = 1, n do
            if XyArray[i] and XyArray[i]["name"] then
                nameToIndex[XyArray[i]["name"]] = i
            end
        end
        
        for i = 1, totalMembers do
            local name, rank, subgroup, level, class, fileName, zone, online = GetRaidRosterInfo(i);
            
            -- 使用映射表检查玩家是否存在
            local info = nil
            if name then
                if nameToIndex[name] then
                    info = XyArray[nameToIndex[name]]
                else
                    -- 玩家不存在，添加新记录
                    info = {}
                    info["name"] = name
                    info["class"] = class
                    info["xy"] = "---未许愿---"
                    info["dkp"] = tonumber(DefaultDKP) or 0
                    table.insert(XyArray, info)
                    nameToIndex[name] = table.getn(XyArray)
                end
                
                if info then
                    if IsLeader and NewDKP then 
                        info["dkp"] = tonumber(DefaultDKP) or 0
                    end
                    if info["xy"] and info["xy"] ~= "---未许愿---" and info["xy"] ~= "" then
                        Xys = Xys + 1
                    else
                        NoXyList = NoXyList .. name .. " "
                    end
                end
            end
        end
        
        -- 保留所有玩家记录，不在队伍中的玩家只是在UI中隐藏而不删除
        
        if IsLeader then
            NewDKP = false
        end
    end
    
    -- 确保总是显示未许愿人数，即使totalMembers为nil
    if totalMembers then
        XyTrackerFrameStatusText:SetText(XyTracker_If(Xys == totalMembers, "当前全部许愿", string.format("%d未许愿人数", totalMembers - Xys)))
    else
        XyTrackerFrameStatusText:SetText("当前不在团队中")
    end
    
    -- 确保文本框总是可见
    if XyTrackerFrameStatusText:IsVisible() == false then
        XyTrackerFrameStatusText:Show()
    end
    
    -- 创建一个只包含当前团队成员的临时数组用于显示
    local displayArray = {}
    if table.getn(XyArray) > 0 and totalMembers then
        for i = 1, table.getn(XyArray) do
            local info = XyArray[i]
            if currentRaidMembers[info["name"]] then
                table.insert(displayArray, info)
            end
        end
    end
    
    -- 更新滚动框
    FauxScrollFrame_Update(XyListScrollFrame, table.getn(displayArray), 18, 25);
    
    -- 显示当前团队成员的许愿信息
    if table.getn(displayArray) > 0 then
        local offset = FauxScrollFrame_GetOffset(XyListScrollFrame);
        for i = 1, 18 do
            k = offset + i;
            if k > table.getn(displayArray) then
                getglobal("XyFrameListButton" .. i):Hide();
            else
                v = displayArray[k]
                -- 获取职业颜色并给名字染色
                local classColor = XYT_GetClassColor(v["class"]) or "|cffffffff"
                local coloredName = classColor .. v["name"] .. "|r"
                getglobal("XyFrameListButton" .. i .. "Name"):SetText(coloredName);
                -- 显示完整职业名称
                getglobal("XyFrameListButton" .. i .. "Class"):SetText(v["class"]);
                getglobal("XyFrameListButton" .. i .. "Xy"):SetText(v["xy"]);
                getglobal("XyFrameListButton" .. i .. "DKP"):SetText(v["dkp"]);
                getglobal("XyFrameListButton" .. i):Show();
                
                -- 显式显示加减按钮，仅在获得IsLeader权限时显示
                local addButton = getglobal("XyFrameListButton" .. i .. "AddDkp")
                local minusButton = getglobal("XyFrameListButton" .. i .. "MinusDkp")
                if IsLeader then
                    if addButton then
                        addButton:Show()
                    end
                    if minusButton then
                        minusButton:Show()
                    end
                else
                    if addButton then
                        addButton:Hide()
                    end
                    if minusButton then
                        minusButton:Hide()
                    end
                end
            end
        end
    else
        for i = 1, 18 do
            getglobal("XyFrameListButton" .. i):Hide();
        end
    end
end

-- 调试级别定义
XyTracker_DebugLevel = {
    ERROR = 1,    -- 仅错误信息
    WARN = 2,     -- 警告和错误
    INFO = 3,     -- 一般信息
    DEBUG = 4     -- 详细调试信息
}

-- 当前调试级别（默认仅显示错误）
XyTracker_CurrentDebugLevel = XyTracker_DebugLevel.ERROR

-- 新的调试输出函数
function XyTracker_Print(msg, level)
    level = level or XyTracker_DebugLevel.INFO
    if level <= XyTracker_CurrentDebugLevel then
        if DEFAULT_CHAT_FRAME then
            local levelText = ""
            if level == XyTracker_DebugLevel.ERROR then
                levelText = "|cffff0000[错误]|r"
            elseif level == XyTracker_DebugLevel.WARN then
                levelText = "|cffffff00[警告]|r"
            elseif level == XyTracker_DebugLevel.INFO then
                levelText = "|cff00ff00[信息]|r"
            elseif level == XyTracker_DebugLevel.DEBUG then
                levelText = "|cff808080[调试]|r"
            end
            DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] "..levelText.." "..msg)
        end
    end
end

function XyTracker_If(expr, a, b)
    if expr then
        return a
    else
        return b
    end
end
function XyTracker_OnSlashCommand(msg)
    XyTracker_Print("收到斜杠命令: " .. (msg or "空"), XyTracker_DebugLevel.DEBUG)
    
    -- 调试级别控制
    if msg == "debug0" then
        XyTracker_CurrentDebugLevel = XyTracker_DebugLevel.ERROR
        XyTracker_Print("调试级别切换为: ERROR (0)", XyTracker_DebugLevel.INFO)
        DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 调试级别设置为：仅错误")
    elseif msg == "debug1" then
        XyTracker_CurrentDebugLevel = XyTracker_DebugLevel.WARN
        XyTracker_Print("调试级别切换为: WARN (1)", XyTracker_DebugLevel.INFO)
        DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 调试级别设置为：警告和错误")
    elseif msg == "debug2" then
        XyTracker_CurrentDebugLevel = XyTracker_DebugLevel.INFO
        XyTracker_Print("调试级别切换为: INFO (2)", XyTracker_DebugLevel.INFO)
        DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 调试级别设置为：一般信息")
    elseif msg == "debug3" then
        XyTracker_CurrentDebugLevel = XyTracker_DebugLevel.DEBUG
        XyTracker_Print("调试级别切换为: DEBUG (3) - 详细调试模式已启用", XyTracker_DebugLevel.INFO)
        DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 调试级别设置为：详细调试")
    elseif msg == "export" then
        -- 已移除导出功能的输出
    elseif msg == "test" then
        -- 调用测试函数
        TestRollMonitor()
    else
        -- 原有的显示/隐藏功能
          XyTracker_OnRefreshButtonClick()
        if XyTrackerFrame:IsVisible() then
            XyTracker_HideXyWindow()
          
        else
            XyTracker_ShowXyWindow()
        end
    end
end

function XyTracker_ShowXyWindow()
    if DefaultDKP == nil then
        DefaultDKP = 4
    end
    getglobal("autoModeButtons"):SetChecked(XyTrackerOptions.XyOnlyMode);
    getglobal("autoAnnounceButton"):SetChecked(XyTrackerOptions.AutoAnnounce);
    getglobal("autoMinButtons"):SetChecked(XyTrackerOptions.autoMinDkp);
    getglobal("greenModeButtons"):SetChecked(XyTrackerOptions.greenModeEnabled);
    getglobal("blueModeButtons"):SetChecked(XyTrackerOptions.blueModeEnabled);
    getglobal("purpleModeButtons"):SetChecked(XyTrackerOptions.purpleModeEnabled);
    
    -- 请求同步信息以验证团长身份（发送同步信息者即为团长）
    if IsLeader then
        -- 团长发送同步请求
        SendAddonMessage("XY_SYNC_NEW", XyTrackerDeclaration, "RAID")
    else
        -- 非团长请求同步数据
        SendAddonMessage("XY_LOOTLIST_SYNC_REQUEST", "", "RAID")
    end
    
    -- 确保加载保存的宣言
    if not playerDeclaration or playerDeclaration == "" then
        playerDeclaration = XyTrackerDeclaration or ""
    end
    
    -- 宣言按钮显示控制
    if IsLeader then
        getglobal("XyTrackerFrameDeclarationButton"):Show()
        getglobal("XyTrackerFrameAnnounceDeclarationButton"):Show()
    else
        getglobal("XyTrackerFrameDeclarationButton"):Hide()
        getglobal("XyTrackerFrameAnnounceDeclarationButton"):Hide()
    end
    
    -- 强制更新许愿权限拥有者显示
    XyTracker_UpdateLeaderText()
    
    -- 再次确保文本可见（冗余保障）
    local leaderText = getglobal("XyTrackerLeaderText")
    if leaderText and not leaderText:IsVisible() then
        leaderText:Show()
    end
    
    -- 宣言内容现在在独立窗口中管理，不需要在这里设置
    
    ShowUIPanel(XyTrackerFrame)
end

function XyTracker_HideXyWindow()
    HideUIPanel(XyTrackerFrame)
end

-- 创建小地图图标
function XyTracker_CreateMinimapButton()
    -- 创建按钮框架
    local button = CreateFrame("Button", "XyTrackerMinimapButton", Minimap)
    button:SetFrameStrata("HIGH")
    button:SetWidth(26)  -- 按钮大小
    button:SetHeight(26)
    button:EnableMouse(true)
    button:SetMovable(true)
    button:RegisterForDrag("LeftButton", "RightButton")  -- 同时支持左键和右键拖动
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")  -- 注册左键和右键点击事件
    
    -- 不设置基础背景，避免黑色背景
    -- 直接使用gold.blp作为按钮纹理
    button:SetNormalTexture("Interface\\AddOns\\XyTracker\\Images\\gold.blp")
    local normalTex = button:GetNormalTexture()
    normalTex:SetWidth(20)
    normalTex:SetHeight(20)
    normalTex:SetPoint("CENTER", 0, 0)
    
    -- 悬停高亮效果
    button:SetHighlightTexture("Interface/Minimap/UI-Minimap-ZoomButton-Highlight")
    local highlightTex = button:GetHighlightTexture()
    highlightTex:SetBlendMode("ADD")
    highlightTex:SetWidth(26)
    highlightTex:SetHeight(26)
    highlightTex:SetPoint("CENTER", 0, 0)
    
    -- 设置鼠标悬停提示
    button:SetScript("OnEnter", function()
        GameTooltip:SetOwner(button, "ANCHOR_LEFT")
        GameTooltip:SetText("开启/关闭 许愿监视")
        GameTooltip:AddLine("左键点击显示/隐藏窗口", 1, 1, 1)
        GameTooltip:AddLine("左键拖动：围绕小地图移动", 1, 1, 1)
        GameTooltip:AddLine("右键拖动：自由移动（不受小地图限制）", 1, 1, 1)
        GameTooltip:AddLine("右键点击：放大/缩小图标", 1, 1, 1)
        GameTooltip:Show()
    end)
    
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    -- 设置拖动功能 - 支持左键围绕小地图拖动和右键自由拖动
    button:SetScript("OnDragStart", function()
        button.isDragging = true
        button.dragButton = arg1  -- 记录使用哪个按钮拖动
        
        if arg1 == "LeftButton" then
            -- 左键拖动：围绕小地图移动
            local mx, my = Minimap:GetCenter()
            local px, py = GetCursorPosition()
            local scale = UIParent:GetScale()
            px = px / scale
            py = py / scale
            
            -- 计算角度并保持在小地图周围
            local angle = math.atan2(py - my, px - mx)
            local x = math.cos(angle) * 80
            local y = math.sin(angle) * 80
            
            -- 设置按钮位置
            button:ClearAllPoints()
            button:SetPoint("CENTER", Minimap, "CENTER", x, y)
        else
                -- 右键拖动：自由移动，不受小地图限制
                button:ClearAllPoints()
                -- 获取当前鼠标位置作为初始位置
                local px, py = GetCursorPosition()
                local scale = UIParent:GetScale()
                px = px / scale
                py = py / scale
                button:SetPoint("CENTER", UIParent, "BOTTOMLEFT", px, py)
        end
    end)
    
    button:SetScript("OnDragStop", function()
        -- 确保XyTrackerOptions表存在
        if not XyTrackerOptions then
            XyTrackerOptions = {}
            -- 重新初始化必要的默认值
            XyTrackerOptions.dkpTime = XyTrackerOptions.dkpTime or 30
            XyTrackerOptions.rollTime = XyTrackerOptions.rollTime or 30
        end
        
        -- 保存拖动类型
        local dragType = button.dragButton
        
        -- 只有在有拖动类型时才保存位置
        if dragType then
            -- 获取最终位置
            local point, relativeTo, relativePoint, xOfs, yOfs = button:GetPoint()
            
            -- 根据拖动按钮类型保存到对应的变量并清除另一种类型的位置
            if dragType == "LeftButton" then
                -- 左键拖动：保存围绕小地图的位置
                -- 确保minimapPos始终是表类型
                if type(XyTrackerOptions.minimapPos) ~= "table" then
                    XyTrackerOptions.minimapPos = {}
                end
                XyTrackerOptions.minimapPos.x = xOfs
                XyTrackerOptions.minimapPos.y = yOfs
                XyTrackerOptions.freePos = nil -- 清除右键位置
                XyTrackerOptions.lastDragType = "LeftButton"
            else
                -- 右键拖动：保存自由位置
                XyTrackerOptions.freePos = {x = xOfs, y = yOfs}
                XyTrackerOptions.minimapPos = nil -- 清除左键位置
                XyTrackerOptions.lastDragType = "RightButton"
            end
        end
        
        -- 清除拖动状态
        button.isDragging = nil  -- 使用nil而不是false，与其他代码保持一致
        button.dragButton = nil
    end)
    
    -- 拖动更新逻辑
    button:SetScript("OnUpdate", function() 
        if button.isDragging then
            -- 确保XyTrackerOptions表存在
            if not XyTrackerOptions then
                XyTrackerOptions = {}
                -- 重新初始化必要的默认值
                XyTrackerOptions.dkpTime = XyTrackerOptions.dkpTime or 30
                XyTrackerOptions.rollTime = XyTrackerOptions.rollTime or 30
            end
            local px, py = GetCursorPosition()
            local scale = UIParent:GetScale()
            px = px / scale
            py = py / scale
            
            -- 保存当前拖动类型（避免在拖动过程中丢失）
            local currentDragType = button.dragButton or "LeftButton" -- 默认左键拖动
            
            if currentDragType == "LeftButton" then
                -- 左键拖动：围绕小地图移动
                local mx, my = Minimap:GetCenter()
                
                -- 计算角度并保持在小地图周围
                local angle = math.atan2(py - my, px - mx)
                local x = math.cos(angle) * 80
                local y = math.sin(angle) * 80
                
                -- 设置按钮位置
                button:ClearAllPoints()
                button:SetPoint("CENTER", Minimap, "CENTER", x, y)
                
                -- 立即保存左键拖动位置
                -- 确保minimapPos始终是表类型
                if type(XyTrackerOptions.minimapPos) ~= "table" then
                    XyTrackerOptions.minimapPos = {}
                end
                XyTrackerOptions.minimapPos.x = x
                XyTrackerOptions.minimapPos.y = y
                XyTrackerOptions.lastDragType = "LeftButton"
                XyTrackerOptions.freePos = nil -- 清除右键位置
            else
                -- 右键拖动：自由移动，不受小地图限制
                -- 直接设置按钮在屏幕上的绝对位置
                button:ClearAllPoints()
                button:SetPoint("CENTER", UIParent, "BOTTOMLEFT", px, py)
                
                -- 立即保存右键拖动位置
                -- 直接保存px, py，确保与设置位置时使用相同的值
                XyTrackerOptions.freePos = {x = px, y = py}
                XyTrackerOptions.lastDragType = "RightButton"
                XyTrackerOptions.minimapPos = nil -- 清除左键位置
            end
        end
    end)
    
    -- 修改点击事件
    button:SetScript("OnClick", function()
        -- 检查是否是拖动操作而不是纯点击
    
        if not button.isDragging then
            -- 右键点击：放大缩小图标
            if arg1 == "RightButton" then
        
                -- 切换按钮尺寸
                -- 使用math.floor解决浮点数精度问题
                local currentWidth = math.floor(button:GetWidth())
                if currentWidth == 26 then
                    -- 放大
                    button:SetWidth(36)
                    button:SetHeight(36)
                    local normalTex = button:GetNormalTexture()
                    if normalTex then
                        normalTex:SetWidth(30)
                        normalTex:SetHeight(30)
                    end
                    local highlightTex = button:GetHighlightTexture()
                    if highlightTex then
                        highlightTex:SetWidth(36)
                        highlightTex:SetHeight(36)
                    end
                    -- 保存图标大小状态
                    XyTrackerOptions.iconSize = 36
                else
                    -- 缩小回原始尺寸
                    button:SetWidth(26)
                    button:SetHeight(26)
                    local normalTex = button:GetNormalTexture()
                    if normalTex then
                        normalTex:SetWidth(20)
                        normalTex:SetHeight(20)
                    end
                    local highlightTex = button:GetHighlightTexture()
                    if highlightTex then
                        highlightTex:SetWidth(26)
                        highlightTex:SetHeight(26)
                    end
                    -- 保存图标大小状态
                    XyTrackerOptions.iconSize = 26
                end
            -- 左键点击：显示/隐藏窗口
            elseif arg1 == "LeftButton" then
                if XyTrackerFrame:IsShown() then
                    XyTracker_HideXyWindow()
                else
                    XyTracker_ShowXyWindow()
                end
            end
        else
            -- 拖动操作后的尺寸保持
            -- 使用math.floor解决浮点数精度问题
            local currentWidth = math.floor(button:GetWidth())
            if currentWidth ~= 26 and currentWidth ~= 36 then
                button:SetWidth(26)
                button:SetHeight(26)
                local normalTex = button:GetNormalTexture()
                if normalTex then
                    normalTex:SetWidth(20)
                    normalTex:SetHeight(20)
                end
                local highlightTex = button:GetHighlightTexture()
                if highlightTex then
                    highlightTex:SetWidth(26)
                    highlightTex:SetHeight(26)
                end
            end
        end
    end)
    
    -- 设置初始位置
    -- 确保XyTrackerOptions表存在并初始化必要字段
    if not XyTrackerOptions then
        XyTrackerOptions = {}
        -- 重新初始化必要的默认值
        XyTrackerOptions.dkpTime = XyTrackerOptions.dkpTime or 30
        XyTrackerOptions.rollTime = XyTrackerOptions.rollTime or 30
    end
    
    -- 加载保存的图标大小
    if XyTrackerOptions.iconSize then
        local size = XyTrackerOptions.iconSize
        button:SetWidth(size)
        button:SetHeight(size)
        local normalTex = button:GetNormalTexture()
        if normalTex then
            normalTex:SetWidth(size == 26 and 20 or 30)
            normalTex:SetHeight(size == 26 and 20 or 30)
        end
        local highlightTex = button:GetHighlightTexture()
        if highlightTex then
            highlightTex:SetWidth(size)
            highlightTex:SetHeight(size)
        end
    end
    -- 根据最后一次拖动类型加载对应的位置
    -- 添加额外的验证确保数据有效
    if XyTrackerOptions.lastDragType == "RightButton" and XyTrackerOptions.freePos and 
       XyTrackerOptions.freePos.x and XyTrackerOptions.freePos.y then
        -- 移除所有坐标限制，允许图标自由拖动到任何位置
        local x, y = XyTrackerOptions.freePos.x, XyTrackerOptions.freePos.y
        
        -- 右键拖动模式：直接使用保存的坐标，保持与保存时完全一致的锚点设置
        -- 不再添加额外偏移，因为保存时已经使用了相同的锚点类型
        button:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
    elseif XyTrackerOptions.minimapPos and XyTrackerOptions.minimapPos.x and XyTrackerOptions.minimapPos.y then
        -- 左键拖动模式：使用围绕小地图的位置
        button:SetPoint("CENTER", Minimap, "CENTER", XyTrackerOptions.minimapPos.x, XyTrackerOptions.minimapPos.y)
    else
        -- 默认位置（小地图右侧）
        button:SetPoint("CENTER", Minimap, "CENTER", 80, 0)
    end
    
    -- 保存按钮引用并确保显示
    XyTrackerMinimapButton = button
    button:Show()
    
    -- 添加错误处理，确保按钮始终可见
    local errorCheckFrame = CreateFrame("Frame")
    local lastCheckTime = 0
    errorCheckFrame:SetScript("OnUpdate", function()
        -- 每5秒检查一次按钮是否可见
        local currentTime = GetTime()
        if not lastCheckTime or currentTime - lastCheckTime > 5 then
            lastCheckTime = currentTime
            if XyTrackerMinimapButton and not XyTrackerMinimapButton:IsVisible() then
                XyTrackerMinimapButton:Show()
                -- 如果位置无效，重置到默认位置
                if XyTrackerOptions then
                    -- 检查右键拖动位置是否无效（仅检查数据结构有效性，移除坐标范围限制）
                    local freePosInvalid = XyTrackerOptions.lastDragType == "RightButton" and
                                         (not XyTrackerOptions.freePos or
                                          not XyTrackerOptions.freePos.x or
                                          not XyTrackerOptions.freePos.y)
                    
                    -- 检查左键拖动位置是否无效
                    local minimapPosInvalid = XyTrackerOptions.lastDragType == "LeftButton" and 
                                             (not XyTrackerOptions.minimapPos or 
                                              not XyTrackerOptions.minimapPos.x or 
                                              not XyTrackerOptions.minimapPos.y or 
                                              math.abs(XyTrackerOptions.minimapPos.x) > 200 or 
                                              math.abs(XyTrackerOptions.minimapPos.y) > 200)
                    
                    -- 根据当前拖动类型检查对应位置是否有效
                    if freePosInvalid or minimapPosInvalid then
                        -- 重置为默认位置（使用左键拖动模式）
                        XyTrackerOptions.minimapPos = {x = 80, y = 0}
                        XyTrackerOptions.freePos = nil
                        XyTrackerOptions.lastDragType = "LeftButton"
                        XyTrackerMinimapButton:ClearAllPoints()
                        XyTrackerMinimapButton:SetPoint("CENTER", Minimap, "CENTER", 80, 0)
                        DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 小地图图标位置无效，已重置到默认位置")
                    end
                end
            end
        end
    end)
end

-- 简化的位置更新函数，用于兼容旧版代码
function XyButton_UpdatePosition()
    -- 使用新的位置加载逻辑，与创建按钮时保持一致
    if XyTrackerMinimapButton and XyTrackerOptions then
        XyTrackerMinimapButton:ClearAllPoints()
        
        -- 根据最后一次拖动类型加载对应的位置
        if XyTrackerOptions.lastDragType == "RightButton" and XyTrackerOptions.freePos and 
           XyTrackerOptions.freePos.x and XyTrackerOptions.freePos.y then
            -- 移除所有坐标限制，允许图标自由拖动到任何位置
            local x, y = XyTrackerOptions.freePos.x, XyTrackerOptions.freePos.y
            
            -- 右键拖动模式：直接使用保存的坐标，保持与保存时完全一致的锚点设置
            XyTrackerMinimapButton:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
        elseif XyTrackerOptions.minimapPos and XyTrackerOptions.minimapPos.x and XyTrackerOptions.minimapPos.y then
            -- 左键拖动模式
            XyTrackerMinimapButton:SetPoint("CENTER", Minimap, "CENTER", XyTrackerOptions.minimapPos.x, XyTrackerOptions.minimapPos.y)
        else
            -- 默认位置
            XyTrackerMinimapButton:SetPoint("CENTER", Minimap, "CENTER", 80, 0)
        end
    end
end

-- 兼容性函数，不再使用旧的保存方式
function XyButton_SavePosition()
    -- 使用新的位置保存逻辑，保持与拖动停止时一致
    if XyTrackerMinimapButton and XyTrackerOptions then
        local dragType = XyTrackerOptions.lastDragType or "LeftButton"
        local point, relativeTo, relativePoint, xOfs, yOfs = XyTrackerMinimapButton:GetPoint()
        
        if dragType == "LeftButton" then
            XyTrackerOptions.minimapPos = {x = xOfs, y = yOfs}
            XyTrackerOptions.freePos = nil
        else
            XyTrackerOptions.freePos = {x = xOfs, y = yOfs}
            XyTrackerOptions.minimapPos = nil
        end
    end
end

-- 检测聊天中的物品链接并通报许愿信息
function CheckItemAndAnnounceWish(msg, sender)
    -- 安全检查：确保参数有效
   
    if not msg or type(msg) ~= "string" then
        return
    end
    
    if not XyTrackerOptions.AutoAnnounce then 
        return 
    end  -- 只有在启用自动播报时才处理，移除XyInProgress条件，允许停止许愿后也能播报
    
    -- 检查消息是否包含白名单标记"★播报许愿★"，如果是则不进行处理
    if string.find(msg, "★播报许愿★") then
        return
    end
    
    -- 获取当前玩家名称
    local playerName = UnitName("player")
    
    -- 提取消息中的所有物品链接
    local itemLinkFound = false
    
    -- 先收集所有物品链接
    local allItemLinks = {}
    for itemLink in string.gmatch(msg, "|Hitem:.-|h.-|h") do
        table.insert(allItemLinks, itemLink)
    end
    
    -- 逐个处理每个物品链接
    for itemIndex, itemLink in ipairs(allItemLinks) do
        itemLinkFound = true
        
        -- 使用pcall安全调用ExtractItemName函数
        local success, itemName = pcall(ExtractItemName, itemLink)
        if not success or type(itemName) ~= "string" then
            itemName = "" -- 设置为空字符串以避免错误
        end
        
        -- 使用全局的安全字符串清理函数
        local cleanItemName = safeCleanString(itemName)
        
        -- 判断是团长还是队员，执行不同的播报逻辑
        if IsLeader then
            -- 团长逻辑：显示所有实际许愿的玩家
            local wishPlayers = {}
            
            -- 遍历许愿列表，匹配有效许愿条目
            for i = 1, table.getn(XyArray) do
                local info = XyArray[i]
                if info and info["name"] and info["xy"] and info["xy"] ~= "---未许愿---" then
                    -- 使用pcall安全调用ExtractItemName函数，获取主物品名称和所有物品名称列表
                    local success, primaryWishItem, allWishItems = pcall(ExtractItemName, info["xy"])
                    if not success or type(primaryWishItem) ~= "string" then
                        primaryWishItem = ""
                    end
                    
                    -- 使用安全的字符串清理函数处理主物品名称
                    local cleanPrimaryWishItem = safeCleanString(primaryWishItem)
                    
                    -- 标记是否匹配成功
                    local isMatched = false
                    
                    -- 修复：添加物品名称有效性检查，避免空值或无效值导致的误判
                    if primaryWishItem ~= "" and cleanPrimaryWishItem ~= "" and cleanItemName ~= "" then
                        -- 先检查主物品名称是否匹配
                        -- 修复：只使用严格的相等比较，移除模糊匹配条件
                        local matchCondition1 = cleanPrimaryWishItem == cleanItemName
                        local matchCondition2 = primaryWishItem == itemName
                        
                        if matchCondition1 or matchCondition2 then
                            isMatched = true
                        else
                            -- 如果主物品不匹配，检查其他物品名称
                            if type(allWishItems) == "table" and table.getn(allWishItems) > 1 then
                                for _, wishItem in ipairs(allWishItems) do
                                    local cleanWishItem = safeCleanString(wishItem)
                                    
                                    -- 修复：同样只使用严格的相等比较
                                    if cleanWishItem == cleanItemName or wishItem == itemName then
                                        isMatched = true
                                        break -- 一旦匹配成功，就跳出循环
                                    end
                                end
                            end
                        end
                    end
                    
                    -- 如果匹配成功，添加到许愿玩家列表
                    if isMatched then
                        table.insert(wishPlayers, {name = info["name"], dkp = info["dkp"]})
                    end
                end
            end
            
            -- 为当前物品生成团长通报内容
            if type(wishPlayers) == "table" then
                -- 获取当前团队成员列表
                local currentRaidMembers = {}
                local totalMembers = GetNumRaidMembers()
                if totalMembers then
                    for i = 1, totalMembers do
                        local name = GetRaidRosterInfo(i)
                        if name then
                            currentRaidMembers[name] = true
                        end
                    end
                end
                
                -- 只保留当前在团队中的玩家
                local inRaidWishPlayers = {}
                for idx = 1, table.getn(wishPlayers) do
                    local player = wishPlayers[idx]
                    if type(player) == "table" then
                        local name = player.name or "未知"
                        if currentRaidMembers[name] then
                            table.insert(inRaidWishPlayers, player)
                        end
                    end
                end
                
                if table.getn(inRaidWishPlayers) > 0 then
                    local announcement = "★"..cleanItemName.."★共"..table.getn(inRaidWishPlayers).."人许愿："
                    for idx = 1, table.getn(inRaidWishPlayers) do
                        local player = inRaidWishPlayers[idx]
                        if type(player) == "table" then
                            local name = player.name or "未知"
                            local dkp = player.dkp or "0"
                            announcement = announcement .. name .. "（" .. dkp .. "分）"
                            if idx < table.getn(inRaidWishPlayers) then
                                announcement = announcement .. "、"
                            end
                        end
                    end
                    
                    local currentLanguage = GetDefaultLanguage("player")
                    SendChatMessage(announcement, "RAID", currentLanguage, nil)
                end
            end
        else
            -- 队员逻辑：只显示自己是否许愿了该物品
            -- 修复：确保每次检查都重新初始化为false
            local hasWished = false
            local myDkp = "0"
            
            -- 遍历许愿列表，检查自己是否许愿了该物品
            for i = 1, table.getn(XyArray) do
                local info = XyArray[i]
                if info and info["name"] == playerName and info["xy"] and info["xy"] ~= "---未许愿---" then
                    -- 使用pcall安全调用ExtractItemName函数
                    local success, primaryWishItem, allWishItems = pcall(ExtractItemName, info["xy"])
                    if not success or type(primaryWishItem) ~= "string" or primaryWishItem == "" then
                        primaryWishItem = ""
                        allWishItems = {}
                    end
                    
                    -- 使用安全的字符串清理函数处理主物品名称
                    local cleanPrimaryWishItem = safeCleanString(primaryWishItem)
                    
                    -- 检查是否匹配
                    local isMatched = false
                    
                    -- 修复：添加物品名称有效性检查，避免空值或无效值导致的误判
                    if primaryWishItem ~= "" and cleanPrimaryWishItem ~= "" and cleanItemName ~= "" then
                        -- 使用更严格的匹配条件，避免模糊匹配导致的误判
                        if cleanPrimaryWishItem == cleanItemName or primaryWishItem == itemName then
                            isMatched = true
                        else
                            -- 如果主物品不匹配，检查其他物品名称
                            if type(allWishItems) == "table" and table.getn(allWishItems) > 1 then
                                for _, wishItem in ipairs(allWishItems) do
                                    local cleanWishItem = safeCleanString(wishItem)
                                    
                                    -- 同样使用严格匹配
                                    if cleanWishItem == cleanItemName or wishItem == itemName then
                                        isMatched = true
                                        break
                                    end
                                end
                            end
                        end
                    end
                    
                    if isMatched then
                        hasWished = true
                        myDkp = info["dkp"] or "0"
                        break
                    end
                end
            end
            
            -- 为当前物品生成队员通报内容
            if hasWished then
                local announcement = "★"..cleanItemName.."★我已许愿（"..myDkp.."分）"
                local currentLanguage = GetDefaultLanguage("player")
                SendChatMessage(announcement, "RAID", currentLanguage, nil)
            end
        end
    end
    
    -- 如果没有找到物品链接，尝试直接匹配物品名称
    if not itemLinkFound then
        local directCleanItemName = safeCleanString(msg)
        
        -- 获取当前玩家名称
        local playerName = UnitName("player")
        
        -- 判断是团长还是队员，执行不同的播报逻辑
        if IsLeader then
            -- 团长逻辑：显示所有实际许愿的玩家
            local directWishPlayers = {}
            for i = 1, table.getn(XyArray) do
                local info = XyArray[i]
                if info and info["xy"] and info["xy"] ~= "---未许愿---" then
                    local success, wishItem = pcall(ExtractItemName, info["xy"])
                    if success and type(wishItem) == "string" and wishItem ~= "" and wishItem ~= "---未许愿---" then
                        
                        local cleanWishItem = safeCleanString(wishItem)
                        
                        if (cleanWishItem == directCleanItemName or wishItem == msg) then
                            table.insert(directWishPlayers, {name = info["name"], dkp = info["dkp"]})
                        end
                    end
                end
            end
            
            if type(directWishPlayers) == "table" then
                -- 获取当前团队成员列表
                local currentRaidMembers = {}
                local totalMembers = GetNumRaidMembers()
                if totalMembers then
                    for i = 1, totalMembers do
                        local name = GetRaidRosterInfo(i)
                        if name then
                            currentRaidMembers[name] = true
                        end
                    end
                end
                
                -- 只保留当前在团队中的玩家
                local inRaidDirectWishPlayers = {}
                for idx = 1, table.getn(directWishPlayers) do
                    local player = directWishPlayers[idx]
                    if type(player) == "table" then
                        local name = player.name or "未知"
                        if currentRaidMembers[name] then
                            table.insert(inRaidDirectWishPlayers, player)
                        end
                    end
                end
                
                if table.getn(inRaidDirectWishPlayers) > 0 then
                    local announcement = "★"..directCleanItemName.."★共"..table.getn(inRaidDirectWishPlayers).."人许愿："
                    for idx = 1, table.getn(inRaidDirectWishPlayers) do
                        local player = inRaidDirectWishPlayers[idx]
                        if type(player) == "table" then
                            local name = player.name or "未知"
                            local dkp = player.dkp or "0"
                            announcement = announcement .. name .. "（" .. dkp .. "分）"
                            if idx < table.getn(inRaidDirectWishPlayers) then
                                announcement = announcement .. "、"
                            end
                        end
                    end
                    
                    local currentLanguage = GetDefaultLanguage("player")
                    SendChatMessage(announcement, "RAID", currentLanguage, nil)
                end
            end
        else
            -- 队员逻辑：只显示自己是否许愿了该物品
            -- 修复：确保每次检查都重新初始化为false
            local hasWished = false
            local myDkp = "0"
            
            for i = 1, table.getn(XyArray) do
                local info = XyArray[i]
                if info and info["name"] == playerName and info["xy"] and info["xy"] ~= "---未许愿---" then
                    local success, wishItem = pcall(ExtractItemName, info["xy"])
                    if success and type(wishItem) == "string" and wishItem ~= "" and wishItem ~= "---未许愿---" then
                        
                        local cleanWishItem = safeCleanString(wishItem)
                        
                        -- 修复：添加directCleanItemName空值检查，确保使用严格的相等比较
                        if directCleanItemName ~= "" and (cleanWishItem == directCleanItemName or wishItem == msg) then
                            hasWished = true
                            myDkp = info["dkp"] or "0"
                            break
                        end
                    end
                end
            end
            
            if hasWished then
                local announcement = "★"..directCleanItemName.."★我已许愿（"..myDkp.."分）"
                local currentLanguage = GetDefaultLanguage("player")
                SendChatMessage(announcement, "RAID", currentLanguage, nil)
            end
        end
    end
end



-- 新增：从LOOT消息中提取物品和玩家信息
function XyTracker_ExtractLootInfo(message)
    if not message then
        return nil, nil
    end
    
    -- 尝试多种可能的LOOT消息格式
    -- 1. 物品被分配给玩家的格式
    local playerName, itemName = string.match(message, "(.-)获得了物品：(.-)。")
    if not (playerName and itemName) then
        playerName, itemName = string.match(message, "(.-)获得了物品：(.-)。")
    end
    if not (playerName and itemName) then
        playerName, itemName = string.match(message, "(.-)赢得了物品：(.-)。")
    end
    if not (playerName and itemName) then
        playerName, itemName = string.match(message, "(.-)赢得了物品：(.-)。")
    end
    if not (playerName and itemName) then
        playerName, itemName = string.match(message, "(.-) received item: (.-)%.")
    end
    
    -- 2. 从物品链接中提取物品名称
    if playerName and not itemName then
        itemName = string.match(message, "|h%[([^%]]+)%]|h")
    end

    
    return playerName, itemName
end


-- 修改：同步拾取信息给队友，直接发送原始拾取消息
function XyTracker_SyncLootInfo(assignment)
    if not assignment or not assignment.playerName or not assignment.originalMessage then
        return
    end
    
    -- 构建同步消息：玩家名称:原始拾取消息
    local syncMsg = assignment.playerName .. ":" .. assignment.originalMessage
    
    -- 发送同步消息到团队
    SendAddonMessage("XY_LOOT_SYNC", syncMsg, "RAID")
end

-- 用于跟踪已接收的拾取信息，防止重复处理
local recentLootMessages = {}

-- 检测是否为重复的拾取信息（10秒内）
function XyTracker_IsDuplicateLoot(msg)
    if not msg or msg == "" then
        return false
    end
    
    local currentTime = GetTime()
    
    -- 清理过期的记录（超过10秒）
    for storedMsg, timestamp in pairs(recentLootMessages) do
        if currentTime - timestamp > 10 then
            recentLootMessages[storedMsg] = nil
        end
    end
    
    -- 检查是否有重复
    if recentLootMessages[msg] then
        return true-- 消息相同，返回false
    end
    -- 添加新记录
    recentLootMessages[msg] = currentTime
    return false -- 消息不同，返回true
end

-- 修改：接收其他团队成员的拾取同步信息
function XyTracker_ReceiveLootSync(syncMsg, senderName)
    if not syncMsg or syncMsg == "" then
        return
    end
    
    -- 解析同步消息：玩家名称:原始拾取消息
    local playerName, originalMessage = string.match(syncMsg, "(.-):(.*)")
    if not (playerName and itemLink and timeStr) then
        -- 尝试解析旧格式的消息作为兼容
        local oldPlayer, oldItem, oldHour, oldMinute = string.match(syncMsg, "(.-):(.-):(.-):(.-)")
        if oldPlayer and oldItem then
            playerName = oldPlayer
            itemLink = oldItem
            timeStr = oldHour .. ":" .. oldMinute
        else
            return -- 消息格式错误
        end
    end
        
    -- 队员接收团长的完整同步信息，直接处理
    local extractedItemLink = itemLink
    
    -- 提取物品名称
    local itemName
    if extractedItemLink then
        itemName = string.match(extractedItemLink, "|h%[([^%]]+)%]|h") or extractedItemLink
    else
        itemName = itemLink
        -- 如果没有物品链接，创建一个模拟的链接
        extractedItemLink = "|cff0070dd|Hitem:0:0:0:0:0:0:0:0|h[" .. itemName .. "]|h|r"
    end
    
    -- 记录到拾取列表
    local info = getXyInfo(playerName)
    local isWishItem = false
    
    if info and info["xy"] and info["xy"] ~= "---未许愿---" then
        local success, primaryWishItem, allWishItems = pcall(ExtractItemName, info["xy"])
        if success then
            local function cleanString(str)
                if not str then return "" end
                str = string.gsub(str, "|c%x+", "")
                str = string.gsub(str, "|r", "")
                str = string.gsub(str, "%[([^%]]+)%]", "%1")
                str = string.lower(str)
                return str
            end
            
            local cleanItemName = cleanString(itemName)
            
            if primaryWishItem and primaryWishItem ~= "" then
                local cleanPrimaryWishItem = cleanString(primaryWishItem)
                if cleanPrimaryWishItem == cleanItemName or primaryWishItem == itemName or string.find(cleanPrimaryWishItem, cleanItemName) or string.find(cleanItemName, cleanPrimaryWishItem) then
                    isWishItem = true
                end
            end
            
            if not isWishItem and type(allWishItems) == "table" and table.getn(allWishItems) > 0 then
                for _, wishItem in ipairs(allWishItems) do
                    local cleanWishItem = cleanString(wishItem)
                    if cleanWishItem == cleanItemName or wishItem == itemName or string.find(cleanWishItem, cleanItemName) or string.find(cleanItemName, cleanWishItem) then
                        isWishItem = true
                        break
                    end
                end
            end
        end
    end
    
    -- 提取物品信息来自动补齐分数和事件
    local itemID = ExtractItemID(extractedItemLink)
    local points = 0 -- 默认0分
    
    -- 如果物品信息可获取，尝试自动计算分数
    if itemID then
        local itemName, itemLink, quality, level, minLevel, type, subType, maxStack, equipLoc, texture, vendorPrice = GetItemInfo(itemID)
        if quality then
            -- 根据物品品质设置默认分数
            if quality >= 4 then -- 史诗
                points = 20
            elseif quality == 3 then -- 精良
                points = 10
            elseif quality == 2 then -- 优秀
                points = 5
            end
        end
    end
    
    -- 创建物品数据对象
    local lootItem = {
        itemName = tostring(itemName),
        itemLink = extractedItemLink and tostring(extractedItemLink) or "",
        playerName = playerName and tostring(playerName) or "未知玩家",
        points = points, -- 根据物品品质自动补齐分数
        isWish = isWishItem,
        timestamp = {
            hour = hour,
            minute = minute
        }
    }
    
    -- 添加到LootList并更新UI
    table.insert(LootList, lootItem)
    XyTracker_UpdateLootList()
    
    -- 处理拾取分配信息
    local assignment = {
        itemName = itemName,
        playerName = playerName,
        confirmed = true,
        timestamp = {hour = hour, minute = minute}
    }
    
    XyTracker_ProcessLootAssignment(assignment)
end

-- 处理团长发送的完整同步信息
function XyTracker_ReceiveCompleteLootSync(syncMsg, senderName)
    -- 只有非团长才处理完整同步信息
    if IsLeader then
        return
    end
    
    -- 检查发送者是否为团长
    local isLeader = UnitIsGroupLeader(senderName)
    if not isLeader then
        return -- 不是团长发送的信息，忽略
    end
    
    -- 调用现有的处理逻辑
    XyTracker_ReceiveLootSync(syncMsg, senderName)
end

-- 新增：处理拾取分配信息
function XyTracker_ProcessLootAssignment(assignment)
    if assignment.itemName and assignment.playerName then
        -- 标记为已确认
        assignment.confirmed = true
        
        -- 初始化物品链接变量
        local itemLink = nil
        
        -- 尝试从assignment中获取物品链接
        if assignment.itemLink then
            itemLink = assignment.itemLink
        else
            -- 如果没有链接，使用物品名称创建链接
            -- 默认使用蓝色作为物品颜色，确保自动扣分逻辑能触发
            itemLink = "|cff0070dd|Hitem:0:0:0:0:0:0:0:0|h[" .. assignment.itemName .. "]|h|r"
        end
        
        -- 处理自动扣分逻辑（如果需要）
        if XyTrackerOptions.autoMinDkp then
            -- 检查该玩家是否有出分记录（不再基于时间限制）
            local playerMessage = raidMessages[assignment.playerName]
            
            if playerMessage then
                -- 获取物品颜色
                local _, _, itemColor = string.find(itemLink, "|c(%x+)|H")
                local shouldDeduct = false
                
                -- 调试输出物品链接和颜色（仅在调试级别下显示）
                  if XyTracker_Print then
                     XyTracker_Print("物品链接: "..itemLink, XyTracker_DebugLevel.DEBUG)
                     XyTracker_Print("提取的颜色代码: "..(itemColor or "未找到"), XyTracker_DebugLevel.DEBUG)
                  end
                
                -- 无论物品颜色如何，都触发自动扣分逻辑
                -- 这确保了所有物品类型都会触发MarkItemAsCompleted函数
                shouldDeduct = true
                
                if shouldDeduct and IsLeader then
                    local info = getXyInfo(assignment.playerName)
                    if info then
                        local number = playerMessage.message
                        
                        -- 修改：支持多物品许愿，只标记已获得的物品为已完成
                        if info["xy"] == "|cFF00FFFF【已完成许愿】|r" then
                            -- 已完成许愿状态，直接扣分
                            info["dkp"] = tonumber(info["dkp"]) - number
                            SendChatMessage(assignment.playerName .. " 扣除" .. number .. "分，当前剩余分数：[" .. info["dkp"] .. "]", "RAID", this.language, nil)
                        elseif info["xy"] and info["xy"] ~= "---未许愿---" then
                            -- 有许愿内容时的处理
                            if number == 0 then
                                -- 0分情况：标记物品为已完成，不扣分
                                info["xy"] = MarkItemAsCompleted(info["xy"], assignment.itemName)
                                     if XyTrackerOptions.AutoAnnounce then
                                SendChatMessage(assignment.playerName .. " 已完成当前物品许愿，当前剩余分数：[" .. info["dkp"] .. "]", "RAID", this.language, nil)
                                end
                            elseif number == 5 then
                                -- 5分的情况：标记物品为已完成，不扣分
                                print("5分情况",info["xy"], assignment.itemName)
                                info["xy"] = MarkItemAsCompleted(info["xy"], assignment.itemName)
                                     if XyTrackerOptions.AutoAnnounce then
                                SendChatMessage(assignment.playerName .. " 已完成当前物品许愿（出5分），当前剩余分数：[" .. info["dkp"] .. "]", "RAID", this.language, nil)
                                end
                            elseif number <= 4 then
                                -- 1-4分的情况：扣除相应分数
                                info["dkp"] = tonumber(info["dkp"]) - number
                                SendChatMessage(assignment.playerName .. " 扣除" .. number .. "分，当前剩余分数：[" .. info["dkp"] .. "]", "RAID", this.language, nil)
                            else
                                -- 6分及以上的情况：标记物品为已完成并扣除相应分数
                                local deductPoints = number - 5
                                info["xy"] = MarkItemAsCompleted(info["xy"], assignment.itemName)
                                info["dkp"] = tonumber(info["dkp"]) - deductPoints
                                     if XyTrackerOptions.AutoAnnounce then
                                SendChatMessage(assignment.playerName .. " 已完成当前物品许愿，并扣除" .. deductPoints .. "分（出" .. number .. "分-5分），当前剩余分数：[" .. info["dkp"] .. "]", "RAID", this.language, nil)
                            end
                            end
                        end
                        
                        XyTracker_UpdateList()
                        syncXy()
                        
                        -- 只清除获得物品玩家的发言记录
                        raidMessages[assignment.playerName] = nil
                    end
                end
            end
        end
        
        -- 记录所有拾取的物品到拾取列表，无论是否花费分数
        local itemName = assignment.itemName
        
        -- 获取玩家信息
        local info = getXyInfo(assignment.playerName)
        
        -- 确定物品是否为许愿物品
        local isWishItem = false
        if info and info["xy"] and info["xy"] ~= "---未许愿---" then
            -- 使用ExtractItemName检查玩家是否许愿了当前物品
            local success, primaryWishItem, allWishItems = pcall(ExtractItemName, info["xy"])
            if success then
                -- 使用我们优化的全局safeCleanString函数进行清理
                local cleanItemName = safeCleanString(itemName)
                
                -- 检查主物品名称是否匹配
                if primaryWishItem and primaryWishItem ~= "" then
                    local cleanPrimaryWishItem = safeCleanString(primaryWishItem)
                    if cleanPrimaryWishItem == cleanItemName or 
                       primaryWishItem == itemName or 
                       string.find(cleanPrimaryWishItem, cleanItemName) or 
                       string.find(cleanItemName, cleanPrimaryWishItem) then
                        isWishItem = true
                    end
                end
                
                -- 如果主物品不匹配，检查其他物品名称
                if not isWishItem and type(allWishItems) == "table" and table.getn(allWishItems) > 0 then
                    for _, wishItem in ipairs(allWishItems) do
                        local cleanWishItem = safeCleanString(wishItem)
                        if cleanWishItem == cleanItemName or 
                           wishItem == itemName or 
                           string.find(cleanWishItem, cleanItemName) or 
                           string.find(cleanItemName, cleanWishItem) then
                            isWishItem = true
                            break
                        end
                    end
                end
            end
        end
        
        -- 确定扣除的分数（如果有）
        local pointsUsed = 0
        
        -- 加强数据验证和类型转换，确保添加的物品数据格式正确
       -- 使用本地时间而非服务器时间
        local hour, minute = tonumber(date("%H")), tonumber(date("%M"))
        
        -- 确保player是有效的字符串
        local validPlayerName = assignment.playerName and tostring(assignment.playerName) or "未知玩家"
        
        -- 创建物品数据对象，确保所有字段类型正确
        local lootItem = {
            itemName = tostring(itemName),
            itemLink = itemLink and tostring(itemLink) or "",
            playerName = validPlayerName,
            points = type(pointsUsed) == "number" and pointsUsed or 0,
            isWish = type(isWishItem) == "boolean" and isWishItem or false,
            timestamp = {
                hour = type(hour) == "number" and hour or 0,
                minute = type(minute) == "number" and minute or 0
            }
        }
        
        -- 重要：只有团长才执行本地物品拾取逻辑并发送同步信息
        -- 团员将完全依赖团长同步的数据，确保所有人显示一致
        if IsLeader then
            -- 根据物品品质和设置决定是否添加到LootList
            local shouldAdd = false
            local itemQuality = 5 -- 默认紫色史诗
            local itemName, itemLink, quality = GetItemInfo(lootItem.itemLink)
            if quality and type(quality) == "number" then
                itemQuality = quality
            end
            
            -- 橙色物品(品质5)总是添加
            if itemQuality == 5 then
                shouldAdd = true
            -- 紫色物品(品质4)根据设置
            elseif itemQuality == 4 then
                shouldAdd = XyTrackerOptions.purpleModeEnabled
            -- 蓝色物品(品质3)根据设置
            elseif itemQuality == 3 then
                shouldAdd = XyTrackerOptions.blueModeEnabled
            -- 绿色物品(品质2)根据设置
            elseif itemQuality == 2 then
                shouldAdd = XyTrackerOptions.greenModeEnabled
            end
            
            -- 只有符合条件的物品才添加到LootList
            if shouldAdd then
                table.insert(LootList, lootItem)
            end
            
            -- 更新拾取列表UI
            XyTracker_UpdateLootList()
            
            -- 同步拾取列表给团队成员（只同步最新的物品）
            -- 确保拾取一件物品就发送一条同步信息
            syncLootList(true)
        end
        
        -- 自动刷新拾取列表
        XyTracker_UpdateLootList()
    end
end


-- 检测聊天中的物品链接并通报许愿信息
-- 重复的函数定义已被删除，保留第807行的修复版本


function XyTracker_OnEvent(event)
	-- 处理插件加载完成事件
	if event == "ADDON_LOADED" and arg1 == "XyTracker" then
		-- 确保斜杠命令已注册
		SlashCmdList["XYTRACKER"] = XyTracker_OnSlashCommand
		XyTracker_Print("插件加载完成，斜杠命令已注册", XyTracker_DebugLevel.INFO)
		return
	end
	
	-- 处理变量加载完成事件，确保在所有保存的变量加载后执行
	if event == "VARIABLES_LOADED" then
		XyTracker_LoadCustomStarttext()
		-- 确保斜杠命令已注册
		SlashCmdList["XYTRACKER"] = XyTracker_OnSlashCommand
		
		-- 初始化dkpTime和rollTime，确保它们在重载后能正确保存
		InitializeXyTrackerOptions()
		
		-- 创建小地图图标
		XyTracker_CreateMinimapButton()
		-- 初始化按钮位置
		XyButton_UpdatePosition()
		return
	end
	
	-- 处理玩家登出事件，确保在退出游戏时保存数据
	if event == "PLAYER_LOGOUT" then
		XyTracker_SaveCustomStarttext()
		-- 确保dkpTime和rollTime被正确保存
		if XyTrackerOptions then
			-- 转换为数字类型以确保数据正确性
			if XyTrackerOptions.dkpTime then
				XyTrackerOptions.dkpTime = tonumber(XyTrackerOptions.dkpTime) or 30
			end
			if XyTrackerOptions.rollTime then
				XyTrackerOptions.rollTime = tonumber(XyTrackerOptions.rollTime) or 30
			end
		end
		return
	end
	
	-- ROLL点超时检查
	if isRolling and GetTime() > rollEndTime then
		RollEnd()
	end
    if event == "CHAT_MSG_RAID" or event == "CHAT_MSG_RAID_LEADER" then

        -- 检查消息是否为0-9的数字，如果是则处理出分拍卖
        local number = tonumber(arg1)
        
        if number and number >= 0 and number <= 9 then
            -- 处理出分拍卖消息
            XYT_ProcessAuctionMessage(arg1, arg2)
            
            -- 更新玩家发言记录
            raidMessages[arg2] = {
                message = number,
                timestamp = GetTime()
            }
        end
          if IsLeader then
          XyTracker_OnSystemMessage()  -- 添加这行来处理系统消息
          end
    end
    -- 检测物品获取
    if event == "CHAT_MSG_LOOT" then
        local player, itemLink = string.match(arg1, "(.+)获得了物品：(.+)。")
        if player and player == "你" then
            player = UnitName("player")
        end
        -- 检查itemLink是否为nil，避免连接错误
        if player and itemLink then
            local msg = player.."获得了物品："..itemLink.."。"
      
        -- 先检查消息是否重复，不重复的才处理
        if not XyTracker_IsDuplicateLoot(msg) then
        
            XyTracker_CHATMSGLOOT(msg)
        end
        end
    end
        -- 新增：团队聊天中检测物品链接并通报（非许愿阶段）
    if (event == "CHAT_MSG_RAID" or event == "CHAT_MSG_RAID_LEADER" or event == "CHAT_MSG_RAID_WARNING") then
        CheckItemAndAnnounceWish(arg1, arg2)
    end
    
    --查询许愿
    if event == "CHAT_MSG_WHISPER" then
        if arg1 == "cxxy" then
            XyQuery(arg2)
        end
    end
    -- 团长点开始许愿,所有团员的禁用团长权限,离开队伍后恢复
    if event == "CHAT_MSG_ADDON" and arg1 == "XY_START" and not IsLeader then
        DisableLeaderOperation()
        LeaderName = arg4 
        XyTracker_UpdateLeaderText()  -- 更新UI显示
        -- 请求LootList同步数据
        SendAddonMessage("XY_LOOTLIST_SYNC_REQUEST", "", "RAID")
    end
    --发送许愿
    if event == "CHAT_MSG_ADDON" and arg1 == "XY_SYNC_NEW" and IsLeader then
        syncXy()
    end
    --同步许愿
    if event == "CHAT_MSG_ADDON" and arg1 == "XY_SYNC" and not IsLeader then
        receiveXySync(arg2)
        LeaderName = arg4  
        XyTracker_UpdateLeaderText()  -- 更新UI显示
    end
    -- 同步LootList数据
    if event == "CHAT_MSG_ADDON" and arg1 == "XY_LOOTLIST_SYNC" then
        -- 团长不接收XY_LOOTLIST_SYNC信息
        if not IsLeader then
            receiveLootListSync(arg2)
        end
    end
    -- 接收LootList同步请求
    if event == "CHAT_MSG_ADDON" and arg1 == "XY_LOOTLIST_SYNC_REQUEST" and IsLeader then
        -- 只有团长才响应LootList同步请求
        -- 修改：响应同步请求时也只同步最新物品，不同步所有数据
        if LootList and table.getn(LootList) > 0 then
            -- 获取最新的物品
            local latestItem = LootList[table.getn(LootList)]
            if latestItem then
                -- 构建并发送最新物品的同步消息
                local itemID = ExtractItemID(latestItem.itemLink)
                local points = latestItem.points or 0
                local isWish = latestItem.isWish and 1 or 0
                local safePlayerName = latestItem.playerName or ""
                local hour = latestItem.timestamp and latestItem.timestamp.hour or 0
                local minute = latestItem.timestamp and latestItem.timestamp.minute or 0
                
                safePlayerName = string.gsub(safePlayerName, "|", "||")
                local safeItemName = string.gsub(latestItem.itemName or "未知物品", "|", "||")
                
                -- 获取物品品质信息
                local itemQuality = 5 -- 默认紫色史诗
                local itemName, itemLink, quality = GetItemInfo(itemID)
                if quality and type(quality) == "number" then
                    itemQuality = quality
                end
                
                local chunkData = string.format(";i=%s,n=%s,f=%d,x=%d,p=%s,t=%02d:%02d,q=%d",
                    itemID,
                    safeItemName,
                    points,
                    isWish,
                    safePlayerName,
                    hour,
                    minute,
                    itemQuality
                )
                
                local message = string.format("%d:%d:%d%s",
                    table.getn(LootList),
                    table.getn(LootList),  -- 起始索引设为总物品数，确保只发送最新物品
                    table.getn(LootList),  -- 结束索引为总物品数
                    chunkData
                )
                
                SendAddonMessage("XY_LOOTLIST_SYNC", message, "RAID")
            end
        end
    end
    
    -- 处理队员发送的拾取信息（仅团长接收）
    if event == "CHAT_MSG_ADDON" and arg1 == "XY_MEMBER_LOOT" and IsLeader then
      if not XyTracker_IsDuplicateLoot(arg2) then     
            XyTracker_CHATMSGLOOT(arg2)
        end
    -- 处理团队成员同步的拾取信息
    elseif event == "CHAT_MSG_ADDON" and arg1 == "XY_LOOT_SYNC" then
        -- 所有玩家都接收XY_LOOT_SYNC消息（但团长不处理自己发送的）
        if not IsLeader then
            XyTracker_ReceiveLootSync(arg2, arg4) -- arg4是发送者名称
        end
    -- 处理团长发送的完整同步信息
    elseif event == "CHAT_MSG_ADDON" and arg1 == "XY_LOOT_COMPLETE_SYNC" then
        -- 接收团长发送的完整同步信息
        XyTracker_ReceiveCompleteLootSync(arg2, arg4)
    end
    --加入团队的时候请求同步数据
    if event == "CHAT_MSG_SYSTEM" and (arg1 == "你加入了一个团队。" or string.find(arg1, "加入了一个团队")) then
        -- 发送同步请求但保留现有LootList数据
        SendAddonMessage("XY_SYNC_NEW", "", "RAID")
        -- 发送LootList同步请求
        SendAddonMessage("XY_LOOTLIST_SYNC_REQUEST", "", "RAID")
        -- 确保更新拾取列表UI显示
        XyTracker_UpdateLootList()
    
    -- 监控玩家交易信息并在团队频道播报
    elseif event == "CHAT_MSG_SYSTEM" and string.find(arg1, "trades item") then
        -- 只有团长才进行播报
        if IsLeader then
            -- 延迟一小段时间确保消息准确获取
            local delayFrame = CreateFrame("Frame")
            delayFrame.elapsed = 0
            delayFrame.tradeMessage = arg1
            delayFrame.count = 0
            delayFrame:SetScript("OnUpdate", function()
          
                this.elapsed = this.elapsed + arg1
                if this.elapsed >= 0.5 and this.count < 3 then
                    this.elapsed = 0
                    this.count = this.count + 1
                    -- 在团队频道播报交易信息（红色文本）
                    SendChatMessage("|cffff0000[交易监控] " .. this.tradeMessage.."|r", "RAID", nil, nil)
                    
                    -- 如果已经播报了3次，移除OnUpdate处理
                    if this.count >= 3 then
                        this:SetScript("OnUpdate", nil)
                    end
                end
            end)
        end
    end
    
    -- 团队成员变动时的处理（当有新成员加入时）
    if event == "GROUP_ROSTER_UPDATE" then
        -- 对于团长：已移除定期广播LootList数据的逻辑，只在拾取时发送一次
        
        -- 对于团员：检查是否有LootList数据，如果没有则请求同步
        if not IsLeader then
            if LootList and table.getn(LootList) == 0 then
                -- 避免频繁请求，只在需要时发送请求
                local currentTime = GetTime()
                if not lastSyncRequestTime or (currentTime - lastSyncRequestTime) > 5 then
                    lastSyncRequestTime = currentTime
                    SendAddonMessage("XY_LOOTLIST_SYNC_REQUEST", "", "RAID")
                end
            end
        end
    end
    --离开队伍后恢复团长功能
    if event == "CHAT_MSG_SYSTEM" and arg1 == "你已经离开了这个团队" then
        IsLeader = false
        -- 先隐藏停止按钮
        getglobal("XyTrackerFrameStopButton"):Hide();
        EnableLeaderOperation()
    end
	-- 修复ROLL点监控逻辑，确保正确捕获ROLL点消息
	if event == "CHAT_MSG_SYSTEM" and XYT_IsRecordingRoll and XYT_Roll_EndTime and GetTime() < XYT_Roll_EndTime then
		-- 尝试多种ROLL点消息格式
		local patterns = {
			"(.+)掷出(%d+)（(%d+)-(%d+)）",  -- 中文格式
			"(.+)rolls (%d+) %((%d+)-(%d+)%)",  -- 英文格式
			"(.+)掷出(%d+)点（(%d+)-(%d+)）"   -- 另一种中文格式
		}
		
		local player, roll, min_roll, max_roll
		for _, pattern in ipairs(patterns) do
			local match = string.find(arg1, pattern)
			if match then
				_, _, player, roll, min_roll, max_roll = string.find(arg1, pattern)
				break
			end
		end
		
		-- 确保是1-100的标准ROLL点
		if player and roll and min_roll and max_roll and min_roll=="1" and max_roll=="100" then
			-- 检查玩家是否已经ROLL过，只记录第一次ROLL点
			if not XYT_Roll_Scores[player] then
				-- 记录ROLL点到XYT_Roll_Scores
				XYT_Roll_Scores[player] = roll
				
				-- 获取玩家许愿信息
				local xyInfo = getXyInfo(player)
				if xyInfo then
					XYT_Roll_Wishes[player] = xyInfo["xy"] or "---未许愿---"
				else
					XYT_Roll_Wishes[player] = "---未许愿---"
				end
				
				-- 调试输出
				-- DEFAULT_CHAT_FRAME:AddMessage("XYTracker: 记录ROLL点 - " .. player .. " 掷出 " .. roll)
			else
				-- 玩家已经ROLL过，输出提示信息
				DEFAULT_CHAT_FRAME:AddMessage("|cffff0000XYTracker: " .. player .. " 已经ROLL过，忽略重复ROLL点|r")
			end
			
			-- 更新显示列表
			XYT_UpdateRollDisplay()
		end
	end
end




    -- 检测物品获取
    function XyTracker_CHATMSGLOOT(msg)
        local player, itemLink = string.match(msg, "(.+)获得了物品：(.+)。")
        if player and itemLink then    
            -- 非团长玩家检测到拾取信息时，发送同步消息给团长
            if not IsLeader then
                -- 构建同步消息：原始拾取消息
                local syncMsg =  msg
                -- 发送同步消息到插件通讯频道（队员发送给团长）
                SendAddonMessage("XY_MEMBER_LOOT", syncMsg, "RAID")
            end
            
            -- 当玩家自己获得物品且有权限时，也处理许愿完成逻辑
            local isSelfLoot = player == UnitName("player")
            
            -- 先处理自动扣分逻辑（如果需要）
            if XyTrackerOptions.autoMinDkp then
                -- 检查该玩家是否有出分记录（不再基于时间限制）
                local playerMessage = raidMessages[player]
                
                if playerMessage then
                    local _, _, itemColor = string.find(itemLink, "|c(%x+)|H")
                    local shouldDeduct = false
                    
                    if itemColor == "ffa335ee" and XyTrackerOptions.purpleModeEnabled then
                        shouldDeduct = true
                    elseif itemColor == "ff0070dd" and XyTrackerOptions.blueModeEnabled then
                        shouldDeduct = true
                    elseif itemColor == "ff1eff00" and XyTrackerOptions.greenModeEnabled then
                        shouldDeduct = true
                    end
                    
                    if shouldDeduct and (IsLeader or isSelfLoot) then  -- 团长或自己获得物品时都处理
                        local info = getXyInfo(player)
                        if info then
                            local number = playerMessage.message
                            
                            -- 修改：支持多物品许愿，使用MarkItemAsCompleted函数处理已完成许愿的显示逻辑
                            if info["xy"] == "|cFF00FFFF已完成许愿|r" then
                                -- 已完成许愿状态，直接扣分
                                info["dkp"] = tonumber(info["dkp"]) - number
                                SendChatMessage(player .. " 扣除" .. number .. "分，当前剩余分数：[" .. info["dkp"] .. "]", "RAID", this.language, nil)
                            elseif info["xy"] and info["xy"] ~= "---未许愿---" then
                                -- 有许愿内容时的处理
                                if number == 0 or number == 5 or number > 5 then
                                    -- 提取物品名称（用于匹配）
                                    local itemName = string.match(itemLink, "|h%[(.-)%]|h")
                                    if not itemName then
                                        itemName = itemLink -- 如果无法提取物品名称，使用整个链接
                                    end
                                                             
                                    -- 调用MarkItemAsCompleted函数更新许愿状态
                                    local newWish = MarkItemAsCompleted(info["xy"], itemName)
                                    
                                    -- 如果许愿状态发生变化
                                    if newWish ~= info["xy"] then
                                        info["xy"] = newWish
                                        
                                        -- 根据不同情况发送相应的消息
                                        if number == 0 then
                                            -- 团长或自己获得物品时都发送消息
                                            if XyTrackerOptions.AutoAnnounce and (IsLeader or isSelfLoot) then
                                                SendChatMessage(player .. " 已完成当前物品许愿，当前剩余分数：[" .. info["dkp"] .. "]", "RAID", this.language, nil)
                                            end
                                        elseif number == 5 then
                                            -- 团长或自己获得物品时都发送消息
                                            if IsLeader or isSelfLoot then
                                                SendChatMessage(player .. " 已完成当前物品许愿（出5分），当前剩余分数：[" .. info["dkp"] .. "]", "RAID", this.language, nil)
                                            end
                                        else
                                            local deductPoints = number - 5
                                            info["dkp"] = tonumber(info["dkp"]) - deductPoints
                                            -- 团长或自己获得物品时都发送消息
                                            if XyTrackerOptions.AutoAnnounce and (IsLeader or isSelfLoot) then
                                                SendChatMessage(player .. " 已完成当前物品许愿，并扣除" .. deductPoints .. "分（出" .. number .. "分-5分），当前剩余分数：[" .. info["dkp"] .. "]", "RAID", this.language, nil)
                                            end
                                        end
                                    else
                                        -- 如果没有匹配的物品，发送提示消息
                                        SendChatMessage(player .. " 获得的物品不在许愿列表中", "RAID", this.language, nil)
                                    end
                                elseif number <= 4 then
                                    -- 1-4分的情况：扣除相应分数
                                    info["dkp"] = tonumber(info["dkp"]) - number
                                    SendChatMessage(player .. " 扣除" .. number .. "分，当前剩余分数：[" .. info["dkp"] .. "]", "RAID", this.language, nil)
                                end
                            end
                            
                            XyTracker_UpdateList()
                            syncXy()
                            
                            -- 只清除获得物品玩家的发言记录
                            raidMessages[player] = nil
                            
                            -- 保存扣除的分数以便在拾取列表中显示
                            local deductedPoints = 0
                            if number <= 4 then
                                deductedPoints = number
                            else
                                deductedPoints = number - 5
                            end
                            
                            -- 存储在临时变量中，供下面的拾取列表使用
                            if not tempDeductedPoints then
                                tempDeductedPoints = {}
                            end
                            tempDeductedPoints[player] = deductedPoints
                        end
                    end
                end
            end
            
            -- 记录所有拾取的物品到拾取列表，无论是否花费分数
            local itemName = string.match(itemLink, "|h%[([^%]]+)%]|h")
            if itemName then
                -- 获取玩家信息
                local info = getXyInfo(player)
                
                -- 确定物品是否为许愿物品
                local isWishItem = false
                if info and info["xy"] and info["xy"] ~= "---未许愿---" then
                    -- 使用ExtractItemName检查玩家是否许愿了当前物品
                    local success, primaryWishItem, allWishItems = pcall(ExtractItemName, info["xy"])
                    if success then
                        -- 简单清理物品名称（去掉多余字符）
                        local function cleanString(str)
                            if not str then return "" end
                            str = string.gsub(str, "|c%x+", "")
                            str = string.gsub(str, "|r", "")
                            str = string.gsub(str, "%[([^%]]+)%]", "%1")
                            str = string.lower(str)
                            return str
                        end
                        
                        local cleanItemName = cleanString(itemName)
                        
                        -- 检查主物品名称是否匹配，包括已完成许愿的情况
                        if primaryWishItem and primaryWishItem ~= "" then
                            local cleanPrimaryWishItem = cleanString(primaryWishItem)
                            if cleanPrimaryWishItem == cleanItemName or primaryWishItem == itemName or string.find(cleanPrimaryWishItem, cleanItemName) or string.find(cleanItemName, cleanPrimaryWishItem) then
                                isWishItem = true
                            end
                        end
                        
                        -- 额外检查是否已完成过该物品的许愿
                        if not isWishItem and string.find(info["xy"], "已完成许愿") then
                            -- 如果已经是已完成许愿状态，但当前物品未被匹配，也标记为许愿物品
                            isWishItem = true
                        end
                        
                        -- 如果主物品不匹配，检查其他物品名称
                        if not isWishItem and type(allWishItems) == "table" and table.getn(allWishItems) > 0 then
                            for _, wishItem in ipairs(allWishItems) do
                                local cleanWishItem = cleanString(wishItem)
                                if cleanWishItem == cleanItemName or wishItem == itemName or string.find(cleanWishItem, cleanItemName) or string.find(cleanItemName, cleanWishItem) then
                                    isWishItem = true
                                    break
                                end
                            end
                        end
                    end
                end
                
                -- 确定扣除的分数（如果有）
                local pointsUsed = 0
                if tempDeductedPoints and tempDeductedPoints[player] then
                    pointsUsed = tempDeductedPoints[player]
                    -- 清除临时存储的分数，避免影响其他物品
                    tempDeductedPoints[player] = nil
                end
                
                -- 如果是许愿物品，无论玩家是否打数字，都自动标记为已许愿
                if isWishItem and info and info["xy"] and info["xy"] ~= "---未许愿---" and not string.find(info["xy"], "已完成许愿") then
                    -- 调用MarkItemAsCompleted函数更新许愿状态
                    local newWish = MarkItemAsCompleted(info["xy"], itemName)
                    
                    -- 如果许愿状态发生变化
                    if newWish ~= info["xy"] then
                        info["xy"] = newWish
                        
                        -- 无论是否打数字，只要是许愿物品就发送已完成许愿的消息
                        -- 团长或自己获得物品时都发送消息
                        if XyTrackerOptions.AutoAnnounce and (IsLeader or isSelfLoot) then
                            SendChatMessage(player .. " 已完成当前物品许愿，当前剩余分数：[" .. info["dkp"] .. "]", "RAID", this.language, nil)
                        end
                        -- 更新列表
                        XyTracker_UpdateList()
                        -- 只有团长同步数据
                        if IsLeader then
                            syncXy()
                        end
                    end
                end
                

                    -- 只有在有IsLeader信息的情况下才自动记录拾取列表
                if IsLeader ~= nil then
                    -- 加强数据验证和类型转换，确保添加的物品数据格式正确
                   -- 使用本地时间而非服务器时间
                    local hour, minute = tonumber(date("%H")), tonumber(date("%M"))
                    
                    -- 确保player是有效的字符串
                    local validPlayerName = player and tostring(player) or "未知玩家"
                    
                    -- 创建物品数据对象，确保所有字段类型正确
                    local lootItem = {
                        itemName = tostring(itemName),
                        itemLink = itemLink and tostring(itemLink) or "",
                        playerName = validPlayerName,
                        points = type(pointsUsed) == "number" and pointsUsed or 0,
                        isWish = type(isWishItem) == "boolean" and isWishItem or false,
                        timestamp = {
                            hour = type(hour) == "number" and hour or 0,
                            minute = type(minute) == "number" and minute or 0
                        }
                    }
                    
                    -- 所有玩家都执行本地物品拾取逻辑，确保自己拾取的物品能被正常记录
                    -- 添加到LootList并更新UI
                    table.insert(LootList, lootItem)
                    
                    -- 更新拾取列表UI
                    XyTracker_UpdateLootList()
                    if IsLeader then
                        -- 传递当前lootItem对象，确保发送正确的物品信息
                        syncLootList(true, lootItem)
                    end
                end
            end
        end
    end
-- 处理系统消息，更新许愿信息
function XyTracker_OnSystemMessage()
    -- 在处理信息之前就根据XY开头直接录入信息
    if not XyInProgress then
        return
    end
    
    if string.lower(string.sub(arg1, 1, 2)) == "xy" then 
        local xytempText = string.gsub(arg1, "^[Xx][Yy]%s*", "")
        -- 直接设置许愿内容，不经过XyTracker_OnXy验证
        local info = getXyInfo(arg2)
        info["xy"] = xytempText
        XyTracker_UpdateList()
        syncXy()
        return
    end
    
    local values = {}
    for word in string.gmatch(arg1, "%S+") do
        table.insert(values, word)
    end



    local val1 = values[1]
    
    -- 原有的许愿处理逻辑 - 修改为支持多物品许愿
    if val1 and string.lower(val1) == "xy" and table.getn(values) > 1 then
        -- 检查是否包含多个物品链接
        -- 安全地移除开头的XY命令
        local xyText = ""
        if type(arg1) == "string" then
            local success, result = pcall(function()
                return string.gsub(arg1, "^[Xx][Yy]%s*", "")
            end)
            if success then
                xyText = result
            else
                xyText = arg1
            end
        end
        local hasMultipleItems = string.find(xyText, "|Hitem:.-|h.-|h.*|Hitem:.-|h.-|h")
        
        if hasMultipleItems then
            -- 处理多物品情况
            local itemCount = 0
            for itemLink in string.gmatch(xyText, "|Hitem:.-|h.-|h") do
                itemCount = itemCount + 1
                if itemCount > 1 then -- 跳过第一个物品，避免重复处理
                    XyTracker_OnXy(arg2, itemLink)
                end
            end
        end
        
        -- 处理第一个物品（保持原有逻辑）
        local Xy = values[2]
        XyTracker_OnXy(arg2, Xy)
        XyTracker_UpdateList()
        syncXy()
    elseif val1 and string.lower(val1) == "txy" and table.getn(values) > 2 then
        local player = values[2]
        local Xy = values[3]
        XyTracker_OnXy(player, Xy)
        XyTracker_UpdateList()
        syncXy()
    elseif XyTrackerOptions.XyOnlyMode == 0 and arg1 and string.find(arg1, "|Hitem:") then
        -- 检查是否包含多个物品链接
        local hasMultipleItems = string.find(arg1, "|Hitem:.-|h.-|h.*|Hitem:.-|h.-|h")
        
        if hasMultipleItems then
            -- 处理多物品情况
            local itemCount = 0
            for itemLink in string.gmatch(arg1, "|Hitem:.-|h.-|h") do
                itemCount = itemCount + 1
                if itemCount > 1 then -- 跳过第一个物品，避免重复处理
                    XyTracker_OnXy(arg2, itemLink)
                end
            end
        end
        
        -- 处理第一个物品（保持原有逻辑）
        local Xy = arg1
        XyTracker_OnXy(arg2, Xy)
        XyTracker_UpdateList()
        syncXy()
    end
end

function receiveXySync(msg)
    DisableLeaderOperation()
    -- 标记开始接收同步数据
    IsReceivingSync = true
    --获取同步开始
    for n, x in string.gfind(msg, "n=(.+),x=(.+)") do
        Xys = x
        XyArray = {}
        XyTracker_UpdateList()
        
        -- 【重要】设置数据变更标记，确保在游戏退出时自动保存
        _G["XyTracker_SavedWishList_LastUpdate"] = time()
        -- 记录当前XyArray的实际大小，用于验证
        _G["XyTracker_ArraySize_LastRecord"] = table.getn(XyArray)
        return
    end
    for p, c, x, s in string.gfind(msg, "p=(.+),c=(.+),x=(.+),s=(.+)") do
        -- 检查玩家是否已存在
        local playerExists = false
        local n = table.getn(XyArray)
        local oldXy = ""
        
        for i = 1, n do
            if XyArray[i]["name"] == p then
                playerExists = true
                oldXy = XyArray[i]["xy"] or ""
                -- 更新现有玩家的数据
                XyArray[i]["class"] = c
                if x == "---未许愿---" then
                    XyArray[i]["xy"] = ""
                else
                    XyArray[i]["xy"] = x
                end
                XyArray[i]["dkp"] = s
                break
            end
        end
        
        -- 如果玩家不存在，则添加新记录
        if not playerExists then
            local info = {}
            info["name"] = p
            info["class"] = c
            if x == "---未许愿---" then
                info["xy"] = ""
            else
                info["xy"] = x
            end
            info["dkp"] = s
            table.insert(XyArray, info)
        end
        
        -- 检查是否发生了许愿变更（从无到有或内容改变）
        -- 重要修复：在接收同步数据时不发送公告，避免重复公告
        if XyTrackerOptions.AutoAnnounce and x ~= "---未许愿---" and x ~= "" and x ~= oldXy and not IsReceivingSync then
            -- 触发重复许愿检查
            local itemName = ExtractItemName(x)
            local count = 0
            for i = 1, table.getn(XyArray) do
                local currentXY = ExtractItemName(XyArray[i]["xy"] or "")
                if currentXY == itemName then
                    count = count + 1
                end
            end
            
            if count >= 2 then
                -- 使用全局的安全字符串清理函数
                local cleanItemName = safeCleanString(itemName)
                
                -- 重要修复：确保cleanItemName不为空
                if cleanItemName == "" and itemName ~= "" then
                    cleanItemName = itemName -- 回退到原始名称
                end
                
                -- 只有当cleanItemName确实有内容时才发送公告
                if cleanItemName ~= "" then
                    local currentLanguage = GetDefaultLanguage("player")
                    SendChatMessage("☆"..cleanItemName.."☆已有 "..count.." 人许愿！", "RAID", currentLanguage, nil)
                end
            end
        end
        
        XyTracker_UpdateList()
        
        -- 【重要】设置数据变更标记，确保在游戏退出时自动保存
        _G["XyTracker_SavedWishList_LastUpdate"] = time()
        -- 记录当前XyArray的实际大小，用于验证
        _G["XyTracker_ArraySize_LastRecord"] = table.getn(XyArray)
    end
    
    -- 同步结束，重置标记
    IsReceivingSync = false
end

function syncXy(playerName)
    local n = table.getn(XyArray)
    local msg = "";
    
    -- 添加移除颜色标记的函数
    local function removeColorMarkup(text)
        if type(text) == "string" then
            -- 移除形如 |cFF00FF00 的颜色代码和 |r 重置代码
            text = string.gsub(text, "|c%x%x%x%x%x%x%x%x", "")
            text = string.gsub(text, "|r", "")
        end
        return text
    end
    
    -- 如果提供了playerName参数，只同步特定玩家的数据
    if playerName then
        -- DEFAULT_CHAT_FRAME:AddMessage("[XyTracker调试] 同步特定玩家: " .. playerName)
        local cleanPlayerName = removeColorMarkup(playerName)
        for i = 1, n do
            local info = XyArray[i]
            if info["name"] and removeColorMarkup(info["name"]) == cleanPlayerName then
                local player = info["name"]
                local xy = info["xy"] or "---未许愿---"
                local dkp = info["dkp"] or 4
                local class = info["class"] or "无"
                
                -- 发送数组大小信息
                msg = "n=" .. n .. ",x=" .. Xys
                SendAddonMessage("XY_SYNC", msg, "RAID")
                
                -- 只发送该玩家的数据
                msg = "p=" .. player .. ",c=" .. class .. ",x=" .. xy .. ",s=" .. dkp
                SendAddonMessage("XY_SYNC", msg, "RAID")
                break
            end
        end
    else
        -- 没有提供playerName参数时，同步所有数据
        -- DEFAULT_CHAT_FRAME:AddMessage("[XyTracker调试] 同步所有玩家许愿数据")
        if n > 0 then
            msg = "n=" .. n .. ",x=" .. Xys
            SendAddonMessage("XY_SYNC", msg, "RAID")
            for i = 1, n do
                local info = XyArray[i]
                local player = info["name"]
                local xy = info["xy"] or "---未许愿---"
                local dkp = info["dkp"] or 4
                local class = info["class"] or "无"
                msg = "p=" .. player .. ",c=" .. class .. ",x=" .. xy .. ",s=" .. dkp
                SendAddonMessage("XY_SYNC", msg, "RAID")
            end
        end
    end
end

function DisableLeaderOperation()
    --这个必须保留，避免团员在进团之前开过许愿 by 无道暴君 20250217
    XyInProgress = false
    getglobal("XyTrackerFrameStartButton"):Hide();
    getglobal("XyTrackerFrameStopButton"):Hide();
    getglobal("XyTrackerFrameResetButton"):Hide();
    -- 隐藏编辑文本按钮（队员模式）
    if getglobal("XyTrackerFrameEditStarttextButton") then
        getglobal("XyTrackerFrameEditStarttextButton"):Hide();
    end
    -- 未许愿人数按钮在团员模式下也显示
    --getglobal("XyTrackerFrameAnnounceButton"):Hide();
    -- 导出许愿按钮在团员模式下也显示
    --getglobal("XyTrackerFrameExportButton"):Hide();
    getglobal("XyTrackerFrameChuShiHua_DKP"):Hide();
    -- 团员端隐藏宣言相关按钮
    getglobal("XyTrackerFrameDeclarationButton"):Hide();
    getglobal("XyTrackerFrameAnnounceDeclarationButton"):Hide();
    getglobal("XyTrackerDeclarationLargeEditBox"):Hide();
end

function EnableLeaderOperation()
    XyInProgress = false
    getglobal("XyTrackerFrameStartButton"):Show();
    getglobal("XyTrackerFrameResetButton"):Show();
    -- 显示编辑文本按钮（团长模式）
    if getglobal("XyTrackerFrameEditStarttextButton") then
        getglobal("XyTrackerFrameEditStarttextButton"):Show();
    end
    getglobal("XyTrackerFrameAnnounceButton"):Show();
    getglobal("XyTrackerFrameExportButton"):Show();
    getglobal("XyTrackerFrameChuShiHua_DKP"):Show();
    -- 团长端显示宣言按钮
    getglobal("XyTrackerFrameDeclarationButton"):Show();
    getglobal("XyTrackerFrameAnnounceDeclarationButton"):Show();
end

function XyQuery(player, dkpnumber)

    local n = table.getn(XyArray)
    for i = 1, n do
        local name = XyArray[i]["name"]
        local xy = XyArray[i]["xy"]
        local currentDKP = XyArray[i]["dkp"] -- 直接使用存储的值，不做任何转换或限制
        
        if not xy then
            xy = ""
        end
        if player == name then
                if dkpnumber and dkpnumber ~= 0 then
                    dkpnumber = tonumber(dkpnumber) or 0;  -- 确保dkpnumber是数字类型
                    if dkpnumber > 0 then
                        SendChatMessage(player .. " 增加[" .. dkpnumber .. "]分,当前剩余分数：[" .. currentDKP .. "]", "RAID", this.language, nil);
                    else
                        SendChatMessage(player .. " 扣除[" .. 0 - dkpnumber .. "]分,当前剩余分数：[" .. currentDKP .. "]", "RAID", this.language, nil);
                    end
                else
                    SendChatMessage(player .. " 许愿[" .. xy .. "],当前剩余分数：[" .. currentDKP .. "]", "RAID", this.language, nil);
                end
                break -- 找到玩家后就退出循环
            end
    end
end


function XyTracker_OnXy(name, Xy)
    if not XyInProgress then
        return
    end
    
    local info = getXyInfo(name)
    
    -- 验证许愿内容：只允许纯物品链接
    local validatedWish = ""
    
    if Xy and Xy ~= "" then
        -- 首先检查是否只包含纯物品链接（允许连续或空格分隔）
        local tempText = string.gsub(Xy, "%s+", " ")  -- 标准化空白字符
        
        -- 检查是否只包含标准物品链接和简化物品链接
        local isValid = true
        
        -- 验证逻辑：只检查物品链接格式
            -- 创建一个临时字符串，移除所有有效的物品链接
            local temp = tempText
            
            -- 移除所有标准物品链接格式
            temp = string.gsub(temp, "|c%x%x%x%x%x%x%x%x|Hitem:[^|]+|h[^|]+|h|r", "")
            
            -- 移除所有简化物品链接格式
            temp = string.gsub(temp, "%[[^%]]+%]", "")
            
            -- 移除所有剩余的空白字符
            temp = string.gsub(temp, "%s+", "")
            
            -- 如果还有剩余内容，说明包含非法字符
            if temp ~= "" then
                isValid = false
            end
        
        
        -- 额外检查：确保至少有一个有效的物品链接
            local hasLink = false
            -- 检查是否有标准链接
            if string.find(tempText, "|c%x%x%x%x%x%x%x%x|Hitem:") then
                hasLink = true
            end
            -- 检查是否有简化链接
            if not hasLink and string.find(tempText, "%[[^%]]+%]") then
                hasLink = true
            end
            -- 如果没有任何链接，仍然视为无效
            if not hasLink then
                isValid = false
            end
        
        
        if isValid then
            -- 提取有效的物品链接
                -- 只包含物品链接，提取所有有效的物品链接
                local parts = {}
                local foundLinks = {} -- 用于去重的表
            
            -- 首先提取标准物品链接格式（优先级高）
            for link in string.gmatch(Xy, "(|c%x%x%x%x%x%x%x%x|Hitem:[^|]+|h[^|]+|h|r)") do
                -- 提取物品名称作为去重键
                local itemName = string.match(link, "|h%[(.-)%]|h|r$")
                if itemName and not foundLinks[itemName] then
                    foundLinks[itemName] = true
                    table.insert(parts, link)
                end
            end
            
            -- 然后提取简化物品链接格式（如[魔导书：恶魔之门]），避免重复
            for link in string.gmatch(Xy, "(%[[^%]]+%])") do
                -- 检查是否是有效的物品名称格式（不能为空）
                if string.match(link, "^%[[^%]]+%]$") and not string.match(link, "^%[%s*%]$") then
                    -- 提取物品名称作为去重键
                    local itemName = string.match(link, "^%[(.-)%]$" )
                    if itemName and not foundLinks[itemName] then
                        foundLinks[itemName] = true
                        table.insert(parts, link)
                    end
                end
            end
            
            -- 如果有找到物品链接，用空格分隔
            if table.getn(parts) > 0 then
                validatedWish = table.concat(parts, " ")
            else
                -- 如果没有找到任何物品链接，保持原来的许愿内容不变
                validatedWish = info["xy"] or ""  -- 保留原有内容
            end
        else
            -- 不符合要求的内容，保持原有许愿内容不变，不做任何操作
            validatedWish = info["xy"] or ""  -- 保留原有内容
            -- DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 许愿内容只能包含纯物品链接，请重新输入")
        end
    end
    
    info["xy"] = validatedWish
    
    -- 只有团长端会弹出界面
    if IsLeader then
    XyTracker_ShowXyWindow()
    end
    
    -- 新增：重复许愿检查 - 移除XyInProgress条件，确保无论是否点击停止按钮都能播报重复警报
    local itemName = ExtractItemName(Xy)
    local count = 0
    local currentLanguage = this.language or GetDefaultLanguage("player") -- 确保有有效的语言设置
    for i = 1, table.getn(XyArray) do
        local currentXY = ExtractItemName(XyArray[i]["xy"] or "")
        if currentXY == itemName then
            count = count + 1
        end
    end
    if XyTrackerOptions.AutoAnnounce and count >= 2 then
        -- 确保在多物品许愿场景下，每个物品的重复检查都能独立进行
        -- 使用全局的安全字符串清理函数
        local cleanItemName = safeCleanString(itemName)
        SendChatMessage("☆"..cleanItemName.."☆已有 "..count.." 人许愿！", "RAID", currentLanguage, nil)
    end
    
    -- 【重要】设置数据变更标记，确保在游戏退出时自动保存
    _G["XyTracker_SavedWishList_LastUpdate"] = time()
    -- 记录当前XyArray的实际大小，用于验证
    _G["XyTracker_ArraySize_LastRecord"] = table.getn(XyArray)
end

function XyTracker_OnStartButtonClick()
    -- 检查是否在队伍/团队中
    if GetNumRaidMembers() == 0 and GetNumPartyMembers() == 0 then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[XyTracker] 你不在一个团队中，无法开始|r")
        return
    end
    
    if GetNumRaidMembers() > 1 then
        IsLeader = true
        LeaderName = UnitName("player")  -- 记录当前玩家作为许愿权限拥有者
        XyTracker_UpdateLeaderText()  -- 更新UI显示

        local Starttext = XyTracker_GetCurrentStarttext()
	SendChatMessage(Starttext, "RAID", this.language, nil);
        XyInProgress = true
        
        -- 重新注册右键菜单按钮，确保团长权限按钮可见
        XyTracker_RegisterRightClickMenuButtons()
        
        -- 注释掉播报所有人许愿的代码
        -- XyTracker_AnnounceAllWishes()
        
        XyTracker_ShowXyWindow()
        --同步到团员端
        SendAddonMessage("XY_START", "", "RAID")
        -- 立即同步当前的LootList数据给所有团员
        XyTracker_UpdateList()
        
        -- 新增：如果当前有ROLL点监控窗口显示，则启动ROLL点计时器
        local rollFrame = getglobal("RollMonitorFrame");
        if rollFrame and rollFrame:IsVisible() and XYT_CurrentItem then
            -- 检查是否有正在进行的ROLL点拍卖
            if XYT_IsRecordingRoll then
                DEFAULT_CHAT_FRAME:AddMessage("ROLL点拍卖已经在进行中");
            else
                -- 启动ROLL点计时器，使用保存的rollTime设置
                local timeValue = tonumber(XyTrackerOptions.rollTime) or 30;
                XYT_Roll_EndTime = GetTime() + timeValue;
                XYT_IsRecordingRoll = true;
            end
            
            -- 确保有OnUpdate脚本用于动态更新剩余时间
            if not rollFrame:GetScript("OnUpdate") then
                rollFrame:SetScript("OnUpdate", function()
                    if XYT_IsRecordingRoll then
                        XYT_UpdateRollDisplay();
                    end
                end);
            end
            
            -- 发送ROLL点开始消息
            SendChatMessage("开始ROLL点拍卖：" .. XYT_CurrentItem .. "，请ROLL点", "RAID");
        end
    end
end

-- 更新许愿权限拥有者显示文本
function XyTracker_UpdateLeaderText()
 
    local leaderText = getglobal("XyTrackerLeaderText")
    if leaderText then
        -- 确保文本元素可见
        leaderText:Show()
    
        -- 设置正确的显示文本
        if LeaderName and LeaderName ~= "" then
            leaderText:SetText("许愿权：" .. LeaderName)
        else
            leaderText:SetText("许愿权：无人")
        end
        
        -- 添加调试信息，帮助排查问题
        -- DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 更新许愿权限拥有者显示: " .. (LeaderName or "无人"))
    else
        -- 尝试动态创建元素，确保显示
        if XyTrackerFrame and XyTrackerFrameStatusText then
            leaderText = XyTrackerFrame:CreateFontString("XyTrackerLeaderText", "ARTWORK", "GameFontNormalSmall")
            leaderText:SetPoint("LEFT", XyTrackerFrameStatusText, "LEFT", 88, 0)
            leaderText:SetWidth(180)
            leaderText:SetHeight(16)
            leaderText:SetTextColor(1.0, 0.82, 0)
            leaderText:SetJustifyH("LEFT")
            leaderText:SetJustifyV("MIDDLE")
            leaderText:Show()
            
            -- 设置文本内容
            if LeaderName and LeaderName ~= "" then
                leaderText:SetText("许愿权：" .. LeaderName)
            else
                leaderText:SetText("许愿权：无人")
            end
        end
    end
end

function XyTracker_OnStopButtonClick()
    SendChatMessage("许愿结束，后续许愿无效", "RAID", this.language, nil)
    XyInProgress = false
    
    -- 新增：如果当前有ROLL点监控窗口显示，则停止ROLL点计时器
    local rollFrame = getglobal("RollMonitorFrame");
    if rollFrame and rollFrame:IsVisible() and XYT_IsRecordingRoll then
        -- 停止ROLL点计时器
        XYT_IsRecordingRoll = false;
        XYT_Roll_EndTime = nil;
        
        -- 更新xytRollTime显示为0，表示ROLL点已停止
        getglobal("xytRollTime"):SetText("0");
        
        -- 发送ROLL点结束消息
        SendChatMessage("ROLL点拍卖结束", "RAID");
        
        -- 更新显示
        XYT_UpdateRollDisplay();
    end
end

-- 创建临时变量用于存储最近扣除的分数
local tempDeductedPoints = nil

function XyTracker_OnClearButtonClick()
    -- 弹出确认对话框
    StaticPopup_Show("XYTRACKER_CONFIRM_RESET")
    
    -- 新增：如果当前有ROLL点监控窗口显示，则清除ROLL点数据
    local rollFrame = getglobal("RollMonitorFrame");
    if rollFrame and rollFrame:IsVisible() then
        -- 清除ROLL点数据
        XYT_Roll_Scores = {};
        XYT_Roll_Wishes = {};
        XYT_IsRecordingRoll = false;
        XYT_Roll_EndTime = nil;
        
        -- 更新xytRollTime显示为0，表示ROLL点已清除
        getglobal("xytRollTime"):SetText("0");
        
        -- 更新显示
        XYT_UpdateRollDisplay();
    end
end

-- 注册静态弹窗
StaticPopupDialogs["XYTRACKER_CONFIRM_RESET"] = {
    text = "确定要重置所有成员的许愿数据吗？",
    button1 = "确定",
    button2 = "取消",
    OnAccept = function()
        XyTracker_DoActualClear()  -- 实际执行重置
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true
}

function XyTracker_DoActualClear()
    XyArray = {}
    XyItemCount = {}  -- 新增：清空物品计数
    -- 注意：LootList 不会在这里清空，只有调用 XyTracker_ClearLootList() 才会清空拾取列表
    -- 这样可以确保数据保存直到手动按下清除按钮
    local totalMembers = GetNumRaidMembers()
    if totalMembers then
        for i = 1, totalMembers do
            local name, rank, subgroup, level, class, fileName, zone, online = GetRaidRosterInfo(i);
            info = {}
            info["name"] = name
            info["class"] = class
            info["dkp"] = 4
            info["xy"] = "---未许愿---"
            table.insert(XyArray, info)
            NoXyList = NoXyList .. name .. " "
        end
    end
    XyTracker_UpdateList()
    if IsLeader then
        syncXy()
    end
end

function XyTracker_OnRefreshButtonClick()
    local totalMembers = GetNumRaidMembers()
    if totalMembers then
        -- 创建一个临时表来存储现有的许愿信息，使用玩家名字作为索引
        local existingWishes = {}
        for i = 1, table.getn(XyArray) do
            local info = XyArray[i]
            existingWishes[info["name"]] = {
                index = i,
                xy = info["xy"],
                dkp = info["dkp"] or DefaultDKP,
                class = info["class"]
            }
        end
        
        -- 检查当前团队中的所有成员，确保他们在XyArray中有记录
        for i = 1, totalMembers do
            local name, rank, subgroup, level, class = GetRaidRosterInfo(i)
            
            -- 如果该玩家之前有许愿信息，则更新职业（可能有变化）
            if existingWishes[name] then
                XyArray[existingWishes[name].index]["class"] = class
            else
                -- 如果是新成员，添加到XyArray
                local info = {}
                info["name"] = name
                info["class"] = class
                info["xy"] = "---未许愿---"
                info["dkp"] = DefaultDKP or 4
                table.insert(XyArray, info)
            end
        end
        
        if IsLeader then
            -- 队长直接发布同步信息
            syncXy()
        else
            -- 队员请求队长发送同步信息（包括许愿和拾取数据）
            SendAddonMessage("XY_SYNC_NEW", "", "RAID")
            SendAddonMessage("XY_LOOTLIST_SYNC_REQUEST", "", "RAID")
        end
    end
    XyTracker_UpdateList()
end

-- 显示拾取列表窗口
function XyTracker_ShowLootListFrame()
    local lootFrame = getglobal("XyTrackerLootListFrame")
    if lootFrame then
        lootFrame:Show()
        XyTracker_UpdateLootList()
    end
end

-- 更新拾取列表
function XyTracker_UpdateLootList()
    -- 确保LootList存在
    if not LootList then
        LootList = {}
    end
    
    -- 对拾取列表进行排序
    XyLootSortList()
    
    local scrollFrame = getglobal("LootListScrollFrame")
    local numItems = table.getn(LootList)
    
    FauxScrollFrame_Update(scrollFrame, numItems, 16, 25)
    
    for i = 1, 16 do
        local button = getglobal("LootFrameListButton"..i)
        local index = i + FauxScrollFrame_GetOffset(scrollFrame)
        
        if index <= numItems then
            local lootItem = LootList[index]
            
            -- 加强数据验证，确保lootItem是有效表
            if not lootItem or type(lootItem) ~= "table" then
                button:Hide()
                -- DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 跳过无效的拾取列表项 (索引: " .. index .. ")")
            else
                -- 设置按钮可见
                button:Show()
                
                -- 设置物品名称并根据品质染色
                local nameText = getglobal(button:GetName().."Name")
                if nameText then
                    local safeItemName = lootItem.itemName and tostring(lootItem.itemName) or "未知物品"
                    local safeItemLink = lootItem.itemLink and tostring(lootItem.itemLink) or ""
                    
                    -- 安全地从物品链接中提取颜色代码
                    local itemColor = nil
                    if safeItemLink and safeItemLink ~= "" then
                        local success, _, _, color = pcall(string.find, safeItemLink, "|c(%x+)|H")
                        if success and color then
                            itemColor = color
                        end
                    end
                    
                    -- 应用颜色或使用默认颜色
                    if itemColor then
                        -- 确保颜色代码格式正确
                        if string.len(itemColor) == 8 then
                            nameText:SetText("|c"..itemColor..safeItemName.."|r")
                        else
                            nameText:SetText(safeItemName)
                        end
                    else
                        nameText:SetText(safeItemName)
                    end
                    nameText:SetWidth(100)  -- 缩短物品名称宽度
                end
                
                -- 设置拾取时间
                local timeText = getglobal(button:GetName().."Time")
                if timeText then
                    local safeTimestamp = lootItem.timestamp and type(lootItem.timestamp) == "table" and lootItem.timestamp or nil
                    local timeString = Xy_FormatTime(safeTimestamp)
                    timeText:SetText(timeString)
                    timeText:SetWidth(80)
                end
                
                -- 设置归属玩家
                local playerText = getglobal(button:GetName().."Xy")
                if playerText then
                    local safePlayerName = lootItem.playerName and tostring(lootItem.playerName) or "未知玩家"
                    -- 获取玩家职业并添加职业染色
                    local playerInfo = getXyInfo(safePlayerName)
                    local class = playerInfo and playerInfo["class"] or "未知"
                    local classColor = XYT_GetClassColor(class) or "|cffffffff"
                    local coloredPlayerName = classColor .. safePlayerName .. "|r"
                    playerText:SetText(coloredPlayerName)
                    playerText:SetWidth(80)
                end
                
                -- 设置使用分数
                local pointsText = getglobal(button:GetName().."DKP")
                if pointsText then
                    local safePoints = type(lootItem.points) == "number" and lootItem.points or 0
                    pointsText:SetText(safePoints)
                    pointsText:SetWidth(50)
                end
                
                -- 隐藏拾取列表中的加减分按钮
                local addButton = getglobal(button:GetName().."AddDkp")
                local minusButton = getglobal(button:GetName().."MinusDkp")
                if addButton then
                    addButton:Hide()
                end
                if minusButton then
                    minusButton:Hide()
                end
                
                -- 设置是否许愿
                local isWishText = getglobal(button:GetName().."IsWish")
                if isWishText then
                    local safeIsWish = type(lootItem.isWish) == "boolean" and lootItem.isWish or false
                    if safeIsWish then
                        -- 许愿成功，显示不同颜色和文字
                        isWishText:SetText("已许愿")
                        isWishText:SetTextColor(1, 0.5, 0, 1)  -- 橙色，代表许愿成功
                    else
                        isWishText:SetText("否")
                        isWishText:SetTextColor(1, 1, 1, 1)  -- 白色
                    end
                    isWishText:SetWidth(60)
                end
            end
            
            -- 设置背景颜色
            if math.mod(index, 2) == 0 then
                button:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
            else
                button:SetBackdropColor(0, 0, 0, 0.5)
            end
            
            -- 禁用鼠标滑过操作
            button:SetScript("OnEnter", nil)
            button:SetScript("OnLeave", nil)
        else
            button:Hide()
        end
    end
end

-- 格式化时间戳或获取当前游戏时间
function Xy_FormatTime(timestamp)
    if timestamp then
        -- 有时间戳时使用时间戳
        if type(timestamp) == "table" and timestamp.hour and timestamp.minute then
            -- 处理新的{hour, minute}格式的时间戳
            return string.format("%02d:%02d", timestamp.hour, timestamp.minute)
        else
            -- 兼容旧的时间戳格式
           -- 使用本地时间而非服务器时间
            local hour, min = tonumber(date("%H")), tonumber(date("%M"))
            return string.format("%02d:%02d", hour, min)
        end
    else
        -- 无时间戳时使用游戏时间
       -- 使用本地时间而非服务器时间
        local hour, min = tonumber(date("%H")), tonumber(date("%M"))
        return string.format("%02d:%02d", hour, min)
    end
end

-- 从物品链接中提取物品品质的辅助函数
function GetItemQualityFromLink(itemLink)
    if not itemLink or type(itemLink) ~= "string" then
        return 0
    end
    
    -- 尝试从物品链接中提取品质信息
    -- 物品链接格式: |cffa335ee|Hitem:12345:0:0:0:0:0:0:0|h[物品名称]|h|r
    local qualityCode = string.match(itemLink, "|c(%x+)|Hitem")
    if not qualityCode then
        return 0
    end
    
    -- 根据颜色代码映射到品质等级
    local qualityMap = {
        ["ff9d9d9d"] = 0, -- 灰色/垃圾
        ["ffffffff"] = 1, -- 白色/普通
        ["ff1eff00"] = 2, -- 绿色/优秀
        ["ff0070dd"] = 3, -- 蓝色/精良
        ["ffa335ee"] = 4, -- 紫色/史诗
        ["ffff8000"] = 5, -- 橙色/传说
        ["ffe6cc80"] = 6  -- 金色/神器
    }
    
    return qualityMap[string.lower(qualityCode)] or 0
end

-- 对拾取列表进行排序
function XyLootSortList()
    -- 确保LootList是一个有效的表
    if not LootList or type(LootList) ~= "table" or table.getn(LootList) <= 1 then
        return
    end
    
    table.sort(LootList, function(a, b)
        -- 确保a和b是有效的表
        if not a or type(a) ~= "table" then
            return false
        end
        if not b or type(b) ~= "table" then
            return true
        end
        
        -- 获取排序字段的值
        local valA = a[LootSortField]
        local valB = b[LootSortField]
        
        -- 特殊处理物品名称排序：先按品质，再按ID
        if LootSortField == "itemName" then
            -- 获取物品品质
            local qualityA = GetItemQualityFromLink(a.itemLink or "")
            local qualityB = GetItemQualityFromLink(b.itemLink or "")
            
            -- 先按品质排序（高品质在前）
            if qualityA ~= qualityB then
                return qualityA * LootSortOrder > qualityB * LootSortOrder
            else
                -- 品质相同时，按物品ID排序
                local itemIDA = tonumber(ExtractItemID(a.itemLink or "")) or 0
                local itemIDB = tonumber(ExtractItemID(b.itemLink or "")) or 0
                return itemIDA * LootSortOrder < itemIDB * LootSortOrder
            end
        
        -- 如果两个值相等，按物品名称排序
        elseif valA == valB then
            return (a.itemName or "") < (b.itemName or "")
        else
            if LootSortField == "timestamp" then
                -- 处理timestamp字段，确保安全地获取和比较时间值
                local function getTimeValue(timeVal)
                    if not timeVal then
                        return 0
                    end
                    
                    -- 检查是否是表类型并包含hour和minute
                    if type(timeVal) == "table" and timeVal.hour and timeVal.minute then
                        -- 将时间转换为总分钟数进行比较
                        return timeVal.hour * 60 + timeVal.minute
                    
                    -- 检查是否是字符串格式的时间（时:分）
                    elseif type(timeVal) == "string" then
                        local hours, minutes = string.match(timeVal, "(%d+):(%d+)")
                        if hours and minutes then
                            return tonumber(hours) * 60 + tonumber(minutes)
                        end
                    
                    -- 尝试将其他类型转换为字符串并解析
                    else
                        local timeStr = tostring(timeVal)
                        local hours, minutes = string.match(timeStr, "(%d+):(%d+)")
                        if hours and minutes then
                            return tonumber(hours) * 60 + tonumber(minutes)
                        end
                    end
                    
                    return 0 -- 默认值
                end
                
                local t1 = getTimeValue(valA)
                local t2 = getTimeValue(valB)
                return t1 * LootSortOrder < t2 * LootSortOrder
            elseif LootSortField == "isWish" then
                -- 特殊处理是否许愿字段，已许愿的应该排在前面
                local wishA = valA and 1 or 0
                local wishB = valB and 1 or 0
                return wishA * LootSortOrder > wishB * LootSortOrder -- 注意这里是大于号，让已许愿的排在前面
            elseif type(valA) == "number" and type(valB) == "number" then
                return valA * LootSortOrder < valB * LootSortOrder
            else
                -- 对于字符串和其他类型，转换为字符串后比较
                return tostring(valA or "") < tostring(valB or "")
            end
        end
    end)
end

-- 设置排序字段
function XyLootSortOptions(field)
    -- 确保排序变量已初始化
    if not LootSortField then
        LootSortField = "timestamp"
    end
    if not LootSortOrder then
        LootSortOrder = 1
    end
    
    -- 更新排序字段和顺序
    if LootSortField == field then
        LootSortOrder = -LootSortOrder
    else
        LootSortField = field
        LootSortOrder = 1
    end
    
    -- 只对筛选后的列表进行排序，不再重新排序原始列表和重新应用筛选
    -- 确保即使在多次点击表头时，也只使用筛选后的列表，不会混入被筛选掉的物品
    
    -- 确保FilteredLootList和OriginalFilteredLootList存在
    if not _G["FilteredLootList"] or type(_G["FilteredLootList"]) ~= "table" then
        _G["FilteredLootList"] = {}
    end
    if not _G["OriginalFilteredLootList"] or type(_G["OriginalFilteredLootList"]) ~= "table" then
        _G["OriginalFilteredLootList"] = {}
    end
    
    -- 重新从OriginalFilteredLootList创建FilteredLootList，确保使用的是经过筛选的数据
    _G["FilteredLootList"] = {}
    for i = 1, table.getn(_G["OriginalFilteredLootList"]) do
        _G["FilteredLootList"][i] = _G["OriginalFilteredLootList"][i]
    end
    
    -- 强制刷新UI，XyTracker_UpdateLootList会使用FilteredLootList
    XyTracker_UpdateLootList()
    
    -- 重置滚动条位置，但只使用FilteredLootList
    local scrollFrame = getglobal("LootListScrollFrame")
    if scrollFrame then
        FauxScrollFrame_SetOffset(scrollFrame, 0)
        local filteredCount = table.getn(_G["FilteredLootList"] or {})
        FauxScrollFrame_Update(scrollFrame, filteredCount, 16, 25)
    end
    
    -- 强制重新布局，但只使用FilteredLootList
    local lootFrame = getglobal("XyTrackerLootListFrame")
    if lootFrame and lootFrame:IsVisible() then
        -- 先完全隐藏并重新显示框架，确保所有状态被重置
        lootFrame:Hide()
        
        -- 强制清空所有按钮，确保没有旧数据残留
        for i=1, 16 do
            local button = getglobal("LootFrameListButton"..i)
            if button then
                button:Hide()
            end
        end
        
        lootFrame:Show()
    end
    
    -- 再次调用XyTracker_UpdateLootList确保最新的筛选数据被正确显示
    XyTracker_UpdateLootList()
end

-- 清除拾取列表
function XyTracker_ClearLootList()
    -- 清空所有列表数据，包括原始列表和筛选后的临时表
    LootList = {}
    _G["OriginalFilteredLootList"] = {}
    _G["FilteredLootList"] = {}
    XyTracker_UpdateLootList()
end

-- 从物品链接中提取物品ID的辅助函数
function ExtractItemID(itemLink)
    if not itemLink or type(itemLink) ~= "string" then
        return "0"  -- 返回默认值而不是空字符串
    end
    
    -- 尝试从物品链接中提取物品ID
    local itemID = string.match(itemLink, "|Hitem:(%d+)")
    return itemID or "0"  -- 确保总是返回一个有效的字符串
end

-- 团长同步LootList数据给所有团员
-- 参数: onlyNewItem - 是否只同步最新拾取的物品（默认：false，同步全部）
-- 参数: specificItem - 可选，指定要同步的具体物品对象
function syncLootList(onlyNewItem, specificItem)
    onlyNewItem = onlyNewItem or false
    
    -- 检查LootList是否存在且有数据
    if not LootList or table.getn(LootList) == 0 then
        return
    end
    
    -- 分段发送LootList数据
    -- 由于AddonMessage有长度限制，我们需要确保每件物品单独发送
    local currentIndex = 1
    local chunkSize = 1  -- 每次只发送1个物品
    local totalItems = table.getn(LootList)
    
    -- 如果只同步最新物品
    if onlyNewItem then
        currentIndex = totalItems  -- 从最后一个物品开始
        chunkSize = 1  -- 每次只发送1个物品
        -- 只处理最新的一个物品，不进行批量处理
        local lootItem = specificItem or LootList[currentIndex]
        if lootItem then
            -- 从物品链接中提取物品ID，只发送关键信息
            local itemID = ExtractItemID(lootItem.itemLink)
            local points = lootItem.points or 0
            local isWish = lootItem.isWish and 1 or 0
            local safePlayerName = lootItem.playerName or ""
            local hour = lootItem.timestamp and lootItem.timestamp.hour or 0
            local minute = lootItem.timestamp and lootItem.timestamp.minute or 0
            
            -- 替换可能导致解析问题的特殊字符
            safePlayerName = string.gsub(safePlayerName, "|", "||")  -- 转义竖线
            local safeItemName = lootItem.itemName or "未知物品"
            safeItemName = string.gsub(safeItemName, "|", "||")  -- 转义物品名称中的竖线
            
            -- 确保itemID不为空
            if not itemID or itemID == "" then
                itemID = "0"
            end
            
            -- 获取物品品质信息
            local itemQuality = 5 -- 默认紫色史诗
            local itemName, itemLink, quality = GetItemInfo(itemID)
            if quality and type(quality) == "number" then
                itemQuality = quality
            end
            
            -- 使用新的格式序列化数据：物品ID、物品名称、玩家名称、分数、是否为许愿、时间戳、物品品质
                -- 使用分号代替竖线，避免与魔兽世界的转义代码冲突
                local chunkData = string.format(";i=%s,n=%s,f=%d,x=%d,p=%s,t=%02d:%02d,q=%d",
                    itemID,
                    safeItemName,
                    points,
                    isWish,
                    safePlayerName,
                    hour,
                    minute,
                    itemQuality
                )
            
            -- 发送当前批次数据，添加批次信息，使用冒号分隔批次信息
            -- 确保消息格式正确，让接收方能够正确解析为单个物品
            -- 修复：确保起始索引正确设置为最新物品的索引
            local message = string.format("%d:%d:%d%s",
                currentIndex,  -- 起始索引设为当前物品索引
                1,             -- 每次只发送1个物品
                totalItems,    -- 总物品数
                chunkData
            )
        
            SendAddonMessage("XY_LOOTLIST_SYNC", message, "RAID")
            
            -- 已移除：团长不再接收自己发送的数据
        end
        return  -- 发送单个物品后直接返回，不进行递归
    end
    
    -- 处理批量同步的情况
    while currentIndex <= totalItems do
        local chunkData = ""
        local itemsInChunk = 0
        
        -- 收集当前批次的数据（每次只发送一个物品）
        for i = currentIndex, math.min(currentIndex + chunkSize - 1, totalItems) do
            local lootItem = LootList[i]
            if lootItem then
                -- 从物品链接中提取物品ID，只发送关键信息
                local itemID = ExtractItemID(lootItem.itemLink)
                local points = lootItem.points or 0
                local isWish = lootItem.isWish and 1 or 0
                local safePlayerName = lootItem.playerName or ""
                local hour = lootItem.timestamp and lootItem.timestamp.hour or 0
                local minute = lootItem.timestamp and lootItem.timestamp.minute or 0
                
                -- 替换可能导致解析问题的特殊字符
                safePlayerName = string.gsub(safePlayerName, "|", "||")  -- 转义竖线
                local safeItemName = lootItem.itemName or "未知物品"
                safeItemName = string.gsub(safeItemName, "|", "||")  -- 转义物品名称中的竖线
                
                -- 确保itemID不为空
                if not itemID or itemID == "" then
                    itemID = "0"
                end
                
                -- 获取物品品质信息
                local itemQuality = 5 -- 默认紫色史诗
                local itemName, itemLink, quality = GetItemInfo(itemID)
                if quality and type(quality) == "number" then
                    itemQuality = quality
                end
                
                -- 使用新的格式序列化数据：物品ID、物品名称、玩家名称、分数、是否为许愿、时间戳、物品品质
                -- 使用分号代替竖线，避免与魔兽世界的转义代码冲突
                local itemData = string.format(";i=%s,n=%s,f=%d,x=%d,p=%s,t=%02d:%02d,q=%d",
                    itemID,
                    safeItemName,
                    points,
                    isWish,
                    safePlayerName,
                    hour,
                    minute,
                    itemQuality
                )
                
                chunkData = chunkData .. itemData
                itemsInChunk = itemsInChunk + 1
            end
        end
        
        -- 发送当前批次数据，添加批次信息，使用冒号分隔批次信息
        local message = string.format("%d:%d:%d%s",
            currentIndex,
            itemsInChunk,
            totalItems,
            chunkData
        )
   
        SendAddonMessage("XY_LOOTLIST_SYNC", message, "RAID")
        
        -- 已移除：团长不再接收自己发送的数据
        
        -- 移动到下一批次
        currentIndex = currentIndex + chunkSize
        
        -- 小延迟以避免消息丢失
        if currentIndex <= totalItems then
            local delayFrame = CreateFrame("Frame")
            delayFrame.elapsed = 0
            delayFrame:SetScript("OnUpdate", function()
                this.elapsed = this.elapsed + arg1
                if this.elapsed >= 0.1 then
                    this:SetScript("OnUpdate", nil)
                    syncLootListBatch(currentIndex, totalItems)
                end
            end)
            return
        end
    end
end

-- 批量同步辅助函数，用于递归发送后续批次数据
function syncLootListBatch(startIndex, totalItems)
    local currentIndex = startIndex or 1
    local chunkSize = 1  -- 每次只发送1个物品，避免数据过长导致错误
    while currentIndex <= totalItems do
        local chunkData = ""
        local itemsInChunk = 0
        
        -- 收集当前批次的数据（每次只发送一个物品）
        for i = currentIndex, math.min(currentIndex + chunkSize - 1, totalItems) do
            local lootItem = LootList[i]
            if lootItem then
                -- 从物品链接中提取物品ID，只发送关键信息
                local itemID = ExtractItemID(lootItem.itemLink)
                local points = lootItem.points or 0
                local isWish = lootItem.isWish and 1 or 0
                local safePlayerName = lootItem.playerName or ""
                local hour = lootItem.timestamp and lootItem.timestamp.hour or 0
                local minute = lootItem.timestamp and lootItem.timestamp.minute or 0
       
                safePlayerName = string.gsub(safePlayerName, "|", "||")  -- 转义竖线
                local safeItemName = string.gsub(lootItem.itemName or "未知物品", "|", "||")
                
                -- 获取物品品质信息
                local itemQuality = 5 -- 默认紫色史诗
                local itemName, itemLink, quality = GetItemInfo(itemID)
                if quality and type(quality) == "number" then
                    itemQuality = quality
                end
                
                local itemData = string.format(";i=%s,n=%s,f=%d,x=%d,p=%s,t=%02d:%02d,q=%d",
                    itemID,
                    safeItemName,
                    points,
                    isWish,
                    safePlayerName,
                    hour,
                    minute,
                    itemQuality
                )
                
                chunkData = chunkData .. itemData
                itemsInChunk = itemsInChunk + 1
            end
        end
        
        -- 发送当前批次数据，添加批次信息，使用冒号分隔批次信息
        local message = string.format("%d:%d:%d%s",
            currentIndex,
            itemsInChunk,
            totalItems,
            chunkData
        )
     
        SendAddonMessage("XY_LOOTLIST_SYNC",message, "RAID")
        
        -- 移动到下一批次
        currentIndex = currentIndex + chunkSize
        
        -- 小延迟以避免消息丢失
        if currentIndex <= totalItems then
            local delayFrame = CreateFrame("Frame")
            delayFrame.elapsed = 0
            delayFrame:SetScript("OnUpdate", function()
                this.elapsed = this.elapsed + arg1
                if this.elapsed >= 0.1 then
                    this:SetScript("OnUpdate", nil)
                    syncLootListBatch(currentIndex, totalItems)
                end
            end)
            return
        end
    end
end
-- 辅助函数：通过物品ID和品质创建物品链接
function CreateBasicItemLink(itemID, itemQuality)
    if not itemID or itemID == "" then
        return ""
    end
    
    -- 根据品质设置正确的颜色代码
    local qualityColor = "ffa335ee" -- 默认紫色
    
    if itemQuality == 5 then -- 橙色传说
        qualityColor = "ffff8000"
    elseif itemQuality == 4 then -- 紫色史诗
        qualityColor = "ffa335ee"
    elseif itemQuality == 3 then -- 蓝色精良
        qualityColor = "ff0070dd"
    elseif itemQuality == 2 then -- 绿色优秀
        qualityColor = "ff1eff00"
    elseif itemQuality == 1 then -- 白色普通
        qualityColor = "ffffffff"

    end
    
    -- 创建包含正确颜色的物品链接
    return "|c"..qualityColor.."|Hitem:"..itemID..":0:0:0|h[未知物品]|h|r"
end

-- LootList同步数据处理函数 - 所有玩家共用的统一逻辑
function receiveLootListSync(message)
    -- 解析消息头：起始索引:当前批次数量:总数量
    local startIndex, itemsCount, totalItems, itemData = string.match(message, "(%d+):(%d+):(%d+)(.*)")
    
    if not startIndex or not itemsCount or not totalItems then
        -- DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 同步数据格式错误！")
        return
    end
    
    startIndex = tonumber(startIndex)
    itemsCount = tonumber(itemsCount)
    totalItems = tonumber(totalItems)
    
    -- 确保LootList存在
    if not LootList then
        LootList = {}
    end
    
    -- 解析物品数据
    local itemsProcessed = 0
    
    -- 逐行解析物品数据块（以分号分隔）
    local pos = 1
    while pos <= string.len(itemData) do
        -- 查找下一个物品的起始位置
        local nextPos = string.find(itemData, ";", pos + 1)
        if not nextPos then
            -- 如果没有下一个分号，处理最后一个物品
            nextPos = string.len(itemData) + 1
        end
        
        -- 提取单个物品的数据块
        local itemDataBlock = string.sub(itemData, pos, nextPos - 1)
        pos = nextPos
        
        -- 尝试解析新格式的数据 (;i=物品ID,n=物品名称,f=分数,x=是否许愿,p=玩家名,t=时间戳)
        -- 处理可能以分号开头的情况
        local firstChar = string.sub(itemDataBlock, 1, 1)
        local secondChar = string.sub(itemDataBlock, 2, 2)
        
        if firstChar == "i" or (firstChar == ";" and secondChar == "i") then
            -- 如果以分号开头，跳过分号
            if firstChar == ";" then
                itemDataBlock = string.sub(itemDataBlock, 2)
            end
            -- 改进的解析逻辑，使用更可靠的方式提取各个字段
            local itemID = string.match(itemDataBlock, "i=([^,]+)")
            local itemName = string.match(itemDataBlock, "n=([^,]+)")
            local points = string.match(itemDataBlock, "f=(%d+)")
            local isWish = string.match(itemDataBlock, "x=(%d+)")
            local playerName = string.match(itemDataBlock, "p=([^,]+)")
            local timestamp = string.match(itemDataBlock, "t=(%d%d:%d%d)")
            
            if itemID and itemName and points and isWish and playerName and timestamp then
                -- 安全解码特殊字符
                playerName = string.gsub(playerName, "||", "|")
                points = tonumber(points) or 0
                isWish = tonumber(isWish) == 1
                
                -- 解析时间戳
                local hour, minute = string.match(timestamp, "(%d%d):(%d%d)")
                hour = tonumber(hour) or 0
                minute = tonumber(minute) or 0
                
                -- 解析物品品质信息（新增字段）
                local itemQuality = 5 -- 默认紫色史诗
                local qualityMatch = string.match(itemDataBlock, "q=(%d+)")
                if qualityMatch then
                    itemQuality = tonumber(qualityMatch) or 5
                end
                
                -- 创建包含正确颜色的物品链接
                local basicItemLink = CreateBasicItemLink(itemID, itemQuality)
                
                -- 完全按照团长发送的数据构建物品对象
                local lootItem = {
                    itemName = itemName,
                    itemLink = basicItemLink,
                    playerName = playerName,
                    points = points,
                    isWish = isWish,
                    timestamp = {hour = hour, minute = minute}
                }
                
                -- 增强版去重和更新逻辑：确保总是保存最新的拾取记录
                local isDuplicate = false
                local existingIndex = nil
                
                for i, existingItem in ipairs(LootList) do
                    -- 判断标准：物品ID、玩家名称和拾取时间都相同，增加物品名称比较确保准确性
                    local existingItemID = ExtractItemID(existingItem.itemLink)
                    local existingTimestamp = existingItem.timestamp
                    
                    if existingItemID == itemID and 
                       existingItem.playerName == playerName and 
                       existingTimestamp and 
                       existingTimestamp.hour == hour and 
                       existingTimestamp.minute == minute and 
                       existingItem.itemName == itemName then
                        -- 找到完全匹配的物品，但仍然更新，确保数据是最新的
                        isDuplicate = true
                        existingIndex = i
                        break
                    end
                end
                
                if isDuplicate and existingIndex then
                    -- 更新现有物品，确保数据是最新的
                    LootList[existingIndex] = lootItem
                    itemsProcessed = itemsProcessed + 1
                else
                    -- 如果不是重复数据，则添加到列表中
                    -- 根据起始索引添加物品到正确位置，确保同步顺序正确
                    local insertIndex = table.getn(LootList) + 1
                    if startIndex and startIndex > insertIndex then
                        insertIndex = startIndex
                    end
                    table.insert(LootList, insertIndex, lootItem)
                    itemsProcessed = itemsProcessed + 1
                end
            else
                XyTracker_Print("解析物品数据失败: " .. itemDataBlock, XyTracker_DebugLevel.ERROR)
            end
        -- 保持向后兼容性，支持旧格式的数据解析 (n=物品链接,f=分数,x=是否许愿,p=玩家名,t=时间戳)
        -- 注意：旧格式仍然使用竖线分隔
        elseif firstChar == "n" or (firstChar == ";" and secondChar == "n") then
            -- 如果以分号开头，跳过分号
            if firstChar == ";" then
                itemDataBlock = string.sub(itemDataBlock, 2)
            end
            -- 改进的解析逻辑，使用更可靠的方式提取各个字段
            local itemLink = string.match(itemDataBlock, "n=([^,]+)")
            local points = string.match(itemDataBlock, "f=(%d+)")
            local isWish = string.match(itemDataBlock, "x=(%d+)")
            local playerName = string.match(itemDataBlock, "p=([^,]+)")
            local timestamp = string.match(itemDataBlock, "t=(%d%d:%d%d)")
            
            if itemLink and points and isWish and playerName and timestamp then
                -- 安全解码特殊字符
                itemLink = string.gsub(itemLink, "||", "|")
                playerName = string.gsub(playerName, "||", "|")
                points = tonumber(points) or 0
                isWish = tonumber(isWish) == 1
                
                -- 解析时间戳
                local hour, minute = string.match(timestamp, "(%d%d):(%d%d)")
                hour = tonumber(hour) or 0
                minute = tonumber(minute) or 0
                
                -- 从物品链接中提取物品名称
                local itemName = ExtractItemName(itemLink)
                
                -- 完全按照团长发送的数据构建物品对象
                local lootItem = {
                    itemName = itemName,
                    itemLink = itemLink,
                    playerName = playerName,
                    points = points,
                    isWish = isWish,
                    timestamp = {hour = hour, minute = minute}
                }
                
                -- 增强版去重和更新逻辑：确保总是保存最新的拾取记录
                local isDuplicate = false
                local existingIndex = nil
                
                for i, existingItem in ipairs(LootList) do
                    -- 判断标准：物品ID、玩家名称和拾取时间都相同，增加物品名称比较确保准确性
                    local existingItemID = ExtractItemID(existingItem.itemLink)
                    local existingTimestamp = existingItem.timestamp
                    
                    if existingItemID == ExtractItemID(itemLink) and 
                       existingItem.playerName == playerName and 
                       existingTimestamp and 
                       existingTimestamp.hour == hour and 
                       existingTimestamp.minute == minute and 
                       existingItem.itemName == itemName then
                        -- 找到完全匹配的物品，但仍然更新，确保数据是最新的
                        isDuplicate = true
                        existingIndex = i
                        break
                    end
                end
                
                if isDuplicate and existingIndex then
                    -- 更新现有物品，确保数据是最新的
                    LootList[existingIndex] = lootItem
                    itemsProcessed = itemsProcessed + 1
                else
                    -- 如果不是重复数据，则添加到列表中
                    -- 根据起始索引添加物品到正确位置，确保同步顺序正确
                    local insertIndex = table.getn(LootList) + 1
                    if startIndex and startIndex > insertIndex then
                        insertIndex = startIndex
                    end
                    table.insert(LootList, insertIndex, lootItem)
                    itemsProcessed = itemsProcessed + 1
                end
            else
                XyTracker_Print("解析旧格式物品数据失败: " .. itemDataBlock, XyTracker_DebugLevel.ERROR)
            end
        end
    end
    
    -- 清理nil值，确保LootList是连续的
    local cleanLootList = {}
    for _, item in ipairs(LootList) do
        if item then
            table.insert(cleanLootList, item)
        end
    end
    LootList = cleanLootList
    
    -- 添加调试信息，帮助排查同步问题
    XyTracker_Print("处理批次: 起始索引="..startIndex..", 处理物品数="..itemsProcessed..", 总物品数="..totalItems, XyTracker_DebugLevel.DEBUG)
    
    -- 检查是否已接收完所有数据
    local currentCount = table.getn(LootList)
    -- DEFAULT_CHAT_FRAME:AddMessage("[XyTracker调试] 当前LootList物品总数: "..currentCount)
    
    -- 如果已接收完所有数据或者当前索引已到达总数量，更新UI
    if currentCount >= totalItems or startIndex + itemsProcessed - 1 >= totalItems then
        -- 使用与团长完全相同的更新逻辑刷新UI
        XyTracker_UpdateLootList()
        XyTracker_Print("拾取列表已从团长同步！共"..currentCount.."个物品", XyTracker_DebugLevel.INFO)
    end
end

-- 保存拾取列表到独立变量
function XyTracker_SaveLootList()
    -- 确保SavedLootList存在且是一个新的空表
    SavedLootList = {}
    
    -- 深拷贝当前LootList数据
    local savedCount = 0
    local lootCount = table.getn(LootList)
    for i = 1, lootCount do
        local lootItem = LootList[i]
        -- 只保存有效的物品数据
        if lootItem and type(lootItem) == "table" and 
           lootItem.itemName and type(lootItem.itemName) == "string" and lootItem.itemName ~= "" and 
           lootItem.playerName and type(lootItem.playerName) == "string" and lootItem.playerName ~= "" then
            
            -- 创建保存的物品数据
            local savedItem = {
                itemName = tostring(lootItem.itemName),
                itemLink = lootItem.itemLink and tostring(lootItem.itemLink) or "",
                playerName = tostring(lootItem.playerName),
                points = type(lootItem.points) == "number" and lootItem.points or 0,
                isWish = type(lootItem.isWish) == "boolean" and lootItem.isWish or false,
                timestamp = {}
            }
            
            -- 正确深拷贝timestamp字段
            if lootItem.timestamp and type(lootItem.timestamp) == "table" then
                savedItem.timestamp.hour = type(lootItem.timestamp.hour) == "number" and lootItem.timestamp.hour or 0
                savedItem.timestamp.minute = type(lootItem.timestamp.minute) == "number" and lootItem.timestamp.minute or 0
            else
                savedItem.timestamp.hour = 0
                savedItem.timestamp.minute = 0
            end
            
            -- 添加到SavedLootList并计数
            table.insert(SavedLootList, savedItem)
            savedCount = savedCount + 1
        end
    end
    
    -- 简单显示保存成功消息
    DEFAULT_CHAT_FRAME:AddMessage("拾取列表已保存", XyTracker_DebugLevel.INFO)
end

-- 从保存的变量恢复拾取列表
function XyTracker_RestoreLootList()
    -- 检查是否有保存的数据
    local hasData = false
    local validItems = {}
    
    -- 确保SavedLootList存在
    if SavedLootList and type(SavedLootList) == "table" then
        -- 使用pairs遍历SavedLootList，处理稀疏数组问题
        for k, v in pairs(SavedLootList) do
            -- 只处理数值键和有效的物品数据
            if type(k) == "number" and v and type(v) == "table" and 
               v.itemName and type(v.itemName) == "string" and v.itemName ~= "" and 
               v.playerName and type(v.playerName) == "string" and v.playerName ~= "" then
                table.insert(validItems, v)
                hasData = true
            end
        end
    else
        -- 简单显示恢复失败原因
         DEFAULT_CHAT_FRAME:AddMessage("恢复失败因为: SavedLootList不存在或不是有效的表", XyTracker_DebugLevel.ERROR)
        return
    end
    
    if hasData then
        -- 清空当前LootList
        LootList = {}
        
        -- 深拷贝保存的数据
        for i, savedItem in ipairs(validItems) do
            local lootItem = {
                itemName = tostring(savedItem.itemName),
                itemLink = savedItem.itemLink and tostring(savedItem.itemLink) or "",
                playerName = tostring(savedItem.playerName),
                points = type(savedItem.points) == "number" and savedItem.points or 0,
                isWish = type(savedItem.isWish) == "boolean" and savedItem.isWish or false,
                timestamp = {}
            }
            
            -- 正确深拷贝timestamp字段
            if savedItem.timestamp and type(savedItem.timestamp) == "table" then
                lootItem.timestamp.hour = type(savedItem.timestamp.hour) == "number" and savedItem.timestamp.hour or 0
                lootItem.timestamp.minute = type(savedItem.timestamp.minute) == "number" and savedItem.timestamp.minute or 0
            else
                lootItem.timestamp.hour = 0
                lootItem.timestamp.minute = 0
            end
            
            table.insert(LootList, lootItem)
        end
        
        -- 更新UI显示
        XyTracker_UpdateLootList()
        
        -- 简单显示恢复成功消息
         DEFAULT_CHAT_FRAME:AddMessage("拾取列表已恢复", XyTracker_DebugLevel.INFO)
    else
        -- 简单显示恢复失败原因
         DEFAULT_CHAT_FRAME:AddMessage("恢复失败因为: 没有找到已保存的拾取列表数据", XyTracker_DebugLevel.ERROR)
    end
end

-- 保存许愿信息到独立变量
function XyTracker_SaveWishList()
    -- 确保XyArray存在
    if not XyArray then
        return
    end
    
    -- 创建或重置SavedWishList
    if not _G["SavedWishList"] then
        _G["SavedWishList"] = {}
    elseif type(_G["SavedWishList"]) ~= "table" then
        _G["SavedWishList"] = {}
    end
    
    -- 本地引用，用于更快的访问
    local SavedWishList = _G["SavedWishList"]
    
    -- 清空SavedWishList中的所有元素
    for k in pairs(SavedWishList) do
        SavedWishList[k] = nil
    end
    
    -- 添加版本控制信息
    SavedWishList.version = "1.3"
    SavedWishList.saveTime = time()
    
    -- 获取成员数量
    local memberCount = table.getn(XyArray)
    
    -- 深拷贝当前XyArray中的许愿数据
    for i = 1, memberCount do
        local memberInfo = XyArray[i]
        -- 只保存有效的成员数据
        if memberInfo and type(memberInfo) == "table" then
            -- 确保name字段存在且为非空字符串
            local name = memberInfo.name and type(memberInfo.name) == "string" and memberInfo.name ~= "" and memberInfo.name or "未知玩家"
            
            -- 创建保存的成员数据
            local savedInfo = {
                name = tostring(name),
                xy = memberInfo.xy and tostring(memberInfo.xy) or "",
                class = memberInfo.class and tostring(memberInfo.class) or "",
                dkp = memberInfo.dkp and tostring(memberInfo.dkp) or "0"
            }
            
            -- 添加到SavedWishList
            table.insert(SavedWishList, savedInfo)
        end
    end
    
    -- 创建备份表
    if not _G["XyTrackerData"] then
        _G["XyTrackerData"] = {}
    end
    
    _G["XyTrackerData"]["WishListBackup"] = {}
    local backup = _G["XyTrackerData"]["WishListBackup"]
    
    -- 备份数据
    for i, savedInfo in ipairs(SavedWishList) do
        if type(i) == "number" and savedInfo then
            backup[i] = {
                name = savedInfo.name,
                xy = savedInfo.xy,
                class = savedInfo.class,
                dkp = savedInfo.dkp
            }
        end
    end
    
    -- 简单显示保存成功消息
    DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 许愿列表已保存", XyTracker_DebugLevel.INFO)
end

-- 从保存的变量恢复许愿信息
function XyTracker_RestoreWishList()
    -- 检查是否有保存的数据
    local hasData = false
    local validMembers = {}
    
    -- 尝试从多个来源恢复数据
    local wishList = nil
    
    -- 1. 首先尝试主数据
    if _G["SavedWishList"] and type(_G["SavedWishList"]) == "table" then
        local mainCount = 0
        for k, v in pairs(_G["SavedWishList"]) do
            if type(k) == "number" then
                mainCount = mainCount + 1
            end
        end
        
        if mainCount > 0 or (_G["SavedWishList"].version and _G["SavedWishList"].saveTime) then
            wishList = _G["SavedWishList"]
        end
    end
    
    -- 2. 如果主数据无效，尝试从备份中获取
    if not wishList then
        if _G["XyTrackerData"] and _G["XyTrackerData"]["WishListBackup"] and type(_G["XyTrackerData"]["WishListBackup"]) == "table" then
            local backupCount = 0
            for k, v in pairs(_G["XyTrackerData"]["WishListBackup"]) do
                if type(k) == "number" then
                    backupCount = backupCount + 1
                end
            end
            
            if backupCount > 0 then
                wishList = _G["XyTrackerData"]["WishListBackup"]
            end
        end
    end
    
    -- 检查数据有效性
    if not wishList or type(wishList) ~= "table" then
        DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 恢复失败因为: 无法获取有效数据")
        return
    end
    
    -- 遍历数据，处理稀疏数组问题
    for k, v in pairs(wishList) do
        -- 跳过元数据（如version和saveTime）
        if k ~= "version" and k ~= "saveTime" and k ~= "timestamp" and k ~= "metadata" and type(k) == "number" and v and type(v) == "table" then
            -- 放宽验证条件，确保能恢复尽可能多的数据
            local name = v.name and type(v.name) == "string" and v.name ~= "" and v.name or ("未知玩家_" .. tostring(k))
            
            table.insert(validMembers, {
                name = name,
                xy = v.xy and tostring(v.xy) or "",
                class = v.class and tostring(v.class) or "",
                dkp = v.dkp and tonumber(v.dkp) or 0
            })
            hasData = true
        end
    end
    
    if hasData then
        -- 创建名称到索引的映射，以便快速查找
        local nameToIndex = {}
        
        -- 确保XyArray存在
        if not XyArray then
            XyArray = {}
        end
        
        -- 建立现有成员的映射
        local existingCount = table.getn(XyArray)
        for i = 1, existingCount do
            local memberInfo = XyArray[i]
            if memberInfo and memberInfo.name then
                nameToIndex[memberInfo.name] = i
            end
        end
        
        -- 恢复许愿信息
        for i, savedInfo in ipairs(validMembers) do
            if savedInfo and savedInfo.name then
                local name = savedInfo.name
                
                if nameToIndex[name] then
                    -- 如果玩家已经在XyArray中，更新他们的许愿信息
                    local index = nameToIndex[name]
                    XyArray[index].xy = tostring(savedInfo.xy or "")
                    if savedInfo.class and savedInfo.class ~= "" then
                        XyArray[index].class = tostring(savedInfo.class)
                    end
                    if savedInfo.dkp and type(savedInfo.dkp) == "number" then
                        XyArray[index].dkp = savedInfo.dkp
                    end
                else
                    -- 如果玩家不在XyArray中，添加新记录
                    local newInfo = {
                        name = tostring(name),
                        xy = tostring(savedInfo.xy or ""),
                        class = tostring(savedInfo.class or ""),
                        dkp = savedInfo.dkp and type(savedInfo.dkp) == "number" and savedInfo.dkp or 0
                    }
                    table.insert(XyArray, newInfo)
                end
            end
        end
        
        -- 更新UI显示
        if getglobal("XyTrackerFrame") then
            XyTrackerFrame:Show()
        end
        XyTracker_UpdateList()
        
        -- 简单显示恢复成功消息
        DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 许愿列表已恢复")
    else
        -- 简单显示恢复失败原因
        DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 恢复失败因为: 没有找到已保存的许愿信息数据")
    end
end
        

function XyTracker_OnAnnounceButtonClick()
    if NoXyList == "" then
        SendChatMessage("所有人都已经许愿", "RAID", this.language, nil);
    else
        SendChatMessage("以下人员未许愿，请尽快许愿：" .. NoXyList, "RAID", this.language, nil);
    end
end

-- 播报许愿信息的计时器
XyBroadcastTimer = nil
XyCurrentBroadcastIndex = 0
XyBroadcastList = {}

function XyTracker_OnBroadcastWishesButtonClick()
    -- 停止任何正在进行的播报
    if XyBroadcastTimer then
        XyBroadcastTimer:Cancel();
        XyBroadcastTimer = nil;
    end
    
    -- 保存当前语言设置，以便在计时器回调中使用
    local currentLanguage = this.language
    
    -- 准备要播报的列表（使用当前排序后的displayArray）
    local totalMembers = GetNumRaidMembers()
    local currentRaidMembers = {}
    
    if totalMembers then
        for i = 1, totalMembers do
            local name = GetRaidRosterInfo(i)
            currentRaidMembers[name] = true
        end
        
        -- 清空之前的列表
        XyBroadcastList = {}
        
        -- 创建一个只包含当前团队成员的临时数组（按当前排序顺序）
        if table.getn(XyArray) > 0 and totalMembers then
            for i = 1, table.getn(XyArray) do
                local info = XyArray[i]
                if currentRaidMembers[info["name"]] then
                    table.insert(XyBroadcastList, info)
                end
            end
        end
        
        -- 开始播报
        XyCurrentBroadcastIndex = 1
        -- 获取当前排序依据的中文描述
        local sortMethodText = "角色名"
        if Xy_SortOptions.method == "class" then
            sortMethodText = "职业"
        elseif Xy_SortOptions.method == "xy" then
            sortMethodText = "许愿"
        elseif Xy_SortOptions.method == "dkp" then
            sortMethodText = "分数"
        end
        -- 添加排序方向描述
        if Xy_SortOptions.itemway == "desc" then
            sortMethodText = sortMethodText .. "降序"
        else
            sortMethodText = sortMethodText .. "升序"
        end
        SendChatMessage("以|cffff0000" .. sortMethodText .. "|r顺序开始播报许愿：", "RAID", currentLanguage, nil);
        
        -- 创建计时器，每0.5秒发送一条消息
        XyBroadcastTimer = CreateFrame("Frame");
        XyBroadcastTimer.elapsed = 0;
        XyBroadcastTimer:SetScript("OnUpdate", function()
            this.elapsed = this.elapsed + arg1;
            if this.elapsed >= 0.5 then
                this.elapsed = 0;
                -- 处理当前及后续可能为空的玩家，直到找到有内容的或结束
                while XyCurrentBroadcastIndex <= table.getn(XyBroadcastList) do
                    local info = XyBroadcastList[XyCurrentBroadcastIndex]
                    XyCurrentBroadcastIndex = XyCurrentBroadcastIndex + 1;
                    
                    -- 只播报有内容的许愿
                    if info and info["xy"] and info["xy"] ~= "---未许愿---" then
                        -- 按照角色名、职业、许愿、分数的格式播报，使用★播报许愿★格式避免重复警报
                        local msg = string.format("★播报许愿★%s(%s): %s [%s分]", info["name"], info["class"], info["xy"], info["dkp"]);
                        SendChatMessage(msg, "RAID", currentLanguage, nil);
                        break; -- 发送一条后等待下一个0.5秒
                    end
                    -- 如果是空内容，则继续循环处理下一个玩家，不等待
                end
                
                -- 检查是否所有玩家都已处理完
                if XyCurrentBroadcastIndex > table.getn(XyBroadcastList) then
                    -- 播报完成
                    SendChatMessage("许愿信息播报完毕！", "RAID", currentLanguage, nil);
                    this:Cancel();
                end
            end
        end);
        
        XyBroadcastTimer.Cancel = function()
            XyBroadcastTimer:SetScript("OnUpdate", nil);
            XyBroadcastTimer = nil;
        end;
    else
        SendChatMessage("你不在团队中，无法播报许愿信息！", "RAID", currentLanguage, nil);
    end
end

function XyTracker_OnExportButtonClick()
    -- 创建一个只包含当前团队成员的临时数组（与displayArray相同的逻辑）
    local totalMembers = GetNumRaidMembers()
    local currentRaidMembers = {}
    local displayArray = {}
    
    if totalMembers then
        for i = 1, totalMembers do
            local name = GetRaidRosterInfo(i)
            currentRaidMembers[name] = true
        end
        
        -- 从XyArray中筛选出当前团队成员
        if table.getn(XyArray) > 0 then
            for i = 1, table.getn(XyArray) do
                local info = XyArray[i]
                if currentRaidMembers[info["name"]] then
                    table.insert(displayArray, info)
                end
            end
        end
    end
    
    -- 如果没有团队成员，使用完整的XyArray
    if table.getn(displayArray) == 0 then
        displayArray = XyArray
    end
    
    -- 生成导出文本
    local csvText = ""
    local n = table.getn(displayArray)
    for i = 1, n do
        local xy = displayArray[i]["xy"]
        if not xy then
            xy = ""
        end
        csvText = csvText .. displayArray[i]["class"] .. "-" .. displayArray[i]["name"] .. "-" .. xy .. "-当前剩余:[" .. displayArray[i]["dkp"] .. "]分" .. "\n"
    end
    
    -- 设置导出文本并显示窗口
    getglobal("XyExportEdit"):SetText(csvText);
    getglobal("XyExportFrame"):Show();
end

function Xy_FixZero(num)
    if (num < 10) then
        return "0" .. num;
    else
        return num;
    end
end

function Xy_Date()
    local t = date("*t");

    return strsub(t.year, 3) .. "-" .. Xy_FixZero(t.month) .. "-" .. Xy_FixZero(t.day) .. " " .. Xy_FixZero(t.hour) .. ":" .. Xy_FixZero(t.min) .. ":" .. Xy_FixZero(t.sec);
end

-- 为指定玩家增加DKP点数
function XyAddDkp(player, score)
    -- 从UI元素获取玩家名称和分数（自定义分数增加功能）
    if not player then
        player = getglobal("XyAddMember"):GetText()
    end
    if not score then
        score = tonumber(getglobal("XyAddDkpFramePoint"):GetText())
    end
    
    if not player or not score then return end
    
    local info = getXyInfo(player)
    if info then
        info["dkp"] = tonumber(info["dkp"]) + score
        XyTracker_UpdateList()
        XyQuery(player, score)
        syncXy()
        
        -- 【重要】设置数据变更标记，确保在游戏退出时自动保存
        _G["XyTracker_SavedWishList_LastUpdate"] = time()
        -- 记录当前XyArray的实际大小，用于验证
        _G["XyTracker_ArraySize_LastRecord"] = table.getn(XyArray)
    end
end

-- 为指定玩家扣除DKP点数
function XyMinusDkp(player, score)
    -- 从UI元素获取玩家名称和分数（自定义分数扣除功能）
    if not player then
        player = getglobal("XyMinusMember"):GetText()
    end
    if not score then
        score = tonumber(getglobal("XyMinusDkpFramePoint"):GetText())
    end
    
    if not player or not score then return end
    
    local info = getXyInfo(player)
    if info then
        info["dkp"] = tonumber(info["dkp"]) - score
        XyTracker_UpdateList()
        XyQuery(player, -score)
        syncXy()
        
        -- 【重要】设置数据变更标记，确保在游戏退出时自动保存
        _G["XyTracker_SavedWishList_LastUpdate"] = time()
        -- 记录当前XyArray的实际大小，用于验证
        _G["XyTracker_ArraySize_LastRecord"] = table.getn(XyArray)
    end
end


-- 设置DKP排序选项
function XySortOptions(method)

    if (Xy_SortOptions.method and Xy_SortOptions.method == method) then
        if (Xy_SortOptions.itemway and Xy_SortOptions.itemway == "asc") then
            Xy_SortOptions.itemway = "desc";
        else
            Xy_SortOptions.itemway = "asc";
        end
    else
        Xy_SortOptions.method = method;
        Xy_SortOptions.itemway = "asc";
    end
    Xy_SortDkp();
    XyTracker_UpdateList();
end

function Xy_SortDkp()
    table.sort(XyArray, Xy_CompareDkps);
end

function Xy_CompareDkps(a1, a2)
    local method, way = Xy_SortOptions["method"], Xy_SortOptions["itemway"];
    local c1, c2 = a1[method], a2[method];
    
    -- 确保类型一致性，特别是对于dkp字段（可能从保存变量加载时变成了字符串）
    if method == "dkp" then
        -- 将可能是字符串的dkp值转换为数字
        c1 = tonumber(c1) or 0
        c2 = tonumber(c2) or 0
    end
    
    if (way == "asc") then
        return c1 < c2;
    else
        return c1 > c2;
    end
end

function ExtractItemName(xy)
    if not xy or type(xy) ~= "string" then
        return "", {}
    end
    
    -- 特殊处理：如果是未许愿状态，直接返回空字符串和空列表
    if xy == "---未许愿---" or xy == "" then
        return "", {}
    end
    
    -- 尝试提取所有物品名称
    local allItemNames = {}
    
    -- 检查是否包含物品链接
    if string.find(xy, "|Hitem:") then
        -- 提取物品链接中的物品名称
        for itemLink in string.gmatch(xy, "|Hitem:.-|h.-|h") do
            local itemName = string.match(itemLink, "|h%[(.-)%]|h")
            if itemName and itemName ~= "" then
                table.insert(allItemNames, itemName)
            end
        end
    else
        -- 处理非物品链接格式的许愿
        -- 1. 特别处理 [物品1][物品2] 这种常见格式
        local bracketPattern = "%[(.-)%]"
        local hasBracketItems = string.find(xy, bracketPattern)
        
        if hasBracketItems then
            for item in string.gmatch(xy, bracketPattern) do
                if item and item ~= "" then
                    table.insert(allItemNames, item)
                end
            end
        else
            -- 2. 处理其他分隔符的情况（逗号、顿号、空格等）
            local delimiters = {"，", ",", "、", " "} -- 支持常见的分隔符
            
            for _, delimiter in ipairs(delimiters) do
                if string.find(xy, delimiter) then
                    -- 分割字符串
                    local startIdx = 1
                    
                    while startIdx <= string.len(xy) do
                        local endIdx = string.find(xy, delimiter, startIdx)
                        if endIdx then
                            local item = string.sub(xy, startIdx, endIdx - 1)
                            item = string.trim(item)
                            if item and item ~= "" then
                                table.insert(allItemNames, item)
                            end
                            startIdx = endIdx + 1
                        else
                            local item = string.sub(xy, startIdx)
                            item = string.trim(item)
                            if item and item ~= "" then
                                table.insert(allItemNames, item)
                            end
                            break
                        end
                    end
                    
                    break -- 找到一个分隔符后就不再检查其他分隔符
                end
            end
        end
    end
    
    -- 如果找到了物品名称，返回第一个作为主物品名称，并返回所有物品名称列表
    if table.getn(allItemNames) > 0 then
        return allItemNames[1], allItemNames
    else
        -- 重要修复：如果没有找到任何物品名称，但原始xy不为空（且不是未许愿状态），
        -- 返回清理后的原始xy字符串，确保手动输入的许愿也能正确显示
        local cleanedXY = string.trim(xy)
        if cleanedXY and cleanedXY ~= "" and cleanedXY ~= "---未许愿---" then
            -- 简单清理：移除可能的多余字符，但保留主要内容
            cleanedXY = string.gsub(cleanedXY, "^%[+|%]+$", "")  -- 移除开头和结尾的方括号
            cleanedXY = string.trim(cleanedXY)
            return cleanedXY, {cleanedXY}
        end
        return "", {}
    end
end


function string.trim(s)
    if type(s) ~= "string" then
        return s
    end
    return string.gsub(string.gsub(s, "^%s+", ""), "%s+$", "")
end

function MarkItemAsCompleted(originalWish, completedItemName)
    if not originalWish or not completedItemName or type(originalWish) ~= "string" or type(completedItemName) ~= "string" then
        return originalWish
    end
    
    -- 清理物品名称，用于比较
    local cleanedCompletedName = safeCleanString(completedItemName)
    
    local newWish = originalWish
    local foundMatch = false
    local remainingItems = {}
    
    -- 1. 先检查是否包含物品链接格式
    if string.find(originalWish, "|Hitem:") then
        -- 物品链接提取正则表达式 - 优化支持所有颜色的物品
        local itemLinkPattern = "|c%x%x%x%x%x%x%x%x|Hitem:.-|h%[.-%]|h|r"
        local itemNamePattern = "|h%[(.-)%]|h"
        
        -- 收集所有物品链接，排除已完成的
        local startPos = 1
        local tempWish = originalWish
        
        while true do
            -- 查找下一个完整的物品链接（支持所有颜色）
            local linkStart, linkEnd = string.find(tempWish, itemLinkPattern, startPos)
            if not linkStart then
                -- 尝试更宽松的匹配模式
                linkStart, linkEnd = string.find(tempWish, "|Hitem:.-|h%[.-%]|h", startPos)
                if not linkStart then
                    break -- 没有更多链接了
                end
            end
            
            local fullItemLink = string.sub(tempWish, linkStart, linkEnd)

            -- 提取物品名称
            local itemName = string.match(fullItemLink, itemNamePattern)
            if itemName then
                local cleanedItemName = safeCleanString(itemName)
                
                -- 使用模糊比较，增加匹配的可能性
                if cleanedItemName == cleanedCompletedName or 
                   string.find(cleanedItemName, cleanedCompletedName) or 
                   string.find(cleanedCompletedName, cleanedItemName) then
                    foundMatch = true
                else
                    table.insert(remainingItems, fullItemLink)
                end
            else
                -- 如果无法提取物品名称，保留原始链接
                table.insert(remainingItems, fullItemLink)
            end
            
            startPos = linkEnd + 1
        end
        
        -- 构建新的许愿字符串
        if foundMatch then
            if table.getn(remainingItems) > 0 then
                newWish = "|cFF00FFFF【已完成许愿】|r" .. table.concat(remainingItems)
            else
                newWish = "|cFF00FFFF【已完成许愿】|r"
            end
        end
    else
        -- 2. 尝试处理 [物品1][物品2] 这种常见格式
        if not foundMatch then
            local itemPattern = "%[(.-)%]"
            local hasBracketItems = string.find(originalWish, itemPattern)
            
            if hasBracketItems then
                -- 收集所有中括号包裹的物品，排除已完成的
                for item in string.gmatch(originalWish, itemPattern) do
                    if item and item ~= "" then
                        local cleanedItemName = safeCleanString(item)
                        if cleanedItemName == cleanedCompletedName or 
                           string.find(cleanedItemName, cleanedCompletedName) or 
                           string.find(cleanedCompletedName, cleanedItemName) then
                            foundMatch = true
                        else
                            table.insert(remainingItems, "["..item.."]")
                        end
                    end
                end
                
                -- 构建新的许愿字符串
                if foundMatch then
                    if table.getn(remainingItems) > 0 then
                        newWish = "|cFF00FFFF【已完成许愿】|r" .. table.concat(remainingItems)
                    else
                        newWish = "|cFF00FFFF【已完成许愿】|r"
                    end
                end
            end
        end
        
        -- 3. 如果上面两种格式都没找到匹配，尝试处理其他分隔符的情况
        if not foundMatch then
            -- 分割许愿文本（支持多种分隔符）
            local delimiters = {"，", ",", "、", " "} -- 支持常见的分隔符
            local matchedDelimiter = nil
            
            -- 查找使用的分隔符
            for _, delimiter in ipairs(delimiters) do
                if string.find(originalWish, delimiter) then
                    matchedDelimiter = delimiter
                    break
                end
            end
            
            if matchedDelimiter then
                -- 分割字符串并收集未完成的物品
                local items = {}
                local startIdx = 1
                local tempStr = originalWish
                
                while startIdx <= string.len(tempStr) do
                    local endIdx = string.find(tempStr, matchedDelimiter, startIdx)
                    if endIdx then
                        local item = string.sub(tempStr, startIdx, endIdx - 1)
                        item = string.trim(item)
                        if item and item ~= "" then
                            table.insert(items, item)
                        end
                        startIdx = endIdx + 1
                    else
                        local item = string.sub(tempStr, startIdx)
                        item = string.trim(item)
                        if item and item ~= "" then
                            table.insert(items, item)
                        end
                        break
                    end
                end
                
                -- 过滤出未完成的物品
                for _, item in ipairs(items) do
                    local cleanedItemName = safeCleanString(item)
                    if cleanedItemName == cleanedCompletedName or 
                       string.find(cleanedItemName, cleanedCompletedName) or 
                       string.find(cleanedCompletedName, cleanedItemName) then
                        foundMatch = true
                    else
                        table.insert(remainingItems, item)
                    end
                end
                
                -- 构建新的许愿字符串
                if foundMatch then
                    if table.getn(remainingItems) > 0 then
                        newWish = "|cFF00FFFF【已完成许愿】|r" .. table.concat(remainingItems, matchedDelimiter)
                    else
                        newWish = "|cFF00FFFF【已完成许愿】|r"
                    end
                end
            end
        end
        
        -- 4. 最后尝试直接匹配整个字符串，处理单个物品或特殊情况
        if not foundMatch then
            local cleanedOriginalWish = safeCleanString(originalWish)
            if cleanedOriginalWish == cleanedCompletedName or 
               string.find(cleanedOriginalWish, cleanedCompletedName) or 
               string.find(cleanedCompletedName, cleanedOriginalWish) then
                foundMatch = true
                newWish = "|cFF00FFFF【已完成许愿】|r"
            end
        end
    end
    
    -- 返回修改后的许愿（如果有匹配的话），否则返回原始许愿
    return foundMatch and newWish or originalWish
end

function string.trim(s)
    return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

-- 安全的字符串清理函数（这是重复定义，已被重命名以避免冲突）
-- 主函数在文件前面已定义
function safeCleanString_duplicate(str)
    if not str or type(str) ~= "string" then
        return ""
    end
    
    -- 移除颜色代码
    local cleanStr = string.gsub(str, "|c%x%x%x%x%x%x%x%x", "")
    cleanStr = string.gsub(cleanStr, "|r", "")
    
    -- 移除空格和特殊字符
    cleanStr = string.gsub(cleanStr, "%s+", "")
    cleanStr = string.lower(cleanStr)
    
    return cleanStr
end

-- 合并 江湖任我行@乌龟服-拉&风 的修改
--加Atlas tooltip 提示许愿人数...
if AtlasLootTooltip then
    Xytooltip = CreateFrame("Frame", "Xytooltip", AtlasLootTooltip)
    Xytooltip:SetScript("OnShow", function()
        local Itemname = getglobal("AtlasLootTooltipTextLeft1"):GetText()
        local namelist
        if Itemname then 
        namelist = XYLIST1(Itemname)
        end
    
        if namelist then
            AtlasLootTooltip:AddLine(namelist)
        end
        AtlasLootTooltip:Show()
    end)

    Xytooltip:SetScript("OnHide", function()
        AtlasLootTooltip:Hide()
    end)
end
--加物品 Gametooltip 提示许愿人数和玩家许愿信息...
-- 修复GameTooltip绑定，保留对物品许愿信息的显示，并添加玩家许愿信息显示
if GameTooltip then
    Xytooltip2 = CreateFrame("Frame", "Xytooltip2", GameTooltip)
    Xytooltip2:SetScript("OnShow", function()
        -- 检查是否已经处理过，避免重复添加
        if GameTooltip.XYProcessed then
            return
        end
        
        local text = getglobal("GameTooltipTextLeft1"):GetText() or ""
        
        -- 添加辅助函数：清理字符串中的颜色代码
        local function stripColorCodes(str)
            if not str then return "" end
            -- 移除颜色代码 |cffRRGGBB
            str = string.gsub(str, "|c%x%x%x%x%x%x%x%x", "")
            -- 移除颜色结束标记 |r
            str = string.gsub(str, "|r", "")
            -- 移除其他可能的控制字符
            str = string.gsub(str, "|H.-|h", "")
            str = string.gsub(str, "|h", "")
            return str
        end
        
        -- 添加辅助函数：提取纯玩家名称，过滤掉军衔信息、换行和称号
        local function extractPlayerName(str)
            if not str then return "" end
            
            -- 首先移除颜色代码
            local cleanStr = stripColorCodes(str)
            
            -- 移除换行符
            cleanStr = string.gsub(cleanStr, "\n", " ")
            
            -- 先尝试从括号中提取玩家名（这是玩家链接的常见格式）
            local bracketedName = string.match(cleanStr, "%[(.-)%]")
            if bracketedName and bracketedName ~= "" then
                return bracketedName
            end
            
            -- 过滤掉军衔信息，格式如[中士]、[军士长]等
            -- 匹配[...]格式的内容并移除
            cleanStr = string.gsub(cleanStr, "%[.-%]", "")
            
            -- 移除前后空白字符
            cleanStr = string.gsub(cleanStr, "^%s*(.-)%s*$", "%1")
            
            -- 处理"军衔 名字 称号"或"军衔 名字"格式，提取中间的名字部分
            local parts = {}
            for part in string.gmatch(cleanStr, "[^%s]+") do
                table.insert(parts, part)
            end
            
            -- 如果有多个部分，取中间的部分作为名字
            -- 如果只有一个部分，直接返回
            local partsCount = table.getn(parts)
            if partsCount == 1 then
                return parts[1]
            elseif partsCount >= 2 then
                -- 对于"军衔 名字 称号"格式，返回中间的名字
                -- 对于"军衔 名字"格式，返回第二个部分
                return parts[2]
            end
            
            return cleanStr
        end
        
        -- 首先尝试作为物品名查询许愿信息
        local namelist = XYLIST1(text)
        
        -- 如果没有找到物品的许愿信息，尝试作为玩家名查询
        if not namelist then
            -- 使用extractPlayerName函数提取纯玩家名称
            local playerName = extractPlayerName(text)
            -- 检查是否是玩家（通常会有职业、等级等信息）
            local isPlayer = false
            for i = 2, GameTooltip:NumLines() do
                local lineText = getglobal("GameTooltipTextLeft"..i):GetText() or ""
                -- 检查是否包含职业、等级等玩家特征信息
                if string.find(lineText, "战士") or string.find(lineText, "法师") or 
                   string.find(lineText, "牧师") or string.find(lineText, "猎人") or 
                   string.find(lineText, "盗贼") or string.find(lineText, "圣骑士") or 
                   string.find(lineText, "德鲁伊") or string.find(lineText, "萨满祭司") or 
                   string.find(lineText, "术士") then
                    isPlayer = true
                    break
                end
            end         
            -- 如果是玩家，查询并显示许愿信息
            if isPlayer then     
                -- 提取纯玩家名称，去除颜色代码和军衔信息
                local cleanPlayerName = extractPlayerName(playerName)
                namelist = XYLISTbyPlayer(cleanPlayerName)
            end
        end
        
        if namelist then
            GameTooltip:AddLine(namelist)
            GameTooltip:Show()
        end
        
        -- 设置处理标记，避免重复处理
        GameTooltip.XYProcessed = true
    end)

    Xytooltip2:SetScript("OnHide", function()
        -- 清除临时标记，允许下次查看时重新显示信息
        GameTooltip.XYProcessed = nil
    end)
end
--加点击物品 tooltip 提示许愿人数...
if ItemRefTooltip then
    Xytooltip3 = CreateFrame("Frame", "Xytooltip3", ItemRefTooltip)
    Xytooltip3:SetScript("OnShow", function()
        local Itemname = getglobal("ItemRefTooltipTextLeft1"):GetText()
        local namelist
        if Itemname then 
        namelist = XYLIST1(Itemname)
        end
        --print(Itemname)
        --print(namelist)
        if namelist then
            ItemRefTooltip:AddLine(namelist)
        end
        ItemRefTooltip:Show()
    end)

    Xytooltip3:SetScript("OnHide", function()
        ItemRefTooltip:Hide()
    end)
end

function ClasstoColor(class)
    if class =='战士' then return "|cffC79C6E"
    elseif  class =='萨满祭司' then return "|cff2773FF"
    elseif class =='德鲁伊' then return "|cffFF7D0A"
    elseif class =='盗贼' then return "|cffFFF569"
    elseif class =='法师' then return "|cff69CCFF"
    elseif class =='圣骑士' then return "|cffF58CBA"
    elseif class =='牧师' then return "|cffFFFFFF"
    elseif class =='术士' then return "|cff9482C9"
    elseif class =='猎人' then return "|cffABD473"
    end
  end
  
  
  function XYLIST(Iname)    
      --by qtz 非许愿模式下,贴装备,团队聊天窗口贴出许愿名单 ,返回许愿该装备的许愿名单.没有就返回nil   
      if XyArray ~=nil then
        local n = table.getn(XyArray)
        local i,name,xy,class,color
        local num = 0
        local itemname =""
        local XYID,NOW,xy_name
        --local itemtable = {}
              
        for i = 1, n do
          name = XyArray[i]["name"]
          xy = XyArray[i]["xy"] 
          if not xy then
            xy = ""
          end           
  
          --XYID,xy_name = string.match(xy, "item:(%d*):.-|h%[(.-)%]|h|r")
          xy_name = string.match(xy, "|h%[(.-)%]|h|r")          
          if xy_name then
            --if xy == arg1 or string.match(arg1, XYID) then 
            if xy_name == Iname then
              class = XyArray[i]["class"]
              color = ClasstoColor(XyArray[i]["class"]) 
              
              --itemname = itemname.. " ".. name..'-'..XyArray[i]["class"].."("..XyArray[i]["dkp"] .."分)"
              itemname = itemname.. " ".. color.. name.."|r("..XyArray[i]["dkp"] .."分)"
              NOW = xy_name
              num = num+1
            end
          end
        end
          --print(itemname)
        --if itemname ~="" and GetItemInfo(NOWID) and IsRaidOfficer() then
        if itemname ~="" and NOW then 
          --return "["..GetItemInfo(NOWID).."] ".."有:"..itemname.. ",共>"..num.."<人许愿."
          return "["..NOW.."]".. "|cffFFFF00("..num..")|r人许愿:"..itemname
          --SendChatMessage("["..GetItemInfo(NOWID).."] ".."有:"..itemname.. ",共>"..num.."<人许愿.", "SAY", this.language, nil);
          --SendChatMessage(xy_name.." 有:"..itemname.. ",共"..num.."人许愿.", "RAID", this.language, nil);
        else
          return nil
        end       
      end 
            -- qtz
  end
  
  function XYLIST1(Iname)    
      --by qtz tooltip提示许愿人数 ,返回许愿该装备的许愿名单.没有就返回nil   
      if XyArray ~=nil and Iname and Iname ~= "" then
        local n = table.getn(XyArray)
        local i,name,xy,class,color
        local num = 0
        local p = 0
        local itemname = ""
        local XYID,NOW,xy_name
        --local itemtable = {}
        
        -- 防止重复显示的临时标记
        if GameTooltip.XYProcessed and GameTooltip.XYProcessed == Iname then
          return nil
        end
        GameTooltip.XYProcessed = Iname
              
        -- 获取当前团队成员列表
        local currentRaidMembers = {}
        local totalMembers = GetNumRaidMembers()
        if totalMembers then
            for i = 1, totalMembers do
                local raidName = GetRaidRosterInfo(i)
                if raidName then
                    currentRaidMembers[raidName] = true
                end
            end
        end
              
        for i = 1, n do
          name = XyArray[i]["name"]
          xy = XyArray[i]["xy"] 
          if not xy then
            xy = ""
          end            

          -- 修复：使用更可靠的方式检测物品是否被许愿
          local isWished = false
          
          -- 方式1：安全检查物品链接格式的匹配（转义特殊字符）
          if string.find(xy, Iname) then
            isWished = true
          end
          
          -- 只显示当前在团队中的玩家
          if isWished and currentRaidMembers[name] then
            num = num+1            
            class = XyArray[i]["class"]
            color = ClasstoColor(XyArray[i]["class"]) 
            -- 安全获取dkp值，如果为nil则使用默认值0
            local dkpValue = XyArray[i]["dkp"] or 0
            
            if p == 3 then
              itemname = itemname.. "\n "..color..name .. "|r["..dkpValue .."分]"
              p=0
            else  
              itemname = itemname.. " "..color..name .. "|r["..dkpValue .."分]"
            end
            p = p+1
            NOW = Iname -- 设置为当前查询的物品名称
          end
        end
        
        if itemname ~="" then
          return "\n XY有:"..itemname.. "|cff9FFFA0".."\n  --共("..num..")人许愿--\n|r"
        else
          -- 即使没有找到许愿信息，也要清除临时标记，避免影响下次显示
          GameTooltip.XYProcessed = nil
          return nil   
        end        
      end
      
      -- 如果XyArray为nil或没有找到玩家的许愿信息，返回nil
      return nil
  end          

  
  --通过玩家名字查询许愿和许愿人数
  
  -- 简单函数：直接返回玩家的许愿内容
  function XY_GetPlayerWish(playername)
      if XyArray ~= nil then
        local n = table.getn(XyArray)
        local i, name, xy
        
        -- 确保playername不为空
        if not playername or playername == "" then
          return nil
        end
        
        -- 移除可能的空格
        playername = string.match(playername, "(%S+)") or playername
        
        -- 查找指定玩家的许愿信息
        for i = 1, n do
          name = XyArray[i]["name"]
          if name == playername then
            xy = XyArray[i]["xy"]
            
            -- 直接返回玩家的许愿内容
            if xy and xy ~= "" and xy ~= "---未许愿---" then
              return xy
            else
              return nil
            end
          end
        end
      end
      
      -- 如果XyArray为nil或没有找到玩家的许愿信息，返回nil
      return nil
  end
  
  function XYLISTbyPlayer(playername)    
    local n = table.getn(XyArray)
    for i = 1, n do
        local name = XyArray[i]["name"]
        local xy = XyArray[i]["xy"]
        local dkpValue = XyArray[i]["dkp"] or 0

        if playername == name then
            if not xy then
                return "---未许愿---" 
            else
                -- 统计每个物品的重复许愿次数
                local formattedXY = xy
                
                -- 提取所有物品链接或名称
                local items = {}
                
                -- 匹配物品链接格式 [物品名] 或带颜色代码的物品链接
                local function extractItems(text)
                    local foundItems = {}
                    -- 匹配 [物品名] 格式
                    for item in string.gmatch(text, "%[([^%]]+)%]") do
                        table.insert(foundItems, item)
                    end
                    -- 如果没有找到标准格式，尝试分割文本中的空格分隔项
                    if table.getn(foundItems) == 0 then
                        for item in string.gmatch(text, "%S+") do
                            table.insert(foundItems, item)
                        end
                    end
                    return foundItems
                end
                
                local playerItems = extractItems(xy)
                
                -- 统计每个物品的重复许愿次数
                for _, item in ipairs(playerItems) do
                    local count = 0
                    -- 遍历所有玩家统计该物品的许愿次数
                    for j = 1, n do
                        local otherXY = XyArray[j]["xy"]
                        if otherXY and string.find(otherXY, item) then
                            count = count + 1
                        end
                    end
                    
                    -- 只在数量大于1时添加计数显示
                    if count > 1 then
                        -- 替换原始物品为带计数的版本，计数部分使用cffffff00颜色
                        formattedXY = string.gsub(formattedXY, "%["..item.."%]", "["..item.."]|cffffff00("..count..")|r")
                    end
                end
                
                return "许愿: "..formattedXY .. " |cffffff00[" .. dkpValue .. "分]|r"   
            end
        end
    end
 end

-- 全局变量存储自定义的Starttext
local CustomStarttext = nil

-- 初始化时从XyTrackerOptions加载自定义欢迎文本
function XyTracker_LoadCustomStarttext()
    if XyTrackerOptions and XyTrackerOptions.CustomStarttext then
        CustomStarttext = XyTrackerOptions.CustomStarttext
        -- 调试信息
        -- DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 成功加载自定义欢迎文本")
    end
end

-- 保存自定义欢迎文本到XyTrackerOptions
function XyTracker_SaveCustomStarttext()
    if CustomStarttext and CustomStarttext ~= "" then
        -- 确保XyTrackerOptions已初始化
        InitializeXyTrackerOptions()
        XyTrackerOptions.CustomStarttext = CustomStarttext
        -- 调试信息
        -- DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 自定义欢迎文本已保存")
    end
end

-- 显示编辑Starttext的输入框
function XyTracker_ShowStarttextEditBox()
    -- 检查是否有权限（团长模式或未开团）
    if not IsLeader and XyInProgress then
        DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 只有团长或未开团时才能编辑欢迎文本")
        return
    end
    
    -- 创建或获取编辑框
    local editBox = getglobal("XyTrackerStarttextEditBox")
    if not editBox then
        -- 创建编辑框窗口
        local frame = CreateFrame("Frame", "XyTrackerStarttextEditBoxFrame", UIParent)
        frame:SetWidth(400)
        frame:SetHeight(300)
        frame:SetPoint("CENTER", 0, 0)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function()
        frame:StartMoving()
    end)
    frame:SetScript("OnDragStop", function()
        frame:StopMovingOrSizing()
    end)
    
    -- 设置背景和边框，与主界面保持一致
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        tileSize = 32,
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    })
    frame:SetBackdropColor(0, 0, 0); -- 纯黑色，与主界面保持一致
    frame:SetBackdropBorderColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, 1); -- 红色边框，与主界面保持一致
    
        
        -- 窗口标题
        local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
        title:SetPoint("TOP", frame, "TOP", 0, -30)
        title:SetText("编辑欢迎文本")
        
        -- 许愿分设置标签
        local wishScoreLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        wishScoreLabel:SetPoint("TOP", frame, "TOP", 0, -50)
        wishScoreLabel:SetText("许愿分设置 (0-9为许愿权限，其他为基础分)")
        
        -- 许愿分设置输入框
        local wishScoreEdit = CreateFrame("EditBox", "XyTrackerWishScoreEditBox", frame, "InputBoxTemplate")
        wishScoreEdit:SetWidth(100)
        wishScoreEdit:SetHeight(26)
        wishScoreEdit:SetPoint("TOP", wishScoreLabel, "BOTTOM", 0, -5)
        wishScoreEdit:SetNumeric(true)
        wishScoreEdit:SetAutoFocus(false)
        wishScoreEdit:SetMaxLetters(2)
        
        -- 编辑框
        editBox = CreateFrame("EditBox", "XyTrackerStarttextEditBox", frame)
        editBox:SetWidth(360)
        editBox:SetHeight(120)
        editBox:SetPoint("TOP", wishScoreEdit, "BOTTOM", 0, -10)
        editBox:SetMultiLine(true)
        editBox:SetAutoFocus(true)
        editBox:SetFontObject("ChatFontNormal")
        editBox:SetScript("OnEscapePressed", function() frame:Hide() end)
        
        -- 保存按钮
        local saveButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        saveButton:SetWidth(80)
        saveButton:SetHeight(22)
        saveButton:SetPoint("BOTTOM", frame, "BOTTOM", -50, 15)
        saveButton:SetText("保存")
        saveButton:SetScript("OnClick", function() 
            local newText = editBox:GetText()
            if newText and newText ~= "" then
                CustomStarttext = newText
                -- 调用保存函数
                XyTracker_SaveCustomStarttext()
            end
            
            -- 保存许愿分设置
            local wishScoreEdit = getglobal("XyTrackerWishScoreEditBox")
            if wishScoreEdit then
                local wishScore = tonumber(wishScoreEdit:GetText()) or 0
                if not XyTrackerOptions then
                    XyTrackerOptions = {}
                end
                XyTrackerOptions.WishScore = wishScore
                DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 许愿分设置已保存为: " .. wishScore)
            end
            
            DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 欢迎文本已更新并保存")
            frame:Hide()
        end)
        
        -- 取消按钮
        local cancelButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        cancelButton:SetWidth(80)
        cancelButton:SetHeight(22)
        cancelButton:SetPoint("BOTTOM", frame, "BOTTOM", 50, 15)
        cancelButton:SetText("取消")
        cancelButton:SetScript("OnClick", function() frame:Hide() end)
    end
    
    -- 设置编辑框的默认内容
    local defaultText = "歪歪1453862000 欢迎来到《无忧小筑》许愿团，在团队频道输入【XY+空格+许愿装备】进行许愿 有意向加入公会一起玩耍的扫YY二维码加入我们公会群"
    editBox:SetText(CustomStarttext or defaultText)
    
    -- 设置许愿分输入框的默认值
    local wishScoreEdit = getglobal("XyTrackerWishScoreEditBox")
    if wishScoreEdit then
        local wishScore = XyTrackerOptions and XyTrackerOptions.WishScore or 0
        wishScoreEdit:SetText(wishScore)
    end
    
    -- 显示编辑框窗口
    getglobal("XyTrackerStarttextEditBoxFrame"):Show()
end

-- 获取当前的Starttext（自定义或默认）
function XyTracker_GetCurrentStarttext()
    -- 优先从XyTrackerOptions获取，确保使用最新保存的值
    local startText = XyTrackerOptions and XyTrackerOptions.CustomStarttext or CustomStarttext
    return startText or "歪歪1453862000 欢迎来到《无忧小筑》许愿团，在团队频道输入【XY+空格+许愿装备】进行许愿 有意向加入公会一起玩耍的扫YY二维码加入我们公会群"
end

-- 获取职业颜色
function XYT_GetClassColor(class)
	if not class then return nil; end
	
	-- 职业颜色映射
	local classColors = {
		["战士"] = "\124cffC79C6E",
		["萨满祭司"] = "\124cff0070DE",
		["猎人"] = "\124cffABD473",
		["盗贼"] = "\124cffFFF569",
		["牧师"] = "\124cffFFFFFF",
		["死亡骑士"] = "\124cffC41F3F",
		["圣骑士"] = "\124cffF58CBA",
		["术士"] = "\124cff9482C9",
		["法师"] = "\124cff69CCF0",
		["德鲁伊"] = "\124cffFF7D0A",
	};
	
	-- 处理职业名称的简写形式
	local className = class;
	if string.find(class, "战士") then className = "战士";
	elseif string.find(class, "萨满祭司") then className = "萨满祭司";
	elseif string.find(class, "猎人") then className = "猎人";
	elseif string.find(class, "盗贼") then className = "盗贼";
	elseif string.find(class, "牧师") then className = "牧师";
	elseif string.find(class, "圣骑士") then className = "圣骑士";
	elseif string.find(class, "术士") then className = "术士";
	elseif string.find(class, "法师") then className = "法师";
	elseif string.find(class, "德鲁伊") then className = "德鲁伊";
	end
	
	return classColors[className];
end

-- 创建ROLL点监控窗口
function XyTracker_CreateRollMonitor()
	-- 如果窗口已存在，直接返回
	if RollMonitorFrame then
		return;
	end
	
	-- 创建主窗口
	RollMonitorFrame = CreateFrame("Frame", "RollMonitorFrame", UIParent);
	RollMonitorFrame:SetWidth(400);
	RollMonitorFrame:SetHeight(300);
	RollMonitorFrame:SetPoint("CENTER", "UIParent", "CENTER", 0, 0);
	RollMonitorFrame:EnableMouse(true);
	RollMonitorFrame:SetMovable(true);
	RollMonitorFrame:RegisterForDrag("LeftButton");
	RollMonitorFrame:SetScript("OnDragStart", function() this:StartMoving(); end);
	RollMonitorFrame:SetScript("OnDragStop", function() this:StopMovingOrSizing(); end);
	RollMonitorFrame:SetFrameStrata("DIALOG");
	RollMonitorFrame:Hide();
	
	-- 设置背景
	RollMonitorFrame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true, tileSize = 32, edgeSize = 32,
		insets = { left = 11, right = 12, top = 12, bottom = 11 }
	});
	
	-- 创建标题
	local title = RollMonitorFrame:CreateFontString("RollMonitorFrameTitle", "ARTWORK", "GameFontNormalLarge");
	title:SetPoint("TOP", RollMonitorFrame, "TOP", 0, -20);
	title:SetText("ROLL点结果");
	
	-- 创建关闭按钮
	local closeButton = CreateFrame("Button", nil, RollMonitorFrame, "UIPanelCloseButton");
	closeButton:SetPoint("TOPRIGHT", RollMonitorFrame, "TOPRIGHT", -5, -5);
	
	-- 创建表头
	local nameHeader = RollMonitorFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	nameHeader:SetPoint("TOPLEFT", RollMonitorFrame, "TOPLEFT", 20, -50);
	nameHeader:SetText("玩家");
	
	local rollHeader = RollMonitorFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	rollHeader:SetPoint("TOP", RollMonitorFrame, "TOP", 0, -50);
	rollHeader:SetText("ROLL点");
	
	local classHeader = RollMonitorFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	classHeader:SetPoint("TOP", RollMonitorFrame, "TOP", 80, -50);
	classHeader:SetText("职业");
	
	local wishHeader = RollMonitorFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	wishHeader:SetPoint("TOP", RollMonitorFrame, "TOP", 160, -50);
	wishHeader:SetText("许愿");

	local actionHeader = RollMonitorFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	actionHeader:SetPoint("TOPRIGHT", RollMonitorFrame, "TOPRIGHT", -20, -50);
	actionHeader:SetText("操作");
	
	-- 创建ROLL点条目
	for i = 1, 10 do
		local entry = CreateFrame("Frame", "RollMonitorEntry" .. i, RollMonitorFrame);
		entry:SetWidth(360);
		entry:SetHeight(20);
		entry:SetPoint("TOPLEFT", RollMonitorFrame, "TOPLEFT", 20, -(50 + i * 20));
		entry:Hide();
		
		-- 玩家名称
		local nameText = entry:CreateFontString("RollMonitorEntry" .. i .. "Name", "ARTWORK", "GameFontNormalSmall");
		nameText:SetPoint("LEFT", entry, "LEFT", 0, 0);
		nameText:SetWidth(120);
		nameText:SetJustifyH("LEFT");
		
		-- ROLL点
		local rollText = entry:CreateFontString("RollMonitorEntry" .. i .. "Roll", "ARTWORK", "GameFontNormalSmall");
		rollText:SetPoint("LEFT", entry, "LEFT", 120, 0);
		rollText:SetWidth(60);
		rollText:SetJustifyH("CENTER");
		
		-- 职业
		local classText = entry:CreateFontString("RollMonitorEntry" .. i .. "Class", "ARTWORK", "GameFontNormalSmall");
		classText:SetPoint("LEFT", entry, "LEFT", 180, 0);
		classText:SetWidth(80);
		classText:SetJustifyH("CENTER");
		
		-- 许愿
		local wishText = entry:CreateFontString("RollMonitorEntry" .. i .. "Wish", "ARTWORK", "GameFontNormalSmall");
		wishText:SetPoint("LEFT", entry, "LEFT", 260, 0);
		wishText:SetWidth(80);
		wishText:SetJustifyH("LEFT");
		
		-- 扣按钮
		local deductButton = CreateFrame("Button", "RollMonitorEntry" .. i .. "Deduct", entry, "UIPanelButtonTemplate");
		deductButton:SetWidth(40);
		deductButton:SetHeight(16);
		deductButton:SetPoint("RIGHT", entry, "RIGHT", 0, 0);
		deductButton:SetText("扣");
		deductButton:SetNormalFontObject(GameFontNormalSmall);
		deductButton:SetHighlightFontObject(GameFontHighlightSmall);
		deductButton:SetDisabledFontObject(GameFontDisableSmall);
		deductButton:Show(); -- 确保按钮默认显示
		deductButton:SetScript("OnClick", function() 
						local name = this:GetParent():GetName();
						local index = string.match(name, "%d+");
						local playerName = getglobal("RollMonitorEntry" .. index .. "Name"):GetText();
						
						-- 去除玩家名称中的颜色标签
						playerName = string.gsub(playerName, "|c[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]", "");
						playerName = string.gsub(playerName, "|r", "");
						
						-- 优先使用玩家在出分拍卖中的出分记录，默认5分
						local bidScore = 5;
						if XYT_Auction_Scores and XYT_Auction_Scores[playerName] then
							bidScore = tonumber(XYT_Auction_Scores[playerName]) or 5;
						end
						
						if playerName then
						-- 调用扣除分数函数
						XYT_DeductPlayerScore(playerName, bidScore);
						-- 移除按钮禁用和文字改变，允许按钮回弹，但通过XYT_HasDeductedScore变量防止重复扣分
						-- 刷新出分拍卖和ROLL点拍卖窗口数据
						XYT_UpdateAuctionDisplay();
						RollMonitor_UpdateList();
						-- 发送系统消息
						DEFAULT_CHAT_FRAME:AddMessage("已扣除玩家 " .. playerName .. " 的分数: " .. bidScore);
						end
		end);
	end
end

-- 宏命令函数：XYTMacro(拍卖类型, 时间)
-- 拍卖类型："f"表示出分拍卖，"r"表示ROLL点拍卖
-- 时间：拍卖持续时间（秒），如30
function XYTMacro(auctionType, duration)
    -- 参数验证
    if not auctionType or not duration then
        DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 参数错误：请提供拍卖类型(f/r)和时间");
        return;
    end
    if not IsLeader then
        DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 没有许愿团权限");
        return;
    end
    -- 检查是否已经有拍卖在进行中
    if auctionType == "f" and XYT_Auction_IsActive then
        -- 出分拍卖进行中，只显示窗口
        if DKPMonitorFrame then
            DKPMonitorFrame:Show();
            DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 出分拍卖进行中，显示监控窗口");
        end
        return;
    elseif auctionType == "r" and XYT_IsRecordingRoll then
        -- ROLL点拍卖进行中，只显示窗口
        if RollMonitorFrame then
            RollMonitorFrame:Show();
            DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] ROLL点拍卖进行中，显示监控窗口");
        end
        return;
    end
    
    -- 获取鼠标指向的物品链接
    local itemLink = XYT_GetMouseItemLink();
    
    if not itemLink then
        DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 错误：请将鼠标指向要拍卖的物品");
        return;
    end
    
    -- 确保时间为数字
    local actualDuration = tonumber(duration) or 30;
    
    -- 根据拍卖类型调用相应的函数
    if auctionType == "f" then
        -- 出分拍卖
        XYT_StartAuction(itemLink, actualDuration);
        -- DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 开始出分拍卖：" .. itemLink .. "，时间" .. actualDuration .. "秒");
    elseif auctionType == "r" then
        -- ROLL点拍卖
        XYT_StartRollRecording(itemLink, actualDuration);
        -- 发送团队消息
        SendChatMessage("开始ROLL点拍卖：" .. itemLink .. "，请ROLL点，时间" .. actualDuration .. "秒", "RAID");
        -- DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 开始ROLL点拍卖：" .. itemLink .. "，时间" .. actualDuration .. "秒");
    else
        DEFAULT_CHAT_FRAME:AddMessage("[XyTracker] 错误：拍卖类型必须是'f'(出分)或'r'(ROLL点)");
        return;
    end
end

-- 获取鼠标指向的物品链接
function XYT_GetMouseItemLink()
    -- 方法1：从GameTooltip获取物品链接（最可靠的方法）
    if GameTooltip and GameTooltip:IsVisible() then
        -- 检查GameTooltip的第一行，通常是物品名称和链接
        local tooltipText = GameTooltipTextLeft1:GetText();
        if tooltipText and string.find(tooltipText, "|c%x%x%x%x%x%x%x%x|Hitem:") then
            return tooltipText;
        end
        
        -- 检查所有可见的行
        for i = 1, math.min(GameTooltip:NumLines(), 10) do
            local line = getglobal("GameTooltipTextLeft"..i);
            if line and line:IsVisible() and line:GetText() then
                local text = line:GetText();
                -- 检测物品链接格式
                if string.find(text, "|c%x%x%x%x%x%x%x%x|Hitem:") then
                    return text;
                end
            end
        end
    end
    
    -- 方法2：尝试从鼠标悬停的框架获取物品链接（兼容魔兽1.12）
    local mouseFocus = GetMouseFocus();
    if mouseFocus then
        local frameName = mouseFocus:GetName();
        
        -- 检查是否是背包物品
        if frameName and string.find(frameName, "ContainerFrame") then
            local containerID = mouseFocus:GetParent():GetID();
            local slotID = mouseFocus:GetID();
            if containerID and slotID then
                local itemLink = GetContainerItemLink(containerID, slotID);
                if itemLink then
                    return itemLink;
                end
            end
        end
        
        -- 检查是否是装备栏物品
        if frameName and string.find(frameName, "Character") then
            local slotID = mouseFocus:GetID();
            if slotID then
                local itemLink = GetInventoryItemLink("player", slotID);
                if itemLink then
                    return itemLink;
                end
            end
        end
        
        -- 检查是否是银行物品
        if frameName and string.find(frameName, "Bank") then
            local slotID = mouseFocus:GetID();
            if slotID then
                local itemLink = GetContainerItemLink(-1, slotID); -- 银行使用-1作为容器ID
                if itemLink then
                    return itemLink;
                end
            end
        end
    end
    
    -- 方法3：如果以上方法都失败，尝试使用物品名称创建基本链接
    if GameTooltip and GameTooltip:IsVisible() then
        local itemName = GameTooltipTextLeft1:GetText();
        if itemName and not string.find(itemName, "|c") then
            -- 创建一个基本的物品链接（没有具体属性）
            return "|cffffffff|Hitem:0:0:0:0:0:0:0:0|h[" .. itemName .. "]|h|r";
        end
    end
    
    return nil;
end
