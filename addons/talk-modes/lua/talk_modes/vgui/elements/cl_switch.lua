local THEME = TalkModes.Client.ActiveTheme
local circles = include("talk_modes/vgui/libs/cl_circles.lua")

local PANEL = {}
AccessorFunc(PANEL, "Value", "Value", FORCE_BOOL)

function PANEL:Init()
    self:SetSize(100, 32)
    self:SetText("")
    self:SetValue(false)

    self.circle = self:Add("DButton")
    self.circle:SetSize(20, 20)
    self.circle:SetPos(0, 5)
    self.circle:SetText("")
    self.circle.func = circles.New(CIRCLE_FILLED, 10, 10, 10)
    self.circle.func:SetDistance(2)
    self.circle.Paint = function()
        draw.NoTexture()
        surface.SetDrawColor((self:GetValue() && self.colGreen) || self.colRed)
        self.circle.func()
    end

    self.circle.DoClick = function()
        self:SetValue(!self:GetValue())
    end

    self.colGreen = Color(39, 174, 96)
    self.colRed = Color(192, 57, 43)
    self.intOffsetX = 0
end

function PANEL:Paint(intW, intH)
    draw.RoundedBox(10, 0, 6, 60, 20, THEME["Background"])
    draw.SimpleText(self:GetValue() && "ON" || "OFF", "TalkModes:Small", intW, intH/2, THEME["White"], TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

    self.intOffsetX = Lerp(FrameTime() * 10, self.intOffsetX, self:GetValue() && 60 - 20 || 0)
    self.circle:SetPos(self.intOffsetX, 5)
end

vgui.Register("TalkModes.Switch", PANEL, "EditablePanel")
