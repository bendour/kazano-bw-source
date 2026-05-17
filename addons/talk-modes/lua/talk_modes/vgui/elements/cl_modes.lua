local PANEL = {}
function PANEL:Init()
    self:SetPageName("Modes")
    self.tblDefaultSettings = {
        ["Whisper"] = {
            strDesc = "Whisper_Desc",
            strType = "tSlider"
        },
        ["Talk"] = {
            strDesc = "Talk_Desc",
            strType = "tSlider"
        },
        ["Yell"] = {
            strDesc = "Yell_Desc",
            strType = "tSlider"
        }
    }
    self:RefreshSettings()
end
vgui.Register("TalkModes.ModesSettings", PANEL, "TalkModes.SettingsBase")
