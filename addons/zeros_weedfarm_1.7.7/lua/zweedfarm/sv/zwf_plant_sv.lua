if not SERVER then return end

zwf = zwf or {}
zwf.f = zwf.f or {}

zwf.Flowerpots = zwf.Flowerpots or {}

// Adds the flowerpot to the list
function zwf.f.AddFlowerPot(Flowerpot)
	table.insert(zwf.Flowerpots, Flowerpot)
end

// Initializeses the Flowerpot
function zwf.f.Flowerpot_Initialize(Flowerpot)
	zwf.f.AddFlowerPot(Flowerpot)
	zwf.f.EntList_Add(Flowerpot)
	zwf.f.PowerEntList_Add(Flowerpot)
	Flowerpot.LastRessourceUse = -1
	Flowerpot.LastHigh_Progress = -1

	Flowerpot.PlantData = nil

	Flowerpot.Grow_Duration = -1
	Flowerpot.Grow_Amount = -1
	Flowerpot.Grow_THC = -1

	Flowerpot.Grow_Start = -1
	Flowerpot.Grow_Finish = -1

	Flowerpot.Unhappy_time = -1

	Flowerpot.UtraForm = false

	Flowerpot.LastInfection = 1
end



// Gets called when something is touching the flowerpot
function zwf.f.Flowerpot_OnTouch(Flowerpot,other)

	if not IsValid(Flowerpot) or not IsValid(other) then return end

	if zwf.f.CollisionCooldown(other) then return end

	local pot_owner = zwf.f.GetOwner(Flowerpot)

	if not IsValid(pot_owner) then return end

	local HasSoil = Flowerpot:GetHasSoil()
	local SeedID = Flowerpot:GetSeed()

	if other:GetClass() == "zwf_soil" and HasSoil == false then

		Flowerpot:SetHasSoil(true)
		SafeRemoveEntity(other)

	elseif other:GetClass() == "zwf_seed" and SeedID == -1 and HasSoil and zwf.f.IsSeedOwner(pot_owner, other) then

		zwf.f.Flowerpot_AddSeedEnt(Flowerpot,other)

	elseif other:GetClass() == "zwf_nutrition" and HasSoil then
		if zwf.config.Sharing.Fertilizer == false and zwf.f.OwnerID_Check(Flowerpot,other) == false then return end

		if zwf.f.Flowerpot_CanNutrition(Flowerpot) then

			zwf.f.Flowerpot_AddNutrition(Flowerpot,other)
		end
	end
end


function zwf.f.Flowerpot_USE(Flowerpot,plant,ply)
	if not IsValid(Flowerpot) then return end
	if not IsValid(plant) then return end
	if zwf.f.IsWeedSeller(ply) == false then return end
	if zwf.f.IsPlantOwner(ply, plant) == false then return end

	if Flowerpot:GetHasPlague() then
		zwf.f.Plague_HealPlant(Flowerpot,ply)
	elseif Flowerpot:GetHarvestReady() then
		zwf.f.Flowerpot_CuttingAction(ply,plant, Flowerpot)
	end
end





// Creates a plant entity
function zwf.f.Flowerpot_SpawnPlant(Flowerpot,seedid)
	local ent = ents.Create("zwf_plant")
	ent:SetPos(Flowerpot:GetPos())
	ent:SetAngles(Flowerpot:GetAngles())
	ent:Spawn()
	ent:Activate()
	ent:SetParent(Flowerpot)

	zwf.f.SetOwner(ent, zwf.f.GetOwner(Flowerpot))

	local phys = ent:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(true)
	end
	ent.PhysgunDisabled = true
	Flowerpot.Plant = ent
	ent.Flowerpot = Flowerpot
end


// Adds a plant seed
function zwf.f.Flowerpot_AddSeedEnt(Flowerpot,seed)

	local seedData = {
		seedID = seed:GetSeedID(),
		perf_time = seed:GetPerf_Time(),
		perf_amount = seed:GetPerf_Amount(),
		perf_thc = seed:GetPerf_THC(),
		seedname = seed:GetSeedName(),
	}

	zwf.f.Flowerpot_AddSeed(Flowerpot,seedData)


	local seedCount = seed:GetSeedCount() - 1

	if seedCount <= 0 then
		SafeRemoveEntity(seed)
	else
		seed:SetSeedCount(seedCount)
	end
end
function zwf.f.Flowerpot_AddSeed(Flowerpot,data)
	local seedID = data.seedID

	Flowerpot:SetSeed(seedID)

	Flowerpot:SetPerf_Time(data.perf_time)
	Flowerpot:SetPerf_Amount(data.perf_amount)
	Flowerpot:SetPerf_THC(data.perf_thc)

	Flowerpot:SetSeedName(data.seedname)

	Flowerpot.PlantData = zwf.config.Plants[seedID]

	zwf.f.Flowerpot_SpawnPlant(Flowerpot,seedID)

	local growBoost = Flowerpot:GetPerf_Time() - 100
	zwf.f.Debug("growBoost: " .. growBoost)

	local grow_Duration = Flowerpot.PlantData.Grow.Duration * (1 - ((1 / 100) * growBoost))
	grow_Duration = math.Clamp(grow_Duration,zwf.f.Flowerpot_GetMinGrowDuration(Flowerpot),99999999)
	zwf.f.Debug("grow_Duration: " .. grow_Duration)
	Flowerpot.Grow_Duration = grow_Duration

	local grow_Amount = Flowerpot.PlantData.Grow.MaxYieldAmount * ((1 / 100) * Flowerpot:GetPerf_Amount())
	grow_Amount = math.Clamp(grow_Amount,1,zwf.config.Growing.max_amount)
	zwf.f.Debug("grow_Amount: " .. grow_Amount)
	Flowerpot.Grow_Amount = grow_Amount

	local grow_THC = Flowerpot.PlantData.thc_level * ((1 / 100) * Flowerpot:GetPerf_THC())
	grow_THC = math.Clamp(grow_THC,1,zwf.config.Growing.max_thc)
	zwf.f.Debug("grow_THC: " .. grow_THC)
	Flowerpot.Grow_THC = grow_THC
end



// Waters the plant
function zwf.f.Flowerpot_Watering(Flowerpot,Water)

	if zwf.f.Flowerpot_CanWaterPlant(Flowerpot) then

		Flowerpot:SetWater(Flowerpot:GetWater() + Water)
	end
end

// Tells us if we can water the plant
function zwf.f.Flowerpot_CanWaterPlant(Flowerpot)
	return Flowerpot:GetWater() <  zwf.config.Flowerpot.Water_Capacity
end

function zwf.f.Flowerpot_UseWater(Flowerpot)
	local c_Water = Flowerpot:GetWater()
	local water_Usage = 1
	local grow_Data = Flowerpot.PlantData.Grow

	// If the plant is over waterd and the Difficulty is low then we remove more water to make it easier for the player
	if grow_Data.Difficulty < 5 then
		local _ , MaxWaterLevel = zwf.f.Flowerpot_GetWaterLevels(Flowerpot)
		if c_Water > MaxWaterLevel then
			water_Usage = 5
		end
	end
	Flowerpot:SetWater(Flowerpot:GetWater() - water_Usage)
end




// Adds Nutrition to the plant
function zwf.f.Flowerpot_AddNutrition(Flowerpot,Nutrition)

	if zwf.f.Flowerpot_CanNutrition(Flowerpot) then

		Flowerpot:SetNutritionID(Nutrition:GetNutritionID())

		SafeRemoveEntity(Nutrition)
	end
end

// Tells us if we can add nutrition the plant
function zwf.f.Flowerpot_CanNutrition(Flowerpot)
	return Flowerpot:GetNutritionID() == -1
end

// Uses the nutrition
function zwf.f.Flowerpot_GetNutritionBoost(Flowerpot)

	local nutData = zwf.config.Nutrition[Flowerpot:GetNutritionID()]

	local boosts = {
		b_speed = 0,
		b_amount = 0,
		b_plague = 0
	}

	if nutData then
		for k, v in pairs(nutData.boost) do
			if v.b_type == 1 then
				boosts.b_speed = boosts.b_speed + v.b_amount

			elseif v.b_type == 2 then

				boosts.b_amount = boosts.b_amount + v.b_amount

			elseif v.b_type == 3 then

				boosts.b_plague = boosts.b_plague + v.b_amount

			end
		end
	end

	return boosts
end



function zwf.f.Flowerpot_Logic()
	for k, v in pairs(zwf.Flowerpots) do
		if IsValid(v) then

			zwf.f.Flowerpot_MainLogic(v)

			// If the flowerpot has light then we remove some no matter what
			if v:GetLight() > 0 then
				v:SetLight(v:GetLight() - 1)
			end
		end
	end
end

// The Core logic of the plant
function zwf.f.Flowerpot_MainLogic(Flowerpot)

	// If the flowerpot has a seed then we grow it
	if zwf.f.Flowerpot_CanGrow(Flowerpot) then

		if Flowerpot.UtraForm == true then return end
		local _harvestready = Flowerpot:GetHarvestReady()

		if zwf.config.Growing.PostGrow.Enabled then
			zwf.f.Flowerpot_KillLogic(Flowerpot)
		else
			if _harvestready == false then
				zwf.f.Flowerpot_KillLogic(Flowerpot)
			end
		end


		if Flowerpot:GetWater() > 0 then

			if _harvestready then

				if zwf.config.Growing.PostGrow.Enabled then

					zwf.f.Flowerpot_PostGrow(Flowerpot)
				end
			else
				zwf.f.Flowerpot_Grow(Flowerpot)
			end
		end
	end
end

// Checks if the plant is ready to grow
function zwf.f.Flowerpot_CanGrow(Flowerpot)
	local canGrow = false
	local seedID = Flowerpot:GetSeed()

	if seedID ~= -1 then
		canGrow = true
	end

	return canGrow
end

// Kills the plants if its too long unahppy
function zwf.f.Flowerpot_KillLogic(Flowerpot)

	local MinWaterLevel , MaxWaterLevel = zwf.f.Flowerpot_GetWaterLevels(Flowerpot)
	local current_Water = Flowerpot:GetWater()

	local _temperatur = Flowerpot:GetTemperatur()
	local _light = Flowerpot:GetLight()
	local _plague = Flowerpot:GetHasPlague()

	if current_Water < MinWaterLevel or current_Water > MaxWaterLevel or _temperatur > 25 or _light <= 0 or _plague then

		Flowerpot.Unhappy_time = Flowerpot.Unhappy_time + 1

		zwf.f.Debug("Flowerpot.Unhappy_time: " .. Flowerpot.Unhappy_time)
	else
		Flowerpot.Unhappy_time = -1
	end


	if Flowerpot.Unhappy_time > zwf.config.Growing.kill_time then

		local _seed = Flowerpot:GetSeed()

		// Kill plant
		if _seed ~= -1 then
			zwf.f.CreateEffectTable(zwf.config.Plants[_seed].death_effect, "zwf_cut_plant", Flowerpot, Flowerpot:GetAngles(), Flowerpot:GetPos() + Flowerpot:GetUp() * 35, nil)
		end


		if IsValid(Flowerpot.Plant) then
			Flowerpot.Plant:Remove()
		end

		zwf.f.Flowerpot_Reset(Flowerpot)

		hook.Run("zwf_OnPlantDeath" ,Flowerpot)
	end
end

// The Main grow function
function zwf.f.Flowerpot_Grow(Flowerpot)

	if Flowerpot.PlantData == nil then return end

	local grow_Data = Flowerpot.PlantData.Grow

	local MinWaterLevel , MaxWaterLevel = zwf.f.Flowerpot_GetWaterLevels(Flowerpot)
	local current_Water = Flowerpot:GetWater()

	local _temperatur = Flowerpot:GetTemperatur()
	local _light = Flowerpot:GetLight()
	local _plague = Flowerpot:GetHasPlague()

	// Here we use up some water
	if CurTime() > Flowerpot.LastRessourceUse and _light > 0  then
		zwf.f.Flowerpot_UseWater(Flowerpot)
		Flowerpot.LastRessourceUse = CurTime() + math.Clamp(10 / grow_Data.Difficulty,1,15)
	end


	// If the plant is a third done with its growth and it has less then a third of water or its overheated then we decrease the process
	if current_Water < MinWaterLevel or current_Water > MaxWaterLevel or _temperatur > 25 or _light <= 0 or _plague  then
		Flowerpot:SetProgress(math.Clamp(Flowerpot:GetProgress() - 1,0,999999))
	else

		//Speedboost from nutrition
		local boosts = zwf.f.Flowerpot_GetNutritionBoost(Flowerpot)
		local growProgress = 1 + (1 / 100) * boosts.b_speed

		Flowerpot:SetProgress(Flowerpot:GetProgress() + growProgress)

		// This tells use when the plant started to grow so we can later calculate the time it took to finish the grow cycle
		if Flowerpot.Grow_Start == -1 then
			Flowerpot.Grow_Start = CurTime()
		end

		// This increases the perfect progress bar to tell us the plant is very happy since everything is perfect
		local water_mid = zwf.config.Flowerpot.Water_Capacity / 2
		if current_Water > (water_mid - 5) and current_Water < (water_mid + 5) and  _temperatur < 6 then
			Flowerpot:SetPerfectProgress(Flowerpot:GetPerfectProgress() + growProgress)
			//zwf.f.Debug("Flowerpot[" .. Flowerpot:EntIndex() .. "] PerfectProgress: " .. Flowerpot:GetPerfectProgress())
		end

		// Saves the last highest progress
		if Flowerpot:GetProgress() > Flowerpot.LastHigh_Progress then
			Flowerpot.LastHigh_Progress = Flowerpot:GetProgress()
		end
	end


	// Updates the final weed YieldAmount
	if _light > 0 and _plague == false then
		zwf.f.Flowerpot_UpdateYieldAmount(Flowerpot)
	end

	// Checks if the plant is harvest ready
	if Flowerpot:GetProgress() >= Flowerpot.Grow_Duration then
		zwf.f.Flowerpot_HarvestReady(Flowerpot)
	end

	//zwf.f.Debug("Flowerpot[" .. Flowerpot:EntIndex() .. "] Progress: " .. Flowerpot:GetProgress())
end

// The grow function after we finished the main grow cyle
function zwf.f.Flowerpot_PostGrow(Flowerpot)

	if Flowerpot:GetYieldAmount() >= zwf.config.Growing.max_amount then
		return
	end


	if Flowerpot.PlantData == nil then return end


	local grow_Data = Flowerpot.PlantData.Grow

	local MinWaterLevel , MaxWaterLevel = zwf.f.Flowerpot_GetWaterLevels(Flowerpot)
	local current_Water = Flowerpot:GetWater()

	local _temperatur = Flowerpot:GetTemperatur()
	local _light = Flowerpot:GetLight()
	local _plague = Flowerpot:GetHasPlague()


	// Here we use up some water
	if CurTime() > Flowerpot.LastRessourceUse and _light > 0  then

		zwf.f.Flowerpot_UseWater(Flowerpot)
		Flowerpot.LastRessourceUse = CurTime() + math.Clamp(10 / grow_Data.Difficulty,3,15)
	end


	if Flowerpot.LastPostGrow == nil then Flowerpot.LastPostGrow = CurTime() end
	if CurTime() > Flowerpot.LastPostGrow and _light > 0  then
		Flowerpot.LastPostGrow = CurTime() + zwf.config.Growing.PostGrow.increment_interval
	else
		return
	end

	if _light > 0 and _plague == false and current_Water > MinWaterLevel and current_Water < MaxWaterLevel and _temperatur < 6 then

		Flowerpot:SetYieldAmount( math.Clamp(Flowerpot:GetYieldAmount() + zwf.config.Growing.PostGrow.increment_amount,0,zwf.config.Growing.max_amount))

		zwf.f.Flowerpot_UpdateCutCount(Flowerpot)
	end
end



// Updates the harvest amount
function zwf.f.Flowerpot_UpdateYieldAmount(Flowerpot)
	local current_Water = Flowerpot:GetWater()

	//WeedAmount Boost from nutrition
	local boosts = zwf.f.Flowerpot_GetNutritionBoost(Flowerpot)

	local YieldImpact = math.Round(Flowerpot.Grow_Amount / Flowerpot.Grow_Duration, 1)

	// Reduce YieldImpact if we have a speedboost
	YieldImpact = YieldImpact + (YieldImpact / 100) * boosts.b_speed

	// Increase YieldImpact if we have a amount boost
	YieldImpact = YieldImpact + (YieldImpact / 100) * boosts.b_amount

	local MinWaterLevel , MaxWaterLevel = zwf.f.Flowerpot_GetWaterLevels(Flowerpot)

	// This can increase or decrease the YieldAmount
	if current_Water > MinWaterLevel and current_Water < MaxWaterLevel and Flowerpot:GetProgress() >= Flowerpot.LastHigh_Progress then

		// If the current grow progress is higher then last high progress then we are allowed to update the YieldAmount again
		// This means that if the progress did go down for a while we wont influence the YieldAmount till its back where it stoped increasing
		// That way players cant fuck with it to increase the end YieldAmount
		Flowerpot:SetYieldAmount( math.Clamp(math.Round(Flowerpot:GetYieldAmount() + YieldImpact,1),0,zwf.config.Growing.max_amount))
	end

	//zwf.f.Debug("Flowerpot[" .. Flowerpot:EntIndex() .. "] YieldAmount: " .. math.Round(Flowerpot:GetYieldAmount()))
end

// Called when the plant its harvest ready
function zwf.f.Flowerpot_HarvestReady(Flowerpot)

	if IsValid(Flowerpot) then
		zwf.f.Flowerpot_UpdateCutCount(Flowerpot)
		Flowerpot:SetHarvestReady(true)
		Flowerpot.Grow_Finish = CurTime()
		Flowerpot.Grow_WeedAmount_At_Finish = math.Round(Flowerpot:GetYieldAmount())

		hook.Run("zwf_OnPlantHarvestReady" ,Flowerpot)
	end
end

// Returns a table with informations about the current grow, [GrowTime,WeedAmount,THCLevel] in Percentage
function zwf.f.Flowerpot_GetGrowPerformance(Flowerpot)
	local boosts = zwf.f.Flowerpot_GetNutritionBoost(Flowerpot)


	// The time it should have taken to grow the plant
	local gTime = Flowerpot.PlantData.Grow.Duration - (Flowerpot.PlantData.Grow.Duration / 100) * boosts.b_speed

	// The real time it took to grow the plant
	local realGrowTime = math.Round(Flowerpot.Grow_Finish - Flowerpot.Grow_Start)


	// The amount the plant should have produced acording to the boosts
	local gAmount = Flowerpot.PlantData.Grow.MaxYieldAmount + (Flowerpot.PlantData.Grow.MaxYieldAmount / 100) * boosts.b_amount



	// The real amount the plant produced
	local realGrowAmount = Flowerpot.Grow_WeedAmount_At_Finish

	local FinalTHC = Flowerpot.Grow_THC
	FinalTHC = FinalTHC + (math.random(1,math.Round(zwf.config.THC.MaxIncrease)) / Flowerpot.Grow_Duration) * Flowerpot:GetPerfectProgress()
	FinalTHC = math.Clamp(math.Round(FinalTHC),1,zwf.config.THC.Max)

	zwf.f.Debug("_______________________________")
	zwf.f.Debug("Flowerpot[" .. Flowerpot:EntIndex() .. "] Finished growing!")
	zwf.f.Debug("Flowerpot[" .. Flowerpot:EntIndex() .. "] Default GrowTime: " .. Flowerpot.PlantData.Grow.Duration)
	zwf.f.Debug("Flowerpot[" .. Flowerpot:EntIndex() .. "] GrowTime: " .. gTime)
	zwf.f.Debug("Flowerpot[" .. Flowerpot:EntIndex() .. "] Real GrowTime: " .. realGrowTime .. "s")
	zwf.f.Debug("Flowerpot[" .. Flowerpot:EntIndex() .. "] Default WeedAmount: " .. Flowerpot.PlantData.Grow.MaxYieldAmount)
	zwf.f.Debug("Flowerpot[" .. Flowerpot:EntIndex() .. "] WeedAmount: " .. gAmount)
	zwf.f.Debug("Flowerpot[" .. Flowerpot:EntIndex() .. "] Real WeedAmount: " .. realGrowAmount .. zwf.config.UoW)
	zwf.f.Debug("Flowerpot[" .. Flowerpot:EntIndex() .. "] Default THC: " .. Flowerpot.PlantData.thc_level)
	zwf.f.Debug("Flowerpot[" .. Flowerpot:EntIndex() .. "] Final THC: " .. FinalTHC)
	zwf.f.Debug("_______________________________")


	// Here we calculate the peformance improvement from a range between 0-200% , 100% = no change
	local plantData = zwf.config.Plants[Flowerpot:GetSeed()]

	local gTime_Improve = realGrowTime - plantData.Grow.Duration
	gTime_Improve = (100 / plantData.Grow.Duration) * gTime_Improve
	gTime_Improve = math.Round(100 - gTime_Improve)
	local gTime_Cap = 200 - (100 / plantData.Grow.Duration) * zwf.f.Flowerpot_GetMinGrowDuration(Flowerpot)
	gTime_Improve = math.Clamp(gTime_Improve,50,gTime_Cap)

	local wAmount_Improve = math.Round((100 / plantData.Grow.MaxYieldAmount) * realGrowAmount)
	local wAmount_Cap = (100 / plantData.Grow.MaxYieldAmount) * zwf.config.Growing.max_amount
	wAmount_Improve = math.Clamp(wAmount_Improve,50,wAmount_Cap)


	local thcLevel_Improve = math.Round((100 / plantData.thc_level) * FinalTHC,2)
	local thcLevel_Cap = (100 / plantData.thc_level) * zwf.config.Growing.max_thc
	thcLevel_Improve = math.Clamp(thcLevel_Improve,50,thcLevel_Cap)



	// Calculates the improvement values in %
	local GrowData = {
		Grow_Time = gTime_Improve,
		Weed_Amount = wAmount_Improve,
		THC_Level = thcLevel_Improve,
	}

	//PrintTable(GrowData)

	zwf.f.Debug(GrowData)

	return GrowData
end



// Updates the Cut Count
function zwf.f.Flowerpot_UpdateCutCount(Flowerpot)

	// This updates the cut count so it increases accordingly to the weedamount
	Flowerpot.CutCount = math.Clamp(math.Round(Flowerpot:GetYieldAmount() / zwf.config.Harvest.Count),zwf.config.Harvest.Min,zwf.config.Harvest.Max)
end

// Called when the player cuts aways the leafs of the plant
function zwf.f.Flowerpot_CuttingAction(ply,Plant,Flowerpot)

	local tr = ply:GetEyeTrace()

	if tr.Hit == false then return end

	local plantData = Flowerpot.PlantData


	// Make cut effect here
	zwf.f.CreateEffectTable(plantData.cut_effect, "zwf_cut_plant", Flowerpot, Flowerpot:GetAngles(), tr.HitPos, nil)

	Flowerpot.CutCount = Flowerpot.CutCount - 1

	if Flowerpot.CutCount <= 0 then
		// Plant is cut now and should be transformed to weed sticks that should be ready to dry

		local weedAmount = Flowerpot:GetYieldAmount()

		if weedAmount > 0 then


			local GrowPerfData = zwf.f.Flowerpot_GetGrowPerformance(Flowerpot)

			// Here we calculate the THC level of the final weed
			// If the plant got pefectly grown for most of its grow time then we give it a bonus
			local finalTHC = Flowerpot.Grow_THC

			zwf.f.Debug("Plant THC: " .. finalTHC .. "%")

			finalTHC = finalTHC + (math.random(1,math.Round(zwf.config.THC.MaxIncrease)) / Flowerpot.Grow_Duration) * Flowerpot:GetPerfectProgress()
			finalTHC = math.Clamp(math.Round(finalTHC,2),1,zwf.config.THC.Max)

			zwf.f.Debug("Final THC: " .. finalTHC .. "%")

			while weedAmount > 0 do
				local ent = ents.Create("zwf_weedstick")
				ent:SetPos(Flowerpot:GetPos() + Flowerpot:GetUp() * 60 + Flowerpot:GetRight() * math.Rand(-25, 25) + Flowerpot:GetForward() * math.Rand(-25, 25))
				ent:SetAngles(Flowerpot:GetAngles())
				ent:Spawn()
				ent:Activate()
				ent:SetSkin(plantData.skin)

				ent.PlantID = Flowerpot:GetSeed()
				ent.PlantName = Flowerpot:GetSeedName()
				ent.THC = finalTHC

				ent.perf_time = GrowPerfData.Grow_Time
				ent.perf_amount = GrowPerfData.Weed_Amount
				ent.perf_thc = GrowPerfData.THC_Level

				local FlowerpotOwner = zwf.f.GetOwnerID(Flowerpot)
				zwf.f.SetOwnerByID(ent, FlowerpotOwner)

				if weedAmount >= zwf.config.Jar.Capacity then
					ent:SetWeedAmount(zwf.config.Jar.Capacity)
					weedAmount = weedAmount - zwf.config.Jar.Capacity
				else
					ent:SetWeedAmount(math.Clamp(math.Round(weedAmount),2,9999999))
					weedAmount = 0
				end
			end
		end

		local _seed = Flowerpot:GetSeed()

		// Kill plant
		if _seed ~= -1 then
			zwf.f.CreateEffectTable(zwf.config.Plants[_seed].death_effect, "zwf_cut_plant", Flowerpot, Flowerpot:GetAngles(), Flowerpot:GetPos() + Flowerpot:GetUp() * 35, nil)
		end

		Plant:Remove()

		hook.Run("zwf_OnPlantHarvest" ,Flowerpot,ply)

		zwf.f.Flowerpot_Reset(Flowerpot)
	end
end


// Resets the flower pot data
function zwf.f.Flowerpot_Reset(Flowerpot)
	Flowerpot:SetWater(0)
	Flowerpot:SetLight(0)
	Flowerpot:SetNutritionID(-1)
	Flowerpot:SetSeed(-1)

	Flowerpot:SetTemperatur(0)
	Flowerpot:SetHasSoil(false)
	Flowerpot:SetHasPlague(false)
	Flowerpot:SetHarvestReady(false)

	Flowerpot:SetProgress(0)
	Flowerpot:SetPerfectProgress(0)

	Flowerpot:SetYieldAmount(0)

	Flowerpot:SetPerf_Time(100)
	Flowerpot:SetPerf_Amount(100)
	Flowerpot:SetPerf_THC(100)

	Flowerpot.Plant = nil

	Flowerpot.LastRessourceUse = -1
	Flowerpot.LastHigh_Progress = -1

	Flowerpot.PlantData = nil

	Flowerpot.Grow_Duration = -1
	Flowerpot.Grow_Amount = -1
	Flowerpot.Grow_THC = -1

	Flowerpot.Grow_Start = -1
	Flowerpot.Grow_Finish = -1

	Flowerpot.Unhappy_time = -1
end


// Used to frezze the plants state in to a ultraform for screenshots and such
function zwf.f.Flowerpot_UltraForm(Flowerpot,weedAmount)
	Flowerpot.CutCount = 3
	Flowerpot:SetHasSoil(true)
	Flowerpot:SetWater(zwf.config.Flowerpot.Water_Capacity / 2)

	Flowerpot.UtraForm = true
	Flowerpot:SetHarvestReady(false)
	Flowerpot:SetYieldAmount(weedAmount)
	Flowerpot.Grow_WeedAmount_At_Finish = weedAmount
	Flowerpot:SetProgress(900)

	zwf.f.Debug("Flowerpot [" .. Flowerpot:EntIndex() .. "] Set To Ultraform!")
end
