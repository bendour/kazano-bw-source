--[[-------------------------------------------

    Talk Modes - whisper/talk/yell 

    Licensed to 00000000000000000
	Version: 1.1.1

	By: SaturdaysHeroes & Djuk
	Special thanks to CupCakeR

--]]-------------------------------------------
local PLAYER = FindMetaTable("Player")

function TalkModes:IsValidMode(strMode)
    local bValid = false

    for i, v in pairs(self.Config:GetTable("Modes")) do 
        if i == strMode then bValid = true end
    end

    return bValid
end

function TalkModes:GetDistance(strMode)
    return self.Config:GetTable("Modes")[strMode] || 0
end

function PLAYER:SetTalkMode(strMode)
    if (SERVER) then 
        if !TalkModes:IsValidMode(strMode) then return end

        self:SetNWString("TalkMode", strMode)
    end
end

function PLAYER:GetTalkMode()
    return self:GetNWString("TalkMode") || "Talk"
end


