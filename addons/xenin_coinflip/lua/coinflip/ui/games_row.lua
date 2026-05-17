local PANEL = {}

AccessorFunc(PANEL, "m_id", "ID")

XeninUI:CreateFont("Coinflip.Games.Row.Name", 24)
XeninUI:CreateFont("Coinflip.Games.Row.Bet", 18)

function PANEL:Init()
	self.background = XeninUI.Theme.Navbar

	self.Avatar = self:Add("XeninUI.Avatar")
	self.Avatar:SetVertices(90)

	self.Join = self:Add("DButton")
	self.Join:SetText(Coinflip.i18n:get("ui.flips.row.join", nil, "Join"))
	self.Join:SetFont("Coinflip.Games.Button")
	self.Join:SizeToContentsY(18)
	self.Join:SizeToContentsX(48)
	self.Join.background = XeninUI.Theme.Background
	self.Join.textcolor = Color(220, 220, 220)
	self.Join.Paint = function(pnl, w, h)
		pnl:SetTextColor(pnl.textcolor)

		draw.RoundedBox(h / 2, 0, 0, w, h, pnl.background)

		if (pnl.drawLoading) then
			local x = w / 2
			local y = h / 2
			local size = h / 2

			XeninUI:DrawLoadingCircle(x, y, size, color_white)
		end
	end
	self.Join.OnCursorEntered = function(pnl)
		local tbl = Coinflip.Games[self:GetID()]
		if (!tbl) then return end
		local curr = Coinflip:GetCurrency(tbl.currency)
		local col = curr:CanAfford(LocalPlayer(), tbl.bet) and XeninUI.Theme.Green or XeninUI.Theme.Red

		pnl:LerpColor("background", col)
		pnl:LerpColor("textcolor", XeninUI.Theme.Background)
	end
	self.Join.OnCursorExited = function(pnl)
		pnl:LerpColor("background", XeninUI.Theme.Background)
		pnl:LerpColor("textcolor", Color(220, 220, 220))
	end
	self.Join.DoClick = function(pnl)
		if (pnl.drawLoading) then return end

		local tbl = Coinflip.Games[self:GetID()]
		if (!tbl) then return end
		local curr = Coinflip:GetCurrency(tbl.currency)
		local canAfford = curr:CanAfford(LocalPlayer(), tbl.bet)
		if (!canAfford) then
			XeninUI:Notify(Coinflip.i18n:get("ui.flips.row.cantAfford", {
				number = Coinflip:GetCurrency(tbl.currency):Format(tbl.bet)
			}, "You can't afford to enter this coinflip! You need :number:"), 
			NOTIFY_ERROR, 5, XeninUI.Theme.Red)

			return
		end

		net.Start("Coinflip.Join")
			net.WriteUInt(self:GetID(), 24)
		net.SendToServer()

		pnl:SetText("")
		pnl.drawLoading = true
	end

	self.Name = self:Add("DLabel")
	self.Name:SetFont("Coinflip.Games.Row.Name")
	self.Name:SetTextColor(Color(220, 220, 220))

	self.Bet = self:Add("DLabel")
	self.Bet:SetFont("Coinflip.Games.Row.Bet")
	self.Bet:SetTextColor(Color(175, 175, 175))
end

function PANEL:SetInfo(tbl)
	self.Avatar:SetPlayer(tbl.author, 128)
	self.Name:SetText(tbl.author:Nick())
	self.Name:SizeToContents()
	local curr = Coinflip:GetCurrency(tbl.currency)
	self.Bet:SetText(curr:Format(tbl.bet))
	self.Bet:SizeToContents()

	if (tbl.author == LocalPlayer()) then
		self.Join:SetText(Coinflip.i18n:get("ui.flips.row.delete", nil, "Delete"))
		self.Join:SizeToContentsX(48)
		self.Join.OnCursorEntered = function(pnl)
			pnl:LerpColor("background", XeninUI.Theme.Red)
			pnl:LerpColor("textcolor", XeninUI.Theme.Background)
		end
		self.Join.OnCursorExited = function(pnl)
			pnl:LerpColor("background", XeninUI.Theme.Background)
			pnl:LerpColor("textcolor", Color(220, 220, 220))
		end
		self.Join.DoClick = function(pnl)
			net.Start("Coinflip.Delete")
				net.WriteUInt(self:GetID(), 24)
			net.SendToServer()
			
			Coinflip.Games[self:GetID()] = nil
			hook.Run("Coinflip.Removed", self:GetID())
		end
	end
end

function PANEL:Paint(w, h)
	draw.RoundedBox(6, 0, 0, w, h, self.background)
end

function PANEL:PerformLayout(w, h)
	self.Join.y = h / 2 - self.Join:GetTall() / 2
	self.Join:AlignRight(self.Join.y)

	self.Avatar:SetPos(8, 8)
	self.Avatar:SetSize(h - 16, h - 16)

	self.Name:SetPos(self.Avatar.x + self.Avatar:GetWide() + 12,
		self.Avatar.y + 2)
	self.Bet:SetPos(self.Name.x,
		self.Name.y + self.Name:GetTall() - 1)
end

vgui.Register("Coinflip.Games.Row", PANEL)