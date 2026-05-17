local sc = VoidUI.Scale
local L = VoidFactions.Lang.GetPhrase

local PANEL = {}

function PANEL:Init()
	self:SSetSize(360, 150)

	self:SetTitle("")
	self:ShowCloseButton(false)

	local buttonPanel = self:Add("Panel")
	buttonPanel:Dock(BOTTOM)
	buttonPanel:MarginSides(40)
	buttonPanel:MarginBottom(12)
	buttonPanel:SSetTall(30)

	local accept = buttonPanel:Add("VoidUI.Button")
	accept:Dock(LEFT)
	accept:SSetWide(115)
	accept:SetCompact()
	accept:SetColor(VoidUI.Colors.Green, VoidUI.Colors.Background)
	accept:SetText(L"accept")

	accept.DoClick = function ()
		net.Start("VoidFactions.Invites.Respond")
			net.WriteBool(true)
		net.SendToServer()
		self:Remove()
	end

	local deny = buttonPanel:Add("VoidUI.Button")
	deny:Dock(RIGHT)
	deny:SSetWide(115)
	deny:SetCompact()
	deny:SetColor(VoidUI.Colors.Red, VoidUI.Colors.Background)
	deny:SetText(L"deny")

	deny.DoClick = function ()
		net.Start("VoidFactions.Invites.Respond")
			net.WriteBool(false)
		net.SendToServer()
		self:Remove()
	end
end

function PANEL:SetInfo(name, id)
	self.name = name
	self.id = id
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(VoidUI.Colors.Background)
	surface.DrawRect(0, 0, w, h)

	local navHeight = sc(35)

	surface.SetDrawColor(VoidUI.Colors.Primary)
	surface.DrawRect(0, 0, w, navHeight)

	-- 00000000000000000

	draw.SimpleText(string.upper(L"factionInvite"), "VoidUI.R18", sc(10), navHeight/2, VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	if (self.name) then
		draw.SimpleText(L"invitedTo", "VoidUI.R24", w/2, sc(55), VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(string.upper(self.name), "VoidUI.B32", w/2, sc(80), VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

end

vgui.Register("VoidFactions.UI.InvitePopup", PANEL, "DFrame")