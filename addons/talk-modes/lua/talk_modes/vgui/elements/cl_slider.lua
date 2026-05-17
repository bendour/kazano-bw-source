local circles = include("talk_modes/vgui/libs/cl_circles.lua")
local THEME = TalkModes.Client.ActiveTheme

local PANEL = {}
AccessorFunc(PANEL, "color", "Color")  
function PANEL:Init()
    self:SetSize(260, 12)
    self:SetDecimals(0)
    self.Wang:SetVisible(false)
    self.Label:SetVisible(false)
    self.TextArea:SetFont("TalkModes:Small")
    self.TextArea:SetDrawLanguageID(false)
--  self.TextArea:SetEditable(false)
    self.Circle = circles.New(CIRCLE_FILLED, 6, 6, 6)
    self.Circle:SetDistance(2)
    self.TextArea:SetTextColor(THEME["White"])
    self.Slider.Knob.Paint = function(this)
        draw.NoTexture()
        surface.SetDrawColor(self:GetColor() || THEME["White"])
        self.Circle()
    end
    self.Slider.Paint = nil
end

function PANEL:Paint(intW, intH)
    draw.RoundedBox(6, 0, 0, intW - self.TextArea:GetSize() - 4, 12, THEME["Background"])
end
vgui.Register("TalkModes.Slider", PANEL, "DNumSlider")
