local L = VoidFactions.Lang.GetPhrase
local sc = VoidUI.Scale

local cachedPages = cachedPages or {}

local PANEL = {}

function PANEL:Init()
    self:SetOrigSize(1000, 600)
    self:SetTitle(string.upper(L"ranking"))

    self.requestedPages = cachedPages or {}
    self.top = {}

    local container = self:Add("Panel")
    container:Dock(FILL)

    local topPanel = container:Add("Panel")
    topPanel:Dock(TOP)
    topPanel.Paint = function (self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, VoidUI.Colors.Primary)
    end

    local factionPanel = container:Add("Panel")
    factionPanel:Dock(FILL)
    factionPanel.Paint = function (self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, VoidUI.Colors.Primary)

        draw.SimpleText(string.upper(L"rank"), "VoidUI.B22", sc(30), sc(20), VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(string.upper(L"name"), "VoidUI.B22", sc(120), sc(20), VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(string.upper(L"level"), "VoidUI.B22", sc(380), sc(20), VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        draw.SimpleText(string.upper(L"members"), "VoidUI.B22", sc(560), sc(20), VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        draw.SimpleText(string.upper(L"actions"), "VoidUI.B22", w-sc(120), sc(20), VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    local rowContent = factionPanel:Add("VoidUI.RowPanel")
    rowContent:Dock(FILL)

    rowContent:SetSpacing(5)

    local pagination = factionPanel:Add("VoidUI.PaginationPanel")
    pagination:Dock(BOTTOM)
    pagination:SetTranslations(L"showingPagination", L"page", L"from")

    pagination:PageChange(function (page)
        if (cachedPages[page]) then
            self:DisplayPage(page)
        end
        self:RequestPage(page)
    end)

    self.topExists = false
    
    self.topPanel = topPanel
    self.factionPanel = factionPanel
    self.container = container
    self.pagination = pagination
    self.rowContent = rowContent

    if (table.Count(cachedPages) > 0) then
        self.top = cachedPages[1]

        self:DisplayTop()
        self:DisplayPage(1)
    end

    self:RequestPage(1)
    self:AddHooks()
end

function PANEL:AddHooks()
    hook.Add("VoidFactions.Factions.ReceivedRankingPage", "VoidFactions.UI.RankingPanel.RankingReceived", function (page, factions, totalPages)
        self.requestedPages[page] = factions
        self:DisplayPage(page)

        cachedPages = self.requestedPages

        if (totalPages) then
            self.pagination:TotalPages(totalPages)
        end

        if (page == 1) then
            self.top = factions
            self:DisplayTop()
        end
    end)
end

function PANEL:OnRemove()
    hook.Remove("VoidFactions.Factions.ReceivedRankingPage", "VoidFactions.UI.RankingPanel.RankingReceived")
end

function PANEL:RequestPage(page)
    VoidFactions.Faction:RequestRankingPage(page)
end

function PANEL:DisplayTop()
    if (self.topExists) then return end
    self.topExists = true

    local topPanel = self.topPanel

    local rankContainer = topPanel:Add("Panel")
    rankContainer:Dock(FILL)

    local trophySize = 65

    local thirdPlace = self.top[3]
    local thirdRank = rankContainer:Add("Panel")
    thirdRank:Dock(LEFT)
    thirdRank:SetVisible(thirdPlace)
    thirdRank.Paint = function (self, w, h)
        draw.RoundedBoxEx(8, 0, h-sc(40), w, sc(40), VoidUI.Colors.InputLight, true, true, false, false)
        draw.SimpleText(thirdPlace.name, "VoidUI.R20", w/2, h-sc(20), VoidUI.Colors.Bronze, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        surface.SetMaterial(VoidUI.Icons.Trophy)
        surface.SetDrawColor(VoidUI.Colors.Bronze)
        surface.DrawTexturedRect(w/2-trophySize/2, h-sc(40)-trophySize, trophySize, trophySize)

        draw.SimpleText("3.", "VoidUI.B20", w/2, h-sc(50)-trophySize/2, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end


    local firstPlace = self.top[1]
    local firstRank = rankContainer:Add("Panel")
    firstRank:Dock(LEFT)
    firstRank:SetVisible(firstPlace)
    firstRank.Paint = function (self, w, h)
        draw.RoundedBoxEx(8, 0, h-sc(80), w, sc(80), VoidUI.Colors.InputLight, true, true, false, false)
        draw.SimpleText(firstPlace.name, "VoidUI.R20", w/2, h-sc(40), VoidUI.Colors.Gold, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        surface.SetMaterial(VoidUI.Icons.Trophy)
        surface.SetDrawColor(VoidUI.Colors.Gold)
        surface.DrawTexturedRect(w/2-trophySize/2, h-sc(80)-trophySize, trophySize, trophySize)

        draw.SimpleText("1.", "VoidUI.B20", w/2, h-sc(90)-trophySize/2, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local secondPlace = self.top[2]
    local secondRank = rankContainer:Add("Panel")
    secondRank:Dock(RIGHT)
    secondRank:SetVisible(secondPlace)
    secondRank.Paint = function (self, w, h)
        draw.RoundedBoxEx(8, 0, h-sc(60), w, sc(60), VoidUI.Colors.InputLight, true, true, false, false)
        draw.SimpleText(secondPlace.name, "VoidUI.R20", w/2, h-sc(30), VoidUI.Colors.Silver, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        surface.SetMaterial(VoidUI.Icons.Trophy)
        surface.SetDrawColor(VoidUI.Colors.Silver)
        surface.DrawTexturedRect(w/2-trophySize/2, h-sc(60)-trophySize, trophySize, trophySize)

        draw.SimpleText("2.", "VoidUI.B20", w/2, h-sc(70)-trophySize/2, VoidUI.Colors.Black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.rankContainer = rankContainer
    self.thirdRank = thirdRank
    self.firstRank = firstRank
    self.secondRank = secondRank

    self:InvalidateLayout()
    self:InvalidateParent()
    self:InvalidateChildren()
end

function PANEL:DisplayPage(page)
    self.rowContent:Clear()
    self.pagination:CurrentPage(page)
    self.pagination:SetFromTo(page*6-6+1, page*6)

    local member = VoidFactions.PlayerMember
    local memberFaction = member.faction

    local factions = self.requestedPages[page]
    for rank, faction in pairs(factions) do
        local row = self.rowContent:Add("Panel")
        row:Dock(TOP)
        row.Paint = function (self, w, h)
            draw.SimpleText(faction.rank .. ".", "VoidUI.R22", sc(20), h/2, VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(faction.name, "VoidUI.R22", sc(90), h/2, VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(faction.level, "VoidUI.R22", sc(350), h/2, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(faction.count .. "/" .. faction.maxMembers, "VoidUI.R22", sc(530), h/2, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        local joinButton = row:Add("VoidUI.Button")
        joinButton:SetText(L"joinFaction")

        local canJoin = faction.canJoin
        if (!canJoin) then
            joinButton:SetText(L"inviteOnly")
        end
        if (memberFaction and memberFaction.id == faction.id) then
            canJoin = false
        end
        if (faction.count >= faction.maxMembers) then
            canJoin = false
        end

        joinButton:Dock(RIGHT)
        joinButton:SSetWide(140)
        joinButton:SetMedium()
        joinButton:MarginRight(20)
        joinButton:MarginTops(2)
        joinButton.rounding = 14
        
        joinButton.font = "VoidUI.R20"
        joinButton:SetEnabled(canJoin)

        joinButton.DoClick = function ()
            VoidFactions.Member:JoinFaction(faction.id)
        end


        self.rowContent:AddRow(row, 30)
    end
end

function PANEL:PerformLayout(w, h)
    self.container:MarginSides(45, self)
    self.container:MarginTop(10, self)
    self.container:MarginBottom(35, self)

    self.topPanel:SSetTall(160, self)
    self.factionPanel:MarginTop(15, self)

    self.factionPanel:SDockPadding(10, 10, 10, 10, self)

    self.rowContent:MarginTop(40, self)
    self.rowContent:MarginBottom(10, self)
    self.rowContent:MarginSides(20, self)

    self.pagination:SSetTall(30, self)

    if (self.topExists) then
        self.rankContainer:MarginSides(140, self)

        self.thirdRank:SSetWide(150, self)

        self.firstRank:MarginLeft(90, self)
        self.firstRank:SSetWide(150, self)

        if (!self.thirdRank:IsVisible()) then
            -- lol
            self.firstRank:MarginLeft(240, self)
        end

        self.secondRank:SSetWide(150, self)
    end
end

vgui.Register("VoidFactions.UI.RankingPanel", PANEL, "VoidUI.PanelContent")