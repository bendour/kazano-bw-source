local AVATAR = {}

AccessorFunc(AVATAR, "_vertices", "Vertices", FORCE_NUMBER)

function AVATAR:Init()
	self:SetVertices(360)

	self.Avatar = vgui.Create("AvatarImage", self)
	self.Avatar:SetPaintedManually(true)
end

function AVATAR:SetPlayer(ply, size)
	self.Avatar:SetPlayer(ply, size)
end

function AVATAR:SetSteamID(steamid64, size)
	self.Avatar:SetSteamID(steamid64, size)
end

function AVATAR:PerformLayout(w,h)
	local H = self:GetTall()

	self.Avatar:SetPos(0, H - h)
	self.Avatar:SetSize(self:GetWide(), h)
end

function AVATAR:GetAvatarPanel()
	return self.Avatar
end

function AVATAR:Paint(w,h)
	BaseWars:DrawStencil(function()
		BaseWars:DrawRoundedBox(BaseWars.ScreenScale * 8, 0, 0, w, h, color_white)
	end, function()
		self.Avatar:PaintManual()
	end)
end

vgui.Register("BaseWars.Avatar", AVATAR, "EditablePanel")