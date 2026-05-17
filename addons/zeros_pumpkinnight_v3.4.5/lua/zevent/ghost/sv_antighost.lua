/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

if CLIENT then return end
zpn = zpn or {}
zpn.Sign = zpn.Sign or {}


////////////////////////////////////////////
////////////////// ENTITY //////////////////
////////////////////////////////////////////
function zpn.Sign.Initialize(Sign)
    zclib.Debug("zpn.Sign.Initialize")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

    zclib.EntityTracker.Add(Sign)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

    zpn.Sign.Add(Sign)
end

function zpn.Sign.OnRemove(Sign)
    table.RemoveByValue(zpn.AntiGhostSigns,Sign)
end
////////////////////////////////////////////
////////////////////////////////////////////


////////////////////////////////////////////
/////////////// Anti Ghost Sign //////////////////
////////////////////////////////////////////
zpn.AntiGhostSigns = zpn.AntiGhostSigns or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

// Gets called when the score changes
function zpn.Sign.Add(Sign)
    table.insert(zpn.AntiGhostSigns,Sign)
end

// Checks if the player is near a AntiGhost Sign
function zpn.Sign.EntityInDistance(ent)
    local InDistance = false
    local entPos = ent:GetPos()

    for k, v in pairs(zpn.AntiGhostSigns) do
        if IsValid(v) and zclib.util.InDistance(entPos, v:GetPos(), zpn.config.AntiGhostSign.Distance) then
            InDistance = true
            break
        end
    end

    return InDistance
end

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a2b46fa362cff6519809e40cc8d153299c414b52d9b8c3759ca38e67d8a7d851

// Sets up the saving / loading and removing of the entity for the map
zclib.STM.Setup("zpn_AntiGhostSigns","zpn/" .. string.lower(game.GetMap()) .. "_AntiGhostSigns" .. ".txt",function()
    local data = {}

    for u, j in pairs(ents.FindByClass("zpn_sign")) do
        if IsValid(j) then
            table.insert(data, {
                pos = j:GetPos(),
                ang = j:GetAngles()
            })
        end
    end

    return data
end,function(data)

    for k, v in pairs(data) do
        local ent = ents.Create("zpn_sign")
        ent:SetPos(v.pos)
        ent:SetAngles(v.ang)
        ent:Spawn()
        ent:Activate()
        local phys = ent:GetPhysicsObject()

        if IsValid(phys) then
            phys:Wake()
            phys:EnableMotion(false)
        end
    end

    zpn.Print("Finished loading AntiGhostSign Entities.")
end,function()
    for k, v in pairs(ents.FindByClass("zpn_sign")) do
        if IsValid(v) then
            v:Remove()
        end
    end
end)

// Save functions
concommand.Add( "zpn_save_Sign", function( ply, cmd, args )
    if zclib.Player.IsAdmin(ply) then
        zclib.Notify(ply, "AntiGhostSign entities have been saved for the map " .. game.GetMap() .. "!", 0)
        zclib.STM.Save("zpn_AntiGhostSigns")
    end
end )

concommand.Add( "zpn_remove_Sign", function( ply, cmd, args )
    if zclib.Player.IsAdmin(ply) then
        zclib.Notify(ply, "AntiGhostSign entities have been removed for the map " .. game.GetMap() .. "!", 0)
        zclib.STM.Remove("zpn_AntiGhostSigns")
    end
end )
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 6af6efba71e4015ff987fc919ecacbe102ec0873079409ab2a0ed0bf25e3f3cd
