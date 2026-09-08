--[[
    Author: SuperCleveRoidMacros
    License: MIT License

    EGD (EasyGrid) mouseover support.
    Hooks into EGD's unit frames to enable [@mouseover] macros.
]]
local _G = _G or getfenv(0)
local CleveRoids = _G.CleveRoids or {}

local Extension = CleveRoids.RegisterExtension("EGD")
Extension.RegisterEvent("ADDON_LOADED", "OnLoad")

function Extension.OnEnter(frame, unitId)
    if unitId then
        CleveRoids.SetMouseoverFrom("egd", unitId)
    end
end

function Extension.OnLeave(frame)
    CleveRoids.ClearMouseoverFrom("egd")
    CleveRoids.ClearMouseoverFrom("native")
end

function Extension.SetupMouseover(frame)
    if not frame then return end

    local origOnEnter = frame:GetScript("OnEnter")
    local origOnLeave = frame:GetScript("OnLeave")

    frame:SetScript("OnEnter", function()
        -- Call original (EGD's tooltip display)
        if origOnEnter then origOnEnter() end
        -- Set mouseover
        Extension.OnEnter(frame, frame.unitId)
    end)

    frame:SetScript("OnLeave", function()
        -- Clear mouseover first
        Extension.OnLeave(frame)
        -- Call original (hide tooltip)
        if origOnLeave then origOnLeave() end
    end)
end

function Extension.OnLoad()
    if arg1 ~= "EGD" then return end

    if not EGDFrame or not EGDFrame.gridFrames then return end

    for i = 1, MAX_COLUMNS * ROWS_PER_COL do
        local frame = EGDFrame.gridFrames[i]
        if frame then
            Extension.SetupMouseover(frame)
        end
    end
end

_G["CleveRoids"] = CleveRoids