local L = VoidFactions.Lang.GetPhrase
local sc = VoidUI.Scale

local PANEL = {}

function PANEL:Init()
    local member = VoidFactions.PlayerMember
    local faction = member.faction
	local this = self

	self.isLoading = false

    local titlePanel = self:SetTitle("", true)
	self:SetOrigSize(1000, 600)

	self.titlePanel = titlePanel

	surface.SetFont("VoidUI.B30")


	local subfactions = {}
	local lastSize = 0
	for k, subfaction in pairs(VoidFactions.LoadedFactions) do
		if ( (subfaction.id == faction.id) or (subfaction.parentFaction and subfaction.parentFaction.id == faction.id) or (subfaction.parentFaction and subfaction.parentFaction.parentFaction and subfaction.parentFaction.parentFaction.id == faction.id) or member.rank.promoteDefault[subfaction.id] ) then
			local name = string.upper(subfaction.name)
			local size = (surface.GetTextSize(name) * 1.2)

			if (size > lastSize) then
				lastSize = size
			end

			subfactions[#subfactions + 1] = subfaction

		end
	end

	local factionDown = titlePanel:Add("VoidUI.Dropdown")
	factionDown:SSetTall(40)
	factionDown:SetWide(lastSize)
	factionDown:Center()
	for k, subfaction in ipairs(subfactions) do
		factionDown:AddChoice(subfaction.name, subfaction)

		if (subfaction.id == faction.id) then
			factionDown:ChooseOptionID(k)
		end
	end

	self.selectedFaction = faction


	function factionDown:OnSelect(index, value, data)
		self:GetParent():GetParent().selectedFaction = data
		self:GetParent():GetParent():LoadContent(data)
		self:GetParent():GetParent().checkIfCanInvite(data)
	end

	self.factionDown = factionDown

    self.container = self:Add("Panel")
    self.container:Dock(FILL)

    self.container.members = self.container:Add("Panel")
    self.container.members:Dock(FILL)
    
    self.container.members.Paint = function (self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, VoidUI.Colors.Primary)

        draw.SimpleText(L"name", "VoidUI.B24", sc(70), sc(20), VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(L"rank", "VoidUI.B24", w/2, sc(20), VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

		if (this.isLoading) then
			draw.SimpleText(L"loading", "VoidUI.B46", w/2, h/2, VoidUI.Colors.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
    end

    local membersContent = self.container.members:Add("VoidUI.RowPanel")
    membersContent:Dock(FILL)

    self.container.members.content = membersContent

	self:LoadContent(faction)

	local leaveButton = titlePanel:Add("VoidUI.Button")
	leaveButton:Dock(RIGHT)
	leaveButton:SetText(L"leaveFaction")
	leaveButton:MarginTops(7)
	leaveButton:MarginRight(15)
	leaveButton:SSetWide(160)
	leaveButton:SetCompact()
	leaveButton:SetColor(VoidUI.Colors.Red)
	leaveButton.DoClick = function ()
		VoidFactions.Member:LeaveFaction()
		VoidFactions.Menu.Panel.sidebar:SelectTab(VoidFactions.Menu.Panel.profileTab)
		VoidFactions.Menu.Panel.factionTab:Remove()
	end

	leaveButton:SetEnabled(!faction.isDefaultFaction)

	local inviteButton = self.container:Add("VoidUI.Button")
	inviteButton:Dock(BOTTOM)
	inviteButton:SetColor(VoidUI.Colors.Blue, VoidUI.Colors.Background)
	inviteButton:SetText(L"inviteMember")
	inviteButton:SetFont("VoidUI.R24")

	local function checkIfCanInvite(faction)
		local canInvite = true
		if (faction.maxMembers != 0 and (faction.members and (#faction.members + 1) or 0) > faction.maxMembers) then canInvite = false end
		
		local lowestRank = member.faction:GetLowestRank()
		if (lowestRank.maxMembers != 0 and #lowestRank:GetMembers() + 1 > lowestRank.maxMembers) then canInvite = false end
		if (!member:Can("Invite")) then canInvite = false end
		if (faction.isDefaultFaction) then canInvite = false end

		inviteButton:SetEnabled(canInvite)
	end

	self.checkIfCanInvite = checkIfCanInvite

	checkIfCanInvite(faction)

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

			local sid = ply:SteamID64()
			if (VoidChar) then
				sid = sid .. "-" .. ply:GetNWInt("VoidFactions.CharID")
			end
			if (membersTbl[sid]) then continue end
			
			plyTbl[sid] = ply:Nick()
		end

		selector:InitItems(plyTbl, function (id, v)
			local sid = VoidChar and string.Split(id, "-")[1] or id
			local ply = player.GetBySteamID64(sid)
			if (IsValid(ply)) then
				-- Invite
				VoidFactions.Member:InvitePlayer(ply, self.selectedFaction)
			end
		end)

		local cx, cy = input.GetCursorPos()
    	selector:SetPos(inviteButton.x + sc(700), cy - sc(250))
	end
	
	self.inviteButton = inviteButton

	hook.Add("VoidFactions.Faction.DataUpdated", "VoidFactions.UI.FactionPanel.UpdateData", function ()
		self:LoadContent(self.selectedFaction)
		self.checkIfCanInvite(self.selectedFaction)
	end)

	hook.Add("VoidFactions.Faction.RanksMembersReceived", "Voidfactions.UI.FactionPanel.MembersUpdate", function (faction)
		if (self.selectedFaction and self.selectedFaction.id == faction.id) then
			self:LoadContent(faction)
			self.checkIfCanInvite(self.selectedFaction)
		end
	end)
end

function PANEL:OnRemove()
	hook.Remove("VoidFactions.Faction.DataUpdated", "VoidFactions.UI.FactionPanel.UpdateData")
	hook.Remove("VoidFactions.Faction.RanksMembersReceived", "Voidfactions.UI.FactionPanel.MembersUpdate")
end

function PANEL:LoadContent(faction)
	local member = VoidFactions.PlayerMember
	
	local membersContent = self.container.members.content
	membersContent:Clear()

	self.isLoading = true

	if (!faction.members) then
		-- Request members
		VoidFactions.Faction:RequestFactionRanks(faction.id)
		return
	end

	self.isLoading = false

	local isSubfaction = false

	for _, facMember in ipairs(faction.members) do

		local isOnline = IsValid(facMember.ply)
		if (VoidChar and isOnline) then
			local charId = facMember.ply:GetNWInt("VoidFactions.CharID")
			local sidId = string.Split(facMember.sid, "-")[2] 
			isOnline = charId == sidId
		end
		
		local playerNick = facMember.name
		if (!playerNick) then
			playerNick = "Unknown"
			steamworks.RequestPlayerInfo(facMember.sid, function (nick)
				playerNick = nick
			end)
		end

		if (facMember == member) then
			playerNick = playerNick .. " (" .. L"you" .. ")"
		end

        local panel = membersContent:Add("Panel")
		panel.Paint = function (self, w, h)
			surface.SetDrawColor(isOnline and VoidUI.Colors.Green or VoidUI.Colors.Red)			
			VoidUI.DrawCircle(20, h/2, 7, 1)

			draw.SimpleText(playerNick or L"loading", "VoidUI.R22", sc(40), h/2-2, VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(facMember.rank and facMember.rank.name or "", "VoidUI.R22", w/2, h/2-2, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			draw.RoundedBox(0, 0, h-1, w, 1, VoidUI.Colors.Background)
		end

		

		local actionPanel = panel:Add("Panel")
		actionPanel:Dock(RIGHT)
		actionPanel:MarginTops(8)
		actionPanel:SSetWide(270)

		local promoteButton = actionPanel:Add("VoidUI.Button")
		promoteButton:Dock(LEFT)
		promoteButton:SSetWide(90)

		promoteButton:SetSmaller()
		promoteButton:SetText(L"promote")
		promoteButton:MarginRight(10)

		local canPromote = member:Can("Promote", facMember.faction, nil, facMember)
		local promoteFactions = nil
		local needsSelection = false
		local validPromoteFactions = {}

		local nextRank = facMember.faction:GetNextRank(facMember.rank)
		if (!nextRank and facMember.faction.parentFaction) then
			promoteFactions = {}

			local rootFaction = facMember.faction:GetRootFaction()
			local factionLevel = facMember.faction:GetFactionLevel()

			-- We get the next level factions by this
			for k, v in pairs(VoidFactions.LoadedFactions) do
				-- linq would be nice :(

				-- the factions must share their root faction!
				local _rootFaction = v:GetRootFaction()
				local _factionLevel = v:GetFactionLevel()

				if (factionLevel == _factionLevel + 1 and rootFaction == _rootFaction) then
					promoteFactions[k] = v
				end
			end


			for id, promoteFaction in pairs(promoteFactions or {}) do
				local b = member:Can("Promote", facMember.faction, nil, facMember, promoteFaction)
				if (b) then
					canPromote = true
					needsSelection = true

					validPromoteFactions[#validPromoteFactions + 1] = promoteFaction
				end
			end
		end

		
		promoteButton:SetEnabled(canPromote)

		promoteButton.DoClick = function ()
			if (needsSelection) then
				if (#validPromoteFactions == 1) then
					VoidFactions.Member:PromoteMember(facMember, playerNick, validPromoteFactions[1])
				else
					local selector = vgui.Create("VoidUI.ItemSelect")
					selector:SetParent(self)

					local factionTbl = {}
					for k, v in ipairs(validPromoteFactions or {}) do
						factionTbl[v.id] = v.name
					end
				
					selector:InitItems(factionTbl, function (id, v)
						VoidFactions.Member:PromoteMember(facMember, playerNick, promoteFactions[id])
					end)
				end
			else
				VoidFactions.Member:PromoteMember(facMember, playerNick)
			end
		end

		local demoteButton = actionPanel:Add("VoidUI.Button")
		demoteButton:Dock(LEFT)
		demoteButton:SSetWide(90)

		demoteButton:SetSmaller()
		demoteButton:SetText(L"demote")
		demoteButton:MarginRight(10)
		demoteButton:SetColor(VoidUI.Colors.Orange)

		local canDemote = member:Can("Demote", facMember.faction, nil, facMember)
		local subfactions = nil
		local needsSelection = false
		local validSubfactions = {}
		if (!canDemote) then
			local prevRank = facMember.faction:GetPrevRank(facMember.rank)
			if (!prevRank) then
				subfactions = facMember.faction:GetSubfactions()
				for id, subfaction in pairs(subfactions or {}) do
					local b = member:Can("Demote", facMember.faction, nil, facMember, subfaction)
					if (b) then
						canDemote = true
						needsSelection = true

						validSubfactions[#validSubfactions + 1] = subfaction
					end
				end
			end
		end


		demoteButton:SetEnabled(canDemote)

		demoteButton.DoClick = function ()
			if (needsSelection) then
				if (#validSubfactions == 1) then
					VoidFactions.Member:DemoteMember(facMember, playerNick, validSubfactions[1])
				else
					local selector = vgui.Create("VoidUI.ItemSelect")
					selector:SetParent(self)

					local factionTbl = {}
					for k, v in ipairs(validSubfactions or {}) do
						factionTbl[v.id] = v.name
					end
				
					selector:InitItems(factionTbl, function (id, v)
						VoidFactions.Member:DemoteMember(facMember, playerNick, subfactions[id])
					end)
				end
			else
				VoidFactions.Member:DemoteMember(facMember, playerNick)
			end
		end

		local kickButton = actionPanel:Add("VoidUI.Button")
		kickButton:Dock(LEFT)
		kickButton:SSetWide(60)
		kickButton:SetSmaller()
		kickButton:SetText(L"kick")
		kickButton:MarginRight(10)
		kickButton:SetColor(VoidUI.Colors.Red)

		kickButton:SetEnabled(member:Can("Kick", facMember.faction, nil, facMember))

		kickButton.DoClick = function ()
			VoidFactions.Member:KickMember(facMember, playerNick)
		end


		membersContent:AddRow(panel, 45)
    end
end

function PANEL:PerformLayout(w, h)
    self:SDockPadding(30,25,30,30, self)

    self.container:MarginTop(20, self)
    self.container.members:MarginBottom(20, self)
    self.container.members.content:MarginTop(50, self)
	self.container.members:SDockPadding(30, 0, 30, 0)

	self.inviteButton:SSetTall(48, self)
	self.inviteButton:MarginSides(340, self)

	self.factionDown:SetPos(self.titlePanel:GetWide() / 2 - self.factionDown:GetWide() / 2)
end

vgui.Register("VoidFactions.UI.FactionPanel", PANEL, "VoidUI.PanelContent")
