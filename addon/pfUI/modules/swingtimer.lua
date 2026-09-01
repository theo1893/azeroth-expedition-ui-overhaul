pfUI:RegisterModule("swingtimer", "vanilla:tbc", function ()
  local rawborder, border = GetBorderSize()

local L = pfUI.L or (pfUI_translation and pfUI_translation[GetLocale()]) or {} 																												 
  -- HitInfo flags (EVENTS.md)
  local HITINFO_LEFTSWING  = 4      -- 4: Off-hand attack
  local HITINFO_MISS       = 16     -- 16: Miss
  local HITINFO_NOACTION   = 65536  -- 65536: server did not advance the swing clock
  local STALL_THRESHOLD    = 0.30

  -- SPELL_QUEUE_EVENT codes (EVENTS.md)
  local ON_SWING_QUEUED       = 0
  local ON_SWING_QUEUE_POPPED = 1

  -- Consolidate state into a table to avoid Lua 5.0 upvalue limit (32 max)
  local S = {
    mhTimer = 0, mhTimerMax = 1,
    ohTimer = 0, ohTimerMax = 1,
    raTimer = 0, raTimerMax = 1,
    mhSpeed = 0, ohSpeed = 0, raSpeed = 0,
    mhActive = false, ohActive = false, raActive = false,
    lastMhMarkerX = -1, lastOhMarkerX = -1, lastRaMarkerX = -1,
    autoAttackActive = false,
    inCombat = false,
    pendingCastSpellId = nil,
    mhFrozenAt = nil,
    hsQueued = false, cleaveQueued = false,
    isWarrior = false,
    cachedHSSlots = {}, cachedCleaveSlots = {},
    useSpellQueueEvent = false,
    playerGUID = nil,
    swingThrottle = 0,
    onSwingCache = {},
    speedSyncUntil = nil,
    mhZeroAt = nil,
    mhStallAt = nil,
    traceFile = nil,
    traceSessionEpoch = nil,
    traceWriteFailed = false,
    traceWarned = false,
  }

  local function DisableTrace(reason)
    S.traceWriteFailed = true
    if S.traceWarned then return end
    S.traceWarned = true
    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
      DEFAULT_CHAT_FRAME:AddMessage(
        "|cffff8080DDPS swing trace disabled: " .. tostring(reason) .. "|r"
      )
    end
  end

  local function TraceState()
    return string.format(
      "mhActive=%s mhRem=%.3f mhMax=%.3f mhSpeed=%.3f combat=%s auto=%s hs=%s cleave=%s",
      tostring(S.mhActive),
      tonumber(S.mhTimer) or 0,
      tonumber(S.mhTimerMax) or 0,
      tonumber(S.mhSpeed) or 0,
      tostring(S.inCombat),
      tostring(S.autoAttackActive),
      tostring(S.hsQueued),
      tostring(S.cleaveQueued)
    )
  end

  local function EnsureTraceFile()
    if not S.isWarrior or S.traceWriteFailed then return nil end
    if S.traceFile then return S.traceFile end
    if type(WriteCustomFile) ~= "function" then
      DisableTrace("Nampower WriteCustomFile is unavailable")
      return nil
    end
    if type(time) ~= "function" or type(date) ~= "function" then
      DisableTrace("client time/date API is unavailable")
      return nil
    end

    -- GetTime survives /reload and measures this client process. Cache the
    -- estimated process start so integer wall-clock rounding cannot rename the
    -- file after a UI reload.
    local estimatedSessionEpoch = math.floor(time() - GetTime() + 0.5)
    pfUI_cache = pfUI_cache or {}
    local traceCache = pfUI_cache.ddpsSwingTrace
    if traceCache and tonumber(traceCache.sessionEpoch)
      and math.abs(tonumber(traceCache.sessionEpoch) - estimatedSessionEpoch) <= 2 then
      S.traceSessionEpoch = tonumber(traceCache.sessionEpoch)
    else
      S.traceSessionEpoch = estimatedSessionEpoch
      pfUI_cache.ddpsSwingTrace = { sessionEpoch = S.traceSessionEpoch }
    end
    local sessionStamp = date("%Y%m%d-%H%M%S", S.traceSessionEpoch)
    S.traceFile = "ddps-swing-" .. sessionStamp .. ".log"

    local nampowerVersion = "unavailable"
    if type(GetNampowerVersion) == "function" then
      local ok, major, minor, patch = pcall(GetNampowerVersion)
      if ok then
        nampowerVersion = string.format(
          "%s.%s.%s",
          tostring(major or 0),
          tostring(minor or 0),
          tostring(patch or 0)
        )
      end
    end
    local header = string.format(
      "# DDPS_SWING_TRACE version=1 clientStart=%s clientStartEpoch=%d nampower=%s\n",
      date("%Y-%m-%dT%H:%M:%S", S.traceSessionEpoch),
      S.traceSessionEpoch,
      nampowerVersion
    )
    local ok, reason = pcall(WriteCustomFile, S.traceFile, header, "a")
    if not ok then
      S.traceFile = nil
      DisableTrace(reason)
      return nil
    end
    return S.traceFile
  end

  local function Trace(kind, detail)
    local fileName = EnsureTraceFile()
    if not fileName then return false end
    local line = string.format(
      "%s uptime=%.3f event=%s %s %s\n",
      date("%Y-%m-%dT%H:%M:%S"),
      GetTime(),
      tostring(kind or "UNKNOWN"),
      tostring(detail or ""),
      TraceState()
    )
    local ok, reason = pcall(WriteCustomFile, fileName, line, "a")
    if not ok then DisableTrace(reason) end
    return ok
  end

  local function EndMHStall(reason)
    if S.mhStallAt then
      Trace("STALL_EXIT", string.format(
        "duration=%.3f cause=%s",
        GetTime() - S.mhStallAt,
        tostring(reason or "unknown")
      ))
    end
    S.mhZeroAt = nil
    S.mhStallAt = nil
  end

  -- Ranged spell IDs
  local RANGED_SPELLIDS = {
    [75]   = true,  -- Auto Shot (Hunter)
    [2764] = true,  -- Throw (Warrior/Rogue)
  }

  -- Slam: has cast time but does NOT reset the swing timer (just delays it).
  -- Turtle WoW may use custom spell IDs for reworked ranks, so keep the
  -- vanilla IDs as a fast path and also identify Slam by its SpellRec name.
  local slamSpellIDs = {
    [1464] = true, [8820] = true, [11604] = true, [11605] = true,
    [45961] = true, -- Turtle WoW reworked Slam
  }

  local function GetSpellRecordName(spellId)
    if not spellId then return nil end
    if GetSpellRecField then
      return GetSpellRecField(spellId, "name")
    end
    local rec = GetSpellRec and GetSpellRec(spellId)
    return rec and rec.name or nil
  end

  local slamSpellNames = {
    ["Slam"] = true,
    ["猛击"] = true,
  }
  local localizedSlamName = GetSpellRecordName(1464)
  if localizedSlamName then slamSpellNames[localizedSlamName] = true end

  local function IsSlamSpell(spellId)
    if slamSpellIDs[spellId] then return true end
    local spellName = GetSpellRecordName(spellId)
    return spellName and slamSpellNames[spellName] or false
  end

  -- SPELL_ATTR_ON_NEXT_SWING (bit 2, value 4): spell replaces next auto-attack swing.
  -- Covers Raptor Strike, Maul, Mongoose Bite, Holy Strike, etc. automatically.
  local ATTR_ON_NEXT_SWING = 4
  local function IsOnSwingSpell(spellId)
    if S.onSwingCache[spellId] ~= nil then return S.onSwingCache[spellId] end
    local rec = GetSpellRec(spellId)
    local result = rec and bit.band(rec.attributes, ATTR_ON_NEXT_SWING) ~= 0 or false
    S.onSwingCache[spellId] = result
    return result
  end

  -- Heroic Strike spell IDs (all ranks)
  local hsSpellIDs = {
    [78] = true, [284] = true, [285] = true, [1608] = true,
    [11564] = true, [11565] = true, [11566] = true, [11567] = true,
    [25286] = true,
  }

  -- Cleave spell IDs (all ranks)
  local cleaveSpellIDs = {
    [845] = true, [7369] = true, [11608] = true, [11609] = true,
    [20569] = true,
  }

  -- Read config
  local sw_enabled   = C.unitframes.swingtimer ~= "0"	
  if not sw_enabled then return end
  local sw_width     = tonumber(C.unitframes.swingtimerwidth) or 200
  local sw_height    = tonumber(C.unitframes.swingtimerheight) or 12
  local sw_texture   = C.unitframes.swingtimertexture or "Interface\\AddOns\\pfUI\\img\\bar"
  local sw_showtext  = C.unitframes.swingtimertext ~= "0"
  local sw_showlabel = C.unitframes.swingtimerlabel ~= "0"
  local sw_showoh    = C.unitframes.swingtimeroffhand ~= "0"
  local sw_showranged = C.unitframes.swingtimerranged ~= "0"
  local sw_fontsize  = tonumber(C.unitframes.swingtimerfontsize) or 12
  local sw_hsqueue   = C.unitframes.swingtimerhsqueue ~= "0"
  local sw_showspeed = C.unitframes.swingtimerattackspeed == "1"
  local sw_rangeindicator = C.unitframes.swingtimerrangeindicator == "1"
  local WINGCLIP_ID   = 2974  -- ~5 yd melee
  local ARCANESHOT_ID = 3044  -- ~8-41 yd ranged (Hunter only)
  local _, playerClass = UnitClass("player")											

  local function ParseColor(str, dr, dg, db, da)
    if not str or str == "" then return dr, dg, db, da end
    local _, _, r, g, b, a = string.find(str, "([%d%.]+),([%d%.]+),([%d%.]+),([%d%.]+)")
    if r then
      return tonumber(r) or dr, tonumber(g) or dg, tonumber(b) or db, tonumber(a) or da
    end
    return dr, dg, db, da
  end

  local mhR, mhG, mhB, mhA = ParseColor(C.unitframes.swingtimermhcolor, 0.8, 0.3, 0.3, 1)
  local ohR, ohG, ohB, ohA = ParseColor(C.unitframes.swingtimerohcolor, 0.3, 0.8, 0.3, 1)
  local raR, raG, raB, raA = ParseColor(C.unitframes.swingtimerrangedcolor, 0.3, 0.6, 1.0, 1)
  local rwR, rwG, rwB, rwA = ParseColor(C.unitframes.swingtimerrangedwarncolor, 0.9, 0.0, 0.0, 1)
  local mhDefaultR, mhDefaultG, mhDefaultB = mhR, mhG, mhB

  -- Create container frame
  pfUI.swingtimer = CreateFrame("Frame", "pfSwingTimer", UIParent)
  pfUI.swingtimer:SetFrameStrata("MEDIUM")
  pfUI.swingtimer:Hide()

  -- Mainhand bar
  pfUI.swingtimer.mainhand = CreateFrame("StatusBar", "pfSwingTimerMainhand", UIParent)
  pfUI.swingtimer.mainhand:SetPoint("CENTER", UIParent, "CENTER", 0, -100)
  pfUI.swingtimer.mainhand:SetWidth(sw_width)
  pfUI.swingtimer.mainhand:SetHeight(sw_height)
  pfUI.swingtimer.mainhand:SetMinMaxValues(0, 1)
  pfUI.swingtimer.mainhand:SetValue(0)
  pfUI.swingtimer.mainhand:SetStatusBarTexture(sw_texture)
  pfUI.swingtimer.mainhand:SetStatusBarColor(mhR, mhG, mhB, mhA)
  pfUI.swingtimer.mainhand:Hide()

  pfUI.swingtimer.mainhand.text = pfUI.swingtimer.mainhand:CreateFontString("Status", "DIALOG", "GameFontNormal")
  pfUI.swingtimer.mainhand.text:SetPoint("CENTER", pfUI.swingtimer.mainhand, "CENTER", 0, 0)
  pfUI.swingtimer.mainhand.text:SetFont(pfUI.font_default, sw_fontsize, "OUTLINE")
  pfUI.swingtimer.mainhand.text:SetTextColor(1, 1, 1, 1)
  pfUI.swingtimer.mainhand.text:SetText("")
  if not sw_showtext then pfUI.swingtimer.mainhand.text:Hide() end

  pfUI.swingtimer.mainhand.label = pfUI.swingtimer.mainhand:CreateFontString("Status", "DIALOG", "GameFontNormal")
  pfUI.swingtimer.mainhand.label:SetPoint("RIGHT", pfUI.swingtimer.mainhand, "LEFT", -4, 0)
  pfUI.swingtimer.mainhand.label:SetFont(pfUI.font_default, sw_fontsize, "OUTLINE")
  pfUI.swingtimer.mainhand.label:SetTextColor(0.8, 0.8, 0.8, 1)
  pfUI.swingtimer.mainhand.label:SetText(sw_showlabel and L["MH"] or "")

  pfUI.swingtimer.mainhand.speed = pfUI.swingtimer.mainhand:CreateFontString("Status", "DIALOG", "GameFontNormal")
  pfUI.swingtimer.mainhand.speed:SetPoint("LEFT", pfUI.swingtimer.mainhand, "RIGHT", 4, 0)
  pfUI.swingtimer.mainhand.speed:SetFont(pfUI.font_default, sw_fontsize, "OUTLINE")
  pfUI.swingtimer.mainhand.speed:SetTextColor(0.8, 0.8, 0.8, 1)
  pfUI.swingtimer.mainhand.speed:SetText("")
  if not sw_showspeed then pfUI.swingtimer.mainhand.speed:Hide() end

  CreateBackdrop(pfUI.swingtimer.mainhand)


  pfUI.swingtimer.mainhand.marker = pfUI.swingtimer.mainhand:CreateTexture(nil, "OVERLAY")
  pfUI.swingtimer.mainhand.marker:SetTexture(1, 1, 1, 1.0)
  pfUI.swingtimer.mainhand.marker:SetWidth(2)
  pfUI.swingtimer.mainhand.marker:SetHeight(sw_height)
  pfUI.swingtimer.mainhand.marker:Hide()

  -- Left glow: fades from transparent to white (right edge = marker)
  pfUI.swingtimer.mainhand.markerGlowL = pfUI.swingtimer.mainhand:CreateTexture(nil, "OVERLAY")
  pfUI.swingtimer.mainhand.markerGlowL:SetTexture(1, 1, 1, 1)
  pfUI.swingtimer.mainhand.markerGlowL:SetGradientAlpha("HORIZONTAL", 1, 1, 1, 0, 1, 1, 1, 0.35)
  pfUI.swingtimer.mainhand.markerGlowL:SetWidth(10)
  pfUI.swingtimer.mainhand.markerGlowL:SetHeight(sw_height)
  pfUI.swingtimer.mainhand.markerGlowL:Hide()

  -- Right glow: fades from white to transparent (left edge = marker)
  pfUI.swingtimer.mainhand.markerGlowR = pfUI.swingtimer.mainhand:CreateTexture(nil, "OVERLAY")
  pfUI.swingtimer.mainhand.markerGlowR:SetTexture(1, 1, 1, 1)
  pfUI.swingtimer.mainhand.markerGlowR:SetGradientAlpha("HORIZONTAL", 1, 1, 1, 0.35, 1, 1, 1, 0)
  pfUI.swingtimer.mainhand.markerGlowR:SetWidth(10)
  pfUI.swingtimer.mainhand.markerGlowR:SetHeight(sw_height)
  pfUI.swingtimer.mainhand.markerGlowR:Hide()

  CreateBackdropShadow(pfUI.swingtimer.mainhand)

  -- Offhand bar
  pfUI.swingtimer.offhand = CreateFrame("StatusBar", "pfSwingTimerOffhand", UIParent)
  pfUI.swingtimer.offhand:SetPoint("TOP", pfUI.swingtimer.mainhand, "BOTTOM", 0, -4)
  pfUI.swingtimer.offhand:SetWidth(sw_width)
  pfUI.swingtimer.offhand:SetHeight(sw_height)
  pfUI.swingtimer.offhand:SetMinMaxValues(0, 1)
  pfUI.swingtimer.offhand:SetValue(0)
  pfUI.swingtimer.offhand:SetStatusBarTexture(sw_texture)
  pfUI.swingtimer.offhand:SetStatusBarColor(ohR, ohG, ohB, ohA)
  pfUI.swingtimer.offhand:Hide()

  pfUI.swingtimer.offhand.text = pfUI.swingtimer.offhand:CreateFontString("Status", "DIALOG", "GameFontNormal")
  pfUI.swingtimer.offhand.text:SetPoint("CENTER", pfUI.swingtimer.offhand, "CENTER", 0, 0)
  pfUI.swingtimer.offhand.text:SetFont(pfUI.font_default, sw_fontsize, "OUTLINE")
  pfUI.swingtimer.offhand.text:SetTextColor(1, 1, 1, 1)
  pfUI.swingtimer.offhand.text:SetText("")
  if not sw_showtext then pfUI.swingtimer.offhand.text:Hide() end

  pfUI.swingtimer.offhand.label = pfUI.swingtimer.offhand:CreateFontString("Status", "DIALOG", "GameFontNormal")
  pfUI.swingtimer.offhand.label:SetPoint("RIGHT", pfUI.swingtimer.offhand, "LEFT", -4, 0)
  pfUI.swingtimer.offhand.label:SetFont(pfUI.font_default, sw_fontsize, "OUTLINE")
  pfUI.swingtimer.offhand.label:SetTextColor(0.8, 0.8, 0.8, 1)
  pfUI.swingtimer.offhand.label:SetText(sw_showlabel and L["OH"] or "")

  pfUI.swingtimer.offhand.speed = pfUI.swingtimer.offhand:CreateFontString("Status", "DIALOG", "GameFontNormal")
  pfUI.swingtimer.offhand.speed:SetPoint("LEFT", pfUI.swingtimer.offhand, "RIGHT", 4, 0)
  pfUI.swingtimer.offhand.speed:SetFont(pfUI.font_default, sw_fontsize, "OUTLINE")
  pfUI.swingtimer.offhand.speed:SetTextColor(0.8, 0.8, 0.8, 1)
  pfUI.swingtimer.offhand.speed:SetText("")
  if not sw_showspeed then pfUI.swingtimer.offhand.speed:Hide() end

  CreateBackdrop(pfUI.swingtimer.offhand)


  pfUI.swingtimer.offhand.marker = pfUI.swingtimer.offhand:CreateTexture(nil, "OVERLAY")
  pfUI.swingtimer.offhand.marker:SetTexture(1, 1, 1, 1.0)
  pfUI.swingtimer.offhand.marker:SetWidth(2)
  pfUI.swingtimer.offhand.marker:SetHeight(sw_height)
  pfUI.swingtimer.offhand.marker:Hide()

  -- Left glow: fades from transparent to white (right edge = marker)
  pfUI.swingtimer.offhand.markerGlowL = pfUI.swingtimer.offhand:CreateTexture(nil, "OVERLAY")
  pfUI.swingtimer.offhand.markerGlowL:SetTexture(1, 1, 1, 1)
  pfUI.swingtimer.offhand.markerGlowL:SetGradientAlpha("HORIZONTAL", 1, 1, 1, 0, 1, 1, 1, 0.35)
  pfUI.swingtimer.offhand.markerGlowL:SetWidth(10)
  pfUI.swingtimer.offhand.markerGlowL:SetHeight(sw_height)
  pfUI.swingtimer.offhand.markerGlowL:Hide()

  -- Right glow: fades from white to transparent (left edge = marker)
  pfUI.swingtimer.offhand.markerGlowR = pfUI.swingtimer.offhand:CreateTexture(nil, "OVERLAY")
  pfUI.swingtimer.offhand.markerGlowR:SetTexture(1, 1, 1, 1)
  pfUI.swingtimer.offhand.markerGlowR:SetGradientAlpha("HORIZONTAL", 1, 1, 1, 0.35, 1, 1, 1, 0)
  pfUI.swingtimer.offhand.markerGlowR:SetWidth(10)
  pfUI.swingtimer.offhand.markerGlowR:SetHeight(sw_height)
  pfUI.swingtimer.offhand.markerGlowR:Hide()

  CreateBackdropShadow(pfUI.swingtimer.offhand)

  -- Ranged bar
  pfUI.swingtimer.ranged = CreateFrame("Frame", "pfSwingTimerRanged", UIParent)
  pfUI.swingtimer.ranged:SetPoint("CENTER", UIParent, "CENTER", 0, -120)
  pfUI.swingtimer.ranged:SetWidth(sw_width)
  pfUI.swingtimer.ranged:SetHeight(sw_height)
  pfUI.swingtimer.ranged:Hide()

  pfUI.swingtimer.ranged.left = pfUI.swingtimer.ranged:CreateTexture(nil, "ARTWORK")
  pfUI.swingtimer.ranged.left:SetTexture(sw_texture)
  pfUI.swingtimer.ranged.left:SetPoint("RIGHT", pfUI.swingtimer.ranged, "CENTER", 0, 0)
  pfUI.swingtimer.ranged.left:SetHeight(sw_height)
  pfUI.swingtimer.ranged.left:SetWidth(sw_width / 2)
  pfUI.swingtimer.ranged.left:SetTexCoord(0, 0.5, 0, 1)
  pfUI.swingtimer.ranged.left:SetVertexColor(raR, raG, raB, raA)

  pfUI.swingtimer.ranged.right = pfUI.swingtimer.ranged:CreateTexture(nil, "ARTWORK")
  pfUI.swingtimer.ranged.right:SetTexture(sw_texture)
  pfUI.swingtimer.ranged.right:SetPoint("LEFT", pfUI.swingtimer.ranged, "CENTER", 0, 0)
  pfUI.swingtimer.ranged.right:SetHeight(sw_height)
  pfUI.swingtimer.ranged.right:SetWidth(sw_width / 2)
  pfUI.swingtimer.ranged.right:SetTexCoord(0.5, 1, 0, 1)
  pfUI.swingtimer.ranged.right:SetVertexColor(raR, raG, raB, raA)

  pfUI.swingtimer.ranged.warn = pfUI.swingtimer.ranged:CreateTexture(nil, "ARTWORK")
  pfUI.swingtimer.ranged.warn:SetTexture(sw_texture)
  pfUI.swingtimer.ranged.warn:SetPoint("CENTER", pfUI.swingtimer.ranged, "CENTER", 0, 0)
  pfUI.swingtimer.ranged.warn:SetHeight(sw_height)
  pfUI.swingtimer.ranged.warn:SetWidth(1)
  pfUI.swingtimer.ranged.warn:SetVertexColor(rwR, rwG, rwB, rwA)
  pfUI.swingtimer.ranged.warn:Hide()

  pfUI.swingtimer.ranged.text = pfUI.swingtimer.ranged:CreateFontString("Status", "DIALOG", "GameFontNormal")
  pfUI.swingtimer.ranged.text:SetPoint("CENTER", pfUI.swingtimer.ranged, "CENTER", 0, 0)
  pfUI.swingtimer.ranged.text:SetFont(pfUI.font_default, sw_fontsize, "OUTLINE")
  pfUI.swingtimer.ranged.text:SetTextColor(1, 1, 1, 1)
  pfUI.swingtimer.ranged.text:SetText("")
  if not sw_showtext then pfUI.swingtimer.ranged.text:Hide() end

  pfUI.swingtimer.ranged.label = pfUI.swingtimer.ranged:CreateFontString("Status", "DIALOG", "GameFontNormal")
  pfUI.swingtimer.ranged.label:SetPoint("RIGHT", pfUI.swingtimer.ranged, "LEFT", -4, 0)
  pfUI.swingtimer.ranged.label:SetFont(pfUI.font_default, sw_fontsize, "OUTLINE")
  pfUI.swingtimer.ranged.label:SetTextColor(0.8, 0.8, 0.8, 1)
  pfUI.swingtimer.ranged.label:SetText(sw_showlabel and L["Ra"] or "")

  pfUI.swingtimer.ranged.speed = pfUI.swingtimer.ranged:CreateFontString("Status", "DIALOG", "GameFontNormal")
  pfUI.swingtimer.ranged.speed:SetPoint("LEFT", pfUI.swingtimer.ranged, "RIGHT", 4, 0)
  pfUI.swingtimer.ranged.speed:SetFont(pfUI.font_default, sw_fontsize, "OUTLINE")
  pfUI.swingtimer.ranged.speed:SetTextColor(0.8, 0.8, 0.8, 1)
  pfUI.swingtimer.ranged.speed:SetText("")
  if not sw_showspeed then pfUI.swingtimer.ranged.speed:Hide() end

  CreateBackdrop(pfUI.swingtimer.ranged)


  pfUI.swingtimer.ranged.marker = pfUI.swingtimer.ranged:CreateTexture(nil, "OVERLAY")
  pfUI.swingtimer.ranged.marker:SetTexture(1, 1, 1, 1.0)
  pfUI.swingtimer.ranged.marker:SetWidth(2)
  pfUI.swingtimer.ranged.marker:SetHeight(sw_height)
  pfUI.swingtimer.ranged.marker:Hide()

  -- Left glow: fades from transparent to white (right edge = marker)
  pfUI.swingtimer.ranged.markerGlowL = pfUI.swingtimer.ranged:CreateTexture(nil, "OVERLAY")
  pfUI.swingtimer.ranged.markerGlowL:SetTexture(1, 1, 1, 1)
  pfUI.swingtimer.ranged.markerGlowL:SetGradientAlpha("HORIZONTAL", 1, 1, 1, 0, 1, 1, 1, 0.35)
  pfUI.swingtimer.ranged.markerGlowL:SetWidth(10)
  pfUI.swingtimer.ranged.markerGlowL:SetHeight(sw_height)
  pfUI.swingtimer.ranged.markerGlowL:Hide()

  -- Right glow: fades from white to transparent (left edge = marker)
  pfUI.swingtimer.ranged.markerGlowR = pfUI.swingtimer.ranged:CreateTexture(nil, "OVERLAY")
  pfUI.swingtimer.ranged.markerGlowR:SetTexture(1, 1, 1, 1)
  pfUI.swingtimer.ranged.markerGlowR:SetGradientAlpha("HORIZONTAL", 1, 1, 1, 0.35, 1, 1, 1, 0)
  pfUI.swingtimer.ranged.markerGlowR:SetWidth(10)
  pfUI.swingtimer.ranged.markerGlowR:SetHeight(sw_height)
  pfUI.swingtimer.ranged.markerGlowR:Hide()

  CreateBackdropShadow(pfUI.swingtimer.ranged)

  UpdateMovable(pfUI.swingtimer.mainhand)
  UpdateMovable(pfUI.swingtimer.ranged)

 -- -------------------------------------------------------------------------
  -- Range indicator frame
  -- -------------------------------------------------------------------------
  -- Hunter: Melee / Dead Zone / In Range / Out of Range
  -- Others: Melee / Dead Zone only (no ranged zone distinction)
  if sw_rangeindicator then
    local ZONES_HUNTER = {
      melee    = { "Melee",     0.13, 0.55, 0.13 },
      range    = { "In Range",  0.10, 0.30, 0.60 },
      deadzone = { "Dead Zone", 0.45, 0.25, 0.05 },
      outrange = { "Out of Range", 0.55, 0.10, 0.10 },
    }
    local ZONES_DEFAULT = {
      melee    = { "Melee",     0.13, 0.55, 0.13 },
      deadzone = { "Dead Zone", 0.45, 0.25, 0.05 },
    }
    local ZONES = playerClass == "HUNTER" and ZONES_HUNTER or ZONES_DEFAULT

    pfUI.swingtimer.rangeindicator = CreateFrame("Frame", "pfSwingTimerRangeIndicator", UIParent)
    pfUI.swingtimer.rangeindicator:SetWidth(120)
    pfUI.swingtimer.rangeindicator:SetHeight(20)
    pfUI.swingtimer.rangeindicator:SetPoint("CENTER", UIParent, "CENTER", 0, -140)
    pfUI.swingtimer.rangeindicator:Hide()

    CreateBackdrop(pfUI.swingtimer.rangeindicator)
    CreateBackdropShadow(pfUI.swingtimer.rangeindicator)

    pfUI.swingtimer.rangeindicator.label = pfUI.swingtimer.rangeindicator:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    pfUI.swingtimer.rangeindicator.label:SetAllPoints()
    pfUI.swingtimer.rangeindicator.label:SetFont(pfUI.font_default, sw_fontsize, "OUTLINE")
    pfUI.swingtimer.rangeindicator.label:SetJustifyH("CENTER")
    pfUI.swingtimer.rangeindicator.label:SetJustifyV("MIDDLE")

    UpdateMovable(pfUI.swingtimer.rangeindicator)

    local ri = pfUI.swingtimer.rangeindicator
    local function SetRangeZone(zone)
      if ri.zone == zone then return end
      ri.zone = zone
      local z = ZONES[zone]
      if not z then return end
      ri.label:SetText(z[1])
      ri.backdrop:SetBackdropColor(z[2], z[3], z[4], .85)
      ri.backdrop:SetBackdropBorderColor(z[2] * 2, z[3] * 2, z[4] * 2, 1)
    end

    local riUpdater = CreateFrame("Frame")
    riUpdater:SetScript("OnUpdate", function()
      local now = GetTime()
      if (this.tick or 0) > now then return end
      this.tick = now + 0.1

      -- Don't hide while unlock mode is active
      if pfUI.unlock and pfUI.unlock:IsShown() then return end

      local hasTarget = UnitExists("target")
        and UnitCanAttack("player", "target")
        and not UnitIsDead("target")

      if not hasTarget then
        ri:Hide()
        return
      end

      ri:Show()

      local melee = IsSpellInRange(WINGCLIP_ID, "target")

      if playerClass == "HUNTER" then
        local ranged = IsSpellInRange(ARCANESHOT_ID, "target")
        if melee == 1 then
          SetRangeZone("melee")
        elseif ranged == 1 then
          SetRangeZone("range")
        elseif CheckInteractDistance("target", 4) then
          SetRangeZone("deadzone")
        else
          SetRangeZone("outrange")
        end
      else
        local ranged = IsSpellInRange(ARCANESHOT_ID, "target")
        if melee == 1 then
          SetRangeZone("melee")
        elseif ranged == 0 and melee == 0 then
          SetRangeZone("deadzone")
        else
          ri:Hide()
        end
      end
    end)
  end
  local OH_WEAPON_TYPES = { [13]=true, [21]=true }
  local function HasOffhandWeapon()
    local l = GetInventoryItemLink("player", 17)
    if not l then return false end
    local _, _, id = string.find(l, "item:(%d+)")
    id = tonumber(id)
    if not id then return false end
    local s = GetItemStats and GetItemStats(id)
    if not s then return false end
    return OH_WEAPON_TYPES[s.inventoryType] == true
  end	 

  local function UpdateWeaponSpeeds()
    local ms, os = UnitAttackSpeed("player")
    S.mhSpeed = (ms and ms > 0) and ms or S.mhSpeed
    S.ohSpeed = (HasOffhandWeapon() and os and os > 0) and os or 0
    local rs = UnitRangedDamage("player")
    S.raSpeed = (rs and rs > 0) and rs or 0
  end

  -- Attack-speed auras can be applied or removed after AUTO_ATTACK_SELF for
  -- the same white hit. Rescale the active interval by completed percentage so
  -- Flurry's first affected swing is hasted and the swing after its last charge
  -- immediately returns to normal speed.
  local function ResyncActiveWeaponSpeeds(reason)
    local oldMhSpeed, oldOhSpeed = S.mhSpeed, S.ohSpeed
    local oldMhMax, oldOhMax = S.mhTimerMax, S.ohTimerMax
    local oldMhTimer, oldOhTimer = S.mhTimer, S.ohTimer
    UpdateWeaponSpeeds()

    if S.mhActive and oldMhMax and oldMhMax > 0
      and S.mhSpeed > 0
      and math.abs(S.mhSpeed - oldMhSpeed) > 0.001 then
      local remainingFraction = S.mhTimer / oldMhMax
      if remainingFraction < 0 then remainingFraction = 0 end
      if remainingFraction > 1 then remainingFraction = 1 end
      S.mhTimerMax = S.mhSpeed
      S.mhTimer = S.mhSpeed * remainingFraction
    end

    if S.ohActive and oldOhMax and oldOhMax > 0
      and S.ohSpeed > 0
      and math.abs(S.ohSpeed - oldOhSpeed) > 0.001 then
      local remainingFraction = S.ohTimer / oldOhMax
      if remainingFraction < 0 then remainingFraction = 0 end
      if remainingFraction > 1 then remainingFraction = 1 end
      S.ohTimerMax = S.ohSpeed
      S.ohTimer = S.ohSpeed * remainingFraction
    end

    if math.abs((S.mhSpeed or 0) - (oldMhSpeed or 0)) > 0.001
      or math.abs((S.ohSpeed or 0) - (oldOhSpeed or 0)) > 0.001 then
      Trace("SPEED_SYNC", string.format(
        "cause=%s oldMhSpeed=%.3f oldMhRem=%.3f oldOhSpeed=%.3f oldOhRem=%.3f newOhSpeed=%.3f newOhRem=%.3f",
        tostring(reason or "unknown"),
        tonumber(oldMhSpeed) or 0,
        tonumber(oldMhTimer) or 0,
        tonumber(oldOhSpeed) or 0,
        tonumber(oldOhTimer) or 0,
        tonumber(S.ohSpeed) or 0,
        tonumber(S.ohTimer) or 0
      ))
    end
  end

  local function QueueWeaponSpeedSync(reason)
    ResyncActiveWeaponSpeeds(reason)
    -- Poll briefly as a guard against clients that dispatch the aura event one
    -- frame before UnitAttackSpeed exposes the new value.
    S.speedSyncUntil = GetTime() + 0.20
  end

  -- Reset MH countdown to full speed (server confirmed swing)
  local function ResetMH(reason)
    local before = S.mhTimer
    EndMHStall(reason or "reset_mh")
    if S.mhFrozenAt then
      S.mhFrozenAt = nil
    end
    -- Melee and ranged timers share one slot and are mutually exclusive.
    S.raActive = false
    pfUI.swingtimer.ranged:Hide()
    UpdateWeaponSpeeds()
    pfUI.swingtimer.mhGraceAt = nil  -- cancel any pending hide
    S.mhTimerMax = S.mhSpeed
    S.mhTimer    = S.mhSpeed
    S.mhActive   = true
    pfUI.swingtimer.mainhand:Show()
    pfUI.swingtimer:Show()
    Trace("RESET_MH", string.format(
      "cause=%s beforeRem=%.3f",
      tostring(reason or "unknown"),
      tonumber(before) or 0
    ))
  end

  -- Reset OH countdown to full speed
  local function ResetOH(reason)
    local before = S.ohTimer
    UpdateWeaponSpeeds()
    if S.ohSpeed <= 0 then return end
    pfUI.swingtimer.ohGraceAt = nil  -- cancel any pending hide
    S.ohTimerMax = S.ohSpeed
    S.ohTimer    = S.ohSpeed
    S.ohActive   = true
    if sw_showoh then pfUI.swingtimer.offhand:Show() end
    pfUI.swingtimer:Show()
    Trace("RESET_OH", string.format(
      "cause=%s beforeRem=%.3f ohRem=%.3f ohSpeed=%.3f",
      tostring(reason or "unknown"),
      tonumber(before) or 0,
      tonumber(S.ohTimer) or 0,
      tonumber(S.ohSpeed) or 0
    ))
  end

  -- Reset ranged countdown
  local function ResetRanged(reason)
    if not sw_showranged then return end
    UpdateWeaponSpeeds()
    if S.raSpeed <= 0 then return end
    -- Ranged replaces MH bar
    EndMHStall(reason or "reset_ranged")
    S.mhActive = false
    pfUI.swingtimer.mainhand:Hide()
    S.raTimerMax = S.raSpeed
    S.raTimer    = S.raSpeed
    S.raActive   = true

    if isHunter then
      pfUI.swingtimer.ranged.left:ClearAllPoints()
      pfUI.swingtimer.ranged.left:SetPoint("RIGHT", pfUI.swingtimer.ranged, "CENTER", 0, 0)
      pfUI.swingtimer.ranged.left:SetWidth(sw_width / 2)
      pfUI.swingtimer.ranged.left:SetTexCoord(0, 0.5, 0, 1)
      pfUI.swingtimer.ranged.right:SetWidth(sw_width / 2)
      pfUI.swingtimer.ranged.right:SetTexCoord(0.5, 1, 0, 1)
    else
      pfUI.swingtimer.ranged.left:ClearAllPoints()
      pfUI.swingtimer.ranged.left:SetPoint("TOPLEFT", pfUI.swingtimer.ranged, "TOPLEFT", 0, 0)
      pfUI.swingtimer.ranged.left:SetWidth(0.1)
      pfUI.swingtimer.ranged.left:Hide()
      pfUI.swingtimer.ranged.left:SetTexCoord(0, 0, 0, 1)
      pfUI.swingtimer.ranged.right:SetWidth(0.1)
      pfUI.swingtimer.ranged.right:Hide()
    end
    pfUI.swingtimer.ranged.left:SetVertexColor(raR, raG, raB, raA)
    pfUI.swingtimer.ranged.right:SetVertexColor(raR, raG, raB, raA)
    pfUI.swingtimer.ranged.warn:SetWidth(1)
    pfUI.swingtimer.ranged.warn:Hide()
    pfUI.swingtimer.ranged:Show()
    pfUI.swingtimer:Show()
    Trace("RESET_RANGED", string.format(
      "cause=%s raRem=%.3f raSpeed=%.3f",
      tostring(reason or "unknown"),
      tonumber(S.raTimer) or 0,
      tonumber(S.raSpeed) or 0
    ))
  end

  local function ResetAll(reason)
    EndMHStall(reason or "reset_all")
    S.mhActive = false
    S.ohActive = false
    S.raActive = false
    S.mhTimer  = 0
    S.ohTimer  = 0
    S.raTimer  = 0
    pfUI.swingtimer.mhGraceAt = nil
    pfUI.swingtimer.ohGraceAt = nil
    pfUI.swingtimer.mainhand:Hide()
    pfUI.swingtimer.offhand:Hide()
    pfUI.swingtimer.ranged:Hide()
    pfUI.swingtimer:Hide()
    Trace("RESET_ALL", "cause=" .. tostring(reason or "unknown"))
  end

  -- HS/Cleave helpers
  local function RebuildQueueSlotCache()
    if not S.isWarrior or not sw_hsqueue or S.useSpellQueueEvent then return end
    S.cachedHSSlots     = {}
    S.cachedCleaveSlots = {}
    for slot = 1, 120 do
      local tex  = GetActionTexture(slot)
      local name = GetActionText(slot)
      -- GetActionText identifies macros. A /startattack macro can remain
      -- "current" while auto attack is active, so treating its HS/Cleave icon
      -- as a native spell slot creates a permanent false queue. Actual casts
      -- from macros are still tracked by SPELL_CAST_EVENT/SPELL_QUEUE_EVENT.
      if tex and not name then
        if string.find(tex, "Ability_Rogue_Ambush") then
          table.insert(S.cachedHSSlots, slot)
        elseif string.find(tex, "Ability_Warrior_Cleave") then
          table.insert(S.cachedCleaveSlots, slot)
        end
      end
    end
  end

  local function CheckQueuedAction(slotList)
    for i = 1, table.getn(slotList) do
      if IsCurrentAction(slotList[i]) then return true end
    end
    return false
  end

  local function IsHSOrCleaveQueued()
    if not sw_hsqueue or not S.isWarrior then return false, false end
    if S.useSpellQueueEvent then return S.hsQueued, S.cleaveQueued end
    return CheckQueuedAction(S.cachedHSSlots), CheckQueuedAction(S.cachedCleaveSlots)
  end

  -- OnUpdate: countdown all timers with delta, then render
  pfUI.swingtimer:SetScript("OnUpdate", function()
    S.swingThrottle = S.swingThrottle + arg1
    local swingDelay = pfUI.throttle and pfUI.throttle:Get("swingtimer") or 0.02
    if S.swingThrottle < swingDelay then return end
    local delta = S.swingThrottle
    S.swingThrottle = 0

    if S.speedSyncUntil then
      ResyncActiveWeaponSpeeds("poll")
      if GetTime() >= S.speedSyncUntil then
        S.speedSyncUntil = nil
      end
    end

    -- (out-of-combat hide handled naturally when timers expire)

    local anyActive = false

    -- Tick timers down. When a timer expires we give a short grace period before
    -- hiding the bar, to bridge the 1-2 frame gap until AUTO_ATTACK_SELF arrives.
    -- If AUTO_ATTACK_SELF arrives during the grace period it resets the timer
    -- normally and the grace timer is cleared. If not (e.g. auto-attack was
    -- turned off), the bar hides after the grace period ends.
    local GRACE = 0.15  -- seconds to wait after timer hits 0 before hiding

    if S.mhActive then
      S.mhTimer = S.mhTimer - delta
      if S.mhTimer <= 0 then
        S.mhTimer = 0
        if not S.mhZeroAt then
          S.mhZeroAt = GetTime()
          Trace("MH_ZERO", "source=countdown")
        end
        if not S.mhStallAt and S.inCombat and S.autoAttackActive
          and GetTime() - S.mhZeroAt >= STALL_THRESHOLD then
          S.mhStallAt = S.mhZeroAt
          Trace("STALL_ENTER", string.format(
            "zeroFor=%.3f frozen=%s",
            GetTime() - S.mhZeroAt,
            tostring(S.mhFrozenAt ~= nil)
          ))
        end
        if S.mhFrozenAt then
          -- Spell with interruptFlags froze the swing: bar holds at 0, skip grace/hide.
          -- ResetMH() will clear mhFrozenAt when AUTO_ATTACK_SELF arrives.
        elseif not pfUI.swingtimer.mhGraceAt then
          pfUI.swingtimer.mhGraceAt = GetTime() + GRACE
        elseif GetTime() >= pfUI.swingtimer.mhGraceAt then
          pfUI.swingtimer.mhGraceAt = nil
          if not S.inCombat or not S.autoAttackActive then
            EndMHStall("inactive_hide")
            S.mhActive = false
            pfUI.swingtimer.mainhand:Hide()
            S.lastMhMarkerX = -1
            pfUI.swingtimer.mainhand.marker:Hide()
            pfUI.swingtimer.mainhand.markerGlowL:Hide()
            pfUI.swingtimer.mainhand.markerGlowR:Hide()
          end
        end
      end
    end
    if S.ohActive then
      S.ohTimer = S.ohTimer - delta
      if S.ohTimer <= 0 then
        S.ohTimer = 0
        if not pfUI.swingtimer.ohGraceAt then
          pfUI.swingtimer.ohGraceAt = GetTime() + GRACE
        elseif GetTime() >= pfUI.swingtimer.ohGraceAt then
          pfUI.swingtimer.ohGraceAt = nil
          if not S.inCombat or not S.autoAttackActive then
            S.ohActive = false
            pfUI.swingtimer.offhand:Hide()
            S.lastOhMarkerX = -1
            pfUI.swingtimer.offhand.marker:Hide()
            pfUI.swingtimer.offhand.markerGlowL:Hide()
            pfUI.swingtimer.offhand.markerGlowR:Hide()
          end
        end
      end
    end
    if S.raActive then
      S.raTimer = S.raTimer - delta
      if S.raTimer <= 0 then
        S.raTimer = 0
        S.raActive = false
        pfUI.swingtimer.ranged:Hide()
      end
    end

    -- HS/Cleave color
    local curR, curG, curB = mhDefaultR, mhDefaultG, mhDefaultB
    if sw_hsqueue and S.isWarrior then
      local hs, cl = IsHSOrCleaveQueued()
      if cl then
        curR, curG, curB = 0.2, 0.9, 0.2
      elseif hs then
        curR, curG, curB = 0.9, 0.9, 0.2
      end
    end

    -- Render MH
    if S.mhActive then
      local progress = 1 - (S.mhTimer / S.mhTimerMax)
      pfUI.swingtimer.mainhand:SetValue(progress)
      if S.mhTimer <= 0 then
        -- Timer expired: hide marker (no gap at right edge)
        if S.lastMhMarkerX ~= -1 then
          S.lastMhMarkerX = -1
          pfUI.swingtimer.mainhand.marker:Hide()
          pfUI.swingtimer.mainhand.markerGlowL:Hide()
          pfUI.swingtimer.mainhand.markerGlowR:Hide()
        end
      else
        local mhMarkerX = progress * sw_width
        if mhMarkerX < 1 then mhMarkerX = 1 end
        if mhMarkerX > sw_width - 2 then mhMarkerX = sw_width - 2 end
        if mhMarkerX ~= S.lastMhMarkerX then
          S.lastMhMarkerX = mhMarkerX
          pfUI.swingtimer.mainhand.marker:SetPoint("LEFT", pfUI.swingtimer.mainhand, "LEFT", mhMarkerX - 1, 0)
          pfUI.swingtimer.mainhand.markerGlowL:SetPoint("RIGHT", pfUI.swingtimer.mainhand.marker, "LEFT", 0, 0)
          pfUI.swingtimer.mainhand.markerGlowR:SetPoint("LEFT", pfUI.swingtimer.mainhand.marker, "RIGHT", 0, 0)
          pfUI.swingtimer.mainhand.marker:Show()
          pfUI.swingtimer.mainhand.markerGlowL:Show()
          pfUI.swingtimer.mainhand.markerGlowR:Show()
        end
      end
      pfUI.swingtimer.mainhand:SetStatusBarColor(curR, curG, curB, mhA)
      if sw_showtext then
        pfUI.swingtimer.mainhand.text:SetText(string.format("%.1f", math.floor(S.mhTimer * 10) / 10))
      end
      if sw_showspeed and S.mhSpeed > 0 then
        pfUI.swingtimer.mainhand.speed:SetText(string.format("%.2f", S.mhSpeed))
      end
      anyActive = true
    end

    -- Render OH
    if sw_showoh and S.ohActive then
      local progress = 1 - (S.ohTimer / S.ohTimerMax)
      pfUI.swingtimer.offhand:SetValue(progress)
      if S.ohTimer <= 0 then
        if S.lastOhMarkerX ~= -1 then
          S.lastOhMarkerX = -1
          pfUI.swingtimer.offhand.marker:Hide()
          pfUI.swingtimer.offhand.markerGlowL:Hide()
          pfUI.swingtimer.offhand.markerGlowR:Hide()
        end
      else
        local ohMarkerX = progress * sw_width
        if ohMarkerX < 1 then ohMarkerX = 1 end
        if ohMarkerX > sw_width - 2 then ohMarkerX = sw_width - 2 end
        if ohMarkerX ~= S.lastOhMarkerX then
          S.lastOhMarkerX = ohMarkerX
          pfUI.swingtimer.offhand.marker:SetPoint("LEFT", pfUI.swingtimer.offhand, "LEFT", ohMarkerX - 1, 0)
          pfUI.swingtimer.offhand.markerGlowL:SetPoint("RIGHT", pfUI.swingtimer.offhand.marker, "LEFT", 0, 0)
          pfUI.swingtimer.offhand.markerGlowR:SetPoint("LEFT", pfUI.swingtimer.offhand.marker, "RIGHT", 0, 0)
          pfUI.swingtimer.offhand.marker:Show()
          pfUI.swingtimer.offhand.markerGlowL:Show()
          pfUI.swingtimer.offhand.markerGlowR:Show()
        end
      end
      if sw_showtext then
        pfUI.swingtimer.offhand.text:SetText(string.format("%.1f", math.floor(S.ohTimer * 10) / 10))
      end
      if sw_showspeed and S.ohSpeed > 0 then
        pfUI.swingtimer.offhand.speed:SetText(string.format("%.2f", S.ohSpeed))
      end
      anyActive = true
    elseif not sw_showoh then
      pfUI.swingtimer.offhand:Hide()
    end

    -- Render Ranged
    if sw_showranged and S.raActive then
      local remaining = S.raTimer
      if isHunter then
        local DEADZONE = 0.5
        local halfW = sw_width / 2
        if remaining > DEADZONE then
          local elapsed   = S.raTimerMax - remaining
          local phase1dur = S.raTimerMax - DEADZONE
          local p = elapsed / phase1dur
          local w = halfW * (1 - p)
          if w < 1 then w = 1 end
          pfUI.swingtimer.ranged.left:Show()
          pfUI.swingtimer.ranged.left:SetWidth(w)
          pfUI.swingtimer.ranged.left:SetTexCoord(0, (1 - p) * 0.5, 0, 1)
          pfUI.swingtimer.ranged.left:SetVertexColor(raR, raG, raB, raA)
          pfUI.swingtimer.ranged.right:Show()
          pfUI.swingtimer.ranged.right:SetWidth(w)
          pfUI.swingtimer.ranged.right:SetTexCoord(1 - (1 - p) * 0.5, 1, 0, 1)
          pfUI.swingtimer.ranged.right:SetVertexColor(raR, raG, raB, raA)
          pfUI.swingtimer.ranged.warn:Hide()
        else
          local p = 1 - (remaining / DEADZONE)
          local w = sw_width * p
          if w < 1 then w = 1 end
          pfUI.swingtimer.ranged.left:Hide()
          pfUI.swingtimer.ranged.right:Hide()
          pfUI.swingtimer.ranged.warn:SetWidth(w)
          pfUI.swingtimer.ranged.warn:Show()
        end
        if sw_showtext then
          if remaining <= 0.5 then
            pfUI.swingtimer.ranged.text:SetText(string.format("%.1f", math.floor(remaining * 10) / 10))
          else
            pfUI.swingtimer.ranged.text:SetText(string.format("%.1f", math.floor((remaining - 0.5) * 10) / 10))
          end
        end
      else
        local progress = 1 - (remaining / S.raTimerMax)
        local w = sw_width * progress
        if w < 1 then w = 1 end
        pfUI.swingtimer.ranged.left:Show()
        pfUI.swingtimer.ranged.left:SetWidth(w)
        pfUI.swingtimer.ranged.left:SetTexCoord(0, progress, 0, 1)
        pfUI.swingtimer.ranged.right:Hide()
        pfUI.swingtimer.ranged.warn:Hide()
        if sw_showtext then
          pfUI.swingtimer.ranged.text:SetText(string.format("%.1f", math.floor(remaining * 10) / 10))
        end
      end
      if sw_showspeed and S.raSpeed > 0 then
        pfUI.swingtimer.ranged.speed:SetText(string.format("%.2f", S.raSpeed))
      end
      local raProgress = 1 - (S.raTimer / S.raTimerMax)
      local raMarkerX = raProgress * sw_width
      if raMarkerX < 1 then raMarkerX = 1 end
      if raMarkerX > sw_width - 2 then raMarkerX = sw_width - 2 end
      if raMarkerX ~= S.lastRaMarkerX then
        S.lastRaMarkerX = raMarkerX
        if not isHunter then
          pfUI.swingtimer.ranged.marker:SetPoint("LEFT", pfUI.swingtimer.ranged, "LEFT", raMarkerX - 1, 0)
          pfUI.swingtimer.ranged.marker:Show()
          pfUI.swingtimer.ranged.markerGlowL:SetPoint("RIGHT", pfUI.swingtimer.ranged.marker, "LEFT", 0, 0)
          pfUI.swingtimer.ranged.markerGlowR:SetPoint("LEFT", pfUI.swingtimer.ranged.marker, "RIGHT", 0, 0)
          pfUI.swingtimer.ranged.markerGlowL:Show()
          pfUI.swingtimer.ranged.markerGlowR:Show()
        else
          pfUI.swingtimer.ranged.marker:Hide()
          pfUI.swingtimer.ranged.markerGlowL:Hide()
          pfUI.swingtimer.ranged.markerGlowR:Hide()
        end
      end
      anyActive = true
    elseif not sw_showranged then
      pfUI.swingtimer.ranged:Hide()
    end

    if not anyActive then
      if not pfUI.swingtimer.mainhand:IsShown()
        and not pfUI.swingtimer.offhand:IsShown()
        and not pfUI.swingtimer.ranged:IsShown() then
        this:Hide()
      end
    end
  end)

  -- SPELL_START_SELF: fires only for cast-time spells, never instants
  local spellStartFrame = CreateFrame("Frame")
  spellStartFrame:RegisterEvent("SPELL_START_SELF")
  spellStartFrame:SetScript("OnEvent", function()
    if arg1 and arg1 > 0 then
      S.pendingCastSpellId = arg1
      Trace("SPELL_START", "spellId=" .. tostring(arg1))
    end
  end)

  -- SPELL_GO hook via libdebuff
  pfUI.libdebuff_spell_go_hooks = pfUI.libdebuff_spell_go_hooks or {}
  pfUI.libdebuff_spell_go_hooks["swingtimer"] = function(spellId)
    if RANGED_SPELLIDS[spellId] then
      Trace("SPELL_GO", "spellId=" .. tostring(spellId) .. " decision=ranged_reset")
      ResetRanged("spell_go:" .. tostring(spellId))
      return
    elseif IsSlamSpell(spellId) then
      -- Slam delays auto-attack but does NOT reset the swing timer. Ignore.
      Trace("SPELL_GO", "spellId=" .. tostring(spellId) .. " decision=ignore_slam")
      S.pendingCastSpellId = nil
      return
    elseif hsSpellIDs[spellId] or IsOnSwingSpell(spellId) then
      Trace("SPELL_GO", "spellId=" .. tostring(spellId) .. " decision=on_swing_reset")
      S.hsQueued = false; S.cleaveQueued = false
      ResetMH("spell_go:" .. tostring(spellId))
    elseif cleaveSpellIDs[spellId] then
      Trace("SPELL_GO", "spellId=" .. tostring(spellId) .. " decision=cleave_reset")
      S.hsQueued = false; S.cleaveQueued = false
      ResetMH("spell_go:" .. tostring(spellId))
    else
      -- Any spell with interruptFlags > 0 resets the swing timer
      -- (Moonfire, Faerie Fire, Wrath, Starfire etc. - NOT Insect Swarm which has flags=0)
      local _rec = GetSpellRec(spellId)
      if _rec and _rec.interruptFlags and _rec.interruptFlags > 0 then
        if S.mhActive and S.mhSpeed > 0 then
          local before = S.mhTimer
          EndMHStall("spell_interrupt:" .. tostring(spellId))
          UpdateWeaponSpeeds()
          S.mhTimerMax = S.mhSpeed
          S.mhTimer    = S.mhSpeed
          Trace("SPELL_GO", string.format(
            "spellId=%s decision=interrupt_reset flags=%s beforeRem=%.3f",
            tostring(spellId),
            tostring(_rec.interruptFlags),
            tonumber(before) or 0
          ))
        else
          Trace("SPELL_GO", string.format(
            "spellId=%s decision=interrupt_no_active flags=%s",
            tostring(spellId),
            tostring(_rec.interruptFlags)
          ))
        end
      else
        Trace("SPELL_GO", string.format(
          "spellId=%s decision=no_reset flags=%s",
          tostring(spellId),
          tostring(_rec and _rec.interruptFlags or 0)
        ))
      end
    end
    S.pendingCastSpellId = nil
  end

  -- SPELL_CAST_EVENT hook: HS/Cleave queue tracking
  pfUI.libdebuff_spell_cast_hooks = pfUI.libdebuff_spell_cast_hooks or {}
  pfUI.libdebuff_spell_cast_hooks["swingtimer"] = function(success, spellId)
    if success ~= 1 then return end
    if hsSpellIDs[spellId] then
      S.hsQueued = true; S.cleaveQueued = false
      Trace("SPELL_CAST", "spellId=" .. tostring(spellId) .. " queue=hs")
    elseif cleaveSpellIDs[spellId] then
      S.cleaveQueued = true; S.hsQueued = false
      Trace("SPELL_CAST", "spellId=" .. tostring(spellId) .. " queue=cleave")
    end
  end


  local events = CreateFrame("Frame")
  events:RegisterEvent("AUTO_ATTACK_SELF")
  events:RegisterEvent("AUTO_ATTACK_OTHER")
  events:RegisterEvent("PLAYER_ENTERING_WORLD")
  events:RegisterEvent("UNIT_INVENTORY_CHANGED")
  events:RegisterEvent("PLAYER_REGEN_DISABLED")
  events:RegisterEvent("PLAYER_REGEN_ENABLED")
  events:RegisterEvent("UNIT_ATTACK_SPEED")
  events:RegisterEvent("PLAYER_AURAS_CHANGED")
  events:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
  events:RegisterEvent("UNIT_DIED")
  events:RegisterEvent("SPELL_QUEUE_EVENT")
  events:RegisterEvent("PLAYER_ENTER_COMBAT")
  events:RegisterEvent("PLAYER_LEAVE_COMBAT")

  events:SetScript("OnEvent", function()
    if event == "AUTO_ATTACK_SELF" then
      S.autoAttackActive = true
      local hitInfo  = arg4 or 0
      local isOffhand = bit.band(hitInfo, HITINFO_LEFTSWING) ~= 0
      local noAction  = bit.band(hitInfo, HITINFO_NOACTION) ~= 0
      local miss = bit.band(hitInfo, HITINFO_MISS) ~= 0
      local autoDetail = string.format(
        "hand=%s source=%s target=%s amount=%s hitInfo=%s miss=%s noAction=%s victimState=%s",
        isOffhand and "off" or "main",
        tostring(arg1),
        tostring(arg2),
        tostring(arg3),
        tostring(hitInfo),
        tostring(miss),
        tostring(noAction),
        tostring(arg5)
      )
      -- NOACTION means server did not advance swing clock (dodge/parry/miss).
      -- Only skip if the timer is already running - if it's not active yet
      -- (first swing ever), we still want to start it so the bar appears.
      if noAction then
        if isOffhand and S.ohActive then
          Trace("AUTO_ATTACK_SELF", autoDetail .. " decision=reject_noaction")
          return
        end
        if not isOffhand and S.mhActive then
          Trace("AUTO_ATTACK_SELF", autoDetail .. " decision=reject_noaction")
          return
        end
      end

      -- Extra attack detection: if timer still has >20% remaining for that hand,
      -- the server did NOT reset the swing clock -> this is an extra attack, skip.
      -- Use 20% here (SP_SwingTimer's ShouldResetTimer threshold).
      -- Exception: if timer is already at 0 (expired), always accept.
      if isOffhand then
        local pct = S.ohActive and (S.ohTimer / S.ohTimerMax) or 0
        if S.ohActive and S.ohTimer > 0 and pct > 0.20 then
          Trace("AUTO_ATTACK_SELF", string.format(
            "%s decision=reject_early_extra remainingPct=%.3f",
            autoDetail,
            pct
          ))
          return
        end
        Trace("AUTO_ATTACK_SELF", string.format(
          "%s decision=accept remainingPct=%.3f",
          autoDetail,
          pct
        ))
        ResetOH("auto_attack_self")
      else
        local pct = S.mhActive and (S.mhTimer / S.mhTimerMax) or 0
        if S.mhActive and S.mhTimer > 0 and pct > 0.20 then
          Trace("AUTO_ATTACK_SELF", string.format(
            "%s decision=reject_early_extra remainingPct=%.3f",
            autoDetail,
            pct
          ))
          return
        end
        Trace("AUTO_ATTACK_SELF", string.format(
          "%s decision=accept remainingPct=%.3f",
          autoDetail,
          pct
        ))
        ResetMH("auto_attack_self")
      end

    elseif event == "AUTO_ATTACK_OTHER" then
      -- Parry haste: enemy attacked the player and player parried
      local targetGuid = arg2
      if not targetGuid or not S.playerGUID then return end
      if targetGuid ~= S.playerGUID then return end
      local victimState = arg5 or 0
      -- VICTIMSTATE_PARRY = 3
      -- Vanilla: parry reduces the NEXT swing timer by 40% of weapon speed,
      -- minimum 20% of weapon speed remaining (SP_SwingTimer approach)
      if victimState == 3 then
        local changedHand = "none"
        local before = 0
        -- Apply to whichever swing comes next (smallest % remaining = closest to firing)
        if S.ohActive and S.ohSpeed > 0 and (S.ohTimer / S.ohTimerMax) < (S.mhTimer / S.mhTimerMax) then
          local minimum = S.ohSpeed * 0.20
          if S.ohTimer > minimum then
            local reduct = S.ohSpeed * 0.40
            before = S.ohTimer
            S.ohTimer = S.ohTimer - reduct
            if S.ohTimer < minimum then S.ohTimer = minimum end
            changedHand = "off"
          end
        elseif S.mhActive and S.mhSpeed > 0 then
          local minimum = S.mhSpeed * 0.20
          if S.mhTimer > minimum then
            local reduct = S.mhSpeed * 0.40
            before = S.mhTimer
            S.mhTimer = S.mhTimer - reduct
            if S.mhTimer < minimum then S.mhTimer = minimum end
            changedHand = "main"
          end
        end
        local after = changedHand == "off" and S.ohTimer or S.mhTimer
        Trace("PARRY_HASTE", string.format(
          "hand=%s beforeRem=%.3f afterRem=%.3f attacker=%s",
          changedHand,
          tonumber(before) or 0,
          tonumber(after) or 0,
          tostring(arg1)
        ))
      end

    elseif event == "SPELL_QUEUE_EVENT" then
      local eventCode = arg1 or -1
      local spellId   = arg2 or 0
      if eventCode == ON_SWING_QUEUED then
        S.useSpellQueueEvent = true
        if hsSpellIDs[spellId] then
          S.hsQueued = true; S.cleaveQueued = false
        elseif cleaveSpellIDs[spellId] then
          S.cleaveQueued = true; S.hsQueued = false
        end
      elseif eventCode == ON_SWING_QUEUE_POPPED then
        S.hsQueued = false; S.cleaveQueued = false
      end
      Trace("SPELL_QUEUE", string.format(
        "code=%s spellId=%s",
        tostring(eventCode),
        tostring(spellId)
      ))

    elseif event == "PLAYER_ENTER_COMBAT" then
      S.autoAttackActive = true
      -- Starting auto-attack has no confirmed swing timestamp. Wait for
      -- AUTO_ATTACK_SELF instead of creating an out-of-phase melee cycle.
      S.raActive = false
      pfUI.swingtimer.ranged:Hide()
      Trace("AUTO_STATE", "active=true source=PLAYER_ENTER_COMBAT")

    elseif event == "PLAYER_LEAVE_COMBAT" then
      S.autoAttackActive = false
      EndMHStall("PLAYER_LEAVE_COMBAT")
      Trace("AUTO_STATE", "active=false source=PLAYER_LEAVE_COMBAT")

    elseif event == "PLAYER_ENTERING_WORLD" then
      local _, class = UnitClass("player")
      S.isWarrior  = (class == "WARRIOR")
      S.playerGUID = GetUnitGUID("player")
      isHunter  = (class == "HUNTER")   -- 添加这一行										
      UpdateWeaponSpeeds()
      RebuildQueueSlotCache()
      Trace("SESSION", string.format(
        "player=%s realm=%s guid=%s",
        tostring(UnitName("player") or "unknown"),
        tostring(GetRealmName and GetRealmName() or "unknown"),
        tostring(S.playerGUID or "unknown")
      ))

    elseif event == "UNIT_ATTACK_SPEED"
      or event == "PLAYER_AURAS_CHANGED" then
      if event == "UNIT_ATTACK_SPEED" and arg1 and arg1 ~= "player" then
        return
      end
      QueueWeaponSpeedSync(event)

    elseif event == "UNIT_INVENTORY_CHANGED" then
      if arg1 and arg1 ~= "player" then return end
      local oldMhSpeed = S.mhSpeed
      local oldOhSpeed = S.ohSpeed
      local oldRaSpeed = S.raSpeed
      UpdateWeaponSpeeds()
      Trace("INVENTORY", string.format(
        "oldMhSpeed=%.3f oldOhSpeed=%.3f oldRaSpeed=%.3f newOhSpeed=%.3f newRaSpeed=%.3f",
        tonumber(oldMhSpeed) or 0,
        tonumber(oldOhSpeed) or 0,
        tonumber(oldRaSpeed) or 0,
        tonumber(S.ohSpeed) or 0,
        tonumber(S.raSpeed) or 0
      ))
      if S.ohSpeed == 0 then
        S.ohActive = false
        pfUI.swingtimer.offhand:Hide()
      elseif oldOhSpeed == 0 and S.ohSpeed > 0 and S.autoAttackActive and S.inCombat then
        -- Offhand was just equipped while in combat and auto-attack active: show immediately
        ResetOH("offhand_equipped")
      end
      if S.raSpeed == 0 then
        S.raActive = false
        pfUI.swingtimer.ranged:Hide()
      end

    elseif event == "ACTIONBAR_SLOT_CHANGED" then
      RebuildQueueSlotCache()

    elseif event == "PLAYER_REGEN_DISABLED" then
      S.inCombat = true
      UpdateWeaponSpeeds()
      Trace("COMBAT", "active=true")

    elseif event == "PLAYER_REGEN_ENABLED" then
      S.inCombat = false
      S.hsQueued     = false
      S.cleaveQueued = false
      EndMHStall("PLAYER_REGEN_ENABLED")
      Trace("COMBAT", "active=false")

    elseif event == "UNIT_DIED" then
      if arg1 and arg1 == S.playerGUID then
        ResetAll("player_died")
      end
    end
  end)
  
    -- -------------------------------------------------------------------------
  -- Public API for external addons (e.g. SCRM)
  -- Only available when the swingtimer module is loaded.
  -- Usage:
  --   if pfUI and pfUI.swingtimer and pfUI.swingtimer.api then
  --     local api = pfUI.swingtimer.api
  --     local mhTimer = api.GetMHTimer()
  --   end
  -- -------------------------------------------------------------------------
  pfUI.swingtimer.api = {
    -- Append DDPS decisions to the same write-only per-client trace.
    AppendTrace       = function(kind, detail) return Trace(kind, detail) end,

    -- Remaining time in seconds until next swing
    GetMHTimer        = function() return S.mhTimer end,
    GetOHTimer        = function() return S.ohTimer end,
    GetRangedTimer    = function() return S.raTimer end,

    -- Weapon speed (full swing duration in seconds)
    GetMHSpeed        = function() return S.mhSpeed end,
    GetOHSpeed        = function() return S.ohSpeed end,
    GetRangedSpeed    = function() return S.raSpeed end,

    -- Whether each timer is currently running
    IsMHActive        = function() return S.mhActive end,
    IsOHActive        = function() return S.ohActive end,
    IsRangedActive    = function() return S.raActive end,

    -- Swing progress 0.0 (just reset) to 1.0 (about to swing)
    GetMHProgress     = function()
      return S.mhActive and S.mhTimerMax > 0 and (1 - S.mhTimer / S.mhTimerMax) or 0
    end,
    GetOHProgress     = function()
      return S.ohActive and S.ohTimerMax > 0 and (1 - S.ohTimer / S.ohTimerMax) or 0
    end,
    GetRangedProgress = function()
      return S.raActive and S.raTimerMax > 0 and (1 - S.raTimer / S.raTimerMax) or 0
    end,

    -- Warrior HS/Cleave queue state
    IsHSQueued        = function() return S.hsQueued end,
    IsCleaveQueued    = function() return S.cleaveQueued end,
  }

  UpdateWeaponSpeeds()
end)
