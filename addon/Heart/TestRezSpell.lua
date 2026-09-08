-- 复活技能选择测试脚本
-- 用途：验证插件是否根据玩家职业正确选择了复活技能

-- 注册命令：/rezdebug
SLASH_REZDEBUG1 = "/rezdebug";
function SlashCmdList.REZDEBUG(msg)
    -- 获取当前玩家职业
    local playerClass = UnitClass("player")
    
    -- 添加职业名称映射，将本地化职业名称转换为英文缩写
    local classMap = {
        ['萨满祭司'] = 'SHAMAN',
        ['牧师'] = 'PRIEST',
        ['圣骑士'] = 'PALADIN',
        ['德鲁伊'] = 'DRUID',
        ['战士'] = 'WARRIOR',
        ['法师'] = 'MAGE',
        ['术士'] = 'WARLOCK',
        ['猎人'] = 'HUNTER',
        ['盗贼'] = 'ROGUE'
    }
    
    -- 使用映射后的职业缩写
    local classKey = classMap[playerClass] or playerClass
    
    -- 处理命令参数
    if msg and string.lower(msg) == "reset" then
        ResetRezSpell()
        return
    end
    
    -- 显示当前配置的复活技能
    local currentRezSpell = Heart_Config["rez_spell"] or "未设置"
    local currentRezRank = Heart_Config["rez_rank"] or 1
    
    -- 显示根据职业应该选择的复活技能
    local expectedRezSpell = HEART_REZ_SPELL[classKey] or "无对应技能"
    local expectedRezRank = expectedRezSpell and Heart_Spells[expectedRezSpell] and table.getn(Heart_Spells[expectedRezSpell]) or 1
    
    -- 显示所有可用的复活技能
    local availableRezSpells = ""
    for spell, _ in Heart_rez_spells do
        if availableRezSpells ~= "" then
            availableRezSpells = availableRezSpells .. ", "
        end
        availableRezSpells = availableRezSpells .. spell
    end
    
    -- 显示测试结果
    DEFAULT_CHAT_FRAME:AddMessage("|cffffff00===== Heart 复活技能测试 =====|r")
    DEFAULT_CHAT_FRAME:AddMessage("玩家职业: |cff00ff00" .. playerClass .. "|r")
    DEFAULT_CHAT_FRAME:AddMessage("配置的复活技能: |cff00ff00" .. currentRezSpell .. " (等级 " .. currentRezRank .. ")|r")
    DEFAULT_CHAT_FRAME:AddMessage("预期的复活技能: |cff00ff00" .. expectedRezSpell .. " (等级 " .. expectedRezRank .. ")|r")
    DEFAULT_CHAT_FRAME:AddMessage("所有可用的复活技能: |cff00ff00" .. availableRezSpells .. "|r")
    
    -- 检查是否匹配
    if currentRezSpell == expectedRezSpell and currentRezRank == expectedRezRank then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00测试通过：复活技能选择正确！|r")
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000测试失败：复活技能选择错误！|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cffffff00输入 /rezdebug reset 可立即重置为正确的职业复活技能。|r")
    end
    DEFAULT_CHAT_FRAME:AddMessage("|cffffff00=========================|r")
end

-- 重置复活技能为职业对应的技能
function ResetRezSpell()
    -- 获取当前玩家职业
    local playerClass = UnitClass("player")
    
    -- 添加职业名称映射，将本地化职业名称转换为英文缩写
    local classMap = {
        ['萨满祭司'] = 'SHAMAN',
        ['牧师'] = 'PRIEST',
        ['圣骑士'] = 'PALADIN',
        ['德鲁伊'] = 'DRUID',
        ['战士'] = 'WARRIOR',
        ['法师'] = 'MAGE',
        ['术士'] = 'WARLOCK',
        ['猎人'] = 'HUNTER',
        ['盗贼'] = 'ROGUE'
    }
    
    -- 使用映射后的职业缩写
    local classKey = classMap[playerClass] or playerClass
    
    -- 获取职业对应的复活技能
    local class_rez_spell = HEART_REZ_SPELL[classKey]
    
    if class_rez_spell and Heart_Spells[class_rez_spell] and Heart_rez_spells[class_rez_spell] then
        -- 重置为职业对应的技能和最高等级
        Heart_Config["rez_spell"] = class_rez_spell
        Heart_Config["rez_rank"] = table.getn(Heart_Spells[class_rez_spell])
        
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[Heart] 成功重置复活技能为：" .. class_rez_spell .. " (等级 " .. Heart_Config["rez_rank"] .. ")|r")
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[Heart] 无法找到适合当前职业的复活技能！|r")
    end
end

-- 自动执行一次测试
local function AutoTestRezSpell()
    if Heart_Config and HEART_REZ_SPELL and Heart_rez_spells then
        local playerClass = UnitClass("player")
        
        -- 添加职业名称映射，将本地化职业名称转换为英文缩写
        local classMap = {
            ['萨满祭司'] = 'SHAMAN',
            ['牧师'] = 'PRIEST',
            ['圣骑士'] = 'PALADIN',
            ['德鲁伊'] = 'DRUID',
            ['战士'] = 'WARRIOR',
            ['法师'] = 'MAGE',
            ['术士'] = 'WARLOCK',
            ['猎人'] = 'HUNTER',
            ['盗贼'] = 'ROGUE'
        }
        
        -- 使用映射后的职业缩写
        local classKey = classMap[playerClass] or playerClass
        
        local currentRezSpell = Heart_Config["rez_spell"]
        local expectedRezSpell = HEART_REZ_SPELL[classKey]
        
        if currentRezSpell and expectedRezSpell and currentRezSpell ~= expectedRezSpell then
            DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[Heart] 注意：当前配置的复活技能可能不正确。请输入 /rezdebug 查看详细信息，或输入 /rezdebug reset 重置。|r")
        end
    end
end

-- 在插件加载完成后延迟执行自动测试
local testFrame = CreateFrame("Frame")
testFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
testFrame:SetScript("OnEvent", function()
    this:UnregisterEvent("PLAYER_ENTERING_WORLD")
    -- 延迟1秒执行，确保所有数据都已加载
    this.timer = 1
    this:SetScript("OnUpdate", function()
        this.timer = this.timer - arg1
        if this.timer <= 0 then
            AutoTestRezSpell()
            this:SetScript("OnUpdate", nil)
        end
    end)
end)

-- 添加重载界面时自动修复的逻辑
local reloadFrame = CreateFrame("Frame")
reloadFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
reloadFrame:SetScript("OnEvent", function()
    if event == "PLAYER_ENTERING_WORLD" then
        -- 每次进入游戏时自动检查并修复复活技能
        local playerClass = UnitClass("player")
        
        -- 添加职业名称映射，将本地化职业名称转换为英文缩写
        local classMap = {
            ['萨满祭司'] = 'SHAMAN',
            ['牧师'] = 'PRIEST',
            ['圣骑士'] = 'PALADIN',
            ['德鲁伊'] = 'DRUID',
            ['战士'] = 'WARRIOR',
            ['法师'] = 'MAGE',
            ['术士'] = 'WARLOCK',
            ['猎人'] = 'HUNTER',
            ['盗贼'] = 'ROGUE'
        }
        
        -- 使用映射后的职业缩写
        local classKey = classMap[playerClass] or playerClass
        
        local class_rez_spell = HEART_REZ_SPELL[classKey]
        
        if class_rez_spell and Heart_Spells[class_rez_spell] and Heart_rez_spells[class_rez_spell] then
            if Heart_Config["rez_spell"] ~= class_rez_spell then
                Heart_Config["rez_spell"] = class_rez_spell
                Heart_Config["rez_rank"] = table.getn(Heart_Spells[class_rez_spell])
            end
        end
    end
end)