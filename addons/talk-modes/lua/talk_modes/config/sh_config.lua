--[[-------------------------------------------

    Talk Modes - whisper/talk/yell 

    Licensed to 00000000000000000
	Version: 1.1.1

	By: SaturdaysHeroes & Djuk
	Special thanks to CupCakeR

--]]-------------------------------------------
TalkModes = TalkModes || {}
TalkModes.Config = TalkModes.Config || {}

-- Ranks allowed to open in-game config
TalkModes.Config.AllowedRanks = {
    ["superadmin"] = true
}

-- List of commands to open the in-game config. 
TalkModes.Config.ConfigCommands = {
    ["!talkmodes"] = true,
    ["/talkmodes"] = true
}

-- Please do not change anything beyond this point, it could potentially break the script. 
-- All of the script functionality is based around these two functions, I will not help if this is modified. 
function TalkModes.Config:GetSetting(strTable, strSetting)
    if (SERVER) then 
        return self.Server[strTable][strSetting]
    else
        return self.Client[strTable][strSetting]
    end
end

function TalkModes.Config:GetTable(strTable)
    if (SERVER) then 
        return self.Server[strTable]
    else
        return self.Client[strTable]
    end
end