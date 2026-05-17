local L = VoidFactions.Lang.GetPhrase
local sc = VoidUI.Scale

local PANEL = {}

function PANEL:Init()
    self:SetTitle(string.upper(L"faction"))
    self:SetOrigSize(1000, 600)

    local member = VoidFactions.PlayerMember
    local faction = member.faction

    local container = self:Add("Panel")
    container:Dock(FILL)

    local factionPanel = container:Add("Panel")
    factionPanel:Dock(TOP)
    factionPanel.Paint = function (self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, VoidUI.Colors.Primary)
    end

    local factionIcon = factionPanel:Add("Panel")
    factionIcon:Dock(LEFT)
    factionIcon.Paint = function (self, w, h)
        surface.SetDrawColor(faction.color)
        surface.DrawRect(0, 0, w, h)
    end

    local factionImage = factionIcon:Add("DImage")
    factionImage:Dock(FILL)
    VoidLib.FetchImage(faction.logo, function (mat)
        factionImage:SetMaterial(mat)
    end)

    local factionPanelInner = factionPanel:Add("Panel")
    factionPanelInner:Dock(FILL)

    local factionText = factionPanelInner:Add("Panel")
    factionText:Dock(LEFT)
    factionText.Paint = function (self, w, h)
        draw.SimpleText(string.upper(L"faction"), "VoidUI.B24", 0, h/2, VoidUI.Colors.Green, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        draw.SimpleText(faction.name, "VoidUI.R24", 0, h/2-2, VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    local factionRank = factionPanelInner:Add("Panel")
    factionRank:Dock(LEFT)
    factionRank.Paint = function (self, w, h)
        draw.SimpleText(string.upper(L"rank"), "VoidUI.B24", w/2, h/2, VoidUI.Colors.Green, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        draw.SimpleText(member.rank.name, "VoidUI.R24", w/2, h/2, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    local factionLeave = factionPanelInner:Add("VoidUI.Button")
    factionLeave:Dock(RIGHT)
    factionLeave:SetMedium()
    factionLeave:SetText(L"leave")
    factionLeave:SetColor(VoidUI.Colors.Red)

	factionLeave.DoClick = function ()
		VoidFactions.Member:LeaveFaction()
		VoidFactions.Menu.Panel:Remove()
	end

    -- Dont show for boss - faction can be disbanded in faction management
    factionLeave:SetVisible(member.rank.weight != 1)

    local factionManage = factionPanelInner:Add("VoidUI.Button")
    factionManage:Dock(RIGHT)
    factionManage:SetMedium()
    factionManage:SetText(L"details")
    factionManage:SetColor(VoidUI.Colors.Green)

	factionManage.DoClick = function ()
		self:GetParent():ManageFaction()
	end

    factionManage:SetVisible(true)
    
    
    local membersPanel = container:Add("Panel")
    membersPanel:Dock(FILL)
    membersPanel.Paint = function (self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, VoidUI.Colors.Primary)
    end

    local membersHeader = membersPanel:Add("Panel")
    membersHeader:Dock(TOP)
    membersHeader.Paint = function (self, w, h)
        local formattedString = VoidLib.StringFormat(L"memberCount",
        {
            x = #faction.members,
            total = faction.GetMaxMembers and faction:GetMaxMembers() or 0
        })
        draw.SimpleText(string.upper(formattedString), "VoidUI.B24", sc(25), h/2, VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local membersContent = membersPanel:Add("Panel")
    membersContent:Dock(FILL)
    membersContent.Paint = function (self, w, h)
		draw.RoundedBox(4, 0, 0, w, sc(22), VoidUI.Colors.BackgroundTransparent)
		
        draw.SimpleText(string.upper(L"name"), "VoidUI.B22", sc(35), sc(10), VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(string.upper(L"rank"), "VoidUI.B22", w/2, sc(10), VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local membersRows = membersContent:Add("VoidUI.RowPanel")
    membersRows:Dock(FILL)
    membersRows.Paint = function (self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, VoidUI.Colors.BackgroundTransparent)
    end

	local inviteButton = membersPanel:Add("VoidUI.Button")
	inviteButton:Dock(BOTTOM)
	inviteButton:SetMedium()
	inviteButton:SetText(L"inviteMember")

	local canInvite = true
	if (faction.members and #faction.members + 1 > faction:GetMaxMembers()) then canInvite = false end
	if (!member:Can("Invite")) then canInvite = false end

	inviteButton:SetEnabled(canInvite)

	local localPly = LocalPlayer()
	inviteButton.DoClick = function ()
		local selector = vgui.Create("VoidUI.ItemSelect")
		selector:SetParent(self)

		local membersTbl = {}
		for k, v in ipairs(faction.members) do
			membersTbl[v.sid] = v
		end

		local plyTbl = {}
		for _, ply in ipairs(player.GetHumans()) do
			if (!IsValid(ply)) then continue end
			if (ply == localPly) then continue end

			local sid = ply:SteamID64()
			if (membersTbl[sid]) then continue end
			
			plyTbl[sid] = ply:Nick()
		end

		selector:InitItems(plyTbl, function (id, v)
			local sid = id
			local ply = player.GetBySteamID64(sid)
			if (IsValid(ply)) then
				VoidFactions.Member:InvitePlayer(ply)
			end
		end)

		local cx, cy = input.GetCursorPos()
    	selector:SetPos(inviteButton.x + sc(700), cy - sc(250))
	end

    self.factionPanel = factionPanel
    self.factionPanelContent = factionPanelContent
    self.factionIcon = factionIcon
    self.factionImage = factionImage
    self.factionText = factionText
    self.factionPanelInner = factionPanelInner
    self.factionRank = factionRank

    self.factionLeave = factionLeave
    self.factionManage = factionManage

    self.membersPanel = membersPanel
    self.membersHeader = membersHeader
    self.membersContent = membersContent
    self.membersRows = membersRows

	self.inviteButton = inviteButton

    self.container = container

    self:PopulateMembers()

	hook.Add("VoidFactions.Faction.DataUpdated", "VoidFactions.UI.FactionPanel.UpdateData", function ()
		self:PopulateMembers()
	end)
end

function PANEL:OnRemove()
	hook.Remove("VoidFactions.Faction.DataUpdated", "VoidFactions.UI.FactionPanel.UpdateData")
end

function PANEL:PopulateMembers()
    local member = VoidFactions.PlayerMember
    local faction = member.faction

    self.membersRows:Clear()

    for _, facMember in ipairs(faction.members or {}) do
		local isOnline = IsValid(facMember.ply)
		
		local playerNick = L"loading"
		steamworks.RequestPlayerInfo(facMember.sid, function (nick)
            playerNick = nick
        end)

		if (facMember == member) then
			playerNick = playerNick .. " (" .. L"you" .. ")"
		end

        local canPromote = member:Can("ChangeRank", faction, nil, facMember)
        local canKick = member:Can("Kick", faction, nil, facMember)
        
        if (facMember.ply == LocalPlayer()) then
            canPromote = false
            canKick = false
        end

        local panel = self.membersRows:Add("Panel")
		panel.Paint = function (self, w, h)
			surface.SetDrawColor(isOnline and VoidUI.Colors.Green or VoidUI.Colors.Red)			
			VoidUI.DrawCircle(20, h/2, 5, 1)

			draw.SimpleText(playerNick or L"loading", "VoidUI.R22", sc(35), h/2-2, VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(facMember.rank and facMember.rank.name or "", "VoidUI.R22", w/2, h/2-2, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		local actionPanel = panel:Add("Panel")
		actionPanel:Dock(RIGHT)
		actionPanel:SSetWide(225)
		actionPanel:MarginRight(30)
		actionPanel:MarginTops(10)

		-- We need to fake the color because button background dont work with transparent backgrounds
		local buttonBg = Color(28, 28, 28)

		local panelKick = actionPanel:Add("VoidUI.Button")
		panelKick:Dock(RIGHT)
		panelKick:SSetWide(70)
		panelKick:SetSmallerMedium()
		panelKick:SetColor(VoidUI.Colors.Red, buttonBg)
		panelKick:SetText(L"kick")
		panelKick:SetEnabled(canKick)

		panelKick.DoClick = function ()
			VoidFactions.Member:KickMember(facMember, playerNick)
		end

		local panelChangeRank = actionPanel:Add("VoidUI.Button")
		panelChangeRank:Dock(LEFT)
		panelChangeRank:SSetWide(140)
		panelChangeRank:SetSmallerMedium()
		panelChangeRank:SetColor(VoidUI.Colors.Orange, buttonBg)
		panelChangeRank:SetText(L"changeRank")
		panelChangeRank:SetEnabled(canPromote)

		panelChangeRank.DoClick = function ()
			local selector = vgui.Create("VoidUI.ItemSelect")
            selector:SetParent(self)

            local rankTbl = {}
            for k, rank in ipairs(member.rank:GetRanksBelow()) do
                rankTbl[rank.id] = rank.name
            end

            selector:InitItems(rankTbl, function (id, v)
				local rank = faction.ranks[id]
                VoidFactions.Member:SetMemberRank(facMember, playerNick, rank)
            end)
		end


        self.membersRows:AddRow(panel, 45)
	end
end

function PANEL:PerformLayout(w, h)
    self.container:MarginSides(45, self)
    self.container:MarginTop(10, self)
    self.container:MarginBottom(25, self)

    self.factionPanel:SSetTall(100, self)
    self.factionPanel:SDockPadding(20, 10, 10, 10, self)
    self.factionIcon:SSetWide(80, self)
    self.factionImage:SDockMargin(2, 2, 2, 2, self)

    self.factionPanelInner:MarginSides(25, self)
    self.factionPanelInner:MarginTops(15, self)

    self.factionText:SSetWide(245, self)
    self.factionRank:SSetWide(165, self)

    self.factionLeave:MarginTops(8, self)
    self.factionLeave:SSetWide(85, self)

    self.factionManage:MarginTops(8, self)
    self.factionManage:SSetWide(110, self)
    self.factionManage:MarginRight(10, self)

    self.membersPanel:MarginTop(15, self)

    self.membersHeader:SSetTall(50)
    self.membersHeader:SDockPadding(20, 20, 20, 20)
    self.membersContent:SDockMargin(25, 0, 25, 15)
    self.membersRows:MarginTop(25, self)

	self.inviteButton:MarginSides(340, self)
	self.inviteButton:MarginBottom(15, self)
	self.inviteButton:SSetTall(35, self)

end

vgui.Register("VoidFactions.UI.DynamicFactionDashboard", PANEL, "VoidUI.PanelContent")

-- Faction panel dashboard

local PANEL = {}

function PANEL:Init()
    local dashboard = self:Add("VoidFactions.UI.DynamicFactionDashboard")
    dashboard:Dock(FILL)
    dashboard:SetVisible(true)

    local manageFaction = self:Add("VoidFactions.UI.DynamicManageFactionsPanel")
    manageFaction:Dock(FILL)
    manageFaction:SetVisible(false)

    self.dashboard = dashboard
    self.manageFaction = manageFaction
end

function PANEL:ManageFaction()
    self.dashboard:SetVisible(false)
    self.manageFaction:SetVisible(true)
end

function PANEL:GoBack()
	self.dashboard:SetVisible(true)
	self.manageFaction:SetVisible(false)
end

vgui.Register("VoidFactions.UI.DynamicFactionPanel", PANEL, "VoidUI.PanelContent")
