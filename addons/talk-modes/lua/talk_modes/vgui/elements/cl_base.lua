local THEME = TalkModes.Client.ActiveTheme
local tblPages = {
    [1] = {
        strName = "General",
        strPanel = "TalkModes.GeneralSettings",
        strMat = Material("talkmodes/config.png")
    },
    [2] = {
        strName = "Modes",
        strPanel = "TalkModes.ModesSettings",
        strMat = Material("talkmodes/modes.png")
    },
    [3] = {
        strName = "Theme",
        strPanel = "TalkModes.ThemesSettings",
        strMat = Material("talkmodes/paint.png")
    }
}

local PANEL = {}
AccessorFunc(PANEL, "loaded_panel", "LoadedPanel")

function PANEL:Init()
    self:SetSize(ScrW()/2.5, ScrH()/2)
    self:Center()
    self:MakePopup()

    local intW, intH = self:GetWide(), self:GetTall()

    self.xBut = self:Add("DButton")
    self.xBut:SetSize(32, intH/12)
    self.xBut:SetText("✕")
    self.xBut:SetFont("TalkModes:Medium")
    self.xBut:SetPos(intW - 46, 0)
    self.xBut.Paint = nil
    self.xBut.Alpha = 120
    self.xBut.Think = function(self)
        self.Alpha = Lerp(FrameTime() * 8, self.Alpha, self:IsHovered() && 255 || 120)
        self:SetColor(Color(THEME["White"].r, THEME["White"].g, THEME["White"].b, self.Alpha))
    end
    self.xBut.DoClick = function()
        self:Close()
    end
    
    self.navbar = self:Add("TalkModes.Navbar")
    self.navbar:SetSize(intW/4)
    self.navbar:Dock(LEFT)
    self.navbar:DockMargin(0, intH/12, 0, 0)
    for _, v in ipairs(tblPages) do
        self.navbar:AddButton(v.strPanel, v.strMat, v.strName)
    end

    self.docker = self:Add("TalkModes.Docker")
    self.docker:Dock(FILL)
    self.docker:DockMargin(0, intH/12, 0, 0)
    self.docker:ChangePage("TalkModes.GeneralSettings")
end

function PANEL:Close()
    self:AlphaTo(0, 0.2, 0, function()
        self:Remove()
    end)
end

function PANEL:Paint(intW, intH)
    draw.RoundedBoxEx(8, 0, 0, intW, intH/12, THEME["Background"], true, true, false, false)
    draw.SimpleText("Talk Modes - Config", "TalkModes:Medium", 8, intH/12/2, THEME["White"], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end
vgui.Register("TalkModes.AdminMenu", PANEL, "EditablePanel")