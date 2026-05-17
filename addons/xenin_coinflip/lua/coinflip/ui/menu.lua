local PANEL = {}

function PANEL:Init()
  Coinflip.Frame = self
  
	self.sidebar = self:Add("XeninUI.SidebarV2")
	self.sidebar:Dock(LEFT)
	self.sidebar:SetBody(self)
  self.sidebar:CreatePanel(Coinflip.i18n:get("ui.tabs.standalone.flips", nil, "Flips"), nil, "Coinflip.Games", "C3MyKJE")
  self.sidebar:CreatePanel(Coinflip.i18n:get("ui.tabs.standalone.history", nil, "History"), nil, "Coinflip.History", "rKPSnOg")
  --self.sidebar:CreatePanel(Coinflip.i18n:get("ui.tabs.standalone.stats", nil, "Stats"), nil, "Coinflip.Stats")
  self.sidebar:SetActive(1)
end

function PANEL:PerformLayout(w, h)
  self.BaseClass.PerformLayout(self, w, h)

  local sw = 0
  for i, v in ipairs(self.sidebar.Sidebar) do
    surface.SetFont("XeninUI.SidebarV2.Name")
    local nameTw = surface.GetTextSize(v.Name or "")
    surface.SetFont("XeninUI.SidebarV2.Desc")
    local descTw = surface.GetTextSize(v.Desc or "")

    local tw = math.max(nameTw, descTw) + 8
    if (v.Icon) then
      tw = tw + 68
    end

    sw = math.max(sw, tw)
  end

  self.sidebar:SetWide(math.max(140, sw))
end
vgui.Register("Coinflip.Frame", PANEL, "XeninUI.Frame")

local PANEL = {}

function PANEL:Init()
  self.topNavbar = vgui.Create("Panel", self)
  self.topNavbar:Dock(TOP)

	self.navbar = vgui.Create("XeninUI.Navbar", self.topNavbar)
	self.navbar:Dock(FILL)
	self.navbar:SetBody(self)
  self.navbar:AddTab(Coinflip.i18n:get("ui.tabs.f4.flips", nil, "FLIPS"), "Coinflip.Games")
  self.navbar:AddTab(Coinflip.i18n:get("ui.tabs.f4.history", nil, "HISTORY"), "Coinflip.History")
  --self.navbar:AddTab(Coinflip.i18n:get("ui.tabs.f4.stats", nil, "STATS"), "Coinflip.Stats")
  self.navbar:SetActive(Coinflip.i18n:get("ui.tabs.f4.flips", nil, "FLIPS"))
end

function PANEL:PerformLayout(w, h)
  self.topNavbar:SetTall(56)
end
vgui.Register("Coinflip.Frame.F4", PANEL)
