hook.Add("PlayerInitialSpawn", "VoidFactions.Playtime.TrackPlaytimeSV", function (ply)
    ply.vf_sessionJoin = SysTime()
end)

hook.Add("InitPostEntity", "VoidFactions.Playtime.TrackSessionCL", function ()
    if (SERVER) then return end
    LocalPlayer().vf_sessionJoin = SysTime()
end)

--[[---------------------------------------------------------
	Name: Player meta
-----------------------------------------------------------]]

local PLAYER = FindMetaTable("Player")

-- Returns seconds
function PLAYER:GetSessionPlaytime(noFormat)
    if (!self.vf_sessionJoin) then
	self.vf_sessionJoin = SysTime()
    end
	
    local sessionTime = SysTime() - self.vf_sessionJoin
    return (noFormat and sessionTime) or string.NiceTime(sessionTime)
end

