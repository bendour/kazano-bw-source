local THEME = TalkModes.Client.ActiveTheme

local PANEL = {}
AccessorFunc(PANEL, "page", "Page")
AccessorFunc(PANEL, "button_text", "ButtonText")
AccessorFunc(PANEL, "mat", "Mat")
AccessorFunc(PANEL, "active", "Active", FORCE_BOOL)

function PANEL:Init()
    self.base = self:GetParent():GetParent()
    self.nav = self:GetParent()
    self:Dock(TOP)
    self:DockMargin(0, 8, 0, 0)
    self:SetHeight(42)
    self:SetText("")
    self.intOffset = 0
    self.colActive = Color(255, 255, 255)
end

function PANEL:Paint(intW, intH)
    self.intOffset = Lerp(FrameTime() * 8, self.intOffset, (self:IsHovered() || self:GetActive()) && 12 || 0)
    self.colActive.r = Lerp(FrameTime() * 16, self.colActive.r, (self:IsHovered() || self:GetActive()) && THEME["Hover"].r || THEME["White"].r )
    self.colActive.g = Lerp(FrameTime() * 16, self.colActive.g, (self:IsHovered() || self:GetActive()) && THEME["Hover"].g || THEME["White"].g )
    self.colActive.b = Lerp(FrameTime() * 16, self.colActive.b, (self:IsHovered() || self:GetActive()) && THEME["Hover"].b || THEME["White"].b )
    
    surface.SetDrawColor(Color(self.colActive.r, self.colActive.g, self.colActive.b))
    surface.SetMaterial(self:GetMat())
    surface.DrawTexturedRect(self.intOffset + 18, (42-32)/2, 32, 32)
    draw.SimpleText(TalkModes.Languages:GetPhrase(self:GetButtonText()), "TalkModes:Medium", self.intOffset + 18 + 32 + 12, intH/2, THEME["White"], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

function PANEL:DoClick()
    if (self:GetActive() or self.base.docker.bChanging) then return end
    for _,btn in ipairs(self.nav.tblButtons) do
        btn:SetActive(false)
    end
    self:SetActive(true)
    self.base.docker:ChangePage(self:GetPage(), true)
end
vgui.Register("TalkModes.NavbarButton", PANEL, "DButton")

local PANEL = {}
function PANEL:Init()
    self.tblButtons = {}
end
function PANEL:Paint(intW, intH)
    draw.RoundedBoxEx(8, 0, 0, intW, intH, THEME["Background"], false, false, true, false)
end

function PANEL:AddButton(strPage, mMat, strText)
    self.btn = self:Add("TalkModes.NavbarButton")
    self.btn:SetPage(strPage)
    self.btn:SetMat(mMat)
    self.btn:SetButtonText(strText)

    self.tblButtons[#self.tblButtons + 1] = self.btn
    if (self.tblButtons[1] == self.btn) then
        self.btn:SetActive(true)
    end
end
vgui.Register("TalkModes.Navbar", PANEL, "DPanel")

