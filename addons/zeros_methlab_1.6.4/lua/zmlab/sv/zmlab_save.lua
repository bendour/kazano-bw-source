if (not SERVER) then return end
zmlab = zmlab or {}
zmlab.f = zmlab.f or {}

function zmlab.f.NPC_Save(ply)
    if not file.Exists("zmlab", "DATA") then
        file.CreateDir("zmlab")
    end
    local bdata = {}

    for u, j in pairs(ents.FindByClass("zmlab_methbuyer")) do
        table.insert(bdata, {
            class = j:GetClass(),
            pos = j:GetPos(),
            ang = j:GetAngles()
        })
    end

    file.Write("zmlab/" .. string.lower(game.GetMap()) .. "_MethNPCs" .. ".txt", util.TableToJSON(bdata))
    zmlab.f.Notify(ply, "Meth BuyerNPCs have been saved for the map " .. string.lower(game.GetMap()) .. "!", 0)
end

function zmlab.f.NPC_Load()
    if file.Exists("zmlab/" .. string.lower(game.GetMap()) .. "_MethNPCs" .. ".txt", "DATA") then
        local data = file.Read("zmlab/" .. string.lower(game.GetMap()) .. "_MethNPCs" .. ".txt", "DATA")
        data = util.JSONToTable(data)

        for k, v in pairs(data) do
            local ent = ents.Create(v.class)
            ent:SetPos(v.pos)
            ent:SetAngles(v.ang)
            ent:Spawn()
            ent:Activate()
        end

        print("[Zeros MethLab] Finished loading MethBuyer entities.")
    else
        print("[Zeros MethLab] No map data found for MethBuyer entities.")
    end
end

function zmlab.f.NPC_Remove()
    if file.Exists("zmlab/" .. string.lower(game.GetMap()) .. "_MethNPCs" .. ".txt", "DATA") then
        file.Delete("zmlab/" .. string.lower(game.GetMap()) .. "_MethNPCs" .. ".txt")
    end

    for k, v in pairs(ents.FindByClass("zmlab_methbuyer")) do
        if IsValid(v) then
            v:Remove()
        end
    end
end



function zmlab.f.DropOff_Save(ply)
    if not file.Exists("zmlab", "DATA") then
        file.CreateDir("zmlab")
    end

    local ddata = {}

    for u, j in pairs(ents.FindByClass("zmlab_methdropoff")) do
        table.insert(ddata, {
            class = j:GetClass(),
            pos = j:GetPos(),
            ang = j:GetAngles()
        })
    end

    file.Write("zmlab/" .. string.lower(game.GetMap()) .. "_MethDropOff" .. ".txt", util.TableToJSON(ddata))
    zmlab.f.Notify(ply, "DropOffPoints have been saved for the map " .. string.lower(game.GetMap()) .. "!", 0)
end

function zmlab.f.DropOff_Load()

    if file.Exists("zmlab/" .. string.lower(game.GetMap()) .. "_MethDropOff" .. ".txt", "DATA") then
        local data = file.Read("zmlab/" .. string.lower(game.GetMap()) .. "_MethDropOff" .. ".txt", "DATA")
        data = util.JSONToTable(data)

        for k, v in pairs(data) do
            local dropoff = ents.Create(v.class)
            dropoff:SetPos(v.pos)
            dropoff:SetAngles(v.ang)
            dropoff:Spawn()
            dropoff:GetPhysicsObject():EnableMotion(false)
        end

        print("[Zeros MethLab] Finished loading DropOffPoint entities.")
    else
        print("[Zeros MethLab] No map data found for DropOffPoint entities.")
    end
end

function zmlab.f.DropOff_Remove()
    if file.Exists("zmlab/" .. string.lower(game.GetMap()) .. "_MethDropOff" .. ".txt", "DATA") then
        file.Delete("zmlab/" .. string.lower(game.GetMap()) .. "_MethDropOff" .. ".txt")
    end

    for k, v in pairs(ents.FindByClass("zmlab_methdropoff")) do
        if IsValid(v) then
            v:Remove()
        end
    end
end



function zmlab.f.PublicEnts_Save(ply)
    zmlab.f.DropOff_Save(ply)
    zmlab.f.NPC_Save(ply)
end

function zmlab.f.PublicEnts_Load()
    zmlab.f.DropOff_Load()
    zmlab.f.NPC_Load()
end
timer.Simple(0,function()
    zmlab.f.PublicEnts_Load()
end)

hook.Add("PostCleanupMap", "a_zmlab_PublicEnts_PostCleanUp", function()
    zmlab.f.PublicEnts_Load()
end)
