local PANEL = {}

function PANEL:Init()
	local factionView = self:Add("VoidFactions.UI.BoardFactions")
	factionView:Dock(FILL)
	factionView:SetVisible(true)

	local memberView = self:Add("VoidFactions.UI.BoardMembers")
	memberView:Dock(FILL)
	memberView:SetVisible(false)

	self.factionView = factionView
	self.memberView = memberView
end

function PANEL:GoBack()
	self.factionView:SetVisible(true)
	self.memberView:SetVisible(false)
end

function PANEL:SelectFaction(faction)
	self.factionView:SetVisible(false)
	self.memberView:SetVisible(true)

	self.memberView:ViewFaction(faction)
end

vgui.Register("VoidFactions.UI.BoardMain", PANEL, "VoidUI.PanelContent")