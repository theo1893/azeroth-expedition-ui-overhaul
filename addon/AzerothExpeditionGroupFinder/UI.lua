local A = AzerothExpeditionGroupFinder
local P = AEGFProtocol
local UI = A.UI or {}
A.UI = UI

local PANEL_WIDTH = 940
local PANEL_HEIGHT = 610
local LIST_PAGE_SIZE = 5
local APPLICATION_PAGE_SIZE = 5

UI.page = UI.page or 1
UI.applicationPage = UI.applicationPage or 1

local roleLabels = { D = "输出", N = "治疗", T = "坦克" }
local stateLabels = {
    SENT = "申请已发送",
    PENDING = "团长已收到",
    INVITED = "已邀请",
    REJECTED = "未通过",
    CLOSED = "已关闭",
}

local function makeButton(parent, width, text)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetWidth(width)
    button:SetHeight(22)
    button:SetText(text)
    return button
end

local function makeLabel(parent, text, x, y, width)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    label:SetWidth(width)
    label:SetJustifyH("LEFT")
    label:SetText(text)
    return label
end

local function makeEdit(parent, name, x, y, width, maximum)
    local edit = CreateFrame("EditBox", name, parent, "InputBoxTemplate")
    edit:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    edit:SetWidth(width)
    edit:SetHeight(20)
    edit:SetAutoFocus(false)
    edit:SetMaxLetters(maximum)
    edit:SetScript("OnEscapePressed", function() this:ClearFocus() end)
    return edit
end

local function setButtonEnabled(button, enabled)
    if enabled then
        button:Enable()
    else
        button:Disable()
    end
end

local function pageCount(total, size)
    return math.max(1, math.ceil(total / size))
end

local frame = CreateFrame("Frame", "AzerothExpeditionGroupFinderFrame", UIParent)
UI.frame = frame
frame:SetWidth(PANEL_WIDTH)
frame:SetHeight(PANEL_HEIGHT)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
frame:SetFrameStrata("DIALOG")
frame:SetScale(0.88)
frame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
})
frame:SetBackdropColor(0.025, 0.02, 0.012, 0.96)
frame:SetBackdropBorderColor(0.63, 0.48, 0.25, 0.95)
frame:EnableMouse(true)
frame:SetMovable(true)
if frame.SetClampedToScreen then
    frame:SetClampedToScreen(true)
end
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function() this:StartMoving() end)
frame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
frame:SetScript("OnShow", function()
    if not UI.loadedDraft then
        UI:LoadDraft()
    end
    A.RequestSync()
    UI:Refresh()
end)
frame:Hide()
table.insert(UISpecialFrames, frame:GetName())

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -14)
title:SetText("艾泽拉斯远征组队")

local version = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
version:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -42, -18)
version:SetTextColor(0.65, 0.62, 0.52, 1)
version:SetText("MVP " .. A.version)

local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -3, -3)

local divider = frame:CreateTexture(nil, "ARTWORK")
divider:SetPoint("TOPLEFT", frame, "TOPLEFT", 602, -43)
divider:SetWidth(2)
divider:SetHeight(548)
divider:SetTexture(0.43, 0.34, 0.20, 0.85)

makeLabel(frame, "正在招募的团队（选择后可直接申请）", 18, -47, 570)

UI.listRows = {}
local rowIndex
for rowIndex = 1, LIST_PAGE_SIZE do
    local row = CreateFrame("Button", nil, frame)
    row:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -68 - ((rowIndex - 1) * 82))
    row:SetWidth(570)
    row:SetHeight(78)
    row:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    row:SetBackdropColor(0.04, 0.035, 0.025, 0.80)
    row:SetBackdropBorderColor(0.28, 0.25, 0.19, 0.9)
    row:RegisterForClicks("LeftButtonUp")
    row:SetScript("OnClick", function()
        UI.selectedListingKey = this.listingKey
        A.selectedListingKey = this.listingKey
        UI:Refresh()
    end)
    row:SetScript("OnEnter", function()
        this:SetBackdropColor(0.11, 0.085, 0.045, 0.92)
    end)
    row:SetScript("OnLeave", function()
        UI:Refresh()
    end)

    row.line1 = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.line1:SetPoint("TOPLEFT", row, "TOPLEFT", 8, -7)
    row.line1:SetWidth(554)
    row.line1:SetJustifyH("LEFT")
    row.line1:SetTextColor(1, 0.82, 0.38, 1)

    row.line2 = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.line2:SetPoint("TOPLEFT", row, "TOPLEFT", 8, -22)
    row.line2:SetWidth(554)
    row.line2:SetJustifyH("LEFT")

    row.line3 = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.line3:SetPoint("TOPLEFT", row, "TOPLEFT", 8, -37)
    row.line3:SetWidth(554)
    row.line3:SetJustifyH("LEFT")
    row.line3:SetTextColor(0.70, 0.76, 0.80, 1)

    row.line4 = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.line4:SetPoint("TOPLEFT", row, "TOPLEFT", 8, -52)
    row.line4:SetWidth(554)
    row.line4:SetJustifyH("LEFT")
    row.line4:SetTextColor(0.70, 0.76, 0.80, 1)

    row.line5 = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.line5:SetPoint("TOPLEFT", row, "TOPLEFT", 8, -67)
    row.line5:SetWidth(554)
    row.line5:SetJustifyH("LEFT")
    row.line5:SetTextColor(0.76, 0.70, 0.58, 1)

    UI.listRows[rowIndex] = row
end

UI.previousPage = makeButton(frame, 36, "<")
UI.previousPage:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 18, 40)
UI.previousPage:SetScript("OnClick", function()
    UI.page = math.max(1, UI.page - 1)
    UI:Refresh()
end)

UI.pageText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
UI.pageText:SetPoint("LEFT", UI.previousPage, "RIGHT", 8, 0)
UI.pageText:SetWidth(72)

UI.nextPage = makeButton(frame, 36, ">")
UI.nextPage:SetPoint("LEFT", UI.pageText, "RIGHT", 0, 0)
UI.nextPage:SetScript("OnClick", function()
    UI.page = UI.page + 1
    UI:Refresh()
end)

UI.roleButton = makeButton(frame, 92, "申请职责：输出")
UI.roleButton:SetPoint("BOTTOM", frame, "BOTTOM", -147, 40)
UI.roleButton:SetScript("OnClick", function()
    if A.selectedRole == "D" then
        A.selectedRole = "N"
    elseif A.selectedRole == "N" then
        A.selectedRole = "T"
    else
        A.selectedRole = "D"
    end
    UI:Refresh()
end)

UI.applyButton = makeButton(frame, 96, "申请入团")
UI.applyButton:SetPoint("LEFT", UI.roleButton, "RIGHT", 8, 0)
UI.applyButton:SetScript("OnClick", function()
    local listing = UI.selectedListingKey and A.listings[UI.selectedListingKey]
    local ok, errorMessage = A.ApplyToListing(listing, A.selectedRole)
    UI:SetStatus(ok and "申请已发送。" or errorMessage, not ok)
end)

UI.status = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
UI.status:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 18, 15)
UI.status:SetWidth(570)
UI.status:SetJustifyH("LEFT")

makeLabel(frame, "发布／更新招募", 620, -47, 290)
makeLabel(frame, "团名", 620, -71, 70)
UI.titleEdit = makeEdit(frame, "AEGFTitleEdit", 620, -87, 286, 42)

makeLabel(frame, "最低装等", 620, -116, 62)
makeLabel(frame, "坦克 T", 694, -116, 55)
makeLabel(frame, "治疗 N", 766, -116, 55)
makeLabel(frame, "输出 D", 838, -116, 55)
UI.minimumItemLevelEdit = makeEdit(frame, "AEGFMinimumItemLevelEdit", 620, -132, 56, 3)
UI.targetTanksEdit = makeEdit(frame, "AEGFTargetTanksEdit", 694, -132, 52, 2)
UI.targetHealersEdit = makeEdit(frame, "AEGFTargetHealersEdit", 766, -132, 52, 2)
UI.targetDamageEdit = makeEdit(frame, "AEGFTargetDamageEdit", 838, -132, 52, 2)

makeLabel(frame, "职业上限：战,骑,猎,贼,牧,萨,法,术,德", 620, -163, 286)
UI.targetClassesEdit = makeEdit(frame, "AEGFTargetClassesEdit", 620, -179, 286, 35)

makeLabel(frame, "团长说明", 620, -208, 286)
UI.leaderInfoEdit = makeEdit(frame, "AEGFLeaderInfoEdit", 620, -224, 286, 42)

makeLabel(frame, "装备竞争（手工填写“物品 当前/上限”）", 620, -253, 286)
-- ponytail: this summary is manual; add structured item claims when applicants can choose contested loot.
UI.competitionEdit = makeEdit(frame, "AEGFCompetitionEdit", 620, -269, 286, 72)

UI.publishButton = makeButton(frame, 136, "发布招募")
UI.publishButton:SetPoint("TOPLEFT", frame, "TOPLEFT", 620, -302)
UI.publishButton:SetScript("OnClick", function()
    local ok, errorMessage = A.PublishListing(UI:ReadDraft())
    UI:SetStatus(ok and "招募信息已发布。" or errorMessage, not ok)
end)

UI.closeListingButton = makeButton(frame, 136, "停止招募")
UI.closeListingButton:SetPoint("LEFT", UI.publishButton, "RIGHT", 10, 0)
UI.closeListingButton:SetScript("OnClick", function()
    if A.CloseListing() then
        UI:SetStatus("已停止招募。")
    end
end)

makeLabel(frame, "收到的申请（装等为客户端自报值）", 620, -346, 286)

UI.applicationRows = {}
for rowIndex = 1, APPLICATION_PAGE_SIZE do
    local row = CreateFrame("Button", nil, frame)
    row:SetPoint("TOPLEFT", frame, "TOPLEFT", 620, -367 - ((rowIndex - 1) * 34))
    row:SetWidth(286)
    row:SetHeight(29)
    row:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.text:SetPoint("LEFT", row, "LEFT", 7, 0)
    row.text:SetWidth(272)
    row.text:SetJustifyH("LEFT")
    row:SetScript("OnClick", function()
        A.selectedApplicationName = this.applicationName
        UI:Refresh()
    end)
    UI.applicationRows[rowIndex] = row
end

UI.previousApplicationPage = makeButton(frame, 32, "<")
UI.previousApplicationPage:SetPoint("TOPLEFT", frame, "TOPLEFT", 620, -543)
UI.previousApplicationPage:SetScript("OnClick", function()
    UI.applicationPage = math.max(1, UI.applicationPage - 1)
    UI:Refresh()
end)

UI.applicationPageText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
UI.applicationPageText:SetPoint("LEFT", UI.previousApplicationPage, "RIGHT", 5, 0)
UI.applicationPageText:SetWidth(45)

UI.nextApplicationPage = makeButton(frame, 32, ">")
UI.nextApplicationPage:SetPoint("LEFT", UI.applicationPageText, "RIGHT", 0, 0)
UI.nextApplicationPage:SetScript("OnClick", function()
    UI.applicationPage = UI.applicationPage + 1
    UI:Refresh()
end)

UI.inviteButton = makeButton(frame, 72, "邀请")
UI.inviteButton:SetPoint("LEFT", UI.nextApplicationPage, "RIGHT", 12, 0)
UI.inviteButton:SetScript("OnClick", function()
    local application = UI:GetSelectedApplication()
    local ok, errorMessage = A.InviteApplicant(application)
    UI:SetStatus(ok and "已发出邀请。" or errorMessage, not ok)
end)

UI.rejectButton = makeButton(frame, 72, "拒绝")
UI.rejectButton:SetPoint("LEFT", UI.inviteButton, "RIGHT", 6, 0)
UI.rejectButton:SetScript("OnClick", function()
    local application = UI:GetSelectedApplication()
    local ok, errorMessage = A.RejectApplicant(application)
    UI:SetStatus(ok and "已拒绝申请。" or errorMessage, not ok)
end)

function UI:LoadDraft()
    local draft = A.GetDraft()
    self.titleEdit:SetText(draft.title)
    self.minimumItemLevelEdit:SetText(draft.minimumItemLevel)
    self.targetTanksEdit:SetText(draft.targetTanks)
    self.targetHealersEdit:SetText(draft.targetHealers)
    self.targetDamageEdit:SetText(draft.targetDamage)
    self.targetClassesEdit:SetText(draft.targetClasses)
    self.leaderInfoEdit:SetText(draft.leaderInfo)
    self.competitionEdit:SetText(draft.competition)
    self.loadedDraft = 1
end

function UI:ReadDraft()
    return {
        title = self.titleEdit:GetText(),
        minimumItemLevel = self.minimumItemLevelEdit:GetText(),
        targetTanks = self.targetTanksEdit:GetText(),
        targetHealers = self.targetHealersEdit:GetText(),
        targetDamage = self.targetDamageEdit:GetText(),
        targetClasses = self.targetClassesEdit:GetText(),
        leaderInfo = self.leaderInfoEdit:GetText(),
        competition = self.competitionEdit:GetText(),
    }
end

function UI:SetStatus(message, isError)
    self.status:SetText(message or "")
    if isError then
        self.status:SetTextColor(1, 0.30, 0.25, 1)
    else
        self.status:SetTextColor(0.55, 0.90, 0.55, 1)
    end
end

function UI:GetSelectedApplication()
    if not A.selectedApplicationName then
        return nil
    end
    return A.applications[string.lower(A.selectedApplicationName)]
end

function UI:Refresh()
    local listings = A.GetListings()
    local totalListings = table.getn(listings)
    local pages = pageCount(totalListings, LIST_PAGE_SIZE)
    self.page = math.min(math.max(1, self.page), pages)
    local first = ((self.page - 1) * LIST_PAGE_SIZE) + 1
    local index

    for index = 1, LIST_PAGE_SIZE do
        local row = self.listRows[index]
        local listing = listings[first + index - 1]
        if listing then
            local totalTarget = listing.targetTanks + listing.targetHealers + listing.targetDamage
            local info = listing.leaderInfo ~= "" and listing.leaderInfo or "无"
            local competition = listing.competition ~= "" and listing.competition or "无"
            row.listingKey = listing.key
            row.line1:SetText(listing.title .. "  |  团长 " .. listing.leader
                .. "  |  " .. listing.currentPlayers .. "/" .. totalTarget
                .. "  |  装等≥" .. listing.minimumItemLevel)
            row.line2:SetText("团长说明 " .. info .. "  |  配置 T" .. listing.targetTanks
                .. " N" .. listing.targetHealers .. " D" .. listing.targetDamage)
            row.line3:SetText("当前职业 " .. P.FormatClassVector(listing.currentClasses))
            row.line4:SetText("职业上限 " .. P.FormatClassVector(listing.targetClasses))
            row.line5:SetText("装备竞争 " .. competition)
            if self.selectedListingKey == listing.key or A.selectedListingKey == listing.key then
                self.selectedListingKey = listing.key
                A.selectedListingKey = listing.key
                row:SetBackdropColor(0.15, 0.10, 0.035, 0.95)
                row:SetBackdropBorderColor(0.90, 0.68, 0.25, 1)
            else
                row:SetBackdropColor(0.04, 0.035, 0.025, 0.80)
                row:SetBackdropBorderColor(0.28, 0.25, 0.19, 0.9)
            end
            row:Show()
        else
            row.listingKey = nil
            row:Hide()
        end
    end

    self.pageText:SetText(self.page .. "/" .. pages)
    setButtonEnabled(self.previousPage, self.page > 1)
    setButtonEnabled(self.nextPage, self.page < pages)
    self.roleButton:SetText("申请职责：" .. roleLabels[A.selectedRole])
    local selectedListing = self.selectedListingKey and A.listings[self.selectedListingKey]
    setButtonEnabled(self.applyButton, selectedListing
        and string.lower(selectedListing.leader or "") ~= string.lower(UnitName("player") or ""))

    local applications = A.GetApplications()
    local totalApplications = table.getn(applications)
    local applicationPages = pageCount(totalApplications, APPLICATION_PAGE_SIZE)
    self.applicationPage = math.min(math.max(1, self.applicationPage), applicationPages)
    first = ((self.applicationPage - 1) * APPLICATION_PAGE_SIZE) + 1
    for index = 1, APPLICATION_PAGE_SIZE do
        local row = self.applicationRows[index]
        local application = applications[first + index - 1]
        if application then
            row.applicationName = application.name
            row.text:SetText(application.name .. "  " .. P.classLabels[application.classIndex]
                .. " / " .. roleLabels[application.role] .. "  装等 " .. application.itemLevel)
            if A.selectedApplicationName == application.name then
                row:SetBackdropColor(0.15, 0.10, 0.035, 0.95)
                row:SetBackdropBorderColor(0.90, 0.68, 0.25, 1)
            else
                row:SetBackdropColor(0.04, 0.035, 0.025, 0.80)
                row:SetBackdropBorderColor(0.28, 0.25, 0.19, 0.9)
            end
            row:Show()
        else
            row.applicationName = nil
            row:Hide()
        end
    end

    self.applicationPageText:SetText(self.applicationPage .. "/" .. applicationPages)
    setButtonEnabled(self.previousApplicationPage, self.applicationPage > 1)
    setButtonEnabled(self.nextApplicationPage, self.applicationPage < applicationPages)
    local selectedApplication = self:GetSelectedApplication()
    setButtonEnabled(self.inviteButton, selectedApplication and A.activeListing)
    setButtonEnabled(self.rejectButton, selectedApplication and A.activeListing)
    self.publishButton:SetText(A.activeListing and "更新招募" or "发布招募")
    setButtonEnabled(self.closeListingButton, A.activeListing)

    local selectedState = selectedListing and A.applicationStates[selectedListing.key]
    local connection = A.channelJoined and "已连接" or "连接中"
    self:SetStatus("频道 " .. connection .. "  |  团队 " .. totalListings
        .. "  |  自身装等 " .. A.GetSelfItemLevel()
        .. (selectedState and "  |  " .. (stateLabels[selectedState] or selectedState) or ""))
end

function UI:Toggle()
    if self.frame:IsShown() then
        self.frame:Hide()
    else
        self.frame:Show()
    end
end
