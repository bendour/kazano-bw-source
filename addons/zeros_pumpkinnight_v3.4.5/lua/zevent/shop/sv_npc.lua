/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

if CLIENT then return end
zpn = zpn or {}
zpn.NPC = zpn.NPC or {}
zpn.PurchaseType = zpn.PurchaseType or {}

function zpn.NPC.USE(ply, npc)
    zpn.Shop.Open(ply, npc)
end

// Sets up the saving / loading and removing of the entity for the map
zclib.STM.Setup("zpn_npc","zpn/" .. string.lower(game.GetMap()) .. "_shopnpc" .. ".txt",function()
    local data = {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 69811ac079f3e93f705541d1ed39dfac3a9e2460011697a76c02cf9afa26f9c3
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

    for u, j in pairs(ents.FindByClass("zpn_npc")) do
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
        local ent = ents.Create("zpn_npc")
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
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

    zpn.Print("Finished loading Shop NPC Entities.")
end,function()
    for k, v in pairs(ents.FindByClass("zpn_npc")) do
        if IsValid(v) then
            v:Remove()
        end
    end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

concommand.Add("zpn_save_npc", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) and zclib.STM.Save("zpn_npc") then
        zclib.Notify(ply, "Shop NPC entities have been saved for the map " .. game.GetMap() .. "!", 0)
    end
end)

concommand.Add("zpn_remove_npc", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then
        zclib.Notify(ply, "Shop NPC entities have been removed for the map " .. game.GetMap() .. "!", 0)
        zclib.STM.Remove("zpn_npc")
    end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- da71c7e0bf5016ce33a9f318a3747fb53331bb70d9090f016fdcc745ceefa6b8
