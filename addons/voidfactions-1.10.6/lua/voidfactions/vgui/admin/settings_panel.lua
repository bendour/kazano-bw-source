local sc = VoidUI.Scale
local L = VoidFactions.Lang.GetPhrase

local PANEL = {}

function PANEL:Init()

    local ply = LocalPlayer()

    self.tabs = self:Add("VoidUI.Tabs")

    self.tabs:SetAccentColor(VoidFactions.UI.Accent)

    if (CAMI.PlayerHasAccess(ply, "VoidFactions_ManageFactions")) then
        local factions = self.tabs:Add("VoidFactions.UI.FactionSettings")
        self.tabs:AddTab(string.upper(L"factions"), factions)
        self.factions = factions
    end

    if (CAMI.PlayerHasAccess(ply, "VoidFactions_EditSettings")) then
        local setup = self.tabs:Add("VoidFactions.UI.SetupPanel")
        self.tabs:AddTab(string.upper(L"setup"), setup)
        self.setup = setup

        local options = self.tabs:Add("VoidFactions.UI.Options")
        self.tabs:AddTab(string.upper(L"options"), options)
        self.options = options
    end

end

vgui.Register("VoidFactions.UI.SettingsPanel", PANEL, "VoidUI.PanelContent")
