local frame = CreateFrame("Frame", "GoblinBrainwashingAddonFrame", UIParent)

local _G = getfenv(0) -- implements _G

-- SavedVariablesPerCharacter
GBHSpec = GBHSpec or {}
RGBSpec = RGBSpec or {} 

for i = 1, 4 do
RGBSpec[i] = RGBSpec[i] or {1, 0, 0} -- set default color
end

local textFrame = CreateFrame("Frame", "GoblinBrainwashingTextFrame", GossipFrame)
textFrame:SetWidth(140)
--textFrame:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"})
textFrame:SetBackdropColor(0, 0, 0, 0.7)
textFrame:SetPoint("TOPLEFT", GossipFrame, "RIGHT", -29, 38)
textFrame:Hide()
textFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})

local helperButton = CreateFrame("Button", "ToggleTextFrameButton", GossipFrame, "UIPanelButtonTemplate")
helperButton:SetWidth(90)
helperButton:SetHeight(18)
helperButton:SetText("天赋备注")
helperButton:SetPoint("TOPLEFT", GossipFrame, "TOPRIGHT", -140, -22)
helperButton:Hide()
helperButton:SetScript("OnClick", function()
        helperButton:Hide()
        textFrame:Show()
end)

-- save button (of lies, it just closes the frame so the gossip window has to be opened again with the new text/colors)
local saveButton = CreateFrame("Button", "GoblinBrainwashingSaveButton", textFrame, "UIPanelButtonTemplate")
saveButton:SetWidth(45)
saveButton:SetHeight(17)
saveButton:SetText("保存")
saveButton:SetPoint("BOTTOM", textFrame, "BOTTOM", 0, 7)
saveButton:SetScript("OnClick", function()
    CloseGossip()
end)

	-- update colour of index specRGBFrame/GBSpec
local function UpdatespecRGBFrameColour(index, r, g, b)
    RGBSpec[index] = {r, g, b} 
	local specRGBFrame = _G["specRGBFrame" .. index]
    local specColor = specRGBFrame.texture
	specColor:SetVertexColor(r, g, b)
end

	-- colorPicker
local function OpenColorPicker(button, index)
    ColorPickerFrame.func = nil -- clear previous specRGBFrame inndex

    local function ColorPickerCallback()
        local newR, newG, newB = ColorPickerFrame:GetColorRGB()
        UpdatespecRGBFrameColour(index, newR, newG, newB) -- update colour of specRGBFrame/RGBSpec
    end

    -- colorPicker setup
    ColorPickerFrame:SetColorRGB(unpack(RGBSpec[index]))
    ColorPickerFrame.previousValues = RGBSpec[index]
    ColorPickerFrame.func = function() ColorPickerCallback(nil) end
    ShowUIPanel(ColorPickerFrame)
end

	-- create base specEditBox and specRGBFrame
local function CreatespecEditBox(parent, index)
    local specEditBox = CreateFrame("EditBox", "specEditBox" .. index, parent, "InputBoxTemplate")
    specEditBox:SetWidth(100)
    specEditBox:SetHeight(30)
    specEditBox:SetAutoFocus(false)
    specEditBox:SetMaxLetters(16)
    specEditBox:SetPoint("TOPLEFT", parent, "TOPLEFT", 11, -23 * (index - 1))

    specRGBFrame = CreateFrame("Button", "specRGBFrame" .. index, parent)
    specRGBFrame:SetWidth(16)
    specRGBFrame:SetHeight(16)
    specRGBFrame:SetPoint("LEFT", specEditBox, "RIGHT", 5, -1)

    specRGBTexture = specRGBFrame:CreateTexture(nil, "BACKGROUND")
    specRGBTexture:SetAllPoints()
    specRGBTexture:SetTexture("Interface\\Buttons\\WHITE8X8")
    specRGBTexture:SetVertexColor(unpack(RGBSpec[index] or {0.5, 0.5, 0.5}))
    specRGBFrame.texture = specRGBTexture

    specRGBFrame:SetScript("OnClick", function()
        OpenColorPicker(specRGBFrame, index)
    end)

    specEditBox:SetScript("OnEditFocusLost", function()
        GBHSpec[index] = specEditBox:GetText()
    end)

    return specEditBox
end

if pfUI and pfUI.env then
    pfUI.api.SkinButton(helperButton)
	pfUI.api.SkinButton(saveButton)
end

	-- replace gossip text with specEditBox/GBHSpec text
local function UpdateGossipOptions()
    for i = 1, 4 do 
        local GBHSpecText = GBHSpec[i]
        if GBHSpecText then
			local gossipOptions = {GetGossipOptions()}
			local numOptions = table.getn(gossipOptions)
            for j = 1, numOptions do 
                local button = _G["GossipTitleButton" .. j]
                if button and button:GetText() then 
                    local text = button:GetText()
                    local startPos = string.find(text, "启用第" .. i .. "天赋。")
                    if startPos then
                        HexRGB = string.format("%02x%02x%02x", math.floor(RGBSpec[i][1]*255), math.floor(RGBSpec[i][2]*255), math.floor(RGBSpec[i][3]*255))
                        local newText = string.gsub(text, "%d天赋。", "|cFF000000|r|cff"..HexRGB .. GBHSpec[i] .. "|r天赋。") 
                        button:SetText(newText)
                    end
                end
            end
        end
    end
end


	--events
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("GOSSIP_SHOW")
frame:RegisterEvent("GOSSIP_CLOSED")

frame:SetScript("OnEvent", function()
    if event == "ADDON_LOADED" and arg1 == "GoblinBrainwashingHelper" then
    elseif event == "GOSSIP_SHOW" then		
		if GossipFrameNpcNameText:GetText() == "地精洗脑装置" then
			 helperButton:Show()
			local gossipOptions = {GetGossipOptions()}
            local activateCount = 0
			local numOptions = table.getn(gossipOptions)
			
			for i = 1, numOptions,2 do
				local optionText = gossipOptions[i]
				if string.find(optionText, "启用第.*天赋。") then
						activateCount = activateCount + 1
				end
			end
			
			for i = 1, activateCount do
                local specEditBox = _G["specEditBox" .. i] or CreatespecEditBox(textFrame, i)
                specEditBox:SetText(GBHSpec[i] or "")
                specEditBox:Show()
            end

            for i = activateCount + 1, 4 do
                local specEditBox = _G["specEditBox" .. i]
                if specEditBox then
                    specEditBox:Hide()
                end
            end
            local newHeight =  26+ (activateCount) * 23  --43
            textFrame:SetHeight(newHeight)
            UpdateGossipOptions()
        else
        end

    elseif event == "GOSSIP_CLOSED" then
        helperButton:Hide()
        textFrame:Hide()
    end
end)