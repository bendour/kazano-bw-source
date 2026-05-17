local PANEL = {}

function PANEL:Init()
    self:SetMouseInputEnabled(true)
    self.state = false

    local p = vgui.Create("EditablePanel", self)
    p:Dock(LEFT)
    p:SetWide(16)
    p:SetMouseInputEnabled(false)

    self.Button = p

    local stateOn = ashop.GetColor('StateOn')
    local stateOff = ashop.GetColor('StateOff')

    p.Paint = function(_, w, h)
        draw.RoundedBox(4, 0, 0, w, h, self.state and stateOn or stateOff)
    end

    local l = vgui.Create("DLabel", self)
    l:SetFont('ashop_16')
    l:SetText('Un texte')
    l:DockMargin(ashop.GetFontHeight('ashop_16')/2, 0, 0, 0)
    l:Dock(FILL)
    l:SetMouseInputEnabled(false)
    l:SetTextColor(color_white)

    self.Label = l
end

function PANEL:SetValue( val )
	self.state = val
end

function PANEL:GetChecked()
	return self.state
end

function PANEL:Toggle()
    self:SetValue(!self:GetChecked())
    self:OnChange(self:GetChecked())
end

function PANEL:PerformLayout(w, h)
    self.Label:DockMargin(ashop.GetFontHeight(self.Label:GetFont())/2, 0, 0, 0)
    self.Button:SetWide(h)
end

function PANEL:SetTextColor( color )
	self.Label:SetTextColor( color )
end

function PANEL:SetText( text )
	self.Label:SetText( text )
end

function PANEL:SetFont( font )
	self.Label:SetFont( font )
    self.Label:DockMargin(ashop.GetFontHeight(font)/2, 0, 0, 0)
end

function PANEL:GetText()
	return self.Label:GetText()
end

function PANEL:Paint()
end

function PANEL:OnChange( bVal )
end

function PANEL:OnMousePressed()
    self:DoClick()
end

function PANEL:DoClick()
    self:Toggle()
end

derma.DefineControl( "AShop_DCheckBoxLabel", "", PANEL, "EditablePanel" )