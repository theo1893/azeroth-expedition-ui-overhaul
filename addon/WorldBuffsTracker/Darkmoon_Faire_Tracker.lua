function Darkmoon_Faire_Alliance_OnLoad()
    this:RegisterEvent("CHAT_MSG_YELL")
    this:RegisterEvent("WORLD_MAP_UPDATE")
end

function Darkmoon_Faire_Alliance_OnEvent(event)
    DEFAULT_CHAT_FRAME:AddMessage(event);
end