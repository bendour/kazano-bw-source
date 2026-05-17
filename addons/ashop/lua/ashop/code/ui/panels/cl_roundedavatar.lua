local PANEL = {}

function PANEL:Init()
end

function PANEL:OnSizeChanged()
    self:Clear()
    self.maskAvatar = nil

    local a = vgui.Create("AvatarImage", self)
    a:Dock(FILL)
    a:SetPlayer(self.player or LocalPlayer(), 184)
    a:SetPaintedManually(true)

    self.avatar = a
end

function PANEL:Paint(w, h)
    if !self.maskAvatar then
        self.maskAvatar = ashop.ui.RoundedBox(8, 0, 0, w, h)
    end

    ashop.StartStencil()
        surface.SetDrawColor(1, 1, 1, 1)
        surface.DrawPoly(self.maskAvatar)
    ashop.ReplaceStencil(1)
        self.avatar:PaintManual()
    ashop.EndStencil()
end

derma.DefineControl( "AShop_RoundedAvatar", "", PANEL, "EditablePanel" )