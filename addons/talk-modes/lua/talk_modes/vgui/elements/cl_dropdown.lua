local THEME = TalkModes.Client.ActiveTheme

local PANEL = {}
function PANEL:Init()
    self:SetTextColor(THEME["White"])
    self:SetFont("TalkModes:Small")
end

function PANEL:Paint(intW, intH)
    draw.RoundedBox(6, 0, 0, intW, intH, THEME["Background"])
end

function PANEL:OnSelect()
    self.intW, self.intH = self:GetContentSize()
    self:SetSize(self.intW + 24, self.intH + 4)
end

vgui.Register("TalkModes.Dropdown", PANEL, "DComboBox")