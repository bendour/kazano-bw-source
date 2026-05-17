local PANEL = {}

function PANEL:Init()

    self:SetOrigSize(1000, 600)
    local container = self:Add("Panel")
    container:Dock(FILL)

    local factionSelection = container:Add("VoidFactions.UI.FactionListSelect")
    factionSelection:Dock(LEFT)
    factionSelection:SetFactions(VoidFactions.LoadedFactions)

    local factionInfo = container:Add("VoidFactions.UI.FactionSettingsInfo")
    factionInfo:Dock(FILL)
    factionInfo:SetVisible(false)

    function factionSelection:OnSelect(faction, isTemplate)
        factionInfo:SetVisible(true)
        factionInfo:SetFaction(faction, isTemplate)
    end

    self.factionSelection = factionSelection
    self.factionInfo = factionInfo

    self.container = container
end

function PANEL:PerformLayout(w, h)
    self.factionSelection:SDockPadding(8,8,8,8,self)
    self.container:SDockMargin(25,25,25,25,self)
    self.factionSelection:SSetWide(270, self)

    self.factionInfo:MarginLeft(20, self)
end


vgui.Register("VoidFactions.UI.StaticFactionSettings", PANEL, "VoidUI.PanelContent")

-- ^ static factions

local PANEL = {}

function PANEL:Init()
    if (VoidFactions.Settings:IsStaticFactions()) then
        local panel = self:Add("VoidFactions.UI.StaticFactionSettings")
        panel:Dock(FILL)
        panel:SetVisible(true)

        self.panel = panel
    else
        local panel = self:Add("VoidFactions.UI.DynamicFactionSettings")
        panel:Dock(FILL)
        panel:SetVisible(true)

        self.panel = panel
    end
end

vgui.Register("VoidFactions.UI.FactionSettings", PANEL, "VoidUI.PanelContent")