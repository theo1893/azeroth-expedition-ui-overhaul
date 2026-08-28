AzerothExpeditionGroupFinder = AzerothExpeditionGroupFinder or {}

local A = AzerothExpeditionGroupFinder
local P = AEGFProtocol
local ADDON_NAME = "AzerothExpeditionGroupFinder"
local CHANNEL_NAME = "AEGF1"
local HEARTBEAT_SECONDS = 60
local LISTING_TTL_SECONDS = 150
local SEND_INTERVAL_SECONDS = 1

A.version = "0.1.1"
A.channelName = CHANNEL_NAME
A.listings = A.listings or {}
A.applications = A.applications or {}
A.applicationStates = A.applicationStates or {}
A.channelQueue = A.channelQueue or {}
A.selectedRole = A.selectedRole or "D"

local defaults = {
    title = "",
    minimumItemLevel = "0",
    targetTanks = "2",
    targetHealers = "8",
    targetDamage = "30",
    targetClasses = "5,4,4,5,6,4,4,4,4",
    leaderInfo = "",
    competition = "",
}

local function now()
    return GetTime()
end

local function playerName()
    return UnitName("player") or ""
end

local function sameName(left, right)
    return string.lower(left or "") == string.lower(right or "")
end

local function listingKey(leader, id)
    return string.lower(leader or "") .. ":" .. (id or "")
end

local function printMessage(message)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cffC9A86AAEGF|r " .. tostring(message))
    end
end

local function copyDefaults(target, source)
    local key
    for key in pairs(defaults) do
        target[key] = tostring(source[key] or defaults[key])
    end
end

local function classIndex(token)
    local index
    for index = 1, 9 do
        if P.classTokens[index] == token then
            return index
        end
    end
    return nil
end

local function emptyClassVector()
    return { 0, 0, 0, 0, 0, 0, 0, 0, 0 }
end

local function scanRoster()
    local counts = emptyClassVector()
    local members = GetNumRaidMembers()
    local index
    if members and members > 0 then
        for index = 1, members do
            local name, rank, subgroup, level, localizedClass, token = GetRaidRosterInfo(index)
            local position = classIndex(token)
            if name and position then
                counts[position] = counts[position] + 1
            end
        end
        return counts, members
    end

    members = (GetNumPartyMembers() or 0) + 1
    for index = 0, members - 1 do
        local unit = index == 0 and "player" or "party" .. tostring(index)
        local localizedClass, token = UnitClass(unit)
        local position = classIndex(token)
        if position then
            counts[position] = counts[position] + 1
        end
    end
    return counts, members
end

local function vectorsEqual(left, right)
    local index
    for index = 1, 9 do
        if left[index] ~= right[index] then
            return nil
        end
    end
    return 1
end

local function canPublish()
    if (GetNumRaidMembers() or 0) > 0 then
        return IsRaidLeader()
    end
    if (GetNumPartyMembers() or 0) > 0 then
        return IsPartyLeader()
    end
    return 1
end

local function queueChannel(message)
    if not message or table.getn(A.channelQueue) >= 20 then
        return nil
    end
    table.insert(A.channelQueue, message)
    return 1
end

local function hideChannel()
    if not ChatFrame_RemoveChannel then
        return
    end
    local maximum = NUM_CHAT_WINDOWS or 7
    local index
    for index = 1, maximum do
        local chatFrame = getglobal("ChatFrame" .. tostring(index))
        if chatFrame then
            ChatFrame_RemoveChannel(chatFrame, CHANNEL_NAME)
        end
    end
end

local function ensureChannel()
    local channelId = GetChannelName(CHANNEL_NAME)
    if channelId and channelId > 0 then
        A.channelId = channelId
        A.channelJoined = 1
        hideChannel()
        return 1
    end

    A.channelJoined = nil
    local frameId = DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME:GetID() or 1
    JoinChannelByName(CHANNEL_NAME, nil, frameId)
    return nil
end

local function queueDirected(payload)
    return queueChannel(payload)
end

local function refreshUI()
    if A.UI and A.UI.Refresh then
        A.UI:Refresh()
    end
end

local function receiveListing(sender, listing)
    if not sender or sender == "" then
        return
    end
    local key = listingKey(sender, listing.id)
    local existing = A.listings[key]
    if existing and existing.revision > listing.revision then
        existing.updatedAt = now()
        return
    end
    local otherKey, otherListing
    for otherKey, otherListing in pairs(A.listings) do
        if otherKey ~= key and sameName(otherListing.leader, sender) then
            A.listings[otherKey] = nil
        end
    end
    listing.leader = sender
    listing.key = key
    listing.updatedAt = now()
    A.listings[key] = listing
    refreshUI()
end

local function announceActive()
    if not A.activeListing then
        return
    end
    local message, errorMessage = P.EncodeListing(A.activeListing)
    if not message then
        printMessage(errorMessage or "无法发布开团信息。")
        return
    end
    queueChannel(message)
    receiveListing(playerName(), A.activeListing)
    A.nextHeartbeatAt = now() + HEARTBEAT_SECONDS
end

local function updateActiveRoster()
    if not A.activeListing then
        return
    end
    if not canPublish() then
        A.CloseListing("你已不是队伍或团队领袖，招募已自动关闭。")
        return
    end
    local classes, players = scanRoster()
    if players ~= A.activeListing.currentPlayers
        or not vectorsEqual(classes, A.activeListing.currentClasses) then
        A.activeListing.currentPlayers = players
        A.activeListing.currentClasses = classes
        A.activeListing.revision = A.activeListing.revision + 1
        A.nextAnnounceAt = now() + 1
        refreshUI()
    end
end

local function pruneListings()
    local changed
    local key, listing
    local currentTime = now()
    for key, listing in pairs(A.listings) do
        if currentTime - listing.updatedAt > LISTING_TTL_SECONDS then
            A.listings[key] = nil
            if A.selectedListingKey == key then
                A.selectedListingKey = nil
            end
            changed = 1
        end
    end
    if changed then
        refreshUI()
    end
end

local function handleChannelMessage(message, sender, rawChannel)
    if string.lower(rawChannel or "") ~= string.lower(CHANNEL_NAME) then
        return
    end
    local kind, data = P.Decode(message)
    if kind == "A" then
        receiveListing(sender, data)
    elseif kind == "C" then
        local key = listingKey(sender, data.id)
        A.listings[key] = nil
        if A.selectedListingKey == key then
            A.selectedListingKey = nil
        end
        refreshUI()
    elseif kind == "Q" and A.activeListing then
        local currentTime = now()
        if not A.lastQueryResponseAt or currentTime - A.lastQueryResponseAt > 10 then
            A.lastQueryResponseAt = currentTime
            A.nextAnnounceAt = currentTime + math.random(0, 5)
        end
    end
    return kind == "P" or kind == "R"
end

local function handleApplication(sender, data)
    if not sender or sender == "" or not A.activeListing
        or data.id ~= A.activeListing.id or sameName(sender, playerName()) then
        return
    end
    if data.itemLevel < A.activeListing.minimumItemLevel then
        queueDirected(P.EncodeResponse(data.id, sender, "REJECTED"))
        return
    end
    local key = string.lower(sender)
    local existing = A.applications[key]
    if existing and now() - existing.receivedAt < 5 then
        return
    end
    A.applications[key] = {
        name = sender,
        role = data.role,
        itemLevel = data.itemLevel,
        classIndex = data.classIndex,
        receivedAt = now(),
    }
    queueDirected(P.EncodeResponse(data.id, sender, "PENDING"))
    printMessage(sender .. " 申请入团。")
    refreshUI()
end

local responseLabels = {
    PENDING = "团长已收到申请。",
    INVITED = "团长已发出邀请。",
    REJECTED = "申请未通过。",
    CLOSED = "该团已停止招募。",
}

local function handleDirectMessage(message, sender)
    local kind, data = P.Decode(message)
    if not data or not sameName(data.recipient, playerName()) then
        return
    end
    if kind == "P" then
        handleApplication(sender, data)
    elseif kind == "R" then
        A.applicationStates[listingKey(sender, data.id)] = data.state
        printMessage(responseLabels[data.state] or data.state)
        refreshUI()
    end
end

function A.GetDraft()
    local draft = {}
    copyDefaults(draft, (AzerothExpeditionGroupFinderDB or {}).draft or {})
    return draft
end

function A.GetListings()
    pruneListings()
    local result = {}
    local index = 1
    local key, listing
    for key, listing in pairs(A.listings) do
        result[index] = listing
        index = index + 1
    end
    table.sort(result, function(left, right)
        if left.updatedAt == right.updatedAt then
            return left.key < right.key
        end
        return left.updatedAt > right.updatedAt
    end)
    return result
end

function A.GetApplications()
    local result = {}
    local index = 1
    local key, application
    for key, application in pairs(A.applications) do
        result[index] = application
        index = index + 1
    end
    table.sort(result, function(left, right)
        return left.receivedAt > right.receivedAt
    end)
    return result
end

function A.PublishListing(draft)
    if not canPublish() then
        return nil, "只有队伍或团队领袖可以发布。"
    end
    local targetClasses = P.ParseClassVector(draft.targetClasses or "")
    if not targetClasses then
        return nil, "职业上限必须是 9 个逗号分隔的整数：战,骑,猎,贼,牧,萨,法,术,德。"
    end
    local currentClasses, currentPlayers = scanRoster()
    local listing = {
        id = A.activeListing and A.activeListing.id
            or string.format("%x-%04x", math.floor(now()), math.random(0, 65535)),
        revision = A.activeListing and A.activeListing.revision + 1 or 1,
        title = draft.title,
        leaderInfo = draft.leaderInfo,
        minimumItemLevel = tonumber(draft.minimumItemLevel),
        targetTanks = tonumber(draft.targetTanks),
        targetHealers = tonumber(draft.targetHealers),
        targetDamage = tonumber(draft.targetDamage),
        currentPlayers = currentPlayers,
        currentClasses = currentClasses,
        targetClasses = targetClasses,
        competition = draft.competition,
    }
    local message, errorMessage = P.EncodeListing(listing)
    if not message then
        return nil, errorMessage
    end

    AzerothExpeditionGroupFinderDB.draft = AzerothExpeditionGroupFinderDB.draft or {}
    copyDefaults(AzerothExpeditionGroupFinderDB.draft, draft)
    A.activeListing = listing
    queueChannel(message)
    receiveListing(playerName(), listing)
    A.nextHeartbeatAt = now() + HEARTBEAT_SECONDS
    printMessage("已发布：" .. listing.title)
    refreshUI()
    return 1
end

function A.CloseListing(reason)
    if not A.activeListing then
        return nil
    end
    local listing = A.activeListing
    queueChannel(P.EncodeClose(listing.id))
    local key, application
    for key, application in pairs(A.applications) do
        queueDirected(P.EncodeResponse(listing.id, application.name, "CLOSED"))
    end
    A.applications = {}
    A.listings[listingKey(playerName(), listing.id)] = nil
    A.activeListing = nil
    A.selectedApplicationName = nil
    printMessage(reason or "已停止招募。")
    refreshUI()
    return 1
end

function A.RequestSync()
    local currentTime = now()
    if A.lastQueryAt and currentTime - A.lastQueryAt < 5 then
        return nil
    end
    A.lastQueryAt = currentTime
    queueChannel(P.EncodeQuery())
    return 1
end

function A.GetSelfItemLevel()
    local slots = { 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18 }
    local total = 0
    local mainHandLevel
    local mainHandTwoHanded
    local offHandEquipped
    local index
    for index = 1, 17 do
        local slot = slots[index]
        local link = GetInventoryItemLink("player", slot)
        if link then
            local name, itemLink, quality, itemLevel, requiredLevel, itemType,
                itemSubType, stackCount, equipLocation = GetItemInfo(link)
            itemLevel = tonumber(itemLevel) or 0
            total = total + itemLevel
            if slot == 16 then
                mainHandLevel = itemLevel
                mainHandTwoHanded = equipLocation == "INVTYPE_2HWEAPON"
            elseif slot == 17 then
                offHandEquipped = 1
            end
        end
    end
    if mainHandTwoHanded and not offHandEquipped then
        total = total + (mainHandLevel or 0)
    end
    return math.floor(total / 17 + 0.5)
end

function A.ApplyToListing(listing, role)
    if not listing then
        return nil, "请先选择一个团。"
    end
    if sameName(listing.leader, playerName()) then
        return nil, "不能申请自己发布的团。"
    end
    local localizedClass, token = UnitClass("player")
    local position = classIndex(token)
    local itemLevel = A.GetSelfItemLevel()
    if not position then
        return nil, "无法识别当前职业。"
    end
    if itemLevel < listing.minimumItemLevel then
        return nil, "当前装等 " .. itemLevel .. "，未达到要求 " .. listing.minimumItemLevel .. "。"
    end
    local payload = P.EncodeApplication(
        listing.id,
        listing.leader,
        role,
        itemLevel,
        position
    )
    if not queueDirected(payload) then
        return nil, "无法发送申请。"
    end
    A.applicationStates[listing.key] = "SENT"
    printMessage("已向 " .. listing.leader .. " 申请；装等为客户端自报值 " .. itemLevel .. "。")
    refreshUI()
    return 1
end

function A.InviteApplicant(application)
    if not application or not A.activeListing or not canPublish() then
        return nil, "当前无法邀请该玩家。"
    end
    InviteByName(application.name)
    queueDirected(P.EncodeResponse(
        A.activeListing.id,
        application.name,
        "INVITED"
    ))
    A.applications[string.lower(application.name)] = nil
    A.selectedApplicationName = nil
    refreshUI()
    return 1
end

function A.RejectApplicant(application)
    if not application or not A.activeListing then
        return nil, "请先选择一个申请者。"
    end
    queueDirected(P.EncodeResponse(
        A.activeListing.id,
        application.name,
        "REJECTED"
    ))
    A.applications[string.lower(application.name)] = nil
    A.selectedApplicationName = nil
    refreshUI()
    return 1
end

local eventFrame = CreateFrame("Frame", "AzerothExpeditionGroupFinderEventFrame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("CHAT_MSG_CHANNEL")
eventFrame:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE")
eventFrame:RegisterEvent("RAID_ROSTER_UPDATE")
eventFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
eventFrame:RegisterEvent("PARTY_LEADER_CHANGED")

eventFrame:SetScript("OnEvent", function()
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        AzerothExpeditionGroupFinderDB = AzerothExpeditionGroupFinderDB or {}
        AzerothExpeditionGroupFinderDB.draft = AzerothExpeditionGroupFinderDB.draft or {}
        local normalized = {}
        copyDefaults(normalized, AzerothExpeditionGroupFinderDB.draft)
        AzerothExpeditionGroupFinderDB.draft = normalized
    elseif event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
        A.nextJoinAt = 0
        A.RequestSync()
    elseif event == "CHAT_MSG_CHANNEL" then
        if handleChannelMessage(arg1, arg2, arg9) then
            handleDirectMessage(arg1, arg2)
        end
    elseif event == "CHAT_MSG_CHANNEL_NOTICE" then
        A.nextJoinAt = 0
    elseif event == "RAID_ROSTER_UPDATE" or event == "PARTY_MEMBERS_CHANGED"
        or event == "PARTY_LEADER_CHANGED" then
        updateActiveRoster()
    end
end)

eventFrame:SetScript("OnUpdate", function()
    local currentTime = now()
    if not A.nextJoinAt or currentTime >= A.nextJoinAt then
        ensureChannel()
        A.nextJoinAt = currentTime + 5
    end
    if A.channelJoined and table.getn(A.channelQueue) > 0
        and (not A.nextSendAt or currentTime >= A.nextSendAt) then
        local message = table.remove(A.channelQueue, 1)
        SendChatMessage(message, "CHANNEL", nil, A.channelId)
        A.nextSendAt = currentTime + SEND_INTERVAL_SECONDS
    end
    if A.activeListing and A.nextAnnounceAt and currentTime >= A.nextAnnounceAt then
        A.nextAnnounceAt = nil
        announceActive()
    elseif A.activeListing and A.nextHeartbeatAt and currentTime >= A.nextHeartbeatAt then
        announceActive()
    end
    if not A.nextPruneAt or currentTime >= A.nextPruneAt then
        pruneListings()
        A.nextPruneAt = currentTime + 5
    end
end)

SLASH_AEGF1 = "/aegf"
SlashCmdList.AEGF = function(message)
    message = string.lower(string.gsub(message or "", "^%s*(.-)%s*$", "%1"))
    if message == "sync" then
        A.RequestSync()
        printMessage("已请求刷新招募目录。")
    elseif message == "close" then
        A.CloseListing()
    elseif message == "help" then
        printMessage("/aegf 打开面板；/aegf sync 刷新；/aegf close 停止招募。")
    elseif A.UI and A.UI.Toggle then
        A.UI:Toggle()
    end
end
