local L = VoidFactions.Lang.GetPhrase

local PANEL = {}

function PANEL:Init()
    self:SetOrigSize(1000, 600)

    local setupPanel = self
    setupPanel:SetTitle(string.upper(L"chooseMode"))

    local cardContainer = setupPanel:Add("Panel")
    cardContainer:Dock(TOP)

    local staticCard = cardContainer:Add("VoidUI.Card")
    staticCard:Dock(LEFT)

    staticCard:SetAccent(VoidUI.Colors.Blue)

    staticCard:SetContent(L"staticFactionsContent")
    staticCard:SetFooter(L"suitedForSerious")
    staticCard:SetTitle(L"factions", L"static")

    if not DarkRP then
        staticCard:SetFooter("Only supported in DarkRP based gamemodes!")
    end

    staticCard.button:SetText(L"select")
    if (VoidFactions.Config.FactionType == VOIDFACTIONS_STATICFACTIONS) then
        staticCard.button:SetSelected(true)
    end
    staticCard.button.DoClick = function ()
        if (VoidFactions.Settings:IsDynamicFactions()) then
            -- Are you sure you want to switch? Wipe all data later
            local popup = vgui.Create("VoidUI.Popup")
            popup:SetText(L"switchType", L"switchTypePrompt")
            popup:SetDanger()
            popup:Continue(L"switch", function ()
                VoidFactions.Settings:UpdateConfig("FactionType", VOIDFACTIONS_STATICFACTIONS)
                self.dynamicCard.button:SetSelected(false)
                staticCard.button:SetSelected(true)

                self:Remove()
                VoidFactions.Menu.ReopenRequested = true
            end)
            popup:Cancel(L"cancel")
            popup:SSetTall(200)
        else
            self.dynamicCard.button:SetSelected(false)
            staticCard.button:SetSelected(true)

            VoidFactions.Settings:UpdateConfig("FactionType", VOIDFACTIONS_STATICFACTIONS)
        end
    end

    local dynamicCard = cardContainer:Add("VoidUI.Card")
    dynamicCard:Dock(RIGHT)

    dynamicCard:SetAccent(VoidUI.Colors.Green)
    dynamicCard:SetGradient(VoidUI.Colors.GreenGradientEnd, VoidUI.Colors.Green)

    dynamicCard:SetTitle(L"factions", L"dynamic")
    dynamicCard:SetContent(L"dynamicFactionsContent")
    dynamicCard:SetFooter(L"suitedForNonSerious")

    dynamicCard.button:SetText(L"select")
    dynamicCard.button.DoClick = function ()
        if (VoidFactions.Settings:IsStaticFactions()) then
            -- Are you sure you want to switch? Wipe all data later
            local popup = vgui.Create("VoidUI.Popup")
            popup:SetText(L"switchType", L"switchTypePrompt")
            popup:SetDanger()
            popup:Continue(L"switch", function ()
                VoidFactions.Settings:UpdateConfig("FactionType", VOIDFACTIONS_DYNAMICFACTIONS)
                dynamicCard.button:SetSelected(true)
                staticCard.button:SetSelected(false)
                self:Remove()

                VoidFactions.Menu.ReopenRequested = true
            end)
            popup:Cancel(L"cancel")
            popup:SSetTall(200)
        else
            dynamicCard.button:SetSelected(true)
            staticCard.button:SetSelected(false)

            VoidFactions.Settings:UpdateConfig("FactionType", VOIDFACTIONS_DYNAMICFACTIONS)
        end
    end
    
    if (VoidFactions.Config.FactionType == VOIDFACTIONS_DYNAMICFACTIONS) then
        dynamicCard.button:SetSelected(true)
    end

    self.setupPanel = setupPanel
    self.cardContainer = cardContainer
    self.staticCard = staticCard
    self.dynamicCard = dynamicCard

end

function PANEL:PerformLayout(w, h)
    self.setupPanel:SDockPadding(140,20,140,80,self)
    self.setupPanel.panelTitle:SSetTall(45, self)

    self.cardContainer:MarginTop(10, self)
    self.cardContainer:SSetTall(410, self)
    self.cardContainer:MarginSides(45, self)

    self.staticCard:SSetWide(300, self)
    self.dynamicCard:SSetWide(300, self)
end

vgui.Register("VoidFactions.UI.SetupPanel", PANEL, "VoidUI.PanelContent")