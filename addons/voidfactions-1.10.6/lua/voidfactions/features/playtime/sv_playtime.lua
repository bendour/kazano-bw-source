
--[[---------------------------------------------------------
	Name: Playtime
-----------------------------------------------------------]]

VoidFactions.Playtime = VoidFactions.Playtime or {}
VoidFactions.Playtime.NextIncrement = VoidFactions.Playtime.NextIncrement or nil

function VoidFactions.Playtime:IncrementMinutes(ply)
    local member = ply:GetVFMember()
    if (!member) then return end

    hook.Run("VoidFactions.Playtime.Incremented", member)
    member:IncrementPlaytime()
end

hook.Add("Think", "VoidFactions.Playtime.XPPlaytime", function ()
    if (!VoidFactions.Config.XP_Playtime) then return end -- wait until the config value is ready
    
    -- Only debug, this should be removed later..
    if (!istable(VoidFactions.Config.XP_Playtime)) then
        VoidFactions.Config.XP_Playtime = {VoidFactions.Config.XP_Playtime, 10}
    end

    VoidFactions.Config.XP_Playtime[1] = tonumber(VoidFactions.Config.XP_Playtime[1]) or 0
    VoidFactions.Config.XP_Playtime[2] = tonumber(VoidFactions.Config.XP_Playtime[2]) or 0

    if (VoidFactions.Config.XP_Playtime[1] < 1) then return end
    if (VoidFactions.Config.XP_Playtime[2] < 1) then return end

    if (!VoidFactions.Playtime.NextIncrement) then
        VoidFactions.Playtime.NextIncrement = SysTime() + VoidFactions.Config.XP_Playtime[1] * 60 -- we need the first value (that's the time)
    end


    if (SysTime() > VoidFactions.Playtime.NextIncrement) then
        VoidFactions.Playtime.NextIncrement = SysTime() + VoidFactions.Config.XP_Playtime[1] * 60
        local players = player.GetHumans()
        for _, ply in pairs(players) do
            local member = ply:GetVFMember()
            if (!member) then return end
            hook.Run("VoidFactions.Playtime.XPIncremented", member)
        end
    end
end)

timer.Create("VoidFactions.PlaytimeTracker", 60, 0, function ()
    local players = player.GetHumans()
    for _, ply in pairs(players) do
        VoidFactions.Playtime:IncrementMinutes(ply)
    end
    VoidFactions.SQL:IncrementPlaytime(players)
end)

--[[---------------------------------------------------------
	Name: Player meta
-----------------------------------------------------------]]

local PLAYER = FindMetaTable("Player")

-- Returns minutes
function PLAYER:GetTotalPlaytime(noFormat)
    local playTime = VoidFactions.Members[self].playtime
    return (noFormat and playTime) or string.NiceTime(playTime * 60)
end
