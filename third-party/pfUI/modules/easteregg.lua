pfUI:RegisterModule("easteregg", "vanilla:tbc", function ()
  -- 圣诞快乐！
  if date("%m%d") == "1224" or date("%m%d") == "1225" then
    local title = (UnitFactionGroup("player") == "Horde") and PVP_RANK_18_0 or PVP_RANK_18_1
    local oldflag = _G.CHAT_FLAG_AFK

    local pvpking = CreateFrame("Frame", "pfPvPKing", UIParent)
    pvpking:Hide()

    pvpking:RegisterEvent("CHAT_MSG_SYSTEM")
    pvpking:SetScript("OnEvent", function()
      if strfind(arg1, "You are now", 1) and strfind(arg1, "(AFK)", 1) then
        _G.CHAT_FLAG_AFK = title .. " "
        this.time = GetTime()
        this:Show()
      end
    end)

    pvpking:SetScript("OnUpdate", function()
      if this.time + 1 < GetTime() then
        _G.CHAT_FLAG_AFK = oldflag
        this:Hide()
      end
    end)

    _G.MARKED_AFK           = "你现在是 |cff33ffcc" .. title .. "|r (暂离)。"
    _G.MARKED_AFK_MESSAGE   = "你现在是 |cff33ffcc" .. title .. "|r (暂离)：%s"
    _G.CLEARED_AFK          = "你不再是 |cff33ffcc" .. title .. "|r (暂离)。\n|cff33ffcc最爱|cffffffff 祝你圣诞快乐。感谢使用最爱插件包（基于PFUI，感谢shagu！）"
  end

  -- 新年快乐
  if date("%m%d") == "1231" or date("%m%d") == "0101" then
    local fireworks = CreateFrame("Button", "pfFireworks", WorldFrame)
    fireworks:SetFrameStrata("DIALOG")
    fireworks:SetAllPoints()
    fireworks:Hide()

    fireworks.night = fireworks:CreateTexture("LOW")
    fireworks.night:SetTexture(0,0,0,1)
    fireworks.night:SetGradientAlpha("VERTICAL", 0,0,0,.5, 0,0,0,1)
    fireworks.night:SetAllPoints()

    fireworks.stext = fireworks:CreateFontString("Status", "LOW", "GameFontWhite")
    fireworks.stext:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
    fireworks.stext:SetPoint("TOP", 0, -380)
    fireworks.stext:SetText("|cff33ffcc最爱|cffffffff 祝你节日快乐!")

    fireworks.text = fireworks:CreateFontString("Status", "LOW", "GameFontWhite")
    fireworks.text:SetFont(pfUI.media["font:BigNoodleTitling.ttf"], 38)
    fireworks.text:SetPoint("TOP", 0, -400)
    fireworks.text:SetText("新年快乐！")

    fireworks.dtext = fireworks:CreateFontString("Status", "LOW", "GameFontWhite")
    fireworks.dtext:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
    fireworks.dtext:SetPoint("TOP", 0, -430)
    fireworks.dtext:SetText("又一年相伴！\n\n感谢使用|cff33ffcc最爱|cffffffff插件包（基于PFUI，感谢|cff33ffccShagu|cffffffff!）\n\n|cff444444<点击>或输入'/afk'退出")

    fireworks:SetScript("OnClick", function()
      this:Hide()
    end)

    -- 暂离时触发烟花
    fireworks:RegisterEvent("CHAT_MSG_SYSTEM")
    fireworks:SetScript("OnEvent", function()
      if strfind(arg1, _G.MARKED_AFK) or strfind(arg1, _G.MARKED_AFK_MESSAGE) then
        this:SetAlpha(0)
        this:Show()
      elseif strfind(arg1, _G.CLEARED_AFK) then
        this:Hide()
      end
    end)

    -- 基础爆炸动画
    local function animation()
      local fps = (60 / math.max(GetFramerate(), 1))
      this:SetWidth(this:GetWidth()+fps)
      this:SetHeight(this:GetHeight()+fps)
      this:SetAlpha(this:GetAlpha()-fps*.01)
      if this:GetAlpha() <= 0 then
        this.free = true
        this:Hide()
      end
    end

    -- 缓存爆炸效果以复用帧
    local explosions = {}
    local function GetExplosion()
      for id, frame in pairs(explosions) do
        if frame.free then
          frame.free = nil
          return frame
        end
      end

      local frame = CreateFrame("Frame", nil, fireworks)
      frame:SetScript("OnUpdate", animation)
      frame.tex = frame:CreateTexture("HIGH")
      frame.tex:SetAllPoints()

      table.insert(explosions, frame)

      return frame
    end

    -- 在随机位置创建随机数量的烟花
    local width, height = GetScreenWidth(), GetScreenHeight()
    fireworks:SetScript("OnUpdate", function()
      -- 淡入黑夜
      if this:GetAlpha() < 1 then
        this:SetAlpha(this:GetAlpha() + .02)
        return
      end

      -- 让"新年快乐"闪烁
      local r,g,b = this.text:GetTextColor()
      this.text:SetTextColor(r+(math.random()-.5)/10, g+(math.random()-.5)/10, b+(math.random()-.5)/10,1)

      if ( this.tick or 1) > GetTime() then return else this.tick = GetTime() + math.random() - .2 end

      local x,y = math.random(1, width), -1*math.random(1,height)

      -- 创建基础爆炸
      local f = GetExplosion()
      f:ClearAllPoints()
      f:SetPoint("CENTER", fireworks, "TOPLEFT", x, y)
      f:SetWidth(25)
      f:SetHeight(25)
      f.tex:SetTexture(1,1,1,.5)
      f:SetAlpha(1)
      f:Show()

      -- 创建随机数量的彩色爆炸
      for i=1, math.random(20) do
        local f = GetExplosion()
        f:ClearAllPoints()
        f:SetPoint("CENTER", fireworks, "TOPLEFT", x+(math.random(0,100)-50), y+(math.random(0,100)-50))
        f:SetWidth(2)
        f:SetHeight(2)
        f.tex:SetTexture(math.random(),math.random(),math.random(),1)
        f:SetAlpha(1)
        f:Show()
      end
    end)
  end

  -- 情人节快乐 (2月14日)
  if date("%m%d") == "0214" then
    local fireworks = CreateFrame("Button", "pfFireworks", WorldFrame)
    fireworks:SetFrameStrata("DIALOG")
    fireworks:SetAllPoints()
    fireworks:Hide()

    fireworks.night = fireworks:CreateTexture("LOW")
    fireworks.night:SetTexture(0,0,0,1)
    fireworks.night:SetGradientAlpha("VERTICAL", 0,0,0,.5, 0,0,0,1)
    fireworks.night:SetAllPoints()

    fireworks.stext = fireworks:CreateFontString("Status", "LOW", "GameFontWhite")
    fireworks.stext:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
    fireworks.stext:SetPoint("TOP", 0, -380)
    fireworks.stext:SetText("|cff33ffcc最爱|cffffffff 祝你情人节快乐!")

    fireworks.text = fireworks:CreateFontString("Status", "LOW", "GameFontWhite")
    fireworks.text:SetFont(pfUI.media["font:BigNoodleTitling.ttf"], 38)
    fireworks.text:SetPoint("TOP", 0, -400)
    fireworks.text:SetText("情人节快乐！")
    fireworks.text:SetTextColor(1, 0.4, 0.7) -- 粉色系

    fireworks.dtext = fireworks:CreateFontString("Status", "LOW", "GameFontWhite")
    fireworks.dtext:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
    fireworks.dtext:SetPoint("TOP", 0, -430)
    fireworks.dtext:SetText("愿有岁月可回首，情深不负共白头！\n\n感谢使用|cff33ffcc最爱|cffffffff插件包（基于PFUI，感谢|cff33ffccShagu|cffffffff!）\n\n|cff444444<点击>或输入'/afk'退出")

    fireworks:SetScript("OnClick", function()
      this:Hide()
    end)

    -- 暂离时触发特效
    fireworks:RegisterEvent("CHAT_MSG_SYSTEM")
    fireworks:SetScript("OnEvent", function()
      if strfind(arg1, _G.MARKED_AFK) or strfind(arg1, _G.MARKED_AFK_MESSAGE) then
        this:SetAlpha(0)
        this:Show()
      elseif strfind(arg1, _G.CLEARED_AFK) then
        this:Hide()
      end
    end)

    -- 基础爆炸动画
    local function animation()
      local fps = (60 / math.max(GetFramerate(), 1))
      this:SetWidth(this:GetWidth()+fps)
      this:SetHeight(this:GetHeight()+fps)
      this:SetAlpha(this:GetAlpha()-fps*.01)
      if this:GetAlpha() <= 0 then
        this.free = true
        this:Hide()
      end
    end

    -- 缓存爆炸效果以复用帧
    local explosions = {}
    local function GetExplosion()
      for id, frame in pairs(explosions) do
        if frame.free then
          frame.free = nil
          return frame
        end
      end

      local frame = CreateFrame("Frame", nil, fireworks)
      frame:SetScript("OnUpdate", animation)
      frame.tex = frame:CreateTexture("HIGH")
      frame.tex:SetAllPoints()

      table.insert(explosions, frame)

      return frame
    end

    -- 在随机位置创建随机数量的心形特效
    local width, height = GetScreenWidth(), GetScreenHeight()
    fireworks:SetScript("OnUpdate", function()
      -- 淡入黑夜
      if this:GetAlpha() < 1 then
        this:SetAlpha(this:GetAlpha() + .02)
        return
      end

      -- 让"情人节快乐"闪烁
      local r,g,b = this.text:GetTextColor()
      this.text:SetTextColor(r+(math.random()-.5)/10, g+(math.random()-.5)/10, b+(math.random()-.5)/10,1)

      if ( this.tick or 1) > GetTime() then return else this.tick = GetTime() + math.random() - .2 end

      local x,y = math.random(1, width), -1*math.random(1,height)

      -- 创建基础爆炸（心形）
      local f = GetExplosion()
      f:ClearAllPoints()
      f:SetPoint("CENTER", fireworks, "TOPLEFT", x, y)
      f:SetWidth(30)
      f:SetHeight(30)
      f.tex:SetTexture(1, 0.4, 0.7,.5) -- 粉色
      f:SetAlpha(1)
      f:Show()

      -- 创建随机数量的彩色心形
      for i=1, math.random(15) do
        local f = GetExplosion()
        f:ClearAllPoints()
        f:SetPoint("CENTER", fireworks, "TOPLEFT", x+(math.random(0,80)-40), y+(math.random(0,80)-40))
        f:SetWidth(3)
        f:SetHeight(3)
        f.tex:SetTexture(1, math.random(0.3,0.7), math.random(0.6,0.9),1) -- 粉色到紫色
        f:SetAlpha(1)
        f:Show()
      end
    end)
  end

  -- 除夕快乐 (2026年2月16日)
  if date("%m%d") == "0216" then
    local fireworks = CreateFrame("Button", "pfFireworks", WorldFrame)
    fireworks:SetFrameStrata("DIALOG")
    fireworks:SetAllPoints()
    fireworks:Hide()

    fireworks.night = fireworks:CreateTexture("LOW")
    fireworks.night:SetTexture(0,0,0,1)
    fireworks.night:SetGradientAlpha("VERTICAL", 0,0,0,.5, 0,0,0,1)
    fireworks.night:SetAllPoints()

    fireworks.stext = fireworks:CreateFontString("Status", "LOW", "GameFontWhite")
    fireworks.stext:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
    fireworks.stext:SetPoint("TOP", 0, -380)
    fireworks.stext:SetText("|cff33ffcc最爱|cffffffff 祝你除夕快乐!")

    fireworks.text = fireworks:CreateFontString("Status", "LOW", "GameFontWhite")
    fireworks.text:SetFont(pfUI.media["font:BigNoodleTitling.ttf"], 38)
    fireworks.text:SetPoint("TOP", 0, -400)
    fireworks.text:SetText("除夕快乐！")
    fireworks.text:SetTextColor(1, 0.8, 0) -- 金色

    fireworks.dtext = fireworks:CreateFontString("Status", "LOW", "GameFontWhite")
    fireworks.dtext:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
    fireworks.dtext:SetPoint("TOP", 0, -430)
    fireworks.dtext:SetText("今岁今宵尽，明年明日催！\n\n感谢使用|cff33ffcc最爱|cffffffff插件包（基于PFUI，感谢|cff33ffccShagu|cffffffff!）\n\n|cff444444<点击>或输入'/afk'退出")

    fireworks:SetScript("OnClick", function()
      this:Hide()
    end)

    -- 暂离时触发特效
    fireworks:RegisterEvent("CHAT_MSG_SYSTEM")
    fireworks:SetScript("OnEvent", function()
      if strfind(arg1, _G.MARKED_AFK) or strfind(arg1, _G.MARKED_AFK_MESSAGE) then
        this:SetAlpha(0)
        this:Show()
      elseif strfind(arg1, _G.CLEARED_AFK) then
        this:Hide()
      end
    end)

    -- 基础爆炸动画
    local function animation()
      local fps = (60 / math.max(GetFramerate(), 1))
      this:SetWidth(this:GetWidth()+fps)
      this:SetHeight(this:GetHeight()+fps)
      this:SetAlpha(this:GetAlpha()-fps*.01)
      if this:GetAlpha() <= 0 then
        this.free = true
        this:Hide()
      end
    end

    -- 缓存爆炸效果以复用帧
    local explosions = {}
    local function GetExplosion()
      for id, frame in pairs(explosions) do
        if frame.free then
          frame.free = nil
          return frame
        end
      end

      local frame = CreateFrame("Frame", nil, fireworks)
      frame:SetScript("OnUpdate", animation)
      frame.tex = frame:CreateTexture("HIGH")
      frame.tex:SetAllPoints()

      table.insert(explosions, frame)

      return frame
    end

    -- 在随机位置创建随机数量的烟花
    local width, height = GetScreenWidth(), GetScreenHeight()
    fireworks:SetScript("OnUpdate", function()
      -- 淡入黑夜
      if this:GetAlpha() < 1 then
        this:SetAlpha(this:GetAlpha() + .02)
        return
      end

      -- 让"除夕快乐"闪烁
      local r,g,b = this.text:GetTextColor()
      this.text:SetTextColor(r+(math.random()-.5)/10, g+(math.random()-.5)/10, b+(math.random()-.5)/10,1)

      if ( this.tick or 1) > GetTime() then return else this.tick = GetTime() + math.random() - .2 end

      local x,y = math.random(1, width), -1*math.random(1,height)

      -- 创建基础爆炸
      local f = GetExplosion()
      f:ClearAllPoints()
      f:SetPoint("CENTER", fireworks, "TOPLEFT", x, y)
      f:SetWidth(25)
      f:SetHeight(25)
      f.tex:SetTexture(1,0.8,0,.5) -- 金色
      f:SetAlpha(1)
      f:Show()

      -- 创建随机数量的彩色爆炸（红色和金色为主）
      for i=1, math.random(20) do
        local f = GetExplosion()
        f:ClearAllPoints()
        f:SetPoint("CENTER", fireworks, "TOPLEFT", x+(math.random(0,100)-50), y+(math.random(0,100)-50))
        f:SetWidth(2)
        f:SetHeight(2)
        f.tex:SetTexture(math.random(0.8,1), math.random(0.5,0.8), 0,1) -- 红金色系
        f:SetAlpha(1)
        f:Show()
      end
    end)
  end

  -- 春节快乐 (2026年2月17-19日)
  if date("%m%d") == "0217" or date("%m%d") == "0218" or date("%m%d") == "0219" then
    local fireworks = CreateFrame("Button", "pfFireworks", WorldFrame)
    fireworks:SetFrameStrata("DIALOG")
    fireworks:SetAllPoints()
    fireworks:Hide()

    fireworks.night = fireworks:CreateTexture("LOW")
    fireworks.night:SetTexture(0,0,0,1)
    fireworks.night:SetGradientAlpha("VERTICAL", 0,0,0,.5, 0,0,0,1)
    fireworks.night:SetAllPoints()

    fireworks.stext = fireworks:CreateFontString("Status", "LOW", "GameFontWhite")
    fireworks.stext:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
    fireworks.stext:SetPoint("TOP", 0, -380)
    fireworks.stext:SetText("|cff33ffcc最爱|cffffffff 祝你春节快乐!")

    fireworks.text = fireworks:CreateFontString("Status", "LOW", "GameFontWhite")
    fireworks.text:SetFont(pfUI.media["font:BigNoodleTitling.ttf"], 38)
    fireworks.text:SetPoint("TOP", 0, -400)
    fireworks.text:SetText("春节快乐！")
    fireworks.text:SetTextColor(1, 0, 0) -- 红色

    fireworks.dtext = fireworks:CreateFontString("Status", "LOW", "GameFontWhite")
    fireworks.dtext:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
    fireworks.dtext:SetPoint("TOP", 0, -430)
    fireworks.dtext:SetText("春风吹拂千山绿，新年新景新气象！\n\n感谢使用|cff33ffcc最爱|cffffffff插件包（基于PFUI，感谢|cff33ffccShagu|cffffffff!）\n\n|cff444444<点击>或输入'/afk'退出")

    fireworks:SetScript("OnClick", function()
      this:Hide()
    end)

    -- 暂离时触发特效
    fireworks:RegisterEvent("CHAT_MSG_SYSTEM")
    fireworks:SetScript("OnEvent", function()
      if strfind(arg1, _G.MARKED_AFK) or strfind(arg1, _G.MARKED_AFK_MESSAGE) then
        this:SetAlpha(0)
        this:Show()
      elseif strfind(arg1, _G.CLEARED_AFK) then
        this:Hide()
      end
    end)

    -- 基础爆炸动画
    local function animation()
      local fps = (60 / math.max(GetFramerate(), 1))
      this:SetWidth(this:GetWidth()+fps)
      this:SetHeight(this:GetHeight()+fps)
      this:SetAlpha(this:GetAlpha()-fps*.01)
      if this:GetAlpha() <= 0 then
        this.free = true
        this:Hide()
      end
    end

    -- 缓存爆炸效果以复用帧
    local explosions = {}
    local function GetExplosion()
      for id, frame in pairs(explosions) do
        if frame.free then
          frame.free = nil
          return frame
        end
      end

      local frame = CreateFrame("Frame", nil, fireworks)
      frame:SetScript("OnUpdate", animation)
      frame.tex = frame:CreateTexture("HIGH")
      frame.tex:SetAllPoints()

      table.insert(explosions, frame)

      return frame
    end

    -- 在随机位置创建随机数量的烟花
    local width, height = GetScreenWidth(), GetScreenHeight()
    fireworks:SetScript("OnUpdate", function()
      -- 淡入黑夜
      if this:GetAlpha() < 1 then
        this:SetAlpha(this:GetAlpha() + .02)
        return
      end

      -- 让"春节快乐"闪烁
      local r,g,b = this.text:GetTextColor()
      this.text:SetTextColor(r+(math.random()-.5)/10, g+(math.random()-.5)/10, b+(math.random()-.5)/10,1)

      if ( this.tick or 1) > GetTime() then return else this.tick = GetTime() + math.random() - .2 end

      local x,y = math.random(1, width), -1*math.random(1,height)

      -- 创建基础爆炸
      local f = GetExplosion()
      f:ClearAllPoints()
      f:SetPoint("CENTER", fireworks, "TOPLEFT", x, y)
      f:SetWidth(25)
      f:SetHeight(25)
      f.tex:SetTexture(1,0,0,.5) -- 红色
      f:SetAlpha(1)
      f:Show()

      -- 创建随机数量的彩色爆炸（红色和金色为主）
      for i=1, math.random(25) do
        local f = GetExplosion()
        f:ClearAllPoints()
        f:SetPoint("CENTER", fireworks, "TOPLEFT", x+(math.random(0,120)-60), y+(math.random(0,120)-60))
        f:SetWidth(2)
        f:SetHeight(2)
        f.tex:SetTexture(math.random(0.8,1), math.random(0,0.2), 0,1) -- 红色系
        f:SetAlpha(1)
        f:Show()
      end
    end)
  end
end)