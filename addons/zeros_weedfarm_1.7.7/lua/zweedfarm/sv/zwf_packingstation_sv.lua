if CLIENT then return end
zwf = zwf or {}
zwf.f = zwf.f or {}

function zwf.f.PackingStation_Initialize(station)
    station.JarData = {}
    zwf.f.EntList_Add(station)
end

function zwf.f.PackingStation_AddJar(station,jar)

    if zwf.config.Sharing.Packing == false and zwf.f.OwnerID_Check(station,jar) == false then return end

    if station:GetJarCount() >= 4 then return end

    if station:GetPlantID() == -1 then
        station:SetPlantID(jar:GetPlantID())
        station:SetWeedName(jar:GetWeedName())
        local plantData = zwf.config.Plants[jar:GetPlantID()]

        station:SetSkin(plantData.skin)

    elseif jar:GetPlantID() ~= station:GetPlantID()  then
        // If the weed isnt the same sort we have on our packing station then we make it to a mix

        station:SetPlantID(1)
        station:SetWeedName(zwf.language.General["packingstation_weedmix"])
        station:SetSkin(0)
        //return
    end

    station:SetJarCount(station:GetJarCount() + 1)


    station.JarData[station:GetJarCount()] = {
        weedid = jar:GetPlantID(),
        weedname = jar:GetWeedName(),
        thc = jar:GetTHC(),
        amount = jar:GetWeedAmount(),
        perf_time = jar:GetPerf_Time(),
        perf_amount = jar:GetPerf_Amount(),
        perf_thc = jar:GetPerf_THC(),
    }


    jar:Remove()
    zwf.f.CreateNetEffect("zwf_place_jar",station)

    // Start Packing Game
    if station:GetJarCount() >= 4 then
        zwf.f.PackingStation_StartGame(station)
    end
end

function zwf.f.PackingStation_RemoveJars(station)

    station:SetJarCount(0)
    station:SetPlantID(-1)
    zwf.f.CreateNetEffect("zwf_place_jar",station)

    for k, v in pairs(station.JarData) do
        if v.weedid ~= nil then

            local ent = ents.Create("zwf_jar")
        	ent:SetPos(station:GetPos() + station:GetForward() * -(35 + (15 * k)) + station:GetUp() * 5)
        	ent:Spawn()
        	ent:Activate()

            zwf.f.SetOwnerByID(ent, zwf.f.GetOwnerID(station))

            ent:SetWeedAmount(v.amount)
            ent:SetPlantID(v.weedid)
            ent:SetTHC(v.thc)

            ent:SetPerf_Time(v.perf_time)
            ent:SetPerf_Amount(v.perf_amount)
            ent:SetPerf_THC(v.perf_thc)

            ent:SetWeedName(v.weedname)
        end
    end

    station.JarData = {}
end


function zwf.f.PackingStation_InstallAutopacker(station,autopacker)
    if zwf.config.Sharing.Packing == false and zwf.f.OwnerID_Check(station,autopacker) == false then return end

    if station:GetGameStage() > 0 then return end

    station:SetAutoPacker(true)
    station:SetBodygroup(2,1)
    SafeRemoveEntity( autopacker )
end

function zwf.f.PackingStation_StartGame(station)
    station:SetGameStage(1)

    if station:GetAutoPacker() == false then
        zwf.f.PackingStation_SetGamePos(station)
    else

        // If a autopacker is installed then we create a timer for automatic packing

        local timerName = "autopacker_timer_" .. station:EntIndex()
        timer.Create(timerName, 0.5, 0, function()
            if IsValid(station) then
                if station:GetGameStage() >= math.Clamp(zwf.config.PackingStation.PackingCount,7,99) then

                    if timer.Exists(timerName) then
                        timer.Remove(timerName)
                    end

                    zwf.f.PackingStation_SpawnWeedBlock(station)
                else
                    zwf.f.PackingStation_IncreaseStage(station)
                end
            else
                if timer.Exists(timerName) then
                    timer.Remove(timerName)
                end
            end
        end)
    end
end

function zwf.f.PackingStation_SetGamePos(station)

    station:SetGamePos(Vector(-17, math.random(-15,15), 41))
end


function zwf.f.PackingStation_IncreaseStage(station)
    station:SetGameStage(station:GetGameStage() + 1)
end

function zwf.f.PackingStation_HitGamePos(station,ply)
    zwf.f.PackingStation_IncreaseStage(station)

    local cStage = station:GetGameStage()

    if cStage > math.Clamp(zwf.config.PackingStation.PackingCount,7,99) then
        zwf.f.PackingStation_SpawnWeedBlock(station)
    else

        zwf.f.PackingStation_SetGamePos(station)
    end
end

function zwf.f.PackingStation_SpawnWeedBlock(station)
    local ent = ents.Create("zwf_weedblock")
    ent:SetPos(station:GetPos() + station:GetUp() * 55)
    ent:SetAngles(station:GetAngles())
    ent:Spawn()
    ent:Activate()
	ent:CPPISetOwner(station:CPPIGetOwner())
    ent:SetWeedID(station:GetPlantID())
    ent:SetWeedName(station:GetWeedName())

    local weedAmount = 0

    // Here we calculate the average THC Level between the jars
    local avg_thc = 0
    for k, v in pairs(station.JarData) do
        avg_thc = avg_thc + v.thc
        weedAmount = weedAmount + v.amount
    end
    avg_thc = math.Round(avg_thc / 4,2)
    ent:SetTHC(avg_thc)

    ent:SetWeedAmount(weedAmount)

    zwf.f.SetOwnerByID(ent, zwf.f.GetOwnerID(station))

    zwf.f.PackingStation_Reset(station)
end

function zwf.f.PackingStation_Reset(station)
    station:SetPlantID(-1)
    station:SetWeedName("NILL")
    station:SetJarCount(0)
    station:SetGamePos(Vector(0, 0, 0))
    station:SetGameStage(-1)
    station.JarData = {}
end

function zwf.f.PackingStation_USE(station, ply)

    if zwf.config.Sharing.Packing == false and zwf.f.IsOwner(ply, station) == false then return end


    local stage = station:GetGameStage()

    // Remove weed jars
    if station:OnRemoveButton(ply) and station:GetJarCount() > 0 and (stage == 0 or stage == -1) then

        zwf.f.PackingStation_RemoveJars(station)

    elseif stage > 0 and station:OnHitButton(ply) and station:GetAutoPacker() == false then

        zwf.f.PackingStation_HitGamePos(station, ply)
    end
end

function zwf.f.PackingStation_Touch(station, other)
    if zwf.f.CollisionCooldown(other) then return end

    if IsValid(other) then
        if other:GetClass() == "zwf_jar" and other:GetWeedAmount() > 0 then
            zwf.f.PackingStation_AddJar(station, other)
        elseif other:GetClass() == "zwf_autopacker" and station:GetAutoPacker() == false then
            zwf.f.PackingStation_InstallAutopacker(station, other)
        end
    end
end
