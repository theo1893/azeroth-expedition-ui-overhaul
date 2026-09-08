--********************************************************
-- DamageEx 伤害/治疗数字显示器
-- 基于 Nampower API 重构
--********************************************************

local dex_lastani = 1;
local dex_bottom = 0;
local dex_petbottom = 0;
local dex_top = -99999;
local DEX_MAXANI = 50;                -- 动画槽数量
local DEX_TEXTSIZE = 22;
local DEX_Registered = 0;
local DEX_aoeStartTimer = 0;
local DEX_aoeNew = 1;
local DEX_aoeId = 1;
local DEX_aoeDct = 0;
local DEX_logLine = 10;
local DEX_logTime = 10;
local DEX_OverHeal = 0;                -- 治疗过量数值

-- 目标连线功能
local TargetLine = {}
TargetLine.pool = {}          -- 存储红点 Frame
TargetLine.MAX_DOTS = 50      -- 红点数量（最大码距）
TargetLine.lastTargetGUID = nil
TargetLine.SHOW_DISTANCE = 0.1

-- 初始化红点池（点的样式会根据配置动态更新）
local function TargetLine_InitPool()
    for i = 1, TargetLine.MAX_DOTS do
        local dot = CreateFrame("Frame", nil, UIParent)
        dot:SetWidth(2)
        dot:SetHeight(2)
        dot:SetBackdrop({ bgFile = "Interface\\ChatFrame\\ChatFrameBackground" })
        dot:SetBackdropColor(1, 0, 0, 1)
        dot:Hide()
        tinsert(TargetLine.pool, dot)
    end
end

-- 更新所有红点的样式（大小、颜色）
local function TargetLine_UpdateStyle()
    local size = DEX_Get("DEX_TargetLineSize") or 2
    size = math.max(1, math.min(8, size))  -- 限制 1~8 像素
    local r = DEX_Get("DEX_TargetLineColor")[1] or 1.0
    local g = DEX_Get("DEX_TargetLineColor")[2] or 0.0
    local b = DEX_Get("DEX_TargetLineColor")[3] or 0.0

    for _, dot in ipairs(TargetLine.pool) do
        dot:SetWidth(size)
        dot:SetHeight(size)
        dot:SetBackdropColor(r, g, b, 1)
    end
end

-- 隐藏所有红点
local function TargetLine_HideAll()
    for _, dot in ipairs(TargetLine.pool) do
        dot:Hide()
    end
end

-- 获取屏幕中心点
local function TargetLine_GetScreenCenter()
    return GetScreenWidth() * 0.5, GetScreenHeight() * 0.5
end

-- 目标切换时清空缓存
local function TargetLine_OnTargetChanged()
    TargetLine.lastTargetGUID = nil
end

-- 小地图图标相关变量
local DEX_MinimapAngle = 220;
local DEX_MinimapDragging = false;

-- 伤害类型常量
DEX_DAMAGE_TYPE_HIT = 0;
DEX_DAMAGE_TYPE_SPELL = 1;
DEX_DAMAGE_TYPE_PERIODIC = 2;
DEX_DAMAGE_TYPE_HEALTH = 3;
DEX_DAMAGE_TYPE_PET = 4;
DEX_DAMAGE_TYPE_HONOR = 5;              -- 荣誉/特殊事件（打断、驱散等）
DEX_DAMAGE_TYPE_MANA = 6;                -- 法力伤害/吸取
DEX_DAMAGE_TYPE_INCOMING = 7;            -- 受到的伤害
DEX_DAMAGE_TYPE_ENERGIZE = 8;            -- 能量恢复（法力、怒气、能量、集中值等）
DEX_FONTNAME = "Interface\\AddOns\\DamageEx\\Fonts\\Z1.ttf";
DEX_SHADOW = 2;

-- 字体效果配置（描边与阴影）
DEX_FONTEFF = {
    {ol = "",shadowOff = 1},
    {ol = "OUTLINE",shadowOff = 0},
    {ol = "OUTLINE",shadowOff = 2},
    {ol = "THICKOUTLINE",shadowOff = 0},
    {ol = "THICKOUTLINE",shadowOff = 2},
}

-- 可用字体列表
DEX_FontList = {
    "Interface\\AddOns\\DamageEx\\Fonts\\Z1.ttf",
    "Interface\\AddOns\\DamageEx\\Fonts\\Z2.ttf",
    "Interface\\AddOns\\DamageEx\\Fonts\\Z3.ttf",
}

-- 十六进制颜色字符列表
DEX_HEX_LIST = {"0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f","f"}

-- 动画移动类型
DEX_MOVTYP_NORMAL = 0;
DEX_MOVTYP_AOE = 1;
DEX_MOVTYP_PET = 2;
DEX_MOVTYP_OTHER = 3;
DEX_MOVTYP_NONE = 99;

-- 动画轨迹类型常量
DEX_TRAJECTORY_VERTICAL = 1;      -- 垂直向上
DEX_TRAJECTORY_RAINBOW = 2;       -- 彩虹弧线
DEX_TRAJECTORY_HORIZONTAL = 3;    -- 水平移动
DEX_TRAJECTORY_ANGLED_DOWN = 4;   -- 斜向下抛物线
DEX_TRAJECTORY_ANGLED_UP = 5;     -- 斜向上抛物线
DEX_TRAJECTORY_SPRINKLER = 6;     -- 洒水器效果
DEX_TRAJECTORY_VERTICAL_DOWN = 7; -- 垂直向下

-- 轨迹动画全局变量（用于交替方向等）
DEX_TRAJECTORY_DIRECTION = 1;
DEX_SPRINKLER_START = 18;
DEX_SPRINKLER_STEP = -3;
DEX_SPRINKLER_RADIUS = 20;
DEX_SPRINKLER = DEX_SPRINKLER_START;

local DEX_critFlag = 0;
local DEX_logFlag = 1;

local DEX_ANI_UID = -9999999

-- 动画数据结构
local dex_AniData = {
    ["aniText1"] = {},
    ["aniText2"] = {},
    ["aniText3"] = {},
    ["aniText4"] = {},
    ["aniText5"] = {},
    ["aniText6"] = {},
    ["aniText7"] = {},
    ["aniText8"] = {},
    ["aniText9"] = {},
    ["aniText10"] = {},
    ["aniText11"] = {},
    ["aniText12"] = {},
    ["aniText13"] = {},
    ["aniText14"] = {},
    ["aniText15"] = {},
    ["aniText16"] = {},
    ["aniText17"] = {},
    ["aniText18"] = {},
    ["aniText19"] = {},
    ["aniText20"] = {},
    ["aniText21"] = {},
    ["aniText22"] = {},
    ["aniText23"] = {},
    ["aniText24"] = {},
    ["aniText25"] = {},
    ["aniText26"] = {},
    ["aniText27"] = {},
    ["aniText28"] = {},
    ["aniText29"] = {},
    ["aniText30"] = {},
    ["aniText31"] = {},
    ["aniText32"] = {},
    ["aniText33"] = {},
    ["aniText34"] = {},
    ["aniText35"] = {},
    ["aniText36"] = {},
    ["aniText37"] = {},
    ["aniText38"] = {},
    ["aniText39"] = {},
    ["aniText40"] = {},
    ["aniText41"] = {},
    ["aniText42"] = {},
    ["aniText43"] = {},
    ["aniText44"] = {},
    ["aniText45"] = {},
    ["aniText46"] = {},
    ["aniText47"] = {},
    ["aniText48"] = {},
    ["aniText49"] = {},
    ["aniText50"] = {},
}

-- AOE 技能列表（1.12 使用技能名称）
DEX_AOE_LIST = {}
local aoeList = {}

-- 注册 AOE 技能（按职业）
function DEX_RegisterAOE(class, ...)
    local list = DEX_AOE_LIST[class]
    if not list then
        list = {}
        DEX_AOE_LIST[class] = list
    end
    local i = 1
    while arg[i] do
        if type(arg[i]) == "string" then
            list[arg[i]] = 1
        end
        i = i + 1
    end
end

-- 各职业 AOE 技能注册
DEX_RegisterAOE("WARRIOR", unpack(DEX_LANG_AOE_SKILLS.WARRIOR))
DEX_RegisterAOE("ROGUE", unpack(DEX_LANG_AOE_SKILLS.ROGUE))
DEX_RegisterAOE("PALADIN", unpack(DEX_LANG_AOE_SKILLS.PALADIN))
DEX_RegisterAOE("HUNTER", unpack(DEX_LANG_AOE_SKILLS.HUNTER))
DEX_RegisterAOE("WARLOCK", unpack(DEX_LANG_AOE_SKILLS.WARLOCK))
DEX_RegisterAOE("MAGE", unpack(DEX_LANG_AOE_SKILLS.MAGE))
DEX_RegisterAOE("PRIEST", unpack(DEX_LANG_AOE_SKILLS.PRIEST))
DEX_RegisterAOE("DRUID", unpack(DEX_LANG_AOE_SKILLS.DRUID))
DEX_RegisterAOE("SHAMAN", unpack(DEX_LANG_AOE_SKILLS.SHAMAN))

DEXPlayer = nil;

-- 默认配置
DEX_DEFAULT_CFG = {
    ["DEX_Enable"] = 1,
    ["DEX_ShowWithMess"] = 0,
    ["DEX_ShowSpellName"] = 1,
    ["DEX_ShowNameOnCrit"] = 0,
    ["DEX_ShowNameOnMiss"] = 0,
    ["DEX_ShowDamageNormal"] = 1,
    ["DEX_ShowDamageSkill"] = 1,
    ["DEX_ShowDamagePeriodic"] = 1,
    ["DEX_ShowDamageShield"] = 1,
    ["DEX_ShowDamageHealth"] = 1,
    ["DEX_ShowBlockNumber"] = 0,
    ["DEX_ShowDamagePet"] = 1,
    ["DEX_ShowDamageWoW"] = 0,
    ["DEX_ShowMaxDamage"] = 0,
    ["DEX_ShowEnergize"] = 1,
    ["DEX_Speed"] = 80,
    ["DEX_PosX"] = 0,
    ["DEX_PosY"] = 100,
    ["DEX_IncomingPosX"] = 0,
    ["DEX_IncomingPosY"] = -100,
    ["DEX_FontSize"] = 25,
    ["DEX_Font"] = 2,
    ["DEX_OutLine"] = 3,
    ["DEX_ScrollHeight"] = 10,
    ["DEX_AnimHeight"] = 400,
    ["DEX_AttachNameplate"] = 0,
    ["DEX_NameplateOffsetX"] = 0,
    ["DEX_NameplateOffsetY"] = 0,
    ["DEX_NameplateScale"] = 1,
    ["DEX_NameplatePoint"] = "CENTER",
    ["DEX_NameplateRelativePoint"] = "CENTER",
    -- 颜色配置
    ["DEX_ColorPet"] = {1,0.8,0.2},
    ["DEX_ColorPetSe"] = {1,0.2,0},
    ["DEX_ColorNormal"] = {1,1,1},
    ["DEX_ColorNormalSe"] = {0.5,0.7,1},
    ["DEX_ColorSkill"] = {1,1,0.2},
    ["DEX_ColorSkillSe"] = {1,0.1,0},
    ["DEX_ColorPeriodic"] = {1,0.4,1},
    ["DEX_ColorPeriodicSe"] = {0.6,0,1},
    ["DEX_ColorHealth"] = {0.2,1,0.2},
    ["DEX_ColorHealthSe"] = {0,0.6,0},
    ["DEX_ColorSpec"] = {1,1,0.3},
    ["DEX_ColorSpecSe"] = {1,0.5,0},
    ["DEX_ColorMana"] = {0.3,0.6,1},
    ["DEX_ColorManaSe"] = {0,0.2,0.8},
    ["DEX_ColorIncoming"] = {1,0.3,0.3},
    ["DEX_ColorIncomingSe"] = {0.8,0,0},
    ["DEX_ColorMode"] = 3,
    ["DEX_LOGLINE"] = 25,
    ["DEX_LOGTIME"] = 10,
    ["DEX_NumberFormat"] = 1,
    ["DEX_ShowSpellIcon"] = 1,
    ["DEX_ShowIncomingDamage"] = 1,
    ["DEX_ShowOverHeal"] = 0,
    ["DEX_MinimapAngle"] = 220,
    ["DEX_ShowMinimapButton"] = 1,
    ["DEX_TrajectoryOutgoing"] = 1,
    ["DEX_TrajectoryIncoming"] = 1,
    ["DEX_TrajectorySideDir"] = 1,
    ["DEX_TrajectoryEnergize"] = 7,
    ["DEX_HideFriendlyDamage"] = 0,
    ["DEX_EnableAOEStandalone"] = 1,   -- 1=开启AOE独立显示，0=关闭（与其他技能相同）
    ["DEX_EnableTargetLine"] = 0,   -- 目标连线，默认关闭（需要 UnitXP）
    ["DEX_TargetLineSize"] = 2,
    ["DEX_TargetLineColor"] = {1, 0, 0},
}

-- 姓名版集成相关变量
local DEX_TargetNameplate = nil
local DEX_NameplatesByName = {}
local DEX_NameplateGUIDMap = {}
local DEX_GUIDToNameplate = {}
local DEX_LastNameplateScan = 0
local DEX_LastTargetPlateCheck = 0
local DEX_LastNameplateScanAttempt = 0

-- 记录最近一次战斗事件的单位信息（用于姓名版附着）
local DEX_LastEventUnitName = nil
local DEX_LastEventGUID = nil
local DEX_LastEventTime = 0
local DEX_LAST_EVENT_TIMEOUT = 1.5

-- Forward declaration
DEX_GameUpdate = DEX_GameUpdate
local DEX_NAMEPLATE_RESCAN_INTERVAL = 0.1
local DEX_UseShaguPlates = nil

-- 从姓名版框架获取 GUID
local function DEX_GetNameplateGUID(nameplateFrame)
    if not nameplateFrame then return nil end

    -- pfUI 缓存了 GUID
    if nameplateFrame.cachedGuid and type(nameplateFrame.cachedGuid) == "string" and string.find(nameplateFrame.cachedGuid, "^0x") then
        return nameplateFrame.cachedGuid
    end

    -- 通过nameplateFrame:GetName(1) 返回 GUID
    if nameplateFrame.parent and nameplateFrame.parent.GetName then
        local success, guid = pcall(function() return nameplateFrame.parent:GetName(1) end)
        if success and guid and type(guid) == "string" and string.find(guid, "^0x") then
            return guid
        end
    end

    if nameplateFrame.GetName then
        local success, guid = pcall(function() return nameplateFrame:GetName(1) end)
        if success and guid and type(guid) == "string" and string.find(guid, "^0x") then
            return guid
        end
    end

    if nameplateFrame.guid and type(nameplateFrame.guid) == "string" and string.find(nameplateFrame.guid, "^0x") then
        return nameplateFrame.guid
    end

    if nameplateFrame.unit then
        local exists, guid = UnitExists(nameplateFrame.unit)
        if guid and type(guid) == "string" and string.find(guid, "^0x") then
            return guid
        end
    end

    return nil
end

-- 重置姓名版缓存
local function DEX_ResetNameplateCaches()
    wipe(DEX_NameplatesByName)
    wipe(DEX_NameplateGUIDMap)
    wipe(DEX_GUIDToNameplate)
    DEX_NameplatesByName = {}
    DEX_NameplateGUIDMap = {}
    DEX_GUIDToNameplate = {}
end

-- 检测是否使用 ShaguPlates/pfUI
local function DEX_DetectNameplateAddon()
    if DEX_UseShaguPlates ~= nil then
        return DEX_UseShaguPlates
    end
    if pfNameplates or getglobal("pfNamePlate1") then
        DEX_UseShaguPlates = true
    else
        DEX_UseShaguPlates = false
    end
    return DEX_UseShaguPlates
end

-- 检查是否需要扫描姓名版（频率限制）
local function DEX_ShouldScanNameplates()
    if DEX_LastNameplateScanAttempt == 0 then
        return true
    end
    return (GetTime() - DEX_LastNameplateScanAttempt) >= DEX_NAMEPLATE_RESCAN_INTERVAL
end

-- 扫描当前可见的姓名版
local function DEX_ScanNameplates(force)
    if not force and not DEX_ShouldScanNameplates() then
        return 0
    end
    DEX_ResetNameplateCaches()
    local useShagu = DEX_DetectNameplateAddon()
    local total = 0
    DEX_LastNameplateScanAttempt = GetTime()

    if useShagu then
        for i = 1, 150 do
            local plate = getglobal("pfNamePlate" .. i)
            if plate and plate:IsVisible() and plate.name then
                local name = plate.name:GetText()
                if name and name ~= "" then
                    DEX_NameplatesByName[name] = DEX_NameplatesByName[name] or {}
                    table.insert(DEX_NameplatesByName[name], plate)
                    total = total + 1

                    local guid = DEX_GetNameplateGUID(plate)
                    if guid then
                        DEX_NameplateGUIDMap[guid] = plate
                        DEX_GUIDToNameplate[plate] = guid
                    end
                end
            end
        end
    else
        local numChildren = WorldFrame:GetNumChildren()
        local maxScan = math.min(numChildren, 100)
        for i = 1, maxScan do
            local frame = select(i, WorldFrame:GetChildren())
            if frame and frame:IsVisible() then
                local regions = { frame:GetRegions() }
                local hasBorder = false
                local nameText = nil
                for _, region in ipairs(regions) do
                    if region then
                        local objType = region:GetObjectType()
                        if objType == "Texture" and not hasBorder then
                            local texture = region:GetTexture()
                            if texture and string.find(texture, "Nameplate%-Border") then
                                hasBorder = true
                            end
                        elseif objType == "FontString" and not nameText then
                            local text = region:GetText()
                            if text and string.len(text) > 1 then
                                nameText = text
                            end
                        end
                        if hasBorder and nameText then break end
                    end
                end

                if hasBorder and nameText then
                    DEX_NameplatesByName[nameText] = DEX_NameplatesByName[nameText] or {}
                    table.insert(DEX_NameplatesByName[nameText], frame)
                    total = total + 1

                    local guid = DEX_GetNameplateGUID(frame)
                    if guid then
                        DEX_NameplateGUIDMap[guid] = frame
                        DEX_GUIDToNameplate[frame] = guid
                    end
                end
            end
        end
    end

    return total
end

-- 通过单位名称获取姓名版（处理重名，仅当确定目标时返回）
local function DEX_GetNameplateByName(unitName)
    if not unitName then return nil end
    local plates = DEX_NameplatesByName[unitName]
    if not plates or table.getn(plates) == 0 then
        return nil
    end

    if table.getn(plates) == 1 then
        if plates[1]:IsVisible() then
            return plates[1]
        end
        return nil
    end

    if UnitExists("target") and UnitName("target") == unitName and DEX_TargetNameplate and DEX_TargetNameplate:IsVisible() then
        for _, plate in ipairs(plates) do
            if plate == DEX_TargetNameplate then
                return plate
            end
        end
    end

    return nil
end

-- 更新当前目标姓名版
local function DEX_UpdateTargetNameplate()
    if not UnitExists("target") then
        DEX_TargetNameplate = nil
        return
    end
    local targetName = UnitName("target")
    if not targetName then
        DEX_TargetNameplate = nil
        return
    end
    local plates = DEX_NameplatesByName[targetName]
    if not plates or table.getn(plates) == 0 then
        DEX_TargetNameplate = nil
        return
    end

    if table.getn(plates) == 1 then
        DEX_TargetNameplate = plates[1]
    else
        DEX_TargetNameplate = nil
        for _, plate in ipairs(plates) do
            if plate:IsVisible() then
                local alphaFrame = plate
                if plate.parent and plate.parent.GetAlpha then
                    alphaFrame = plate.parent
                end
                if alphaFrame:GetAlpha() >= 0.99 then
                    DEX_TargetNameplate = plate
                    break
                end
            end
        end
    end

    if DEX_TargetNameplate then
        local guid = GetUnitGUID("target")
        if guid then
            DEX_NameplateGUIDMap[guid] = DEX_TargetNameplate
            DEX_GUIDToNameplate[DEX_TargetNameplate] = guid
        end
    end
end

-- 通过 GUID 获取姓名版
local function DEX_GetNameplateByGUID(guid)
    if not guid then return nil end
    local plate = DEX_NameplateGUIDMap[guid]
    if plate and plate:IsVisible() then
        return plate
    end

    for name, plates in pairs(DEX_NameplatesByName) do
        if plates then
            for _, frame in ipairs(plates) do
                if frame and frame:IsVisible() then
                    local plateGUID = DEX_GetNameplateGUID(frame)
                    if plateGUID == guid then
                        DEX_NameplateGUIDMap[guid] = frame
                        DEX_GUIDToNameplate[frame] = guid
                        return frame
                    end
                end
            end
        end
    end

    return nil
end

-- 获取要附着的姓名版（核心函数）
local function DEX_GetAttachNameplate(guid, unitName)
    if guid then
        local plate = DEX_GetNameplateByGUID(guid)
        if plate and plate:IsVisible() then
            return plate
        end
    end

    if unitName then
        local plate = DEX_GetNameplateByName(unitName)
        if plate then
            return plate
        end
    end

    if DEX_TargetNameplate and DEX_TargetNameplate:IsVisible() then
        local targetName = UnitName("target")
        local targetGUID = GetUnitGUID("target")
        local matchesGUID = guid and targetGUID and targetGUID == guid
        local matchesName = unitName and targetName and targetName == unitName
        if matchesGUID or matchesName then
            return DEX_TargetNameplate
        end
    end

    DEX_ScanNameplates(true)
    DEX_UpdateTargetNameplate()

    if guid then
        local plate = DEX_GetNameplateByGUID(guid)
        if plate and plate:IsVisible() then
            return plate
        end
    end
    if unitName then
        local plate = DEX_GetNameplateByName(unitName)
        if plate then
            return plate
        end
    end

    if DEX_TargetNameplate and DEX_TargetNameplate:IsVisible() then
        local targetName = UnitName("target")
        local targetGUID = GetUnitGUID("target")
        local matchesGUID = guid and targetGUID and targetGUID == guid
        local matchesName = unitName and targetName and targetName == unitName
        if matchesGUID or matchesName then
            return DEX_TargetNameplate
        end
    end

    return nil
end

-- 记录事件单位信息
local function DEX_RecordEventUnit(guid)
    if not guid or not UnitExists(guid) then return end

    DEX_LastEventUnitName = UnitName(guid)
    DEX_LastEventGUID = guid
    DEX_LastEventTime = GetTime()
end

-- 获取最近事件单位（用于补充缺失信息）
local function DEX_GetRecentEventUnit()
    if DEX_LastEventTime == 0 then return nil, nil end
    if GetTime() - DEX_LastEventTime > DEX_LAST_EVENT_TIMEOUT then
        return nil, nil
    end
    return DEX_LastEventUnitName, DEX_LastEventGUID
end

-- 调试输出
function DEX_Debug(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff10ff00"..msg.."|r");
end

-- 绘制连线
local function TargetLine_Draw()
    if DEX_Get("DEX_EnableTargetLine") ~= 1 then
        TargetLine_HideAll()
        return
    end
    TargetLine_UpdateStyle()   -- 确保样式与配置同步

    -- 获取当前目标的 GUID
    local guid = TargetLine.lastTargetGUID
    if not guid or not UnitExists("target") then
        local exists, newGuid = UnitExists("target")
        if not exists then
            TargetLine_HideAll()
            return
        end
        guid = newGuid
        TargetLine.lastTargetGUID = guid
    end

    -- 通过 GUID 获取姓名板
    local plate = DEX_GetNameplateByGUID(guid)
    if not plate or not plate:IsVisible() then
        DEX_ScanNameplates(true)
        plate = DEX_GetNameplateByGUID(guid)
        if not plate or not plate:IsVisible() then
            TargetLine_HideAll()
            return
        end
    end

    -- 可选距离限制（仅当 UnitXP 可用时）
    local hasUnitXP = pcall(UnitXP, "nop", "nop")
    if hasUnitXP then
        local success, yards = pcall(UnitXP, "distanceBetween", "player", "target")
        if success and yards and ( yards < 8 or yards > 50 ) then
            TargetLine_HideAll()
            return
        end
    end

    -- 获取姓名板位置（偏移 -20 使连线指向目标脚下）
    if not TargetLine.probe then
        local probe = CreateFrame("Frame", nil, UIParent)
        probe:SetWidth(1)
        probe:SetHeight(1)
        TargetLine.probe = probe
    end
    local probe = TargetLine.probe
    probe:ClearAllPoints()
    probe:SetPoint("CENTER", plate, "CENTER", 0, -20)
    probe:GetLeft()
    local px, py = probe:GetCenter()
    if not px or not py then
        TargetLine_HideAll()
        return
    end

    local sx, sy = TargetLine_GetScreenCenter()
    local dx = px - sx
    local dy = py - sy
    local len = math.sqrt(dx * dx + dy * dy)
    if len < 1 then
        TargetLine_HideAll()
        return
    end
    local ux = dx / len
    local uy = dy / len

    -- 绘制红点（最后一个点正好在目标位置）
    local dotCount = table.getn(TargetLine.pool)
    for i = 1, dotCount do
        local t = (i - 1) / (dotCount - 1)   -- 最后一个点 t = 1
        local x = sx + ux * len * t
        local y = sy + uy * len * t
        local dot = TargetLine.pool[i]
        dot:ClearAllPoints()
        dot:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
        dot:Show()
    end
end

-- 目标切换时清空缓存
local function TargetLine_OnTargetChanged()
    TargetLine.lastTargetGUID = nil
end

-- 颜色转换辅助函数
function DEX_ToDec(a)
    local i = 0;
    while a - i > 1 do
        i = i + 1;
    end
    return i;
end

function DEX_ToHEX(a)
    if a < 0 then a = 0;end
    if a > 1 then a = 1;end
    local b = a * 256;
    return ""..DEX_HEX_LIST[DEX_ToDec(b / 16) + 1]..DEX_HEX_LIST[ DEX_ToDec( ( b / 16 - DEX_ToDec(b / 16) ) * 16 ) + 1];
end

function DEX_ColorFlip(r,g,b)
    return "|cff"..DEX_ToHEX(r)..DEX_ToHEX(g)..DEX_ToHEX(b);
end

-- 生成渐变色文字
function DEX_TranTxt(txt,rgb1,rgb2)    
    local tc = string.len(txt)
    if tc < 2 then return txt;end

    -- 计算实际字符数量（中文字符按1个计算）
    local charCount = 0
    local i = 1
    while i <= tc do
        local byte = string.byte(txt, i)
        if byte < 128 then
            if byte ~= 32 then
                charCount = charCount + 1
            end
            i = i + 1
        else
            charCount = charCount + 1
            i = i + 3
        end
    end

    if charCount < 2 then return txt;end

    local re = ""
    local rs,gs,bs
    rs = (rgb2[1] - rgb1[1]) / (charCount - 1)
    gs = (rgb2[2] - rgb1[2]) / (charCount - 1)
    bs = (rgb2[3] - rgb1[3]) / (charCount - 1)

    local charIndex = 0
    i = 1
    while i <= tc do
        local byte = string.byte(txt, i)
        if byte < 128 then
            if byte ~= 32 then
                charIndex = charIndex + 1
                local char = string.sub(txt, i, i)
                re = re..DEX_ColorFlip(rgb1[1] + rs * (charIndex - 1),rgb1[2] + gs * (charIndex - 1),rgb1[3] + bs * (charIndex - 1))..char.."|r"
            else
                re = re.." "
            end
            i = i + 1
        else
            charIndex = charIndex + 1
            local char = string.sub(txt, i, i + 2)
            re = re..DEX_ColorFlip(rgb1[1] + rs * (charIndex - 1),rgb1[2] + gs * (charIndex - 1),rgb1[3] + bs * (charIndex - 1))..char.."|r"
            i = i + 3
        end
    end
    return re
end

-- 构建显示文本（根据颜色模式）
function DEX_BuildText(damage, spellId, color, colorSe, damagetype, crit, isAOE)
    if DEX_Get("DEX_NumberFormat") == 1 and tonumber(damage) then
        damage = amount_format(damage)
    end

    local spell = GetSpellRecField(spellId, "name")
    local colorMode = DEX_Get("DEX_ColorMode") or 1

    if isAOE and DEX_Get("DEX_EnableAOEStandalone") == 1 then
        spell = ""
    end

    if DEX_Get("DEX_ShowSpellName") ~= 1 then
        -- 主开关关闭，不显示技能名
        spell = ""
    else
        -- 判断是否为数值伤害（包含数字）还是文本事件（如未击中）
        local hasDigit = string.find(damage, "%d") ~= nil
        local isDamageNumber = hasDigit
        local shouldShow = false
        if DEX_Get("DEX_ShowNameOnCrit") == 1 and DEX_Get("DEX_ShowNameOnMiss") == 1 then
            -- 两者都勾选：暴击或未击中时显示
            shouldShow = (crit == 1) or (not isDamageNumber)
        elseif DEX_Get("DEX_ShowNameOnCrit") == 1 then
            -- 仅暴击显示
            shouldShow = (crit == 1)
        elseif DEX_Get("DEX_ShowNameOnMiss") == 1 then
            -- 仅未击中显示
            shouldShow = (not isDamageNumber)
        else
            -- 两者都不勾选：总是显示
            shouldShow = true
        end
        if not shouldShow then
            spell = ""
        end
    end

    if colorMode == 1 then
        -- 单色
        local text = damage;
        if spell and spell ~= "" then
            text = text .. " " .. spell;
        end
        return text;
    elseif colorMode == 2 then
        -- 双色
        local text = damage;
        if spell and spell ~= "" and colorSe then
            text = text .. " " .. DEX_ColorFlip(colorSe[1], colorSe[2], colorSe[3]) .. spell .. "|r";
        elseif spell and spell ~= "" then
            text = text .. " " .. spell;
        end
        return text;
    elseif colorMode == 3 then
        -- 渐变
        local text = damage;
        if spell and spell ~= "" then
            text = text .. " " .. spell;
        end
        if colorSe then
            return DEX_TranTxt(text, color, colorSe);
        else
            return text;
        end
    elseif colorMode == 4 then
        -- 模式4：伤害类型着色（对直接法术和周期性法术生效）
        if (damagetype == DEX_DAMAGE_TYPE_SPELL or damagetype == DEX_DAMAGE_TYPE_PERIODIC) and spellId and spellId > 0 then
            local enhancedColor = DEX_GetEnhancedColor(damage, spellId, damagetype, crit)
            if enhancedColor then
                local numText = DEX_ColorFlip(enhancedColor[1], enhancedColor[2], enhancedColor[3]) .. damage .. "|r"
                local spellText = ""
                if spell and spell ~= "" and colorSe then
                    spellText = " " .. DEX_ColorFlip(colorSe[1], colorSe[2], colorSe[3]) .. spell .. "|r"
                elseif spell and spell ~= "" then
                    spellText = " " .. spell
                end
                return numText .. spellText
            end
        end
        local text = damage;
        if spell and spell ~= "" then
            text = text .. " " .. spell;
        end
        return text;
    end
end

-- 根据法术学校和数值获取增强颜色（用于颜色模式4）
function DEX_GetEnhancedColor(damage, spellId, damagetype, crit)
    local color = {1,1,1};
    local damageNum = tonumber(damage) or 0;

    if damagetype == DEX_DAMAGE_TYPE_HIT then
        if damageNum > 2000 then
            color = {1, 0.9, 0.1};
        elseif damageNum > 1000 then
            color = {1, 0.8, 0.2};
        elseif damageNum > 500 then
            color = {0.9, 0.7, 0.1};
        else
            color = {0.8, 0.6, 0.1};
        end
    elseif damagetype == DEX_DAMAGE_TYPE_SPELL then
        if GetSpellIdForName and GetSpellRecField then
            if spellId and spellId > 0 then
                local school = GetSpellRecField(spellId, "school")
                if school then
                    if school == 1 then -- 神圣
                        color = {1, 1, 0.3}
                    elseif school == 2 then -- 火焰
                        color = {1, 0.3, 0.3}
                    elseif school == 3 then -- 自然
                        color = {0.2, 1, 0.2}
                    elseif school == 4 then -- 冰霜
                        color = {0.3, 0.8, 1}
                    elseif school == 5 then -- 暗影
                        color = {0.6, 0.2, 0.8}
                    elseif school == 6 then -- 奥术
                        color = {0.8, 0.3, 1}
                    else
                        color = DEX_Get("DEX_ColorSkill")
                    end
                    if crit and crit > 0 then
                        color[1] = math.min(color[1] * 1.4, 1)
                        color[2] = math.min(color[2] * 1.4, 1)
                        color[3] = math.min(color[3] * 1.4, 1)
                    end
                    return color
                end
            end
        else
            color = DEX_Get("DEX_ColorSkill");
        end
    elseif damagetype == DEX_DAMAGE_TYPE_PERIODIC then
        if GetSpellIdForName and GetSpellRecField and spellId and spellId > 0 then
            local school = GetSpellRecField(spellId, "school")
            if school then
                if school == 1 then -- 神圣
                    color = {1, 1, 0.3}
                elseif school == 2 then -- 火焰
                    color = {1, 0.3, 0.3}
                elseif school == 3 then -- 自然
                    color = {0.2, 1, 0.2}
                elseif school == 4 then -- 冰霜
                    color = {0.3, 0.8, 1}
                elseif school == 5 then -- 暗影
                    color = {0.6, 0.2, 0.8}
                elseif school == 6 then -- 奥术
                    color = {0.8, 0.3, 1}
                else
                    color = DEX_Get("DEX_ColorPeriodic")
                end
            else
                color = DEX_Get("DEX_ColorPeriodic")
            end
        else
            color = DEX_Get("DEX_ColorPeriodic")
        end
    elseif damagetype == DEX_DAMAGE_TYPE_HEALTH then
        if damageNum > 3000 then
            color = {0.1, 1, 0.1};
        elseif damageNum > 1500 then
            color = {0.2, 1, 0.2};
        elseif damageNum > 500 then
            color = {0.3, 0.9, 0.3};
        else
            color = {0.4, 0.8, 0.4};
        end
    elseif damagetype == DEX_DAMAGE_TYPE_PET then
        color = DEX_Get("DEX_ColorPet");
    end

    if crit and crit > 0 then
        color[1] = math.min(color[1] * 1.4, 1);
        color[2] = math.min(color[2] * 1.4, 1);
        color[3] = math.min(color[3] * 1.4, 1);
    end

    return color;
end

-- 插件加载时注册事件
function DEX_OnLoad()
    this:RegisterEvent("PLAYER_ENTERING_WORLD");
    this:RegisterEvent("VARIABLES_LOADED");
    this:RegisterEvent("ADDON_LOADED");
    DEX_Set_WOWDamage();
end

-- 初始化插件
function DEX_Init()
    if (DEX_Registered == 1) then return;end

    -- 初始化目标连线红点池
    TargetLine_InitPool()
    TargetLine_UpdateStyle()
    -- 注册目标切换事件（清空缓存）
    this:RegisterEvent("PLAYER_TARGET_CHANGED")

    -- 开启 Nampower 事件
    if GetNampowerVersion then
        local major, minor, patch = GetNampowerVersion()
        if major >= 4 then
            SetCVar("NP_EnableAutoAttackEvents", "1")
            SetCVar("NP_EnableSpellHealEvents", "1")
            SetCVar("NP_EnableSpellEnergizeEvents", "1")
        else
            DEX_Debug(DEX_LANG_ERROR_NAMEPOWER_LOW)
        end
    end

    -- 注册 Nampower 事件
    if GetNampowerVersion then
        this:RegisterEvent("SPELL_DAMAGE_EVENT_SELF");
        this:RegisterEvent("AUTO_ATTACK_SELF");
        this:RegisterEvent("SPELL_HEAL_BY_SELF");
        this:RegisterEvent("DAMAGE_SHIELD_SELF");
        this:RegisterEvent("SPELL_MISS_SELF");
        this:RegisterEvent("SPELL_DAMAGE_EVENT_OTHER");
        this:RegisterEvent("AUTO_ATTACK_OTHER");
        this:RegisterEvent("SPELL_HEAL_BY_OTHER");
        this:RegisterEvent("DAMAGE_SHIELD_OTHER");
        this:RegisterEvent("SPELL_MISS_OTHER");
        this:RegisterEvent("SPELL_ENERGIZE_BY_SELF");
        this:RegisterEvent("SPELL_ENERGIZE_ON_SELF");
    else
        DEFAULT_CHAT_FRAME:AddMessage(DEX_LANG_ERROR_NO_NAMEPOWER);
        return;
    end

    if DEX_SAVE == nil then DEX_SAVE = {};end
    DEXPlayer = DEX_Config_GetPlayer();
    DEX_Debug(DEX_Version);
    DEX_Registered = 1

    SlashCmdList["DEX"] = DEX_showMenu;
    SLASH_DEX1 = "/dex";

    -- 测试命令（仅在调试时使用）
    SlashCmdList["DEXTEST"] = function(msg)
        if msg == DEX_LANG_COMMANDS.CRIT or msg == DEX_LANG_COMMANDS.CRIT_ZH then
            local fontSize = DEX_Get("DEX_FontSize") or DEX_TEXTSIZE;
            DEFAULT_CHAT_FRAME:AddMessage(DEX_LANG_DEBUG.TITLE);
            DEFAULT_CHAT_FRAME:AddMessage(string.format(DEX_LANG_DEBUG.FONT_SIZE, fontSize));
            DEFAULT_CHAT_FRAME:AddMessage(string.format(DEX_LANG_DEBUG.CRIT_MULTIPLIER, "0.1"));
            DEFAULT_CHAT_FRAME:AddMessage(string.format(DEX_LANG_DEBUG.EXPECTED_CRIT_SIZE, fontSize * 1.1));

            DEX_AddText("1234", 0, DEX_DAMAGE_TYPE_HIT, 1);
            DEX_AddText("5678", 0, DEX_DAMAGE_TYPE_HIT, 1);
            DEX_AddText("999", 133, DEX_DAMAGE_TYPE_SPELL, 1);
            DEX_AddText("666", 0, DEX_DAMAGE_TYPE_PET, 1);
            DEFAULT_CHAT_FRAME:AddMessage(DEX_LANG_DEBUG.CRIT_TEST_DONE);
        elseif msg == DEX_LANG_COMMANDS.NORMAL or msg == DEX_LANG_COMMANDS.NORMAL_ZH then
            DEX_AddText("123", 0, DEX_DAMAGE_TYPE_HIT, 0);
            DEX_AddText("456", 133, DEX_DAMAGE_TYPE_SPELL, 0);
            DEX_AddText("789", 0, DEX_DAMAGE_TYPE_PET, 0);
            DEFAULT_CHAT_FRAME:AddMessage(DEX_LANG_DEBUG.NORMAL_TEST_DONE);
        elseif msg == DEX_LANG_COMMANDS.COLOR or msg == DEX_LANG_COMMANDS.COLOR_ZH then
            DEFAULT_CHAT_FRAME:AddMessage(DEX_LANG_DEBUG.COLOR_TITLE);
            DEFAULT_CHAT_FRAME:AddMessage(string.format(DEX_LANG_DEBUG.COLOR_MODE, DEX_Get("DEX_ColorMode") or "nil"));

            DEX_AddText("12345", 133, DEX_DAMAGE_TYPE_SPELL, 0);
            DEX_AddText("23456", 116, DEX_DAMAGE_TYPE_SPELL, 0);
            DEX_AddText("34567", 686, DEX_DAMAGE_TYPE_SPELL, 0);
            DEX_AddText("45678", 172, DEX_DAMAGE_TYPE_PERIODIC, 0);
            DEX_AddText("56789", 689, DEX_DAMAGE_TYPE_PERIODIC, 0);
            DEFAULT_CHAT_FRAME:AddMessage(DEX_LANG_DEBUG.COLOR_TEST_DONE);
        elseif msg == DEX_LANG_COMMANDS.DEBUG or msg == DEX_LANG_COMMANDS.DEBUG_ZH then
            DEX_ShowColorDebug = not DEX_ShowColorDebug;
            DEX_ColorModeDebugShown = false;
            DEX_GradientDebugShown = false;
            DEX_TranTxtDebugShown = false;
            if DEX_ShowColorDebug then
                DEFAULT_CHAT_FRAME:AddMessage(DEX_LANG_DEBUG.DEBUG_MODE_ON);
            else
                DEFAULT_CHAT_FRAME:AddMessage(DEX_LANG_DEBUG.DEBUG_MODE_OFF);
            end
        elseif msg == DEX_LANG_COMMANDS.FONT or msg == DEX_LANG_COMMANDS.FONT_ZH then
            local currentFont = DEX_Get("DEX_Font") or 1;
            DEFAULT_CHAT_FRAME:AddMessage(DEX_LANG_DEBUG.FONT_TITLE);
            DEFAULT_CHAT_FRAME:AddMessage(string.format(DEX_LANG_DEBUG.FONT_NUMBER, currentFont));
            DEFAULT_CHAT_FRAME:AddMessage(string.format(DEX_LANG_DEBUG.FONT_PATH, DEX_FONTNAME or "nil"));
            DEFAULT_CHAT_FRAME:AddMessage("");

            DEFAULT_CHAT_FRAME:AddMessage(DEX_LANG_DEBUG.FONT_LIST);
            for i = 1, 3 do
                DEFAULT_CHAT_FRAME:AddMessage(string.format(DEX_LANG_DEBUG.FONT_ENTRY, i, DEX_FontList[i] or "nil"));
            end
            DEFAULT_CHAT_FRAME:AddMessage("");

            DEFAULT_CHAT_FRAME:AddMessage(DEX_LANG_DEBUG.START_TEST);
            for i = 1, 3 do
                DEX_Set("DEX_Font", i);
                DEX_aniInit();
                DEFAULT_CHAT_FRAME:AddMessage(string.format(DEX_LANG_DEBUG.TEST_FONT, i, DEX_FontList[i]));
                DEX_AddText("88888", 0, DEX_DAMAGE_TYPE_SPELL, 0);
            end

            DEX_Set("DEX_Font", currentFont);
            DEX_aniInit();
            DEFAULT_CHAT_FRAME:AddMessage("");
            DEFAULT_CHAT_FRAME:AddMessage(string.format(DEX_LANG_DEBUG.FONT_TEST_DONE, currentFont));
            DEFAULT_CHAT_FRAME:AddMessage(DEX_LANG_DEBUG.OBSERVE_NOTE);
            DEFAULT_CHAT_FRAME:AddMessage(DEX_LANG_DEBUG.SEE_NOTE);
        else
            DEFAULT_CHAT_FRAME:AddMessage(DEX_LANG_DEBUG.HELP_TITLE);
            DEFAULT_CHAT_FRAME:AddMessage(DEX_LANG_DEBUG.HELP_CRIT);
            DEFAULT_CHAT_FRAME:AddMessage(DEX_LANG_DEBUG.HELP_NORMAL);
            DEFAULT_CHAT_FRAME:AddMessage(DEX_LANG_DEBUG.HELP_COLOR);
            DEFAULT_CHAT_FRAME:AddMessage(DEX_LANG_DEBUG.HELP_FONT);
            DEFAULT_CHAT_FRAME:AddMessage(DEX_LANG_DEBUG.HELP_DEBUG);
        end
    end;
    SLASH_DEXTEST1 = "/dextest";
    SLASH_DEXTEST2 = "/dex测试";

    if(myAddOnsList) then
        myAddOnsList.DEX = {
            name = "Damage Text",
            description = "DamageEx",
            version = DEX_Version,         
            frame = "DEX_TEXT",         
            optionsframe = "DEXOptions",
            category = MYADDONS_CATEGORY_COMBAT
        };      
    end

    UIPanelWindows["DEXOptions"] = {area = "center", pushable = 0};

    -- 根据玩家职业初始化 AOE 列表
    local _, playerClass = UnitClass("player")
    aoeList = DEX_AOE_LIST[playerClass]

    DEX_aniInit();
    DEX_staticInit();

    DEX_InitMinimapButton();
end

-- 重置当前角色配置
function DEX_Reset()
    DEX_hideMenu();
    DEX_SAVE[UnitName("player").." of "..GetCVar("realmName")] = nil;
    DEXPlayer = DEX_Config_GetPlayer(); 
    DEX_showMenu(); 
end

function DEX_Config_GetPlayer()
    if (DEX_SAVE[UnitName("player").." of "..GetCVar("realmName")] == nil) then
        DEX_Config_NewPlayer(UnitName("player").." of "..GetCVar("realmName"));
    end
    return DEX_SAVE[UnitName("player").." of "..GetCVar("realmName")];
end

-- 为新角色创建默认配置
function DEX_Config_NewPlayer(PlayerName)
    DEX_SAVE[PlayerName] = DEX_clone(DEX_DEFAULT_CFG);
end

-- 获取配置值（若不存在则补全）
function DEX_Get(option)
    if (DEXPlayer ~= nil) and (DEXPlayer[option] ~= nil) then
        return DEXPlayer[option];
    else
        local defaultValue = DEX_DEFAULT_CFG[option];
        if defaultValue ~= nil and DEXPlayer ~= nil then
            DEXPlayer[option] = defaultValue;
        end
        return defaultValue;
    end
end

function DEX_Set(option, newVal)
    if (DEXPlayer ~= nil) then
        if ( option ) then
            DEXPlayer[option] = newVal;
        end
    end
end

-- 深拷贝表格
function DEX_clone(t)
    local new = {};
    local i, v = next(t, nil);
    while i do
        if type(v)=="table" then 
            v=DEX_clone(v);
        end 
        new[i] = v;
        i, v = next(t, i);
    end
    return new;
end

-- 事件处理
function DEX_OnEvent(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
    if (event == "VARIABLES_LOADED") or ( event == "ADDON_LOADED" and arg1 == "DamegeEx" ) or (event=="PLAYER_ENTERING_WORLD") then
        DEX_Init();
        return;
    end

    if DEX_Registered ~= 1 then return;end
    if DEX_Get("DEX_Enable") ~= 1 then return;end

    -- Nampower 事件处理
    if event == "SPELL_DAMAGE_EVENT_SELF" then
        local targetGuid, casterGuid, spellId, amount, mitigationStr, hitInfo, spellSchool, effectAuraStr = arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8
        local targetName = UnitName(targetGuid) or ""
        local crit = 0
        if hitInfo and bit.band(hitInfo, 2) ~= 0 then crit = 1 end
        local damagetype = DEX_DAMAGE_TYPE_SPELL

        local isPeriodic = false
        if effectAuraStr and effectAuraStr ~= "" then
            local effect = strsplit(effectAuraStr, ",")
			local auraType = tonumber(effect[4])

            if auraType == 3 or auraType == 89 then
                isPeriodic = true
            end
        end

        if isPeriodic then
            damagetype = DEX_DAMAGE_TYPE_PERIODIC
        end

        local damageText = amount
        if mitigationStr and mitigationStr ~= "" then
            local mitigationTable = strsplit(mitigationStr, ",")
            local absorb = tonumber(mitigationTable[1])
            local block = tonumber(mitigationTable[2])
            local resist = tonumber(mitigationTable[3])

            if block and block > 0 and DEX_Get("DEX_ShowBlockNumber") == 1 then
                damageText = amount .. " (".. DEX_TXT_BLOCK .." " .. block .. ")"
            end

            if absorb and absorb > 0 and DEX_Get("DEX_ShowBlockNumber") == 1 then
                damageText = amount .. " (".. DEX_TXT_ABSORB .." " .. absorb .. ")"
            end

            if resist and resist > 0 and DEX_Get("DEX_ShowBlockNumber") == 1 then
                damageText = amount .. " (".. DEX_TXT_RESIST .." " .. resist .. ")"
            end
        end

        DEX_RecordEventUnit(targetGuid)
        DEX_AddText(damageText, spellId, damagetype, crit, targetName, targetGuid)
        return

    elseif event == "AUTO_ATTACK_SELF" then
        local attackerGuid, targetGuid, totalDamage, hitInfo, victimState, subDamageCount, blockedAmount, totalAbsorb, totalResist = arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9
        local targetName = UnitName(targetGuid) or ""

        if victimState == 1 then
            local crit = 0
            if hitInfo and bit.band(hitInfo, 128) ~= 0 then crit = 1 end
            local damageText = totalDamage

            if blockedAmount and blockedAmount > 0 and DEX_Get("DEX_ShowBlockNumber") == 1 then
                damageText = totalDamage .. " (".. DEX_TXT_BLOCK .." " .. blockedAmount .. ")"
            end

            if totalAbsorb and totalAbsorb > 0 and DEX_Get("DEX_ShowBlockNumber") == 1 then
                damageText = totalDamage .. " (".. DEX_TXT_ABSORB .." " .. totalAbsorb .. ")"
            end

            if totalResist and totalResist > 0 and DEX_Get("DEX_ShowBlockNumber") == 1 then
                damageText = totalDamage .. " (".. DEX_TXT_RESIST .." " .. totalResist .. ")"
            end

            DEX_RecordEventUnit(targetGuid)
            DEX_AddText(damageText, 0, DEX_DAMAGE_TYPE_HIT, crit, targetName, targetGuid)
        else
            local missText = ""
            if victimState == 2 then missText = DEX_TXT_DODGE
            elseif victimState == 3 then missText = DEX_TXT_PARRY
            elseif victimState == 5 then missText = DEX_TXT_BLOCK
            elseif victimState == 6 then missText = DEX_TXT_EVADE
            elseif victimState == 7 then missText = DEX_TXT_IMM
            elseif victimState == 8 then missText = DEX_TXT_DEFLECTED
            else missText = DEX_TXT_MISS
            end
            DEX_RecordEventUnit(targetGuid)
            DEX_AddText(missText, 0, DEX_DAMAGE_TYPE_HIT, 0, targetName, targetGuid)
        end
        return

    elseif event == "SPELL_HEAL_BY_SELF" then
        local targetGuid, casterGuid, spellId, amount, critical, periodic = arg1, arg2, arg3, arg4, arg5, arg6
        local targetName = UnitName(targetGuid) or ""
        DEX_RecordEventUnit(targetGuid)
        DEX_AddText(amount, spellId, DEX_DAMAGE_TYPE_HEALTH, critical, targetName, targetGuid)
        return

    elseif event == "DAMAGE_SHIELD_SELF" then
        local unitGuid, targetGuid, damage, spellSchool = arg1, arg2, arg3, arg4
        local targetName = UnitName(targetGuid) or ""
        DEX_RecordEventUnit(targetGuid)
        DEX_AddText(damage, 0, DEX_DAMAGE_TYPE_SPELL, 0, targetName, targetGuid)
        return

    elseif event == "SPELL_MISS_SELF" then
        local casterGuid, targetGuid, spellId, missInfo = arg1, arg2, arg3, arg4
        local targetName = UnitName(targetGuid) or ""
        local missText = ""
        if missInfo == 1 then missText = DEX_TXT_MISS
        elseif missInfo == 2 then missText = DEX_TXT_RESIST
        elseif missInfo == 3 then missText = DEX_TXT_DODGE
        elseif missInfo == 4 then missText = DEX_TXT_PARRY
        elseif missInfo == 5 then missText = DEX_TXT_BLOCK
        elseif missInfo == 6 then missText = DEX_TXT_EVADE
        elseif missInfo == 7 or missInfo == 8 then missText = DEX_TXT_IMM
        elseif missInfo == 9 then missText = DEX_TXT_DEFLECTED
        elseif missInfo == 10 then missText = DEX_TXT_ABSORB
        elseif missInfo == 11 then missText = DEX_TXT_SHIELD
        else missText = DEX_TXT_MISS
        end
        DEX_RecordEventUnit(targetGuid)
        DEX_AddText(missText, spellId, DEX_DAMAGE_TYPE_SPELL, 0, targetName, targetGuid)
        return

	elseif event == "SPELL_DAMAGE_EVENT_OTHER" then
        local targetGuid, casterGuid, spellId, amount, mitigationStr, hitInfo, spellSchool, effectAuraStr = arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8
        local playerGuid = GetUnitGUID("player")
        -- 目标为自己，显示受到的伤害
        if targetGuid == playerGuid then
            local crit = 0
            if hitInfo and bit.band(hitInfo, 2) ~= 0 then crit = 1 end
            local damageText = amount
            if mitigationStr and mitigationStr ~= "" then
			    local mitigationTable = strsplit(mitigationStr, ",")
			    local absorb = tonumber(mitigationTable[1])
			    local block = tonumber(mitigationTable[2])
			    local resist = tonumber(mitigationTable[3])
                if block and block > 0 and DEX_Get("DEX_ShowBlockNumber") == 1 then
                    damageText = amount .. " (".. DEX_TXT_BLOCK .." " .. block .. ")"
                end
                if absorb and absorb > 0 and DEX_Get("DEX_ShowBlockNumber") == 1 then
                    damageText = amount .. " (".. DEX_TXT_ABSORB .." " .. absorb .. ")"
                end
                if resist and resist > 0 and DEX_Get("DEX_ShowBlockNumber") == 1 then
                    damageText = amount .. " (".. DEX_TXT_RESIST .." " .. resist .. ")"
                end
            end
            local targetName = UnitName(targetGuid) or ""
            DEX_RecordEventUnit(targetGuid)
            DEX_AddText(damageText, spellId, DEX_DAMAGE_TYPE_INCOMING, crit, targetName, targetGuid)
            return
        end
        -- 宠物伤害处理
        local ownerGUID = casterGuid and GetUnitGUID(casterGuid.."owner")
        local charmGUID = casterGuid and GetUnitField(casterGuid, "charm")
        local createrGUID = casterGuid and GetUnitField(casterGuid, "createdBy")
        local relationType = nil
        if charmGUID and playerGuid == charmGUID then
            relationType = "charm"
        elseif createrGUID and playerGuid == createrGUID then
            relationType = "createdBy"
        elseif ownerGUID and playerGuid == ownerGUID then
            relationType = "owner"
        end
        if not relationType then return end  -- 无关单位直接忽略

		local targetName = UnitName(targetGuid) or ""
		local crit = 0
		if hitInfo and bit.band(hitInfo, 2) ~= 0 then crit = 1 end

		local damagetype = DEX_DAMAGE_TYPE_SPELL
		local isPeriodic = false
		if effectAuraStr and effectAuraStr ~= "" then
            local effect = strsplit(effectAuraStr, ",")
			local auraType = tonumber(effect[4])
			if auraType == 3 or auraType == 89 then
				isPeriodic = true
			end
		end
		if isPeriodic then
			damagetype = DEX_DAMAGE_TYPE_PERIODIC
		end

		local damageText = amount
		if mitigationStr and mitigationStr ~= "" then
			local mitigationTable = strsplit(mitigationStr, ",")
			local absorb = tonumber(mitigationTable[1])
			local block = tonumber(mitigationTable[2])
			local resist = tonumber(mitigationTable[3])

			if block and block > 0 and DEX_Get("DEX_ShowBlockNumber") == 1 then
				damageText = amount .. " (".. DEX_TXT_BLOCK .." " .. block .. ")"
			end
			if absorb and absorb > 0 and DEX_Get("DEX_ShowBlockNumber") == 1 then
				damageText = amount .. " (".. DEX_TXT_ABSORB .." " .. absorb .. ")"
			end
			if resist and resist > 0 and DEX_Get("DEX_ShowBlockNumber") == 1 then
				damageText = amount .. " (".. DEX_TXT_RESIST .." " .. resist .. ")"
			end
		end

		-- 根据关系类型决定最终伤害类型
		local finalDamagetype
		if relationType == "charm" then
			finalDamagetype = damagetype
		else
			finalDamagetype = DEX_DAMAGE_TYPE_PET
		end

		DEX_RecordEventUnit(targetGuid)
		DEX_AddText(damageText, spellId, finalDamagetype, crit, targetName, targetGuid)
		return

	elseif event == "AUTO_ATTACK_OTHER" then
        local attackerGuid, targetGuid, totalDamage, hitInfo, victimState, subDamageCount, blockedAmount, totalAbsorb, totalResist = arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9
        local playerGuid = GetUnitGUID("player")
        -- 目标为自己，显示受到的平砍伤害
        if targetGuid == playerGuid then
            local targetName = UnitName(targetGuid) or ""
            if victimState == 1 then
                local crit = 0
                if hitInfo and bit.band(hitInfo, 128) ~= 0 then crit = 1 end
                local damageText = totalDamage
                if blockedAmount and blockedAmount > 0 and DEX_Get("DEX_ShowBlockNumber") == 1 then
                    damageText = totalDamage .. " (".. DEX_TXT_BLOCK .." " .. blockedAmount .. ")"
                end
                if totalAbsorb and totalAbsorb > 0 and DEX_Get("DEX_ShowBlockNumber") == 1 then
                    damageText = totalDamage .. " (".. DEX_TXT_ABSORB .." " .. totalAbsorb .. ")"
                end
                if totalResist and totalResist > 0 and DEX_Get("DEX_ShowBlockNumber") == 1 then
                    damageText = totalDamage .. " (".. DEX_TXT_RESIST .." " .. totalResist .. ")"
                end
                DEX_RecordEventUnit(targetGuid)
                DEX_AddText(damageText, 0, DEX_DAMAGE_TYPE_INCOMING, crit, targetName, targetGuid)
            else
                local missText = ""
                if victimState == 2 then missText = DEX_TXT_DODGE
                elseif victimState == 3 then missText = DEX_TXT_PARRY
                elseif victimState == 5 then missText = DEX_TXT_BLOCK
                elseif victimState == 6 then missText = DEX_TXT_EVADE
                elseif victimState == 7 then missText = DEX_TXT_IMM
                elseif victimState == 8 then missText = DEX_TXT_DEFLECTED
                else missText = DEX_TXT_MISS
                end
                DEX_RecordEventUnit(targetGuid)
                DEX_AddText(missText, 0, DEX_DAMAGE_TYPE_INCOMING, 0, targetName, targetGuid)
            end
            return
        end
        -- 宠物攻击处理
        local ownerGUID = attackerGuid and GetUnitGUID(attackerGuid.."owner")
        local charmGUID = attackerGuid and GetUnitField(attackerGuid, "charm")
        local createrGUID = attackerGuid and GetUnitField(attackerGuid, "createdBy")
        local relationType = nil
        if charmGUID and playerGuid == charmGUID then
            relationType = "charm"
        elseif createrGUID and playerGuid == createrGUID then
            relationType = "createdBy"
        elseif ownerGUID and playerGuid == ownerGUID then
            relationType = "owner"
        end
        if not relationType then return end

		local targetName = UnitName(targetGuid) or ""
		if victimState == 1 then
			local crit = 0
			if hitInfo and bit.band(hitInfo, 128) ~= 0 then crit = 1 end
			local damageText = totalDamage

			if blockedAmount and blockedAmount > 0 and DEX_Get("DEX_ShowBlockNumber") == 1 then
				damageText = totalDamage .. " (".. DEX_TXT_BLOCK .." " .. blockedAmount .. ")"
			end
			if totalAbsorb and totalAbsorb > 0 and DEX_Get("DEX_ShowBlockNumber") == 1 then
				damageText = totalDamage .. " (".. DEX_TXT_ABSORB .." " .. totalAbsorb .. ")"
			end
			if totalResist and totalResist > 0 and DEX_Get("DEX_ShowBlockNumber") == 1 then
				damageText = totalDamage .. " (".. DEX_TXT_RESIST .." " .. totalResist .. ")"
			end

			local finalDamagetype
			if relationType == "charm" then
				finalDamagetype = DEX_DAMAGE_TYPE_HIT
			else
				finalDamagetype = DEX_DAMAGE_TYPE_PET
			end

			DEX_RecordEventUnit(targetGuid)
			DEX_AddText(damageText, 0, finalDamagetype, crit, targetName, targetGuid)
		else
			local missText = ""
			if victimState == 2 then missText = DEX_TXT_DODGE
			elseif victimState == 3 then missText = DEX_TXT_PARRY
			elseif victimState == 5 then missText = DEX_TXT_BLOCK
			elseif victimState == 6 then missText = DEX_TXT_EVADE
			elseif victimState == 7 then missText = DEX_TXT_IMM
			elseif victimState == 8 then missText = DEX_TXT_DEFLECTED
			else missText = DEX_TXT_MISS
			end

			local finalDamagetype
			if relationType == "charm" then
				finalDamagetype = DEX_DAMAGE_TYPE_HIT
			else
				finalDamagetype = DEX_DAMAGE_TYPE_PET
			end

			DEX_RecordEventUnit(targetGuid)
			DEX_AddText(missText, 0, finalDamagetype, 0, targetName, targetGuid)
		end
		return

	elseif event == "SPELL_HEAL_BY_OTHER" then
		local targetGuid, casterGuid, spellId, amount, critical, periodic = arg1, arg2, arg3, arg4, arg5, arg6
		local ownerGUID = casterGuid and GetUnitGUID(casterGuid.."owner")
		local charmGUID = casterGuid and GetUnitField(casterGuid, "charm")
		local createrGUID = casterGuid and GetUnitField(casterGuid, "createdBy")
		local playerGuid = GetUnitGUID("player")
		local relationType = nil
		if charmGUID and playerGuid == charmGUID then
			relationType = "charm"
		elseif createrGUID and playerGuid == createrGUID then
			relationType = "createdBy"
		elseif ownerGUID and playerGuid == ownerGUID then
			relationType = "owner"
		end
		if not relationType then return end

		local targetName = UnitName(targetGuid) or ""

		local finalDamagetype = DEX_DAMAGE_TYPE_HEALTH

		DEX_RecordEventUnit(targetGuid)
		DEX_AddText(amount, spellId, finalDamagetype, critical, targetName, targetGuid)
		return

	elseif event == "DAMAGE_SHIELD_OTHER" then
        local unitGuid, targetGuid, damage, spellSchool = arg1, arg2, arg3, arg4
        local playerGuid = GetUnitGUID("player")
        -- 目标为自己，显示受到的盾伤害
        if targetGuid == playerGuid then
            local targetName = UnitName(targetGuid) or ""
            DEX_RecordEventUnit(targetGuid)
            DEX_AddText(damage, 0, DEX_DAMAGE_TYPE_INCOMING, 0, targetName, targetGuid)
            return
        end
        -- 宠物盾伤害处理
        local ownerGUID = unitGuid and GetUnitGUID(unitGuid.."owner")
        local charmGUID = unitGuid and GetUnitField(unitGuid, "charm")
        local createrGUID = unitGuid and GetUnitField(unitGuid, "createdBy")
        local relationType = nil
        if charmGUID and playerGuid == charmGUID then
            relationType = "charm"
        elseif createrGUID and playerGuid == createrGUID then
            relationType = "createdBy"
        elseif ownerGUID and playerGuid == ownerGUID then
            relationType = "owner"
        end
        if not relationType then return end

		local targetName = UnitName(targetGuid) or ""

		local finalDamagetype
		if relationType == "charm" then
			finalDamagetype = DEX_DAMAGE_TYPE_SPELL
		else
			finalDamagetype = DEX_DAMAGE_TYPE_PET
		end

		DEX_RecordEventUnit(targetGuid)
		DEX_AddText(damage, 0, finalDamagetype, 0, targetName, targetGuid)
		return

	elseif event == "SPELL_MISS_OTHER" then
        local casterGuid, targetGuid, spellId, missInfo = arg1, arg2, arg3, arg4
        local playerGuid = GetUnitGUID("player")
        -- 目标为自己，显示受到的未命中
        if targetGuid == playerGuid then
            local targetName = UnitName(targetGuid) or ""
            local missText = ""
            if missInfo == 1 then missText = DEX_TXT_MISS
            elseif missInfo == 2 then missText = DEX_TXT_RESIST
            elseif missInfo == 3 then missText = DEX_TXT_DODGE
            elseif missInfo == 4 then missText = DEX_TXT_PARRY
            elseif missInfo == 5 then missText = DEX_TXT_BLOCK
            elseif missInfo == 6 then missText = DEX_TXT_EVADE
            elseif missInfo == 7 or missInfo == 8 then missText = DEX_TXT_IMM
            elseif missInfo == 9 then missText = DEX_TXT_DEFLECTED
            elseif missInfo == 10 then missText = DEX_TXT_ABSORB
            elseif missInfo == 11 then missText = DEX_TXT_SHIELD
            else missText = DEX_TXT_MISS
            end
            DEX_RecordEventUnit(targetGuid)
            DEX_AddText(missText, spellId, DEX_DAMAGE_TYPE_INCOMING, 0, targetName, targetGuid)
            return
        end
        -- 宠物未命中处理
        local ownerGUID = casterGuid and GetUnitGUID(casterGuid.."owner")
        local charmGUID = casterGuid and GetUnitField(casterGuid, "charm")
        local createrGUID = casterGuid and GetUnitField(casterGuid, "createdBy")
        local relationType = nil
        if charmGUID and playerGuid == charmGUID then
            relationType = "charm"
        elseif createrGUID and playerGuid == createrGUID then
            relationType = "createdBy"
        elseif ownerGUID and playerGuid == ownerGUID then
            relationType = "owner"
        end
        if not relationType then return end

		local targetName = UnitName(targetGuid) or ""
		local missText = ""
		if missInfo == 1 then missText = DEX_TXT_MISS
		elseif missInfo == 2 then missText = DEX_TXT_RESIST
		elseif missInfo == 3 then missText = DEX_TXT_DODGE
		elseif missInfo == 4 then missText = DEX_TXT_PARRY
		elseif missInfo == 5 then missText = DEX_TXT_BLOCK
		elseif missInfo == 6 then missText = DEX_TXT_EVADE
		elseif missInfo == 7 or missInfo == 8 then missText = DEX_TXT_IMM
		elseif missInfo == 9 then missText = DEX_TXT_DEFLECTED
		elseif missInfo == 10 then missText = DEX_TXT_ABSORB
		elseif missInfo == 11 then missText = DEX_TXT_SHIELD
		else missText = DEX_TXT_MISS
		end

		local finalDamagetype
		if relationType == "charm" then
			finalDamagetype = DEX_DAMAGE_TYPE_SPELL
		else
			finalDamagetype = DEX_DAMAGE_TYPE_PET
		end

		DEX_RecordEventUnit(targetGuid)
		DEX_AddText(missText, spellId, finalDamagetype, 0, targetName, targetGuid)
		return

    elseif event == "SPELL_ENERGIZE_BY_SELF" then
        if DEX_Get("DEX_ShowEnergize") ~= 1 then return; end
        local targetGuid, casterGuid, spellId, powerType, amount, periodic = arg1, arg2, arg3, arg4, arg5, arg6;
        if casterGuid == GetUnitGUID("player") then return end
        local targetName = UnitName(targetGuid) or "";
        DEX_RecordEventUnit(targetGuid);
        DEX_AddText(amount, spellId, DEX_DAMAGE_TYPE_ENERGIZE, 0, targetName, targetGuid, powerType);
        return;

    elseif event == "SPELL_ENERGIZE_ON_SELF" then
        if DEX_Get("DEX_ShowEnergize") ~= 1 then return; end
        local targetGuid, casterGuid, spellId, powerType, amount, periodic = arg1, arg2, arg3, arg4, arg5, arg6;
        local targetName = UnitName(targetGuid) or "";
        DEX_RecordEventUnit(targetGuid);
        DEX_AddText(amount, spellId, DEX_DAMAGE_TYPE_ENERGIZE, 0, targetName, targetGuid, powerType);
        return;

    elseif event == "PLAYER_TARGET_CHANGED" then
        TargetLine_OnTargetChanged()
    end
end

-- 每帧更新动画
function DEX_GameUpdate(elapsed)
    dex_bottom = 99999;
    dex_petbottom = 99999;
    dex_top = -99999;

    local attachPlates = DEX_Get("DEX_AttachNameplate") == 1 and DEX_Get("DEX_ShowWithMess") == 0
    if attachPlates then
        DEX_ScanNameplates(false)
        DEX_UpdateTargetNameplate()
    end

    if DEX_Get("DEX_ShowWithMess") == 0 then
        for key, value in pairs(dex_AniData) do
            if (value.Active == true) then
                DEX_doAni(value);
            end
        end
    else
        for key, value in pairs(dex_AniData) do
            if (value.Active == true) then
                DEX_doLog(value);
            end
        end
    end

    -- 目标连线绘制（每帧更新）
    if DEX_Get("DEX_EnableTargetLine") == 1 then
        TargetLine_Draw()
    else
        TargetLine_HideAll()
    end
end

-- 判断动画是否应参与防重叠（向上移动）
local function DEX_IsUpwardAni(ani)
    return ani.moveTyp == DEX_MOVTYP_NORMAL and ani.trajectory ~= DEX_TRAJECTORY_VERTICAL_DOWN
end

-- 判断动画是否应参与防重叠（向下移动）
local function DEX_IsDownwardAni(ani)
    return ani.isIncoming == true or ani.trajectory == DEX_TRAJECTORY_VERTICAL_DOWN
end

-- 记录顶部位置用于向下动画防重叠
function DEX_RefressTop(ani)
    if DEX_IsDownwardAni(ani) then
        local top = ani.posY + ani.height;
        if top > dex_top then dex_top = top; end
    end
end

-- 记录底部位置用于防重叠
function DEX_RefressBottom(ani)
    if DEX_IsUpwardAni(ani) then
        if ani.posY < dex_bottom then dex_bottom = ani.posY; end
    end
    if ani.moveTyp == DEX_MOVTYP_PET and ani.trajectory ~= DEX_TRAJECTORY_VERTICAL_DOWN then
        if ani.posY < dex_petbottom then dex_petbottom = ani.posY; end
    end
end

-- 彩虹弧线轨迹
function DEX_TrajectoryRainbow(ani)
    if ani.addY > 0 then
        ani.addY = ani.addY - 0.22
    else
        ani.addY = ani.addY - (0.18 * (DEX_Get("DEX_Speed") / 100))
    end
    if ani.addY < -7 then ani.addY = -7 end
    ani.posY = ani.posY + ani.addY
    ani.posX = ani.posX - 2.2 * ani.sideDir

    local maxDistance = DEX_Get("DEX_AnimHeight") or 400
    if ani.posY < (ani.baseY - maxDistance) then
        ani.alpha = ani.alpha - 0.05
    end
end

-- 水平轨迹
function DEX_TrajectoryHorizontal(ani)
    local step = math.abs(ani.addX)
    local alphastep = 0.01 * step
    local max = 210 * 0.5
    ani.delay = ani.delay + 1
    if ani.delay > (max / step) then
        ani.alpha = ani.alpha - alphastep
    end
    ani.posX = ani.posX - (ani.addX * ani.sideDir)
end

-- 斜向下抛物线
function DEX_TrajectoryAngledDown(ani)
    if ani.delay <= 13 then
        ani.delay = ani.delay + 1
        ani.posY = ani.posY - ani.addY
        ani.posX = ani.posX - ani.addX * ani.sideDir
    elseif ani.delay <= 35 then
        ani.delay = ani.delay + 1
        ani.posY = ani.posY + (random(0, 70) - 35) * 0.02
        ani.posX = ani.posX + (random(0, 70) - 35) * 0.02
    elseif ani.delay <= 50 then
        ani.delay = ani.delay + 1
    else
        ani.posY = ani.posY + DEX_Get("DEX_Speed") / 50
        ani.posX = ani.posX - (DEX_Get("DEX_Speed") / 50) * ani.sideDir
        ani.alpha = ani.alpha - 0.02
    end
end

-- 斜向上抛物线
function DEX_TrajectoryAngledUp(ani)
    if ani.delay <= 13 then
        ani.delay = ani.delay + 1
        ani.posY = ani.posY + ani.addY
        ani.posX = ani.posX - ani.addX * ani.sideDir
    elseif ani.delay <= 35 then
        ani.delay = ani.delay + 1
        ani.posY = ani.posY + (random(0, 70) - 35) * 0.02
        ani.posX = ani.posX + (random(0, 70) - 35) * 0.02
    elseif ani.delay <= 50 then
        ani.delay = ani.delay + 1
    else
        ani.posY = ani.posY + DEX_Get("DEX_Speed") / 50
        ani.alpha = ani.alpha - 0.02
    end
end

-- 洒水器效果
function DEX_TrajectorySprinkler(ani)
    local movement = DEX_Get("DEX_Speed") / 50
    if ani.delay <= (movement * 10 + 10) then
        ani.delay = ani.delay + 1
        ani.posY = ani.posY + ani.addY
        ani.posX = ani.posX + ani.addX
    elseif ani.delay <= 35 then
        ani.delay = ani.delay + 1
        ani.posY = ani.posY + (random(0, 70) - 35) * 0.02
        ani.posX = ani.posX + (random(0, 70) - 35) * 0.02
    elseif ani.delay <= 55 then
        ani.delay = ani.delay + 1
    else
        ani.posY = ani.posY + (ani.addY * 0.1)
        ani.posX = ani.posX + (ani.addX * 0.1)
        ani.alpha = ani.alpha - 0.02
    end
end

-- 垂直向下轨迹（用于受到伤害）
function DEX_TrajectoryVerticalDown(ani)
    local thetime = GetTime() - ani.starttime;
    ani.posY = ani.baseY - (thetime * DEX_Get("DEX_Speed"));
    ani.posYbak = ani.posY;
    DEX_RefressTop(ani);  -- 记录顶部
end

-- 将动画附着到姓名版
local function DEX_AttachAnimationToPlate(ani, plate)
    if not ani or not plate or not ani.FObject then return end
    local anchor = plate
    if plate.health and plate.health.GetObjectType then
        anchor = plate.health
    elseif plate.nameplate and plate.nameplate.GetObjectType then
        anchor = plate.nameplate
    elseif plate.parent and plate.parent.GetObjectType then
        anchor = plate.parent
    end

    local point = DEX_Get("DEX_NameplatePoint") or "CENTER"
    local relativePoint = DEX_Get("DEX_NameplateRelativePoint") or "CENTER"
    local offsetX = DEX_Get("DEX_NameplateOffsetX") or 0
    local offsetY = DEX_Get("DEX_NameplateOffsetY") or 0
    ani.FObject:ClearAllPoints()
    ani.FObject:SetPoint(point, anchor, relativePoint, offsetX, offsetY)
    if ani.IObject and ani.IObject:IsShown() then
        ani.IObject:ClearAllPoints()
        local iconSize = DEX_Get("DEX_FontSize") or DEX_TEXTSIZE
        ani.IObject:SetPoint(point, anchor, relativePoint, offsetX - iconSize, offsetY)
    end

    local resolvedGUID = DEX_GetNameplateGUID(plate)
    if resolvedGUID then
        DEX_NameplateGUIDMap[resolvedGUID] = plate
        DEX_GUIDToNameplate[plate] = resolvedGUID
        if not ani.eventGUID then
            ani.eventGUID = resolvedGUID
        end
        if ani.eventUnitName then
            DEX_RecordEventUnit(resolvedGUID)
        end
    end

    ani.attachedPlate = anchor
end

-- Log模式动画（静止显示）
function DEX_doLog(ani)
    local thetime = GetTime() - ani.starttime;
    if thetime < DEX_logTime and thetime > 0 then
        ani.FObject:SetAlpha(1);
    else
        if thetime < DEX_logTime + 3 then         
            ani.FObject:SetAlpha(1 - (thetime - DEX_logTime) / 3);
        else
            DEX_aniReset(ani);
        end
    end
end

-- 主动画更新（移动、淡入淡出、暴击缩放）
function DEX_doAni(ani)
    local thetime = GetTime() - ani.starttime;
    local animDuration = DEX_Get("DEX_LOGLINE") / 10
    local fadeInTime = animDuration * 0.08
    local fadeOutStart = animDuration * 0.5
    local fadeOutDuration = animDuration * 0.5

    if thetime < animDuration and thetime > 0 then
        if thetime < fadeInTime then
            local t = thetime / fadeInTime
            ani.alpha = t * t * (3 - 2 * t)
        elseif thetime < fadeOutStart then
            ani.alpha = 1;
        else
            local t = (thetime - fadeOutStart) / fadeOutDuration
            ani.alpha = 1 - (t * t * (3 - 2 * t))
        end

        if ani.crit == 1 and ani.moveTyp == DEX_MOVTYP_NONE then
            ani.posYbak = ani.posY;
        elseif ani.moveTyp == DEX_MOVTYP_NORMAL then
            if ani.trajectory == DEX_TRAJECTORY_VERTICAL then
                ani.posY = thetime * DEX_Get("DEX_Speed") + ani.baseY;
                ani.posYbak = ani.posY;
                DEX_RefressBottom(ani);
            elseif ani.trajectory == DEX_TRAJECTORY_RAINBOW then
                DEX_TrajectoryRainbow(ani);
            elseif ani.trajectory == DEX_TRAJECTORY_HORIZONTAL then
                DEX_TrajectoryHorizontal(ani);
            elseif ani.trajectory == DEX_TRAJECTORY_ANGLED_DOWN then
                DEX_TrajectoryAngledDown(ani);
            elseif ani.trajectory == DEX_TRAJECTORY_ANGLED_UP then
                DEX_TrajectoryAngledUp(ani);
            elseif ani.trajectory == DEX_TRAJECTORY_SPRINKLER then
                DEX_TrajectorySprinkler(ani);
            elseif ani.trajectory == DEX_TRAJECTORY_VERTICAL_DOWN then
                DEX_TrajectoryVerticalDown(ani);
            end
        elseif ani.moveTyp == DEX_MOVTYP_OTHER then
            ani.posX = sin(thetime / 2.1 * 180) * 30 + 75;
        elseif ani.moveTyp == DEX_MOVTYP_AOE then
            if thetime < 0.2 then 
                ani.posY = thetime * 30 + 30;
            else 
                ani.posY = 36;
            end
            if thetime < 0.1 then
                ani.alpha = thetime * 10;
            elseif thetime < 0.7 then
                ani.alpha = 1;
            else
                ani.alpha = 1 - (thetime - 0.7) * 5;
            end
            if thetime > 0.9 then DEX_aniClear(ani);return;end
        end

        -- 暴击缩放处理
        if ani.crit == 1 then
            local baseSize = (DEX_Get("DEX_FontSize") or DEX_TEXTSIZE)*1.5;

            if ani.critTyp == 0 then
                if thetime < 0.05 then
                    ani.height = baseSize * ani.zoom;
                elseif thetime < 0.30 then
                    ani.height = (1 - (thetime - 0.05) / 0.25) * baseSize * ani.zoom + baseSize;
                else
                    ani.height = baseSize;
                end
                DEX_SetFontSize(ani,ani.height);
            elseif ani.critTyp == 1 then
                if thetime < 0.1 then
                    local progress = thetime / 0.1
                    ani.height = baseSize * (1 + ani.zoom * progress);
                    DEX_SetFontSize(ani,ani.height);
                elseif thetime < 0.35 then
                    local progress = (thetime - 0.1) / 0.25
                    ani.height = baseSize * (1 + ani.zoom * (1 - progress));
                    DEX_SetFontSize(ani,ani.height);
                elseif ani.height ~= baseSize then
                    ani.height = baseSize;
                    DEX_SetFontSize(ani,ani.height);
                end
            elseif ani.critTyp == 2 then
                local userFontSize = DEX_Get("DEX_FontSize") or DEX_TEXTSIZE;
                local maxSize = userFontSize + userFontSize * ani.zoom;
                if thetime < 0.1 then
                    ani.height = userFontSize * thetime / 0.1 + userFontSize * ani.zoom;
                else
                    ani.height = maxSize;
                end
                DEX_SetFontSize(ani, ani.height);
            end
            if thetime < 0.2 then
                ani.alpha = thetime * 2.5 + 0.5
            end
        else
            if thetime < 0.05 and ani.height ~= (DEX_Get("DEX_FontSize") or DEX_TEXTSIZE) then
                ani.height = DEX_Get("DEX_FontSize") or DEX_TEXTSIZE;
                DEX_SetFontSize(ani, ani.height);
            end
        end

        ani.FObject:SetAlpha(ani.alpha);

        local basePosX, basePosY;
        if ani.isIncoming then
            basePosX = DEX_Get("DEX_IncomingPosX");
            basePosY = DEX_Get("DEX_IncomingPosY");
        else
            basePosX = DEX_Get("DEX_PosX");
            basePosY = DEX_Get("DEX_PosY");
        end

        if ani.attachedPlate then
            if not ani.attachedPlate:IsShown() or not ani.attachedPlate:IsVisible() then
                local replate = nil
                if ani.eventGUID then
                    replate = DEX_GetNameplateByGUID(ani.eventGUID)
                end
                if not replate and ani.eventUnitName then
                    replate = DEX_GetNameplateByName(ani.eventUnitName)
                end
                if replate and replate:IsVisible() then
                    DEX_AttachAnimationToPlate(ani, replate)
                else
                    ani.attachedPlate = nil
                end
            end
            if ani.attachedPlate then
                local offsetX = (DEX_Get("DEX_NameplateOffsetX") or 0) + ani.posX
                local offsetY = (DEX_Get("DEX_NameplateOffsetY") or 0) + ani.posY
                ani.FObject:ClearAllPoints()
                ani.FObject:SetPoint("CENTER", ani.attachedPlate, "CENTER", offsetX, offsetY)
            else
                ani.FObject:ClearAllPoints()
                ani.FObject:SetPoint("CENTER", "UIParent", "CENTER", ani.posX + basePosX, ani.posY + basePosY);
            end
        else
            ani.FObject:ClearAllPoints()
            ani.FObject:SetPoint("CENTER", "UIParent", "CENTER", ani.posX + basePosX, ani.posY + basePosY);
        end

        if ani.IObject and ani.IObject:IsShown() then
            local iconSize = DEX_Get("DEX_FontSize") or DEX_TEXTSIZE;
            ani.IObject:SetAlpha(ani.alpha);

            if ani.crit == 1 then
                ani.IObject:SetWidth(iconSize);
                ani.IObject:SetHeight(iconSize);
            else
                ani.IObject:SetWidth(iconSize-5);
                ani.IObject:SetHeight(iconSize-5);
            end

            local textWidth = ani.FObject:GetStringWidth()
            ani.IObject:ClearAllPoints();
            if ani.attachedPlate then
                local offsetX = (DEX_Get("DEX_NameplateOffsetX") or 0) + ani.posX
                local offsetY = (DEX_Get("DEX_NameplateOffsetY") or 0) + ani.posY
                ani.IObject:SetPoint("CENTER", ani.attachedPlate, "CENTER", offsetX - textWidth/2 - iconSize/2 - 4, offsetY)
            else
                ani.IObject:SetPoint("CENTER", "UIParent", "CENTER", ani.posX + basePosX - textWidth/2 - iconSize/2 - 4, ani.posY + basePosY);
            end
        end
    else
        if thetime >= animDuration then DEX_aniClear(ani);end
    end
end

-- 清除动画
function DEX_aniClear(ani)
    if ani.crit == 1 then
        if ani.critId < DEX_critFlag then DEX_critFlag = ani.critId;end
    end
    DEX_aniReset(ani);
end

-- 判断是否应附着到姓名版
local function DEX_ShouldAttachToPlate(damagetype)
    if DEX_Get("DEX_ShowWithMess") == 1 then return false end
    if DEX_Get("DEX_AttachNameplate") ~= 1 then return false end
    if damagetype == DEX_DAMAGE_TYPE_INCOMING then return false end
    return true
end

-- 添加一个新的数字文本
function DEX_AddText(damage, spellId, damagetype, crit, unitName, guid, powerType)
    -- 可选过滤器（示例屏蔽特定技能，此处屏蔽火舌攻击）
    if spellId and ( spellId == 52373 or spellId == 10444 ) then return end
    if spellId and ( spellId == 2687 ) then crit=0 end


	-- 队友误伤过滤
	if DEX_Get("DEX_HideFriendlyDamage") == 1 and guid and UnitIsFriend("player", guid) and ( damagetype ~= DEX_DAMAGE_TYPE_HEALTH ) and ( damagetype ~= DEX_DAMAGE_TYPE_INCOMING ) then return end

    local spellName = ""
    local iconTexture = nil
    if spellId and spellId > 0 then
        local name, rank = GetSpellNameAndRankForId(spellId)
        if name then
            spellName = name
        end
        local iconId = GetSpellRecField(spellId, "spellIconID")
        if iconId then
            iconTexture = GetSpellIconTexture(iconId)
        end
    end

    if spellName == nil then spellName = "" end

    local color = {1,1,1};
    local colorSe = {1,1,1};

    if damagetype == DEX_DAMAGE_TYPE_HIT then
        if DEX_Get("DEX_ShowDamageNormal") ~= 1 then return;end
        color = DEX_Get("DEX_ColorNormal");
        colorSe = DEX_Get("DEX_ColorNormalSe");
    elseif damagetype == DEX_DAMAGE_TYPE_SPELL then
        if DEX_Get("DEX_ShowDamageSkill") ~= 1 then return;end
        color = DEX_Get("DEX_ColorSkill");
        colorSe = DEX_Get("DEX_ColorSkillSe");
    elseif damagetype == DEX_DAMAGE_TYPE_PERIODIC then
        if DEX_Get("DEX_ShowDamagePeriodic") ~= 1 then return;end
        color = DEX_Get("DEX_ColorPeriodic");
        colorSe = DEX_Get("DEX_ColorPeriodicSe");
    elseif damagetype == DEX_DAMAGE_TYPE_HEALTH then
        if DEX_Get("DEX_ShowDamageHealth") ~= 1 then return;end
        color = DEX_Get("DEX_ColorHealth");
        colorSe = DEX_Get("DEX_ColorHealthSe");
        if DEX_OverHeal and DEX_OverHeal > 0 then
            if DEX_Get("DEX_ShowOverHeal") == 1 then
                damage = (tonumber(damage) - DEX_OverHeal) .. " (" .. DEX_OverHeal .. ")";
            else
                damage = tonumber(damage) - DEX_OverHeal;
                if damage == 0 then return; end
            end
        end
    elseif damagetype == DEX_DAMAGE_TYPE_PET then
        if DEX_Get("DEX_ShowDamagePet") ~= 1 then return;end
        color = DEX_Get("DEX_ColorPet");
        colorSe = DEX_Get("DEX_ColorPetSe");
    elseif damagetype == DEX_DAMAGE_TYPE_HONOR then
        color = DEX_Get("DEX_ColorSpec");
        colorSe = DEX_Get("DEX_ColorSpecSe");
    elseif damagetype == DEX_DAMAGE_TYPE_MANA then
        color = DEX_Get("DEX_ColorMana");
        colorSe = DEX_Get("DEX_ColorManaSe");
    elseif damagetype == DEX_DAMAGE_TYPE_INCOMING then
        if DEX_Get("DEX_ShowIncomingDamage") ~= 1 then return;end
        color = DEX_Get("DEX_ColorIncoming");
        colorSe = DEX_Get("DEX_ColorIncomingSe");
        if tonumber(damage) then
            damage = "-" .. damage;
        end
    elseif damagetype == DEX_DAMAGE_TYPE_ENERGIZE and powerType then
        if powerType == 0 then
            color = {0.3, 0.6, 1};
            colorSe = {0, 0.2, 0.8};
        elseif powerType == 1 then
            color = {1, 0.3, 0.3};
            colorSe = {0.8, 0, 0};
        elseif powerType == 2 then
            color = {0.8, 0.5, 0.2};
            colorSe = {0.6, 0.3, 0.1};
        elseif powerType == 3 then
            color = {1, 1, 0.2};
            colorSe = {0.8, 0.8, 0};
        elseif powerType == 4 then
            color = {1, 0.5, 1};
            colorSe = {0.8, 0.3, 0.8};
        else
            color = {1, 1, 1};
            colorSe = {0.8, 0.8, 0.8};
        end
    end

    local isAOE = false;
    if aoeList and spellName ~= "" then
        isAOE = aoeList[spellName]
    end

    -- Log 模式处理
    if DEX_Get("DEX_ShowWithMess") == 1 then
        local anitmp;
        if crit == 1 then damage = DEX_TXT_CRIT..damage; end

        -- 将所有现有日志行向上移动（图标自动跟随）
        for i = 1, DEX_logLine do
            anitmp = dex_AniData["aniText"..i];
            anitmp.posY = anitmp.posY + DEX_Get("DEX_FontSize");
            anitmp.FObject:SetPoint("CENTER", "UIParent", "CENTER", anitmp.posX + DEX_Get("DEX_PosX"), anitmp.posY + DEX_Get("DEX_PosY"));
            -- 图标锚定在文本上，无需单独移动
        end

        anitmp = dex_AniData["aniText"..dex_lastani];
        DEX_aniReset(anitmp);
        anitmp.starttime = GetTime();
        anitmp.Active = true;
        anitmp.posY = 0;
        anitmp.posX = 0;

        -- 构建文本
        local finalText = DEX_BuildText(damage, spellId, color, colorSe, damagetype, crit, isAOE);
        anitmp.FObject:SetText(finalText);
        anitmp.FObject:SetAlpha(1);
        anitmp.FObject:SetTextColor(color[1], color[2], color[3]);
        anitmp.FObject:SetPoint("CENTER", "UIParent", "CENTER", anitmp.posX + DEX_Get("DEX_PosX"), anitmp.posY + DEX_Get("DEX_PosY"));

        -- 图标处理
        if DEX_Get("DEX_ShowSpellIcon") == 1 and anitmp.IObject then
            local textureToSet = nil;
            if damagetype == DEX_DAMAGE_TYPE_PET and spellName == "" then
                textureToSet = "Interface\\Icons\\Ability_Hunter_Pet_Bear";
            elseif spellName ~= "" and iconTexture then
                textureToSet = iconTexture;
            end
            if textureToSet then
                anitmp.IObject:SetTexture(textureToSet);
                local iconSize = DEX_Get("DEX_FontSize") or DEX_TEXTSIZE;
                anitmp.IObject:SetWidth(iconSize);
                anitmp.IObject:SetHeight(iconSize);
                anitmp.IObject:SetAlpha(1);
                -- 将图标锚定到文本的左侧（偏移-5像素）
                anitmp.IObject:ClearAllPoints();
                anitmp.IObject:SetPoint("RIGHT", anitmp.FObject, "LEFT", -5, 0);
                anitmp.IObject:Show();
            else
                anitmp.IObject:Hide();
            end
        elseif anitmp.IObject then
            anitmp.IObject:Hide();
        end

        dex_lastani = dex_lastani + 1;
        if dex_lastani > DEX_logLine then dex_lastani = 1; end
        return;
    end

    local ani = dex_AniData["aniText"..dex_lastani];
    DEX_aniReset(ani);
    ani.Active = true;
    ani.height = DEX_Get("DEX_FontSize") or DEX_TEXTSIZE;
    ani.crit = crit;
    ani.isIncoming = (damagetype == DEX_DAMAGE_TYPE_INCOMING);

    if damagetype == DEX_DAMAGE_TYPE_ENERGIZE then
        ani.trajectory = DEX_Get("DEX_TrajectoryEnergize") or DEX_TRAJECTORY_VERTICAL_DOWN;
        ani.isIncoming = true;
    elseif ani.isIncoming then
        ani.trajectory = DEX_Get("DEX_TrajectoryIncoming") or DEX_TRAJECTORY_VERTICAL;
    else
        ani.trajectory = DEX_Get("DEX_TrajectoryOutgoing") or DEX_TRAJECTORY_VERTICAL;
    end

    local sideDirType = DEX_Get("DEX_TrajectorySideDir") or 1;
    local curDir = 1;
    if sideDirType == 1 then
        DEX_TRAJECTORY_DIRECTION = DEX_TRAJECTORY_DIRECTION * -1;
        curDir = DEX_TRAJECTORY_DIRECTION;
    elseif sideDirType == 2 then
        if damagetype == DEX_DAMAGE_TYPE_HONOR then curDir = 1 else curDir = -1 end
    elseif sideDirType == 3 then
        if damagetype == DEX_DAMAGE_TYPE_HONOR then curDir = -1 else curDir = 1 end
    elseif sideDirType == 4 then
        curDir = -1;
    elseif sideDirType == 5 then
        curDir = 1;
    end
    ani.sideDir = curDir;

    if ani.trajectory == DEX_TRAJECTORY_RAINBOW then
        ani.addY = random(3, 6);
        ani.posX = ani.posX - (20 * ani.sideDir);
    elseif ani.trajectory == DEX_TRAJECTORY_HORIZONTAL then
        ani.posX = ani.posX - (55 * ani.sideDir);
        ani.addX = DEX_Get("DEX_Speed") / 50;
    elseif ani.trajectory == DEX_TRAJECTORY_ANGLED_DOWN then
        ani.posX = ani.posX - (20 * ani.sideDir);
        ani.addY = random(8, 13);
        ani.addX = random(8, 13);
    elseif ani.trajectory == DEX_TRAJECTORY_ANGLED_UP then
        ani.posX = ani.posX - (20 * ani.sideDir);
        ani.addY = random(10, 15);
        ani.addX = random(10, 15);
    elseif ani.trajectory == DEX_TRAJECTORY_SPRINKLER then
        ani.addX = DEX_SPRINKLER;
        ani.addY = math.sqrt((DEX_SPRINKLER_RADIUS ^ 2) - math.abs((DEX_SPRINKLER ^ 2)));
        if ani.isIncoming then
            ani.addY = ani.addY * -1;
        end
        DEX_SPRINKLER = DEX_SPRINKLER + DEX_SPRINKLER_STEP;
        if DEX_SPRINKLER < (DEX_SPRINKLER_START * -1) then
            DEX_SPRINKLER = DEX_SPRINKLER_START;
        end
    end

    local resolvedName = unitName
    local resolvedGUID = guid
    if (not resolvedName or not resolvedGUID) then
        local recentName, recentGUID = DEX_GetRecentEventUnit()
        if not resolvedName then resolvedName = recentName end
        if not resolvedGUID then resolvedGUID = recentGUID end
    end
    ani.eventUnitName = resolvedName
    ani.eventGUID = resolvedGUID
    DEX_ANI_UID = DEX_ANI_UID + 1;

    ani.attachedPlate = nil
    if DEX_ShouldAttachToPlate(damagetype) then
        local plate = DEX_GetAttachNameplate(resolvedGUID, resolvedName)
        if plate and plate:IsVisible() then
            DEX_AttachAnimationToPlate(ani, plate)
        end
    end

    if damagetype == DEX_DAMAGE_TYPE_PET then
        local fontSize = DEX_Get("DEX_FontSize") or DEX_TEXTSIZE;
        ani.posX = ani.posX - fontSize * 2.5;
    end

    if DEX_IsUpwardAni(ani) then    -- 向上动画防重叠
        if dex_bottom - ani.baseY < ani.height + 6 then         
            local fixY = ani.height + 6 + ani.baseY - dex_bottom;
            local anitmp;
            for i = 1, DEX_MAXANI do
                anitmp = dex_AniData["aniText"..i];
                if i ~= dex_lastani and anitmp.Active and DEX_IsUpwardAni(anitmp) then
                    anitmp.baseY = anitmp.baseY + fixY;
                end
            end
        end
    elseif DEX_IsDownwardAni(ani) then    -- 向下动画防重叠
        -- 计算当前所有活跃向下动画的最高顶部位置
        local maxTop = -99999;
        for i = 1, DEX_MAXANI do
            local anitmp = dex_AniData["aniText"..i];
            if i ~= dex_lastani and anitmp.Active and DEX_IsDownwardAni(anitmp) then
                local top = anitmp.posY + anitmp.height;
                if top > maxTop then maxTop = top; end
            end
        end
        if maxTop > -99999 then
            local newTop = ani.baseY + ani.height;
            -- 如果新动画的顶部与当前最高顶部过近，则需要下移现有动画
            if maxTop - newTop < ani.height + 6 then
                local fixY = ani.height + 6 + maxTop - newTop;
                for i = 1, DEX_MAXANI do
                    local anitmp = dex_AniData["aniText"..i];
                    if i ~= dex_lastani and anitmp.Active and DEX_IsDownwardAni(anitmp) then
                        anitmp.baseY = anitmp.baseY - fixY;  -- 下移（减小 baseY）
                    end
                end
            end
        end
    end

    if crit == 1 then      
        ani.zoom = 1.5;

        if DEX_Get("DEX_ShowSpellName") ~= 1 or DEX_Get("DEX_ShowNameOnCrit") ~= 1 or spellName == "" then
            ani.critTyp = 1;
        end

        if damagetype ~= DEX_DAMAGE_TYPE_PET and damagetype ~= DEX_DAMAGE_TYPE_INCOMING then
            ani.critId = DEX_critFlag;
            DEX_critFlag = DEX_critFlag + 1;     
            if DEX_critFlag > 3 then DEX_critFlag = 0;end

            ani.posYbak = ani.posY;
        elseif damagetype == DEX_DAMAGE_TYPE_INCOMING then
            ani.moveTyp = DEX_MOVTYP_NONE;
            ani.posYbak = ani.posY;
        end
    end

    if (crit == 1 and damagetype ~= DEX_DAMAGE_TYPE_PET and damagetype ~= DEX_DAMAGE_TYPE_INCOMING) or damagetype == DEX_DAMAGE_TYPE_HONOR then
        -- 扩大随机范围
        ani.posX = random(-200, 200);
        ani.posY = random(-200, 150);

        local fontSize = DEX_Get("DEX_FontSize") or DEX_TEXTSIZE;
        local minSpacing = fontSize * 2.5;          -- 增大间距
        local maxAttempts = 40;                      -- 增加尝试次数
        local foundGoodPosition = false;
        local attempt = 0;

        while attempt < maxAttempts and not foundGoodPosition do
            foundGoodPosition = true;
            for i = 1, DEX_MAXANI do
                local anitmp = dex_AniData["aniText" .. i];
                if i ~= dex_lastani and anitmp.Active and anitmp.moveTyp == DEX_MOVTYP_NONE and anitmp.crit == 1 then
                    local dx = ani.posX - anitmp.posX;
                    local dy = ani.posY - anitmp.posY;
                    local distance = math.sqrt(dx * dx + dy * dy);
                    if distance < minSpacing then
                        foundGoodPosition = false;
                        if distance > 0 then
                            -- 沿远离方向推开
                            ani.posX = ani.posX + (dx / distance) * minSpacing;
                            ani.posY = ani.posY + (dy / distance) * minSpacing;
                        else
                            -- 完全重合时随机偏移
                            ani.posX = ani.posX + random(-minSpacing, minSpacing);
                            ani.posY = ani.posY + random(-minSpacing, minSpacing);
                        end
                        break;
                    end
                end
            end
            attempt = attempt + 1;
        end

        if not foundGoodPosition then
            -- 改进后备方案：半径范围更大，角度更分散
            local angle = math.mod(dex_lastani * 45, 360);
            local radius = 70 + math.mod(dex_lastani, 6) * 30;  -- 半径 70~220
            ani.posX = radius * cos(angle);
            ani.posY = radius * sin(angle);
        end

        ani.posYbak = ani.posY;
        ani.moveTyp = DEX_MOVTYP_NONE;
    elseif crit == 1 and damagetype == DEX_DAMAGE_TYPE_INCOMING then
        -- 扩大随机范围
        ani.posX = random(-200, 200);
        ani.posY = random(-200, 120);

        local fontSize = DEX_Get("DEX_FontSize") or DEX_TEXTSIZE;
        local minSpacing = fontSize * 2.5;
        local maxAttempts = 40;
        local foundGoodPosition = false;
        local attempt = 0;

        while attempt < maxAttempts and not foundGoodPosition do
            foundGoodPosition = true;
            for i = 1, DEX_MAXANI do
                local anitmp = dex_AniData["aniText" .. i];
                if i ~= dex_lastani and anitmp.Active and anitmp.isIncoming and anitmp.crit == 1 then
                    local dx = ani.posX - anitmp.posX;
                    local dy = ani.posY - anitmp.posY;
                    local distance = math.sqrt(dx * dx + dy * dy);
                    if distance < minSpacing then
                        foundGoodPosition = false;
                        if distance > 0 then
                            ani.posX = ani.posX + (dx / distance) * minSpacing;
                            ani.posY = ani.posY + (dy / distance) * minSpacing;
                        else
                            ani.posX = ani.posX + random(-minSpacing, minSpacing);
                            ani.posY = ani.posY + random(-minSpacing, minSpacing);
                        end
                        break;
                    end
                end
            end
            attempt = attempt + 1;
        end

        if not foundGoodPosition then
            local angle = math.mod(dex_lastani * 45, 360);
            local radius = 70 + math.mod(dex_lastani, 6) * 30;
            ani.posX = radius * cos(angle);
            ani.posY = radius * sin(angle);
        end

        ani.posYbak = ani.posY;
        ani.moveTyp = DEX_MOVTYP_NONE;
    end

    if damagetype == DEX_DAMAGE_TYPE_HONOR then
        ani.critTyp = 1
        ani.zoom = 1.35;
        ani.moveTyp = DEX_MOVTYP_NONE;
    end

    ani.starttime = GetTime();
    if isAOE and crit == 0 and DEX_Get("DEX_EnableAOEStandalone") == 1 then
        -- 只有开启独立显示且非暴击时才走 AOE 特殊动画
        ani.moveTyp = DEX_MOVTYP_AOE;

        if DEX_aoeNew == 1 then DEX_AoeReset(); end

        if GetTime() - DEX_aoeStartTimer >= 0.7 then DEX_AoeReset(); end
        ani.posY = 30;
        local fontSize = DEX_Get("DEX_FontSize") or DEX_TEXTSIZE;
        if DEX_aoeDct == 0 then
            ani.posX = -fontSize * 2 * DEX_aoeId - 20;
        else
            ani.posX = fontSize * 2 * DEX_aoeId + 20;
        end
        ani.starttime = GetTime() + DEX_aoeId * 0.05;

        DEX_aoeDct = DEX_aoeDct + 1;
        if DEX_aoeDct >= 2 then
            DEX_aoeId = DEX_aoeId + 1;
            DEX_aoeDct = 0;
        end
    end

    ani.damageText = damage;
    ani.spellName = spellName;

    -- 图标处理
    if DEX_Get("DEX_ShowSpellIcon") == 1 and ani.IObject then
        if damagetype == DEX_DAMAGE_TYPE_PET and spellName == "" then
            ani.IObject:SetTexture("Interface\\Icons\\Ability_Hunter_Pet_Bear")
            ani.IObject:Show()
            ani.showIcon = true
        elseif spellName ~= "" and iconTexture then
            ani.IObject:SetTexture(iconTexture)
            ani.IObject:Show()
            ani.showIcon = true
        else
            ani.IObject:Hide()
            ani.showIcon = false
        end
    elseif ani.IObject then
        ani.IObject:Hide()
        ani.showIcon = false
    end

    -- 构建最终文本
    ani.FObject:SetText(DEX_BuildText(damage, spellId, color, colorSe, damagetype, crit, isAOE))

    DEX_RefressBottom(ani);
    ani.FObject:SetTextColor(color[1], color[2], color[3]);
    if ani.attachedPlate then
        local attachOffsetX = (DEX_Get("DEX_NameplateOffsetX") or 0) + ani.posX
        local attachOffsetY = (DEX_Get("DEX_NameplateOffsetY") or 0) + ani.posY
        ani.FObject:SetPoint("CENTER", ani.attachedPlate, "CENTER", attachOffsetX, attachOffsetY)
    else
        ani.FObject:SetPoint("CENTER", "UIParent", "CENTER", ani.posX + DEX_Get("DEX_PosX"), ani.posY + DEX_Get("DEX_PosY"));
    end
    ani.FObject:SetAlpha(ani.alpha);

    dex_lastani = dex_lastani + 1;
    if dex_lastani > DEX_MAXANI then dex_lastani = tonumber(DEX_Get("DEX_LOGLINE")) * tonumber(DEX_Get("DEX_ShowWithMess")) + 1;end
end

-- 重置 AOE 计数器
function DEX_AoeReset()
    DEX_aoeNew = 0;
    DEX_aoeId = 1;
    DEX_aoeDct = 0;
    DEX_aoeStartTimer = GetTime();  
end

-- 初始化动画字体
function DEX_aniInit()
    local FontNumber;
    local FontSize;
    FontNumber = DEX_Get("DEX_Font");
    FontSize = DEX_Get("DEX_FontSize");
    dex_lastani = 1;

    if FontNumber >= 1 and FontNumber <= 3 then
        DEX_FONTNAME = DEX_FontList[FontNumber];
    else
        DEX_FONTNAME = DEX_FontList[1];
    end

    DEX_TEXTSIZE = DEX_Get("DEX_FontSize");

    for key, value in pairs(dex_AniData) do
        value.FObject = getglobal("DEX"..key);
        local iconName = string.gsub(key, "Text", "Icon")
        value.IObject = getglobal("DEX"..iconName);

        if value.FObject then
            local outlineIndex = DEX_Get("DEX_OutLine") or 3
            local fontEffect = DEX_FONTEFF[outlineIndex]
            value.FObject:SetTextHeight(DEX_TEXTSIZE);
            value.FObject:SetFont(DEX_FONTNAME, DEX_TEXTSIZE, fontEffect.ol);
            if fontEffect.shadowOff > 0 then
                value.FObject:SetShadowOffset(fontEffect.shadowOff, -fontEffect.shadowOff);
                value.FObject:SetShadowColor(0, 0, 0, 1);
            end
            value.FObject:SetTextColor(1, 1, 1);
        end

        if value.IObject then
            local iconSize = DEX_Get("DEX_FontSize") or DEX_TEXTSIZE;
            value.IObject:SetWidth(iconSize);
            value.IObject:SetHeight(iconSize);
            value.IObject:Hide();
        end

        DEX_aniReset(value);
    end
    DEX_Set_WOWDamage();
end

function DEX_staticInit()
    DEX_logLine = DEX_Get("DEX_LOGLINE");
    DEX_logTime = DEX_Get("DEX_LOGTIME");
end

-- 统一设置字体大小
function DEX_SetFontSize(ani,size)
    if not ani.FObject then return; end
    local outlineIndex = DEX_Get("DEX_OutLine") or 3
    local fontEffect = DEX_FONTEFF[outlineIndex]

    ani.FObject:SetTextHeight(size);
    ani.FObject:SetFont(DEX_FONTNAME, size, fontEffect.ol);

    if fontEffect.shadowOff > 0 then
        ani.FObject:SetShadowOffset(fontEffect.shadowOff, -fontEffect.shadowOff);
        ani.FObject:SetShadowColor(0, 0, 0, 1);
    end
end

-- 重置动画槽
function DEX_aniReset(aniData)    
    aniData.Active = false;
    aniData.crit = false;
    aniData.moveTyp = DEX_MOVTYP_NORMAL;
    aniData.critId = 0;
    aniData.critTyp = 0;
    aniData.posY = 0;
    aniData.posX = 0;
    aniData.zoom = 0;
    aniData.baseY = 0;
    aniData.alpha = 0;
    aniData.height = DEX_Get("DEX_FontSize") or DEX_TEXTSIZE;
    aniData.delay = 0;
    aniData.spellName = "";
    aniData.isIncoming = false;
    aniData.eventUnitName = nil
    aniData.eventGUID = nil
    aniData.starttime = 0;
    aniData.trajectory = 1;
    aniData.sideDir = 1;
    aniData.addX = 0;
    aniData.addY = 0;

    if aniData.FObject then
        DEX_SetFontSize(aniData,aniData.height);
        aniData.FObject:SetAlpha(aniData.alpha);
        aniData.FObject:SetPoint("CENTER", "UIParent", "CENTER", aniData.posX, aniData.posY);
    end

    if aniData.IObject then
        aniData.IObject:Hide();
        aniData.IObject:SetAlpha(0);
    end
    aniData.attachedPlate = nil
end

-- 设置是否显示系统默认伤害
function DEX_Set_WOWDamage()
    if (DEX_Get("DEX_ShowDamageWoW") == 0) then
        SetCVar("CombatDamage", 0);
    else
        SetCVar("CombatDamage", 1);
    end
end

-- 数字格式化（万/亿）
function amount_format(num)
    local strReturn = ""
    local str = tostring(num)
    local strLen = string.len(str)

    if strLen > 0 then
        local number = tonumber(num)
        if number then
            if number < 9999 then
                strReturn = number
            elseif number < 99999999 then
                strReturn = string.format("%.1f万", number / 10000)
            elseif number < 99999999999 then
                strReturn = string.format("%.2f亿", number / 100000000)
            end
        else
            strReturn = num
        end
    end
    return strReturn
end

------------------------------------
-- 小地图按钮功能
------------------------------------

local DEX_MinimapButton = nil;

-- 创建小地图按钮
local function DEX_CreateMinimapButton()
    if DEX_MinimapButton then return DEX_MinimapButton; end

    local button = CreateFrame("Button", "DEX_MinimapButton", Minimap);
    button:SetWidth(32);
    button:SetHeight(32);
    button:SetFrameStrata("MEDIUM");
    button:SetFrameLevel(8);
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight");

    local icon = button:CreateTexture(nil, "BACKGROUND");
    icon:SetWidth(20);
    icon:SetHeight(20);
    icon:SetPoint("CENTER", button, "CENTER", 0, 1);
    icon:SetTexture("Interface\\Icons\\Spell_Fire_SelfDestruct");
    button.icon = icon;

    local overlay = button:CreateTexture(nil, "OVERLAY");
    overlay:SetWidth(53);
    overlay:SetHeight(53);
    overlay:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0);
    overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder");

    button:SetMovable(true);
    button:EnableMouse(true);
    button:RegisterForDrag("LeftButton");
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp");

    local function UpdatePosition()
        local angle = DEX_Get("DEX_MinimapAngle") or 220;
        local x = 80 * cos(angle);
        local y = 80 * sin(angle);
        button:SetPoint("CENTER", Minimap, "CENTER", x, y);
    end

    button:SetScript("OnDragStart", function()
        this:LockHighlight();
        this:SetScript("OnUpdate", function()
            local mx, my = Minimap:GetCenter();
            local px, py = GetCursorPosition();
            local scale = Minimap:GetEffectiveScale();
            px, py = px / scale, py / scale;

            local angle = math.deg(math.atan2(py - my, px - mx));
            DEX_Set("DEX_MinimapAngle", angle);
            UpdatePosition();
        end);
    end);

    button:SetScript("OnDragStop", function()
        this:SetScript("OnUpdate", nil);
        this:UnlockHighlight();
    end);

    button:SetScript("OnClick", function()
        if arg1 == "LeftButton" then
            DEX_showMenu();
        elseif arg1 == "RightButton" then
            if DEX_Get("DEX_Enable") == 1 then
                DEX_Set("DEX_Enable", 0);
                DEX_Debug(DEX_LANG_MINIMAP_TOOLTIP.DEX_DISABLE);
            else
                DEX_Set("DEX_Enable", 1);
                DEX_Debug(DEX_LANG_MINIMAP_TOOLTIP.DEX_ENABLE);
            end
        end
    end);

    button:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_LEFT");
        GameTooltip:AddLine(DEX_LANG_MINIMAP_TOOLTIP.TITLE, 1, 1, 1);
        GameTooltip:AddLine(" ");
        GameTooltip:AddLine(DEX_LANG_MINIMAP_TOOLTIP.LEFT_CLICK, 0.2, 1, 0.2);
        GameTooltip:AddLine(DEX_LANG_MINIMAP_TOOLTIP.RIGHT_CLICK, 0.2, 1, 0.2);
        GameTooltip:AddLine(DEX_LANG_MINIMAP_TOOLTIP.DRAG, 0.2, 1, 0.2);
        GameTooltip:AddLine(" ");
        if DEX_Get("DEX_Enable") == 1 then
            GameTooltip:AddLine(DEX_LANG_MINIMAP_TOOLTIP.STATUS_ENABLED);
        else
            GameTooltip:AddLine(DEX_LANG_MINIMAP_TOOLTIP.STATUS_DISABLED);
        end
        GameTooltip:Show();
    end);

    button:SetScript("OnLeave", function()
        GameTooltip:Hide();
    end);

    UpdatePosition();
    button:Show();

    DEX_MinimapButton = button;
    return button;
end

-- 初始化小地图按钮
function DEX_InitMinimapButton()
    if DEX_Get("DEX_ShowMinimapButton") == nil then
        DEX_Set("DEX_ShowMinimapButton", 1);
    end

    if DEX_Get("DEX_ShowMinimapButton") == 1 then
        DEX_CreateMinimapButton();
    end
end