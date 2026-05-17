--[[-------------------------------------------

    Talk Modes - whisper/talk/yell 

    Licensed to 00000000000000000
	Version: 1.1.1

	By: SaturdaysHeroes & Djuk
	Special thanks to CupCakeR

--]]-------------------------------------------
TalkModes = TalkModes || {}
TalkModes.Server = TalkModes.Server || {}

function TalkModes.Server.OpenAdminMenu(pPlayer, strTxt)
    if !TalkModes.Config.ConfigCommands[string.lower(strTxt)] then return end
    if !TalkModes.Config.AllowedRanks[pPlayer:GetUserGroup()] then return "" end
    
    net.Start("TalkModes.OpenAdminMenu")
    net.Send(pPlayer)

    return ""
end
hook.Add("PlayerSay", "TalkModes.Server.OpenAdminMenu", TalkModes.Server.OpenAdminMenu)

-- Took the idea from DarkRP, we'll create a proxy function to avoid expensive calculations in the hook. 
function TalkModes.Server:CalculateCanHear(pPlayer)
    if !IsValid(pPlayer) then return end

    pPlayer.CanHear = pPlayer.CanHear || {}
    for _, v in ipairs(player.GetAll()) do 
        local vecTalkPos = v:GetShootPos()
        local intTalkDistance = TalkModes:GetDistance(v:GetTalkMode()) * TalkModes:GetDistance(v:GetTalkMode())

        pPlayer.CanHear[v] = vecTalkPos:DistToSqr(pPlayer:GetShootPos()) <= intTalkDistance
    end
end

-- Create a timer for each player to check who they can hear. 
function TalkModes.Server.PlayerInitialSpawn(pPlayer)
    pPlayer:SetTalkMode("Talk")

    -- Run all initial functions on the player. 
    TalkModes.Server:NetworkConfig(pPlayer)
    TalkModes.Server:InitMenu(pPlayer)
    TalkModes.Server:CalculateCanHear(pPlayer)

    -- Running the proxy function every 0.5s will guarantee everyone is heard "in time".
    -- It still has a low impact compared to the voice hook which triggers multiple times per tick. 
    timer.Create("TalkModes.Server.ProxyCanHear_"..pPlayer:SteamID64(), 0.5, 0, function() 
        TalkModes.Server:CalculateCanHear(pPlayer)
    end)

    -- Sadly, input.GetKeyName is only available clientside. 
    timer.Simple(5, function()
        if !IsValid(pPlayer) then return end
        
        net.Start("TalkModes.WelcomeMessage")
        net.Send(pPlayer)
    end)
end
hook.Add("PlayerInitialSpawn", "TalkModes.Server.ProxyCanHear", TalkModes.Server.PlayerInitialSpawn)

-- You can't hear players who left, right?
function TalkModes.Server.PlayerDisconnected(pPlayer)
    if !pPlayer.CanHear then return end

    for _, v in ipairs(player.GetAll()) do
        if !v.CanHear then continue end

        v.CanHear[pPlayer] = nil
    end

    timer.Remove("TalkModes.Server.ProxyCanHear_"..pPlayer:SteamID64())
end
hook.Add("PlayerDisconnected", "TalkModes.Server.ProxyCanHear", TalkModes.Server.PlayerDisconnected)

-- We have to override this gamemode hook, sorry. 
-- I thought this could cause potential issues but DarkRP handles it in the same way, we should be fine. 
hook.Add("PostGamemodeLoaded", "TalkModes.Server.PostGamemodeLoaded", function()
    function GAMEMODE:PlayerCanHearPlayersVoice(pListener, pTalker)
        if !pTalker:Alive() then return TalkModes.Config:GetSetting("General", "Talking Dead") end 

        local bHear = pListener.CanHear[pTalker] && pListener.CanHear[pTalker]

        return bHear, TalkModes.Config:GetSetting("General", "3D Voice") 
    end
end) 