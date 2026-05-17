local sc = VoidUI.Scale
local L = VoidFactions.Lang.GetPhrase

local PANEL = {}

function PANEL:Init()
	local this = self
	self:SetOrigSize(660, 506)
	local ply = LocalPlayer()

	self.isLoading = true
	

	self.selectedFaction = nil

	local namePanel = self:Add("Panel")
	namePanel:Dock(TOP)
	namePanel.Paint = function (self, w, h)
		if (!this.selectedFaction) then return end
		draw.RoundedBox(8, 0, 0, w, h, VoidUI.Colors.Primary)

		draw.SimpleText(string.upper(this.selectedFaction.name), "VoidUI.B28", w/2, h/2-1, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local manageButton = namePanel:Add("VoidUI.Button")
	manageButton:Dock(RIGHT)
	manageButton:SetText(L"manage")
	manageButton:MarginTops(10)
	manageButton:MarginRight(10)
	manageButton:SSetWide(80)
	manageButton:SetCompact()
	manageButton:SetColor(VoidFactions.UI.Accent)
	manageButton.DoClick = function ()
		if (!self.selectedFaction) then return end

		local frame = vgui.Create("VoidFactions.UI.FactionCreate")
		frame:EditMode(self.selectedFaction)
	end

	local ply = LocalPlayer()
	if (!CAMI.PlayerHasAccess(ply, "VoidFactions_EditFactions")) then
		manageButton:SetEnabled(false)
	end

	local rankPanel = self:Add("Panel")
	rankPanel:Dock(FILL)
	rankPanel.Paint = function (self, w, h)
		if (!this.selectedFaction) then return end
		draw.RoundedBox(8, 0, 0, w, h, VoidUI.Colors.Primary)
	end

	local rankPanelContainer = rankPanel:Add("Panel")
	rankPanelContainer:Dock(FILL)
	rankPanelContainer.Paint = function (self, w, h)
		draw.SimpleText(L"rank", "VoidUI.B24", 0, 0, VoidUI.Colors.Gray)
		draw.SimpleText(L"members", "VoidUI.B24", w/2, 0, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER)
		draw.SimpleText(L"actions", "VoidUI.B24", w-w*0.1, 0, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER)
	end

	local rankContent = rankPanelContainer:Add("Panel")
	rankContent:Dock(FILL)

	rankContent.Paint = function (self, w, h)
		if (this.isLoading or (this.selectedFaction and table.Count(this.selectedFaction.ranks or {}) == 0 and !this.isTemplate) ) then
			local text = this.isLoading and L"loading" or L"noRanksAvailable"
			draw.SimpleText(text, "VoidUI.B40", w/2, h/2-h*0.05, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end


	local scrollContainer = rankContent:Add("VoidUI.ScrollPanel")
	scrollContainer:Dock(FILL)

	local rankRows = scrollContainer:Add("DListLayout")
	rankRows:Dock(TOP)

	function rankRows:OnModified()
		for k, v in pairs(this.rankPanels) do
			VoidFactions.Rank:UpdateRankWeight(v.rank, v:GetZPos())
		end
	end

	rankRows:MakeDroppable("rankRowsOrder")

	local addButton = rankPanelContainer:Add("VoidUI.Button")
	addButton:Dock(BOTTOM)
	addButton:SetText(L"addRank")
	addButton:SetColor(VoidFactions.UI.Accent)
	addButton:SetFont("VoidUI.R22")
	addButton.DoClick = function ()
		local frame = vgui.Create("VoidFactions.UI.RankCreate")
		frame:SetFaction(self.isTemplate and 0 or self.selectedFaction)
	end

	if (!CAMI.PlayerHasAccess(ply, "VoidFactions_EditFactions")) then
		addButton:SetEnabled(false)
	end

	self.rankContent = rankContent
	self.scrollContainer = scrollContainer
	self.rankPanelContainer = rankPanelContainer
	self.addButton = addButton
	self.rankRows = rankRows
	self.rankPanel = rankPanel
	self.namePanel = namePanel
	self.manageButton = manageButton

	self.rankEditFrame = nil

	hook.Add("VoidFactions.Faction.DataUpdated", "VoidFactions.UI.FactionSettingsInfo.DataUpdate", function (faction)
		if (this.selectedFaction and this.selectedFaction.id == faction.id) then
			self:SetRanks(faction)
		end
	end)

	hook.Add("VoidFactions.Rank.RankTemplatesReceived", "VoidFactions.UI.FactionSettingsInfo.DataRankTempalteUpdate", function (ranks)
		self:SetRanks({ranks = ranks})
	end)
end

function PANEL:OnRemove()
	hook.Remove("VoidFactions.Faction.DataUpdated", "VoidFactions.UI.FactionSettingsInfo.DataUpdate")
end

function PANEL:SetRanks(faction)

	local ranks = faction.ranks
	local members = faction.members

	self.rankRows:Clear()

	local rankTbl = {}
	for k, member in ipairs(members or {}) do
		if (!member.rank) then
			VoidFactions.PrintError("Member SID " .. member.sid .. " does not have a rank!")
			continue
		end
		if (rankTbl[member.rank.id]) then
			rankTbl[member.rank.id] = rankTbl[member.rank.id] + 1
		else
			rankTbl[member.rank.id] = 1
		end
	end

	local rankRows = self.rankRows

	local root = self

	self.isLoading = false

	self.rankPanels = {}
	self.panelRanks = {}


	for id, rank in SortedPairsByMemberValue(ranks, "weight") do
		local memberCount = rankTbl[id] or 0

		local rankPanel = self.rankRows:Add("DButton")
		rankPanel:SetText("")
		rankPanel.Paint = function (self, w, h)
			draw.SimpleText(rank.name, "VoidUI.R22", 5, h/2-sc(10), VoidUI.Colors.Gray)

			draw.SimpleText(memberCount .. "/" .. rank.maxMembers, "VoidUI.R22", w/2, h/2-sc(10), VoidUI.Colors.Gray, TEXT_ALIGN_CENTER)

			surface.SetDrawColor(VoidUI.Colors.Background)
			surface.DrawLine(0, h-1, w, h-1)
		end

		local function duplicatePopup()
			local popup = vgui.Create("VoidUI.Popup")
			popup:SetText(L"duplicate", L("duplicate_confirm", { faction = rank.name }))

			popup:Continue(L"duplicate", function (val)
				VoidFactions.Rank:CreateRank(faction, rank.name .. " (copy)", rank.weight, rank.tag, rank.maxMembers, rank.canInvite, rank.canPromote, rank.canDemote, rank.canPurchasePerks, rank.kickMembers, rank.manageFaction, rank.minLevel, rank.jobs, rank.canWithdrawMoney, rank.canDepositMoney, rank.canWithdrawItems, rank.canDepositItems, rank.autoPromoteLevel, {})
			end)
			
			popup:Cancel(L"cancel")
		end

		local origPress = rankPanel.OnMousePressed
		rankPanel.OnMousePressed = function (s, keycode)
			origPress(s, keycode)

			if (keycode == MOUSE_RIGHT) then
				local ctxMenu = VoidUI:CreateDropdownPopup()

				local duplicate = ctxMenu:AddOption(L"duplicate", function ()
					duplicatePopup()
				end)

				ctxMenu.y = ctxMenu.y - 15
				ctxMenu.x = ctxMenu.x + 10
			end
		end

		rankPanel.rank = rank
		rankPanel:SetCursor("sizeall")


		local actionPanel = rankPanel:Add("Panel")
		actionPanel:Dock(RIGHT)

		local manageButton = actionPanel:Add("VoidUI.Button")
		manageButton:Dock(TOP)
		manageButton:SetText(L"manage")
		manageButton:SetCompact()
		manageButton:SetColor(VoidFactions.UI.Accent)
		manageButton.DoClick = function ()
			local frame = vgui.Create("VoidFactions.UI.RankCreate")
			frame:SetFaction(self.selectedFaction)
			frame:EditMode(rank)

			self.rankEditFrame = frame
		end
		
		
		rankPanel.actionPanel = actionPanel
		rankPanel.actionPanel.manage = manageButton

		self.rankPanels[#self.rankPanels + 1] = rankPanel

		self.rankRows:Add(rankPanel)
		
	end

	self.scrollContainer:SetVisible(true)

	self:InvalidateLayout(true)
	self.scrollContainer:InvalidateLayout(true)
	self.scrollContainer:InvalidateChildren(true)
	self.rankRows:InvalidateLayout(true)
	self.rankRows:SizeToChildren(false, true)
end

function PANEL:SetFaction(faction, isTemplate)
	if (!isTemplate) then
		faction = VoidFactions.LoadedFactions[faction.id]
	end

	self.selectedFaction = faction
	self.isLoading = true

	self.scrollContainer:SetVisible(false)

	self.isTemplate = isTemplate or false
	if (isTemplate) then
		self.manageButton:SetVisible(false)
	else
		self.manageButton:SetVisible(true)
	end

	if (faction.ranks and faction.members) then
		self:SetRanks(faction)
	end

	if ((isTemplate and VoidFactions.RankTemplates)) then
		self:SetRanks({ranks = VoidFactions.RankTemplates}, "template")
	else
		-- Request ranks from server
		VoidFactions.Faction:RequestFactionRanks(faction.id)
	end
end

function PANEL:PerformLayout(w, h)

	self.addButton:MarginSides(180, self)
	self.addButton:SSetTall(40, self)

	self.namePanel:SSetTall(45, self)
	self.rankPanel:MarginTop(10, self)

	self.rankContent:MarginTop(30, self)
	self.rankContent:MarginBottom(10, self)

	self.rankPanel:SDockPadding(35, 10, 35, 20, self)

	if (self.rankPanels) then
		for k, panel in ipairs(self.rankPanels) do
			panel:SSetTall(40, self)

			panel.actionPanel:SSetWide(165, self)
			panel.actionPanel:MarginTop(10, self)
			panel.actionPanel:MarginBottom(8, self)
			panel.actionPanel.manage:MarginLeft(65, self)
			panel.actionPanel.manage:MarginRight(15, self)
		end
	end
end

vgui.Register("VoidFactions.UI.FactionSettingsInfo", PANEL, "Panel")
