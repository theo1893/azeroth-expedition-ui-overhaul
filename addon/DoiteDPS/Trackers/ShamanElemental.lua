-- ============================================================================
-- DoiteDPS - Elemental Shaman state tracker
-- Preserves EleDPS clearcasting and Flame Shock/Lava Burst event handling.
-- ============================================================================

local D = DoiteDPS
local T = {}
D.Trackers.ShamanElemental = T

local CLEARCASTING_TEXTURE = "Interface\\Icons\\Spell_Shadow_ManaBurn"
local FLAME_SHOCK_TEXTURE = "Interface\\Icons\\Spell_Fire_FlameShock"
local SEARING_TOTEM_TEXTURE = "spell_fire_searingtotem"
local FIRE_NOVA_TOTEM_TEXTURE = "spell_fire_sealoffire"
local MAGMA_TOTEM_TEXTURE = "spell_fire_selfdestruct"
local FIRE_NOVA_BASE_ACTIVATION = 5

T.fsByGuid = {}
T.flameShockSpellIds = {}
T.lavaBurstSpellIds = {}
T.rekindleSpellIds = {}

local function Debug(message)
    if D.debugMode then
        D:Print(message)
    end
end

local function ClearTable(value)
    local key
    for key in pairs(value) do
        value[key] = nil
    end
end

local function SpellNameForId(spellId)
    if not spellId or not GetSpellNameAndRankForId then
        return nil
    end
    local ok, name = pcall(GetSpellNameAndRankForId, spellId)
    if ok then return name end
    return nil
end

local function IsImprovedFireTotemsName(name)
    if not name then return false end
    if name == "Improved Fire Totems"
        or name == "强化火焰图腾"
        or name == "強化火焰圖騰" then
        return true
    end

    local value = tostring(name)
    if string.find(value, "Improved")
        and string.find(value, "Fire")
        and string.find(value, "Totem") then
        return true
    end
    return string.find(value, "强化")
        and string.find(value, "火焰")
        and string.find(value, "图腾")
end

local function GetFireTotemKind(name, icon)
    local texture = string.lower(tostring(icon or ""))
    if name == D.Names.SEARING_TOTEM
        or string.find(texture, SEARING_TOTEM_TEXTURE, 1, true) then
        return "searing"
    elseif name == D.Names.FIRE_NOVA_TOTEM
        or string.find(texture, FIRE_NOVA_TOTEM_TEXTURE, 1, true) then
        return "nova"
    elseif name == D.Names.MAGMA_TOTEM
        or string.find(texture, MAGMA_TOTEM_TEXTURE, 1, true) then
        return "magma"
    end
    return "utility"
end

function T:RefreshImprovedFireTotems()
    if type(GetNumTalentTabs) ~= "function"
        or type(GetNumTalents) ~= "function"
        or type(GetTalentInfo) ~= "function" then
        return false
    end

    local tabCount = tonumber(GetNumTalentTabs()) or 0
    if tabCount <= 0 then return false end

    local sawTalent = false
    local detectedRank = 0
    local tab = 1
    while tab <= tabCount do
        local talentCount = tonumber(GetNumTalents(tab)) or 0
        local index = 1
        while index <= talentCount do
            local name, icon, tier, column, rank = GetTalentInfo(tab, index)
            if name and name ~= "" then
                sawTalent = true
                if IsImprovedFireTotemsName(name) then
                    detectedRank = tonumber(rank) or 0
                    tab = tabCount + 1
                    break
                end
            end
            index = index + 1
        end
        tab = tab + 1
    end

    if not sawTalent then return false end
    if detectedRank < 0 then detectedRank = 0 end
    if detectedRank > 2 then detectedRank = 2 end
    self.improvedFireTotemsRank = detectedRank
    return true
end

function T:GetImprovedFireTotemsRank()
    if self.improvedFireTotemsRank == nil then
        self:RefreshImprovedFireTotems()
    end
    return tonumber(self.improvedFireTotemsRank) or 0
end

function T:BuildFireTotemState(state)
    local talentRank = self:GetImprovedFireTotemsRank()
    state.improvedFireTotemsRank = talentRank
    state.fireNovaActivation = FIRE_NOVA_BASE_ACTIVATION - talentRank
    state.fireTotemStateAvailable = false
    state.fireTotemActive = false
    state.fireTotemKind = nil
    state.fireTotemName = nil
    state.fireTotemStart = nil
    state.fireTotemDuration = 0
    state.fireTotemRemaining = 0

    if type(GetTotemInfo) ~= "function" then return end

    local slot = FIRE_TOTEM_SLOT or 1
    local ok, active, name, startTime, duration, icon =
        pcall(GetTotemInfo, slot)
    if not ok then return end

    state.fireTotemStateAvailable = true
    if (active ~= true and active ~= 1) or not name then return end

    startTime = tonumber(startTime)
    duration = tonumber(duration)
    if not startTime or not duration or duration <= 0 then
        state.fireTotemStateAvailable = false
        return
    end

    local kind = GetFireTotemKind(name, icon)
    local effectiveDuration = duration
    if kind == "nova" then
        -- pfUI's vanilla Totem API emulation reports the original five-second
        -- lifetime. Improved Fire Totems changes the real activation to 4/3s.
        effectiveDuration = state.fireNovaActivation
    end

    local remaining = startTime + effectiveDuration
        - ((GetTime and GetTime()) or 0)
    if remaining <= 0.05 then return end

    state.fireTotemActive = true
    state.fireTotemKind = kind
    state.fireTotemName = name
    state.fireTotemStart = startTime
    state.fireTotemDuration = effectiveDuration
    state.fireTotemRemaining = remaining
end

function T:Reset()
    self.clearcastingRank = 0
    self.castSinceRankOne = false
    self.isCasting = false
    self.castFailed = false
    self.castSucceeded = false
    self.ccRankAtStart = 0
    self.castStartTime = 0
    self.castDuration = 0
    self.castSpellName = nil
    self.lavaBurstInFlight = 0
    self.lavaBurstCastPending = false
    self.lastCastReason = nil
    self.improvedFireTotemsRank = nil
    ClearTable(self.fsByGuid)
    ClearTable(self.flameShockSpellIds)
    ClearTable(self.lavaBurstSpellIds)
    ClearTable(self.rekindleSpellIds)
end

function T:SetLastCastReason(reason)
    self.lastCastReason = reason
end

function T:GetClearcastingRank()
    if self.clearcastingRank == 1 and self.castSinceRankOne then
        return 0
    end
    return self.clearcastingRank or 0
end

function T:ScanClearcasting()
    local i = 1
    while i <= 32 do
        local texture, applications = UnitBuff("player", i)
        if texture == CLEARCASTING_TEXTURE then
            return true, tonumber(applications) or 0
        end
        i = i + 1
    end
    return false, 0
end

function T:TargetHasFlameShock()
    local i = 1
    while i <= 32 do
        local texture = UnitDebuff("target", i)
        if not texture then break end
        if texture == FLAME_SHOCK_TEXTURE then
            return true
        end
        i = i + 1
    end
    return false
end

function T:GetFlameShockState()
    local targetGuid = D:GetUnitGUID("target")
    if not targetGuid then
        return 0, 0
    end

    local fs = self.fsByGuid[targetGuid]
    if not fs or not fs.appliedAt or not fs.fullDur then
        return 0, 0
    end

    if not self:TargetHasFlameShock() then
        self.fsByGuid[targetGuid] = nil
        return 0, 0
    end

    if fs.lvbPending and (GetTime() - fs.lvbPending) > 1.0 then
        self.fsByGuid[targetGuid] = nil
        self.lavaBurstInFlight = 0
        return 0, 0
    end

    local remaining = fs.fullDur - (GetTime() - fs.appliedAt)
    if remaining <= 0 then
        self.fsByGuid[targetGuid] = nil
        return 0, 0
    end
    return remaining, fs.fullDur
end

function T:GetLavaBurstTravelTime()
    local distance = D:GetDistance("target")
    if distance and distance > 0 then
        return 0.2 + (distance / 18.5)
    end
    return 1.5
end

function T:IsLavaBurstFlying()
    return self.lavaBurstInFlight and self.lavaBurstInFlight > 0
        and (GetTime() - self.lavaBurstInFlight) < 3
end

function T:PredictFlameShockRemaining(remaining, state)
    if not state.casting then
        return remaining
    end
    local castRemaining = tonumber(state.castRemaining) or 0
    return remaining - castRemaining
end

function T:BuildState(state)
    local fsRemaining, fsDuration = self:GetFlameShockState()
    local cast = state.cast or {}
    local eventRemaining = 0

    if self.isCasting and self.castDuration and self.castDuration > 0 then
        eventRemaining = self.castDuration - (GetTime() - self.castStartTime)
        if eventRemaining < 0 then eventRemaining = 0 end
    end

    state.resourceType = "mana"
    state.timingType = "shaman"
    state.clearcasting = self:GetClearcastingRank()
    state.flameShock = fsRemaining > 0
    state.flameShockRemaining = fsRemaining
    state.flameShockDuration = fsDuration
    state.lavaBurstFlying = self:IsLavaBurstFlying()
    state.lavaBurstTravel = self:GetLavaBurstTravelTime()
    state.casting = (cast.active or self.isCasting) and true or false
    state.castName = state.casting and
        (cast.name or self.castSpellName) or nil
    state.castRemaining = tonumber(cast.remaining) or 0
    state.castDuration = tonumber(cast.duration) or 0

    if state.castRemaining <= 0 then
        state.castRemaining = eventRemaining
    end
    if state.castDuration <= 0 then
        state.castDuration = tonumber(self.castDuration) or 0
    end

    self:BuildFireTotemState(state)

    local range = D:IsInRange("LIGHTNING_BOLT", "target")
    state.inRange = state.targetValid and range ~= false or false
    state.profileDB = D:GetProfileDB("SHAMAN_ELEMENTAL")
end

function T:OnUnitAura(unit)
    if unit ~= "player" then return end
    local hasClearcasting, rank = self:ScanClearcasting()

    if hasClearcasting then
        if rank == 2 and self.clearcastingRank ~= 2 then
            self.clearcastingRank = 2
            self.castSinceRankOne = false
            Debug("节能施法获得 2 层")
        elseif rank == 1 and self.clearcastingRank == 2 then
            self.clearcastingRank = 1
            self.castSinceRankOne = false
            Debug("节能施法消耗 2→1")
        elseif rank ~= 0 then
            self.clearcastingRank = rank
        end
    elseif self.clearcastingRank and self.clearcastingRank > 0 then
        self.clearcastingRank = 0
        self.castSinceRankOne = false
        Debug("节能施法消失")
    end
end

function T:OnAuraCast(spellIdValue, casterGuid, targetGuid, durationValue)
    local spellId = tonumber(spellIdValue) or 0
    local durationMs = tonumber(durationValue) or 0
    if spellId <= 0 or durationMs <= 0 or not targetGuid or targetGuid == "" then
        return
    end

    local playerGuid = D:GetUnitGUID("player")
    if not playerGuid or casterGuid ~= playerGuid then
        return
    end

    local spellName = SpellNameForId(spellId)
    if spellName ~= D.Names.FLAME_SHOCK then
        return
    end

    local duration = math.floor((durationMs / 1000) + 0.5)
    self.fsByGuid[targetGuid] = {
        appliedAt = GetTime(),
        fullDur = duration,
        spellId = spellId,
    }
    self.flameShockSpellIds[spellId] = true
    Debug("烈焰震击追踪 " .. tostring(duration) .. "s")
end

function T:OnSpellDamage(targetGuid, casterGuid, spellIdValue)
    local spellId = tonumber(spellIdValue) or 0
    if spellId <= 0 then return end

    local playerGuid = D:GetUnitGUID("player")
    if not playerGuid or casterGuid ~= playerGuid then
        return
    end

    local isRekindle = self.rekindleSpellIds[spellId]
    if isRekindle == nil then
        isRekindle = SpellNameForId(spellId) == "重燃烈火"
        self.rekindleSpellIds[spellId] = isRekindle
    end

    if isRekindle then
        self.lavaBurstInFlight = 0
        if not targetGuid or targetGuid == "" then
            targetGuid = D:GetUnitGUID("target")
        end
        local fs = targetGuid and self.fsByGuid[targetGuid]
        if fs and fs.fullDur and fs.fullDur > 0 then
            fs.appliedAt = GetTime()
            fs.lvbPending = nil
            Debug("重燃烈火确认刷新烈焰震击")
        end
        return
    end

    local isLavaBurst = self.lavaBurstSpellIds[spellId]
    if isLavaBurst == nil then
        isLavaBurst = SpellNameForId(spellId) == D.Names.LAVA_BURST
        self.lavaBurstSpellIds[spellId] = isLavaBurst
    end
    if not isLavaBurst then return end

    if not targetGuid or targetGuid == "" then
        targetGuid = D:GetUnitGUID("target")
    end
    local fs = targetGuid and self.fsByGuid[targetGuid]
    if fs and fs.appliedAt and fs.fullDur and fs.fullDur > 0 then
        fs.lvbPending = GetTime()
        Debug("熔岩爆裂命中，等待重燃烈火")
    end
end

function T:OnEvent(eventName, a1, a2, a3, a4, a5, a6, a7, a8, a9)
    if eventName == "PLAYER_ENTERING_WORLD" or eventName == "PLAYER_LOGIN" then
        self:Reset()
        self:RefreshImprovedFireTotems()
        self:OnUnitAura("player")
    elseif eventName == "CHARACTER_POINTS_CHANGED"
        or eventName == "SPELLS_CHANGED" then
        self.improvedFireTotemsRank = nil
        self:RefreshImprovedFireTotems()
    elseif eventName == "SPELLCAST_START" then
        if self.lavaBurstCastPending and a1 ~= D.Names.LAVA_BURST then
            self.lavaBurstInFlight = GetTime()
            self.lavaBurstCastPending = false
        end
        self.isCasting = true
        self.castFailed = false
        self.castSucceeded = false
        self.ccRankAtStart = self.clearcastingRank or 0
        self.castStartTime = GetTime()
        self.castDuration = (tonumber(a2) or 0) / 1000
        self.castSpellName = a1
        if self.lastCastReason then
            Debug(tostring(a1) .. "：" .. tostring(self.lastCastReason))
            self.lastCastReason = nil
        end
        if a1 == D.Names.LAVA_BURST then
            self.lavaBurstCastPending = true
        end
    elseif eventName == "SPELLCAST_STOP" then
        if self.isCasting and not self.castFailed then
            self.castSucceeded = true
            if self.lavaBurstCastPending then
                self.lavaBurstInFlight = GetTime()
                self.lavaBurstCastPending = false
            end
            if self.clearcastingRank == 1 and self.ccRankAtStart == 1 then
                self.castSinceRankOne = true
            end
        end
        self.isCasting = false
        self.castFailed = false
        self.castSpellName = nil
        self.castDuration = 0
    elseif eventName == "SPELLCAST_FAILED"
        or eventName == "SPELLCAST_INTERRUPTED" then
        self.castFailed = true
        if self.castSucceeded and self.clearcastingRank == 1
            and self.ccRankAtStart == 1 then
            self.castSinceRankOne = false
        end
        self.castSucceeded = false
        self.lavaBurstCastPending = false
        self.lastCastReason = nil
    elseif eventName == "UNIT_AURA" then
        self:OnUnitAura(a1)
    elseif eventName == "AURA_CAST_ON_OTHER" then
        self:OnAuraCast(a1, a2, a3, a8)
    elseif eventName == "SPELL_DAMAGE_EVENT_SELF" then
        self:OnSpellDamage(a1, a2, a3)
    elseif eventName == "PLAYER_TARGET_CHANGED" then
        local targetGuid = D:GetUnitGUID("target")
        local fs = targetGuid and self.fsByGuid[targetGuid]
        if fs and fs.appliedAt and fs.fullDur
            and (fs.fullDur - (GetTime() - fs.appliedAt)) <= 0 then
            self.fsByGuid[targetGuid] = nil
        end
    end
end

T:Reset()
