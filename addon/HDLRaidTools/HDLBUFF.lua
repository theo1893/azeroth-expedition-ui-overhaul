HDLUI = {}

HDLUI.REPORT = 0
HDLUI.REPORTTIME = GetTime()
HDLUI.UpDateTime = GetTime()

--默认祝福分配方式,可自行根据下方备注进行调整
--1-智慧祝福，2-力量祝福，3-拯救祝福，4-光明祝福，5-王者祝福，6-庇护祝福

HDLUI.DefaultBleesing = {
    --团队仅有1名骑士时
    [1] = {
        --骑士1默认加buff方式
        [1] = {3,3,1,1,1,3,3,3,1}
        
    },
    --团队仅有2名骑士时
    [2] = {
        --骑士1默认加buff方式
        [1] = {3,3,1,1,1,3,3,3,1},
        --骑士2默认加buff方式
        [2] = {5,5,5,5,5,5,5,5,5}
    },
    [3] = {
        [1] = {3,3,3,3,3,3,3,3,3},
        [2] = {5,5,5,5,5,5,5,5,5},
        [3] = {2,2,1,1,1,1,1,1,1}
    },
    [4] = {
        [1] = {3,3,3,3,3,3,3,3,3},
        [2] = {5,5,5,5,5,5,5,5,5},
        [3] = {2,2,0,2,2,0,0,0,2},
        [4] = {0,0,1,1,1,1,1,1,1},
    },
    [5] = {
        [1] = {3,3,3,3,3,3,3,3,3},
        [2] = {5,5,5,5,5,5,5,5,5},
        [3] = {2,2,0,2,2,0,0,0,2},
        [4] = {0,0,1,1,1,1,1,1,1},
        [5] = {4,4,4,4,4,4,4,4,4}
    },
    [6] = {
        [1] = {3,3,3,3,3,3,3,3,3},
        [2] = {5,5,5,5,5,5,5,5,5},
        [3] = {2,2,0,2,2,0,0,0,2},
        [4] = {0,0,1,1,1,1,1,1,1},
        [5] = {4,4,4,4,4,4,4,4,4},
        [6] = {6,6,6,6,6,6,6,6,6}
    } 
}

--是否是团队领袖
function  HDLUI.IsRaidLeader()
    for i = 1, GetNumRaidMembers() do
        local name, rank = GetRaidRosterInfo(i)
        if name and name == UnitName("player") and rank > 0 then
            return true
        end
    end
    return false
end


-- 计算列表中某个值出现的次数
function HDLUI.CountValueOccurrences(tbl, value)
    local count = 0
    for _, v in ipairs(tbl) do
        if v == value then
            count = count + 1
        end
    end
    return count
end

--获取团队中，指定职业的人数及所有名字的函数
function  HDLUI.GetClassN(class)
    local num = 0
    local result = {};
    -- 默认处理40人团队
    for i = 1, 40 do
        local p = "raid"..i
        local getclass,_ = UnitClass(p);
        if getclass == class then 
            num = num + 1
            name,_ = UnitName(p)
            table.insert(result,name)
        end
    end
    return num,result
end

--获取团队中，各小队的人数
function HDLUI.GetGroupN()

    local TeamPlayers = {}
    for i = 1, 8 do
        TeamPlayers[i] = 0
    end

    for i = 1, 40 do
        -- 获取团队成员信息
        local name, rank, subgroup, level, class, classEN, online, _, _, _, _, _ = GetRaidRosterInfo(i)
        
        -- 检查是否成功获取到了信息
        if subgroup then
            TeamPlayers[subgroup] = TeamPlayers[subgroup] + 1
        end
    end
    TeamNumHasPlayer = 0
    for i = 1, 8 do
		if TeamPlayers[i] > 0 then
			TeamNumHasPlayer = TeamNumHasPlayer + 1
		end
    end
    return TeamNumHasPlayer, TeamPlayers
end

--- 拷贝函数
function DeepCopy(t)
    if type(t) ~= "table" then
        return t
    end

    local mt = getmetatable(t)
    local res = {}
    for k, v in pairs(t) do
        res[DeepCopy(k)] = DeepCopy(v)
    end
    setmetatable(res, DeepCopy(mt))
    return res
end

--- 恢复默认值的函数
function HDLUI.RestoreBuffList()
    if not HDLUIBuffListDefault then
        error("HDLUIBuffListDefault 未定义！")
    end
    HDLUIBuffList = DeepCopy(HDLUIBuffListDefault)
end

--分配牧师、法师、德鲁伊加buff的函数
function HDLUI.AutoClassBuff(class)
    local classToBuff = {
        ["牧师"] = "Fortitude",
        ["法师"] = "Intellect",
        ["德鲁伊"] = "WildMark"
    }

    local TeamNumHasPlayer, TeamPlayers = HDLUI.GetGroupN()
    local BuffClassNum, BuffClassNames = HDLUI.GetClassN(class)
    -- local TeamNumHasPlayer = 8
    -- local TeamPlayers = {1, 2, 3, 4, 5, 6, 7, 8}
    -- local BuffClassNum = 4
    -- local BuffClassNames = {"乌鸡", "牛大", "黑法", "白骨", "迷路", "卡拉米"}

    HDLUIBuffList[classToBuff[class]]["Nums"] = BuffClassNum
    HDLUIBuffList[classToBuff[class]]["Names"] = BuffClassNames

    if BuffClassNum > 0 then
        local numBuffsPerPlayer = math.floor(TeamNumHasPlayer / BuffClassNum)
        local extraBuffs = math.mod(TeamNumHasPlayer, BuffClassNum )-- 改用取余确保正确计算余数
        local currentPlayerIndex = 1
        local assignedBuffs = {}  -- 记录每个法师已分配的队伍数

        -- 初始化每个法师的已分配数
        for i = 1, BuffClassNum do
            assignedBuffs[i] = 0
        end

        -- 优先分配余数（extraBuffs）给前几位法师
        for i = 1, TeamNumHasPlayer do
            if currentPlayerIndex > BuffClassNum then
                currentPlayerIndex = 1  -- 循环重置，避免越界
            end

            -- 分配队伍给当前法师
            local team = i  -- 假设按顺序分配
            HDLUIBuffList[classToBuff[class]][team] = BuffClassNames[currentPlayerIndex]
            UIDropDownMenu_SetText(BuffClassNames[currentPlayerIndex], HDLUI.BuffWindow[classToBuff[class]..team])

            -- 更新已分配数
            assignedBuffs[currentPlayerIndex] = assignedBuffs[currentPlayerIndex] + 1

            -- 判断是否达到分配上限
            if assignedBuffs[currentPlayerIndex] >= numBuffsPerPlayer + (currentPlayerIndex <= extraBuffs and 1 or 0) then
                currentPlayerIndex = currentPlayerIndex + 1
            end
        end
    end
end

--分配诅咒的函数
function HDLUI.AutoCruseBuff()
    local BuffClassNum, BuffClassNames = HDLUI.GetClassN("术士")
    -- local BuffClassNum = 4
    -- local BuffClassNames = {"乌鸡", "牛大", "黑法", "白骨", "迷路", "卡拉米"}

    HDLUIBuffList["Curse"]["Nums"] = BuffClassNum
    HDLUIBuffList["Curse"]["Names"] = BuffClassNames


    for i = 1, 4 do
        if i > BuffClassNum then
            UIDropDownMenu_SetText("<空>", HDLUI.BuffWindow["Curse"..i])
        else
            HDLUIBuffList["Curse"][i] = BuffClassNames[i]
            UIDropDownMenu_SetText(BuffClassNames[i], HDLUI.BuffWindow["Curse"..i])
        end
    end
end

--分配骑士祝福的函数
function HDLUI.AutoBlessingBuff()
    --存储 HDLUIBuffList["Blessing"] ["paladinBlessing"]["paladinName1"][1]
    --图标 PaladinNames[index]..iconIndex
    --名字 "BlessingPaladinButton"..index

    local BuffClassNum, BuffClassNames = HDLUI.GetClassN("圣骑士")
    -- local BuffClassNum = 3
    -- local BuffClassNames = {"乌鸡", "牛大", "黑法", "白骨", "迷路", "卡拉米"}
    HDLUIBuffList["Blessing"]["Nums"] = BuffClassNum
    HDLUIBuffList["Blessing"]["Names"] = BuffClassNames

    HDLUI.RefreshBlessingFrame(BuffClassNum, BuffClassNames)

    for PaladinNumIndex = 1, BuffClassNum do
        getglobal("BlessingPaladinButton"..PaladinNumIndex):SetText(BuffClassNames[PaladinNumIndex]) -- 重复了
        for BlessingIndex = 1, 9 do
            HDLUI.BuffWindow.BlessingFrame.PaladinBlessingButtonsClick[PaladinNumIndex][BlessingIndex].Texture:SetTexture(HDL_BlessingIcon[HDLUI.DefaultBleesing[BuffClassNum][PaladinNumIndex][BlessingIndex]])
            HDLUIBuffList["Blessing"]["paladinBlessing"][PaladinNumIndex] = HDLUIBuffList["Blessing"]["paladinBlessing"][PaladinNumIndex] or {}
            HDLUIBuffList["Blessing"]["paladinBlessing"][PaladinNumIndex][BlessingIndex] = HDLUI.DefaultBleesing[BuffClassNum][PaladinNumIndex][BlessingIndex]
        end
    end
end

function HDLUI.ResetAllDropdowns()
    -- 定义需要重置的类别及其对应的下拉菜单数量和配置
    local categories = {
        { prefix = "Fortitude", count = 8, key = "Fortitude" },
        { prefix = "Intellect", count = 8, key = "Intellect" },
        { prefix = "WildMark", count = 8, key = "WildMark" },
        { prefix = "Curse", count = 4, key = "Curse" },
        { prefix = "Tank", count = 4, key = "Tank" }
    }

    -- 遍历所有分类
    for _, category in ipairs(categories) do
        -- 清空内存数据
        HDLUIBuffList[category.key]["Names"] = {}
        HDLUIBuffList[category.key]["Nums"] = 0
        
        -- 遍历每个下拉菜单
        for i = 1, category.count do
            -- 获取下拉菜单的全局名称
            local dropdownName = "HDLUIBuffWindow"..category.prefix..i
            local dropdown = _G[dropdownName]
            
            if dropdown then
                -- 设置下拉菜单显示文本
                UIDropDownMenu_SetText("<空>", dropdown)
                -- 更新数据存储
                HDLUIBuffList[category.key][i] = ""
            end
        end
    end
end

--自动分配加buff任务的函数
function HDLUI.AutoBuff()
    HDLUI.ResetAllDropdowns()
    HDLUI.RestoreBuffList()
    HDLUI.AutoClassBuff("牧师")
    HDLUI.AutoClassBuff("法师")
    HDLUI.AutoClassBuff("德鲁伊")
    HDLUI.AutoCruseBuff()
    HDLUI.AutoBlessingBuff()
end

--通报：耐力、爪子、智力
function HDLUI.generateReport(bufflist, buffname)
    if not bufflist then
        error("Error: bufflist cannot be nil!")  -- 参数校验
    end

    local buffData = bufflist
    if not buffData then
        error(string.format("Error: No data found for buff '%s'!", bufflist))  -- 检查是否存在该BUFF的数据
    end

    local result = {}
    local nameToTeams = {}

    -- 统计每个名字对应的队伍编号
    for team, name in pairs(buffData) do
        if type(team) == "number" and name ~= "" then
            if not nameToTeams[name] then
                nameToTeams[name] = {}
            end
            table.insert(nameToTeams[name], team)
        end
    end

    -- 格式化结果
    for name, teams in pairs(nameToTeams) do
        table.sort(teams)
        local teamStr = table.concat(teams, "、") .. "队"
        table.insert(result, string.format("[%s：%s]", name, teamStr))
    end

    -- 拼接最终字符串
    local formattedReport = buffname.."： " .. table.concat(result, " ")
    return formattedReport
end

function HDLUI.CurseReport()
    local result = "|cff800080诅咒|r： "
    if HDLUIBuffList["Curse"][1] ~= "" then
        result = result.."[鲁莽："..HDLUIBuffList["Curse"][1].."] "
    end
    if HDLUIBuffList["Curse"][2] ~= "" then
        result = result.."[元素："..HDLUIBuffList["Curse"][2].."] "
    end
    if HDLUIBuffList["Curse"][3] ~= "" then
        result = result.."[暗影："..HDLUIBuffList["Curse"][3].."] "
    end
    if HDLUIBuffList["Curse"][4] ~= "" then
        result = result.."[语言："..HDLUIBuffList["Curse"][4].."] "
    end
    return result
end

function HDLUI.TankReport()
    local result = "|cffFFD700坦克|r： "
    if HDLUIBuffList["Tank"][1] ~= "" then
        result = result.."[1T："..HDLUIBuffList["Tank"][1].." →|cffFFFFFF骷髅|r] "
    end
    if HDLUIBuffList["Tank"][2] ~= "" then
        result = result.."[2T："..HDLUIBuffList["Tank"][2].." →|cffFF0000叉子|r] "
    end
    if HDLUIBuffList["Tank"][3] ~= "" then
        result = result.."[3T："..HDLUIBuffList["Tank"][3].." →|cff00BFFF方块|r] "
    end
    if HDLUIBuffList["Tank"][4] ~= "" then
        result = result.."[4T："..HDLUIBuffList["Tank"][4].." →|cffF0F0FF月亮|r] "
    end
    if result == "|cffFFD700坦克|r： " then
        result = "|cffFFD700坦克|r： 未分配"
    end
    return result
end

function HDLUI.BlessingReport()

    local blessingToNum = {
        [1] = "智慧祝福",
        [2] = "力量祝福",
        [3] = "拯救祝福",
        [4] = "光明祝福",
        [5] = "王者祝福",
        [6] = "庇护祝福"
    }

    local result = "|cffFFB6C1祝福|r： "
    for paladingNamesIndex = 1, HDLUIBuffList["Blessing"]["Nums"] do
        result = result.."["..HDLUIBuffList["Blessing"]["Names"][paladingNamesIndex]..":"
        for blessingIndex = 1, 9 do
            local blessingString = blessingToNum[HDLUIBuffList["Blessing"]["paladinBlessing"][paladingNamesIndex][blessingIndex]] or ""
            if blessingString ~= "" and not string.find(result, blessingString) then
                if string.sub(result, -1) == ":" then
                    result = result..blessingString
                else
                    result = result..","..blessingString
                end
            end
        end
        result = result.."]"
    end
    return result
end



--团队通报的函数
function HDLUI.BuffAllocationReport()
    SendChatMessage(HDLUI.generateReport(HDLUIBuffList["Fortitude"], "|cffFFFFFF耐力|r"), "raid")
    SendChatMessage(HDLUI.generateReport(HDLUIBuffList["Intellect"], "|cff00BFFF智力|r"), "raid")
    SendChatMessage(HDLUI.generateReport(HDLUIBuffList["WildMark"] , "|cffA0522D爪子|r"), "raid")
    SendChatMessage(HDLUI.CurseReport(), "raid")
    SendChatMessage(HDLUI.TankReport(), "raid")
    SendChatMessage(HDLUI.BlessingReport(), "raid")
    HDLUI.SendToPallyPower()
end

--检查耐智爪的函数
function HDLUI.generateCheck()

end

--祝福检查
function HDLUI.blessingCheck()

end

HDLUI.buffCheckList = {
    ["战士"]     = { ["拯救祝福"] = 1, ["光明祝福"] = 1, ["王者祝福"] = 1, ["耐力"] = 1, ["爪子"] = 1, ["力量祝福"] = 1,  ["庇护祝福"] = nil, ["智慧祝福"] = nil, ["智力"] = nil },
    ["猎人"]     = { ["拯救祝福"] = 1, ["光明祝福"] = 1, ["王者祝福"] = 1, ["耐力"] = 1, ["爪子"] = 1, ["力量祝福"] = nil, ["庇护祝福"] = nil, ["智慧祝福"] = 1,  ["智力"] = 1   },
    ["盗贼"]     = { ["拯救祝福"] = 1, ["光明祝福"] = 1, ["王者祝福"] = 1, ["耐力"] = 1, ["爪子"] = 1, ["力量祝福"] = 1,  ["庇护祝福"] = nil, ["智慧祝福"] = nil, ["智力"] = nil },
    ["牧师"]     = { ["拯救祝福"] = 1, ["光明祝福"] = 1, ["王者祝福"] = 1, ["耐力"] = 1, ["爪子"] = 1, ["力量祝福"] = nil, ["庇护祝福"] = nil, ["智慧祝福"] = 1,  ["智力"] = 1   },
    ["法师"]     = { ["拯救祝福"] = 1, ["光明祝福"] = 1, ["王者祝福"] = 1, ["耐力"] = 1, ["爪子"] = 1, ["力量祝福"] = nil, ["庇护祝福"] = nil, ["智慧祝福"] = 1,  ["智力"] = 1   },
    ["术士"]     = { ["拯救祝福"] = 1, ["光明祝福"] = 1, ["王者祝福"] = 1, ["耐力"] = 1, ["爪子"] = 1, ["力量祝福"] = nil, ["庇护祝福"] = nil, ["智慧祝福"] = 1,  ["智力"] = 1   },
    ["德鲁伊"]   = { ["拯救祝福"] = 1, ["光明祝福"] = 1, ["王者祝福"] = 1, ["耐力"] = 1, ["爪子"] = 1, ["力量祝福"] = 1,  ["庇护祝福"] = nil, ["智慧祝福"] = 1,  ["智力"] = 1   },
    ["圣骑士"]   = { ["拯救祝福"] = 1, ["光明祝福"] = 1, ["王者祝福"] = 1, ["耐力"] = 1, ["爪子"] = 1, ["力量祝福"] = 1,  ["庇护祝福"] = nil,   ["智慧祝福"] = 1,  ["智力"] = 1   },
    ["萨满祭司"] = { ["拯救祝福"] = 1, ["光明祝福"] = 1, ["王者祝福"] = 1, ["耐力"] = 1, ["爪子"] = 1, ["力量祝福"] = 1,  ["庇护祝福"] = nil, ["智慧祝福"] = 1,  ["智力"] = 1   }
}

HDLUI.buffCheckIcon = {
    ["智慧祝福"] = {"Interface\\Icons\\Spell_Holy_SealOfWisdom",        "Interface\\Icons\\Spell_Holy_GreaterBlessingofWisdom"      },
    ["拯救祝福"] = {"Interface\\Icons\\Spell_Holy_SealOfSalvation",     "Interface\\Icons\\Spell_Holy_GreaterBlessingofSalvation"   },
    ["力量祝福"] = {"Interface\\Icons\\Spell_Holy_FistOfJustice",       "Interface\\Icons\\Spell_Holy_GreaterBlessingofKings"       },
    ["光明祝福"] = {"Interface\\Icons\\Spell_Holy_PrayerOfHealing02",   "Interface\\Icons\\Spell_Holy_GreaterBlessingofLight"       },
    ["王者祝福"] = {"Interface\\Icons\\Spell_Magic_MageArmor",          "Interface\\Icons\\Spell_Magic_GreaterBlessingofKings"      },
    ["庇护祝福"] = {"Interface\\Icons\\Spell_Nature_LightningShield",   "Interface\\Icons\\Spell_Holy_GreaterBlessingofSanctuary"   },
    ["智力"]    = {"Interface\\Icons\\Spell_Holy_MagicalSentry",        "Interface\\Icons\\Spell_Holy_ArcaneIntellect"              },
    ["耐力"]    = {"Interface\\Icons\\Spell_Holy_WordFortitude",        "Interface\\Icons\\Spell_Holy_PrayerOfFortitude"            },
    ["爪子"]    = {"Interface\\Icons\\Spell_Nature_Regeneration",       "Interface\\Icons\\Spell_Nature_Regeneration"               }
}

--生成TANK人员的名单列表
function HDLUI.TankList()
    local TankList = {}
    for i = 1, 4 do
        if HDLUIBuffList["Tank"][i] ~= "" then
            --将当前HDLUIBuffList["Tank"][i]的值加入到TankList中
            table.insert(TankList, HDLUIBuffList["Tank"][i])
        end
    end
    return TankList
end

--生成加BUFF人员的名单列表
function HDLUI.GetBuffPlayerList()

    -- 获取各个职业名称列表
    local num, namelist1 = HDLUI.GetClassN("牧师")
    local num, namelist2 = HDLUI.GetClassN("法师")
    local num, namelist3 = HDLUI.GetClassN("德鲁伊")
    local num, namelist4 = HDLUI.GetClassN("圣骑士")

    -- 合并namelist1-3
    local namelist = {}

    -- 定义一个辅助函数来检查表是否为空
    local function isNotEmpty(tbl)
        if tbl == nil then return false end -- 如果是nil直接返回false
        for _, _ in pairs(tbl) do
            return true -- 只要有任何一个元素就返回true
        end
        return false -- 循环完没有找到元素则返回false
    end
    if isNotEmpty(namelist1) then
        for _, value in ipairs(namelist1) do
            table.insert(namelist, value)
        end
    end
    if isNotEmpty(namelist2) then
        for _, value in ipairs(namelist2) do
            table.insert(namelist, value)
        end
    end
    if isNotEmpty(namelist3) then
        for _, value in ipairs(namelist3) do
            table.insert(namelist, value)
        end
    end
    if isNotEmpty(namelist4) then
        for _, value in ipairs(namelist4) do
            table.insert(namelist, value)
        end
    end

    -- 生成一个空的加BUFF人员列表BuffPlayerList,每个人名都是一个表，用于存储缺少BUFF玩家的名字和队伍
    local BuffPlayerList = {}
    for _,value in pairs(namelist) do
        BuffPlayerList[value] = ""
    end

    return BuffPlayerList
end

--生成加BUFF人员的名单列表
function HDLUI.BlessingPlayerList()
    local numToClass = {
        [1] = "战士",
        [2] = "盗贼",
        [3] = "牧师",
        [4] = "德鲁伊",
        [5] = "圣骑士",
        [6] = "猎人",
        [7] = "法师",
        [8] = "术士",
        [9] = "萨满祭司"
    }

    local numToBlessing = {
        [1] = "智慧祝福",
        [2] = "力量祝福",
        [3] = "拯救祝福",
        [4] = "光明祝福",
        [5] = "王者祝福",
        [6] = "庇护祝福"
    }
    --blessingIndex[buffname][class]
    local BlessingPlayerList = {}
    local num = 0
    local names = {}
    if HDLUIBuffList["Blessing"]["Names"] ~= {} then
        num = HDLUIBuffList["Blessing"]["Nums"]
        names = HDLUIBuffList["Blessing"]["Names"]
    else
        num, names = HDLUI.GetClassN("圣骑士")
    end


    local BuffList = HDLUIBuffList["Blessing"]["paladinBlessing"]

    for paladingIndex = 1, num do
        for blessingIndex = 1, 9 do
            BuffList[paladingIndex] = BuffList[paladingIndex] or {}
            local buffname = numToBlessing[BuffList[paladingIndex][blessingIndex]] or ""
            local class = numToClass[blessingIndex]
            BlessingPlayerList[buffname] = BlessingPlayerList[buffname] or {}
            BlessingPlayerList[buffname][class] = names[paladingIndex]
        end
    end
    return BlessingPlayerList
end



--生成需要加BUFF信息的表
function HDLUI.BuffCheck(BuffPlayerList, TankList, BlessingPlayerList)

    local classToBuff = {
        ["耐力"] = HDLUIBuffList["Fortitude"],
        ["智力"] = HDLUIBuffList["Intellect"],
        ["爪子"] = HDLUIBuffList["WildMark"]

    }

    for playerIndex = 1, 40 do
        local playerID = "raid"..playerIndex
        local name, rank, subgroup, level, class, classEN, online, _, _, _, _, _ = GetRaidRosterInfo(playerIndex)
        if name and online~="离线" then
            for buffName,_ in pairs(HDLUI.buffCheckList[class]) do
                --print(name.."-"..subgroup.."-"..class)
                --判定当前职业是否需要加当前BUFF
                if HDLUI.buffCheckList[class][buffName] then
                    --判定当前职业是否已经加了当前BUFF
                    local buffIcon1 = HDLUI.buffCheckIcon[buffName][1]
                    local buffIcon2 = HDLUI.buffCheckIcon[buffName][2]

                    local hasBuff = false
                    local buffIndex = 1
                    while UnitBuff(playerID, buffIndex) do
                        local buffTexture,_ = UnitBuff(playerID, buffIndex)
                        if buffTexture == buffIcon1 or buffTexture == buffIcon2 then
                            hasBuff = true
                            break
                        end
                        buffIndex = buffIndex + 1
                    end
                    
                    --如果没有加BUFF
                    if not hasBuff then
                        --找到加此队伍此buff的人员                     
                        if buffName == "耐力" or buffName == "智力" or buffName == "爪子" then
                            local buffPlayer = classToBuff[buffName][subgroup] or ""
                            if buffPlayer and buffPlayer ~= "" then
                                if BuffPlayerList[buffPlayer] == "" then
                                    BuffPlayerList[buffPlayer] = "请及时为以下玩家补"..buffName.."BUFF: "..name.."["..subgroup.."队]"
                                else
                                    BuffPlayerList[buffPlayer] = BuffPlayerList[buffPlayer]..","..name.."["..subgroup.."队]"
                                end
                            end
                        end

                        if buffName == "拯救祝福" or buffName == "光明祝福" or buffName == "王者祝福" or buffName == "力量祝福" or buffName == "庇护祝福" or buffName == "智慧祝福" then
                            BlessingPlayerList[buffName] = BlessingPlayerList[buffName] or {}
                            if  BlessingPlayerList[buffName]~={} then
                                local buffPlayer = BlessingPlayerList[buffName][class]
                                if buffPlayer and buffName ~= "拯救祝福" then
                                    if BuffPlayerList[buffPlayer] == "" then
                                        BuffPlayerList[buffPlayer] = "请及时为以下玩家补"..buffName.."BUFF: "..name.."["..subgroup.."队]"
                                    else
                                        BuffPlayerList[buffPlayer] = BuffPlayerList[buffPlayer]..","..name.."["..subgroup.."队]"
                                    end
                                end
                                if buffPlayer and buffName == "拯救祝福" then
                                    if HDLUI.CountValueOccurrences(TankList, name) == 0 then
                                        if BuffPlayerList[buffPlayer] == "" then
                                            BuffPlayerList[buffPlayer] = "请及时为以下玩家补"..buffName.."BUFF: "..name.."["..subgroup.."队]"
                                        else
                                            BuffPlayerList[buffPlayer] = BuffPlayerList[buffPlayer]..","..name.."["..subgroup.."队]"
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return BuffPlayerList
end

--buff检查函数
function HDLUI.BuffCheckAndReport()
    --加BUFF人员列表
    BuffPlayerList = HDLUI.GetBuffPlayerList()
    --坦克列表
    TankList = HDLUI.TankList()
    --祝福查询表
    BlessingPlayerList = HDLUI.BlessingPlayerList()
    --获取广播内容列表
    HDLUI.BuffPlayerList = HDLUI.BuffCheck(BuffPlayerList, TankList, BlessingPlayerList)

    --广播
    if HDLUI.REPORT == 0 then
        HDLUI.GETTIME = GetTime()
        print("|cff00ff00开始进行补BUFF通知！|r")
        print("|cff00ff00------------------|r")
        HDLUI.REPORT = 1
    else
        print("|cffff0000------------------|r")
        print("|cffff0000通知被主动终止！|r")
    end
end

HDLUI.HASDEATHPLAYER = false

function HDLUI.CheckDeathPlayer()

    --/run local  name, _, _, _,_, _, _, online ,IsDead = GetRaidRosterInfo(8);print(name, online, IsDead)
    --如果团队中存在死亡玩家则返回，并且HDLUI.HASDEATHPLAYER = true
    for playerIndex = 1, 40 do
        local  name, _, _, _,_, _, _, online ,IsDead = GetRaidRosterInfo(playerIndex)
        if name and online and IsDead then
            HDLUI.HASDEATHPLAYER = true
            return false
        end
    end
    if HDLUI.HASDEATHPLAYER then
        HDLUI.HASDEATHPLAYER = false
        return true
    end
end


--创建一个用于计时的框架
HDLUI.CreateTimerFrame = CreateFrame("Frame")
HDLUI.CreateTimerFrame:SetScript("OnUpdate", function(self, elapsed)
    if HDLUI.REPORT == 1 and GetTime() - HDLUI.GETTIME > 0.3 then
        for player, report in pairs(HDLUI.BuffPlayerList) do
            if report ~= "" then
                SendChatMessage(report, "WHISPER", nil, player)
                HDLUI.BuffPlayerList[player] = ""
                HDLUI.GETTIME = GetTime()
                return
            end
        end
        HDLUI.REPORT = 0
        print("|cffff0000------------------|r")
        print("|cffff0000通知完成！|r")
    end
    if GetTime() - HDLUI.UpDateTime > 5 then
        HDLUI.UpDateTime = GetTime()
        if HDLUI.CHATREGISTED then 
            if HDLUI.CheckDeathPlayer() then
                HDLUI.BuffCheckAndReport()
            end
        end
    end
end)

-- 事件处理函数
HDLUI.CreateTimerFrame:SetScript("OnEvent", function()
    -- 检查是否为密语事件
    if event == "CHAT_MSG_WHISPER" then
        -- 判断消息是否为 "buff"
        if (arg1 == "buff" or arg1 == "BUFF") and HDLUI.IsRaidLeader() and HDLUI.REPORT == 0 and GetTime() - HDLUI.REPORTTIME > 60 then
            HDLUI.REPORTTIME = GetTime()
            HDLUI.BuffCheckAndReport()
        end
    end
end)

function HDLUI.OpenBlessingFrame()
    --获取团队中，圣骑士的人数
    local num,_ = HDLUI.GetClassN("圣骑士")
    if HDLUI.BuffWindow.BlessingFrame:IsVisible() then
        HDLUI.BuffWindow.BlessingFrame:Hide()
    else
        if num >0 then
            HDLUI.BuffWindow.BlessingFrame:Show()
        else
            print("|cffff0000团队中没有圣骑士！|r")
        end
    end
end

function HDLUI.AutoResponse()
    if HDLUI.CHATREGISTED then 
        HDLUI.CreateTimerFrame:UnregisterEvent("CHAT_MSG_WHISPER")
        print("密语监控：【|cffff0000关闭|r】")
        AutoResponseButton:SetTextColor(0.7, 0.7, 0.7)
        HDLUI.CHATREGISTED = false 
    else  
        HDLUI.CreateTimerFrame:RegisterEvent("CHAT_MSG_WHISPER")
        AutoResponseButton:SetTextColor(1, 1, 1)
        print("密语监控：【|cff00ff00开启|r】")
        SendChatMessage("密语监控已开启，私聊我【|cffff0000buff|r】会自动通知相应人员为你加BUFF,此功能|cffff0000每60秒|r仅可被触发1次", "raid")
        HDLUI.CHATREGISTED = true
    end 
end

--/run SendAddonMessage("PLPWR", "ASSIGN 巫鸡 2 0", "RAID")
function HDLUI.SendToPallyPower()
    local num = HDLUIBuffList["Blessing"]["Nums"]
    local names = HDLUIBuffList["Blessing"]["Names"]
    local SendList = HDLUIBuffList["Blessing"]["paladinBlessing"]
    
    for paladingIndex = 1, num do
        for classIndex = 1, 9 do
            local SendString = "ASSIGN "..names[paladingIndex]
            SendList[paladingIndex][classIndex] = SendList[paladingIndex][classIndex] or {}
            local class = classIndex - 1
            SendString = SendString.." "..tostring(class)
            local blessingIcon = SendList[paladingIndex][classIndex]-1
            if blessingIcon == -1 then
                blessingIcon = 6
            end
            SendString = SendString.." "..tostring(blessingIcon)
            SendAddonMessage("PLPWR", SendString, "RAID")
        end
    end
end

