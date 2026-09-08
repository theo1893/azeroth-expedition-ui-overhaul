-- 进入战斗，离开战斗提示
local alertFrame = CreateFrame("Frame")
alertFrame:Hide()
alertFrame.Bg = alertFrame:CreateTexture(nil, "BACKGROUND")
alertFrame.Bg:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
alertFrame.Bg:SetBlendMode("ADD")
alertFrame.Bg:SetPoint("TOP", "UIParent", 0, -152)
alertFrame.Bg:SetWidth(110)
alertFrame.Bg:SetHeight(25)
alertFrame.Bg:SetVertexColor(1, 1, 1, 0.6)
alertFrame.text = alertFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
alertFrame.text:SetFont(STANDARD_TEXT_FONT, 20)
alertFrame.text:SetPoint("CENTER", alertFrame.Bg, "CENTER", 0, 1)

alertFrame:SetScript("OnUpdate", function()
    this.timer = this.timer + 0.03
    if (this.timer > this.totalTime) then this:Hide() end
    if (this.timer <= 0.5) then
        this:SetAlpha(this.timer * 2)
    elseif (this.timer > 2) then
        this:SetAlpha(1-this.timer/this.totalTime)
    end
end)

alertFrame:SetScript("OnShow", function()
    this.totalTime = 3.2
    this.timer = 0
end)

alertFrame:SetScript("OnEvent", function()
    if (event == "PLAYER_REGEN_DISABLED") then
        this.text:SetText("进入战斗")
		this.text:SetTextColor(1, 0, 0)
    elseif (event == "PLAYER_REGEN_ENABLED") then
        this.text:SetText("离开战斗")
		this.text:SetTextColor(0, 1, 0)
    end
    this:Show()
end)

alertFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
alertFrame:RegisterEvent("PLAYER_REGEN_DISABLED")