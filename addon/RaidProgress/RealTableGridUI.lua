-- RealTableGridUI.lua - 真正的表格网格界面
-- 角色在左列，副本在顶部，用表格形式显示

-- WoW 1.12 兼容性函数
local function SetCompatibleFont(fontString, size)
    if not fontString then return end
    size = size or 12
    fontString:SetFont("Fonts\\FRIZQT__.TTF", size)
end

-- WoW 1.12 可能缺少的tContains函数
local function tContains(table, item)
    if not table then return false end
    for i = 1, getn(table) do
        if table[i] == item then
            return true
        end
    end
    return false
end

-- 创建全局对象
local RealTableGridUI = {}
_G["RealTableUI"] = RealTableGridUI

local mainFrame = nil
local tableRows = {}
local isUIVisible = false  -- 添加状态跟踪变量

-- 副本定义（按照用户指定顺序排列）
local RAIDS = {
    {id = 409, name = "MC", fullName = "熔火之心", cycle = "weekly"}, -- 周重置
    {id = 469, name = "BWL", fullName = "黑翼之巢", cycle = "weekly"}, -- 周重置
    {id = 719, name = "TAQ", fullName = "安其拉神殿", cycle = "weekly"}, -- 周重置
    {id = 533, name = "NAX", fullName = "纳克萨玛斯", cycle = "weekly"}, -- 周重置
    {id = 540, name = "翡翠", fullName = "翡翠圣地", cycle = "weekly"}, -- 周重置
    {id = 536, name = "K40", fullName = "卡拉赞之塔", cycle = "weekly"}, -- 周重置
    {id = 509, name = "黑龙MM", fullName = "奥妮克希亚的巢穴", cycle = "daily"}, -- 5天重置
    {id = 535, name = "卡下", fullName = "卡拉赞下层大厅", cycle = "daily"}, -- 5天重置
    {id = 531, name = "ZG", fullName = "祖尔格拉布", cycle = "3day"}, -- 3天重置
    {id = 718, name = "FX", fullName = "安其拉废墟", cycle = "3day"}, -- 3天重置    -- 周常任务
    {id = "quest_1", name = "净化", fullName = "武装的召唤：净化腐化", cycle = "quest", isQuest = true},
    {id = "quest_2", name = "地下城", fullName = "武装的召唤：地下城探索", cycle = "quest", isQuest = true},
    {id = "quest_3", name = "熔火", fullName = "武装的召唤：熔火突袭", cycle = "quest", isQuest = true}
}

-- 副本周期颜色配置（表头和状态按钮的背景色 - 增强对比度版本）
local CYCLE_COLORS = {
    ["weekly"] = {r = 0.1, g = 0.2, b = 0.5, a = 0.8},   -- 更深的蓝色 - 周重置
    ["daily"] = {r = 0.5, g = 0.1, b = 0.2, a = 0.8},    -- 更深的红色 - 5天重置
    ["3day"] = {r = 0.1, g = 0.4, b = 0.1, a = 0.8},     -- 更深的绿色 - 3天重置
    ["quest"] = {r = 0.6, g = 0.5, b = 0.1, a = 0.8}     -- 黄色 - 周常任务
}

-- 职业颜色（支持英文和中文）
local CLASS_COLORS = {
    -- 英文职业名
    ["WARRIOR"] = {r=0.78, g=0.61, b=0.43},
    ["PALADIN"] = {r=0.96, g=0.55, b=0.73},
    ["HUNTER"] = {r=0.67, g=0.83, b=0.45},
    ["ROGUE"] = {r=1.00, g=0.96, b=0.41},
    ["PRIEST"] = {r=1.00, g=1.00, b=1.00},
    ["SHAMAN"] = {r=0.00, g=0.44, b=0.87},
    ["MAGE"] = {r=0.41, g=0.80, b=0.94},
    ["WARLOCK"] = {r=0.58, g=0.51, b=0.79},
    ["DRUID"] = {r=1.00, g=0.49, b=0.04},
    -- 中文职业名支持
    ["战士"] = {r=0.78, g=0.61, b=0.43},
    ["圣骑士"] = {r=0.96, g=0.55, b=0.73},
    ["猎人"] = {r=0.67, g=0.83, b=0.45},
    ["盗贼"] = {r=1.00, g=0.96, b=0.41},
    ["牧师"] = {r=1.00, g=1.00, b=1.00},
    ["萨满祭司"] = {r=0.00, g=0.44, b=0.87},
    ["法师"] = {r=0.41, g=0.80, b=0.94},
    ["术士"] = {r=0.58, g=0.51, b=0.79},
    ["德鲁伊"] = {r=1.00, g=0.49, b=0.04}
}

-- 职业图标纹理坐标（WoW 1.12 经典版本 - 使用Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes.tga）
local CLASS_ICON_COORDS = {
    -- 英文职业名 - 纹理坐标 (left, right, top, bottom)
    ["WARRIOR"] = {0, 0.25, 0, 0.25},
    ["MAGE"] = {0.25, 0.5, 0, 0.25},
    ["ROGUE"] = {0.5, 0.75, 0, 0.25},
    ["DRUID"] = {0.75, 1, 0, 0.25},
    ["HUNTER"] = {0, 0.25, 0.25, 0.5},
    ["SHAMAN"] = {0.25, 0.5, 0.25, 0.5},
    ["PRIEST"] = {0.5, 0.75, 0.25, 0.5},
    ["WARLOCK"] = {0.75, 1, 0.25, 0.5},
    ["PALADIN"] = {0, 0.25, 0.5, 0.75},
    -- 中文职业名支持
    ["战士"] = {0, 0.25, 0, 0.25},
    ["法师"] = {0.25, 0.5, 0, 0.25},
    ["盗贼"] = {0.5, 0.75, 0, 0.25},
    ["德鲁伊"] = {0.75, 1, 0, 0.25},
    ["猎人"] = {0, 0.25, 0.25, 0.5},
    ["萨满祭司"] = {0.25, 0.5, 0.25, 0.5},
    ["牧师"] = {0.5, 0.75, 0.25, 0.5},
    ["术士"] = {0.75, 1, 0.25, 0.5},
    ["圣骑士"] = {0, 0.25, 0.5, 0.75}
}

-- 获取职业颜色的智能函数
local function GetClassColor(classString)
    if not classString then
        return {r=1, g=1, b=1} -- 默认白色
    end
    
    -- 尝试原始字符串
    local color = CLASS_COLORS[classString]
    if color then
        return color
    end
    
    -- 尝试大写版本
    local upperClass = string.upper(classString)
    color = CLASS_COLORS[upperClass]
    if color then
        return color
    end
    
    -- 尝试小写版本
    local lowerClass = string.lower(classString)
    color = CLASS_COLORS[lowerClass]
    if color then
        return color
    end
    
    -- 默认白色
    return {r=1, g=1, b=1}
end

-- 获取职业图标纹理坐标的智能函数
local function GetClassIconCoords(classString)
    if not classString then
        return {0, 0.25, 0, 0.25} -- 默认战士图标
    end
    
    -- 尝试原始字符串
    local coords = CLASS_ICON_COORDS[classString]
    if coords then
        return coords
    end
    
    -- 尝试大写版本
    local upperClass = string.upper(classString)
    coords = CLASS_ICON_COORDS[upperClass]
    if coords then
        return coords
    end
    
    -- 尝试小写版本
    local lowerClass = string.lower(classString)
    coords = CLASS_ICON_COORDS[lowerClass]
    if coords then
        return coords
    end
    
    -- 默认使用战士图标坐标
    return {0, 0.25, 0, 0.25}
end

-- 获取角色数据（增强安全版本，包含周任务数据）
local function GetCharacterData()
    local chars = {}
      -- 安全检查数据库存在性
    if not RaidProgressDB or not RaidProgressDB.characters then
        return chars
    end
    
    for fullName, data in pairs(RaidProgressDB.characters) do
        -- 安全检查角色数据完整性
        if data and data.info and data.info.level and data.info.level >= 55 then
            table.insert(chars, {
                name = fullName,
                class = data.info.class or "WARRIOR",
                level = data.info.level,
                progress = data.progress or {},
                weeklyQuests = data.weeklyQuests or {}
            })
        end
    end
    
    return chars
end

-- 检查副本是否重置（增强版本）
local function IsRaidReset(progress, raidId)
    -- 安全检查：确保 progress 和 raidId 都存在
    if not progress or not raidId then
        return true -- 默认已重置
    end
    
    local raidData = progress[raidId]
    if not raidData then
        return true -- 没有记录，默认已重置
    end
    
    local resetTime = raidData.resetTime or 0
    return time() >= resetTime
end

-- 检查周任务状态（增强版本 - 支持多种状态）
local function GetQuestStatus(weeklyQuests, questId)
    -- 安全检查
    if not questId then
        return "unknown", true -- 未知状态，默认可重置
    end
    
    -- 如果没有周任务数据，说明从未接取过
    if not weeklyQuests then
        return "available", true -- 可接取，已重置
    end
    
    local questData = weeklyQuests[questId]
    if not questData then
        return "available", true -- 没有记录，可接取且已重置
    end
    
    -- 检查是否已重置（过了重置时间）
    local resetTime = questData.resetTime or 0
    local currentTime = time()
    local isReset = currentTime >= resetTime
    
    if isReset then
        return "available", true -- 已重置，可以重新接取
    end
    
    -- 未重置情况下，检查完成状态
    local isCompleted = questData.completed or false
    
    if isCompleted then
        return "completed", false -- 已完成，未重置
    else
        -- 如果有任务数据且未完成，且未过重置时间，则认为是进行中
        -- 简化逻辑：只要有数据记录且未完成，就是进行中
        local lastUpdate = questData.lastUpdate or 0
        
        -- 如果有最后更新时间，说明任务被接取过
        if lastUpdate > 0 then
            return "inprogress", false -- 进行中，未重置
        else
            -- 没有最后更新时间但有数据，可能是旧数据
            return "available", false -- 可接取但未重置
        end
    end
end

-- 创建表格头部（包含重置时间信息）
local function CreateTableHeader(parent)    local headerFrame = CreateFrame("Frame", nil, parent)
    headerFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, -50)
    headerFrame:SetWidth(1000) -- 从860调整到1000，为更多列留空间
    headerFrame:SetHeight(50) -- 增加高度以容纳重置时间
    
    -- 角色名称标题
    local nameHeader = headerFrame:CreateFontString(nil, "OVERLAY")
    SetCompatibleFont(nameHeader, 14)
    nameHeader:SetPoint("LEFT", headerFrame, "LEFT", 0, 5)
    nameHeader:SetText("角色名称")
    nameHeader:SetTextColor(1, 1, 0)
    nameHeader:SetWidth(150)
    nameHeader:SetJustifyH("LEFT")
    
    -- 获取服务器配置
    local serverConfig = nil
    if RaidProgressConfig and RaidProgressConfig.GetServerRaidConfig then
        serverConfig = RaidProgressConfig.GetServerRaidConfig()
    end      -- 副本标题和重置时间
    for i, raid in ipairs(RAIDS) do        -- 创建副本列背景框
        local columnBg = CreateFrame("Frame", nil, headerFrame)
        columnBg:SetPoint("LEFT", headerFrame, "LEFT", 150 + (i-1) * 65 - 2, 0) -- 从58调整到65
        columnBg:SetWidth(66) -- 从59调整到66，略宽于列宽
        columnBg:SetHeight(50)
        columnBg:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        })
        -- 根据副本周期设置背景色
        local cycleColor = CYCLE_COLORS[raid.cycle or "weekly"]
        columnBg:SetBackdropColor(cycleColor.r, cycleColor.g, cycleColor.b, cycleColor.a)
        columnBg:SetBackdropBorderColor(cycleColor.r * 0.7, cycleColor.g * 0.7, cycleColor.b * 0.7, 1)
        
        -- 副本名称（增大字体）
        local raidHeader = headerFrame:CreateFontString(nil, "OVERLAY")
        SetCompatibleFont(raidHeader, 14) -- 从10增加到12
        raidHeader:SetPoint("LEFT", headerFrame, "LEFT", 150 + (i-1) * 65, 8) -- 从58调整到65
        raidHeader:SetText(raid.name)
        raidHeader:SetTextColor(1, 1, 0)
        raidHeader:SetWidth(62) -- 从55调整到62
        raidHeader:SetJustifyH("CENTER")
        raidHeader:SetDrawLayer("OVERLAY", 5)

        -- 重置时间信息
        local resetInfo = headerFrame:CreateFontString(nil, "OVERLAY")
        SetCompatibleFont(resetInfo, 10)
        resetInfo:SetPoint("LEFT", headerFrame, "LEFT", 150 + (i-1) * 65, -8) -- 从58调整到65
        resetInfo:SetWidth(62) -- 从55调整到62
        resetInfo:SetJustifyH("CENTER")
        resetInfo:SetDrawLayer("OVERLAY", 5)
          -- 显示重置时间（仅显示剩余时间）
        local resetText = "?"
        if _G.GetSimpleResetTime then
            resetText = _G.GetSimpleResetTime(raid.id)
        else
            -- 备用显示
            if serverConfig and serverConfig[raid.id] then
                local config = serverConfig[raid.id]
                if config.resetDay and config.resetDay > 0 then
                    local dayNames = {"", "一", "二", "三", "四", "五", "六", "日"}
                    resetText = "周" .. (dayNames[config.resetDay] or "?")
                else
                    local days = math.floor(config.cycle / (24 * 3600))
                    resetText = days .. "天"
                end            end
        end
        
        resetInfo:SetText(resetText)
        resetInfo:SetTextColor(0.7, 0.9, 1)
    end
    
    return headerFrame
end

-- 创建角色行（修复版 - 完全重写工具提示处理）
local function CreateCharacterRow(parent, char, rowIndex)    local rowFrame = CreateFrame("Frame", nil, parent)
    rowFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, -110 - rowIndex * 25)
    rowFrame:SetWidth(1000) -- 从860调整到1000，匹配表头宽度
    rowFrame:SetHeight(25)
    
    -- 背景色（交替）
    local mod = rowIndex - math.floor(rowIndex / 2) * 2  -- 兼容 WoW 1.12
    local isEven = (mod == 0)
    if isEven then
        rowFrame:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            tile = true, tileSize = 16
        })
        rowFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.3)    end    -- 角色职业图标（使用WoW 1.12经典职业图标TGA文件）
    local classIcon = rowFrame:CreateTexture(nil, "OVERLAY")
    classIcon:SetWidth(18)
    classIcon:SetHeight(18)
    classIcon:SetPoint("LEFT", rowFrame, "LEFT", 2, 0)
    
    -- 设置职业图标纹理和坐标
    local iconCoords = GetClassIconCoords(char.class)
    if char and char.class then
        -- print("DEBUG: 为角色 " .. (char.name or "未知") .. " 设置职业图标，职业=" .. (char.class or "未知") .. "，坐标=" .. table.concat(iconCoords, ","))
    end
    
    -- 使用WoW 1.12的职业创建界面图标文件
    local success = pcall(function()
        classIcon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
        classIcon:SetTexCoord(iconCoords[1], iconCoords[2], iconCoords[3], iconCoords[4])
    end)
    
    if not success then
        -- 如果经典图标加载失败，尝试使用备用路径
        success = pcall(function()
            classIcon:SetTexture("Interface\\Icons\\ClassIcon_Warrior")
        end)
        
        if not success then
            -- 最后的备用方案：显示一个简单的方块
            classIcon:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
            classIcon:SetVertexColor(0.5, 0.5, 0.5, 0.8)
            print("DEBUG: 所有图标加载方案都失败，使用备用显示")
        else
            print("DEBUG: 使用备用图标路径")
        end
    end
    
    -- 角色名称（位置向右调整以为图标留空间）
    local nameText = rowFrame:CreateFontString(nil, "OVERLAY")
    SetCompatibleFont(nameText, 14)
    nameText:SetPoint("LEFT", rowFrame, "LEFT", 25, 0) -- 从0调整到25，为图标留空间
    nameText:SetWidth(125) -- 从150调整到125，因为图标占用了25px
    nameText:SetJustifyH("LEFT")
    
    -- 设置职业颜色
    local classColor = GetClassColor(char.class)
    
    local shortName = string.gsub(char.name, "-.*", "") -- 移除服务器名
    nameText:SetText(shortName .. " (" .. char.level .. ")")
    nameText:SetTextColor(classColor.r, classColor.g, classColor.b)      -- 副本状态 - 带背景色的版本
    for i, raid in ipairs(RAIDS) do        -- 创建按钮用于鼠标事件
        local statusButton = CreateFrame("Button", nil, rowFrame)
        statusButton:SetPoint("LEFT", rowFrame, "LEFT", 150 + (i-1) * 65, 0) -- 从58调整到65，匹配表头
        statusButton:SetWidth(62) -- 从55调整到62，匹配表头
        statusButton:SetHeight(25)        -- 设置按钮背景色（根据副本周期）
        statusButton:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 8,
            insets = { left = 1, right = 1, top = 1, bottom = 1 }
        })
        local cycleColor = CYCLE_COLORS[raid.cycle or "weekly"]
        statusButton:SetBackdropColor(cycleColor.r, cycleColor.g, cycleColor.b, cycleColor.a) -- 使用完全不透明度
        statusButton:SetBackdropBorderColor(cycleColor.r * 0.5, cycleColor.g * 0.5, cycleColor.b * 0.5, 0.8) -- 更深的边框色        -- 创建状态文字
        local statusText = statusButton:CreateFontString(nil, "OVERLAY")
        SetCompatibleFont(statusText, 16) -- 从12增加到16，使符号更大
        statusText:SetPoint("CENTER", statusButton, "CENTER", 0, 0)
        statusText:SetWidth(62) -- 从55调整到62，匹配按钮宽度
        statusText:SetJustifyH("CENTER")
          local isReset, isCompleted = false, false
        local tooltipTitle = raid.fullName or raid.name or "未知"
        local tooltipStatus = ""
        local questStatus = nil -- 在这里声明，确保作用域正确        -- 判断是副本还是任务
        if raid.isQuest then
            -- 处理周任务状态（支持多种状态）
            questStatus, isReset = GetQuestStatus(char.weeklyQuests, raid.id)            -- 调试信息：显示任务状态判断过程
            if char.name and string.find(char.name, GetUnitName("player") or "") then
                -- 只为当前角色显示调试信息
                local debugInfo = string.format("任务 %s 状态: %s, 重置: %s", 
                    raid.name or "未知", questStatus or "nil", tostring(isReset))
                -- print("DEBUG: " .. debugInfo)  -- 关闭调试信息
            end
              if questStatus == "completed" then
                tooltipStatus = "本周已完成"
                isCompleted = true
            elseif questStatus == "inprogress" then
                tooltipStatus = "任务进行中"
                isCompleted = false
            elseif questStatus == "available" and isReset then
                tooltipStatus = "可以接取（已重置）"
                isCompleted = false
            elseif questStatus == "available" and not isReset then
                tooltipStatus = "可接取（可能被放弃）"
                isCompleted = false
            else
                tooltipStatus = "状态未知"
                isCompleted = false
            end
        else
            -- 处理副本状态
            isReset = IsRaidReset(char.progress, raid.id)
            if isReset then
                tooltipStatus = "已重置"
            else
                tooltipStatus = "冷却中"
            end
        end        -- 使用动态符号设置或默认符号
        local resetSymbol = _G.RAID_RESET_SYMBOL or "√"
        local cooldownSymbol = _G.RAID_COOLDOWN_SYMBOL or "×"
        local completedSymbol = _G.QUEST_COMPLETED_SYMBOL or "★"
        local inProgressSymbol = _G.QUEST_INPROGRESS_SYMBOL or ">>>"  -- 波浪号，表示进行中
          if raid.isQuest then
            -- 周任务显示逻辑（直接使用之前获取的 questStatus）
            if questStatus == "completed" then
                statusText:SetText(completedSymbol) -- 已完成任务显示星号
                statusText:SetTextColor(1, 0.8, 0) -- 金色
            elseif questStatus == "inprogress" then
                statusText:SetText(inProgressSymbol) -- 进行中显示箭头
                statusText:SetTextColor(0, 0.8, 1) -- 蓝色
            elseif questStatus == "available" and isReset then
                statusText:SetText(resetSymbol) -- 可接取显示对勾
                statusText:SetTextColor(0, 1, 0) -- 绿色
            elseif questStatus == "available" and not isReset then
                statusText:SetText("○") -- 可接取但未重置显示空心圆
                statusText:SetTextColor(1, 1, 0) -- 黄色
            else
                statusText:SetText("?") -- 未知状态
                statusText:SetTextColor(0.7, 0.7, 0.7) -- 灰色
            end
        else
            -- 副本显示逻辑（保持原有逻辑）
            if isReset then
                statusText:SetText(resetSymbol)
                statusText:SetTextColor(0, 1, 0) -- 绿色
            else
                statusText:SetText(cooldownSymbol)
                statusText:SetTextColor(1, 0, 0) -- 红色
            end
        end        -- 工具提示处理 - 超简单版本
        if _G.CreateUltraSimpleTooltip then
            -- 准备 raidInfo 参数
            local raidInfo = {
                isQuest = raid.isQuest,
                fullName = raid.fullName,
                questStatus = raid.isQuest and questStatus or nil
            }
            _G.CreateUltraSimpleTooltip(statusButton, raid.id, isReset, raidInfo)
        else-- 备用简单版本
            statusButton:SetScript("OnEnter", function()
                if GameTooltip then
                    GameTooltip:SetOwner(statusButton, "ANCHOR_RIGHT")
                    GameTooltip:SetText(tooltipTitle)                    -- 根据类型设置不同的颜色和信息
                    if raid.isQuest then
                        -- 任务特有信息（使用之前获取的 questStatus）
                        if questStatus == "completed" then
                            GameTooltip:AddLine(tooltipStatus, 1, 0.8, 0) -- 金色
                            GameTooltip:AddLine("周常任务", 0.8, 0.8, 0.8) -- 灰色说明
                            GameTooltip:AddLine("等待下周重置", 0.6, 0.6, 1) -- 淡蓝色
                        elseif questStatus == "inprogress" then
                            GameTooltip:AddLine(tooltipStatus, 0, 0.8, 1) -- 蓝色
                            GameTooltip:AddLine("周常任务", 0.8, 0.8, 0.8) -- 灰色说明
                            GameTooltip:AddLine("请完成任务目标", 1, 1, 0.6) -- 淡黄色提示
                        elseif questStatus == "available" and isReset then
                            GameTooltip:AddLine(tooltipStatus, 0, 1, 0) -- 绿色
                            GameTooltip:AddLine("周常任务", 0.8, 0.8, 0.8) -- 灰色说明
                            GameTooltip:AddLine("可前往NPC接取", 0.7, 0.9, 1) -- 浅蓝色提示
                        elseif questStatus == "available" and not isReset then
                            GameTooltip:AddLine(tooltipStatus, 0.8, 0.8, 0) -- 黄色
                            GameTooltip:AddLine("周常任务", 0.8, 0.8, 0.8) -- 灰色说明
                            GameTooltip:AddLine("下次重置：周三 12:00", 1, 0.8, 0.4) -- 橙色时间信息
                        else
                            GameTooltip:AddLine(tooltipStatus, 0.7, 0.7, 0.7) -- 灰色
                            GameTooltip:AddLine("周常任务", 0.8, 0.8, 0.8) -- 灰色说明
                            GameTooltip:AddLine("状态未明", 1, 0.5, 0.5) -- 红色警告
                        end
                    else
                        -- 副本特有信息
                        if isReset then
                            GameTooltip:AddLine(tooltipStatus, 0, 1, 0) -- 绿色
                            GameTooltip:AddLine("副本进度", 0.8, 0.8, 0.8) -- 灰色说明
                        else
                            GameTooltip:AddLine(tooltipStatus, 1, 0, 0) -- 红色
                            GameTooltip:AddLine("副本进度", 0.8, 0.8, 0.8) -- 灰色说明
                        end
                    end
                    
                    GameTooltip:Show()
                end
            end)
            
            statusButton:SetScript("OnLeave", function()
                if GameTooltip then
                    GameTooltip:Hide()
                end
            end)
        end
    end
    
    return rowFrame
end

-- 创建真正的表格界面
local function CreateRealTableGrid()
    -- 如果界面已存在，先隐藏并销毁，然后重新创建以刷新数据
    if mainFrame then
        mainFrame:Hide()
        mainFrame = nil
        tableRows = {} -- 清空行数据
        isUIVisible = false  -- 重置状态
    end-- 创建主窗口
    mainFrame = CreateFrame("Frame", "RealTableGridFrame", UIParent)
    mainFrame:SetWidth(1050) -- 从900调整到1050，容纳更多列
    mainFrame:SetHeight(600) -- 从500调整到600，给更多行留空间
    mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    mainFrame:SetFrameStrata("HIGH")
    mainFrame:SetFrameLevel(100)

    -- 设置背景
    mainFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
      -- 设置为可移动
    mainFrame:EnableMouse(true)
    mainFrame:SetMovable(true)
    mainFrame:RegisterForDrag("LeftButton")
    mainFrame:SetScript("OnDragStart", function()
        mainFrame:StartMoving()
    end)
    mainFrame:SetScript("OnDragStop", function()
        mainFrame:StopMovingOrSizing()
    end)
      -- 支持ESC键关闭 (WoW 1.12兼容版本)
    mainFrame:EnableKeyboard(true)
    mainFrame:SetScript("OnKeyDown", function()
        if arg1 == "ESCAPE" then
            RealTableGridUI.Hide()
        end
    end)
    
    -- 确保窗口获得键盘焦点并注册到ESC关闭序列
    mainFrame:SetScript("OnShow", function()
        -- 在WoW 1.12中，使用table.insert添加到UISpecialFrames以支持ESC键
        if not tContains(UISpecialFrames, "RealTableGridFrame") then
            table.insert(UISpecialFrames, "RealTableGridFrame")
        end
        -- 设置键盘焦点
        this:SetFocus()
    end)
    
    -- 当窗口隐藏时从ESC序列中移除
    mainFrame:SetScript("OnHide", function()
        -- 从UISpecialFrames中移除
        for i = 1, table.getn(UISpecialFrames) do
            if UISpecialFrames[i] == "RealTableGridFrame" then
                table.remove(UISpecialFrames, i)
                break
            end
        end
        isUIVisible = false
    end)
      -- 标题
    local title = mainFrame:CreateFontString(nil, "OVERLAY")
    SetCompatibleFont(title, 16)
    title:SetPoint("TOP", mainFrame, "TOP", 0, -15)
    title:SetText("副本进度检查 2.0 - 作者:吊儿啷当")
    title:SetTextColor(1, 1, 0)
    
    -- 关闭按钮
    local closeBtn = CreateFrame("Button", nil, mainFrame)
    closeBtn:SetWidth(20)
    closeBtn:SetHeight(20)
    closeBtn:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -10, -10)
      local closeBtnText = closeBtn:CreateFontString(nil, "OVERLAY")
    SetCompatibleFont(closeBtnText, 12)
    closeBtnText:SetPoint("CENTER", closeBtn, "CENTER", 0, 0)
    closeBtnText:SetText("X")
    closeBtnText:SetTextColor(1, 0, 0)
      closeBtn:SetScript("OnClick", function()
        mainFrame:Hide()
        isUIVisible = false  -- 更新状态
    end)
    
    -- 创建表格头部
    CreateTableHeader(mainFrame)
    
    -- 获取角色数据并创建行
    local chars = GetCharacterData()
      -- 检查是否有角色数据
    local hasData = false
    local charCount = 0
    for _ in pairs(chars) do
        hasData = true
        charCount = charCount + 1
    end
    
    if hasData then
        for i, char in ipairs(chars) do
            if i > 15 then -- 限制显示行数
                break
            end
            CreateCharacterRow(mainFrame, char, i-1)
        end    else        -- 没有数据时显示提示
        local noDataText = mainFrame:CreateFontString(nil, "ARTWORK")
        SetCompatibleFont(noDataText, 14)  -- 增大字体以提高可见性
        noDataText:SetPoint("CENTER", mainFrame, "CENTER", 0, 0)
        noDataText:SetText("没有找到55级以上的角色数据\n\n请进入一些副本让插件记录数据")
        noDataText:SetTextColor(1, 0.8, 0.2)  -- 改为更亮的黄色
        -- 添加文字阴影以提高可读性
        noDataText:SetShadowColor(0, 0, 0, 1)
        noDataText:SetShadowOffset(1, -1)
        -- 设置更高的帧级别确保不被遮挡
        noDataText:SetDrawLayer("ARTWORK", 7)  -- 使用子层级7，确保在最前面
    end-- 底部说明（左侧）
    local infoText = mainFrame:CreateFontString(nil, "OVERLAY")
    infoText:SetFont("Fonts\\FRIZQT__.TTF", 11)
    infoText:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 20, 50)
    infoText:SetText("绿色=已重置可进入  红色=有CD未重置  鼠标悬停查看详情")
    infoText:SetTextColor(0.8, 0.8, 0.8)
    
    -- 颜色图例说明
    local legendText = mainFrame:CreateFontString(nil, "OVERLAY")
    legendText:SetFont("Fonts\\FRIZQT__.TTF", 10)
    legendText:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 20, 35)
    legendText:SetText("背景色: 蓝色=周重置  红色=5天重置  绿色=3天重置  黄色=周常任务")
    legendText:SetTextColor(0.7, 0.7, 0.7)
    
    --任务状态图例说明
    local questLegendText = mainFrame:CreateFontString(nil, "OVERLAY")
    questLegendText:SetFont("Fonts\\FRIZQT__.TTF", 10)
    questLegendText:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 20, 20)
    questLegendText:SetText("任务符号: ★=已完成  >>>=进行中  √=可接取(已重置)")
    questLegendText:SetTextColor(0.7, 0.7, 0.7)

    -- 服务器信息（右下角）
    local serverText = mainFrame:CreateFontString(nil, "OVERLAY")
    serverText:SetFont("Fonts\\FRIZQT__.TTF", 10)
    serverText:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -20, 20)    serverText:SetText("服务器: " .. (GetRealmName() or "未知"))
    serverText:SetTextColor(0.6, 0.8, 1)
      mainFrame:Show()
    isUIVisible = true  -- 更新状态
end

-- 公共接口
function RealTableGridUI.Show()
    -- 在显示界面前更新当前角色的周任务数据
    if RaidProgress and RaidProgress.UpdateWeeklyQuests then
        RaidProgress:UpdateWeeklyQuests()
    end
    
    CreateRealTableGrid()
end

function RealTableGridUI.Hide()
    if mainFrame then
        mainFrame:Hide()
    end
    isUIVisible = false  -- 更新状态
end

-- 添加状态检查函数
function RealTableGridUI.IsVisible()
    return isUIVisible and mainFrame and mainFrame:IsShown()
end

-- RaidInfoFrame 集成功能
function RealTableGridUI.ShowCombinedInfo()
    -- 让窗口显示在 RaidInfoFrame 右侧
    if RaidInfoFrame then
        -- 更新数据
        if RaidProgress and RaidProgress.UpdateWeeklyQuests then
            RaidProgress:UpdateWeeklyQuests()
        end
        
        CreateRealTableGrid()
        
        -- 重新定位界面到 RaidInfoFrame 右侧
        if mainFrame then
            mainFrame:ClearAllPoints()
            mainFrame:SetPoint("TOPLEFT", RaidInfoFrame, "TOPRIGHT", 10, 0)
        end
    else
        -- 如果没有 RaidInfoFrame，就正常显示在中央
        RealTableGridUI.Show()
    end
end

function RealTableGridUI.HideCombinedInfo()
    RealTableGridUI.Hide()
end

-- 等待 RaidInfoFrame 加载完成再添加钩子
local function SetupRaidInfoFrameHook()
    local hookFrame = CreateFrame("Frame")
    hookFrame:RegisterEvent("ADDON_LOADED")
    hookFrame:SetScript("OnEvent", function(_, addonName)
        -- 检查是否是 Blizzard_RaidUI 或者 RaidInfoFrame 已经可用
        if addonName == "Blizzard_RaidUI" or RaidInfoFrame then
            if RaidInfoFrame and RaidInfoFrame.SetScript then
                -- 当 RaidInfoFrame 显示时，显示我们的界面
                RaidInfoFrame:SetScript("OnShow", function()
                    RealTableGridUI.ShowCombinedInfo()
                end)
                
                -- 当 RaidInfoFrame 隐藏时，隐藏我们的界面
                RaidInfoFrame:SetScript("OnHide", function()
                    RealTableGridUI.HideCombinedInfo()
                end)
                
                print("|cFF00FF00RaidProgress 2.0: 已启用副本信息面板集成功能|r")
            end
            hookFrame:UnregisterEvent("ADDON_LOADED")
        end
    end)
end

-- 初始化 RaidInfoFrame 钩子
SetupRaidInfoFrameHook()

-- 注册测试命令
SLASH_RPGRID1 = "/rpgrid"
SlashCmdList["RPGRID"] = function(msg)
    RealTableGridUI.Show()
end

-- 覆盖所有相关命令
SLASH_RPNEWGRID1 = "/rpnew"
SLASH_RPMAINGRID1 = "/rp"
SlashCmdList["RPNEWGRID"] = function(msg)
    RealTableGridUI.Show()
end

SlashCmdList["RPMAINGRID"] = function(msg)
    local command = string.lower(msg or "")
    if command == "" or command == "progress" then
        RealTableGridUI.Show()
    elseif command == "old" then
        if RaidProgress and RaidProgress.ShowProgress then
            RaidProgress:UpdateCharacterInfo()
            RaidProgress:UpdateAllInstances()
            RaidProgress:ShowProgress()
        else
            print("|cFFFF0000传统界面不可用|r")
        end
    else
        print("|cFFFFFF00RaidProgress 2.0 命令:|r")
        print("  |cFFFFAAAA/rp|r - 显示真正的表格界面")
        print("  |cFFFFAAAA/rp old|r - 显示传统界面") 
        print("  |cFFFFAAAA/rpgrid|r - 测试表格界面")
    end
end


