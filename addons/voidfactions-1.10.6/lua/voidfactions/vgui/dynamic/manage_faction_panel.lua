local L = VoidFactions.Lang.GetPhrase
local sc = VoidUI.Scale

local PANEL = {}

function PANEL:Init()
	self:SetOrigSize(1000, 600)
	local title = self:SetTitle(string.upper(L"manageFaction"))

	local member = VoidFactions.PlayerMember
	local faction = member.faction

	VoidFactions.Faction:RequestFactionRank()

	local hasPerms = member:Can("ManageFaction", faction)

	self.hasPerms = hasPerms

	self.rankPanels = {}

	self.shouldDrawGradient = true
	local this = self

	local backButton = title:Add("DButton")
	backButton:Dock(LEFT)
	backButton:SetText("")
	backButton.Paint = function (self, w, h)
		local color = self:IsHovered() and VoidUI.Colors.Green or VoidUI.Colors.Gray
		draw.SimpleText("<  " .. string.upper(L"back"), "VoidUI.R22", w/2, h/2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	backButton.DoClick = function ()
		self:GetParent():GoBack()
	end

	local editButton = title:Add("VoidUI.Button")
	editButton:Dock(RIGHT)
	editButton:SetText(L"edit")
	editButton:SetCompact()
	editButton:SetColor(VoidUI.Colors.Green)
	
	editButton.DoClick = function ()
		local frame = vgui.Create("VoidFactions.UI.FactionCreate")
		frame:EditMode(faction)

		self.rankEditFrame = frame
	end

	editButton:SetVisible(hasPerms)

	local container = self:Add("Panel")
	container:Dock(FILL)

	local factionInfo = container:Add("Panel")
	factionInfo:Dock(LEFT)

	local xpPanel = factionInfo:Add("Panel")

	local requiredXP = VoidFactions.XP:GetRequiredXP(faction.level)
	local fraction = faction.xp / requiredXP

	factionInfo.Paint = function (self, w, h)
		draw.RoundedBox(8, 0, 0, w, h, VoidUI.Colors.Primary)

		local logoSize = sc(150)
		local x = w/2 - logoSize/2
		local y = sc(10)

		VoidLib.FetchImage(faction.logo, function (mat)
			draw.RoundedBox(6, x, y, logoSize, logoSize, faction.color)

			surface.SetMaterial(mat)
			surface.SetDrawColor(VoidUI.Colors.White)
			surface.DrawTexturedRect(x+1, y+1, logoSize-2, logoSize-2)
		end)

		local textY = y + logoSize + sc(20)

		draw.SimpleText(faction.name, "VoidUI.R28", w/2, textY, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(string.upper(L"level") .. " " .. faction.level, "VoidUI.B20", xpPanel.x, xpPanel.y-2, VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
		draw.SimpleText(faction.xp .. " / " .. requiredXP .. " XP", "VoidUI.R20", xpPanel.x, xpPanel.y+sc(15)+2, VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end

	
	xpPanel:Dock(TOP)
	function xpPanel:Paint(w,h)
		requiredXP = VoidFactions.XP:GetRequiredXP(faction.level)
		fraction = faction.xp / requiredXP

		local x, y = self:LocalToScreen(0, 0)

		surface.SetMaterial(VoidUI.Icons.RoundedBox)
		surface.SetDrawColor(VoidUI.Colors.Background)
		surface.DrawTexturedRect(0, 0, w, h)

		if (this.shouldDrawGradient) then
			VoidUI.StencilMaskStart()
				surface.SetMaterial(VoidUI.Icons.RoundedBox)
				surface.SetDrawColor(VoidUI.Colors.White)
				surface.DrawTexturedRect(0, 0, w, h)
			VoidUI.StencilMaskApply()
				VoidUI.SimpleLinearGradient(x, y, w*fraction, h, VoidUI.Colors.Green, VoidUI.Colors.GreenGradientEnd, true)
			VoidUI.StencilMaskEnd()
		end
	end

	xpPanel:SetVisible(!VoidFactions.Config.DisableXP)

	local infoGrid = factionInfo:Add("VoidUI.Grid")
	infoGrid:Dock(BOTTOM)

	infoGrid:SetColumns(2)
	infoGrid:SetHorizontalMargin(10)
	infoGrid:SetVerticalMargin(10)
	
	local memberPanel = infoGrid:Add("Panel")
	memberPanel.Paint = function (self, w, h)
		draw.RoundedBox(6, 0, 0, w, h, VoidUI.Colors.BackgroundTransparent)

		draw.SimpleText(string.upper(L"members"), "VoidUI.R20", w/2, sc(10), VoidUI.Colors.Green, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText(#faction.members .. " / " .. faction:GetMaxMembers(), "VoidUI.R20", w/2, h-sc(10), VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	end
	infoGrid:AddCell(memberPanel)

	local levelPanel = infoGrid:Add("Panel")
	levelPanel.Paint = function (self, w, h)
		draw.RoundedBox(6, 0, 0, w, h, VoidUI.Colors.BackgroundTransparent)

		draw.SimpleText(string.upper(L"level"), "VoidUI.R20", w/2, sc(10), VoidUI.Colors.Green, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText(faction.level, "VoidUI.R20", w/2, h-sc(10), VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	end
	infoGrid:AddCell(levelPanel)

	local rankingPanel = infoGrid:Add("Panel")
	rankingPanel.Paint = function (self, w, h)
		draw.RoundedBox(6, 0, 0, w, h, VoidUI.Colors.BackgroundTransparent)

		draw.SimpleText(string.upper(L"ranking"), "VoidUI.R20", w/2, sc(10), VoidUI.Colors.Green, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		if (faction.factionRank) then
			local rankNum = faction.factionRank
			local trophyColor = (rankNum == 1 and VoidUI.Colors.Gold) or (rankNum == 2 and VoidUI.Colors.Silver) or (rankNum == 3 and VoidUI.Colors.Bronze) or VoidUI.Colors.Gray
			local trophyMat = (rankNum > 3 and VoidUI.Icons.TrophyHollow) or VoidUI.Icons.Trophy

			local trophySize = 63
			surface.SetMaterial(trophyMat)
			surface.SetDrawColor(trophyColor)
			surface.DrawTexturedRect(w/2 - trophySize/2, h/2 - trophySize/2+sc(10), trophySize, trophySize)

			local font = rankNum > 99 and "VoidUI.B18" or "VoidUI.B22"
			draw.SimpleText(rankNum .. ".", font, w/2, h/2, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
	infoGrid:AddCell(rankingPanel)

	local upgrText = string.upper(L"totalUpgrades")

	local wrappedUpgradeText = nil

	local upgrCount = table.Count(faction.upgrades or {})

	local upgradesPanel = infoGrid:Add("Panel")
	upgradesPanel.Paint = function (self, w, h)
		draw.RoundedBox(6, 0, 0, w, h, VoidUI.Colors.BackgroundTransparent)

		if (!wrappedUpgradeText) then
			wrappedUpgradeText = VoidUI.TextWrap(upgrText, "VoidUI.R20", w*0.9)
		end

		draw.DrawText(wrappedUpgradeText, "VoidUI.R20", w/2, sc(10), VoidUI.Colors.Green, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText(upgrCount, "VoidUI.R26", w/2, h-sc(30), VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	end
	infoGrid:AddCell(upgradesPanel)


	local rankPanel = container:Add("Panel")
	rankPanel:Dock(FILL)
	rankPanel.Paint = function (self, w, h)
		draw.RoundedBox(8, 0, 0, w, h, VoidUI.Colors.Primary)

		draw.SimpleText(L"rank", "VoidUI.B22", sc(30), sc(20), VoidUI.Colors.Gray, TEXT_ALIGN_LEFT)
	end

	local scrollContainer = rankPanel:Add("VoidUI.ScrollPanel")
	scrollContainer:Dock(FILL)

	local rankRows = scrollContainer:Add("DListLayout")
	rankRows:Dock(TOP)

	function rankRows:OnModified()
		for k, v in pairs(this.rankPanels) do
			VoidFactions.Rank:UpdateRankWeight(v.rank, v:GetZPos())
		end
	end

	rankRows:MakeDroppable("rankRowsOrder")
	

	local newRank = rankPanel:Add("VoidUI.Button")
	newRank:Dock(BOTTOM)
	newRank:SetMedium()
	newRank:SetText(L"addRank")

	newRank:SetVisible(hasPerms)

	newRank.DoClick = function ()
		local frame = vgui.Create("VoidFactions.UI.RankCreate")
		frame:SetFaction(faction)

		self.rankEditFrame = frame
	end
	

	self.backButton = backButton

	self.container = container
	self.factionInfo = factionInfo
	self.infoGrid = infoGrid

	self.memberPanel = memberPanel
	self.levelPanel = levelPanel
	self.rankingPanel = rankingPanel
	self.upgradesPanel = upgradesPanel

	self.rankPanel = rankPanel

	self.rankRows = rankRows
	self.scrollContainer = scrollContainer

	self.editButton = editButton
	self.newRank = newRank

	self.xpPanel = xpPanel

	self:LoadRanks() 

	hook.Add("VoidFactions.Faction.DataUpdated", "VoidFactions.UI.ManageFactionPanel.UpdateData", function ()
		self:LoadRanks()
	end)
end

function PANEL:Think()
	self.shouldDrawGradient = !IsValid(self.rankEditFrame)
end

function PANEL:OnRemove()
	hook.Remove("VoidFactions.Faction.DataUpdated", "VoidFactions.UI.ManageFactionPanel.UpdateData")
end


function PANEL:LoadRanks()
	local member = VoidFactions.PlayerMember
	local faction = member.faction 

	local hasPerms = self.hasPerms

	local ranks = faction.ranks

	local rankRows = self.rankRows
	rankRows:Clear()
	
	local root = self

	self.rankPanels = {}
	self.panelRanks = {}

	for id, rank in SortedPairsByMemberValue(ranks, "weight") do

		local rankPanel = self.rankRows:Add("DPanel")
		rankPanel:SetText("")
		rankPanel.Paint = function (self, w, h)
			draw.SimpleText(rank.name, "VoidUI.R22", 5, h/2-sc(10), VoidUI.Colors.Gray)

			surface.SetDrawColor(VoidUI.Colors.Background)
			surface.DrawLine(0, h-1, w, h-1)
		end

		rankPanel.rank = rank

		local cannotMove = rank.weight == 1 or !member:Can("ManageFaction")
		if (cannotMove) then
			rankPanel:SetCursor("no")
		else
			rankPanel:SetCursor("sizeall")
		end

		local actionPanel = rankPanel:Add("Panel")
		actionPanel:Dock(RIGHT)


		local manageButton = actionPanel:Add("VoidUI.Button")
		manageButton:Dock(TOP)
		manageButton:SetText(L"manage")
		manageButton:SetCompact()
		manageButton:SetColor(VoidUI.Colors.Green)
		manageButton.DoClick = function ()
			local frame = vgui.Create("VoidFactions.UI.RankCreate")
			frame:SetFaction(self.selectedFaction)
			frame:EditMode(rank)

			self.rankEditFrame = frame
		end

		manageButton:SetVisible(hasPerms)
		
		
		rankPanel.actionPanel = actionPanel
		rankPanel.actionPanel.manage = manageButton

		self.rankPanels[#self.rankPanels + 1] = rankPanel

		self.rankRows:Add(rankPanel)

		-- Dont allow dragging if cant move
		if (cannotMove) then
			rankPanel.m_DragSlot = nil
		end
	end

	self:InvalidateLayout(true)
	self.scrollContainer:InvalidateLayout(true)
	self.scrollContainer:InvalidateChildren(true)
	self.rankRows:InvalidateLayout(true)
	self.rankRows:SizeToChildren(false, true)
end

function PANEL:PerformLayout(w, h)
	self.backButton:SSetWide(70, self)
	self.backButton:MarginLeft(10, self)
	self.backButton:MarginTops(5, self)

	self.container:MarginSides(45, self)
	self.container:MarginTop(10, self)
	self.container:MarginBottom(35, self)

	self.factionInfo:SSetWide(300, self)
	self.factionInfo:SDockPadding(25, 25, 25, 5, self)

	self.infoGrid:SSetTall(190, self)
	

	self.memberPanel:SSetTall(60, self)
	self.levelPanel:SSetTall(60, self)
	self.rankingPanel:SSetTall(115, self)
	self.upgradesPanel:SSetTall(115, self)

	self.rankPanel:MarginLeft(10, self)
	self.rankPanel:SDockPadding(30, 30, 30, 20, self)

	self.scrollContainer:MarginTop(20, self)

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

	self.editButton:SSetWide(50, self)
	self.editButton:MarginTops(7, self)
	self.editButton:MarginRight(25, self)

	self.newRank:MarginSides(170, self)
	self.newRank:SSetTall(40, self)

	self.xpPanel:SSetTall(15, self)
	self.xpPanel:MarginTop(205, self)

	self.infoGrid:CalculateRows()
end

vgui.Register("VoidFactions.UI.DynamicManageFactionsPanel", PANEL, "VoidUI.PanelContent")