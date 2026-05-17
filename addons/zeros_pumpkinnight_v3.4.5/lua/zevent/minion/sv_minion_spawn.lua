/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

if CLIENT then return end
zpn = zpn or {}
zpn.Minion = zpn.Minion or {}

zpn.MinionPositions = zpn.MinionPositions or {}

concommand.Add("zpn_minion_showspawns", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then
        zpn.Minion.ShowSpawnHints(ply)
    end
end)

concommand.Add( "zpn_minion_save", function( ply, cmd, args )

    if zclib.Player.IsAdmin(ply) and zclib.STM.Save("zpn_minionspawns") then
        zclib.Notify(ply, "All minion positions got saved for " .. string.lower(game.GetMap()), 0)
        zclib.Notify(ply, "Changes will take effect after map restart.", 0)
    end
end )

concommand.Add( "zpn_minion_remove", function( ply, cmd, args )

    if zclib.Player.IsAdmin(ply) then

        zclib.STM.Remove("zpn_minionspawns")
    end
end )

concommand.Add( "zpn_minion_kill", function( ply, cmd, args )

    if zclib.Player.IsAdmin(ply) then

        for k, v in pairs(ents.FindByClass("zpn_minion")) do
            if IsValid(v) and not IsValid(v.Boss) then
                zpn.Minion.Death(v)
            end
        end
    end
end )

concommand.Add("zpn_minion_spawn", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then
        local tr = util.TraceLine({
            start = ply:EyePos() + ply:EyeAngles():Forward() * 100,
            endpos = ply:EyePos() + ply:EyeAngles():Forward() * 1000
        })

        if tr.Hit and tr.HitPos then
            local ent = ents.Create("zpn_minion")
            local angle = ply:GetAimVector():Angle()
            angle = Angle(0, angle.yaw, 0)
            ent:SetAngles(angle)
            ent:SetPos(tr.HitPos + tr.HitNormal:Angle():Forward() * 50)
            ent:Spawn()
            ent:Activate()
        end
    end
end)


// Sets up the saving / loading and removing of the entity for the map
zclib.STM.Setup("zpn_minionspawns","zpn/" .. string.lower(game.GetMap()) .. "_minionspawns" .. ".txt",function()
    local data = {}

    // Lets load in the existing positions
    for k,v in pairs(zpn.MinionPositions) do
        if v then
            table.insert(data, {
                pos = v.pos,
                ang = v.ang
            })
        end
    end

    for u, j in pairs(ents.FindByClass("zpn_minion")) do
        if IsValid(j) and not IsValid(j.Boss) then
            local InDistance = false
            for k,v in pairs(zpn.MinionPositions) do
                if v and zclib.util.InDistance(v.pos, j:GetPos(), 100) then
                    InDistance = true
                    break
                end
            end
            if InDistance == true then continue end

            table.insert(data, {
                pos = j:GetPos(),
                ang = j:GetAngles()
            })
        end
    end

    return data
end,function(data)

    zpn.MinionPositions = {}
    zpn.MinionPositions = table.Copy(data)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- da71c7e0bf5016ce33a9f318a3747fb53331bb70d9090f016fdcc745ceefa6b8

    zpn.Print("Finished loading Minion Positions.")
end,function()
    for k, v in pairs(ents.FindByClass("zpn_minion")) do
        if IsValid(v) and not IsValid(v.Boss) then
            v:Remove()
        end
    end

    zpn.MinionPositions = {}
end)


////////////////////////////////////////////
//////////////// AUTOSPAWN /////////////////
////////////////////////////////////////////
zpn.SpawnedMinions = zpn.SpawnedMinions or {}

timer.Simple(1,function()
    zpn.Minion.StartAutoSpawn()
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 6af6efba71e4015ff987fc919ecacbe102ec0873079409ab2a0ed0bf25e3f3cd

function zpn.Minion.StartAutoSpawn()
    zclib.Timer.Remove("zpn_Minion_AutoSpawner")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

    zclib.Timer.Create("zpn_Minion_AutoSpawner",zpn.config.Minion.AutoSpawn.Interval,0,function()

        for k,v in pairs(zpn.MinionPositions) do

            if v == nil or v.pos == nil or v.ang == nil then continue end

            // If the Minion limit is reached then stop and wait till some Minion did die
            if table.Count(zpn.SpawnedMinions) >= zpn.config.Minion.AutoSpawn.Limit then continue end

            if IsValid(v.ent) then continue end

            if math.random(0,100) < zpn.config.Minion.AutoSpawn.Chance then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a2b46fa362cff6519809e40cc8d153299c414b52d9b8c3759ca38e67d8a7d851

                local ent = ents.Create("zpn_minion")
                ent:SetPos(v.pos)
                ent:SetAngles(v.ang)
                ent:Spawn()
                ent:Activate()

                local phys = ent:GetPhysicsObject()

                if IsValid(phys) then
                    phys:Wake()
                    phys:EnableMotion(false)
                end

                table.insert(zpn.SpawnedMinions,ent)

                v.ent = ent
            end
        end
    end)
end
////////////////////////////////////////////
////////////////////////////////////////////
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000
