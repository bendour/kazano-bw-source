local PANEL = {}

XeninUI:CreateFont("Coinflip.Games.Create.Title", 28)
XeninUI:CreateFont("Coinflip.Games.Create.Option", 25)
XeninUI:CreateFont("Coinflip.Games.Create.Slider", 18)

local matCanAfford = Material("xenin/tick.png", "smooth")
local matCantAfford = Material("xenin/closebutton.png", "smooth")

function PANEL:Init()
	self:SetAlpha(0)
	self:AlphaTo(255, 0.15)

	self:SetSize(ScrW(), ScrH())
	self:SetBackgroundWidth(508)
	local height = 268
	if (!Coinflip.Config.DisableCreationAnnouncement) then height = height + 44 end
	if (!Coinflip.Config.DisableWinAnnouncement) then height = height + 44 end
	if (istable(Coinflip.Config.Currency)) then height = height + 44 end
	self:SetBackgroundHeight(height)
	self:SetTitle(Coinflip.i18n:get("ui.flips.create.title", nil, "Create a coinflip"))
	self:MakePopup()

	self.Panel = self.background:Add("XeninUI.Panel")
	self.Panel:Dock(FILL)
	self.Panel.PerformLayout = function(pnl, w, h)
		local x = 16
		local y = 16

		self.Avatar:SetPos(x, y)
		self.Avatar:SetSize(80, 80)

		self.Text:SetPos(x + self.Avatar:GetWide() + 10, y + 1)
		self.Text:SizeToContents()

		self.Textentry:SetPos(self.Text.x, self.Text.y + self.Text:GetTall() + 5)
		self.Textentry:SetTall(36)
		self.Textentry:SetWide(w - x - self.Avatar:GetWide() - 10 - x)

		y = y + self.Avatar:GetTall() + 16

		for i, v in pairs(self.options) do
			v:SetPos(x, y)
			v:SetSize(w - (x * 2), 36)

			y = y + v:GetTall() + 8
		end
	end

	self.Avatar = self.Panel:Add("XeninUI.Avatar")
	self.Avatar:SetVertices(90)
	self.Avatar:SetPlayer(LocalPlayer(), 128)

	self.Text = self.Panel:Add("DLabel")
	self.Text:SetText(Coinflip.i18n:get("ui.flips.create.howMuch", nil, "How much would you like to bet?"))
	self.Text:SetFont("Coinflip.Games.Create.Title")
	self.Text:SetTextColor(Color(220, 220, 220))

	self.Textentry = self.Panel:Add("XeninUI.TextEntry")
	self.Textentry:SetPlaceholder(Coinflip:GetCurrency():Format(10000))
	self.Textentry.textentry:SetUpdateOnType(true)
	self.Textentry.textentry:SetNumeric(true)
	self.Textentry.textentry.OnValueChange = function(pnl, text)
		local num = tonumber(text)
		if (!num) then self.Textentry.Summary.icon = nil return end
		local curr = Coinflip:GetCurrency(self.Currency)
		local canAfford = curr:CanAfford(LocalPlayer(), num)
		if (num < Coinflip.Config.MinBet) then canAfford = false end
		if (num > Coinflip.Config.MaxBet and Coinflip.Config.MaxBet != 0) then canAfford = false end

		self.Textentry.Summary.icon = canAfford and matCanAfford or matCantAfford
		self.Textentry.Summary.color = canAfford and XeninUI.Theme.Green or XeninUI.Theme.Red
	end

	self.Textentry.Summary = self.Textentry:Add("Panel")
	self.Textentry.Summary:Dock(RIGHT)
	self.Textentry.Summary:DockMargin(0, 0, 0, 0)
	self.Textentry.Summary:SetWide(36)
	self.Textentry.Summary.Paint = function(pnl, w, h)
		if (pnl.icon) then
			surface.SetMaterial(pnl.icon)
			surface.SetDrawColor(pnl.color)
			surface.DrawTexturedRect(6, 6, h - 12, h - 12)
		end
	end

	self.options = {}

	if (istable(Coinflip.Config.Currency)) then
		self:CreateDropdown("currency", Coinflip.i18n:get("ui.flips.create.currency", nil, "Currency"), Coinflip:GetCurrencies()[1])
	end
	if (!Coinflip.Config.DisableCreationAnnouncement) then
		self:CreateCheckbox("announceCreation", Coinflip.i18n:get("ui.flips.create.announceCreation", nil, "Announce creation"), true)
	end
	if (!Coinflip.Config.DisableWinAnnouncement) then
		self:CreateCheckbox("announceWinner", Coinflip.i18n:get("ui.flips.create.announceWinner", nil, "Announce winner"), true)
	end
	self:CreateSlider("timeLimit", Coinflip.i18n:get("ui.flips.create.timeLimit.msg", nil, "Time limit"), 5)

	self.Create = self.Panel:Add("XeninUI.ButtonV2")
	self.Create:Dock(BOTTOM)
	self.Create:DockMargin(16, 16, 16, 16)
	self.Create:SetText(Coinflip.i18n:get("ui.flips.create.create", nil, "Create"))
	self.Create:SetFont("Coinflip.Games.Button")
	self.Create:SizeToContentsY(24)
	self.Create:SetTextColor(Color(222, 222, 222))
	self.Create:SetRoundness(6)
	self.Create:SetSolidColor(XeninUI.Theme.Primary)
	self.Create:SetHoverColor(Color(65, 65, 65))
	local oldPaint = self.Create.Paint
	self.Create.Paint = function(pnl, w, h)
		oldPaint(pnl, w, h)

		if (pnl.Loading) then
			local size = h / 2
			local x = w / 2
			local y = h / 2

			XeninUI:DrawLoadingCircle(x, y, size)
		end
	end
	self.Create.DoClick = function(pnl)
		local money = tonumber(self.Textentry:GetText())
		if (!money) then return end
		money = math.abs(money)
		local curr = Coinflip:GetCurrency(self.Currency)
		if (!curr:CanAfford(LocalPlayer(), money)) then return end
		if (money < Coinflip.Config.MinBet) then return end
		if (money > Coinflip.Config.MaxBet and Coinflip.Config.MaxBet != 0) then return end

		pnl:SetText("")
		pnl.Loading = true

		local tbl = {}
		for i, v in pairs(self.options) do
			if (v.slider) then 
				tbl[i] = math.floor((v.slider:GetMax() * v.slider.fraction)) + v.slider:GetMin()

				continue
			elseif (v.button) then
				tbl[i] = v.button.Currency

				continue
			end

			tbl[i] = v.checkbox:GetState()
		end

		net.Start("Coinflip.Create")
			net.WriteUInt(money, 32)
			net.WriteBool(tobool(tbl.announceCreation))
			net.WriteBool(tobool(tbl.announceWinner))
			net.WriteUInt(tbl.timeLimit, 5)
			net.WriteString(tbl.currency or Coinflip.Config.Currency)
		net.SendToServer()

		hook.Add("Coinflip.Created", "CoinflipMenu", function(id)
			if (!IsValid(self)) then return end

			self:AlphaTo(0, 0.15, nil, function()
				self:Remove()
			end)
		end)
	end

	hook.Add("Coinflip.Create.Error", self, function(self, err)
		self.Panel:Notification(err, XeninUI.Theme.Red)
		self.Create.Loading = false
		self.Create:SetText(Coinflip.i18n:get("ui.flips.create.create", nil, "Create"))
	end)
end

function PANEL:CreateDropdown(id, text, defaultState)
	self.options[id] = self.Panel:Add("Panel")
	local panel = self.options[id]
	panel.text = panel:Add("DLabel")
	panel.text:Dock(LEFT)
	panel.text:SetText(text)
	panel.text:SetFont("Coinflip.Games.Create.Option")
	panel.text:SetTextColor(Color(200, 200, 200))
	panel.text:SizeToContents()

	local currency = Coinflip:GetCurrencies()[1]
	local realCurrency = currency
	for i, v in pairs(Coinflip.Currencies) do
		if (i != currency) then continue end
		
		realCurrency = i
		currency = v.Name or i
	end
	panel.button = panel:Add("XeninUI.ButtonV2")
	panel.button:Dock(RIGHT)
	panel.button:SetWide(110)
	panel.button:SetText(currency)
	panel.button.Currency = realCurrency
	panel.button:SetSolidColor(XeninUI.Theme.Primary)
	panel.button:SetRoundness(6)
	panel.button:SizeToContentsX(32)
	panel.button.SortChanged = function(pnl, text, currency)
    pnl:SetText(text)
		pnl:SizeToContentsX(32)
		pnl.Currency = currency
		self.Currency = currency

		self.Textentry:SetPlaceholder(Coinflip:GetCurrency(currency):Format(10000))

    self:InvalidateLayout()
	end
	panel.button.DoClick = function(pnl)
		local func = function(btn)
			local currency = btn:GetText()
			for i, v in pairs(Coinflip.Currencies) do
				if (v.Name != currency) then continue end
				
				currency = i
			end
		  pnl:SortChanged(btn:GetText(), currency)
		end
		local hoverColor = Color(75, 75, 75)

		local panel = XeninUI:DropdownPopup(pnl:LocalToScreen(-12, -12 + pnl:GetTall()))
		panel:SetBackgroundColor(XeninUI.Theme.Navbar)
		panel:SetTextColor(Color(185, 185, 185))
    for i, v in ipairs(Coinflip:GetCurrencies()) do
			local currency = Coinflip.Currencies[v]
			if (!currency) then continue end

      panel:AddChoice(currency.Name or v, func, nil, hoverColor)
    end
  end
end

function PANEL:CreateCheckbox(id, text, defaultState)
	self.options[id] = self.Panel:Add("Panel")
	local panel = self.options[id]
	panel.text = panel:Add("DLabel")
	panel.text:Dock(LEFT)
	panel.text:SetText(text)
	panel.text:SetFont("Coinflip.Games.Create.Option")
	panel.text:SetTextColor(Color(200, 200, 200))
	panel.text:SizeToContents()

	panel.checkbox = panel:Add("XeninUI.Checkbox")
	panel.checkbox:Dock(RIGHT)
	panel.checkbox:SetWide(110)
	panel.checkbox:SetStateText(
		Coinflip.i18n:get("ui.flips.create.no", nil, "NO"), 
		Coinflip.i18n:get("ui.flips.create.yes", nil, "YES")
	)
	panel.checkbox:SetState(defaultState, true)
end

function PANEL:CreateSlider(id, text, time)
	self.options[id] = self.Panel:Add("Panel")
	local panel = self.options[id]
	panel.text = panel:Add("DLabel")
	panel.text:Dock(LEFT)
	panel.text:SetText(text)
	panel.text:SetFont("Coinflip.Games.Create.Option")
	panel.text:SetTextColor(Color(200, 200, 200))
	panel.text:SizeToContentsY()
	panel.text:SizeToContentsX(16)

	panel.sliderText = panel:Add("DLabel")
	panel.sliderText:Dock(RIGHT)
	panel.sliderText:SetText(Coinflip.i18n:get("ui.flips.create.timeLimit.time", { number = time }, ":number: min"))
	panel.sliderText:SetFont("Coinflip.Games.Create.Slider")
	panel.sliderText:SetTextColor(Color(200, 200, 200))
	panel.sliderText:SizeToContentsY()
	panel.sliderText:SetContentAlignment(6)
	panel.sliderText:SetWide(58)

	panel.slider = panel:Add("XeninUI.Slider")
	panel.slider:Dock(RIGHT)
	panel.slider:DockMargin(0, 0, 16, 0)
	panel.slider:SetWide(110)
	panel.slider:SetMax(25)
	panel.slider:SetMin(5)
	panel.slider.OnValueChanged = function(pnl, frac)
		local time = pnl:GetMin() + math.floor(frac * pnl:GetMax())

		panel.sliderText:SetText(Coinflip.i18n:get("ui.flips.create.timeLimit.time", { number = time }, ":number: min"))
	end
end

vgui.Register("Coinflip.Games.Create", PANEL, "XeninUI.Popup")