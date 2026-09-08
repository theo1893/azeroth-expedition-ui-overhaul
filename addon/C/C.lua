-- C.lua - 治疗法术监控插件
local CastingSpeed = {}
CastingSpeed.version = "1.0"

-- 存储施法信息的表
CastingSpeed.castData = {}

-- 初始化函数
function CastingSpeed:Init()
    -- 检查是否安装了SUPERWOW
    if not SUPERWOW_STRING then
        return
    end
    -- 注册事件
    self:RegisterEvents()
end

-- 注册事件
function CastingSpeed:RegisterEvents()
    -- 监听UNIT_CASTEVENT事件
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("UNIT_CASTEVENT")
    frame:SetScript("OnEvent", function(self, event)
        if arg3 == "START" then
            CastingSpeed:OnUnitCastEvent(arg1, arg2, arg3, arg4, arg5)
        end
    end)
end

-- 处理UNIT_CASTEVENT事件
function CastingSpeed:OnUnitCastEvent(casterGUID, targetGUID, castType, spellID, castTime)
    -- 只处理施法开始事件
    if castType ~= "START" then
        return
    end

    -- 只处理治疗法术(施法时间>0)
    if castTime > 0 then
        -- 获取目标单位
        local targetUnit
        -- 构建单位列表：目标、玩家自己、小队成员、团队成员和队友宠物
        local units = {"target", "player"}
        
        -- 添加小队成员 (party1-party4) 及其宠物 (partypet1-partypet4)
        for i = 1, 4 do
            table.insert(units, "party"..i)
            table.insert(units, "partypet"..i)
        end
        
        -- 添加团队成员 (raid1-raid40) 及其宠物 (raidpet1-raidpet40)
        for i = 1, 40 do
            table.insert(units, "raid"..i)
            table.insert(units, "raidpet"..i)
        end
        
        -- 遍历所有单位查找匹配的GUID
        for _, unit in ipairs(units) do
            if UnitExists(unit) then
                local _,unitGUID = UnitExists(unit)
                if unitGUID == targetGUID then
                    targetUnit = unit
                    break
                end
            end
        end
        
        -- 检查目标是否为友方
        if not targetUnit or not UnitIsFriend("player", targetUnit) then
            return
        end
        local currentTime = GetTime()
        local endTime = currentTime + castTime / 1000

        -- 获取目标名称
        local targetName = CastingSpeed:GetUnitNameByGUID(targetGUID) or "未知"
        
        -- 存储施法信息
        if not CastingSpeed.castData[targetGUID] then
            CastingSpeed.castData[targetGUID] = {}
        end

        CastingSpeed.castData[targetGUID][casterGUID] = {
            spellID = spellID,
            castTime = castTime,
            startTime = currentTime,
            endTime = endTime
        }
        
        -- 添加调试信息
        local casterName = CastingSpeed:GetUnitNameByGUID(casterGUID) or "未知"
        -- print("[治疗监控存储] 存储施法信息: 施法者" .. casterName .. ", 目标" .. targetName .. ", 施法时间" .. castTime/1000 .. "秒")
    end
end

-- 获取目标的治疗施法者数量
function CastingSpeed:GetHealerCount(targetGUID)
    if not CastingSpeed.castData[targetGUID] then
        return 0
    end

    local count = 0
    local _,playerGUID = UnitExists("player") -- 获取当前玩家的GUID

    for casterGUID, _ in pairs(CastingSpeed.castData[targetGUID]) do
        -- 排除自己
        if casterGUID ~= playerGUID then
            count = count + 1
        end
    end

    return count
end

-- 获取最快完成的治疗法术时间(秒)
function CastingSpeed:GetFastestCastTime(targetGUID)
    if not CastingSpeed.castData[targetGUID] then
        return nil
    end

    local fastestTime = nil
    local currentTime = GetTime()

    for _, castInfo in pairs(CastingSpeed.castData[targetGUID]) do
        local timeLeft = castInfo.endTime - currentTime
        if timeLeft > 0 and (fastestTime == nil or timeLeft < fastestTime) then
            fastestTime = timeLeft
        end
    end

    return fastestTime
end

-- 检查是否有人比当前玩家先读完法术
function CastingSpeed:HasFasterCaster(targetGUID, casterGUID)
    if not CastingSpeed.castData[targetGUID] then
        return false
    end

    local playerEndTime = nil
    local currentTime = GetTime()

    -- 先找到当前施法者的施法结束时间
    for guid, castInfo in pairs(CastingSpeed.castData[targetGUID] or {}) do
        if guid == casterGUID then
            playerEndTime = castInfo.endTime
            break
        end
    end

    -- 如果玩家没有在施法，返回false
    if not playerEndTime then
        return false
    end

    -- 检查是否有其他施法者比当前施法者更快
    for guid, castInfo in pairs(CastingSpeed.castData[targetGUID] or {}) do
        if guid ~= casterGUID and castInfo.endTime < playerEndTime and castInfo.endTime > currentTime then
            return true
        end
    end

    return false
end

-- 清理过期的施法数据
function CastingSpeed:CleanExpiredCastData()
    local currentTime = GetTime()
    for targetGUID, casters in pairs(CastingSpeed.castData or {}) do
        for casterGUID, castInfo in pairs(casters) do
            -- 检查法术是否已经释放完毕
            if castInfo.endTime <= currentTime then
                -- 删除过期记录
                casters[casterGUID] = nil
                --print("[治疗监控清理] 移除过期施法记录: 目标" .. (CastingSpeed:GetUnitNameByGUID(targetGUID) or "未知") .. ", 施法者" .. (CastingSpeed:GetUnitNameByGUID(casterGUID) or "未知"))
            end
        end
        -- 如果目标没有施法者了，删除该目标
        if next(casters) == nil then
            CastingSpeed.castData[targetGUID] = nil
        end
    end
end



-- 初始化插件
CastingSpeed:Init()

-- 简化的GUID处理，通过GUID获取单位名称
function CastingSpeed:GetUnitNameByGUID(guid)
    -- 遍历单位列表查找匹配的GUID
    local units = {"target", "player"}
    
    -- 添加小队成员
    for i = 1, 4 do
        table.insert(units, "party"..i)
    end
    
    -- 添加团队成员
    for i = 1, 40 do
        table.insert(units, "raid"..i)
    end
    
    for _, unit in ipairs(units) do
        if UnitExists(unit) then
            local _, unitGUID = UnitExists(unit)
            if unitGUID == guid then
                return UnitName(unit)
            end
        end
    end
    return "未知"
end

-- 从Heart插件获取配置
function CastingSpeed:GetHeartConfig()
    if Heart_Config then
        return Heart_Config
    else
        -- 默认配置
        return {
            healer_count_limit = 3,
            block_faster_healers = false
        }
    end
end

-- 判断是否应该治疗目标
function CastingSpeed:ShouldHealTarget(targetGUID, casterGUID, spellID)
    local config = CastingSpeed:GetHeartConfig()
    local healerCount = CastingSpeed:GetHealerCount(targetGUID)
    
    -- 添加调试信息
    local targetName = CastingSpeed:GetUnitNameByGUID(targetGUID)
    local casterName = CastingSpeed:GetUnitNameByGUID(casterGUID) or "未知"
    -- print("[治疗监控调试] 目标: " .. targetName .. ", 施法者: " .. casterName .. ", 竞争者数量: " .. healerCount)
    
    -- 检查是否允许别人比我更快
    if config.block_faster_healers == 1 then
    
        -- 获取自己的施法信息
        local myCastTime = 0
        local casterName = CastingSpeed:GetUnitNameByGUID(casterGUID) or "未知"
        
        -- 如果提供了法术ID，直接使用C_GetSpellData获取施法时间
        if spellID then
            local mana, range, casttime, text = C_GetSpellData(spellID, BOOKTYPE_SPELL)
            myCastTime = casttime
            -- print("[治疗监控调试] 你的法术施法时间: " .. math.floor(myCastTime * 10) / 10 .. "秒")
        else
            -- 否则使用现有逻辑获取施法时间
            if not CastingSpeed.castData[targetGUID] then
                -- print("[治疗监控调试] 没有找到目标的施法数据")
            elseif not CastingSpeed.castData[targetGUID][casterGUID] then
                -- print("[治疗监控调试] 没有找到施法者" .. casterName .. "的施法数据")
            end
            
            if CastingSpeed.castData[targetGUID] and CastingSpeed.castData[targetGUID][casterGUID] then
                local myCastInfo = CastingSpeed.castData[targetGUID][casterGUID]
                local currentTime = GetTime()
                myCastTime = myCastInfo.endTime - currentTime
                -- print("[治疗监控调试] 你的剩余施法时间: " .. math.floor(myCastTime * 10) / 10 .. "秒")
            end
        end
        
        -- 获取最快竞争者的信息
        local fastestTime = CastingSpeed:GetFastestCastTime(targetGUID)
        if fastestTime then
            -- print("[治疗监控调试] 最快竞争者剩余时间: " .. math.floor(fastestTime * 10) / 10 .. "秒")
            
            -- 对比施法时间
            if spellID and fastestTime < myCastTime then
                -- print("[治疗监控调试] 你的施法速度比最快竞争者慢，中断治疗")
                return false
            end
        else
            -- print("[治疗监控调试] 没有其他竞争者")
        end

        local hasFaster = CastingSpeed:HasFasterCaster(targetGUID, casterGUID)
        if not hasFaster then
            -- 没有更快的施法者，直接治疗
            -- print("[治疗监控调试] 没有更快的施法者，直接治疗")
            return true
        else
            -- 有更快的施法者，检查人数限制
            -- print("[治疗监控调试] 有更快的施法者，检查人数限制")
     if type(healerCount) == "number" and config and type(config.healer_count_limit) == "number" then
            if healerCount >= config.healer_count_limit then
                -- 人数也超过限制，中断治疗
                -- print("[治疗监控调试] 竞争者数量达到限制，中断治疗")
                return false
            else
                -- 人数未超过限制，但有更快施法者，仍中断治疗
                -- print("[治疗监控调试] 有更快的施法者，中断治疗")
                return false
            end
        end
        end
    else
        -- 不启用比我更快检查，仅检查人数限制
     if type(healerCount) == "number" and config and type(config.healer_count_limit) == "number" then
        if healerCount >= config.healer_count_limit then
            -- print("[治疗监控调试] 竞争者数量达到限制，中断治疗")
            return false
        else
            -- print("[治疗监控调试] 竞争者数量未达限制，继续治疗")
            return true
        end
    end
    end
end




_G.CastingSpeed = CastingSpeed