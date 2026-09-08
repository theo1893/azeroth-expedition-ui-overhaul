if RunAway.disabled then return end

local settings = {}
local templates = RunAway.templates

-- Minimap button configuration
local minimapButtonAngle = 225  -- Default position (degrees)
local minimapButtonRadius = 80

-- Create minimap button
local minimapButton = CreateFrame("Button", "RunAwayMinimapButton", Minimap)
minimapButton:SetWidth(31)
minimapButton:SetHeight(31)
minimapButton:SetFrameStrata("MEDIUM")
minimapButton:SetFrameLevel(8)
minimapButton:EnableMouse(true)
minimapButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
minimapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

-- Icon texture (centered and properly sized for circular mask)
local icon = minimapButton:CreateTexture(nil, "BACKGROUND")
icon:SetTexture("Interface\\Icons\\Ability_Rogue_Sprint")
icon:SetWidth(20)
icon:SetHeight(20)
icon:SetPoint("CENTER", minimapButton, "CENTER", 0, 0)
icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
minimapButton.icon = icon

-- Border overlay (standard minimap tracking button style)
local border = minimapButton:CreateTexture(nil, "OVERLAY")
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
border:SetWidth(54)
border:SetHeight(54)
border:SetPoint("TOPLEFT", minimapButton, "TOPLEFT", -2, 2)
minimapButton.border = border

-- Pushed texture effect
minimapButton:SetScript("OnMouseDown", function()
  if arg1 == "LeftButton" and not this.dragging then
    this.icon:ClearAllPoints()
    this.icon:SetPoint("CENTER", this, "CENTER", 1, -1)
  end
end)

minimapButton:SetScript("OnMouseUp", function()
  this.icon:ClearAllPoints()
  this.icon:SetPoint("CENTER", this, "CENTER", 0, 0)
end)

-- Position the button around minimap
local function UpdateMinimapButtonPosition()
  local angle = math.rad(minimapButtonAngle)
  local x = math.cos(angle) * minimapButtonRadius
  local y = math.sin(angle) * minimapButtonRadius
  minimapButton:ClearAllPoints()
  minimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

-- Dragging support for minimap button
minimapButton:RegisterForDrag("LeftButton")
minimapButton:SetScript("OnDragStart", function()
  this.dragging = true
end)

minimapButton:SetScript("OnDragStop", function()
  this.dragging = false
end)

minimapButton:SetScript("OnUpdate", function()
  if not this.dragging then return end

  local mx, my = Minimap:GetCenter()
  local cx, cy = GetCursorPosition()
  local scale = UIParent:GetEffectiveScale()
  cx, cy = cx / scale, cy / scale

  minimapButtonAngle = math.deg(math.atan2(cy - my, cx - mx))
  UpdateMinimapButtonPosition()
end)

-- Tooltip
minimapButton:SetScript("OnEnter", function()
  GameTooltip:SetOwner(this, "ANCHOR_LEFT")
  GameTooltip:AddLine("|cffffcc00快|cffffffff跑！")
  GameTooltip:AddLine("|cffffffff左键:|r 打开设置菜单", 1, 1, 1)
  GameTooltip:AddLine("|cffffffff拖拽:|r 移动按钮", 1, 1, 1)
  if RunAway_db.enabled then
    GameTooltip:AddLine("|cff00ff00已启用|r", 1, 1, 1)
  else
    GameTooltip:AddLine("|cffff0000已禁用|r", 1, 1, 1)
  end
  GameTooltip:Show()
end)

minimapButton:SetScript("OnLeave", function()
  GameTooltip:Hide()
end)

UpdateMinimapButtonPosition()

-- Dropdown menu system
local dropdownFrames = {}
local currentLevel = 0

-- Prettier dropdown backdrop
local dropdownBackdrop = {
  bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  tile = true,
  tileSize = 16,
  edgeSize = 16,
  insets = { left = 4, right = 4, top = 4, bottom = 4 }
}

-- Create a dropdown frame
local function CreateDropdownFrame(level)
  local frame = CreateFrame("Frame", "RunAwayDropdown" .. level, UIParent)
  frame:SetFrameStrata("DIALOG")
  frame:SetFrameLevel(100 + level)
  frame:SetBackdrop(dropdownBackdrop)
  frame:SetBackdropColor(0.05, 0.05, 0.1, 0.95)
  frame:SetBackdropBorderColor(0.4, 0.4, 0.5, 1)

  -- Title bar for all menu levels
  local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  title:SetPoint("TOP", frame, "TOP", 0, -8)
  title:SetText("|cffffcc00快|cffffffff跑！")
  frame.title = title

  frame.buttons = {}
  frame.level = level
  frame:Hide()

  return frame
end

-- Create a menu button
local function CreateMenuButton(parent, index)
  local button = CreateFrame("Button", nil, parent)
  button:SetHeight(18)

  -- Highlight texture
  local highlight = button:CreateTexture(nil, "HIGHLIGHT")
  highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
  highlight:SetBlendMode("ADD")
  highlight:SetAllPoints(button)
  highlight:SetAlpha(0.5)

  -- Text
  local text = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  text:SetPoint("LEFT", button, "LEFT", 10, 0)
  text:SetJustifyH("LEFT")
  button.text = text

  -- Arrow for submenus
  local arrow = button:CreateTexture(nil, "OVERLAY")
  arrow:SetTexture("Interface\\ChatFrame\\ChatFrameExpandArrow")
  arrow:SetWidth(14)
  arrow:SetHeight(14)
  arrow:SetPoint("RIGHT", button, "RIGHT", -4, 0)
  arrow:Hide()
  button.arrow = arrow

  -- Checkmark for toggle items
  local check = button:CreateTexture(nil, "OVERLAY")
  check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
  check:SetWidth(14)
  check:SetHeight(14)
  check:SetPoint("LEFT", button, "LEFT", 2, 0)
  check:Hide()
  button.check = check

  return button
end

-- Hide all dropdowns at or above a level
local function HideDropdownsAbove(level)
  for i = level, 10 do
    if dropdownFrames[i] then
      dropdownFrames[i]:Hide()
    end
  end
end

-- Hide all dropdowns
local function HideAllDropdowns()
  HideDropdownsAbove(1)
  currentLevel = 0
end

-- Build and show a dropdown menu
local function ShowDropdownMenu(menuData, level, anchorFrame, menuTitle)
  -- Create frame if needed
  if not dropdownFrames[level] then
    dropdownFrames[level] = CreateDropdownFrame(level)
  end

  local frame = dropdownFrames[level]

  -- Hide higher level menus
  HideDropdownsAbove(level + 1)

  -- Clear existing buttons
  for _, btn in pairs(frame.buttons) do
    btn:Hide()
  end

  -- Set title
  if frame.title then
    if menuTitle then
      frame.title:SetText("|cffffcc00" .. menuTitle .. "|r")
    else
      frame.title:SetText("|cffffcc00快|cffffffff跑！")
    end
  end

  -- Calculate dimensions
  local buttonCount = table.getn(menuData)
  local buttonWidth = 160
  local buttonHeight = 18
  local padding = 8
  local titleHeight = 20  -- Always have title space

  frame:SetWidth(buttonWidth + padding * 2)
  frame:SetHeight(buttonCount * buttonHeight + padding * 2 + titleHeight)

  -- Create buttons
  for i, item in ipairs(menuData) do
    if not frame.buttons[i] then
      frame.buttons[i] = CreateMenuButton(frame, i)
    end

    local button = frame.buttons[i]
    button:SetWidth(buttonWidth)
    button:SetPoint("TOPLEFT", frame, "TOPLEFT", padding, -padding - titleHeight - (i - 1) * buttonHeight)

    -- Store item data on button for closure access in Lua 5.0
    button.itemData = item
    button.menuLevel = level

    -- Reset button state
    button.text:SetPoint("LEFT", button, "LEFT", 10, 0)
    button.arrow:Hide()
    button.check:Hide()

    -- Set text with color
    if item.disabled then
      button.text:SetTextColor(0.5, 0.5, 0.5)
    elseif item.isTitle then
      button.text:SetTextColor(0.7, 0.7, 0.7, 1)
    else
      button.text:SetTextColor(1, 1, 1, 1)
    end
    button.text:SetText(item.text)

    -- Show checkmark for checked items
    if item.checked then
      button.check:Show()
      button.text:SetPoint("LEFT", button, "LEFT", 20, 0)
    end

    -- Show arrow for submenus
    if item.hasSubmenu then
      button.arrow:Show()
    end

    -- Click handler
    button:SetScript("OnClick", function()
      local data = this.itemData
      if not data or data.disabled then return end

      if data.func then
        data.func()
        if not data.keepOpen then
          HideAllDropdowns()
        end
      end
    end)

    -- Hover handler for submenus
    button:SetScript("OnEnter", function()
      local data = this.itemData
      local lvl = this.menuLevel
      if data and data.hasSubmenu and data.submenuFunc then
        local submenuData = data.submenuFunc()
        -- Pass menuArg as the title for submenus
        ShowDropdownMenu(submenuData, lvl + 1, this, data.menuArg)
        -- Store menu info for refresh after frame is created
        if dropdownFrames[lvl + 1] and data.menuArg then
          dropdownFrames[lvl + 1].menuArg = data.menuArg
        end
      else
        HideDropdownsAbove(lvl + 1)
      end
    end)

    button:Show()
  end

  -- Position and show frame
  frame:ClearAllPoints()
  if anchorFrame then
    local anchorX, anchorY = anchorFrame:GetCenter()
    local screenWidth = GetScreenWidth()
    local screenHeight = GetScreenHeight()
    local scale = UIParent:GetEffectiveScale()
    local frameWidth = frame:GetWidth()
    local frameHeight = frame:GetHeight()

    -- For level 1 (main menu from minimap button)
    if level == 1 then
      -- Determine best horizontal position based on minimap location
      if anchorX > screenWidth / 2 then
        -- Button is on right side, open menu to the left
        frame:SetPoint("TOPRIGHT", anchorFrame, "LEFT", 0, 10)
      else
        -- Button is on left side, open menu to the right
        frame:SetPoint("TOPLEFT", anchorFrame, "RIGHT", 0, 10)
      end
    else
      -- For submenus, always open to the left
      -- Offset to align first submenu button with parent button (title + padding)
      local titleOffset = 28
      frame:SetPoint("TOPRIGHT", anchorFrame, "TOPLEFT", -2, titleOffset)
    end
  else
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  end

  frame:Show()
  currentLevel = level
end

-- Check if a boss has any enabled auras
-- Uses code-defined layouts as source of truth
-- A boss is considered enabled if: boss-level enabled AND at least one column enabled
local function IsBossEnabled(bossName)
  -- First check if boss exists in code
  if not RunAway.IsDeclaredBoss(bossName) then
    return false
  end

  -- Check boss-level enabled state
  if not RunAway.IsBossEnabled(bossName) then
    return false
  end

  local layout = RunAway.GetBossLayout(bossName)
  if not layout or not layout.columns then return false end
  for _, column in ipairs(layout.columns) do
    if column.enabled then
      return true
    end
  end
  return false
end

-- Check if a raid has any enabled bosses
-- Uses code-defined raids as source of truth
local function IsRaidEnabled(raidName)
  local raid = RunAway.codeDefaults.raids and RunAway.codeDefaults.raids[raidName]
  if not raid or not raid.bosses then return false end
  for _, bossName in ipairs(raid.bosses) do
    if IsBossEnabled(bossName) then
      return true
    end
  end
  return false
end

-- Forward declarations for refresh
local BuildMainMenu, BuildBossSubmenu, BuildAuraSubmenu

-- ============================================================================
-- APPEARANCE SETTINGS - Demo window for scale and position
-- ============================================================================

local demoFrame = nil
local demoScale = 1.0

-- Create the demo/preview frame
local function CreateDemoFrame()
    if demoFrame then return demoFrame end

    -- Use exact same dimensions as real UI
    local barWidth = 90
    local barHeight = 14
    local barSpacing = 4
    local titleHeight = 20

    local frame = CreateFrame("Frame", "RunAwayDemoFrame", UIParent)
    frame:SetFrameStrata("DIALOG")
    frame:SetFrameLevel(50)
    frame:SetWidth(barWidth + 80)  -- Extra width for distance and timer
    frame:SetHeight(titleHeight + 80)
    frame:SetBackdrop(templates.background)
    frame:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")

    -- Border
    local border = CreateFrame("Frame", nil, frame)
    border:SetBackdrop(templates.border)
    border:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    border:SetPoint("TOPLEFT", frame, "TOPLEFT", -2, 2)
    border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 2, -2)
    frame.border = border

    -- Title (same style as real UI)
    local title = frame:CreateFontString(nil, "HIGH", "GameFontWhite")
    title:SetFont(STANDARD_TEXT_FONT, 10, "THINOUTLINE")
    title:SetPoint("TOP", frame, "TOP", 0, -4)
    title:SetTextColor(1, 1, 0, 1)
    title:SetText("预览窗口")
    frame.title = title

    -- Demo column (simulated, matching real column style)
    local demoColumn = CreateFrame("Frame", nil, frame)
    demoColumn:SetWidth(barWidth + 60)
    demoColumn:SetHeight(titleHeight + 2 * (barHeight + barSpacing) + 10)
    demoColumn:SetPoint("TOP", frame, "TOP", 0, -titleHeight)
    demoColumn:SetBackdrop(templates.background)
    demoColumn:SetBackdropColor(0.3, 0.1, 0.1, 0.9)  -- Same as real column

    local columnBorder = CreateFrame("Frame", nil, demoColumn)
    columnBorder:SetBackdrop(templates.border)
    columnBorder:SetBackdropBorderColor(1, 0.2, 0.2, 1)  -- Same as real column
    columnBorder:SetPoint("TOPLEFT", demoColumn, "TOPLEFT", -2, 2)
    columnBorder:SetPoint("BOTTOMRIGHT", demoColumn, "BOTTOMRIGHT", 2, -2)

    -- Column title (same style as real UI)
    local columnTitle = demoColumn:CreateFontString(nil, "HIGH", "GameFontWhite")
    columnTitle:SetFont(STANDARD_TEXT_FONT, 9, "THINOUTLINE")
    columnTitle:SetPoint("TOP", demoColumn, "TOP", 0, -2)
    columnTitle:SetTextColor(1, 0.4, 0.4, 1)  -- Same as real column
    columnTitle:SetText("示例列")

    -- Distance label (same position as real UI)
    local distanceLabel = demoColumn:CreateFontString(nil, "HIGH", "GameFontWhite")
    distanceLabel:SetFont(STANDARD_TEXT_FONT, 7, "THINOUTLINE")
    distanceLabel:SetPoint("TOPLEFT", demoColumn, "TOPLEFT", 10, -9)
    distanceLabel:SetTextColor(0.6, 0.6, 0.6, 1)
    distanceLabel:SetText("距离")

    -- Timer label (same position as real UI)
    local timerLabel = demoColumn:CreateFontString(nil, "HIGH", "GameFontWhite")
    timerLabel:SetFont(STANDARD_TEXT_FONT, 7, "THINOUTLINE")
    timerLabel:SetPoint("TOPRIGHT", demoColumn, "TOPRIGHT", -10, -9)
    timerLabel:SetTextColor(0.6, 0.6, 0.6, 1)
    timerLabel:SetText("时间")

    -- Demo bars (exact same style as real UI)
    local demoPlayers = {
        { name = "玩家一", health = 85, distance = "12.5", timer = "8.2s", color = {0.2, 0.8, 0.2} },
        { name = "玩家二", health = 60, distance = "25.0", timer = "5.1s", color = {0.2, 0.6, 0.8} },
    }

    for i, player in ipairs(demoPlayers) do
        local barFrame = CreateFrame("Button", nil, demoColumn)
        barFrame:SetWidth(barWidth)
        barFrame:SetHeight(barHeight)
        barFrame:SetPoint("TOP", demoColumn, "TOP", 0, -titleHeight - (i - 1) * (barHeight + barSpacing))
        barFrame:SetBackdrop(templates.background)
        barFrame:SetBackdropColor(0, 0, 0, 1)

        -- Health bar (same texture as real UI)
        local statusBar = CreateFrame("StatusBar", nil, barFrame)
        statusBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        statusBar:SetStatusBarColor(unpack(player.color))
        statusBar:SetMinMaxValues(0, 100)
        statusBar:SetValue(player.health)
        statusBar:SetAllPoints()

        -- Bar border (same style as real UI)
        local barBorder = CreateFrame("Frame", nil, statusBar)
        barBorder:SetBackdrop(templates.border)
        barBorder:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
        barBorder:SetPoint("TOPLEFT", statusBar, "TOPLEFT", -2, 2)
        barBorder:SetPoint("BOTTOMRIGHT", statusBar, "BOTTOMRIGHT", 2, -2)

        -- Player name text (same style as real UI)
        local text = statusBar:CreateFontString(nil, "HIGH", "GameFontWhite")
        text:SetFont(STANDARD_TEXT_FONT, 9, "THINOUTLINE")
        text:SetPoint("TOPLEFT", statusBar, "TOPLEFT", 2, -2)
        text:SetPoint("BOTTOMRIGHT", statusBar, "BOTTOMRIGHT", -2, 2)
        text:SetJustifyH("CENTER")
        text:SetText(player.name)

        -- Distance text (left side, same position as real UI)
        local distanceText = barFrame:CreateFontString(nil, "OVERLAY", "GameFontWhite")
        distanceText:SetPoint("RIGHT", statusBar, "LEFT", -2, 0)
        distanceText:SetJustifyH("RIGHT")
        distanceText:SetFont(STANDARD_TEXT_FONT, 9, "THINOUTLINE")
        if i == 1 then
            distanceText:SetText("|cff00ff00" .. player.distance .. "|r")
        else
            distanceText:SetText("|cffffff00" .. player.distance .. "|r")
        end

        -- Timer text (right side, same position as real UI)
        local timerText = barFrame:CreateFontString(nil, "OVERLAY", "GameFontWhite")
        timerText:SetPoint("LEFT", statusBar, "RIGHT", 2, 0)
        timerText:SetFont(STANDARD_TEXT_FONT, 9, "THINOUTLINE")
        timerText:SetTextColor(1, 1, 0.5, 1)
        timerText:SetText(player.timer)
    end

    frame.demoColumn = demoColumn

    -- Drag to move
    frame:SetScript("OnDragStart", function()
        this:StartMoving()
    end)

    frame:SetScript("OnDragStop", function()
        this:StopMovingOrSizing()
    end)

    -- Hint text
    local hint = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hint:SetPoint("BOTTOM", frame, "BOTTOM", 0, 4)
    hint:SetTextColor(0.7, 0.7, 0.7, 1)
    hint:SetText("拖拽移动位置")
    frame.hint = hint

    frame:Hide()
    demoFrame = frame
    return frame
end

-- Create the control panel for scale adjustment
local controlPanel = nil

local function CreateControlPanel()
    if controlPanel then return controlPanel end

    local panel = CreateFrame("Frame", "RunAwayControlPanel", UIParent)
    panel:SetFrameStrata("DIALOG")
    panel:SetFrameLevel(60)
    panel:SetWidth(180)
    panel:SetHeight(100)
    panel:SetBackdrop(dropdownBackdrop)
    panel:SetBackdropColor(0.05, 0.05, 0.1, 0.95)
    panel:SetBackdropBorderColor(0.4, 0.4, 0.5, 1)
    panel:SetPoint("CENTER", UIParent, "CENTER", 0, -100)

    -- Title
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", panel, "TOP", 0, -8)
    title:SetText("|cffffcc00外观设置|r")

    -- Scale label
    local scaleLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    scaleLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 15, -30)
    scaleLabel:SetText("缩放:")

    -- Scale value display
    local scaleValue = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    scaleValue:SetPoint("LEFT", scaleLabel, "RIGHT", 5, 0)
    scaleValue:SetText("1.00")
    panel.scaleValue = scaleValue

    -- Decrease scale button
    local decreaseBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    decreaseBtn:SetWidth(24)
    decreaseBtn:SetHeight(20)
    decreaseBtn:SetPoint("LEFT", scaleValue, "RIGHT", 10, 0)
    decreaseBtn:SetText("-")
    decreaseBtn:SetScript("OnClick", function()
        demoScale = math.max(0.5, demoScale - 0.1)
        panel.scaleValue:SetText(string.format("%.2f", demoScale))
        if demoFrame then
            demoFrame:SetScale(demoScale)
        end
    end)

    -- Increase scale button
    local increaseBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    increaseBtn:SetWidth(24)
    increaseBtn:SetHeight(20)
    increaseBtn:SetPoint("LEFT", decreaseBtn, "RIGHT", 2, 0)
    increaseBtn:SetText("+")
    increaseBtn:SetScript("OnClick", function()
        demoScale = math.min(2.0, demoScale + 0.1)
        panel.scaleValue:SetText(string.format("%.2f", demoScale))
        if demoFrame then
            demoFrame:SetScale(demoScale)
        end
    end)

    -- Confirm button
    local confirmBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    confirmBtn:SetWidth(60)
    confirmBtn:SetHeight(22)
    confirmBtn:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 15, 10)
    confirmBtn:SetText("确定")
    confirmBtn:SetScript("OnClick", function()
        -- Save scale
        RunAway_db.globalScale = demoScale

        -- Save position from demo frame
        if demoFrame then
            local point, _, _, x, y = demoFrame:GetPoint()
            RunAway_db.framePosition = {
                anchor = point,
                x = x,
                y = y
            }
            demoFrame:Hide()
        end

        panel:Hide()
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00快跑！|r 外观设置已保存")

        -- Apply to real frame if it exists
        if RunAway.ui and RunAway.ui.rootFrame then
            RunAway.ui.rootFrame:SetScale(demoScale)
            RunAway.ui.rootFrame:ClearAllPoints()
            local pos = RunAway_db.framePosition
            if pos then
                RunAway.ui.rootFrame:SetPoint(pos.anchor, pos.x, pos.y)
            end
        end
    end)

    -- Cancel button
    local cancelBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    cancelBtn:SetWidth(60)
    cancelBtn:SetHeight(22)
    cancelBtn:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -15, 10)
    cancelBtn:SetText("取消")
    cancelBtn:SetScript("OnClick", function()
        if demoFrame then
            demoFrame:Hide()
        end
        panel:Hide()
    end)

    panel:Hide()
    controlPanel = panel
    return panel
end

-- Show the appearance settings window
local function ShowAppearanceSettings()
    local demo = CreateDemoFrame()
    local control = CreateControlPanel()

    -- Initialize scale from saved value or default
    demoScale = RunAway_db.globalScale or RunAway.codeDefaults.globalScale or 1.0
    control.scaleValue:SetText(string.format("%.2f", demoScale))

    -- Position demo frame from saved position or center
    demo:ClearAllPoints()
    local savedPos = RunAway_db.framePosition
    if savedPos then
        demo:SetPoint(savedPos.anchor, savedPos.x, savedPos.y)
    else
        demo:SetPoint("CENTER", UIParent, "CENTER", 0, 50)
    end

    demo:SetScale(demoScale)
    demo:Show()
    control:Show()
end

-- Refresh all open dropdown menus
local function RefreshDropdowns()
  if currentLevel < 1 then return end

  -- Store current menu anchors before rebuilding
  local anchors = {}
  for i = 1, currentLevel do
    if dropdownFrames[i] and dropdownFrames[i]:IsShown() then
      anchors[i] = {
        frame = dropdownFrames[i],
        menuArg = dropdownFrames[i].menuArg
      }
    end
  end

  -- Rebuild level 1 (main menu)
  if anchors[1] then
    local menuData = BuildMainMenu()
    ShowDropdownMenu(menuData, 1, minimapButton)
  end

  -- Rebuild level 2 (submenu) if open
  if anchors[2] and anchors[2].menuArg then
    local menuData = BuildBossSubmenu(anchors[2].menuArg)

    if menuData then
      local parentBtn = nil
      -- Find the parent button in level 1 by menuArg
      if dropdownFrames[1] then
        for _, btn in pairs(dropdownFrames[1].buttons) do
          if btn.itemData and btn.itemData.menuArg == anchors[2].menuArg then
            parentBtn = btn
            break
          end
        end
      end
      if parentBtn then
        ShowDropdownMenu(menuData, 2, parentBtn, anchors[2].menuArg)
        dropdownFrames[2].menuArg = anchors[2].menuArg
      end
    end
  end

  -- Rebuild level 3 (aura submenu) if open
  if anchors[3] and anchors[3].menuArg then
    local menuData = BuildAuraSubmenu(anchors[3].menuArg)
    local parentBtn = nil
    -- Find the parent button in level 2 by menuArg
    if dropdownFrames[2] then
      for _, btn in pairs(dropdownFrames[2].buttons) do
        if btn.itemData and btn.itemData.menuArg == anchors[3].menuArg then
          parentBtn = btn
          break
        end
      end
    end
    if parentBtn then
      ShowDropdownMenu(menuData, 3, parentBtn, anchors[3].menuArg)
      dropdownFrames[3].menuArg = anchors[3].menuArg
    end
  end
end

-- Build aura submenu for a boss
-- Uses code-defined layouts as source of truth
BuildAuraSubmenu = function(bossName)
  -- First check if boss exists in code
  if not RunAway.IsDeclaredBoss(bossName) then
    return {{ text = "Boss not found in code", disabled = true }}
  end

  local layout = RunAway.GetBossLayout(bossName)
  if not layout or not layout.columns then
    return {{ text = "No auras configured", disabled = true }}
  end

  local menuData = {}

  -- Boss-level activate/deactivate toggle
  -- "激活" means activate - controls whether boss monitoring is active
  local bossActive = RunAway.IsBossEnabled(bossName)
  local bossToggleText = bossActive and "|cff00ff00已激活|r" or "|cff666666未激活|r"
  table.insert(menuData, {
    text = bossToggleText,
    keepOpen = true,
    func = function()
      local newActive = not RunAway.IsBossEnabled(bossName)
      RunAway.SetBossEnabled(bossName, newActive)
      if newActive then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00快跑！|r " .. bossName .. " |cff00ff00已激活|r")
      else
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00快跑！|r " .. bossName .. " |cffff0000已停用|r")
      end
      RefreshDropdowns()
    end
  })

  -- Separator
  table.insert(menuData, {
    text = "──────────",
    disabled = true,
    isTitle = true
  })

  -- Column toggles - show actual configured state
  -- When boss is inactive, columns are greyed out but show their real enabled state
  for i, column in ipairs(layout.columns) do
    local columnIndex = i  -- Capture for Lua 5.0 closure
    local columnTitle = column.title
    -- Get the actual stored column enabled state (not affected by boss active state)
    local userSettings = RunAway_db.bossSettings and RunAway_db.bossSettings[bossName]
    local columnEnabled = true  -- Default
    if userSettings and userSettings.columns and userSettings.columns[columnIndex] ~= nil then
      columnEnabled = userSettings.columns[columnIndex]
    end

    local displayText = columnTitle
    if not bossActive then
      -- Grey out text when boss is inactive (same grey as "未激活")
      displayText = "|cff666666" .. columnTitle .. "|r"
    elseif not columnEnabled then
      -- Column disabled but boss active - lighter grey
      displayText = "|cff999999" .. columnTitle .. "|r"
    end

    table.insert(menuData, {
      text = displayText,
      checked = columnEnabled,  -- Always show actual configured state
      keepOpen = true,  -- Keep menu open after clicking
      func = function()
        -- Toggle the column's own enabled state (not affected by boss active state)
        local currentEnabled = true
        local settings = RunAway_db.bossSettings and RunAway_db.bossSettings[bossName]
        if settings and settings.columns and settings.columns[columnIndex] ~= nil then
          currentEnabled = settings.columns[columnIndex]
        end
        local newEnabled = not currentEnabled
        RunAway.SetColumnEnabled(bossName, columnIndex, newEnabled)
        if newEnabled then
          DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00快跑！|r " .. bossName .. " - " .. columnTitle .. " |cff00ff00已启用|r")
        else
          DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00快跑！|r " .. bossName .. " - " .. columnTitle .. " |cffff0000已禁用|r")
        end
        -- Refresh all menus to update enabled status
        RefreshDropdowns()
      end
    })
  end

  return menuData
end

-- Build boss submenu for a raid
-- Uses code-defined raids as source of truth
BuildBossSubmenu = function(raidName)
  local raid = RunAway.codeDefaults.raids[raidName]
  if not raid or not raid.bosses then
    return {{ text = "No bosses configured", disabled = true }}
  end

  local menuData = {}
  for _, boss in ipairs(raid.bosses) do
    local bossName = boss  -- Capture for Lua 5.0 closure
    -- Only show bosses that exist in code
    if RunAway.IsDeclaredBoss(bossName) then
      local bossActive = RunAway.IsBossEnabled(bossName)
      local bossFullyEnabled = IsBossEnabled(bossName)  -- Active AND has enabled columns
      local displayText = bossName
      if not bossActive then
        -- Boss is deactivated - dark grey
        displayText = "|cff666666" .. bossName .. "|r"
      elseif not bossFullyEnabled then
        -- Boss is activated but all columns disabled - yellow/warning
        displayText = "|cffffff00" .. bossName .. "|r"
      else
        -- Boss is activated and has enabled columns - green
        displayText = "|cff00ff00" .. bossName .. "|r"
      end
      table.insert(menuData, {
        text = displayText,
        menuArg = bossName,  -- Raw name for refresh
        hasSubmenu = true,
        submenuFunc = function()
          return BuildAuraSubmenu(bossName)
        end
      })
    end
  end

  return menuData
end

-- Build main menu
-- Uses code-defined raids as source of truth
BuildMainMenu = function()
  local menuData = {}

  -- Enable/Disable toggle
  local enableText = RunAway_db.enabled and "启用" or "|cff888888启用|r"
  table.insert(menuData, {
    text = enableText,
    checked = RunAway_db.enabled,
    keepOpen = true,
    func = function()
      RunAway_db.enabled = not RunAway_db.enabled
      if not RunAway_db.enabled then
        -- Reset UI when disabled
        if RunAway.core then
          RunAway.core.ResetStatus()
        end
      end
      RefreshDropdowns()
    end
  })

  -- Debug toggle
  local debugText = RunAway_db.debug and "调试" or "|cff888888调试|r"
  table.insert(menuData, {
    text = debugText,
    checked = RunAway_db.debug,
    keepOpen = true,
    func = function()
      RunAway_db.debug = not RunAway_db.debug
      if RunAway_db.debug then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00快跑！|r 调试模式 |cff00ff00开启|r")
      else
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00快跑！|r 调试模式 |cffff0000关闭|r")
      end
      RefreshDropdowns()
    end
  })

  -- Appearance settings
  table.insert(menuData, {
    text = "外观设置",
    func = function()
      ShowAppearanceSettings()
    end
  })

  -- Raid announce toggle
  local announceEnabled = RunAway_db.raidAnnounceEnabled ~= false
  local announceText = announceEnabled and "团队通报" or "|cff888888团队通报|r"
  table.insert(menuData, {
    text = announceText,
    checked = announceEnabled,
    keepOpen = true,
    func = function()
      RunAway_db.raidAnnounceEnabled = not RunAway_db.raidAnnounceEnabled
      if RunAway_db.raidAnnounceEnabled then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00快跑！|r 团队通报 |cff00ff00开启|r")
      else
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00快跑！|r 团队通报 |cffff0000关闭|r")
      end
      RefreshDropdowns()
    end
  })

  -- Death watch toggle (raid wipe detection)
  local deathWatchEnabled = RunAway_db.deathWatchEnabled ~= false
  local deathWatchText = deathWatchEnabled and "团灭预警" or "|cff888888团灭预警|r"
  table.insert(menuData, {
    text = deathWatchText,
    checked = deathWatchEnabled,
    keepOpen = true,
    func = function()
      RunAway_db.deathWatchEnabled = not RunAway_db.deathWatchEnabled
      if RunAway_db.deathWatchEnabled then
        local threshold = RunAway.deathWatch and RunAway.deathWatch.GetThreshold() or 10
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00快跑！|r 团灭预警 |cff00ff00开启|r (1秒内" .. threshold .. "人死亡触发)")
      else
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00快跑！|r 团灭预警 |cffff0000关闭|r")
      end
      RefreshDropdowns()
    end
  })

  -- Separator
  table.insert(menuData, {
    text = "──────────",
    disabled = true,
    isTitle = true
  })

  -- Raids - use code-defined raids as source of truth
  -- Sort raids by order
  local sortedRaids = {}
  if RunAway.codeDefaults.raids then
    for raidName, raidData in pairs(RunAway.codeDefaults.raids) do
      table.insert(sortedRaids, { name = raidName, order = raidData.order or 999 })
    end
    table.sort(sortedRaids, function(a, b) return a.order < b.order end)

    for _, raid in ipairs(sortedRaids) do
      local raidName = raid.name  -- Capture for Lua 5.0 closure
      local raidEnabled = IsRaidEnabled(raidName)
      local displayText = raidName
      if not raidEnabled then
        displayText = "|cff888888" .. raidName .. "|r"
      else
        displayText = "|cff00ff00" .. raidName .. "|r"
      end
      table.insert(menuData, {
        text = displayText,
        menuArg = raidName,  -- Raw name for refresh
        hasSubmenu = true,
        submenuFunc = function()
          return BuildBossSubmenu(raidName)
        end
      })
    end
  end

  return menuData
end

-- Minimap button click handler
minimapButton:SetScript("OnClick", function()
  if arg1 == "LeftButton" then
    if currentLevel > 0 then
      HideAllDropdowns()
    else
      local menuData = BuildMainMenu()
      ShowDropdownMenu(menuData, 1, minimapButton)
    end
  end
end)

-- Close dropdowns when clicking elsewhere
local closeFrame = CreateFrame("Button", "RunAwayCloseFrame", UIParent)
closeFrame:SetAllPoints()
closeFrame:SetFrameStrata("DIALOG")
closeFrame:SetFrameLevel(1)
closeFrame:Hide()
closeFrame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
closeFrame:SetScript("OnClick", function()
  HideAllDropdowns()
end)

-- Show/hide the close frame when dropdowns open/close
local origHideAllDropdowns = HideAllDropdowns
HideAllDropdowns = function()
  origHideAllDropdowns()
  closeFrame:Hide()
end

local origShowDropdownMenu = ShowDropdownMenu
ShowDropdownMenu = function(menuData, level, anchorFrame, menuTitle)
  closeFrame:Show()
  origShowDropdownMenu(menuData, level, anchorFrame, menuTitle)
end

-- Also close on Escape
local escapeFrame = CreateFrame("Frame", "RunAwayEscapeHandler", UIParent)
escapeFrame:EnableKeyboard(true)
escapeFrame:SetPropagateKeyboardInput(true)
escapeFrame:SetScript("OnKeyDown", function()
  if arg1 == "ESCAPE" and currentLevel > 0 then
    HideAllDropdowns()
    this:SetPropagateKeyboardInput(false)
  else
    this:SetPropagateKeyboardInput(true)
  end
end)

RunAway.settings = settings
