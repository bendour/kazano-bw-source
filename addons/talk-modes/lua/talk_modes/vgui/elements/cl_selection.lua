local circles = include("talk_modes/vgui/libs/cl_circles.lua")
local THEME = TalkModes.Client.ActiveTheme

local PANEL = {}
AccessorFunc(PANEL, "mode_mat", "Material")
AccessorFunc(PANEL, "mode", "Mode")
local tblTalkModes = {
    [1] = {
        strMode = "Whisper",
        matImage = Material("talkmodes/whisper.png")
    },
    [2] = {
        strMode = "Talk",
        matImage = Material("talkmodes/normal.png")
    },  
    [3] = {
        strMode = "Yell",
        matImage = Material("talkmodes/yell.png")
    }
}

function PANEL:Init()
    self:SetSize(32, 32)
    self:Dock(LEFT)
    self:DockMargin(6, 6, 0, 6)
end

function PANEL:Paint(intW, intH)
    surface.SetDrawColor((self:GetMode() == LocalPlayer():GetTalkMode()) && THEME["Hover"] || THEME["Gray"])
    surface.SetMaterial(self:GetMaterial())
    surface.DrawTexturedRect(0, 0, 32, 32)
end
vgui.Register("TalkModes.SpeakMode", PANEL, "EditablePanel")


local PANEL = {}
function PANEL:Init()
    self:SetSize(3 * 32 + 4 * 6, 32 + 12)
    for _, val in ipairs(tblTalkModes) do
        self.pMode = self:Add("TalkModes.SpeakMode")
        self.pMode:SetMaterial(val.matImage)
        self.pMode:SetMode(val.strMode)
    end
end
function PANEL:Paint(intW, intH) 
    draw.RoundedBox(8, 0, 0, intW, intH, THEME["Background"])
end

vgui.Register("TalkModes.PlayerMenu", PANEL, "EditablePanel")
