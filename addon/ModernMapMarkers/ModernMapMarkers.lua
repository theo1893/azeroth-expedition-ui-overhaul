-- Marker data: { continent, zoneID, x, y, name, type, info, Atlas ID }
local points = {
    -- 卡利姆多副本
    {1, 20, 0.123, 0.128, "黑暗深渊", "小副本", "24-32", 3},
    {1, 8, 0.66, 0.49, "黑色沼泽", "小副本", "60", 12},
    {1, 20, 0.51, 0.78, "新月林地", "小副本", "32-38", 5},
    {1, 25, 0.648, 0.303, "厄运之槌 - 东", "小副本", "55-58", 9},
    {1, 25, 0.624, 0.249, "厄运之槌 - 北", "小副本", "57-60", 10},
    {1, 25, 0.604, 0.311, "厄运之槌 - 西", "小副本", "57-60", 11},
    {1, 4, 0.29, 0.629, "玛拉顿", "小副本", "46-55", 8},
    {1, 9, 0.53, 0.486, "怒焰裂谷", "小副本", "13-18", 1},
    {1, 26, 0.491, 0.896, "剃刀高地", "小副本", "37-46", 6},
    {1, 26, 0.431, 0.863, "剃刀沼泽", "小副本", "29-38", 4},
    {1, 26, 0.472, 0.327, "哀嚎洞穴", "小副本", "17-24", 2},
    {1, 8, 0.389, 0.184, "祖尔法拉克", "小副本", "44-54", 7},
	-- 卡利姆多团队副本
	{1, 19, 0.207, 0.592, "翡翠圣殿", "团队副本", "60", 13},
	{1, 12, 0.53, 0.76, "奥妮克希亚的巢穴", "团队副本", "60", 14},
	{1, 13, 0.296, 0.960, "安其拉废墟", "团队副本", "60", 15},
	{1, 13, 0.282, 0.956, "安其拉神殿", "团队副本", "60", 16},
	-- 卡利姆多世界BOSS
	{1, 23, 0.535, 0.816, "艾索雷葛斯", "世界BOSS", "60", 1},
	{1, 23, 0.69, 0.094, "克拉科拉", "世界BOSS", "60", nil},
	{1, 4, 0.82, 0.80, "空卡维斯", "世界BOSS", "60", 8},
	{1, 19, 0.336, 0.398, "人狼神父", "世界BOSS", "60", nil}, -- maybe coords need tweaking
	{1, 8, 0.361, 0.762, "奥兹塔里亚斯", "世界BOSS", "60", 7},
	{1, 20, 0.937, 0.355, "翡翠巨龙 - 1/4刷新点", "世界BOSS", "60", 2},
	{1, 25, 0.512, 0.108, "翡翠巨龙 - 2/4刷新点", "世界BOSS", "60", 2},
    -- 卡利姆多交通
    {1, 16, 0.512, 0.135, "飞艇：开往幽暗城 & 格罗姆高", "飞艇", "部落", nil},  -- horde
    {1, 16, 0.413, 0.174, "飞艇：开往雷霆崖 & 卡加斯", "飞艇", "部落", nil},   -- horde
    {1, 29, 0.165, 0.230, "飞艇：开往奥格瑞玛", "飞艇", "部落", nil},  -- horde
    {1, 16, 0.598, 0.236, "船：开往恶齿村", "船", "部落", nil},  -- horde
    {1, 26, 0.636, 0.389, "船：开往藏宝海湾", "船", "联盟/部落", nil},  -- neutral
	{1, 30, 0.324, 0.44, "船：开往暴风城", "船", "联盟", nil}, -- alliance
	{1, 30, 0.304, 0.41, "船：开往阿拉索尔", "船", "联盟", nil},  -- alliance
	{1, 30, 0.333, 0.399, "船：开往鲁瑟兰村", "船", "联盟", nil}, -- alliance
	{1, 12, 0.718, 0.566, "船：开往米奈希尔港", "船", "联盟", nil}, -- alliance
	{1, 25, 0.311, 0.395, "船：开往被遗忘的海岸", "船", "联盟", nil}, -- alliance
	{1, 25, 0.431, 0.428, "船：开往羽月要塞", "船", "联盟", nil}, -- alliance
	{1, 18, 0.552, 0.949, "船：开往奥伯丁", "船", "联盟", nil}, -- alliance
    -- 东部王国副本
    {2, 21, 0.371, 0.857, "黑石深渊", "小副本", "52-60", 13},
	{2, 22, 0.328, 0.362, "黑石深渊", "小副本", "52-60", 13},
    {2, 29, 0.41, 0.68, "死亡矿井", "小副本", "17-24", 1},
    {2, 7, 0.30, 0.27, "吉尔尼斯城", "小副本", "43", 10},
    {2, 3, 0.248, 0.337, "诺莫瑞根", "小副本", "29-38", 6},
    {2, 22, 0.95, 0.53, "仇恨熔炉采石场", "小副本", "52-60", 11},
    {2, 34, 0.45, 0.75, "卡拉赞墓穴", "小副本", "58-60", 15},
    {2, 22, 0.321, 0.386, "黑石塔下层", "小副本", "55-60", 14},
	{2, 21, 0.364, 0.879, "黑石塔下层", "小副本", "55-60", 14},
    {2, 15, 0.869, 0.323, "血色修道院 - 军械库", "小副本", "32-42", 7}, 
    {2, 15, 0.862, 0.295, "血色修道院 - 大教堂", "小副本", "35-45", 8}, 
    {2, 15, 0.839, 0.283, "血色修道院 - 墓地", "小副本", "26-36", 4},
    {2, 15, 0.850, 0.338, "血色修道院 - 图书馆", "小副本", "29-39", 5},  -- atlasID for Armory, Cath, GY and Lib are 13, 14, 15
    {2, 28, 0.69, 0.74, "通灵学院", "小副本", "58-60", 16},
    {2, 36, 0.44, 0.67, "影牙城堡", "小副本", "22-30", 2},
    {2, 17, 0.51, 0.675, "监狱", "小副本", "24-31", 3},
    {2, 17, 0.63, 0.58, "暴风城地牢", "小副本", "60", 19},
    {2, 23, 0.29, 0.61, "暴风城地牢 - 部落入口", "小副本", "60", 19},
    {2, 1, 0.31, 0.14, "斯坦索姆", "小副本", "58-60", 16},
    {2, 1, 0.47, 0.24, "斯坦索姆 - 后门", "小副本", "58-60", 16},
    {2, 13, 0.69, 0.55, "沉没的神庙", "小副本", "50-60", 12},
    {2, 25, 0.429, 0.130, "奥达曼 - 主入口", "小副本", "41-51", 9},
    {2, 25, 0.657, 0.438, "奥达曼 - 后门", "小副本", "41-51", 9},
    {2, 22, 0.312, 0.365, "黑石塔上层", "小副本", "55-60", 18},
	{2, 21, 0.355, 0.855, "黑石塔上层", "小副本", "55-60", 18},
	{2, 20, 0.67, 0.634, "龙喉居所", "小副本", "27-33", nil}, -- Atlas needs to update for atlasID
	{2, 10, 0.57, 0.598, "风暴废墟", "小副本", "35-41", nil}, -- Atlas needs to update for atlasID
	-- 东部王国团队副本
	{2, 21, 0.332, 0.851, "黑翼之巢", "团队副本", "60", 25},
	{2, 22, 0.273, 0.363, "黑翼之巢", "团队副本", "60", 25},
	{2, 34, 0.46, 0.70, "卡拉赞下层", "团队副本", "58-60", 20},
	{2, 21, 0.336, 0.879, "熔火之心", "团队副本", "60", 22},
	{2, 22, 0.273, 0.387, "熔火之心", "团队副本", "60", 22},
	{2, 1, 0.40, 0.28, "纳克萨玛斯", "团队副本", "60", 24},
	{2, 34, 0.442, 0.719, "卡拉赞之塔", "团队副本", "60", 21}, -- needs Atlas page
	{2, 24, 0.53, 0.18, "祖尔格拉布", "团队副本", "60", 23},
	-- 东部王国世界BOSS
	{2, 34, 0.471, 0.751, "卡拉赞黑暗掠夺者", "世界BOSS", "60", 6},
	{2, 16, 0.465, 0.357, "翡翠巨龙 - 3/4刷新点", "世界BOSS", "60", 2},
	{2, 33, 0.632, 0.217, "翡翠巨龙 - 4/4刷新点", "世界BOSS", "60", 2},
	{2, 30, 0.36, 0.753, "卡扎克", "世界BOSS", "60", 3},
	{2, 1, 0.082, 0.38, "蛛怪监工", "世界BOSS", "60", 5},
	-- 东部王国交通
	{2, 17, 0.694, 0.294, "地铁：开往铁炉堡", "地铁", "联盟", nil},  -- alliance
	{2, 35, 0.762, 0.511, "地铁：开往暴风城", "地铁", "联盟", nil},  -- alliance
	{2, 33, 0.812, 0.794, "船：开往怒水港（杜隆塔尔）", "船", "部落", nil}, -- horde
	{2, 20, 0.068, 0.613, "船：开往塞拉摩岛", "船", "联盟", nil},  -- alliance
	{2, 17, 0.218, 0.563, "船：开往奥伯丁", "船", "联盟", nil}, -- alliance
	{2, 24, 0.257, 0.73, "船：开往棘齿城", "船", "联盟/部落", nil}, -- neutral
	{2, 15, 0.616, 0.571, "飞艇：开往奥格瑞玛 & 格罗姆高", "飞艇", "部落", nil}, -- horde
	{2, 24, 0.312, 0.298, "飞艇：开往幽暗城 & 奥格瑞玛", "飞艇", "部落", nil}, -- Horde
	{2, 25, 0.075, 0.480, "飞艇：开往奥格瑞玛", "飞艇", "部落",  nil}, -- Horde
	{2, 37, 0.531, 0.047, "船：开往奥伯丁", "船", "联盟", nil}, -- alliance
}

-- keeping zoneIDs for reference and debugging only
kZoneNames = {GetMapZones(1)}
ekZoneNames = {GetMapZones(2)}
local firstLoad = true

local markers = {}
local debug = false

-- UI Elements will be initialized later
local config
local masterToggle
local dungeonRaidsToggle
local transportToggle
local worldBossToggle

local function print(string) 
    DEFAULT_CHAT_FRAME:AddMessage(string) 
end

-- Prevent the error `Interface\FrameXML\MoneyFrame.lua:185: attempt to perform arithmetic on local `money' (a nil value)`
-- Reference: https://github.com/veechs/Bagshui/blob/c70823167ae2581da7a777c073291805297cb0a2/Components/Bagshui.BlizzFixes.lua#L6
local oldMoneyFrame_UpdateMoney = MoneyFrame_UpdateMoney
function MoneyFrame_UpdateMoney()
    if this.moneyType == "STATIC" and this.staticMoney == nil then
        this.staticMoney = 0
    end
    oldMoneyFrame_UpdateMoney()
end

local function CreateMapPin(parent, x, y, size, texture, tooltipText, tooltipInfo, atlasID)
    if debug then
        print("Attempting to create map pin. X: " .. x .. " Y: " .. y .. " Size: ".. size .. " Texture: " .. texture .. " Tip Text: " .. tooltipText)
    end
    local pin = CreateFrame("Button", nil, parent)
    pin.texture = pin:CreateTexture(nil, "OVERLAY")
    pin:SetWidth(size)
    pin:SetHeight(size)
    pin:SetPoint("CENTER", parent, "TOPLEFT", x, -y) 
    pin.texture:SetAllPoints()
    pin.texture:SetTexture(texture)
    pin:SetFrameLevel(parent:GetFrameLevel() + 3)
    pin:Show()

    local MapTooltip
    pin:SetScript("OnEnter", function()
        WorldMapTooltip:SetOwner(pin, "ANCHOR_BOTTOMRIGHT", -15, 15)
        WorldMapTooltip:SetText(tooltipText, 1, 1 ,1)
        if tooltipInfo == "联盟" then
            WorldMapTooltip:AddLine(tooltipInfo, 0.145, 0.588, 0.745)
        elseif tooltipInfo == "部落" then
            WorldMapTooltip:AddLine(tooltipInfo, 0.89, 0.161, 0.102)
        elseif tooltipInfo == "联盟/部落" then
            WorldMapTooltip:AddLine(tooltipInfo, 1, 1, 0)    
        elseif tooltipInfo ~= "" then 
            WorldMapTooltip:AddLine("等级: " .. tooltipInfo, 1,1,0)
        end
        WorldMapTooltip:Show()
    end)

    pin:SetScript("OnLeave", function()
        WorldMapTooltip:Hide()
    end)

    pin:SetScript("OnClick", function() 
        if texture == "Interface\\Addons\\ModernMapMarkers\\Textures\\worldboss.tga" then
            if debug then
                print("Clicked on a world boss, can't do anything here")
                -- Atlas only has one world boss, Azuregos, so currently we do nothing if you click a world boss.
            end
            return
        end
        if debug then
            print("Tooltip was clicked")
            print("atlasID is: " .. atlasID)
        end
        
        if atlasID ~= nil then
            -- Check if Atlas is present
            if AtlasFrame then
                -- Atlas uses opposite continent IDs to the client so we need to switch them!
                local currentContinent
                currentContinent = GetCurrentMapContinent()
                if currentContinent == 1 then
                    AtlasOptions.AtlasType = 2 -- 1 is EK, 2 is Kalimdor
                elseif currentContinent == 2 then
                    AtlasOptions.AtlasType = 1 -- 1 is EK, 2 is Kalimdor
                end
                
                AtlasOptions.AtlasZone = atlasID
                Atlas_Refresh();
                AtlasFrame:SetFrameStrata("FULLSCREEN")
                AtlasFrame:Show()
                if AtlasQuestFrame then
                    --Automatically opens the Atlas Quest popout for the zone (mimics dungeon Journal in retail... kind of!)
                    AtlasQuestFrame:Show()
                end
            end
        end
    end)
    return pin
end

local function UpdateMarkers()
    if firstLoad == true then
        firstLoad = false
        return
    end

    -- do nothing if the option to draw pins is disabled
    if not ModernMapMarkersDB.showMarkers then
        -- status:SetText("Current Status is: |cFFFFFFFFFalse|r" )
        return
    end
    
    -- do nothing if the worldmap frame is not visible
    if not WorldMapFrame:IsVisible() then
        return
    end
    
    -- Make sure Atlas is installed
    if AtlasFrame and not Atlas_CheckAddonInstalled then
        if debug then
            print("Atlas is installed but missing required function Atlas_CheckAddonInstalled")
        end
    end

    local currentContinent = GetCurrentMapContinent()
    local currentZone = GetCurrentMapZone()

    if currentZone == 0 and currentContinent == 0 then
        -- When Continent and Zone ID is 0 We are looking at the zoomed out world map
        if debug then
            print("Zone and Continent index is 0 - Looking at World Map")
        end
    elseif currentZone == 0 then
        -- When Zone ID is 0 We are looking at the zoomed out map of a continent
        if debug then
            print("Looking at Continent Map")
        end
    end    
    
    -- Because these maps also have co-ordinates, we need to remove any drawn pins otherwise they will overlay these maps
    -- Destroy any entries in markers for pins relating to other zone / continent maps
    for _, pin in pairs(markers) do
        pin:Hide()
        pin = nil
    end
    markers = {} -- Clear the markers table

    local worldMap = WorldMapDetailFrame
    local mapWidth, mapHeight = worldMap:GetWidth(), worldMap:GetHeight()

    for i, data in pairs(points) do
        local isMatching = false
        local cont, zoneID, x, y, label, kind, info, atlasID = unpack(data)
        
        -- Check if this type of marker should be displayed based on settings
        local shouldDisplay = true
        
        if kind == "小副本" or kind == "团队副本" then
            shouldDisplay = ModernMapMarkersDB.showDungeonRaids
        elseif kind == "世界BOSS" then
            shouldDisplay = ModernMapMarkersDB.showWorldBosses
        elseif kind == "船" or kind == "飞艇" or kind == "地铁" then
            shouldDisplay = ModernMapMarkersDB.showTransport
        end
        
        if not shouldDisplay then
            -- Skip this marker if its type is disabled
            if debug then
                print("Skipping marker: " .. label .. " of type " .. kind .. " (disabled in settings)")
            end
            -- Skip to next iteration
            -- Lua 5.0 doesn't support goto, use alternative approach
        else
            if debug then
                print("Cont: " .. cont .. " Zone ID: " .. zoneID .. " X: " .. x .. " Y: " .. y .. " Label: " .. label .. " Kind: " .. kind)
                -- We are looking at Kalimdor or Eastern Kingdoms (not the world map)
                print("Current Zone ID is: " .. currentZone)
            end
            
            if currentZone == zoneID and currentContinent == cont then
                isMatching = true
                if debug then
                    print("Matched current continent " .. currentContinent .. " to pin data for zone: " .. label)
                    print("We are looking at a map for zone: " .. currentZone .. " which matches defined zone pin data:" ..
                          zoneID .. " for zone: " .. label)
                end
            end

            if isMatching then
                local size = 32
                local texture = "Interface\\Addons\\ModernMapMarkers\\Textures\\POIIcons.blp"
                
                if kind == "团队副本" then
                    texture = "Interface\\Addons\\ModernMapMarkers\\Textures\\raid.tga"
                elseif kind == "世界BOSS" then
                    texture = "Interface\\Addons\\ModernMapMarkers\\Textures\\worldboss.tga"
                elseif kind == "飞艇" then
                    texture = "Interface\\Addons\\ModernMapMarkers\\Textures\\zepp.tga"
                    size = 24
                elseif kind == "船" then
                    texture = "Interface\\Addons\\ModernMapMarkers\\Textures\\boat.tga"
                    size = 24
                elseif kind == "地铁" then
                    texture = "Interface\\Addons\\ModernMapMarkers\\Textures\\tram.tga"
                    size = 24
                else -- Dungeon
                    texture = "Interface\\Addons\\ModernMapMarkers\\Textures\\dungeon.tga"
                end

                local px, py = x * mapWidth, y * mapHeight
                local pin = CreateMapPin(worldMap, px, py, size, texture, label, info, atlasID)        

                markers[i] = pin -- Store the pin in the markers table
            end
        end
    end
end

local function CreateToggleCheckbox(parent, x, y, text, optionKey)
    local checkbox = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", x, y)
    checkbox:SetWidth(24)
    checkbox:SetHeight(24)
    
    local label = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
    label:SetText(text)
    
    checkbox:SetScript("OnClick", function()
        local isChecked = checkbox:GetChecked()
        if isChecked then
            ModernMapMarkersDB[optionKey] = true
        else
            ModernMapMarkersDB[optionKey] = false
        end
        
        if debug then
            print("Checkbox " .. text .. " is now set to: " .. tostring(ModernMapMarkersDB[optionKey]))
        end
        UpdateMarkers()
    end)
    
    return checkbox
end

local function UpdateCheckboxStates()
    -- This function updates all checkboxes to match the loaded saved variables
    if masterToggle then
        masterToggle:SetChecked(ModernMapMarkersDB.showMarkers)
    end
    if dungeonRaidsToggle then
        dungeonRaidsToggle:SetChecked(ModernMapMarkersDB.showDungeonRaids)
    end
    if transportToggle then
        transportToggle:SetChecked(ModernMapMarkersDB.showTransport)
    end
    if worldBossToggle then
        worldBossToggle:SetChecked(ModernMapMarkersDB.showWorldBosses)
    end
end

local function CreateConfigUI()
    config = CreateFrame("Frame", "MMMConfigFrame", UIParent)
    config:SetWidth(320)
    config:SetHeight(220)
    config:SetPoint("CENTER", UIParent, "CENTER")
	
	tinsert(UISpecialFrames, "MMMConfigFrame")
    config:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = {
            left = 11,
            right = 11,
            top = 11,
            bottom = 11
        }
    })
    config:SetMovable(true)
    config:EnableMouse(true)
    config:RegisterForDrag("LeftButton")
    config:SetScript("OnDragStart", function()
        this:StartMoving()
    end)
    config:SetScript("OnDragStop", function()
        this:StopMovingOrSizing()
    end)
    
    local title = config:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -15)
    title:SetText("乌龟服地图标记")

    -- Master toggle
    local masterLabel = config:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    masterLabel:SetPoint("TOPLEFT", 20, -45)
    masterLabel:SetText("开启地图标记:")

    masterToggle = CreateFrame("CheckButton", nil, config, "UICheckButtonTemplate")
    masterToggle:SetPoint("LEFT", masterLabel, "RIGHT", 5, 0)
    masterToggle:SetWidth(24)
    masterToggle:SetHeight(24)

    masterToggle:SetScript("OnClick", function()
        local isChecked = masterToggle:GetChecked()
        if isChecked then
            ModernMapMarkersDB.showMarkers = true
        else
            ModernMapMarkersDB.showMarkers = false
        end
        
        if ModernMapMarkersDB.showMarkers then
            if debug then
                print("Map Markers: Enabled")
            end
        else
            if debug then
                print("Map Markers: Disabled")
            end
            for _, pin in pairs(markers) do
                pin:Hide()
                pin = nil
            end
            markers = {} -- Clear the markers table
        end
        
        UpdateMarkers()
    end)

    -- Add category toggles
    dungeonRaidsToggle = CreateToggleCheckbox(config, 20, -75, "显示副本和团本", "showDungeonRaids")
    transportToggle = CreateToggleCheckbox(config, 20, -100, "显示交通（船，飞艇，地铁）", "showTransport")
    worldBossToggle = CreateToggleCheckbox(config, 20, -125, "显示世界BOSS", "showWorldBosses")

    local closeButton = CreateFrame("Button", nil, config, "UIPanelButtonTemplate")
    closeButton:SetWidth(80)
    closeButton:SetHeight(25)
    closeButton:SetPoint("BOTTOM", 0, 15)
    closeButton:SetText("关闭")
    closeButton:SetScript("OnClick", function()
        config:Hide()
    end)

    -- Hide the config window by default
    config:Hide()
end

local function InitializeSavedVariables()
    -- Initialize saved variables with defaults if they don't exist
    if not ModernMapMarkersDB then
        ModernMapMarkersDB = {
            showMarkers = true,
            showDungeonRaids = true,
            showTransport = true,
            showWorldBosses = true
        }
        if debug then
            print("Modern Map Markers: Created new saved variables with defaults")
        end
    else
        -- Ensure all settings exist (in case of addon updates)
        if ModernMapMarkersDB.showMarkers == nil then
            ModernMapMarkersDB.showMarkers = true
        end
        if ModernMapMarkersDB.showDungeonRaids == nil then
            ModernMapMarkersDB.showDungeonRaids = true
        end
        if ModernMapMarkersDB.showTransport == nil then
            ModernMapMarkersDB.showTransport = true
        end
        if ModernMapMarkersDB.showWorldBosses == nil then
            ModernMapMarkersDB.showWorldBosses = true
        end
    end
    
    if debug then
        print("Saved Variables Loaded:")
        print("  showMarkers: " .. tostring(ModernMapMarkersDB.showMarkers))
        print("  showDungeonRaids: " .. tostring(ModernMapMarkersDB.showDungeonRaids))
        print("  showTransport: " .. tostring(ModernMapMarkersDB.showTransport))
        print("  showWorldBosses: " .. tostring(ModernMapMarkersDB.showWorldBosses))
    end
end

-- Add a flag to track if we've already initialized
local initialized = false

-- Event(s) handling frame
local frame = CreateFrame("Frame")

frame:RegisterEvent("WORLD_MAP_UPDATE")
frame:RegisterEvent("VARIABLES_LOADED")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

frame:SetScript("OnEvent", function()
    if event == "ADDON_LOADED" and arg1 == "ModernMapMarkers" then
        -- Addon is loaded, create UI but don't initialize saved vars yet
        CreateConfigUI()
        if debug then
            print("Modern Map Markers: Addon Loaded, UI Created")
        end
    elseif event == "VARIABLES_LOADED" then
        -- This is when saved variables are actually available
        if not initialized then
            InitializeSavedVariables()
            UpdateCheckboxStates()
            initialized = true
            
            if debug then
                print("Modern Map Markers: Variables Loaded and Initialized")
            end
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Ensure everything is set up when entering world
        if not initialized then
            InitializeSavedVariables()
            if not config then
                CreateConfigUI()
            end
            UpdateCheckboxStates()
            initialized = true
        end
        -- Always update markers when entering world
        UpdateMarkers()
    elseif event == "WORLD_MAP_UPDATE" then
        if initialized then
            UpdateMarkers()
        end
    end
end)

local function CreateToggleCheckbox(parent, x, y, text, optionKey)
    local checkbox = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", x, y)
    checkbox:SetWidth(24)
    checkbox:SetHeight(24)
    
    local label = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
    label:SetText(text)
    
    checkbox:SetScript("OnClick", function()
        local isChecked = checkbox:GetChecked()
        if isChecked then
            ModernMapMarkersDB[optionKey] = true
        else
            ModernMapMarkersDB[optionKey] = false
        end
        
        if debug then
            print("Checkbox " .. text .. " is now set to: " .. tostring(ModernMapMarkersDB[optionKey]))
        end
        UpdateMarkers()
    end)
    
    return checkbox
end

-- Slash command handler
SLASH_MMM1 = "/mmm"
SlashCmdList["MMM"] = function()
    if MMMConfigFrame and MMMConfigFrame:IsVisible() then
        MMMConfigFrame:Hide()
    else
        MMMConfigFrame:Show()
    end
end

if debug then
    DEFAULT_CHAT_FRAME:AddMessage("Modern Map Markers: Initial Load Complete")
end
