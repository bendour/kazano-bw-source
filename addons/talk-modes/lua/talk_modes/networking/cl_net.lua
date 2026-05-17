--[[-------------------------------------------

    Talk Modes - whisper/talk/yell 

    Licensed to 00000000000000000
	Version: 1.1.1

	By: SaturdaysHeroes & Djuk
	Special thanks to CupCakeR

--]]-------------------------------------------
TalkModes.Client = TalkModes.Client || {}
TalkModes.Client.ActiveTheme = TalkModes.Client.ActiveTheme || {
    ["Background"] = Color(30, 30, 30), 
    ["Foreground"] = Color(40, 40, 40),
    ["Gray"] = Color(160, 160, 160),
    ["Hover"] = Color(192, 57, 43),
    ["White"] = Color(230, 230, 230)
}

function TalkModes.Client.OpenAdminMenu()
    local pMenu = vgui.Create("TalkModes.AdminMenu")
    pMenu:SetAlpha(0)
    pMenu:AlphaTo(255, 0.2)
end
net.Receive("TalkModes.OpenAdminMenu", TalkModes.Client.OpenAdminMenu)

net.Receive("TalkModes.Notify", function()  
    local strMessage = net.ReadString()

    chat.AddText(TalkModes.Client.ActiveTheme["Hover"] || Color(255, 0, 0), "[Talk Modes] ", color_white, strMessage)
end)

net.Receive("TalkModes.WelcomeMessage", function()
    chat.AddText(TalkModes.Client.ActiveTheme["Hover"] || Color(255, 0, 0), "[Talk Modes] ", color_white, string.format(TalkModes.Languages:GetPhrase("WelcomeMessage"), string.upper(input.GetKeyName(TalkModes.Config:GetSetting("General", "Selection Key")))))
end)

net.Receive("TalkModes.Config.Network", function()
	local tblConfig = net.ReadTable()

	TalkModes.Config.Client = tblConfig || {}

    -- This will convert the color values to a color vector. 
    -- It'll make it much easier for the UI. 
    if TalkModes.Client.ActiveTheme != tblConfig["UI"] then 
        for i, v in pairs(tblConfig["UI"]) do 
            TalkModes.Client.ActiveTheme[i] = Color(v.r, v.g, v.b, v.a)
        end
    end
end)
