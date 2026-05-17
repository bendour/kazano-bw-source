local PANEL = {}

XeninUI:CreateFont("Coinflip.Games.Flip.Name", 24)
XeninUI:CreateFont("Coinflip.Games.Flip.Wins", 18)
XeninUI:CreateFont("Coinflip.Games.Flip.Money", 45)

local matBlue = Material("xenin/coinflip/coin_blue.png", "smooth")
local matRed = Material("xenin/coinflip/coin_red.png", "smooth")

function PANEL:Init()
	self:SetSize(ScrW(), ScrH())
	self:SetTitle(Coinflip.i18n:get("ui.flips.game.countdown", { number = 4 }, "Coinflip - flipping in :number:"))
	self:SetBackgroundWidth(650)
	self:SetBackgroundHeight(332)
	self:MakePopup()
end

function PANEL:SetInfo(tbl)
	self.SpinSpeed = Coinflip.Config.StartSpeed
	self.CurrentTime = 0
	self.TimeToEnd = tbl.time

	local leftPlayer = tbl.author
	local rightPlayer = tbl.challenger
	local money = tbl.money
	self.tbl = tbl

	local countdown = 4
	timer.Create("Coinflip.Flipping", 1, countdown, function()
		if (!IsValid(self)) then return end

		countdown = countdown - 1

		if (countdown > 0) then
			self:SetTitle(Coinflip.i18n:get("ui.flips.game.countdown", { number = countdown }, "Coinflip - flipping in :number:"))
		else
			self:SetTitle(Coinflip.i18n:get("ui.flips.game.flipping", nil, "Coinflip - flipping"))
		
			self:Flip()
		end
	end)

	self.LeftAvatar = self.background:Add("XeninUI.Avatar")
	self.LeftAvatar:SetVertices(90)
	self.LeftAvatar:SetPlayer(leftPlayer, 128)

	self.LeftName = self.background:Add("DLabel")
	self.LeftName:SetFont("Coinflip.Games.Flip.Name")
	self.LeftName:SetTextColor(color_white)
	self.LeftName:SetContentAlignment(4)
	self.LeftName:SetText(leftPlayer:Nick())

	self.LeftWins = self.background:Add("DLabel")
	self.LeftWins:SetFont("Coinflip.Games.Flip.Wins")
	self.LeftWins:SetTextColor(Color(210, 210, 210))
	self.LeftWins:SetContentAlignment(4)
	self.LeftWins:SetText(Coinflip.i18n:get("ui.flips.game.blue", nil, "Blue"))

	self.RightAvatar = self.background:Add("XeninUI.Avatar")
	self.RightAvatar:SetVertices(90)
	self.RightAvatar:SetPlayer(rightPlayer, 128)

	self.RightName = self.background:Add("DLabel")
	self.RightName:SetFont("Coinflip.Games.Flip.Name")
	self.RightName:SetTextColor(color_white)
	self.RightName:SetContentAlignment(6)
	self.RightName:SetText(rightPlayer:Nick())

	self.RightWins = self.background:Add("DLabel")
	self.RightWins:SetFont("Coinflip.Games.Flip.Wins")
	self.RightWins:SetTextColor(Color(210, 210, 210))
	self.RightWins:SetContentAlignment(6)
	self.RightWins:SetText(Coinflip.i18n:get("ui.flips.game.red", nil, "Red"))

	self.Money = self.background:Add("DPanel")
	self.Money.Text = Coinflip:GetCurrency(tbl.currency):Format(money)
	self.Money.Paint = function(pnl, w, h)
		XeninUI:DrawShadowText(pnl.Text, "Coinflip.Games.Flip.Money", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, 125)
	end

	--self.Money:SetFont("Coinflip.Games.Flip.Money")
	--self.Money:SetText(DarkRP.formatMoney(money))
	--self.Money:SetTextColor(color_white)
	--self.Money:SetContentAlignment(5)
	--self.Money:SizeToContents()

	local oldPaint = self.background.Paint
	self.background.Sin = 1
	self.background.lastSin = 1
	self.background.Angle = 300
	self.background.Paint = function(pnl, w, actualH)
		oldPaint(pnl, w, actualH)

		local x = 16
		local y = 56 + self.LeftAvatar:GetTall() + 16

		local leftPoly = {
			{ x = 0, y = 40 },
			{ x = w * 0.55, y = 40 },
			{ x = w * 0.45, y = y },
			{ x = 0, y = y }
		}
		local rightPoly = {
			{ x = w, y = 40 },
			{ x = w, y = y },
			{ x = w * 0.45, y = y },
			{ x = w * 0.55, y = 40 }
		}
		-- 00000000000000000
		draw.NoTexture()
		surface.SetDrawColor(XeninUI.Theme.Accent)
		surface.DrawPoly(leftPoly)
		surface.SetDrawColor(XeninUI.Theme.Red)
		surface.DrawPoly(rightPoly)

		local size = 150
		local sin = (math.sin(pnl.Angle) + 1) / 2
		local sizeY = math.abs(Lerp(sin, -size, size))
		x = w / 2 - size / 2
		y = y + self.LeftAvatar:GetTall() + 16 + 4 + 16 - sizeY / 2

		local mat = sin < 0.5 and matBlue or matRed
		surface.SetDrawColor(color_white)
		surface.SetMaterial(mat)
		surface.DrawTexturedRect(x, y, size, sizeY)
	end
end

function PANEL:PerformLayout(w, h)
	self.BaseClass.PerformLayout(self, w, h)
	w = self.background:GetWide()
	h = self.background:GetTall()

	local x = 16
	local y = 56
	if (IsValid(self.LeftAvatar)) then
		self.LeftAvatar:SetPos(x, y)
		self.LeftAvatar:SetSize(64, 64)
		self.LeftName:SetPos(x + self.LeftAvatar:GetWide() + 8, y - draw.GetFontHeight(self.LeftWins:GetFont()) / 2)
		self.LeftName:SizeToContentsX()
		self.LeftName:SetTall(self.LeftAvatar:GetTall())
		self.LeftWins:SetPos(x + self.LeftAvatar:GetWide() + 8, y + draw.GetFontHeight(self.LeftWins:GetFont()) / 2)
		self.LeftWins:SizeToContentsX()
		self.LeftWins:SetTall(self.LeftAvatar:GetTall())
	end

	if (IsValid(self.RightAvatar)) then
		x = w - 64 - x

		surface.SetFont(self.RightName:GetFont())
		local nW = surface.GetTextSize(self.RightName:GetText())
		surface.SetFont(self.RightWins:GetFont())
		local wW = surface.GetTextSize(self.RightWins:GetText())

		self.RightAvatar:SetPos(x, y)
		self.RightAvatar:SetSize(64, 64)
		self.RightName:SizeToContentsX()
		self.RightName:SetPos(x - nW - 8, y - draw.GetFontHeight(self.LeftWins:GetFont()) / 2)
		self.RightName:SetTall(self.LeftAvatar:GetTall())
		self.RightWins:SetPos(x - wW - 8, y + draw.GetFontHeight(self.LeftWins:GetFont()) / 2)
		self.RightWins:SizeToContentsX()
		self.RightWins:SetTall(self.LeftAvatar:GetTall())
	end

	if (IsValid(self.Money)) then
		self.Money:SetPos(w / 2 - self.Money:GetWide() / 2, y)
		self.Money:SetTall(self.LeftAvatar:GetTall())
		surface.SetFont("Coinflip.Games.Flip.Money")
		local tw = surface.GetTextSize(self.Money.Text)
		self.Money:SetWide(tw + 2)
	end
end

function PANEL:Flip()
	hook.Add("Think", "Coinflip.Flip", function()
		if (IsValid(self)) then
			local spinSpeed = self.SpinSpeed
			self.background.Angle = self.background.Angle - (FrameTime() * spinSpeed)
		end
	end)

	timer.Create("Coinflip.Flipping.Rotate", 0.1, self.TimeToEnd * 10, function()
		if (!IsValid(self)) then return end

		self.CurrentTime = self.CurrentTime + 0.1
		self.SpinSpeed = Coinflip.Config.StartSpeed - ((self.CurrentTime / self.TimeToEnd) * 10)
	end)

	timer.Simple(self.TimeToEnd, function()
		hook.Remove("Think", "Coinflip.Flip")

		if (!IsValid(self)) then return end
		local winner = self.tbl.winner
		local rightPlayer = self.tbl.challenger
		local leftPlayer = self.tbl.author

		hook.Add("Think", "Coinflip.Flip", function()
			if (IsValid(self)) then
				self.background.Angle = self.background.Angle - (FrameTime() * self.SpinSpeed)

				local sin = (math.sin(self.background.Angle) + 1) / 2
				if (0.99 < sin and winner == rightPlayer) then
					hook.Remove("Think", "Coinflip.Flip")
				elseif (sin < 0.01 and winner == leftPlayer) then
					hook.Remove("Think", "Coinflip.Flip")
				end
			end
		end)
	end)
end
vgui.Register("Coinflip.Games.Flip", PANEL, "XeninUI.Popup")

