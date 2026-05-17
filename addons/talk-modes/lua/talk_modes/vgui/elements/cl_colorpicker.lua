local circles = include("talk_modes/vgui/libs/cl_circles.lua")
local THEME = TalkModes.Client.ActiveTheme

local PANEL = {}
AccessorFunc(PANEL, "value", "Value")
function PANEL:Init()
    self.R = self:Add("TalkModes.Slider")
    self.R:SetColor(Color(192, 57, 43))
    self.R:SetPos(6, 60)
    self.R:SetMinMax(0, 255)
    self.G = self:Add("TalkModes.Slider")
    self.G:SetColor(Color(39, 174, 96))
    self.G:SetPos(6, 80)
    self.G:SetMinMax(0, 255)
    self.B = self:Add("TalkModes.Slider")
    self.B:SetColor(Color(41, 128, 185))
    self.B:SetPos(6, 100)
    self.B:SetMinMax(0, 255)

    self.preview = self:Add("DPanel")
    self.preview:SetSize(56, 56)
    self.preview:SetPos(300, 60)
    self.preview.Paint = function(_, intW, intH)
        surface.SetDrawColor(Color(20, 20, 20))
        surface.DrawRect(0, 0, intW, intH)
        surface.SetDrawColor(self:GetValue())
        surface.DrawRect(2, 2, intW-4, intH-4)
    end
end
function PANEL:UpdateColors()
    self.R:SetValue(self:GetValue().r)
    self.G:SetValue(self:GetValue().g)
    self.B:SetValue(self:GetValue().b)
end

function PANEL:Think()
    self:SetValue(Color(self.R:GetValue(), self.G:GetValue(), self.B:GetValue()))
end
vgui.Register("TalkModes.ColorPicker", PANEL, "EditablePanel")
