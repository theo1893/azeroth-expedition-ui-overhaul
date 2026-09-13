pfUI:RegisterSkin("Profession", "vanilla:tbc", function ()
  local rawborder, border = GetBorderSize()
  local bpad = rawborder > 1 and border - GetPerfectPixel() or GetPerfectPixel()

  local function WorkbenchPanel(frame, rim, width, height)
    if not frame or not AzerothExpeditionUI or not AzerothExpeditionUI.media then return end
    local media = AzerothExpeditionUI.media.root .. "Professions\\"
    local target = frame.backdrop or frame
    if rim == 16 then
      if frame.backdrop_shadow then frame.backdrop_shadow:Hide() end
      if target ~= frame then target:ClearAllPoints(); target:SetAllPoints(frame) end
    end
    target:SetBackdrop({ bgFile = media .. "WorkbenchLeatherV2", tile = true, tileSize = 64 })
    local shade = rim == 5 and .85 or 1
    target:SetBackdropColor(shade, shade * .9, shade * .75, 1)
    if frame.SetHighlightTexture then
      frame:SetHighlightTexture("Interface\\Buttons\\WHITE8X8")
      frame:GetHighlightTexture():SetVertexColor(.8, .6, .3, .18)
    end
    -- Reuse the accepted frame atlas; stretch only its straight edge regions.
    if not target.aeuiProfessionArt then
      target.aeuiProfessionArt = true
      if rim == 16 then
        local function Piece(path, x, y, width, height, u, v)
          local texture = target:CreateTexture(nil, "BORDER")
          texture:SetTexture(media .. path)
          texture:SetTexCoord(0, u or 1, 0, v or 1)
          texture:SetPoint("TOPLEFT", frame, "TOPLEFT", x, -y)
          texture:SetWidth(width); texture:SetHeight(height)
        end
        -- The anchored backdrop can still report the old native size during load.
        -- Use the layout contract and anchor each piece to the real window.
        Piece("CornerTLV2", 0, 0, 16, 16)
        Piece("CornerTRV2", width-16, 0, 16, 16)
        Piece("CornerBLV2", 0, height-16, 16, 16)
        Piece("CornerBRV2", width-16, height-16, 16, 16)
        for x=16,width-16,128 do
          local length=math.min(128,width-16-x)
          if length>0 then
            Piece("WoodTopV2",x,0,length,16,length/128,1)
            Piece("WoodBottomV2",x,height-16,length,16,length/128,1)
          end
        end
        for y=16,height-16,128 do
          local length=math.min(128,height-16-y)
          if length>0 then
            Piece("WoodLeftV2",0,y,16,length,1,length/128)
            Piece("WoodRightV2",width-16,y,16,length,1,length/128)
          end
        end
        return
      end
      local path = rim == 5 and "PanelRimV2" or "ButtonRimV2"
      if frame.GetNumber then path = "InputRimV2" end
      rim = 2
      local uv = {0, 4/32, 28/32, 1}
      local x, y = {0, rim, -rim, 0}, {0, -rim, rim, 0}
      for row = 1, 3 do
        for col = 1, 3 do
          if row ~= 2 or col ~= 2 then
            local texture = target:CreateTexture(nil, "BORDER")
            texture:SetTexture(media .. path)
            texture:SetTexCoord(uv[col], uv[col+1], uv[row], uv[row+1])
            texture:SetPoint("TOPLEFT", target,
              (row <= 2 and "TOP" or "BOTTOM") .. (col <= 2 and "LEFT" or "RIGHT"), x[col], y[row])
            texture:SetPoint("BOTTOMRIGHT", target,
              (row < 2 and "TOP" or "BOTTOM") .. (col < 2 and "LEFT" or "RIGHT"), x[col+1], y[row+1])
          end
        end
      end
    end
  end

  local function WorkbenchButton(button)
    if not button then return end
    WorkbenchPanel(button, 3)
    button:SetPushedTexture("Interface\\Buttons\\WHITE8X8")
    button:GetPushedTexture():SetVertexColor(.55, .35, .12, .22)
    local glyph = button.icon or button.texture
    if glyph and glyph.SetVertexColor then
      local name = button:GetName() or ""
      local sprite, height
      if string.find(name, "ScrollUpButton$") then sprite, height = "ArrowUpV2", 10
      elseif string.find(name, "ScrollDownButton$") or string.find(name, "DropDownButton$") then sprite, height = "ArrowDownV2", 10
      elseif string.find(name, "DecrementButton$") then sprite, height = "ArrowLeftV2", 14
      elseif string.find(name, "IncrementButton$") then sprite, height = "ArrowRightV2", 14
      elseif string.find(name, "CloseButton$") or string.find(name, "ClearButton$") then sprite, height = "CloseV2", 10 end
      if sprite and AzerothExpeditionUI and AzerothExpeditionUI.media then
        glyph:SetTexture(AzerothExpeditionUI.media.root .. "Professions\\" .. sprite)
        glyph:SetTexCoord(0, 20/32, 0, height*2/32)
        glyph:ClearAllPoints()
        glyph:SetPoint("CENTER", button.backdrop or button, "CENTER", 0, 0)
        glyph:SetWidth(10); glyph:SetHeight(height)
      end
      local function RefreshGlyph()
        local enabled = button:IsEnabled() ~= 0
        glyph:SetVertexColor(enabled and (sprite and 1 or .95) or .3,
          enabled and (sprite and 1 or .75) or .25, enabled and (sprite and 1 or .42) or .18, 1)
      end
      -- Replace pfUI's per-frame grey-arrow tint with native state transitions.
      if button.pficonfade then button.pficonfade:SetScript("OnUpdate", nil) end
      hooksecurefunc(button, "Enable", RefreshGlyph)
      hooksecurefunc(button, "Disable", RefreshGlyph)
      RefreshGlyph()
    end
    if button.text then button.text:SetTextColor(.95, .8, .5) end
  end

  local function WorkbenchControls(name, prefix, template, displayed)
    if not AzerothExpeditionUI or not AzerothExpeditionUI.media then return end
    local media = AzerothExpeditionUI.media.root
    for _, suffix in ipairs({"SubClassDropDown", "InvSlotDropDown"}) do
      local dropdown = _G[name .. suffix]
      if dropdown then
        WorkbenchPanel(dropdown, 3)
        WorkbenchButton(_G[name .. suffix .. "Button"])
      end
    end
    for _, suffix in ipairs({"ListScrollFrameScrollBar", "DetailScrollFrameScrollBar"}) do
      local bar = _G[name .. suffix]
      if bar then
        WorkbenchPanel(bar.bg, 2)
        WorkbenchButton(_G[bar:GetName() .. "ScrollUpButton"])
        WorkbenchButton(_G[bar:GetName() .. "ScrollDownButton"])
        local thumb = bar.thumb or bar:GetThumbTexture()
        thumb:SetTexture(media .. "Professions\\ThumbV2")
        thumb:SetTexCoord(0, 16/32, 0, 28/32)
        thumb:SetVertexColor(1, 1, 1, 1)
        thumb:ClearAllPoints()
        thumb:SetPoint("CENTER", bar:GetThumbTexture(), "CENTER", 0, 0)
        thumb:SetWidth(8); thumb:SetHeight(14)
      end
    end
    local collapse = _G[name .. "CollapseAllButton"]
    WorkbenchButton(collapse and collapse.icon)
    for i = 1, displayed do
      WorkbenchButton(_G[template .. i].icon)
    end
    for _, suffix in ipairs({"DecrementButton", "IncrementButton", "CreateButton", "CreateAllButton", "CancelButton"}) do
      WorkbenchButton(_G[name .. suffix])
    end
    WorkbenchButton(_G[name .. "FrameCloseButton"])
    for _, suffix in ipairs({"Mats", "Skill"}) do
      local checkbox = _G[prefix .. suffix .. "CheckButton"]
      if checkbox then
        local checked = checkbox:GetCheckedTexture()
        if checked then checked:SetVertexColor(.95, .8, .45) end
      end
    end
    local search = _G[prefix .. "SearchBox"]
    search:SetTextInsets(8, 24, 5, 5)
    local clear = _G[prefix .. "SearchBoxClearButton"]
    if clear then
      clear:SetNormalTexture(pfUI.media["img:close"])
      clear.texture = clear:GetNormalTexture()
      WorkbenchButton(clear)
    end
    -- Native refreshes change these colors; values and visibility remain native.
    local rank = _G[name .. "RankFrame"]
    WorkbenchPanel(rank, 3)
    rank:SetStatusBarTexture(media .. "ActionBars\\Readouts\\CastFillV1")
    local setColor = rank.SetStatusBarColor
    rank.SetStatusBarColor = function(self) setColor(self, .38, .65, .1, 1) end
    rank:SetStatusBarColor()
    local selected = _G[name .. "Highlight"]
    if selected then
      selected:SetTexture(media .. "Professions\\WorkbenchLeatherV2")
      selected:SetTexCoord(0, 1, 0, .125)
      local setVertexColor = selected.SetVertexColor
      selected.SetVertexColor = function(self) setVertexColor(self, 1, .72, .28, .85) end
      selected:SetVertexColor()
    end
  end

  local frames = {
    ["TradeSkill"] = { "Blizzard_TradeSkillUI", "TRADE_SKILLS_DISPLAYED", "TradeSkillSkill", "MAX_TRADE_SKILL_REAGENTS" },
    ["Craft"] = { "Blizzard_CraftUI", "CRAFTS_DISPLAYED", "Craft", "MAX_CRAFT_REAGENTS" },
  }

  for name, ext in pairs(frames) do
    local name        = name
    local ext         = ext
    local addon       = ext[1]
    local displayed   = ext[2]
    local template    = ext[3]
    local maxreagents = ext[4]
    local frame       = name .. "Frame"

    HookAddonOrVariable(addon, function()
      local SetSelection = frame.."_SetSelection"
      local icon = _G[template.."Icon"]
      local seltitle = _G[template.."Name"]
      local reagentlabel = _G[name.."ReagentLabel"]
      local collapseall = _G[name.."CollapseAllButton"]
      local detailscroll = _G[name.."DetailScrollFrame"]
      local detailscrollchild = _G[name.."DetailScrollChildFrame"]
      local detailscrollbar = _G[name.."DetailScrollFrameScrollBar"]
      local rankbar = _G[name.."RankFrame"]
      local decrease = _G[name.."DecrementButton"]
      local increase = _G[name.."IncrementButton"]
      local inputbox = _G[name.."InputBox"]
      local cancel = _G[name.."CancelButton"]
      local create = _G[name.."CreateButton"]
      local createall = _G[name.."CreateAllButton"]
      local subclassdropdown = _G[name.."SubClassDropDown"]
      local invslotdropdown = _G[name.."InvSlotDropDown"]
      local scrollbar = _G[name.."ListScrollFrameScrollBar"]
      local scrollframe = _G[name.."ListScrollFrame"]
      local close = _G[frame.."CloseButton"]
      local title = _G[frame.."TitleText"]
      local points = _G[frame.."PointsText"]
      local requiretext = _G[name .. "RequirementText"]
      local search = _G[name .. "FrameEditBox"]
      local turtlePrefix = name == "Craft" and "CraftFrame" or "TradeSkill"
      local turtleSearch = _G[turtlePrefix .. "SearchBox"]

      local frame = _G[frame]

      StripTextures(frame)
      CreateBackdrop(frame, nil, nil, .75)
      CreateBackdropShadow(frame)

      frame:SetWidth(676)
      frame:SetHeight(440)
      frame:DisableDrawLayer("BACKGROUND")
      EnableMovable(frame)

      title:ClearAllPoints()
      title:SetPoint("TOP", 0, -10)
      title:SetTextColor(1,1,1,1)
      SkinCloseButton(close, frame, -6, -6)

      do -- left pane
        StripTextures(scrollframe)
        SkinScrollbar(scrollbar)

        scrollframe:ClearAllPoints()
        scrollframe:SetPoint("TOPLEFT", 10, -65)
        scrollframe:SetWidth(300)
        scrollframe:SetHeight(365)

        local backdrop = CreateFrame("Frame", scrollframe:GetName().."Backdrop", frame)
        CreateBackdrop(backdrop, nil, nil, .75)
        scrollframe.backdrop = backdrop.backdrop
        scrollframe.backdrop:SetPoint("TOPLEFT", scrollframe, "TOPLEFT", -5, 5)
        scrollframe.backdrop:SetPoint("BOTTOMRIGHT", scrollframe, "BOTTOMRIGHT", 26, -5)

        _G[template..1]:ClearAllPoints()
        _G[template..1]:SetPoint("TOPLEFT", scrollframe, "TOPLEFT", 0, 0)

        StripTextures(collapseall)
        SkinCollapseButton(collapseall, true)
        collapseall:ClearAllPoints()
        collapseall:SetPoint("BOTTOMLEFT", scrollframe, "TOPLEFT", -5, 5)

        if invslotdropdown then
          SkinDropDown(invslotdropdown)
          invslotdropdown:ClearAllPoints()
          invslotdropdown:SetPoint("BOTTOMRIGHT", scrollframe.backdrop, "TOPRIGHT", 15, 0)

          SkinDropDown(subclassdropdown)
          subclassdropdown:ClearAllPoints()
          subclassdropdown:SetPoint("RIGHT", invslotdropdown, "LEFT", 27, 0)
        end
      end

      do -- right pane
        StripTextures(detailscroll)
        StripTextures(detailscrollchild)
        SkinScrollbar(detailscrollbar)

        local backdrop = CreateFrame("Frame", nil, frame)
        CreateBackdrop(backdrop, nil, nil, .75)
        detailscroll.backdrop = backdrop.backdrop

        detailscroll.backdrop:SetPoint("TOPLEFT", detailscroll, "TOPLEFT", -5, 5)
        detailscroll.backdrop:SetPoint("BOTTOMRIGHT", detailscroll, "BOTTOMRIGHT", 26, -5)

        StripTextures(_G[name.."RankFrameBorder"])
        CreateBackdrop(rankbar, nil, true)
        rankbar:SetStatusBarTexture(pfUI.media["img:bar"])
        rankbar:ClearAllPoints()
        rankbar:SetPoint("TOPLEFT", detailscroll.backdrop, "TOPLEFT", 0, 25)
        rankbar:SetPoint("BOTTOMRIGHT", detailscroll.backdrop, "TOPRIGHT", 0, 6)

        if decrease and increase then
          SkinArrowButton(decrease, "left", 18)
          SkinArrowButton(increase, "right", 18)
        end

        if inputbox then
          inputbox:DisableDrawLayer("BACKGROUND")
          CreateBackdrop(inputbox)
          SetAllPointsOffset(inputbox.backdrop, inputbox, .2)
          inputbox:SetJustifyH("CENTER")
          inputbox:SetWidth(36)
        end

        SkinButton(cancel)
        cancel:ClearAllPoints()
        cancel:SetPoint("TOPRIGHT", detailscroll.backdrop, "BOTTOMRIGHT", 0, -5)

        SkinButton(create)
        create:ClearAllPoints()
        create:SetPoint("RIGHT", cancel, "LEFT", -2*bpad, 0)

        SkinButton(createall)
        StripTextures(_G[name.."ExpandButtonFrame"])

        detailscroll:ClearAllPoints()
        detailscroll:SetPoint("TOPLEFT", 346, -65)
        detailscroll:SetWidth(299)
        detailscroll:SetHeight(338)

        -- skin buttons
        for i = 1, _G[maxreagents] do
          local name = name.."Reagent" .. i
          local item = _G[name]
          local icon = _G[name.."IconTexture"]
          local count = _G[name.."Count"]
          local title = _G[name.."Name"]
          local size = item:GetHeight() - 10

          StripTextures(item)
          CreateBackdrop(item, nil, nil, .75)
          SetAllPointsOffset(item.backdrop, item, 4)
          SetHighlight(item)

          icon:SetWidth(size)
          icon:SetHeight(size)
          icon:ClearAllPoints()
          icon:SetPoint("LEFT", 5, 0)
          icon:SetTexCoord(.08, .92, .08, .92)
          icon:SetParent(item.backdrop)
          icon:SetDrawLayer("OVERLAY")

          count:SetParent(item.backdrop)
          count:SetDrawLayer("OVERLAY")
          count:ClearAllPoints()
          count:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 0, 0)

          title:SetParent(item.backdrop)
          title:SetDrawLayer("OVERLAY")
        end

        if points then
          points:ClearAllPoints()
          points:SetPoint("RIGHT", create, "LEFT", -20, 0)
        end

        StripTextures(icon)
        icon:ClearAllPoints()
        icon:SetPoint("TOPLEFT", 5, -5)
        SkinButton(icon, nil, nil, nil, nil, true)
        icon:SetPushedTexture(nil)

        seltitle:SetJustifyV("TOP")
        seltitle:SetTextColor(.8,.8,.8,1)

        reagentlabel:ClearAllPoints()
        reagentlabel:SetPoint("TOPLEFT", seltitle, "BOTTOMLEFT", -45, -15)
        reagentlabel:SetTextColor(1,1,1,1)

        local scanner = libtipscan:GetScanner(name)
        hooksecurefunc(SetSelection, function(id)
          if id and id ~= 0 then
            detailscroll:Show()
            HandleIcon(icon, icon:GetNormalTexture())

            if name == "TradeSkill" then
              local itemlink  = GetTradeSkillItemLink(id)
              if not itemlink then return end
              local _, _, link = string.find(itemlink, "(item:%d+:%d+:%d+:%d+)")

              local cooldown = _G[template .. "Cooldown"]
              local off = (requiretext and requiretext:GetHeight() or 1)
                + (cooldown and cooldown:GetHeight() or 0)
              reagentlabel:SetPoint("TOPLEFT", seltitle, "BOTTOMLEFT", -45, -15-off)

              if link then
                scanner:SetHyperlink(link)
                seltitle:SetHeight(0)
                seltitle:SetText(scanner:FontString())

                if seltitle:GetHeight() < 30 then
                  seltitle:SetHeight(35)
                end
              else
                detailscroll:Hide()
              end
            end
            detailscroll:UpdateScrollChildRect()
          end
        end)
      end

      -- Compatibility
      if search then -- tbc
        _G[displayed] = 21
        scrollframe:SetHeight(338)

        local rank = _G[name.."RankFrameSkillRank"]
        rank:ClearAllPoints()
        rank:SetPoint("CENTER", rankbar, "CENTER", 0, 0)

        local available = _G[frame:GetName().."AvailableFilterCheckButton"]
        SkinCheckbox(available)
        available:ClearAllPoints()
        available:SetPoint("TOPLEFT", scrollframe.backdrop, "BOTTOMLEFT", -4, -5)

        search:DisableDrawLayer("BACKGROUND")
        CreateBackdrop(search, nil, nil, 1)
        search.backdrop:SetAllPoints(search)
        search:SetTextInsets(5, 5, 5, 5)
        search:SetHeight(22)
        search:ClearAllPoints()
        search:SetPoint("TOPRIGHT", scrollframe.backdrop, "BOTTOMRIGHT", 0, -5)

        local craft_filter = CraftFrameFilterDropDown
        if craft_filter then
          SkinDropDown(craft_filter)
          craft_filter:ClearAllPoints()
          craft_filter:SetPoint("BOTTOMRIGHT", scrollframe.backdrop, "TOPRIGHT", 15, 0)
        end
      elseif turtleSearch then -- Turtle WoW workbench
        frame:SetWidth(760)
        frame:SetHeight(548)
        title:ClearAllPoints()
        title:SetPoint("TOP", frame, "TOP", 0, -24)
        if AzerothExpeditionUI and AzerothExpeditionUI.media then
          title:SetFont(AzerothExpeditionUI.media.root .. "Fonts\\NotoSerifSC-SemiBold.ttf", 16)
        end
        title:SetTextColor(.94, .82, .60)
        close:ClearAllPoints()
        close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -18, -18)

        _G[displayed] = 22
        scrollframe:SetPoint("TOPLEFT", 22, -132)
        scrollframe:SetHeight(352)
        collapseall:ClearAllPoints()
        collapseall:SetPoint("TOPLEFT", frame, "TOPLEFT", 22, -108)
        if subclassdropdown and invslotdropdown then
          subclassdropdown:ClearAllPoints()
          subclassdropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -78)
          invslotdropdown:ClearAllPoints()
          invslotdropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 167, -78)
        end
        for i, suffix in ipairs({ "Mats", "Skill" }) do
          local checkbox = _G[turtlePrefix .. suffix .. "CheckButton"]
          if checkbox then
            SkinCheckbox(checkbox, 20)
            checkbox:ClearAllPoints()
            checkbox:SetPoint("TOPLEFT", frame, "TOPLEFT", 22 + (i - 1) * 160, -50)
            WorkbenchPanel(checkbox, 3)
          end
        end

        StripTextures(turtleSearch)
        CreateBackdrop(turtleSearch, nil, nil, 1)
        turtleSearch:SetTextInsets(8, 8, 5, 5)
        turtleSearch:SetHeight(22)
        turtleSearch:ClearAllPoints()
        turtleSearch:SetPoint("TOPLEFT", scrollframe.backdrop, "BOTTOMLEFT", 0, -5)
        turtleSearch:SetPoint("TOPRIGHT", scrollframe.backdrop, "BOTTOMRIGHT", 0, -5)

        detailscroll:SetPoint("TOPLEFT", 374, -110)
        detailscroll:SetWidth(342)
        detailscroll:SetHeight(370)
        detailscrollchild:SetWidth(342)
        rankbar:ClearAllPoints()
        rankbar:SetPoint("TOPLEFT", frame, "TOPLEFT", 369, -54)
        rankbar:SetPoint("BOTTOMRIGHT", frame, "TOPLEFT", 742, -74)
        local rank = _G[name .. "RankFrameSkillRank"]
        rank:ClearAllPoints()
        rank:SetPoint("RIGHT", rankbar, "RIGHT", -8, 0)
        seltitle:SetWidth(287)

        -- A fixed two-column material grid, including the seventh/eighth reagents.
        for i = 1, _G[maxreagents] do
          local reagent = _G[name .. "Reagent" .. i]
          reagent:ClearAllPoints()
          reagent:SetWidth(164)
          reagent:SetHeight(46)
          if i == 1 then
            reagent:SetPoint("TOPLEFT", reagentlabel, "BOTTOMLEFT", 0, -8)
          elseif math.mod(i, 2) == 0 then
            reagent:SetPoint("TOPLEFT", _G[name .. "Reagent" .. (i-1)], "TOPRIGHT", 6, 0)
          else
            reagent:SetPoint("TOPLEFT", _G[name .. "Reagent" .. (i-2)], "BOTTOMLEFT", 0, -6)
          end
          local text = _G[name .. "Reagent" .. i .. "Name"]
          text:ClearAllPoints()
          text:SetPoint("LEFT", reagent, "LEFT", 44, 0)
          text:SetWidth(112)
          WorkbenchPanel(reagent, 3)
        end

        cancel:ClearAllPoints()
        cancel:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -18, -504)
        create:SetPoint("RIGHT", cancel, "LEFT", -6, 0)
        if createall and decrease and inputbox and increase then
          createall:ClearAllPoints()
          createall:SetPoint("TOPLEFT", frame, "TOPLEFT", 369, -504)
          decrease:ClearAllPoints()
          decrease:SetPoint("LEFT", createall, "RIGHT", 6, 0)
          inputbox:ClearAllPoints()
          inputbox:SetPoint("LEFT", decrease, "RIGHT", 4, 0)
          increase:ClearAllPoints()
          increase:SetPoint("LEFT", inputbox, "RIGHT", 4, 0)
        end

        WorkbenchPanel(frame, 16, 760, 548)
        WorkbenchPanel(scrollframe.backdrop, 5)
        WorkbenchPanel(detailscroll.backdrop, 5)
        WorkbenchPanel(turtleSearch, 3)
        WorkbenchPanel(icon, 3)
        for _, suffix in ipairs({"CreateButton", "CreateAllButton", "CancelButton", "InputBox"}) do
          WorkbenchPanel(_G[name .. suffix], 3)
        end
      else -- vanilla
        _G[displayed] = 23
      end
      -- build remaining tradeskills
      for i = 9, _G[displayed] do
        local button = _G[template..i] or CreateFrame("Button", template..i, frame, template.."ButtonTemplate")
        button:SetPoint("TOPLEFT", _G[template..i - 1], "BOTTOMLEFT")
      end
      for i = 1, _G[displayed] do SkinCollapseButton(_G[template..i]) end
      if turtleSearch then WorkbenchControls(name, turtlePrefix, template, _G[displayed]) end
      if name == "TradeSkill" and turtleSearch then
        frame.aeuiQueueSkin = function(button)
          SkinButton(button)
          if AzerothExpeditionUI then WorkbenchButton(button) end
        end
        if TradeSkillQueueButton then frame.aeuiQueueSkin(TradeSkillQueueButton) end
      end
    end)
  end
end)

-- Recipe planning is independent of UI and never counts bank stock.
pfUI.professionQueue = {}
local queue = pfUI.professionQueue

function queue.Plan(root, count, recipes, inventory, preview)
  local stock, visiting, steps, casts, materials, shortage = {}, {}, {}, 0, {}, nil
  for id, amount in pairs(inventory) do stock[id] = amount end
  local function craft(recipe, amount)
    if visiting[recipe.id] then return nil, "配方循环：" .. recipe.name end
    if recipe.cooldown and not preview then return nil, "配方冷却中：" .. recipe.name end
    visiting[recipe.id] = true
    for _, reagent in ipairs(recipe.reagents) do
      if reagent.id == recipe.id then return nil, "配方循环：" .. recipe.name end
      local needed = reagent.count * amount
      local missing = needed - (stock[reagent.id] or 0)
      local child = recipes[reagent.id]
      if not child then
        local material = materials[reagent.id] or {id=reagent.id, name=reagent.name, count=0, owned=inventory[reagent.id] or 0}
        materials[reagent.id] = material
        material.count = material.count + needed
        if missing > 0 then shortage = shortage or ("缺少材料或本专业未学配方：" .. reagent.name .. " ×" .. missing) end
      elseif missing > 0 then
        local ok, reason = craft(child, math.ceil(missing / child.yield))
        if not ok then return nil, reason end
      end
      stock[reagent.id] = (stock[reagent.id] or 0) - needed
    end
    visiting[recipe.id] = nil
    casts = casts + amount
    if casts > 1000 then return nil, "本次制作超过 1000 次，请减少数量。" end
    table.insert(steps, {recipe=recipe, count=amount})
    stock[recipe.id] = (stock[recipe.id] or 0) + recipe.yield * amount
    return true
  end
  if not count or count < 1 or count > 1000 or count ~= math.floor(count) then
    return nil, "制作次数必须为 1–1000。"
  end
  local ok, reason = craft(root, count)
  if not ok then return nil, reason end
  if shortage and not preview then return nil, shortage, materials end
  return steps, shortage, materials
end

function queue.Maximum(root, recipes, inventory)
  local low, high = 0, 1000
  while low < high do
    local middle = math.floor((low + high + 1) / 2)
    if queue.Plan(root, middle, recipes, inventory) then low = middle else high = middle - 1 end
  end
  return low
end

pfUI:RegisterModule("profession-queue", "vanilla", function()
  local active, button, catalogue, catalogueRoots, catalogueProfession
  local Poll
  local driver = CreateFrame("Frame")
  local function Say(message) DEFAULT_CHAT_FRAME:AddMessage("|cffe6bf73连续制作：|r" .. message) end
  local function ItemID(link)
    local _, _, id = string.find(link or "", "item:(%d+)")
    return tonumber(id)
  end
  local function Inventory()
    local items = {}
    for bag = 0, 4 do
      for slot = 1, GetContainerNumSlots(bag) do
        local id = ItemID(GetContainerItemLink(bag, slot))
        if id then
          local _, count = GetContainerItemInfo(bag, slot)
          items[id] = (items[id] or 0) + (count or 0)
        end
      end
    end
    return items
  end
  local function Find(recipe)
    for i = 1, GetNumTradeSkills() do
      local name, kind = GetTradeSkillInfo(i)
      if kind ~= "header" and name == recipe.name and ItemID(GetTradeSkillItemLink(i)) == recipe.id then return i end
    end
  end
  local function SaveView(root)
    local view = {root=root, profession=GetTradeSkillLine(),
      subclasses={}, slots={}, collapsed={}, position=1}
    for i = 1, table.getn({GetTradeSkillSubClasses()}) do view.subclasses[i] = GetTradeSkillSubClassFilter(i) and 1 or 0 end
    for i = 1, table.getn({GetTradeSkillInvSlots()}) do view.slots[i] = GetTradeSkillInvSlotFilter(i) and 1 or 0 end
    for i = 1, GetNumTradeSkills() do
      local name, type, _, expanded = GetTradeSkillInfo(i)
      if type == "header" and not expanded then view.collapsed[name] = true end
    end
    return view
  end
  local function RestoreView(view)
    -- Restore filters only while the original profession is still open.
    if TradeSkillFrame:IsShown() and GetTradeSkillLine() == view.profession then
      for i, enabled in ipairs(view.subclasses) do SetTradeSkillSubClassFilter(i, enabled, i == 1 and 1 or nil) end
      for i, enabled in ipairs(view.slots) do SetTradeSkillInvSlotFilter(i, enabled, i == 1 and 1 or nil) end
      for i = GetNumTradeSkills(), 1, -1 do
        local name, kind = GetTradeSkillInfo(i)
        if kind == "header" and view.collapsed[name] then CollapseTradeSkillSubClass(i) end
      end
      local index = Find(view.root)
      if index then TradeSkillFrame_SetSelection(index) end
      TradeSkillFrame_Search()
    end
  end
  local function ReadRecipes()
    local recipes, roots = {}, {}
    for i = 1, GetNumTradeSkills() do
      local name, type = GetTradeSkillInfo(i)
      local id = type ~= "header" and ItemID(GetTradeSkillItemLink(i))
      if id then
        local minimum = GetTradeSkillNumMade(i)
        local recipe = {id=id, name=name, yield=math.max(1, minimum or 1),
          cooldown=GetTradeSkillCooldown(i), reagents={}}
        for r = 1, GetTradeSkillNumReagents(i) do
          local reagentName, _, count = GetTradeSkillReagentInfo(i, r)
          local reagentID = ItemID(GetTradeSkillReagentItemLink(i, r))
          if not reagentID then return nil, nil, "材料信息尚未加载，请重试。" end
          table.insert(recipe.reagents, {id=reagentID, name=reagentName, count=count})
        end
        recipes[id] = recipes[id] or recipe
        roots[name .. ":" .. id] = recipe
      end
    end
    return recipes, roots
  end
  local function Stop(reason)
    if not active then return end
    local old = active
    active = nil
    driver:Hide()
    button:SetText("连续制作")
    TradeSkillCreateButton:SetText(CREATE or "制作")
    RestoreView(old)
    if reason then Say(reason) end
  end
  local function Next()
    if not active then return end
    if not TradeSkillFrame:IsShown() or GetTradeSkillLine() ~= active.profession then Stop("已停止：专业窗口已切换或关闭。"); return end
    local step = active.steps[active.position]
    if not step then Stop("已完成。"); return end
    local index = Find(step.recipe)
    if not index then Stop("配方不可见，已停止；请保持分类展开。"); return end
    if GetTradeSkillCooldown(index) then Stop("配方正在冷却，已停止。"); return end
    local stock = Inventory()
    for _, reagent in ipairs(step.recipe.reagents) do
      if (stock[reagent.id] or 0) < reagent.count * step.count then Stop("背包材料已不足：" .. reagent.name); return end
    end
    active.awaitingClick = nil
    TradeSkillCreateButton:SetText(CREATE or "制作")
    TradeSkillFrame_SetSelection(index)
    active.pending = {id=step.recipe.id, before=stock[step.recipe.id] or 0,
      yield=step.recipe.yield * step.count, count=step.count, inventory=stock, reagents=step.recipe.reagents, deadline=GetTime()+45, startedAt=GetTime()}
    button:SetText("停止制作")
    Say("正在制作：" .. step.recipe.name .. "（本步剩余 " .. step.count .. " 次）")
    DoTradeSkill(index, step.count)
  end
  local function Start(all)
    if active then
      Stop("已停止。"); SpellStopCasting(); return
    end
    local index = GetTradeSkillSelectionIndex()
    if not index or index < 1 then Say("请先选择一个生产配方。"); return end
    local rootName, kind = GetTradeSkillInfo(index)
    local rootID = ItemID(GetTradeSkillItemLink(index))
    if not rootID or kind == "header" then Say("请先选择一个生产配方。"); return end
    local old = SaveView({id=rootID, name=rootName})
    active = old
    SetTradeSkillSubClassFilter(0, 1, 1)
    SetTradeSkillInvSlotFilter(0, 1, 1)
    ExpandTradeSkillSubClass(0)
    local recipes, roots, error = ReadRecipes()
    if not recipes then Stop(error); return end
    catalogue, catalogueRoots, catalogueProfession = recipes, roots, old.profession
    local root = roots[rootName .. ":" .. rootID]
    if not root then Stop("找不到所选配方。"); return end
    local inventory = Inventory()
    local count = all and queue.Maximum(root, recipes, inventory) or TradeSkillInputBox:GetNumber()
    if all and count == 0 then Stop("基础材料不足，无法制作。"); return end
    local steps, reason = queue.Plan(root, count, recipes, inventory)
    if not steps then Stop(reason); return end
    active.steps = steps
    local rootIndex = Find(root)
    if rootIndex then TradeSkillFrame_SetSelection(rootIndex) end
    Say("开始制作 " .. root.name .. " ×" .. count .. " 次；中间材料将按需补做（每批最多 1000 次含中间制作）。")
    driver:Show()
    Next()
    local session = active
    local function Continue()
      if not active or active ~= session then return end
      local ok, advance = pcall(Poll)
      if not ok then Stop("队列错误：" .. tostring(advance)); return end
      if advance and active == session then
        local step = active.steps[active.position]
        if not step then Stop("已完成。"); return end
        -- Vanilla requires a fresh hardware event when starting another recipe.
        active.awaitingClick = true
        local index = Find(step.recipe)
        if not index then Stop("找不到下一配方。"); return end
        TradeSkillFrame_SetSelection(index)
        TradeSkillCreateButton:SetText("继续制造")
        TradeSkillCreateButton:Enable()
        button:SetText("停止队列")
        Say("材料已备好：" .. step.recipe.name .. " ×" .. step.count .. " 次。点击“继续制造”开始。")
      end
      if active == session and not active.awaitingClick then QueueFunction(Continue) end
    end
    if session then session.continue = Continue; QueueFunction(Continue) end
  end
  driver:Hide()
  for _, event in ipairs({"SPELLCAST_START", "SPELLCAST_STOP", "SPELLCAST_FAILED", "SPELLCAST_INTERRUPTED", "TRADE_SKILL_CLOSE"}) do driver:RegisterEvent(event) end
  driver:SetScript("OnEvent", function()
    if not active then return end
    if event == "TRADE_SKILL_CLOSE" then Stop("专业窗口已关闭。"); return end
    if event == "SPELLCAST_FAILED" or event == "SPELLCAST_INTERRUPTED" then Stop("制作失败或被打断，已停止。"); return end
    local pending = active.pending
    if pending and event == "SPELLCAST_START" then
      pending.started = true
      pending.castUntil = GetTime() + (tonumber(arg2) or 0)/1000
      pending.deadline = GetTime() + (tonumber(arg2) or 0)/1000 + 15
    end
    if pending and event == "SPELLCAST_STOP" then pending.finished = true end
  end)
  Poll = function()
    if not active or not active.pending then return end
    if not TradeSkillFrame:IsShown() or GetTradeSkillLine() ~= active.profession then Stop("专业窗口已切换或关闭。"); return end
    local pending = active.pending
    local inventory = Inventory()
    local consumed = table.getn(pending.reagents) > 0
    for _, reagent in ipairs(pending.reagents) do
      if (inventory[reagent.id] or 0) > (pending.inventory[reagent.id] or 0) - reagent.count * pending.count then consumed = false end
    end
    -- Bag changes confirm production even when the legacy cast-stop event is absent.
    -- A received item alone must not advance the queue. Allow late cast events to settle.
    if consumed and (inventory[pending.id] or 0) >= pending.before + pending.yield or
      table.getn(pending.reagents) == 0 and pending.finished and (inventory[pending.id] or 0) >= pending.before + pending.yield then
      -- Inventory packets can arrive before the native trade batch exits casting.
      local casting = false
      if GetCurrentCastingInfo then
        local _, _, _, cast, channel = GetCurrentCastingInfo()
        casting = cast == 1 or channel == 1
      elseif pending.castUntil then
        casting = GetTime() < pending.castUntil
      end
      if casting then pending.readyAt = nil; return end
      if not pending.readyAt then
        local _, _, latency = GetNetStats()
        pending.readyAt = GetTime() + math.max(1, (latency or 0) / 500)
        return
      end
      if GetTime() < pending.readyAt then return end
      active.position = active.position + 1
      active.pending = nil
      return true
    elseif GetTime() > pending.deadline then Stop(pending.started and "制作未完成，已停止；请检查材料、背包空间和制作条件。" or "未收到施法开始，已停止；下一批未能开工。")
    elseif not pending.reported and GetTime() - pending.startedAt > 8 then
      pending.reported = true
      Say("等待确认：" .. active.steps[active.position].recipe.name .. "，产物 " ..
        (inventory[pending.id] or 0) .. "/" .. (pending.before + pending.yield) ..
        "，原料扣除=" .. (consumed and "是" or "否") .. "，施法开始=" .. (pending.started and "是" or "否"))
    end
  end
  HookAddonOrVariable("Blizzard_TradeSkillUI", function()
    button = CreateFrame("Button", "TradeSkillQueueButton", TradeSkillFrame, "UIPanelButtonTemplate")
    button:SetWidth(116); button:SetHeight(22)
    button:SetPoint("TOPLEFT", TradeSkillFrame, "TOPLEFT", 369, -80)
    button:SetText("连续制作")
    button:SetScript("OnClick", function() Start(false) end)
    TradeSkillCreateButton:SetScript("OnClick", function()
      if active and active.awaitingClick then
        local session = active
        Next()
        if active == session then QueueFunction(session.continue) end
      elseif not active then Start(false) end
    end)
    TradeSkillCreateAllButton:SetScript("OnClick", function() if not active then Start(true) end end)
    if pfUI_config.disabled.skin_Profession == "1" then
      button:ClearAllPoints(); button:SetPoint("TOPLEFT", TradeSkillFrame, "BOTTOMLEFT", 20, 0)
    end
    if TradeSkillFrame.aeuiQueueSkin then TradeSkillFrame.aeuiQueueSkin(button) end
    local summary = TradeSkillDetailScrollChildFrame:CreateFontString("TradeSkillRawMaterials", "OVERLAY", "GameFontHighlightSmall")
    summary:SetWidth(290)
    summary:SetJustifyH("LEFT")
    summary:SetTextColor(.9, .82, .65)
    local updater = CreateFrame("Frame", "pfUIProfessionMaterialsUpdater", TradeSkillFrame)
    local function RefreshMaterials()
      if not TradeSkillFrame:IsShown() then return end
      TradeSkillCreateButton:Disable()
      TradeSkillCreateAllButton:Disable()
      summary:SetText("")
      local index = GetTradeSkillSelectionIndex()
      if not index or index < 1 then return end
      local name, kind = GetTradeSkillInfo(index)
      local id = ItemID(GetTradeSkillItemLink(index))
      if not id or kind == "header" then return end
      if not catalogue or catalogueProfession ~= GetTradeSkillLine() then
        local view = SaveView({id=id, name=name})
        SetTradeSkillSubClassFilter(0, 1, 1)
        SetTradeSkillInvSlotFilter(0, 1, 1)
        ExpandTradeSkillSubClass(0)
        catalogue, catalogueRoots = ReadRecipes()
        catalogueProfession = view.profession
        RestoreView(view)
        index = GetTradeSkillSelectionIndex()
      end
      local count = TradeSkillInputBox:GetNumber()
      local root = catalogueRoots and catalogueRoots[name .. ":" .. id]
      local steps, reason, materials
      if root then
        local inventory = Inventory()
        steps, reason, materials = queue.Plan(root, count, catalogue, inventory, true)
        if active and active.awaitingClick then
          TradeSkillCreateButton:Enable()
        elseif not active then
          if queue.Plan(root, count, catalogue, inventory) then TradeSkillCreateButton:Enable() end
          if queue.Plan(root, 1, catalogue, inventory) then TradeSkillCreateAllButton:Enable() end
        end
      end
      local lines = {"基础原材料（" .. count .. " 次制作，已扣除现有中间材料）"}
      if steps then
        local rows = {}
        for _, material in pairs(materials) do table.insert(rows, material) end
        table.sort(rows, function(a,b) return a.name < b.name end)
        for _, material in ipairs(rows) do
          local missing = math.max(0, material.count - material.owned)
          local color = missing > 0 and "|cffff8066" or "|cffcce0aa"
          table.insert(lines, color .. material.name .. " ×" .. material.count ..
            "（背包 " .. material.owned .. "，缺 " .. missing .. "）|r")
        end
        if table.getn(rows) == 0 then table.insert(lines, "现有材料已满足，无需补做基础原料。") end
      else
        table.insert(lines, reason or "配方信息尚未加载，请重新打开专业窗口。")
      end
      local reagents = GetTradeSkillNumReagents(index)
      local anchor = reagents > 0 and _G["TradeSkillReagent" .. (reagents - math.mod(reagents+1, 2))] or TradeSkillReagentLabel
      summary:ClearAllPoints()
      summary:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -14)
      summary:SetText(table.concat(lines, "\n"))
      local top, bottom = TradeSkillDetailScrollChildFrame:GetTop(), summary:GetBottom()
      if top and bottom then
        local height = math.max(150, top - bottom + 12)
        if TradeSkillDetailScrollChildFrame:GetHeight() ~= height then TradeSkillDetailScrollChildFrame:SetHeight(height) end
      end
      TradeSkillDetailScrollFrame:UpdateScrollChildRect()
    end
    local function Schedule() updater:Show() end
    -- Native UI only counts direct ingredients. Re-evaluate disabled buttons
    -- against the full dependency chain, and prevent a second batch while active.
    for _, control in ipairs({TradeSkillCreateButton, TradeSkillCreateAllButton}) do
      local control, disable = control, control.Disable
      hooksecurefunc(control, "Disable", Schedule)
      hooksecurefunc(control, "Enable", function()
        if active and not (active.awaitingClick and control == TradeSkillCreateButton) then disable(control) end
      end)
    end
    updater:SetScript("OnUpdate", function() RefreshMaterials(); updater:Hide() end)
    for _, event in ipairs({"BAG_UPDATE", "TRADE_SKILL_UPDATE", "TRADE_SKILL_SHOW", "SKILL_LINES_CHANGED"}) do updater:RegisterEvent(event) end
    updater:SetScript("OnEvent", function()
      if not active and (event == "TRADE_SKILL_SHOW" or event == "SKILL_LINES_CHANGED") then catalogue=nil end
      Schedule()
    end)
    hooksecurefunc("TradeSkillFrame_SetSelection", Schedule)
    local changed = TradeSkillInputBox:GetScript("OnTextChanged")
    TradeSkillInputBox:SetScript("OnTextChanged", function()
      if changed then changed() end
      Schedule()
    end)
    Schedule()
  end)
end)
