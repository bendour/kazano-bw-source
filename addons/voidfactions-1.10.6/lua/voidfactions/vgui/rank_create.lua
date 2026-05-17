local sc = VoidUI.Scale
local L = VoidFactions.Lang.GetPhrase

local PANEL = {}

local nickSteamids = {}

function PANEL:Init()

	self:SetTitle(L"newRank")

	self:SSetSize(670, 520)
	self:Center()
	
	self.tabs = self:Add("VoidUI.Tabs")

	if (VoidFactions.Settings:IsDynamicFactions()) then
		self.tabs:SetAccentColor(VoidUI.Colors.Green)
	end

	local generalPanel = self:CreateGeneral()
	local permissionPanel = self:CreatePermissions()
	
	if (VoidFactions.Settings:IsDynamicFactions() or CAMI.PlayerHasAccess(LocalPlayer(), "VoidFactions_EditFactions")) then
		self.tabs:AddTab(string.upper(L"general"), generalPanel)
		self.assets = self.tabs:AddTab(string.upper(VoidFactions.Settings:IsStaticFactions() and L"permissions" or L"assets"), permissionPanel)
	end
	
	local buttonContainer = self:Add("Panel")
	buttonContainer:Dock(BOTTOM)
	buttonContainer:SSetTall(100)
	buttonContainer:SDockPadding(80,30,80,30)

	local saveButton = buttonContainer:Add("VoidUI.Button")
	saveButton:Dock(LEFT)
	saveButton:SSetWide(230)
	saveButton:SetText(L"save")
	saveButton:SetColor(VoidUI.Colors.Green, VoidUI.Colors.Background)

	saveButton.DoClick = function ()

		local name, tag, maxMembers, canInvite, canKick, canPromote, canDemote, manageFaction, canPurchasePerks, minLevel, jobs, canWithdrawMoney, canDepositMoney, canWithdrawItems, canDepositItems, autoPromoteLevel, promoteDefault = self:GetValues()
		local b = VoidFactions.Rank:CreateRank(self.faction, name, nil, tag, maxMembers, canInvite, canPromote, canDemote, canPurchasePerks, canKick, manageFaction, minLevel, jobs, canWithdrawMoney, canDepositMoney, canWithdrawItems, canDepositItems, autoPromoteLevel, promoteDefault)
		if (b) then
			self:Remove()
		end
	end

	self.buttonContainer = buttonContainer

	self.generalPanel = generalPanel
	self.permissionPanel = permissionPanel
	self.saveButton = saveButton

end

function PANEL:GetValues()

	local generalPanel = self.generalPanel
	local permissionPanel = self.permissionPanel

	local name = generalPanel.name.entry:GetValue()
	local tag = generalPanel.tag and generalPanel.tag.entry:GetValue()

	local minLevel = nil 
	local maxMembers = nil
	if (VoidFactions.Settings:IsStaticFactions()) then
		maxMembers = generalPanel.maxMembers.entry:GetValue() != "" and generalPanel.maxMembers.entry:GetInt() or 0
		minLevel = generalPanel.minLevel.entry:GetValue() != "" and generalPanel.minLevel.entry:GetInt() or 0
	end

	permissionPanel = VoidFactions.Settings:IsStaticFactions() and permissionPanel or generalPanel

	local canInvite = permissionPanel.canInvite.value
	local canKick = permissionPanel.canKick:GetSelectedID()
	local canPromote = permissionPanel.canPromote:GetSelectedID()
	local canDemote = permissionPanel.canDemote and permissionPanel.canDemote:GetSelectedID() or 1
	local manageFaction = permissionPanel.manageFaction.value

	permissionPanel = self.permissionPanel

	local canPurchasePerks = permissionPanel.canPurchasePerks and permissionPanel.canPurchasePerks.value or false

	local canWithdrawMoney = permissionPanel.canWithdrawMoney and permissionPanel.canWithdrawMoney.value or false
	local canDepositMoney = permissionPanel.canDepositMoney and permissionPanel.canDepositMoney.value or false

	local canWithdrawItems = permissionPanel.canWithdrawItems and permissionPanel.canWithdrawItems.value or false
	local canDepositItems = permissionPanel.canDepositItems and permissionPanel.canDepositItems.value or false

	local jobs = generalPanel.jobs and generalPanel.jobs.value or {}

	local autoPromoteLevel = generalPanel.autoPromoteLevel and (generalPanel.autoPromoteLevel.entry:GetValue() != "" and generalPanel.autoPromoteLevel.entry:GetInt()) or 0
	local promoteDefault = permissionPanel.promoteDefaultRanks and permissionPanel.promoteDefaultRanks.value or {}

	return name, tag, maxMembers, canInvite, canKick, canPromote, canDemote, manageFaction, canPurchasePerks, minLevel, jobs, canWithdrawMoney, canDepositMoney, canWithdrawItems, canDepositItems, autoPromoteLevel, promoteDefault
end


function PANEL:SetFaction(faction)
	self.faction = faction
end


function PANEL:CreateGeneral()
	local panel = self.tabs:Add("VoidUI.PanelContent")
	panel:Dock(FILL)

	local container = panel:Add("Panel")
	container:Dock(FILL)
	container:SDockMargin(30, 20, 30, 20)

	local grid = container:Add("VoidUI.ElementGrid")
	grid:Dock(FILL)

	panel.name = grid:AddElement(L"name", "VoidUI.TextInput")
	

	if (VoidFactions.Settings:IsStaticFactions()) then

		panel.tag = grid:AddElement(L"rankTag", "VoidUI.TextInput")
		panel.maxMembers = grid:AddElement(L"maxMembers", "VoidUI.TextInput")
		panel.maxMembers:SetNumeric(true)

		panel.minLevel = grid:AddElement(L"minimumLevel", "VoidUI.TextInput")
		panel.minLevel:SetNumeric(true)

		panel.jobs = grid:AddElement(L"jobs", "VoidUI.SelectorButton")
		
		panel.jobs.text = L"clickToAdd"
		panel.jobs.DoClick = function ()
			local selector = vgui.Create("VoidUI.ItemSelect")
			selector:SetParent(self)
			selector:SetMultipleChoice(true)

			if (panel.jobs.multiSelection) then
				selector.choices = panel.jobs.multiSelection
			end

			local jobTbl = {}

			for id, job in pairs(RPExtraTeams or {}) do
				jobTbl[job.team] = job.name
			end

			selector:InitItems(jobTbl, function (tbl, selTbl)
				panel.jobs:Select(tbl, selTbl)
			end)
		end

		panel.autoPromoteLevel = grid:AddElement(L"autoPromote" .. " " .. L"level", "VoidUI.TextInput")
		panel.autoPromoteLevel:SetNumeric(true)
	else

		grid:Skip()

		-- Some permissions go here
		panel.canInvite = grid:AddElement(L"inviteMembers", "VoidUI.Dropdown")
		panel.canInvite:SetupChoice(L"yes", L"no")

		panel.canKick = grid:AddElement(L"kickMembers", "VoidUI.Dropdown")
		panel.canKick:AddChoice(L"no")
		panel.canKick:AddChoice(L"yes")
		panel.canKick:ChooseOptionID(1)

		panel.canPromote = grid:AddElement(L"setRanks", "VoidUI.Dropdown")
		panel.canPromote:AddChoice(L"no")
		panel.canPromote:AddChoice(L"yes")
		panel.canPromote:ChooseOptionID(1)

		panel.manageFaction = grid:AddElement(L"manageFaction", "VoidUI.Dropdown")
		panel.manageFaction:SetupChoice(L"yes", L"no")
	end

	return panel
end

function PANEL:CreatePermissions()
	local panel = self.tabs:Add("VoidUI.PanelContent")
	panel:Dock(FILL)

	local container = panel:Add("Panel")
	container:Dock(FILL)
	container:SDockMargin(30, 20, 30, 20)

	local grid = container:Add("VoidUI.ElementGrid")
	grid:Dock(FILL)

	if (VoidFactions.Settings:IsStaticFactions()) then
		panel.canInvite = grid:AddElement(L"inviteMembers", "VoidUI.Dropdown")
		panel.canInvite:SetupChoice(L"yes", L"no")

		panel.canKick = grid:AddElement(L"kickMembers", "VoidUI.Dropdown")
		panel.canKick:AddChoice(L"no")
		panel.canKick:AddChoice(L"onlyFactionMembers")
		panel.canKick:AddChoice(L"factionAndSubfactions")
		panel.canKick:ChooseOptionID(1)
		
		panel.canPromote = grid:AddElement(L"promoteMembers", "VoidUI.Dropdown")
		panel.canPromote:AddChoice(L"no")
		panel.canPromote:AddChoice(L"onlyFactionMembers")
		panel.canPromote:AddChoice(L"factionAndSubfactions")
		panel.canPromote:ChooseOptionID(1)

		panel.canDemote = grid:AddElement(L"demoteMembers", "VoidUI.Dropdown")
		panel.canDemote:AddChoice(L"no")
		panel.canDemote:AddChoice(L"onlyFactionMembers")
		panel.canDemote:AddChoice(L"factionAndSubfactions")
		panel.canDemote:ChooseOptionID(1)

		panel.manageFaction = grid:AddElement(L"manageFaction", "VoidUI.Dropdown")
		panel.manageFaction:SetupChoice(L"yes", L"no")
		panel.manageFaction:GetParent():SetVisible(false)
		
		if (VoidFactions.Config.UpgradesEnabled) then
			panel.canPurchasePerks = grid:AddElement(L"purchaseUpgrades", "VoidUI.Dropdown")
			panel.canPurchasePerks:SetupChoice(L"yes", L"no")
		end

		if (VoidFactions.Config.DepositEnabled) then
			panel.canWithdrawMoney = grid:AddElement(L"canWithdrawMoney", "VoidUI.Dropdown")
			panel.canWithdrawMoney:SetupChoice(L"yes", L"no")

			panel.canDepositMoney = grid:AddElement(L"canDepositMoney", "VoidUI.Dropdown")
			panel.canDepositMoney:SetupChoice(L"yes", L"no")

			panel.canWithdrawItems = grid:AddElement(L"canWithdrawItems", "VoidUI.Dropdown")
			panel.canWithdrawItems:SetupChoice(L"yes", L"no")

			panel.canDepositItems = grid:AddElement(L"canDepositItems", "VoidUI.Dropdown")
			panel.canDepositItems:SetupChoice(L"yes", L"no")
		end

		panel.promoteDefaultRanks = grid:AddElement(L"promoteDefaultRanks", "VoidUI.SelectorButton")

		panel.promoteDefaultRanks.text = L"clickToAdd"
		panel.promoteDefaultRanks.DoClick = function ()
			local selector = vgui.Create("VoidUI.ItemSelect")
			selector:SetParent(self)
			selector:SetMultipleChoice(true)

			if (panel.promoteDefaultRanks.multiSelection) then
				selector.choices = panel.promoteDefaultRanks.multiSelection
			end

			local factionsTbl = {}
			for id, faction in pairs(VoidFactions.LoadedFactions) do
				local defaultRank = faction:GetLowestRank()
				if (!defaultRank) then continue end
				if (self.editedRank and self.editedRank.id == defaultRank.id) then continue end

				local rankTag = defaultRank.tag != "" and defaultRank.tag or defaultRank.name

				factionsTbl[faction.id] = faction.name .. " - " .. rankTag
			end

			selector:InitItems(factionsTbl, function (tbl, selTbl)
				panel.promoteDefaultRanks:Select(tbl, selTbl)
			end)
		end

		
	else
		panel.canPurchasePerks = grid:AddElement(L"purchaseUpgrades", "VoidUI.Dropdown")
		panel.canPurchasePerks:SetupChoice(L"yes", L"no")

		grid:Skip()

		panel.canWithdrawMoney = grid:AddElement(L"canWithdrawMoney", "VoidUI.Dropdown")
		panel.canWithdrawMoney:SetupChoice(L"yes", L"no")

		panel.canDepositMoney = grid:AddElement(L"canDepositMoney", "VoidUI.Dropdown")
		panel.canDepositMoney:SetupChoice(L"yes", L"no")

		panel.canWithdrawItems = grid:AddElement(L"canWithdrawItems", "VoidUI.Dropdown")
		panel.canWithdrawItems:SetupChoice(L"yes", L"no")

		panel.canDepositItems = grid:AddElement(L"canDepositItems", "VoidUI.Dropdown")
		panel.canDepositItems:SetupChoice(L"yes", L"no")
	end

	return panel
end

function PANEL:CreateMembers(rank)

	local this = self

	local panel = self.tabs:Add("VoidUI.PanelContent")
	panel:Dock(FILL)

	local container = panel:Add("Panel")
	container:Dock(FILL)
	container:MarginSides(45)
	container:MarginTop(20)
	container:SDockPadding(24, 5, 24, 0)
	container.Paint = function (self, w, h)
		draw.RoundedBox(8, 0, 0, w, h, VoidUI.Colors.Primary)
	end

	local header = container:Add("Panel")
	header:Dock(TOP)
	header:SSetTall(40)
	header.Paint = function (self, w, h)
		draw.SimpleText(string.upper(L"name"), "VoidUI.B24", 0, h/2, VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	local searchInput = header:Add("VoidUI.TextInput")
	searchInput:Dock(RIGHT)
	searchInput:SSetWide(170)
	searchInput:MarginTops(5)
	searchInput.entry:SetPlaceholderText(L"searchByName")
	searchInput.entry:SetFont("VoidUI.R20")

	function searchInput.entry:OnValueChange(val)
		this.performSearch(val)
	end

	self.searchInput = searchInput

	local memberPanel = container:Add("VoidUI.RowPanel")
	memberPanel:Dock(FILL)

	local addMember = container:Add("VoidUI.Button")
	addMember:Dock(BOTTOM)
	addMember:MarginSides(190)
	addMember:MarginTops(12)
	addMember:SSetTall(32)
	addMember.rounding = 16
	addMember.thickness = 1
	addMember:SetColor(VoidUI.Colors.Blue)
	addMember:SetText(L"addMember")
	addMember:SetFont("VoidUI.R20")

	local canInvite = true
	if (rank.faction:GetMaxMembers() != 0 and #rank.faction.members + 1 > rank.faction:GetMaxMembers()) then canInvite = false end
	if (VoidFactions.Settings:IsStaticFactions()) then
		if (rank.maxMembers != 0 and #rank:GetMembers() + 1 > rank.maxMembers) then canInvite = false end
	end

	addMember:SetEnabled(canInvite)

	addMember.DoClick = function ()
		local selector = vgui.Create("VoidUI.ItemSelect")
		selector:SetParent(self)

		local rankMembers = rank:GetMembers()
		local membersTbl = {}
		for k, v in ipairs(rankMembers) do
			if (IsValid(v.ply)) then
				membersTbl[v.sid] = v
			end
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
				VoidFactions.Member:SetFaction(rank.faction, rank, ply)
			end
		end)
	end


	self.performSearch = function (str)

		memberPanel:Clear()

		if (self.editedRank) then
			rank = self.editedRank
		end

		local members = rank:GetMembers()
		for _, member in ipairs(members) do

			local rankPanel = nil

			local memberName = nickSteamids[member.sid] or member.name
			if (!memberName) then
				steamworks.RequestPlayerInfo(member.sid, function (name)
				    nickSteamids[member.sid] = name
				    memberName = name

					if (!string.find(memberName, str)) then
						timer.Simple(0, function ()
							rankPanel:Remove()
						end)
					end

				end)
			else
				if (!string.find(memberName, str)) then continue end
			end

			rankPanel = memberPanel:Add("Panel")
			rankPanel:SetText("")
			rankPanel.Paint = function (self, w, h)
				draw.SimpleText(memberName or L"loading", "VoidUI.R24", 5, h/2-sc(10), VoidUI.Colors.Gray)

				surface.SetDrawColor(VoidUI.Colors.Background)
				surface.DrawLine(0, h-1, w, h-1)
			end
			rankPanel:SDockPadding(9,9,9,9)


			local kickButton = rankPanel:Add("VoidUI.Button")
			kickButton:Dock(RIGHT)
			kickButton:SetCompact(true)
			kickButton:SetText(L"kick")
			kickButton:SSetWide(70)
			kickButton:SetColor(VoidUI.Colors.Red)

			kickButton:SetEnabled(!rank.faction.isDefaultFaction)

			kickButton.DoClick = function ()
				local popup = vgui.Create("VoidUI.Popup")
				popup:SetText(L"kickMember", L("kickMemberPrompt", {["name"] = memberName, ["faction"] = member.faction.name}))
				popup:SetDanger()
				popup:Continue(L"kick", function ()
					-- Kick the member
					VoidFactions.Member:KickMember(member, memberName)
					self:Remove()
				end)
				popup:Cancel(L"cancel")
			end



			memberPanel:AddRow(rankPanel, 40)
		end

		if (#members == 0) then
			memberPanel.Paint = function (self, w, h)
				draw.SimpleText(L"thereAreNoMembers", "VoidUI.R36", w/2, h/2-5, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		else
			memberPanel.Paint = nil
		end
	end
	

	self.performSearch("")
	

	return panel
end

function PANEL:EditMode(rank)

	self.editedRank = rank

	self:SetTitle(L("editRank", rank.name))


	if (VoidFactions.Settings:IsDynamicFactions() and rank:IsTopRank()) then
		self.assets:SetVisible(false)

		local panel = self.generalPanel

		panel.canInvite:GetParent():SetVisible(false)
		panel.canKick:GetParent():SetVisible(false)
		panel.canPromote:GetParent():SetVisible(false)
		panel.manageFaction:GetParent():SetVisible(false)
	end

	local deleteButton = self.buttonContainer:Add("VoidUI.Button")
	deleteButton:Dock(RIGHT)
	deleteButton:SSetWide(230)
	deleteButton:SetText(L"delete")
	deleteButton:SetColor(VoidUI.Colors.Red, VoidUI.Colors.Background)

	if (rank.faction and rank:IsTopRank() and VoidFactions.Settings:IsDynamicFactions()) then
		deleteButton:SetEnabled(false)
	end

	deleteButton.DoClick = function ()
		-- Open a popup
		local popup = vgui.Create("VoidUI.Popup")
		popup:SetText(L"deleteRank", L("deleteRankPrompt", rank.name))
		popup:SetDanger()
		popup:Continue(L"delete", function ()
			-- Delete the faction
			VoidFactions.Rank:DeleteRank(rank)
			self:Remove()
		end)
		popup:Cancel(L"cancel")
	end

	local panel = self.generalPanel

	if (panel.jobs and #rank.jobs > 0) then
		local tbl = {}
		local tbl1 = {}
		for k, v in pairs(rank.jobs or {}) do
			local job = RPExtraTeams[v]
			tbl[job.team] = job.name
			tbl1[#tbl1 + 1] = job.name
		end
		
		panel.jobs.multiSelection = tbl
		panel.jobs:Select(table.GetKeys(tbl), tbl1)
	end

	panel.name.entry:SetValue(rank.name)
	if (VoidFactions.Settings:IsStaticFactions()) then
		panel.tag.entry:SetValue(rank.tag or "")
		panel.maxMembers.entry:SetValue(rank.maxMembers)
		panel.minLevel.entry:SetValue(rank.minLevel)
		panel.autoPromoteLevel.entry:SetValue(rank.autoPromoteLevel)
	end

	panel = VoidFactions.Settings:IsStaticFactions() and self.permissionPanel or self.generalPanel

	panel.canInvite:ChooseOptionID(rank.canInvite and 1 or 2)
	panel.canKick:ChooseOptionID(rank.kickMembers)

	panel.canPromote:ChooseOptionID(rank.canPromote)
	if (VoidFactions.Settings:IsStaticFactions()) then
		panel.canDemote:ChooseOptionID(rank.canDemote)
	end

	panel.manageFaction:ChooseOptionID(rank.manageFaction and 1 or 2)

	panel = self.permissionPanel

	if (VoidFactions.Settings:IsDynamicFactions()) then
		panel.canPurchasePerks:ChooseOptionID(rank.canPurchasePerks and 1 or 2)

		panel.canWithdrawMoney:ChooseOptionID(rank.canWithdrawMoney and 1 or 2)
		panel.canDepositMoney:ChooseOptionID(rank.canDepositMoney and 1 or 2)

		panel.canWithdrawItems:ChooseOptionID(rank.canWithdrawItems and 1 or 2)
		panel.canDepositItems:ChooseOptionID(rank.canDepositItems and 1 or 2)
	end

	if (VoidFactions.Settings:IsStaticFactions() and VoidFactions.Config.UpgradesEnabled) then
		panel.canPurchasePerks:ChooseOptionID(rank.canPurchasePerks and 1 or 2)
	end

	if (VoidFactions.Settings:IsStaticFactions() and VoidFactions.Config.DepositEnabled) then
		panel.canWithdrawMoney:ChooseOptionID(rank.canWithdrawMoney and 1 or 2)
		panel.canDepositMoney:ChooseOptionID(rank.canDepositMoney and 1 or 2)

		panel.canWithdrawItems:ChooseOptionID(rank.canWithdrawItems and 1 or 2)
		panel.canDepositItems:ChooseOptionID(rank.canDepositItems and 1 or 2)
	end

	local membersPanel = nil
	if (VoidFactions.Settings.IsStaticFactions() and rank.faction) then
		panel.promoteDefaultRanks.editFaction = rank.faction

		if (rank.promoteDefault and table.Count(rank.promoteDefault) > 0) then
			local tbl = {}
			local tbl1 = {}
			for k, v in pairs(rank.promoteDefault or {}) do
				local defaultRank = v:GetLowestRank()
				if (!defaultRank) then continue end

				local rankTag = defaultRank.tag != "" and defaultRank.tag or defaultRank.name
				tbl[v.id] = v.name .. " - " .. rankTag
				tbl1[#tbl1 + 1] = v.name .. " - " .. rankTag
			end
			
			panel.promoteDefaultRanks.multiSelection = tbl
			panel.promoteDefaultRanks:Select(table.GetKeys(tbl), tbl1)
		end

		membersPanel = self:CreateMembers(rank)
		self.tabs:AddTab(string.upper(L"members"), membersPanel)
	end


	self.saveButton.DoClick = function ()
		local name, tag, maxMembers, canInvite, canKick, canPromote, canDemote, manageFaction, canPurchasePerks, minLevel, jobs, canWithdrawMoney, canDepositMoney, canWithdrawItems, canDepositItems, autoPromoteLevel, promoteDefault = self:GetValues()

		local b = VoidFactions.Rank:UpdateRank(rank, name, nil, tag, maxMembers, canInvite, canPromote, canDemote, canPurchasePerks, canKick, manageFaction, minLevel, jobs, canWithdrawMoney, canDepositMoney, canWithdrawItems, canDepositItems, autoPromoteLevel, promoteDefault)
		if (b) then
			self:Remove()
		end
	end


end

vgui.Register("VoidFactions.UI.RankCreate", PANEL, "VoidUI.ModalFrame")
