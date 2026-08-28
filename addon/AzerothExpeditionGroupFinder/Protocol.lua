AEGFProtocol = AEGFProtocol or {}

local P = AEGFProtocol
local PREFIX = "AEGF1"
local VERSION = "2"
local MAX_MESSAGE = 230

P.classTokens = {
    "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST",
    "SHAMAN", "MAGE", "WARLOCK", "DRUID",
}

P.classLabels = { "战", "骑", "猎", "贼", "牧", "萨", "法", "术", "德" }

local function isInteger(value, minimum, maximum)
    return value and value == math.floor(value) and value >= minimum and value <= maximum
end

local function readInteger(value, minimum, maximum)
    local number = tonumber(value)
    if not isInteger(number, minimum, maximum) then
        return nil
    end
    return number
end

local function split(value, separator)
    local fields = {}
    local first = 1
    local index = 1
    while true do
        local last = string.find(value, separator, first)
        if not last then
            fields[index] = string.sub(value, first)
            return fields
        end
        fields[index] = string.sub(value, first, last - 1)
        index = index + 1
        first = last + 1
    end
end

local function cleanText(value, maximum)
    value = tostring(value or "")
    value = string.gsub(value, "[%c~|]", " ")
    value = string.gsub(value, "%s+", " ")
    value = string.gsub(value, "^%s+", "")
    value = string.gsub(value, "%s+$", "")
    if string.len(value) > maximum then
        return nil
    end
    return value
end

local function validText(value, maximum)
    if type(value) ~= "string" or string.len(value) > maximum then
        return nil
    end
    if string.find(value, "[%c~|]") then
        return nil
    end
    return value
end

local function validId(value)
    if type(value) ~= "string" or string.len(value) < 1 or string.len(value) > 24 then
        return nil
    end
    if not string.find(value, "^[%w%-]+$") then
        return nil
    end
    return value
end

local function encodeVector(values)
    local output = {}
    local total = 0
    local index
    for index = 1, 9 do
        local value = values and tonumber(values[index]) or nil
        if not isInteger(value, 0, 40) then
            return nil
        end
        output[index] = tostring(value)
        total = total + value
    end
    return table.concat(output, ","), total
end

local function decodeVector(value)
    local fields = split(value or "", ",")
    local output = {}
    local total = 0
    local index
    for index = 1, 9 do
        local count = readInteger(fields[index], 0, 40)
        if not count then
            return nil
        end
        output[index] = count
        total = total + count
    end
    if fields[10] then
        return nil
    end
    return output, total
end

local function finish(fields)
    local message = table.concat(fields, "~")
    if string.len(message) > MAX_MESSAGE then
        return nil, "信息过长，请缩短团名、团长说明或装备竞争摘要。"
    end
    return message
end

function P.EncodeListing(listing)
    local id = validId(listing and listing.id)
    local revision = readInteger(listing and listing.revision, 1, 9999999)
    local title = cleanText(listing and listing.title, 42)
    local leaderInfo = cleanText(listing and listing.leaderInfo, 42)
    local minimumItemLevel = readInteger(listing and listing.minimumItemLevel, 0, 999)
    local targetTanks = readInteger(listing and listing.targetTanks, 0, 40)
    local targetHealers = readInteger(listing and listing.targetHealers, 0, 40)
    local targetDamage = readInteger(listing and listing.targetDamage, 0, 40)
    local currentPlayers = readInteger(listing and listing.currentPlayers, 1, 40)
    local currentClasses, currentClassTotal = encodeVector(listing and listing.currentClasses)
    local targetClasses, targetClassTotal = encodeVector(listing and listing.targetClasses)
    local competition = cleanText(listing and listing.competition, 72)

    if not id or not revision or not title or title == "" or not leaderInfo
        or not minimumItemLevel or not targetTanks or not targetHealers
        or not targetDamage or not currentPlayers or not currentClasses
        or not targetClasses or not competition then
        return nil, "开团信息格式不正确。"
    end

    local roleTotal = targetTanks + targetHealers + targetDamage
    if roleTotal < 1 or roleTotal > 40 or targetClassTotal ~= roleTotal
        or currentClassTotal ~= currentPlayers then
        return nil, "职业上限总数必须等于 T/N/D 总数，且总人数为 1 到 40。"
    end

    return finish({
        PREFIX, VERSION, "A", id, tostring(revision), title, leaderInfo,
        tostring(minimumItemLevel), tostring(targetTanks), tostring(targetHealers),
        tostring(targetDamage), tostring(currentPlayers), currentClasses,
        targetClasses, competition,
    })
end

function P.EncodeQuery()
    return PREFIX .. "~" .. VERSION .. "~Q"
end

function P.EncodeClose(id)
    id = validId(id)
    if not id then
        return nil
    end
    return PREFIX .. "~" .. VERSION .. "~C~" .. id
end

function P.EncodeApplication(id, recipient, role, itemLevel, classIndex)
    id = validId(id)
    recipient = validText(recipient, 48)
    itemLevel = readInteger(itemLevel, 0, 999)
    classIndex = readInteger(classIndex, 1, 9)
    if not id or not recipient or recipient == ""
        or (role ~= "T" and role ~= "N" and role ~= "D")
        or not itemLevel or not classIndex then
        return nil
    end
    return table.concat({
        PREFIX, VERSION, "P", id, recipient, role,
        tostring(itemLevel), tostring(classIndex),
    }, "~")
end

function P.EncodeResponse(id, recipient, state)
    id = validId(id)
    recipient = validText(recipient, 48)
    if not id or not recipient or recipient == ""
        or (state ~= "PENDING" and state ~= "INVITED"
        and state ~= "REJECTED" and state ~= "CLOSED") then
        return nil
    end
    return table.concat({ PREFIX, VERSION, "R", id, recipient, state }, "~")
end

function P.Decode(message)
    if type(message) ~= "string" or string.len(message) > MAX_MESSAGE then
        return nil
    end
    local fields = split(message, "~")
    if fields[1] ~= PREFIX or fields[2] ~= VERSION then
        return nil
    end

    local kind = fields[3]
    if kind == "Q" and not fields[4] then
        return kind, {}
    end
    if kind == "C" and validId(fields[4]) and not fields[5] then
        return kind, { id = fields[4] }
    end
    if kind == "P" and validId(fields[4]) and not fields[9] then
        local recipient = validText(fields[5], 48)
        local itemLevel = readInteger(fields[7], 0, 999)
        local classIndex = readInteger(fields[8], 1, 9)
        if recipient and recipient ~= ""
            and (fields[6] == "T" or fields[6] == "N" or fields[6] == "D")
            and itemLevel and classIndex then
            return kind, {
                id = fields[4], recipient = recipient, role = fields[6],
                itemLevel = itemLevel, classIndex = classIndex,
            }
        end
        return nil
    end
    if kind == "R" and validId(fields[4]) and not fields[7] then
        local recipient = validText(fields[5], 48)
        local state = fields[6]
        if recipient and recipient ~= ""
            and (state == "PENDING" or state == "INVITED"
                or state == "REJECTED" or state == "CLOSED") then
            return kind, { id = fields[4], recipient = recipient, state = state }
        end
        return nil
    end
    if kind ~= "A" or fields[16] then
        return nil
    end

    local revision = readInteger(fields[5], 1, 9999999)
    local title = validText(fields[6], 42)
    local leaderInfo = validText(fields[7], 42)
    local minimumItemLevel = readInteger(fields[8], 0, 999)
    local targetTanks = readInteger(fields[9], 0, 40)
    local targetHealers = readInteger(fields[10], 0, 40)
    local targetDamage = readInteger(fields[11], 0, 40)
    local currentPlayers = readInteger(fields[12], 1, 40)
    local currentClasses, currentClassTotal = decodeVector(fields[13])
    local targetClasses, targetClassTotal = decodeVector(fields[14])
    local competition = validText(fields[15], 72)

    if not validId(fields[4]) or not revision or not title or title == ""
        or not leaderInfo or not minimumItemLevel or not targetTanks
        or not targetHealers or not targetDamage or not currentPlayers
        or not currentClasses or not targetClasses or not competition then
        return nil
    end

    local roleTotal = targetTanks + targetHealers + targetDamage
    if roleTotal < 1 or roleTotal > 40 or targetClassTotal ~= roleTotal
        or currentClassTotal ~= currentPlayers then
        return nil
    end

    return kind, {
        id = fields[4], revision = revision, title = title, leaderInfo = leaderInfo,
        minimumItemLevel = minimumItemLevel, targetTanks = targetTanks,
        targetHealers = targetHealers, targetDamage = targetDamage,
        currentPlayers = currentPlayers, currentClasses = currentClasses,
        targetClasses = targetClasses, competition = competition,
    }
end

function P.ParseClassVector(value)
    return decodeVector(value)
end

function P.FormatClassVector(values)
    local parts = {}
    local outputIndex = 1
    local index
    for index = 1, 9 do
        local count = values and tonumber(values[index]) or 0
        if count > 0 then
            parts[outputIndex] = P.classLabels[index] .. tostring(count)
            outputIndex = outputIndex + 1
        end
    end
    if outputIndex == 1 then
        return "无"
    end
    return table.concat(parts, " ")
end
