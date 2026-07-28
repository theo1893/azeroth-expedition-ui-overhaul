pfUI:RegisterModule("unitxp", "vanilla", function ()
  -- Check if UnitXP is available
  local hasUnitXP = pcall(UnitXP, "nop", "nop")
  if not hasUnitXP then return end

  local L = pfUI.L or (pfUI_translation and pfUI_translation[GetLocale()]) or {}
  local rawborder, border = GetBorderSize()

  -- 设置默认配置（若不存在）
  local uc = C.unitframes
  if uc.distance_indicator_font_size == nil then uc.distance_indicator_font_size = 13 end
  if uc.distance_indicator_face_color == nil then uc.distance_indicator_face_color = "1,0.3,0.3,1" end
  if uc.distance_indicator_back_color == nil then uc.distance_indicator_back_color = "0,1,0,1" end
  if uc.distance_indicator_deadzone_color == nil then uc.distance_indicator_deadzone_color = "1,1,0,1" end
  if uc.distance_indicator_outsight_color == nil then uc.distance_indicator_outsight_color = "0.66,0.66,0.66,1" end
  if uc.distance_indicator_outsight_icon == nil then uc.distance_indicator_outsight_icon = "1" end
  if uc.distance_indicator_sound == nil then uc.distance_indicator_sound = "1" end
  if uc.distance_indicator_sound_cooldown == nil then uc.distance_indicator_sound_cooldown = 2 end
  if uc.mouseover_tooltip_distance == nil then uc.mouseover_tooltip_distance = "0" end

  -- ===== 新增：鼠标悬停距离变色配置 =====
  if uc.mouseover_distance_linear_color == nil then uc.mouseover_distance_linear_color = "0" end
  if uc.mouseover_distance_linear_from == nil then uc.mouseover_distance_linear_from = 0 end
  if uc.mouseover_distance_linear_to == nil then uc.mouseover_distance_linear_to = 40 end
  if uc.mouseover_distance_linear_color_from == nil then uc.mouseover_distance_linear_color_from = "0,1,0" end
  if uc.mouseover_distance_linear_color_to == nil then uc.mouseover_distance_linear_color_to = "1,0,0" end
  if uc.mouseover_distance_use_outsight == nil then uc.mouseover_distance_use_outsight = "0" end
  if uc.mouseover_distance_outsight_color == nil then uc.mouseover_distance_outsight_color = "0.66,0.66,0.66" end

  -- 新增：距离指示器前缀文字开关
  if uc.distance_indicator_show_prefix == nil then uc.distance_indicator_show_prefix = "1" end

  -- 新增：距离渐变开关
  if uc.distance_indicator_use_gradient == nil then uc.distance_indicator_use_gradient = "1" end

  -- ===== 新增：宠物距离显示配置 =====
  -- 宠物距离显示模式：0关闭，1常驻，2仅野兽之眼
  if uc.distance_indicator_pet_mode == nil then uc.distance_indicator_pet_mode = "2" end
  -- 宠物距离字体大小
  if uc.distance_indicator_pet_font_size == nil then uc.distance_indicator_pet_font_size = "13" end
  -- 宠物距离颜色（rgba）
  if uc.distance_indicator_pet_color == nil then uc.distance_indicator_pet_color = "0,1,0,1" end
  -- 宠物距离显示位置偏移（相对于主文本，Y方向）
  if uc.distance_indicator_pet_offset_y == nil then uc.distance_indicator_pet_offset_y = "-20" end

  -- Helper to create independent indicators (not attached to target frame)
  local function CreateIndependentIndicators()
    if not pfUI.uf or not pfUI.uf.target then return false end

    if C.unitframes.distance_indicator == "1" and not pfUI.distanceIndicator then
      local frame = CreateFrame("Frame", "pfDistanceIndicator", UIParent)
      frame:SetWidth(90)
      frame:SetHeight(30)
      frame:SetPoint("CENTER", UIParent, "CENTER", 200, -30)

      -- 主文本（目标距离）
      frame.text = frame:CreateFontString(nil, "OVERLAY")
      frame.text:SetFont(pfUI.font_default, tonumber(C.unitframes.distance_indicator_font_size) or 13, "OUTLINE")
      frame.text:SetPoint("CENTER", frame, "CENTER")
      frame.text:SetTextColor(1, 1, 1, 1)
      frame.text:SetText("")

      -- ===== 新增：宠物距离文本（位于主文本下方） =====
      frame.petText = frame:CreateFontString(nil, "OVERLAY")
      frame.petText:SetFont(pfUI.font_default, tonumber(C.unitframes.distance_indicator_pet_font_size) or 13, "OUTLINE")
      frame.petText:SetPoint("TOP", frame.text, "BOTTOM", 0, tonumber(C.unitframes.distance_indicator_pet_offset_y) or -20)
      frame.petText:SetTextColor(1, 1, 1, 1)
      frame.petText:Hide()  -- 默认隐藏

      -- 视野图标（可隐藏）
      local icon = frame:CreateTexture(nil, "OVERLAY")
      icon:SetPoint("RIGHT", frame.text, "LEFT", -2, 0)
      local iconSize = tonumber(C.unitframes.distance_indicator_icon_size) or 20
      icon:SetWidth(iconSize)
      icon:SetHeight(iconSize)
      icon:Hide()
      frame.icon = icon

      -- 颜色阈值（与原有逻辑一致）
      local thresholds = {
        {  5, 0.3, 0.5, 1.0 },
        {  8, 0.4, 0.7, 1.0 },
        { 20, 0.4, 0.9, 1.0 },
        { 30, 0.0, 1.0, 0.0 },
        { 35, 0.8, 1.0, 0.0 },
        { 41, 1.0, 1.0, 0.0 },
        { 999, 1.0, 1.0, 1.0 },  -- 大于41码显示白色
      }

      local INSIGHT_TEXTURE = pfUI.media["img:oeye"]
      local OUTSIGHT_TEXTURE = pfUI.media["img:ceye"]

      local nextSoundPlayTime = 0
      local playerClass = UnitClass("player")
      local isHunter = (playerClass == "HUNTER" or playerClass == "猎人")

      local lastCheck = 0
      frame:SetScript("OnUpdate", function()
        if GetTime() - lastCheck < 0.1 then return end
        lastCheck = GetTime()

        this:Show()

        -- 实时读取配置（允许动态调整）
        local font_size = tonumber(C.unitframes.distance_indicator_font_size) or 13
        this.text:SetFont(pfUI.font_default, font_size, "OUTLINE")

        local face_color = {strsplit(",", C.unitframes.distance_indicator_face_color or "1,0.3,0.3,1")}
        local back_color = {strsplit(",", C.unitframes.distance_indicator_back_color or "0,1,0,1")}
        local deadzone_color = {strsplit(",", C.unitframes.distance_indicator_deadzone_color or "1,1,0,1")}
        local outsight_color = {strsplit(",", C.unitframes.distance_indicator_outsight_color or "0.66,0.66,0.66,1")}
        local show_outsight_icon = C.unitframes.distance_indicator_outsight_icon == "1"
        local play_sound = C.unitframes.distance_indicator_sound == "1"
        local sound_only_group = C.unitframes.distance_indicator_sound_only_group == "1"
        local sound_cooldown = tonumber(C.unitframes.distance_indicator_sound_cooldown) or 2
        local show_prefix = C.unitframes.distance_indicator_show_prefix == "1"   -- 读取开关
        local use_gradient = C.unitframes.distance_indicator_use_gradient == "1" -- 读取渐变开关

        -- ===== 读取宠物距离配置 =====
        local pet_mode = tonumber(C.unitframes.distance_indicator_pet_mode) or 0
        local pet_color = {strsplit(",", C.unitframes.distance_indicator_pet_color or "0,1,0,1")}
        local pet_font_size = tonumber(C.unitframes.distance_indicator_pet_font_size) or 13
        this.petText:SetFont(pfUI.font_default, pet_font_size, "OUTLINE")
        -- 更新宠物文本位置（允许动态调整偏移）
        this.petText:ClearAllPoints()
        this.petText:SetPoint("TOP", this.text, "BOTTOM", 0, tonumber(C.unitframes.distance_indicator_pet_offset_y) or -20)

        if UnitExists("target") then
          local successDist, distance = pcall(UnitXP, "distanceBetween", "player", "target")
          if successDist and distance then
            -- 检测视线
            local successL, inSight = pcall(UnitXP, "inSight", "player", "target")
            local outSight = (successL and inSight == false)

            -- 处理图标
            if show_outsight_icon then
              this.icon:SetTexture(outSight and OUTSIGHT_TEXTURE or INSIGHT_TEXTURE)
              this.icon:SetVertexColor(1, 1, 1)
              this.icon:Show()
            else
              this.icon:Hide()
            end

            local prefix = ""
            local r, g, b
            local meleeRange = false
            local behind = false

            -- 判断近战范围
            local successMelee, meleeDist = pcall(UnitXP, "distanceBetween", "player", "target", "meleeAutoAttack")
            if successMelee and meleeDist and meleeDist == 0 then
              meleeRange = true
              local successBehind, behindStatus = pcall(UnitXP, "behind", "player", "target")
              if successBehind then
                behind = behindStatus
              end

              if behind then
                prefix = show_prefix and "近战\n" or ""   -- 开关控制
                r, g, b = back_color[1], back_color[2], back_color[3]
              else
                prefix = show_prefix and "打脸\n" or ""   -- 开关控制
                r, g, b = face_color[1], face_color[2], face_color[3]

                -- 语音提醒
                if play_sound and UnitAffectingCombat("player") then
                  -- 如果启用了“仅组队”选项，且当前不在任何队伍/团队中，则跳过播放
                  if sound_only_group then
                    local inGroup = GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0
                    if not inGroup then
                      return
                    end
                  end

                  local ttime = GetTime()
                  if ttime > nextSoundPlayTime then
                    PlaySoundFile(pfUI.media["img:warn.ogg"])
                    nextSoundPlayTime = ttime + sound_cooldown
                  end
                end
              end
            elseif isHunter and distance < 8 then
              prefix = show_prefix and "盲区\n" or ""   -- 开关控制
              r, g, b = deadzone_color[1], deadzone_color[2], deadzone_color[3]
            end

            -- 距离渐变（如果未设置特殊颜色）
            if not r then
              if use_gradient then
                for i = 1, table.getn(thresholds) do
                  if distance <= thresholds[i][1] then
                    r, g, b = thresholds[i][2], thresholds[i][3], thresholds[i][4]
                    break
                  end
                end
              else
                r, g, b = 1, 1, 1  -- 关闭渐变时使用白色
              end
            end

            -- 视野外强制使用配置颜色
            if outSight then
              r, g, b = outsight_color[1], outsight_color[2], outsight_color[3]
            end

            this.text:SetTextColor(r, g, b, 1)
            this.text:SetText(prefix .. string.format("%.1f", distance))
          else
            this.icon:Hide()
            this.text:SetText("")
            this.text:SetTextColor(1, 1, 1, 1)
          end
        else
          this.icon:Hide()
          this.text:SetText("")
          this.text:SetTextColor(1, 1, 1, 1)
        end

        -- ===== 更新宠物距离 =====
        local showPetDistance = false
        if isHunter and pet_mode > 0 and UnitExists("pet") then
          if pet_mode == 1 then
            showPetDistance = true
          elseif pet_mode == 2 then
            -- 检查是否有野兽之眼 buff
            local hasEotB = false
            for i = 1, 32 do
              local buff = UnitBuff("player", i)
              if not buff then break end
              if buff == "Interface\\Icons\\Ability_EyeOfTheOwl" then
                hasEotB = true
                break
              end
            end
            showPetDistance = hasEotB
          end
        end

        if showPetDistance then
          local success, petDist = pcall(UnitXP, "distanceBetween", "player", "pet")
          if success and petDist then
            this.petText:SetText(string.format("%.1f", petDist))
            -- 颜色：使用独立配置
            this.petText:SetTextColor(pet_color[1], pet_color[2], pet_color[3], pet_color[4] or 1)
            this.petText:Show()
          else
            this.petText:Hide()
          end
        else
          this.petText:Hide()
        end

        -- ===== 动态调整框架高度（根据显示的文本） =====
        local totalHeight = 0
        local textShown = this.text:GetText() and this.text:GetText() ~= ""
        local petShown = this.petText:IsShown()

        if textShown then
          totalHeight = totalHeight + this.text:GetHeight()
        end
        if petShown then
          local offsetY = tonumber(C.unitframes.distance_indicator_pet_offset_y) or -20
          totalHeight = totalHeight + math.abs(offsetY) + this.petText:GetHeight()
        end

        if totalHeight > 0 then
          this:SetHeight(totalHeight)
        else
          this:SetHeight(30)  -- 默认高度
        end
      end)

      pfUI.distanceIndicator = frame
      pfUI.movables["pfDistanceIndicator"] = frame
      UpdateMovable(frame)
    end

    return true
  end

  -- ===== 新增：获取鼠标悬停距离颜色 =====
  local function GetMouseoverDistanceColor(distance, unit)
    local r, g, b = 1, 1, 1  -- 默认白色

    -- 视野外颜色覆盖（如果启用）
    if C.unitframes.mouseover_distance_use_outsight == "1" then
      local success, inSight = pcall(UnitXP, "inSight", "player", unit or "mouseover")
      if success and inSight == false then
        local outColor = {strsplit(",", C.unitframes.mouseover_distance_outsight_color)}
        return tonumber(outColor[1]) or 0.66, tonumber(outColor[2]) or 0.66, tonumber(outColor[3]) or 0.66
      end
    end

    -- 线性渐变（如果启用）
    if C.unitframes.mouseover_distance_linear_color == "1" then
      local fromDist = tonumber(C.unitframes.mouseover_distance_linear_from) or 0
      local toDist = tonumber(C.unitframes.mouseover_distance_linear_to) or 40
      local fromColor = {strsplit(",", C.unitframes.mouseover_distance_linear_color_from or "0,1,0")}
      local toColor = {strsplit(",", C.unitframes.mouseover_distance_linear_color_to or "1,0,0")}

      -- 将距离限制在渐变范围内
      local clampedDist = math.min(math.max(distance, fromDist), toDist)
      local t = (clampedDist - fromDist) / (toDist - fromDist)
      r = tonumber(fromColor[1]) + (tonumber(toColor[1]) - tonumber(fromColor[1])) * t
      g = tonumber(fromColor[2]) + (tonumber(toColor[2]) - tonumber(fromColor[2])) * t
      b = tonumber(fromColor[3]) + (tonumber(toColor[3]) - tonumber(fromColor[3])) * t
    end

    return r, g, b
  end

  -- 鼠标悬停距离提示设置（已修改，增加变色）
  local function SetupMouseoverTooltip()
    if C.unitframes.mouseover_tooltip_distance ~= "1" then return end

    -- 保存原始 OnShow
    local origOnShow = GameTooltip:GetScript("OnShow")
    GameTooltip:SetScript("OnShow", function()
        if type(origOnShow) == "function" then
            origOnShow()
        end

        if not UnitExists("mouseover") then return end
        local success, dist = pcall(UnitXP, "distanceBetween", "player", "mouseover")
        if not success or not dist then return end

        local unitSuffix = GetLocale() == "zhCN" and "码" or "yd"
        local newText = string.format("%.1f %s", dist, unitSuffix)

        -- 计算颜色
        local r, g, b = GetMouseoverDistanceColor(dist, "mouseover")

        -- 查找并更新已有距离行
        for i = 1, GameTooltip:NumLines() do
            local textObj = _G["GameTooltipTextLeft" .. i]
            if textObj then
                local text = textObj:GetText() or ""
                if string.find(text, "%d+%.?%d*%s*[码yd]+$") then
                    textObj:SetText(newText)
                    textObj:SetTextColor(r, g, b)
                    return
                end
            end
        end

        -- 未找到则新增一行
        local line = GameTooltip:NumLines() + 1
        GameTooltip:AddLine(newText, r, g, b)
        local newTextObj = _G["GameTooltipTextLeft" .. line]
        if newTextObj then
            GameTooltip:SetHeight(GameTooltip:GetHeight() + newTextObj:GetHeight())
        end
    end)

    -- 创建实时更新帧
    if not pfUI.mouseoverTooltipUpdater then
        local updater = CreateFrame("Frame", nil, UIParent)
        updater:SetScript("OnUpdate", function()
            if C.unitframes.mouseover_tooltip_distance ~= "1" then return end
            if not GameTooltip:IsVisible() then return end
            if not UnitExists("mouseover") then return end

            local success, dist = pcall(UnitXP, "distanceBetween", "player", "mouseover")
            if not success or not dist then return end

            local unitSuffix = GetLocale() == "zhCN" and "码" or "yd"
            local newText = string.format("%.1f %s", dist, unitSuffix)
            local r, g, b = GetMouseoverDistanceColor(dist, "mouseover")

            for i = 1, GameTooltip:NumLines() do
                local textObj = _G["GameTooltipTextLeft" .. i]
                if textObj then
                    local text = textObj:GetText() or ""
                    if string.find(text, "%d+%.?%d*%s*[码yd]+$") then
                        textObj:SetText(newText)
                        textObj:SetTextColor(r, g, b)
                        break
                    end
                end
            end
        end)
        pfUI.mouseoverTooltipUpdater = updater
    end
  end

  CreateIndependentIndicators()

  local initFrame = CreateFrame("Frame")
  initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
  initFrame:RegisterEvent("PLAYER_LOGOUT")
  initFrame:SetScript("OnEvent", function()
    if event == "PLAYER_LOGOUT" then
      this:UnregisterAllEvents()
      this:SetScript("OnEvent", nil)
      if pfUI.distanceIndicator then
        pfUI.distanceIndicator:SetScript("OnUpdate", nil)
      end
      if pfUI.mouseoverTooltipUpdater then
        pfUI.mouseoverTooltipUpdater:SetScript("OnUpdate", nil)
        pfUI.mouseoverTooltipUpdater = nil
      end
      return
    end
    CreateIndependentIndicators()
    SetupMouseoverTooltip()  -- 启用鼠标悬停距离提示
    this:UnregisterAllEvents()
  end)

  -- OS Notification Support (unchanged)
  if C.unitframes.unitxp_notify == "1" then
    local notifyFrame = CreateFrame("Frame")
    notifyFrame:RegisterEvent("CHAT_MSG_WHISPER")
    notifyFrame:RegisterEvent("CHAT_MSG_BN_WHISPER")
    notifyFrame:RegisterEvent("READY_CHECK")
    notifyFrame:RegisterEvent("RAID_INSTANCE_WELCOME")
    notifyFrame:RegisterEvent("PLAYER_LOGOUT")

    notifyFrame:SetScript("OnEvent", function()
      if event == "PLAYER_LOGOUT" then
        this:UnregisterAllEvents()
        this:SetScript("OnEvent", nil)
        return
      end
      pcall(UnitXP, "notify", "taskbarIcon")
      pcall(UnitXP, "notify", "systemSound")
    end)

    local origBattlefieldPortShow = BattlefieldFrame_Show
    if origBattlefieldPortShow then
      BattlefieldFrame_Show = function()
        pcall(UnitXP, "notify", "taskbarIcon")
        pcall(UnitXP, "notify", "systemSound")
        return origBattlefieldPortShow()
      end
    end
  end

  -- Enhanced Distance API (unchanged)
  pfUI.api.GetPreciseDistance = function(unit1, unit2)
    if not unit2 then
      unit2 = unit1
      unit1 = "player"
    end
    local success, distance = pcall(UnitXP, "distanceBetween", unit1, unit2)
    if success then return distance end
    return nil
  end

  pfUI.api.IsInMeleeRange = function(unit)
    local success, distance = pcall(UnitXP, "distanceBetween", "player", unit, "meleeAutoAttack")
    if success and distance then
      return distance <= 5
    end
    return nil
  end

  pfUI.api.GetAoEDistance = function(unit1, unit2)
    if not unit2 then
      unit2 = unit1
      unit1 = "player"
    end
    local success, distance = pcall(UnitXP, "distanceBetween", unit1, unit2, "AoE")
    if success then return distance end
    return nil
  end

  pfUI.api.TargetNearestEnemy = function()
    local success, found = pcall(UnitXP, "target", "nearestEnemy")
    return success and found
  end

  pfUI.api.TargetHighestHP = function()
    local success, found = pcall(UnitXP, "target", "mostHP")
    return success and found
  end

  pfUI.api.TargetNextEnemy = function()
    local success, found = pcall(UnitXP, "target", "nextEnemyInCycle")
    return success and found
  end

  pfUI.api.TargetPreviousEnemy = function()
    local success, found = pcall(UnitXP, "target", "previousEnemyInCycle")
    return success and found
  end

  pfUI.api.TargetNextMarked = function(order)
    local success, found = pcall(UnitXP, "target", "nextMarkedEnemyInCycle", order)
    return success and found
  end

  pfUI.api.UnitInLineOfSight = function(unit1, unit2)
    if not unit2 then
      unit2 = unit1
      unit1 = "player"
    end
    local success, inSight = pcall(UnitXP, "inSight", unit1, unit2)
    if success then return inSight end
    return nil
  end

  pfUI.api.UnitIsBehind = function(unit1, unit2)
    if not unit2 then
      unit2 = unit1
      unit1 = "player"
    end
    local success, behind = pcall(UnitXP, "behind", unit1, unit2)
    if success then return behind end
    return nil
  end

  -- Debug command
  SLASH_PFUNITXP1 = "/pfunitxp"
  SlashCmdList["PFUNITXP"] = function()
    local chat = DEFAULT_CHAT_FRAME
    chat:AddMessage("|cff33ffccpfUI|r: UnitXP 指示器调试")

    if not UnitExists("target") then
      chat:AddMessage(" |cffff0000未选中目标|r")
      return
    end

    local successB, behind = pcall(UnitXP, "behind", "player", "target")
    chat:AddMessage(" 后背检测: success=" .. tostring(successB) .. " value=" .. tostring(behind) .. " type=" .. type(behind))

    local successL, inSight = pcall(UnitXP, "inSight", "player", "target")
    chat:AddMessage(" 视线检测: success=" .. tostring(successL) .. " value=" .. tostring(inSight) .. " type=" .. type(inSight))

    chat:AddMessage(" 独立框架状态:")
    if pfUI.distanceIndicator then
      chat:AddMessage("  距离指示器: |cff00ff00存在|r, 可见=" .. tostring(pfUI.distanceIndicator:IsVisible()))
      if pfUI.distanceIndicator.petText then
        chat:AddMessage("  宠物距离文本: |cff00ff00存在|r")
      else
        chat:AddMessage("  宠物距离文本: |cffff0000不存在|r")
      end
    else
      chat:AddMessage("  距离指示器: |cffff0000未创建|r")
    end
  end
end)