local THEME = TalkModes.Client.ActiveTheme

local PANEL = {}
AccessorFunc(PANEL, "value", "Value")
function PANEL:Init()
    self.slider = self:Add("TalkModes.Slider")
    self.slider:SetSize(256, 12)
    self.slider:SetPos(8, 100 - 6 - 24)

    self.preview = self:Add("DButton")
    self.preview:SetFont("TalkModes:Small")
    self.preview:SetText(string.upper(TalkModes.Languages:GetPhrase("Preview")))
    self.preview:DockMargin(6, 6, 6, 6)
    self.preview:SetColor(THEME["White"])
    self.preview:SizeToContents()
    self.preview:SetPos(8 + 256, 100 - 6 - 18 - self.preview:GetTall()/2)
    self.preview.Alpha = 90
    self.preview.Paint = function(self, intW, intH)
        self.Alpha = Lerp(FrameTime() * 8, self.Alpha, self:IsHovered() && 230 || 90)
        draw.RoundedBox(6, 0, 0, intW, intH, Color(THEME["Hover"].r, THEME["Hover"].g, THEME["Hover"].b, self.Alpha))
    end
    self.preview.DoClick = function(this)
        net.Start("TalkModes.AttemptPreview")
            net.WriteUInt(self.slider:GetValue(), 32)
        net.SendToServer()
    end
end

function PANEL:RefreshValue()
    self.slider:SetValue(self:GetValue())
end

function PANEL:Think()
    self:SetValue(self.slider:GetValue())
end
vgui.Register("TalkModes.PreviewSlider", PANEL, "EditablePanel")
