zwf = zwf or {}
zwf.f = zwf.f or {}

// Used for Debug
function zwf.f.Debug(mgs)
	if zwf.config.Debug then
		if istable(mgs) then
			print("[    DEBUG    ] Table Start >")
			PrintTable(mgs)
			print("[    DEBUG    ] Table End <")
		else
			print("[    DEBUG    ] " .. mgs)
		end
	end
end

function zwf.f.Debug_Sphere(pos,size,lifetime,color,ignorez)
	if zwf.config.Debug then
		debugoverlay.Sphere( pos, size, lifetime, color, ignorez )
	end
end

if SERVER then
    concommand.Add("zwf_debug_ent", function(ply, cmd, args)
        if zwf.f.IsAdmin(ply) then
            local tr = ply:GetEyeTrace()

            if tr.Hit and IsValid(tr.Entity) then
                if tr.Entity:GetClass() == "zwf_generator" then
                    print("Fuel: " .. tr.Entity:GetFuel())
                    print("AnimState: " .. tostring(tr.Entity:GetAnimState()))
                    print("Output: " .. tostring(tr.Entity:GetOutput()))
                elseif tr.Entity:GetClass() == "zwf_lamp" then
                    print("Power: " .. tr.Entity:GetPower())
                    print("Output: " .. tostring(tr.Entity:GetOutput()))
                elseif tr.Entity:GetClass() == "zwf_weedstick" then
                    print("Perf_Time: " .. tr.Entity.perf_time)
                    print("Perf_Amount: " .. tr.Entity.perf_amount)
                    print("Perf_THC: " .. tr.Entity.perf_thc)
                elseif tr.Entity:GetClass() == "zwf_jar" then
                    print("Perf_Time: " .. tr.Entity:GetPerf_Time())
                    print("Perf_Amount: " .. tr.Entity:GetPerf_Amount())
                    print("Perf_THC: " .. tr.Entity:GetPerf_THC())
                elseif tr.Entity:GetClass() == "zwf_ventilator" then
                    print("Power: " .. tr.Entity:GetPower())
                    print("Output: " .. tostring(tr.Entity:GetOutput()))
                    print("PowerSource: " .. tostring(tr.Entity:GetPowerSource()))
                elseif tr.Entity:GetClass() == "zwf_outlet" then
                    print("Power: " .. tr.Entity:GetPower())
                    print("PowerSource: " .. tostring(tr.Entity:GetPowerSource()))
                    print("Output01: " .. tostring(tr.Entity:GetOutput01()))
                    print("Output02: " .. tostring(tr.Entity:GetOutput02()))
                    print("Output03: " .. tostring(tr.Entity:GetOutput03()))
                elseif tr.Entity:GetClass() == "zwf_pot" or tr.Entity:GetClass() == "zwf_pot_hydro" then
                    print("Entity: " .. tostring(tr.Entity))
                    print("HasSoil: " .. tostring(tr.Entity:GetHasSoil()))
                    print("WaterSource: " .. tostring(tr.Entity:GetWaterSource()))
                    print("Output: " .. tostring(tr.Entity:GetOutput()))
                    print("Current_Water: " .. tr.Entity:GetWater())
                    print("PerfectProgress: " .. tr.Entity:GetPerfectProgress())

                    if tr.Entity:GetSeed() > 0 then
                        local grow_Data = zwf.config.Plants[tr.Entity:GetSeed()].Grow
                        local current_Water = tr.Entity:GetWater()
                        // Calculates the minimum water level we need to have in order to increase the YieldAmount
                        local MaxWaterLevel = 0.9 - ((0.4 / 10) * grow_Data.Difficulty)
                        MaxWaterLevel = math.Clamp(MaxWaterLevel, 0.5, 0.9)
                        MaxWaterLevel = MaxWaterLevel * zwf.config.Flowerpot.Water_Capacity
                        // Calculate the maximal water level allowed
                        local MinWaterLevel = 0.1 + (0.35 / 10) * grow_Data.Difficulty
                        MinWaterLevel = math.Clamp(MinWaterLevel, 0.1, 0.45)
                        MinWaterLevel = MinWaterLevel * zwf.config.Flowerpot.Water_Capacity
                        print("MaxWaterLevel: " .. MaxWaterLevel)
                        print("MinWaterLevel: " .. MinWaterLevel)
                        print("Current_Water: " .. current_Water)
                        zwf.f.Flowerpot_GetGrowPerformance(tr.Entity)
                    end
                end
            end
        end
    end)

    // Adds a seed with the provided data to the seedbank or player you are looking at
    // zwf_addseed Weed_ID Weed_Name Perf_Time Perf_Amount Perf_THC
    concommand.Add("zwf_addseed", function(ply, cmd, args)
        if zwf.f.IsAdmin(ply) then

            local tr = ply:GetEyeTrace()

            if tr.Hit and IsValid(tr.Entity) then

                local sb_owner

                if tr.Entity:GetClass() == "zwf_seed_bank" then
                    sb_owner = zwf.f.GetOwner(tr.Entity)
                elseif tr.Entity:IsPlayer() then
                    sb_owner = tr.Entity
                else
                    return
                end


                if not IsValid(sb_owner) then
                    zwf.f.Notify(ply, "This seedbank doesent have a owner!", 1)

                    return
                end



                if table.Count(sb_owner.zwf_seedbank) >= zwf.config.SeedBank.Limit then
                    zwf.f.Notify(ply, "Seedbank inventory limit reached!", 1)

                    return
                end


                local _weedid = tonumber(args[1])
                if _weedid == nil then
                    zwf.f.Notify(ply, "The provided weed id is not a number!", 1)

                    return
                end
                if zwf.config.Plants[_weedid] == nil then
                    zwf.f.Notify(ply, "The provided weed id doesent exist in the plant config!", 1)

                    return
                end



                local _weedname = tostring(args[2])
                if _weedname == "" or string.len(_weedname) < 3 then
                    zwf.f.Notify(ply, "The provided weed name is to short!", 1)

                    return
                end



                local _perftime = tonumber(args[3])
                if _perftime == nil then
                    zwf.f.Notify(ply, "The provided performance time is not a number!", 1)

                    return
                end



                local _perfamount = tonumber(args[4])
                if _perfamount == nil then
                    zwf.f.Notify(ply, "The provided performance amount is not a number!", 1)

                    return
                end



                local _perfthc = tonumber(args[5])
                if _perfthc == nil then
                    zwf.f.Notify(ply, "The provided performance thc is not a number!", 1)

                    return
                end


                // Here we calculate the % of the performance
                local weed_data = zwf.config.Plants[_weedid]
                _perftime = math.Round(200 - (100 / weed_data.Grow.Duration) * _perftime)
                _perfamount = math.Round((100 / weed_data.Grow.MaxYieldAmount) * _perfamount)
                _perfthc = math.Round((100 / weed_data.thc_level) * _perfthc,2)


                local seedData = {
                    Weed_ID = _weedid,
                    Weed_Name = _weedname,
                    Perf_Time = _perftime,
                    Perf_Amount = _perfamount,
                    Perf_THC = _perfthc,
                    SeedCount = zwf.config.Seeds.Count,
                }

                zwf.data.AddSeedData(sb_owner, seedData)

                zwf.f.Notify(ply, "Seed added!", 0)

            else
                zwf.f.Notify(ply, "You need to look at a seedbank or player!", 1)
            end
        end
    end)

	local weed_names = {"Dank Shit", "OG Flush", "Ocean Man", "Weed Me"}
	concommand.Add("zwf_debug_spawn_weedjars", function(ply, cmd, args)
		if zwf.f.IsAdmin(ply) then
			local tr = ply:GetEyeTrace()

			if tr.Hit and tr.HitPos then
				local ent = ents.Create("zwf_jar")
				ent:SetPos(tr.HitPos + Vector(0, 0, 10))
				ent:Spawn()
				ent:Activate()
				zwf.f.SetOwner(ent, ply)
				local weedID = math.random(1, table.Count(zwf.config.Plants))
				local name = weed_names[math.random(#weed_names)]
				ent:SetWeedAmount(math.Rand(100, 200))
				ent:SetPlantID(weedID)
				ent:SetTHC(math.Rand(15, 100))
				ent:SetPerf_Time(math.Rand(75, 200))
				ent:SetPerf_Amount(math.Rand(75, 200))
				ent:SetPerf_THC(math.Rand(75, 200))
				ent:SetWeedName(name)
			end
		end
	end)

	concommand.Add("zwf_debug_spawn_weedblock", function(ply, cmd, args)
		if zwf.f.IsAdmin(ply) then
			local tr = ply:GetEyeTrace()

			if tr.Hit and tr.HitPos then
				local ent = ents.Create("zwf_weedblock")
				ent:SetPos(tr.HitPos + Vector(0, 0, 10))
				ent:Spawn()
				ent:Activate()
				zwf.f.SetOwner(ent, ply)

				local weedID = math.random(1, table.Count(zwf.config.Plants))
				local name = weed_names[math.random(#weed_names)]

				ent:SetWeedID(weedID)
		        ent:SetTHC(math.Rand(15, 100))
		        ent:SetWeedName(name)
		        ent:SetWeedAmount(math.Rand(100, 200))
				ent.PlantID = weedID
			end
		end
	end)

	concommand.Add("zwf_debug_spawn_muffin", function(ply, cmd, args)
		if zwf.f.IsAdmin(ply) then
			local tr = ply:GetEyeTrace()

			if tr.Hit and tr.HitPos then

				local edible_data = zwf.config.Cooking.edibles[1]

				local ent = ents.Create("zwf_edibles")
				ent:SetPos(tr.HitPos + Vector(0, 0, 10))
				ent:Spawn()
				ent:SetModel(edible_data.edible_model)
				ent:Activate()
				zwf.f.SetOwner(ent, ply)

				ent.EdibleID = 1


				if math.random(100) > 50 then
					local weedID = math.random(1, table.Count(zwf.config.Plants))
					local name = weed_names[math.random(#weed_names)]
					ent.WeedID = weedID
					ent.WeedAmount = math.Rand(100, 200)
					ent.WeedTHC = math.Rand(15, 100)
					ent.WeedName = name
					ent:SetColor(zwf.config.Plants[weedID].color)
					ent:SetSkin(1)
				else
					ent:SetSkin(0)
					ent:SetColor(HSVToColor(math.random(0, 360), 0.5, 0.85))
				end
			end
		end
	end)

	concommand.Add("zwf_debug_spawn_brownie", function(ply, cmd, args)
		if zwf.f.IsAdmin(ply) then
			local tr = ply:GetEyeTrace()

			if tr.Hit and tr.HitPos then
				local edible_data = zwf.config.Cooking.edibles[2]

				local ent = ents.Create("zwf_edibles")
				ent:SetPos(tr.HitPos + Vector(0, 0, 10))
				ent:Spawn()
				ent:SetModel(edible_data.edible_model)
				ent:Activate()
				zwf.f.SetOwner(ent, ply)

				ent.EdibleID = 2

				if math.random(100) > 50 then
					local weedID = math.random(1, table.Count(zwf.config.Plants))
					local name = weed_names[math.random(#weed_names)]
					ent.WeedID = weedID
					ent.WeedAmount = math.Rand(100, 200)
					ent.WeedTHC = math.Rand(15, 100)
					ent.WeedName = name
					ent:SetColor(zwf.config.Plants[weedID].color)
					ent:SetSkin(1)
				else
					ent:SetSkin(0)
					ent:SetColor(HSVToColor(math.random(0, 360), 0.5, 0.85))
				end
			end
		end
	end)

    concommand.Add("zwf_debug_spawn_weedseeds", function(ply, cmd, args)
        if zwf.f.IsAdmin(ply) then
            local tr = ply:GetEyeTrace()

            if tr.Hit then

                for i = 1, 4 do
                    local ent = ents.Create("zwf_seed")
                    ent:SetPos(tr.HitPos + Vector(0, 0, 10) * i)
                    ent:Spawn()
                    ent:Activate()
                    zwf.f.SetOwner(ent, ply)

                    local seedID = math.random(1,#zwf.config.Plants)
                    local plantData = zwf.config.Plants[seedID]
                    ent:SetSeedID(seedID)

                    ent:SetPerf_Time(math.random(70,140))
                    ent:SetPerf_Amount(math.random(70,140))
                    ent:SetPerf_THC(math.random(70,140))

                    ent:SetSeedCount(zwf.config.Seeds.Count)

                    if plantData then
                        ent:SetSeedName(weed_names[math.random(#weed_names)])
                        ent:SetSkin(plantData.skin)
                    end
                end

            end
        end
    end)

    concommand.Add("zwf_debug_plant_ultraform", function(ply, cmd, args)
        if zwf.f.IsAdmin(ply) then
            local tr = ply:GetEyeTrace()

            if tr.Hit and IsValid(tr.Entity) and tr.Entity:GetClass() == "zwf_pot" or tr.Entity:GetClass() == "zwf_pot_hydro" then
                zwf.f.Flowerpot_UltraForm(tr.Entity, tonumber(args[1]))
            end
        end
    end)

    concommand.Add("zwf_debug_plant_growboost", function(ply, cmd, args)
        if zwf.f.IsAdmin(ply) then
            local tr = ply:GetEyeTrace()

            if tr.Hit and IsValid(tr.Entity) and tr.Entity:GetClass() == "zwf_pot" or tr.Entity:GetClass() == "zwf_pot_hydro" then
                tr.Entity:SetProgress(tr.Entity:GetProgress() + 50)
                tr.Entity:SetYieldAmount(tr.Entity:GetYieldAmount() + 50)
            end
        end
    end)


    concommand.Add("zwf_create_smoke", function(ply, cmd, args)
        if zwf.f.IsAdmin(ply) then
            zwf.f.SmokeEffect(1, 10, ply)
        end
    end)



    // GrowScene Save
    // Used for quickly saving and loading grow setups

    zwf.GrowScene_Data = {}

    concommand.Add("zwf_save_growscene", function(ply, cmd, args)
        if zwf.f.IsAdmin(ply) then
            zwf.f.GrowScene_Save(args[1])
        end
    end)

    concommand.Add("zwf_load_growscene", function(ply, cmd, args)
        if zwf.f.IsAdmin(ply) then
            zwf.f.GrowScene_Load(ply,args[1])
        end
    end)

    local zwf_ConnectionClass = {"zwf_generator","zwf_outlet","zwf_lamp","zwf_ventilator","zwf_watertank","zwf_pot_hydro"}

    function zwf.f.GrowScene_SaveMultiConnect(ent)
        local dataTable = {}

        local connectedEnt01 = ent:GetOutput01()
        local connectedEnt02 = ent:GetOutput02()
        local connectedEnt03 = ent:GetOutput03()

        local connectedID01 = -1
        local connectedID02 = -1
        local connectedID03 = -1


        if IsValid(connectedEnt01) then
            connectedID01 = connectedEnt01:EntIndex()
        end

        if IsValid(connectedEnt02) then
            connectedID02 = connectedEnt02:EntIndex()
        end

        if IsValid(connectedEnt03) then
            connectedID03 = connectedEnt03:EntIndex()
        end


        dataTable = {
            class = ent:GetClass(),
            pos = ent:GetPos(),
            ang = ent:GetAngles(),
            id = ent:EntIndex(),
            coID01 = connectedID01,
            coID02 = connectedID02,
            coID03 = connectedID03
        }

        return dataTable
    end

    function zwf.f.GrowScene_SaveAllMultiConnect(class)
        for k, v in pairs(zwf.EntList) do
            if IsValid(v) and v:GetClass() == class then

                local aTable = zwf.f.GrowScene_SaveMultiConnect(v)

                if aTable and table.Count(aTable) > 0 then

                    table.insert(zwf.GrowScene_Data, aTable)
                end
            end
        end
    end

    // Here we build our PipeLine Table
    function zwf.f.GrowScene_Build()

        zwf.GrowScene_Data = {}

        // Saves all Generic Entities
        for k, v in pairs(zwf.EntList) do
            if IsValid(v) and not table.HasValue(zwf_ConnectionClass,v:GetClass()) and v:GetClass() ~= "zwf_seed" and v:GetClass() ~= "zwf_nutrition" and v:GetClass() ~= "zwf_buyer_npc" then

                table.insert(zwf.GrowScene_Data, {
                    class = v:GetClass(),
                    pos = v:GetPos(),
                    ang = v:GetAngles(),
                    id = v:EntIndex()
                })
            end
        end

        // Saves all Connected Entities
        for k, v in pairs(zwf.EntList) do
            if IsValid(v) and table.HasValue(zwf_ConnectionClass,v:GetClass()) and v:GetClass() ~=  "zwf_outlet" then

                local connectedEnt = nil
                local connectedID = -1
                local extra_ID = -1

                if v:GetClass() == "zwf_generator" then
                    connectedEnt = v:GetOutput()
                elseif v:GetClass() == "zwf_ventilator" then
                    connectedEnt = v:GetOutput()
                elseif v:GetClass() == "zwf_lamp" then
                    connectedEnt = v:GetOutput()
                    extra_ID = v:GetLampID()
                elseif v:GetClass() == "zwf_watertank" then
                    connectedEnt = v:GetOutput()
                elseif v:GetClass() == "zwf_pot_hydro" then
                    connectedEnt = v:GetOutput()
                end


                if IsValid(connectedEnt) then
                    connectedID = connectedEnt:EntIndex()
                end

                if connectedEnt and connectedID ~= 1 then
                    table.insert(zwf.GrowScene_Data, {
                        class = v:GetClass(),
                        pos = v:GetPos(),
                        ang = v:GetAngles(),
                        id = v:EntIndex(),
                        coID = connectedID,
                        exID = extra_ID,
                    })
                end
            end
        end

        // Saves all the outles
        zwf.f.GrowScene_SaveAllMultiConnect("zwf_outlet")


        return zwf.GrowScene_Data
    end

    // Saves the GrowScene
    function zwf.f.GrowScene_Save(name)

        local data = zwf.f.GrowScene_Build()

        if not file.Exists("zwf", "DATA") then
            file.CreateDir("zwf")
        end
        if data and table.Count(data) > 0 then
            file.Write("zwf/" .. string.lower(game.GetMap()) .. "_growscene_" .. tostring(name) .. ".txt", util.TableToJSON(data))
        end
    end


    function zwf.f.GrowScene_FindConnectedEntByID(id, atable)
        local foundEnt = nil

        for k, v in pairs(atable) do
            if (v.PipeLine_ID == id) then
                foundEnt = v
                break
            end
        end

        return foundEnt
    end

    // Here we rebuild our Pipeline
    function zwf.f.GrowScene_Rebuild(ply,data)

        for k, v in pairs(zwf.EntList) do
            if IsValid(v) then
                v:Remove()
            end
        end

        local createdEnts = {}

        // Create the entites at the exact ang and pos
        // Also we tell them what their childs EntIndex are

        for k, v in pairs(data) do

            if v.class then

                local ent = ents.Create(v.class)
                ent:SetPos(v.pos)
                ent:SetAngles(v.ang)
                ent:Spawn()
                ent:Activate()

                if v.class == "zwf_lamp" and v.exID ~= nil and v.exID ~= -1 then
                    ent:SetLampID(v.exID)
                    ent:SetModel(zwf.config.Lamps[v.exID].model)
                end

                local phys = ent:GetPhysicsObject()
                if (phys:IsValid()) then
                    phys:Wake()
                    phys:EnableMotion(false)
                end


                zwf.f.SetOwner(ent, ply)

                if v.id then
                    ent.PipeLine_ID = v.id
                end

                if table.HasValue(zwf_ConnectionClass,v.class) then
                    if v.class == "zwf_outlet" then
                        ent.PipeLine_CoID01 = v.coID01
                        ent.PipeLine_CoID02 = v.coID02
                        ent.PipeLine_CoID03 = v.coID03
                    else
                        ent.PipeLine_CoID = v.coID
                    end
                end

                table.insert(createdEnts, ent)
            end
        end

        local foundEnt

        // Connect Normal Ents
        for k, v in pairs(createdEnts) do
            if IsValid(v) and v:GetClass() ~= "zwf_outlet" and v.PipeLine_CoID and v.PipeLine_CoID ~= -1 then
                foundEnt = zwf.f.GrowScene_FindConnectedEntByID(v.PipeLine_CoID, createdEnts)

                if IsValid(foundEnt) then
                    if v:GetClass() == "zwf_generator" then
                        v:SetOutput(foundEnt)
                        foundEnt:SetPowerSource(v)
                    elseif v:GetClass() == "zwf_ventilator" then
                        v:SetOutput(foundEnt)
                        foundEnt:SetPowerSource(v)
                    elseif v:GetClass() == "zwf_lamp" then
                        v:SetOutput(foundEnt)
                        foundEnt:SetPowerSource(v)
                    elseif v:GetClass() == "zwf_watertank" then
                        v:SetOutput(foundEnt)
                        foundEnt:SetWaterSource(v)
                    elseif v:GetClass() == "zwf_pot_hydro" then
                        v:SetOutput(foundEnt)
                        foundEnt:SetWaterSource(v)
                    end

                    net.Start("zwf_cable_update")
                    net.WriteEntity(v)
                    net.Broadcast()
                end
            end
        end



        // Connect Outlet Ents
        for k, v in pairs(createdEnts) do

            if v:GetClass() == "zwf_outlet" then

                local connectdID01 = v.PipeLine_CoID01
                local connectdID02 = v.PipeLine_CoID02
                local connectdID03 = v.PipeLine_CoID03

                if (connectdID01 ~= -1) then
                    foundEnt = zwf.f.GrowScene_FindConnectedEntByID(connectdID01, createdEnts)

                    if IsValid(foundEnt) then
                        v:SetOutput01(foundEnt)
                    end
                end

                if (connectdID02 ~= -1) then
                    foundEnt = zwf.f.GrowScene_FindConnectedEntByID(connectdID02, createdEnts)

                    if IsValid(foundEnt) then
                        v:SetOutput02(foundEnt)
                    end
                end

                if (connectdID03 ~= -1) then
                    foundEnt = zwf.f.GrowScene_FindConnectedEntByID(connectdID03, createdEnts)

                    if IsValid(foundEnt) then
                        v:SetOutput03(foundEnt)
                    end
                end

                net.Start("zwf_cable_update" )
                    net.WriteEntity(v)
                net.Broadcast()
            end
        end



        // Special stuff for ents
        for k, v in pairs(createdEnts) do
            if IsValid(v) then

                if v:GetClass() == "zwf_generator" then
                    //v.UtraForm = false
                    v:SetFuel(zwf.config.Generator.Fuel_Capacity)
                    v:SetAnimState(1)
                elseif v:GetClass() == "zwf_ventilator" then
                    v:SetIsRunning(true)
                elseif v:GetClass() == "zwf_lamp" then
                    v:SetIsRunning(true)
                elseif v:GetClass() == "zwf_pot" then

                    v.CutCount = 3
                    v:SetHasSoil(true)
                    v:SetWater(zwf.config.Flowerpot.Water_Capacity / 2)

                    local seedID = math.random(1,table.Count(zwf.config.Plants))

                    local seedData = {
                        seedID = seedID ,
                        perf_time = math.Rand(100,120),
                        perf_amount = math.Rand(100,120),
                        perf_thc = math.Rand(100,120),
                        seedname = zwf.config.Plants[seedID].name,
                    }

                    zwf.f.Flowerpot_AddSeed(v,seedData)

                    zwf.f.Flowerpot_UltraForm(v,math.random(300,800))
                elseif v:GetClass() == "zwf_pot_hydro" then

                    local seedID = math.random(1,table.Count(zwf.config.Plants))

                    local seedData = {
                        seedID = seedID,
                        perf_time = math.Rand(100,120),
                        perf_amount = math.Rand(100,120),
                        perf_thc = math.Rand(100,120),
                        seedname = zwf.config.Plants[seedID].name,
                    }

                    zwf.f.Flowerpot_AddSeed(v,seedData)


                    zwf.f.Flowerpot_UltraForm(v,math.random(300,800))
                end
            end
        end
    end


    function zwf.f.GrowScene_Load(ply,name)
        local path = "zwf/" .. string.lower(game.GetMap()) .. "_growscene_" .. tostring(name) .. ".txt"
        if file.Exists(path, "DATA") then
            local data = file.Read(path, "DATA")
            data = util.JSONToTable(data)

            if data and table.Count(data) > 0 then
                zwf.f.GrowScene_Rebuild(ply,data)
            end
        end
    end
end

if CLIENT then
    concommand.Add("zwf_debug_shop_close", function(ply, cmd, args)
        if IsValid(ply) and IsValid(zwf_ShopMenu_panel) then
            zwf_ShopMenu_panel:Remove()
        end
    end)
end
