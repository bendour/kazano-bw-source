zmlab = zmlab or {}
zmlab.f = zmlab.f or {}

function zmlab.f.Player_GetID(ply)
    if ply:IsBot() then
        return ply:UserID()
    else
        return ply:SteamID()
    end
end

function zmlab.f.Player_GetName(ply)
    if ply:IsBot() then
        return "Bot_" .. ply:UserID()
    else
        return ply:Nick()
    end
end
