local PANEL = {}
function PANEL:Init()
    self:SetPageName("General")
    self.tblDefaultSettings = {
        ["Language"] = {
            strDesc = "Language_Desc",
            strType = "tDropdown",
            tblData = TalkModes.Languages.Available
        },
        ["Selection Key"] = {
            strDesc = "Selection Key_Desc",
            strType = "tBinder"
        },
        ["3D Voice"] = {
            strDesc = "3D Voice_Desc",
            strType = "tSwitch"
        },
        ["Talking Dead"] = {
            strDesc = "Talking Dead_Desc",
            strType = "tSwitch"
        },
        ["Selection Menu Position"] = {
            strDesc = "Selection Menu Position_Desc",
            strType = "tDropdown",
            tblData = {
                ["Top Left"] = 1,
                ["Top Center"] = 2,
                ["Top Right"] = 3,
                ["Center Left"] = 4,
                ["Center Right"] = 5,
                ["Bottom Left"] = 6,
                ["Bottom Center"] = 7,
                ["Bottom Right"] = 8
            }
        },
        ["Auto-Hide"] = {
            strDesc = "Auto-Hide_Desc",
            strType = "tSwitch"
        },
        ["Mode Change Message"] = {
            strDesc = "Mode Change Message_Desc",
            strType = "tSwitch"
        }
    }
    self:RefreshSettings()
end
vgui.Register("TalkModes.GeneralSettings", PANEL, "TalkModes.SettingsBase")
