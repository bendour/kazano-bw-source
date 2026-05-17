if CLIENT then return end
zwf = zwf or {}
zwf.f = zwf.f or {}
zwf.data = zwf.data or {}


// DATA
function zwf.data.DataChanged(ply)
    zwf.f.Debug("zwf.data.DataChanged")

    if not ply.zwf_DataChanged then
        ply.zwf_DataChanged = true
    end
end

function zwf.data.PlayerDisconnect(ply)
    zwf.f.Debug("zwf.data.PlayerDisconnect")

    if (ply.zwf_DataChanged) then
        zwf.data.Save(ply)
    end
end

hook.Add("PlayerDisconnected", "a_zwf.data.playerdisconnect_id", zwf.data.PlayerDisconnect)

function zwf.data.PlayerSpawn(ply)
    zwf.f.Debug("zwf.data.PlayerSpawn")

    timer.Create("Steam_id_delay_zwf_seedbank" .. ply:EntIndex(), 1, 1, function()
        if (IsValid(ply)) then
            if not file.Exists("zwf", "DATA") then
                file.CreateDir("zwf")
            end

            if not file.Exists("zwf/seedbank/", "DATA") then
                file.CreateDir("zwf/seedbank/")
            end

            local plyID = ply:SteamID64()

            if file.Exists("zwf/seedbank/" .. plyID .. ".txt", "DATA") then
                local data = file.Read("zwf/seedbank/" .. plyID .. ".txt", "DATA")
                data = util.JSONToTable(data)
                ply.zwf_seedbank = data
            else
                ply.zwf_seedbank = {}
            end

            zwf.data.DataChanged(ply)
        end
    end)
end

function zwf.data.AddSeedData(ply, seedData)
    zwf.f.Debug("zwf.data.AddSeedData")

    if ply.zwf_seedbank == nil then
        ply.zwf_seedbank = {}
    end

    table.insert(ply.zwf_seedbank, seedData)
    zwf.data.Save(ply)
end

function zwf.data.RemoveSeedData(ply, DataIndex)
    zwf.f.Debug("zwf.data.RemoveSeedData")

    table.remove(ply.zwf_seedbank, DataIndex)
    zwf.data.Save(ply)
end

function zwf.data.Save(ply)
    zwf.f.Debug("zwf.data.Save")

    if ply.zwf_seedbank == nil then return end

    local plyID = ply:SteamID64()
    if table.Count(ply.zwf_seedbank) <= 0 then 
        file.Delete("zwf/seedbank/" .. tostring(plyID) .. ".txt")
        return
    end

    file.Write("zwf/seedbank/" .. tostring(plyID) .. ".txt", util.TableToJSON(ply.zwf_seedbank,true))
end

function zwf.data.HasSeedDataID(ply, SeedDataID)
    local result = (ply.zwf_seedbank ~= nil and ply.zwf_seedbank[SeedDataID] ~= nil)

    zwf.f.Debug("zwf.data.HasSeedDataID: " .. tostring(result))

    return result
end


//INTERFACE
util.AddNetworkString("zwf_OpenSeedBank")
util.AddNetworkString("zwf_CloseSeedBank")
function zwf.f.OpenSeedBank(ply, SeedBank)

    local seedsString = util.TableToJSON(ply.zwf_seedbank)
    local seedsCompressed = util.Compress(seedsString)
    net.Start("zwf_OpenSeedBank")
    net.WriteUInt(#seedsCompressed, 16)
    net.WriteData(seedsCompressed, #seedsCompressed)
    net.WriteEntity(SeedBank)
    net.Send(ply)
end


util.AddNetworkString("zwf_DropSeed")
net.Receive("zwf_DropSeed", function(len, ply)
    if zwf.f.NW_Player_Timeout(ply) then return end

    local SeedBank = net.ReadEntity()
    local SeedDataID = net.ReadInt(16)

    if not IsValid(SeedBank) then return end
    if SeedBank:GetClass() ~= "zwf_seed_bank" then return end
    if not IsValid(ply) then return end
    if not ply:IsPlayer() then return end
    if not ply:Alive() then return end
    if not zwf.f.InDistance(ply:GetPos(), SeedBank:GetPos(), 200) then return end

    zwf.f.DropSeed(SeedDataID, SeedBank, ply)
end)
function zwf.f.DropSeed(SeedDataID, SeedBank, ply)
    if not IsValid(SeedBank) then return end

    zwf.f.Debug("zwf.f.DropSeed")
    zwf.f.Debug("SeedDataID: " .. SeedDataID)
    zwf.f.Debug("SeedBank: " .. tostring(SeedBank))

    if zwf.data.HasSeedDataID(ply, SeedDataID) then

        local seedData = ply.zwf_seedbank[SeedDataID]

        // Removes the seed from the seedbank
        zwf.data.RemoveSeedData(ply, SeedDataID)

        // Spawns the Seed
    	local ent = ents.Create("zwf_seed")
    	ent:SetAngles(Angle(0,0,0))
    	ent:SetPos(ply:GetPos() + Vector(0,0,50))
    	ent:Spawn()
    	ent:Activate()

        zwf.f.SetOwner(ent, ply)

        ent:SetSkin(zwf.config.Plants[seedData.Weed_ID].skin)

        ent:SetSeedID(seedData.Weed_ID)
        ent:SetSeedName(seedData.Weed_Name)

        ent:SetPerf_Time(seedData.Perf_Time)
        ent:SetPerf_Amount(seedData.Perf_Amount)
        ent:SetPerf_THC(seedData.Perf_THC)

        ent:SetSeedCount(seedData.SeedCount)
    end
end


util.AddNetworkString("zwf_DeleteSeed")
net.Receive("zwf_DeleteSeed", function(len, ply)
    if zwf.f.NW_Player_Timeout(ply) then return end

    local SeedBank = net.ReadEntity()
    local SeedDataID = net.ReadInt(16)

    if not IsValid(SeedBank) then return end
    if SeedBank:GetClass() ~= "zwf_seed_bank" then return end
    if not IsValid(ply) then return end
    if not ply:IsPlayer() then return end
    if not ply:Alive() then return end
    if not zwf.f.InDistance(ply:GetPos(), SeedBank:GetPos(), 200) then return end

    zwf.f.DeleteSeed(SeedDataID, SeedBank, ply)


    timer.Simple(0.1,function()
        if not IsValid(SeedBank) then return end
        if SeedBank:GetClass() ~= "zwf_seed_bank" then return end
        if not IsValid(ply) then return end
        if not ply:IsPlayer() then return end
        if not ply:Alive() then return end
        if not zwf.f.InDistance(ply:GetPos(), SeedBank:GetPos(), 200) then return end

        zwf.f.OpenSeedBank(ply, SeedBank)
    end)
end)
function zwf.f.DeleteSeed(SeedDataID, SeedBank, ply)
    if not IsValid(SeedBank) then return end

    zwf.f.Debug("zwf.f.DropSeed")
    zwf.f.Debug("SeedDataID: " .. SeedDataID)
    zwf.f.Debug("SeedBank: " .. tostring(SeedBank))

    if zwf.data.HasSeedDataID(ply, SeedDataID) then

        // Removes the seed from the seedbank
        zwf.data.RemoveSeedData(ply, SeedDataID)
    end
end



// ENTITY
function zwf.f.SeedBank_Initialize(SeedBank)
    zwf.f.EntList_Add(SeedBank)
    SeedBank.LastTouch = 0
end

function zwf.f.SeedBank_Touch(SeedBank, other)
    if SeedBank.LastTouch > CurTime() then return end

    if IsValid(SeedBank) then
        if zwf.f.CollisionCooldown(other) then return end
        if zwf.config.Sharing.Seeds == false and zwf.f.OwnerID_Check(SeedBank,other) == false then return end
        zwf.f.SeedBank_AddSeed(SeedBank, other)
    end

    SeedBank.LastTouch = CurTime() + 0.5
end

function zwf.f.SeedBank_USE(SeedBank, ply)
	if zwf.f.IsWeedSeller(ply) == false then return end
    if zwf.config.Sharing.Seeds == false and zwf.f.IsOwner(ply, SeedBank) == false then return end

    // Open seed interface
    zwf.f.OpenSeedBank(ply, SeedBank)
end

function zwf.f.SeedBank_AddSeed(SeedBank, SeedBox)

    local ply = zwf.f.GetOwner(SeedBank)

    if not IsValid(ply) then return end

    if zwf.f.IsSeedOwner(ply, SeedBox) == false then return end


    if table.Count(ply.zwf_seedbank) >= zwf.config.SeedBank.Limit then
        zwf.f.Notify(ply, zwf.language.General["seedbank_full"], 1)

        return
    end


    if IsValid(ply) then

        local seedData = {
            Weed_ID = SeedBox:GetSeedID(),
            Weed_Name = SeedBox:GetSeedName(),
            Perf_Time = SeedBox:GetPerf_Time(),
            Perf_Amount = SeedBox:GetPerf_Amount(),
            Perf_THC = SeedBox:GetPerf_THC(),
            SeedCount = SeedBox:GetSeedCount(),
        }

        zwf.data.AddSeedData(ply, seedData)

        SeedBox:Remove()
    end
end
