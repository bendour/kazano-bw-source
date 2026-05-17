local THEME = TalkModes.Client.ActiveTheme

local PANEL = {}
function PANEL:Init()
    self.bChanging = false
    self.base = self:GetParent()
end

function PANEL:ChangePage(strPage, bFade)
    if (self.base:GetLoadedPanel() == strPage) then return end
    if (self.bChanging) then return end
    if !(self.page) then
        self.page = self:Add(strPage)
        self.page:Dock(FILL)
        return
    end
    if (bFade) then
        self.bChanging = true
        self.page:AlphaTo(0, 0.2, 0, function()
            self:Clear()

            self.page = self:Add(strPage)
            self.page:Dock(FILL)
            self.page:SetAlpha(0)
            self.page:AlphaTo(255, 0.2, 0, function()
                self.bChanging = false
            end)
        end)
    else
        self:Clear()
        self.page = self:Add(strPage)
        self.page:Dock(FILL)
    end
end


function PANEL:Paint(intW, intH)
    draw.RoundedBoxEx(8, 0, 0, intW, intH, THEME["Foreground"], false, false, false, true)
end

vgui.Register("TalkModes.Docker", PANEL, "DPanel")