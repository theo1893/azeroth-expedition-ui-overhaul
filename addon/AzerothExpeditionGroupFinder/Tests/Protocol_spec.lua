table.getn = table.getn or function(value) return #value end

dofile("addon/AzerothExpeditionGroupFinder/Protocol.lua")

local listing = {
    id = "abc-123",
    revision = 7,
    title = "熔火之心  ~ 速通",
    leaderInfo = "团长|: 示例",
    minimumItemLevel = 62,
    targetTanks = 2,
    targetHealers = 8,
    targetDamage = 30,
    currentPlayers = 17,
    currentClasses = { 3, 2, 2, 2, 2, 1, 2, 1, 2 },
    targetClasses = { 5, 4, 4, 5, 6, 4, 4, 4, 4 },
    competition = "风剑 4/5；毁灭之刃 2/3",
}

local encoded, errorMessage = AEGFProtocol.EncodeListing(listing)
assert(encoded, errorMessage)
local kind, decoded = AEGFProtocol.Decode(encoded)
assert(kind == "A" and decoded.id == listing.id)
assert(decoded.title == "熔火之心 速通")
assert(decoded.leaderInfo == "团长 : 示例")
assert(decoded.currentClasses[1] == 3 and decoded.targetClasses[9] == 4)
assert(AEGFProtocol.Decode("AEGF1~2~P~abc-123~白麒麟~X~60~1") == nil)
assert(AEGFProtocol.Decode("AEGF1~1~A~broken") == nil)

local application = AEGFProtocol.EncodeApplication("abc-123", "白麒麟", "N", 64, 5)
local applicationKind, applicationData = AEGFProtocol.Decode(application)
assert(applicationKind == "P" and applicationData.recipient == "白麒麟")
assert(applicationData.itemLevel == 64 and applicationData.classIndex == 5)
assert(string.lower(applicationData.recipient) ~= string.lower("大奶黑牛"))

local response = AEGFProtocol.EncodeResponse("abc-123", "大奶黑牛", "PENDING")
local responseKind, responseData = AEGFProtocol.Decode(response)
assert(responseKind == "R" and responseData.recipient == "大奶黑牛")
assert(responseData.state == "PENDING")
assert(string.lower(responseData.recipient) ~= string.lower("白麒麟"))

listing.targetDamage = 29
assert(AEGFProtocol.EncodeListing(listing) == nil)
listing.targetDamage = 30
listing.currentPlayers = 16
assert(AEGFProtocol.EncodeListing(listing) == nil)

print("PASS Protocol_spec")
