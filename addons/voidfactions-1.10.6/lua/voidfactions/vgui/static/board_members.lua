local sc = VoidUI.Scale
local L = VoidFactions.Lang.GetPhrase

local PANEL = {}

function PANEL:Init()
	self:SetOrigSize(1000, 600)

	self.isEmpty = false

	local this = self

	local memberPanel = self:Add("Panel")
	memberPanel:Dock(FILL)
	memberPanel.Paint = function (self, w, h)
		draw.RoundedBox(8, 0, 0, w, h, VoidUI.Colors.Primary)
	end

	local memberPanelContainer = memberPanel:Add("Panel")
	memberPanelContainer:Dock(FILL)
	memberPanelContainer.Paint = function (self, w, h)
		draw.SimpleText(L"name", "VoidUI.B24", sc(70), sc(20), VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(L"rank", "VoidUI.B24", w/2, sc(20), VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText(L"lastSeen", "VoidUI.B24", w-w*0.18, sc(20), VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	
		if (this.isLoading) then
			draw.SimpleText(L"loading", "VoidUI.B42", w/2, h/2, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		if (this.isEmpty) then
			draw.SimpleText(L"nothingToShow", "VoidUI.B42", w/2, h/2, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end

	local memberContent = memberPanelContainer:Add("VoidUI.RowPanel")
    memberContent:Dock(FILL)

	self.memberPanel = memberPanel
	self.memberPanelContainer = memberPanelContainer
	self.memberContent = memberContent
end

function PANEL:ViewFaction(faction)
	-- Grab a new reference
	local faction = VoidFactions.LoadedFactions[faction.id]

	local titlePanel = self:SetTitle(string.upper(faction.name), true)

	if (titlePanel.backButton) then
		titlePanel.backButton:Remove()
	end
	
	local backButton = titlePanel:Add("DButton")
	backButton:Dock(LEFT)
	backButton:SetText("")
	backButton.Paint = function (self, w, h)
		local color = self:IsHovered() and VoidUI.Colors.Blue or VoidUI.Colors.Gray
		draw.SimpleText("<  " .. string.upper(L"back"), "VoidUI.R20", w/2, h/2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	backButton.DoClick = function ()
		self:GetParent():GoBack()
	end

	titlePanel.backButton = backButton
	self.backButton = backButton

	self:LoadMembers(faction)

	self:InvalidateLayout()

	hook.Add("VoidFactions.Faction.RanksMembersReceived", "VoidFactions.UI.BoardMembers.RanksReceived", function (faction)
		self:SetMembers(faction)
	end)
	
end

function PANEL:OnRemove()
	hook.Remove("VoidFactions.Faction.RanksMembersReceived", "VoidFactions.UI.BoardMembers.RanksReceived")
end

function PANEL:LoadMembers(faction)

	self.isLoading = true

	if (faction.ranks and faction.members) then
		self:SetMembers(faction)
	end

	VoidFactions.Faction:RequestFactionRanks(faction.id)
end

function PANEL:SetMembers(faction)

	self.memberContent:Clear()
	self.isEmpty = false
	self.isLoading = false

	local memberContent = self.memberContent

	if (#faction.members == 0) then
		self.isEmpty = true
	end

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

		local lastSeenString = facMember.lastSeen != 0 and L("ago", string.NiceTime(os.time() - facMember.lastSeen)) or L"never"

        local panel = memberContent:Add("Panel")
		panel.Paint = function (self, w, h)
			surface.SetDrawColor(isOnline and VoidUI.Colors.Green or VoidUI.Colors.Red)			
			VoidUI.DrawCircle(20, h/2, 7, 1)

			draw.SimpleText(playerNick or L"loading", "VoidUI.R22", sc(40), h/2-2, VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(facMember.rank.name, "VoidUI.R22", w/2, h/2-2, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(isOnline and L"now" or lastSeenString, "VoidUI.R22", w-w*0.16, h/2-2, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			draw.RoundedBox(0, 0, h-1, w, 1, VoidUI.Colors.Background)
		end

		memberContent:AddRow(panel, 45)
    end
end

function PANEL:PerformLayout(w, h)
	self:SDockPadding(30, 25, 30, 30, self)

	self.backButton:SSetWide(70, self)
	self.backButton:MarginLeft(10, self)
	self.backButton:MarginTops(5, self)

	self.memberPanel:MarginTop(20, self)
    self.memberPanelContainer:MarginBottom(20, self)
    self.memberContent:MarginTop(50, self)
	self.memberPanelContainer:SDockPadding(30, 0, 30, 0)
end

vgui.Register("VoidFactions.UI.BoardMembers", PANEL, "VoidUI.PanelContent")