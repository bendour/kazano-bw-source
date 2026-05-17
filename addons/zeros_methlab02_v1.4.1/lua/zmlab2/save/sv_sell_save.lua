/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.1 (stable)
*/

if not SERVER then return end
zmlab2 = zmlab2 or {}
zmlab2.SellSetup = zmlab2.SellSetup or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7e845693ad2a490ead94c2e1f6c2eaff90beaf41e1d134566247921805d9f29b

concommand.Add("zmlab2_sellsetup_save", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then
        zmlab2.SellSetup.Save(ply)
    end
end)
function zmlab2.SellSetup.Save(ply)
    local data = {}

    for k, v in pairs(ents.GetAll()) do
        if IsValid(v) and v:GetClass() == "zmlab2_npc" or v:GetClass() == "zmlab2_dropoff" then
            table.insert(data, {
                class = v:GetClass(),
                pos = v:GetPos(),
                ang = v:GetAngles()
            })
        end
    end

    // Save to file
    if not file.Exists("zmlab2/save", "DATA") then
        file.CreateDir("zmlab2/save")
    end

    file.Write("zmlab2/save/" .. "npc_ents_" .. string.lower(game.GetMap()) .. ".txt", util.TableToJSON(data))
    zclib.Notify(ply, "All NPC / DropOffPoints have been saved for " .. game.GetMap(), 0)
end


function zmlab2.SellSetup.Load()

    local path = "zmlab2/save/" .. "npc_ents_" .. string.lower(game.GetMap()) .. ".txt"
    if file.Exists(path, "DATA") then
        local data = file.Read(path, "DATA")

        data = util.JSONToTable(data)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 071bfceb8fb4fbc39d3b52c5c3fe7b52159006ab4669d1b75f42deff9fdb1cb2
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

        if data and table.Count(data) > 0 then
            for k, v in pairs(data) do
                if v == nil then continue end
                local ent = ents.Create(v.class)
                if not IsValid(ent) then return end
                ent:SetPos(v.pos)
                ent:SetAngles(v.ang)
                ent:Spawn()
                ent:Activate()
            end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7e845693ad2a490ead94c2e1f6c2eaff90beaf41e1d134566247921805d9f29b

            zmlab2.Print("Finished loading NPC / DropOffPoints Entities!")
        end
    else
        zmlab2.Print("No map data found for NPC / DropOffPoints Entities. Please place some and type !zmlab2_save in chat to create the data.")
    end
end
timer.Simple(0.1,function() zmlab2.SellSetup.Load() end)
zclib.Hook.Add("PostCleanupMap", "zmlab2_SellSetup_Load", zmlab2.SellSetup.Load)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 20505de7028925e794a03b5d1a113ab09db033ae5f8a5a69bfd7d0ab6982aaae


concommand.Add("zmlab2_sellsetup_remove", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then
        zmlab2.SellSetup.Remove(ply)
    end
end)
function zmlab2.SellSetup.Remove(ply)
    zclib.Debug("zmlab2.SellSetup.Remove")

    for k, v in pairs(ents.GetAll()) do
        if IsValid(v) and v:GetClass() == "zmlab2_npc" or v:GetClass() == "zmlab2_dropoff" then
            v:Remove()
        end
    end

    local path = "zmlab2/save/" .. "npc_ents_" .. string.lower(game.GetMap()) .. ".txt"
    if file.Exists(path, "DATA") then
        file.Delete(path)
        zclib.Notify(ply, "All NPC / DropOffPoints have been removed for " .. game.GetMap(), 0)
    else
        zclib.Notify(ply,"No NPC / DropOffPoints could be found!", 1)
    end
end
