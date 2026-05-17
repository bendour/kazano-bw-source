local PANEL = {}
function PANEL:Init()
    self:SetPageName("UI")
    self.tblDefaultSettings = {
        ["Background"] = {
            strDesc = "Background_Desc",
            strType = "tColor",
        },
        ["Foreground"] = {
            strDesc = "Foreground_Desc",
            strType = "tColor"
        },
        ["Hover"] = {
            strDesc = "Hover_Desc",
            strType = "tColor"
        },
        ["White"] = {
            strDesc = "White_Desc",
            strType = "tColor"
        },
        ["Gray"] = {
            strDesc = "Gray_Desc",
            strType = "tColor"
        },
    }
    self:RefreshSettings()
end
vgui.Register("TalkModes.ThemesSettings", PANEL, "TalkModes.SettingsBase")