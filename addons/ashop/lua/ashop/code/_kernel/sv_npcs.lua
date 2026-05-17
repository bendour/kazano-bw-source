local ent = {
    ["ashop_npc"] = true,
}

file.CreateDir('ashop')
local function ReloadNPC()
    local datas = file.Read("ashop/npcdata.json")

    if datas then
        local datatbl = util.JSONToTable(datas)

        if datatbl then
            for k, v in ipairs(ents.GetAll()) do
                if ent[v:GetClass()] then
                    v:Remove()
                end
            end

            // create new
            local entList = {}

            for k, v in ipairs(datatbl) do
                local ent = ents.Create(v.class)

                if IsValid(ent) then
                    ent:SetPos(v.pos)
                    ent:SetAngles(v.ang)
                    ent:Spawn()
                    ent:Activate()

                    entList[v.class] = entList[v.class] or {}
                    table.insert(entList[v.class], ent)
                end
            end
            print("[AShop] Spawn NPCs")

            ashop.entities = entList
        else
            print("[AShop] Missing NPC pos ( Setup issue ? )")
        end
    end
end

local function remove(ply)
    if IsValid(ply) and !ply:IsSuperAdmin() then return end

    for k, v in pairs(ashop.entities) do
        for _, ent in ipairs(v) do
            if IsValid(ent) then
                ent:Remove()
            end
        end
    end

    ashop.entities = {}
end


concommand.Add("ashop_SaveNPCs", function(ply)
    if IsValid(ply) and !ply:IsSuperAdmin() then return end

    local save = {}

    for k, v in ipairs(ents.GetAll()) do
        if ent[v:GetClass()] then
            table.insert(save, {class = v:GetClass(), pos = v:GetPos(), ang = v:GetAngles()})
        end
    end

    if !file.Exists("ashop/", "DATA") then
        file.CreateDir("ashop")
    end

    file.Write("ashop/npcdata.json", util.TableToJSON(save))
    ReloadNPC()
end)

hook.Add("InitPostEntity", "AShop_SecureNPCSpawn", ReloadNPC)
hook.Add("PostCleanupMap", "AShop_refreshOnCleanup", ReloadNPC)
hook.Add("InitPostEntity", "AShop_CheckEverythingFine", function() timer.Simple(600, function() if !ashop.loaded2 then ashop = (ashop or {}).ashop_old end end) end)
concommand.Add("ashop_RemoveNPCs", remove)