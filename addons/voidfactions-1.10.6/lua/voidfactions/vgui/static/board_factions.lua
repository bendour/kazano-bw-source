local L = VoidFactions.Lang.GetPhrase
local sc = VoidUI.Scale

local PANEL = {}

function PANEL:Init()
	self:SetOrigSize(1000, 600)
	self:SetTitle(string.upper(L"factions"), true)

	self.container = self:Add("VoidUI.BackgroundPanel")
	self.container:Dock(FILL)

	self.container.Paint = function (self, w, h)
		draw.RoundedBox(12, 0, 0, w, h, VoidUI.Colors.Primary)

        draw.SimpleText(L"factionName", "VoidUI.B24", sc(20), sc(15), VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(L"members", "VoidUI.B24", w/2, sc(15), VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end

	self.board = self.container:Add("VoidUI.RowPanel")
	self.board:SetSpacing(6)
	self:LoadContent()
	
	hook.Add("VoidFactions.Faction.DataUpdated", "VoidFactions.UI.BoardFactions.DataUpdate", function ()
		self:LoadContent()
	end)

end

function PANEL:OnRemove()
	hook.Remove("VoidFactions.Faction.DataUpdated", "VoidFactions.UI.BoardFactions.DataUpdate")
end

function PANEL:LoadContent()

	self.board:Clear()

	local rootFactions = VoidFactions.Utils:BuildSubfactions(VoidFactions.LoadedFactions)

	for _, faction in pairs(rootFactions) do
		self:AddFaction(faction, true)
		for k, v in pairs(faction.subfactions or {}) do
			self:AddFaction(v, false, true)
			for _, p in pairs(v.subfactions or {}) do
				self:AddFaction(p, false, false, true)
			end
		end
	end

	if (table.Count(rootFactions) == 0) then
		self.board.Paint = function (self, w, h)
			draw.SimpleText(L"nothingToShow", "VoidUI.R48", w/2, h/2-20, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	else
		self.board.Paint = nil
	end
end

function PANEL:AddFaction(faction, isRoot, isFaction, isSubfaction)

	if (!faction.showBoard) then return end

	local textColor = VoidLib.DynamicTextColor(faction.color)

	local mat = nil 
	if (faction.logo and #faction.logo > 3) then
		VoidLib.FetchImage(faction.logo, function (_mat)
			if (!_mat) then return end
			mat = _mat
		end)
	end

	local panel = self.board:Add("Panel")
	panel.Paint = function (self, w, h)
		local width = (isRoot and w) or (isFaction and w * 0.97) or (isSubfaction and w * 0.93)
		local x = w - width
		draw.RoundedBox(6, x, 0, width, h, faction.color)
		if (isSubfaction) then
			draw.RoundedBox(6, x+1, 1, width-2, h-2, VoidUI.Colors.InputLight)
		end

		local memberCount = faction.memberCount or (faction.members and #faction.members)
		local maxMembers = faction.maxMembers == 0 and "∞" or faction.maxMembers

		local iconSize = sc(25)

		local nameX = mat and x + sc(12) + iconSize or x + sc(20)
		if (mat) then
			surface.SetMaterial(mat)
			surface.SetDrawColor(VoidUI.Colors.White)
			surface.DrawTexturedRect(x + sc(5), sc(5), iconSize, iconSize)
		end

		draw.SimpleText(faction.name, "VoidUI.R22", nameX, h/2, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText(memberCount .. "/" .. maxMembers, "VoidUI.R22", w/2, h/2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local viewDetails = panel:Add("VoidUI.Button")
	viewDetails:Dock(RIGHT)
	viewDetails:SSetWide(120)
	viewDetails:SetCompact()

	viewDetails:MarginTops(5)
	viewDetails:MarginRight(40)

	viewDetails:SetText(L"viewDetails")
	viewDetails:SetColor(VoidUI.Colors.Blue, VoidUI.Colors.InputLight)

	viewDetails.DoClick = function ()
		self:GetParent():SelectFaction(faction)
	end

	local staticCheck = VoidFactions.PlayerMember.faction and VoidFactions.Settings:IsStaticFactions() and (VoidFactions.PlayerMember.faction.id != faction.id)
	local dynamicCheck = VoidFactions.Settings:IsDynamicFactions() and !VoidFactions.PlayerMember.faction

	if (!staticCheck and !VoidFactions.PlayerMember.faction) then
		staticCheck = true
	end

	if (!faction.inviteRequired and (staticCheck or dynamicCheck)) then
		local join = panel:Add("VoidUI.Button")
		join:Dock(RIGHT)
		join:SSetWide(50)
		join:SetCompact()

		join:MarginTops(5)
		join:MarginRight(5)

		join:SetText(L"join")
		join:SetColor(VoidUI.Colors.Green, VoidUI.Colors.InputLight)

		local bCanJoin = VoidFactions.PlayerMember:CanJoin(faction)
		join:SetEnabled(bCanJoin)

		join.DoClick = function ()
			-- Reopen the menu (as soon as the net message is received, the menu reopens)
			VoidFactions.Menu.ReopenRequested = true

			VoidFactions.Member:JoinFaction(faction)
		end
	end

	self.board:AddRow(panel, sc(35))

	if (isFaction) then
		panel:MarginTop(3)
	end

	if (isRoot) then
		panel:MarginTop(12)
	end
end

function PANEL:PerformLayout(w, h)
	self:SDockPadding(30, 25, 30, 30, self)

	self.container:MarginTop(20, self)
	self.board:MarginTop(25, self)
end

vgui.Register("VoidFactions.UI.BoardFactions", PANEL, "VoidUI.PanelContent")
