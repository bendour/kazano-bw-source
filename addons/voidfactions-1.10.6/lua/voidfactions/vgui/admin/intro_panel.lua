local sc = VoidUI.Scale

local text = [[
Thank you for :state: VoidFactions.
Please select your faction type below in order to continue.
]]

local PANEL = {}

function PANEL:Init()
    self:SetOrigSize(1000, 600)

    local setup = self:Add("VoidFactions.UI.SetupPanel")
    setup:Dock(FILL)
    setup:SetVisible(true)

    local state = "purchasing"
    if (string.find(VoidFactions.CurrentVersion, "beta")) then
        state = "beta testing"
    end
    if (string.find(VoidFactions.CurrentVersion, "alpha")) then
        state = "alpha testing"
    end

    self.text = VoidLib.StringFormat(text, state)

    setup.staticCard.button.DoClick = function ()
        VoidFactions.Settings:UpdateConfig("FactionType", VOIDFACTIONS_STATICFACTIONS)

        self:Finalize(VOIDFACTIONS_STATICFACTIONS)
    end
    setup.dynamicCard.button.DoClick = function ()
        VoidFactions.Settings:UpdateConfig("FactionType", VOIDFACTIONS_DYNAMICFACTIONS)

        self:Finalize(VOIDFACTIONS_DYNAMICFACTIONS)
    end

    self.setup = setup
end

function PANEL:Finalize(fType)
    local panel = self:GetParent()
    panel:Remove()

    VoidFactions.Config.FactionType = fType

    VoidLib.Notify("Success", "VoidFactions has been set up and is now ready to use.", VoidUI.Colors.Green, 5)
    VoidFactions.Menu:Open()
end

function PANEL:Paint(w, h)
    draw.DrawText(self.text, "VoidUI.R32", w/2, sc(20), VoidUI.Colors.Gray, TEXT_ALIGN_CENTER)
end


function PANEL:PerformLayout(w, h)
    self.setup:MarginTop(60, self)
end


vgui.Register("VoidFactions.UI.IntroPanel", PANEL, "VoidUI.PanelContent")