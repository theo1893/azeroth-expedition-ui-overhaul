--########### RangeController
--########### By YourName

local RC = CreateFrame('Frame', "RangeController", UIParent)
RC.Options = CreateFrame("Frame", nil, UIParent)

-- Options frame initialization
function RC:Init()
    local backdrop = {
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        tile = false,
        tileSize = 8,
        edgeSize = 8,
        insets = {
            left = 2,
            right = 2,
            top = 2,
            bottom = 2
        }
    }

    self.Options:SetFrameStrata("BACKGROUND")
    self.Options:SetWidth(300)
    self.Options:SetHeight(150)
    self.Options:SetPoint("CENTER", 0, 0)
    self.Options:SetMovable(true)
    self.Options:EnableMouse(true)
    self.Options:RegisterForDrag("LeftButton")
    self.Options:SetBackdrop(backdrop)
    self.Options:SetBackdropColor(0, 0, 0, 1)

    -- Title
    local title = self.Options:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", self.Options, "TOP", 0, -20) -- 调整标题位置
    title:SetText("战斗记录收集范围")

    -- Slider
    self.Slider = CreateFrame("Slider", "RC_Slider", self.Options, 'OptionsSliderTemplate')
    self.Slider:SetWidth(200)
    self.Slider:SetHeight(20)
    self.Slider:SetPoint("TOP", title, "BOTTOM", 0, -20) -- 调整滑块位置
    self.Slider:SetMinMaxValues(0, 200)
    self.Slider:SetValue(150) -- Default value
    self.Slider:SetValueStep(5) -- 设置最小滑动步数为5
    getglobal(self.Slider:GetName() .. 'Low'):SetText('0')
    getglobal(self.Slider:GetName() .. 'High'):SetText('200')

    -- Current value display
    self.CurrentValueText = self.Options:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.CurrentValueText:SetPoint("TOP", self.Slider, "BOTTOM", 0, -10) -- 调整当前值显示位置
    self.CurrentValueText:SetText("当前选择: " .. self.Slider:GetValue())

    self.Slider:SetScript("OnValueChanged", function(slider, value)
        local currentValue = value or self.Slider:GetValue()
        self.CurrentValueText:SetText("当前选择: " .. currentValue) -- 更新当前选择的显示值
    end)

    -- Confirm button
    self.ConfirmButton = CreateFrame("Button", nil, self.Options, "UIPanelButtonTemplate")
    self.ConfirmButton:SetWidth(79)
    self.ConfirmButton:SetHeight(18)
    self.ConfirmButton:SetText("确认") -- 将按钮文本改为中文“确认”

    -- Close button
    self.CloseButton = CreateFrame("Button", nil, self.Options, "UIPanelButtonTemplate")
    self.CloseButton:SetWidth(79)
    self.CloseButton:SetHeight(18)
    self.CloseButton:SetText("关闭窗口") -- 设置按钮文本为“关闭窗口”

    -- Position Confirm and Close buttons horizontally centered relative to the options frame
    local totalWidth = self.ConfirmButton:GetWidth() + 40 + self.CloseButton:GetWidth()
    local offsetX = (self.Options:GetWidth() - totalWidth) / 2

    self.ConfirmButton:SetPoint("CENTER", self.Options, "CENTER", -offsetX - 10, -50) -- Adjust Y offset as needed
    self.CloseButton:SetPoint("LEFT", self.ConfirmButton, "RIGHT", 40, 0)

    self.ConfirmButton:SetScript("OnClick", function()
        local range = self.Slider:GetValue()  -- 获取滑块当前值
        local commands = {
            '/console SET CombatLogRangeHostilePlayers "' .. range .. '"',
            '/console SET CombatLogRangeHostilePlayersPets "' .. range .. '"',
            '/console SET CombatLogRangeParty "' .. range .. '"',
            '/console SET CombatLogRangePartyPet "' .. range .. '"',
            '/console SET CombatLogRangeFriendlyPlayers "' .. range .. '"',
            '/console SET CombatLogRangeFriendlyPlayersPets "' .. range .. '"',
            '/console SET CombatLogRangeCreature "' .. range .. '"',
            '/console SET CombatDeathLogRange "' .. range .. '"',
            '/console SET CombatModeMaxDistance "' .. range .. '"'
        }

        -- 遍历命令并发送
        for _, command in ipairs(commands) do
            DEFAULT_CHAT_FRAME.editBox:SetText(command)
            ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)-- 使用你的命令执行函数发送命令
        end

        print("战斗记录范围设置为 " .. range)  -- 输出设置的范围
    end)

    self.CloseButton:SetScript("OnClick", function()
        RC.Options:Hide()
    end)

    self.Options:Hide()
end

-- Register PLAYER_LOGIN event
RC:RegisterEvent("PLAYER_LOGIN")
RC:SetScript("OnEvent", RC.OnEvent)

-- Slash command
SLASH_RangeController1 = "/FW"
SlashCmdList["RangeController"] = function()
    if RC.Options:IsShown() then
        RC.Options:Hide()
    else
        RC.Options:Show()
    end
end

RC:Init()