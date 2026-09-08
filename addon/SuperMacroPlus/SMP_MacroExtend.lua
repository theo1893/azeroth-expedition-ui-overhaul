-- SuperMacroPlusExtend handlers

-- string: saved current extend script page to show.
local currentPageId


-- Change current page to new Id
local function SetCurrentPage(pageId)
    currentPageId = pageId
    local extendText
    if currentPageId then
        extendText=SMP_EXTEND[currentPageId]
    end
    if extendText then
        SuperMacroPlusFrameExtendText:SetText(extendText)
    else
        -- Create new or invalid id. Show empty text
        SuperMacroPlusFrameExtendText:SetText("")
    end
end

-- Save current extend script text to SMP_EXTEND and update UI
local function SaveCurrentPage()
    if not currentPageId then
        return
    end

    local text=SuperMacroPlusFrameExtendText:GetText()
    if text and text~="" then
        SMP_EXTEND[currentPageId]=text
    else
        -- auto delete empty page
        SMP_EXTEND[currentPageId]=nil
    end

    SuperMacroPlusFrameExtendText:ClearFocus()
    SuperMacroPlusSaveExtendButton:SetTextColor(0.5, 0.5, 0.5)
end

-- Run all current scripts
local function RunAllScripts()
    for m,e in pairs(SMP_EXTEND) do
        if ( e ) then
            RunScript(e)
        end
    end
end




-- External functions
-- Initialize extend macro
function SuperMacroPlusInitExtend()
    RunAllScripts()
end

-- Save current UI text changes and run scripts
function SuperMacroPlusRunAllExtend()
    SaveCurrentPage()
	RunAllScripts()
end

function SuperMacroPlusSelectExtend(pageId)
    SaveCurrentPage()
    SetCurrentPage(pageId)
end

function SuperMacroPlusCopyExtend(fromId, toId)
    assert(fromId ~= toId)
    SaveCurrentPage()

    local text = SMP_EXTEND[fromId]
    SMP_EXTEND[toId] = text
end

function SuperMacroPlusDeleteExtend(pageId)
    SaveCurrentPage()
    SMP_EXTEND[pageId]=nil
    if pageId == currentPageId then
        -- Update script UI
        SetCurrentPage(pageId)
    end
end

-- Save button action
function SuperMacroPlusSaveExtendButton_OnClick()
    SuperMacroPlusRunAllExtend()
end

-- Delete button action
function SuperMacroPlusDeleteExtendButton_OnClick()
    if currentPageId then
        SuperMacroPlusDeleteExtend(currentPageId)
    end
    SuperMacroPlusRunAllExtend()
end

-- UI change text action
function SuperMacroPlusFrameExtendText_OnTextChanged()
    SuperMacroPlusFrameExtendCharLimitText:SetText(format(TEXT(SUPERMACROPLUSFRAME_EXTEND_CHAR_LIMIT), SMP_utf8len(SuperMacroPlusFrameExtendText:GetText())))
    SuperMacroPlusHandleEditBox(SuperMacroPlusFrameExtendText)
    SuperMacroPlusSaveExtendButton:SetTextColor(1, 0.82, 0)
end

function SuperMacroPlusSetDefaultTooltipColor(frame)
    frame:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
    frame:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);
end
