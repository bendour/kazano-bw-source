local PANEL = {}

AccessorFunc(PANEL, "m_id", "ID")

XeninUI:CreateFont("Coinflip.Games.Row.Name", 24)
XeninUI:CreateFont("Coinflip.Games.Row.Bet", 18)

function PANEL:Init()
	self.background = XeninUI.Theme.Navbar

	self.Avatar = self:Add("XeninUI.Avatar")
	self.Avatar:SetVertices(90)

	self.Name = self:Add("DLabel")
	self.Name:SetFont("Coinflip.Games.Row.Name")
	self.Name:SetTextColor(Color(220, 220, 220))

	self.Money = self:Add("DLabel")
	self.Money:SetFont("Coinflip.Games.Row.Name")
  self.Money:SetContentAlignment(6)

	self.Status = self:Add("DLabel")
	self.Status:SetFont("Coinflip.Games.Row.Bet")
  self.Status:SetTextColor(Color(175, 175, 175))
end

function PANEL:SetInfo(tbl)
	self.Avatar.avatar:SetSteamID(tbl.opponent, 128)
  if (player.GetBySteamID64(tbl.opponent)) then
    self.Name:SetText(player.GetBySteamID64(tbl.opponent):Nick())
    self.Name:SizeToContents()
  else
    steamworks.RequestPlayerInfo(tbl.opponent, function(name)
      self.Name:SetText(name)
      self.Name:SizeToContents()
    end)
  end
  if (tbl.currency == "NULL") then tbl.currency = Coinflip:GetCurrencyIfNil() end
  local curr = Coinflip:GetCurrency(tbl.currency)
  local money = curr:Format(tbl.money)
  if (tbl.winner == LocalPlayer():SteamID64()) then
    money = "+" .. money
  else
    money = "-" .. money
  end
	self.Money:SetText(money)
	self.Money:SizeToContentsY()
  self.Money:SizeToContentsX(2)

  self.Status:SetText(tbl.winner == LocalPlayer():SteamID64() and 
    Coinflip.i18n:get("ui.history.won", nil, "WON" )or
    Coinflip.i18n:get("ui.history.lost", nil, "LOST")
  )
  local col = tbl.winner == LocalPlayer():SteamID64() and XeninUI.Theme.Green or XeninUI.Theme.Red
  self.Money:SetTextColor(col)
  self.Status:SetTextColor(col)
  self.Status:SizeToContentsX(2)
end

function PANEL:Paint(w, h)
	draw.RoundedBox(6, 0, 0, w, h, self.background)
end

function PANEL:PerformLayout(w, h)
	self.Avatar:SetPos(8, 8)
	self.Avatar:SetSize(h - 16, h - 16)

	self.Name:SetPos(self.Avatar.x + self.Avatar:GetWide() + 12,
		self.Avatar.y + 2)
	self.Status:SetPos(self.Name.x,
		self.Name.y + self.Name:GetTall() - 2)
  self.Money:SetTall(h)
  self.Money:AlignRight(20)
end

vgui.Register("Coinflip.History.Row", PANEL)