local THEME = TalkModes.Client.ActiveTheme

local PANEL = {}
function PANEL:Init()
    self:SetTextColor(THEME["White"])
    self:SetFont("TalkModes:Small")
end

function PANEL:Paint(intW, intH)
    draw.RoundedBox(6, 0, 0, intW, intH, THEME["Background"])
end

function PANEL:DoClick()
	self:SetText("PRESS A KEY")
	self.intW, self.intH = self:GetContentSize()
    self:SetSize(self.intW + 24, self.intH + 4)
	input.StartKeyTrapping()
	self.Trapping = true
end

function PANEL:UpdateText()
	local str = input.GetKeyName( self:GetSelectedNumber() )
	if ( !str ) then str = "NONE" end
	str = language.GetPhrase( str )
	self:SetText(string.upper(str))
	self.intW, self.intH = self:GetContentSize()
    self:SetSize(self.intW + 24, self.intH + 4)
end
vgui.Register("TalkModes.Binder", PANEL, "DBinder")