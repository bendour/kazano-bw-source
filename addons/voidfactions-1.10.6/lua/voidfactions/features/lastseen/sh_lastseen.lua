VoidFactions.LastSeen = VoidFactions.LastSeen or {}

function VoidFactions.LastSeen:UpdateLastSeen(ply)
    local member = ply:GetVFMember()
    if (!member) then return end

    member:SetLastSeen(os.time())
end

timer.Create("VoidFactions.LastSeenTracker", 60, 0, function ()
    local players = player.GetHumans()
    for _, ply in pairs(players) do
        VoidFactions.LastSeen:UpdateLastSeen(ply)
    end

    if (SERVER) then
        VoidFactions.SQL:UpdateLastSeen(players)
    end
end)