/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

if CLIENT then return end
zpn = zpn or {}
zpn.Candy = zpn.Candy or {}

////////////////////////////////////////////
////////////// Candy Points //////////////////
////////////////////////////////////////////
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- da71c7e0bf5016ce33a9f318a3747fb53331bb70d9090f016fdcc745ceefa6b8

// This System keeps track on how many Candy Points the player currently has
zpn.CandyPoints = zpn.CandyPoints or {}

function zpn.Candy.SetPoints(ply, points)
    if not IsValid(ply) then return end
    zclib.Debug("zpn.Candy.SetPoints: " .. points .. " for " .. ply:Nick())
    local plyID = zclib.Player.GetID(ply)

    zpn.CandyPoints[plyID] = points

    zpn.data.DataChanged(ply)
end

function zpn.Candy.AddPoints(ply, points)
    if not IsValid(ply) then return end
    zclib.Debug("zpn.Candy.AddPoints: " .. points .. " to " .. ply:Nick())
    local plyID = zclib.Player.GetID(ply)

    zpn.Candy.Notify(ply,points)
    zpn.CandyPoints[plyID] = zpn.Candy.ReturnPoints(ply) + points
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

    hook.Run("zpn_OnCandyCollect", ply, points)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 69811ac079f3e93f705541d1ed39dfac3a9e2460011697a76c02cf9afa26f9c3

    zpn.data.DataChanged(ply)
end

// Returns the players CandyPoints
function zpn.Candy.ReturnPoints(ply)
    return zpn.CandyPoints[zclib.Player.GetID(ply)] or 0
end

// Checks if the player has a certain amount of candy points
function zpn.Candy.HasPoints(ply,amount)
    return zpn.Candy.ReturnPoints(ply) >= amount
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

// Takes CandyPoints from a Player
function zpn.Candy.TakePoints(ply,amount)
    if not IsValid(ply) then return end
    zclib.Debug("zpn.Candy.TakePoints: " .. amount .. " to " .. ply:Nick())
    local plyID = zclib.Player.GetID(ply)

    zpn.CandyPoints[plyID] = math.Clamp(zpn.Candy.ReturnPoints(ply) - amount,0,9999999999)

    zpn.data.DataChanged(ply)
end
////////////////////////////////////////////
////////////////////////////////////////////
