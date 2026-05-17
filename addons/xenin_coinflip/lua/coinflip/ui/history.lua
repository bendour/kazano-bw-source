local PANEL = {}

function PANEL:Init()
	self.Title = self:Add("DLabel")
	self.Title:SetTextInset(0, 2)
	self.Title:SetFont("Coinflip.Games.Title")
	self.Title:SetTextColor(Color(220, 220, 220))

	self.Scroll = self:Add("XeninUI.Scrollpanel.Wyvern")
	self.Scroll:Dock(FILL)
	self.Scroll:DockMargin(16, 60, 16, 16)
end

function PANEL:Refresh()
  self.Rows = {}
  self.Title:SetText("")
  self.Loading = true

  net.Start("Coinflip.RequestHistory")
  net.SendToServer()

  hook.Add("Coinflip.RequestHistory", self, function(self, result)
    if (!IsValid(self)) then return end

    self.HasLoaded = true
    self.Loading = false
    self:Populate(result)
  end)

  hook.Add("Coinflip.Join", self, function(self, id, winner, time)
    timer.Simple(time + 1, function()
      if (!IsValid(self)) then return end

      self.HasLoaded = false
    end)
  end)

  hook.Add("Coinflip.PlayerJoined", self, function(self, id, challenger, winner, time)
    timer.Simple(time + 1, function()
      if (!IsValid(self)) then return end

      self.HasLoaded = false
    end)
  end)
end

function PANEL:Populate(tbl)
	for i, v in pairs(self.Scroll:GetChildren()[1]:GetChildren()) do
		v:Remove()
		self.Scroll:GetChildren()[1]:GetChildren()[i] = nil
	end

  local amt = #tbl
  self.Title:SetText(Coinflip.i18n:get("ui.history.title", { flips = amt }, "Last :flips: coinflips"))
  self.Title:SizeToContents()

	for i, v in ipairs(tbl) do
		local panel = self.Scroll:Add("Coinflip.History.Row")
		self.Rows[#self.Rows + 1] = panel
		panel:Dock(TOP)
		panel:DockMargin(0, 0, 8, 8)
		panel:SetTall(64)
		panel:SetID(i)
		panel:SetInfo(v)
	end

	self:InvalidateLayout()
end

function PANEL:OnSwitchedTo()
  if (self.HasLoaded) then return end

  self:Refresh()
end

function PANEL:Paint(w, h)
  if (self.Loading) then
    local x = w / 2
    local y = h / 2
    local size = 150

    XeninUI:DrawLoadingCircle(x, y, size)
  end
end

function PANEL:PerformLayout(w, h)
	self.Title:SetPos(16, 12)
	self.Title:SizeToContents()
end

vgui.Register("Coinflip.History", PANEL, "XeninUI.Panel")

net.Receive("Coinflip.RequestHistory", function(len)
  local result = net.ReadTable()
  
  hook.Run("Coinflip.RequestHistory", result)
end)