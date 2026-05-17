if CLIENT then return end
zrush = zrush or {}
zrush.DrillHole = zrush.DrillHole or {}
zrush.DrillHole.List = zrush.DrillHole.List or {}

// Here we create the drillhole
function zrush.DrillHole.Create(DrillTower,ply)
	local hole = ents.Create("zrush_drillhole")
	hole:SetModel("models/zerochain/props_oilrush/zor_drillhole.mdl")
	hole:SetPos(DrillTower:LocalToWorld(Vector(0, 0, 0)))
	hole:SetAngles(DrillTower:GetAngles())
	hole:Spawn()
	hole:Activate()

	local phys = hole:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:EnableMotion(false)
	end

	constraint.NoCollide(hole, DrillTower, 0, 0)
	DrillTower:SetHole(hole)
	zclib.Player.SetOwner(hole, ply)
	ply:zrush_CreatedDrillHole(hole:EntIndex())

	return hole
end

function zrush.DrillHole.Initialize(DrillHole)
	DrillHole:SetModel( "models/zerochain/props_oilrush/zor_drillhole.mdl")
	DrillHole:PhysicsInit(SOLID_VPHYSICS)
	DrillHole:SetMoveType(MOVETYPE_VPHYSICS)
	DrillHole:SetSolid(SOLID_VPHYSICS)
	DrillHole:SetUseType(SIMPLE_USE)
	DrillHole:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	local phys = DrillHole:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:EnableMotion(false)
	end

	DrillHole:UseClientSideAnimation()
	DrillHole.PhysgunDisabled = true
	DrillHole:SetBodygroup(0, 0)

	if (zrush.config.Machine["DrillHole"].RandomColor) then
		DrillHole:SetColor(HSVToColor(math.Rand(0, 360), 0.4, 0.5))
	else
		DrillHole:SetColor(zrush.config.Machine["DrillHole"].CustomColor)
	end

	local HoleID = zrush.OilSpot.GetRandom()
	local HoleData = zrush.OilSpot.GetData(HoleID)

	DrillHole:SetHoleType(HoleID)
	DrillHole:SetOilAmount(HoleData.oil_amount)
	DrillHole:SetNeededPipes(HoleData.depth)
	DrillHole:SetChaosEventBoost(HoleData.chaos_chance)

	DrillHole.Closed = false
	DrillHole.NoOil_TimeStamp = -1
	DrillHole.LastInteraction_TimeStamp = CurTime()

	zrush.Machine.SetState(ZRUSH_STATE_NEEDPIPES, DrillHole)

	table.insert(zrush.DrillHole.List,DrillHole)

	zclib.EntityTracker.Add(DrillHole)

	/*
		If set to true then drilled oilspots will lose oil if not caped by a pump
	*/
	if zrush.config.OilSpot.OilLoss and zrush.config.OilSpot.OilLoss > 0 then
		timer.Simple(1, function()
			if not IsValid(DrillHole) then return end

			local timerid = "zrush_DrillholeOilLoss_" .. DrillHole:EntIndex()
			zclib.Timer.Remove(timerid)
			zclib.Timer.Create(timerid, 1, 0, function()
				if DrillHole:GetPipes() >= DrillHole:GetNeededPipes() and not IsValid(DrillHole:GetParent()) and DrillHole:GetOilAmount() > 0 and DrillHole:GetState() ~= ZRUSH_STATE_NEEDBURNER then
					DrillHole:SetOilAmount(DrillHole:GetOilAmount() - zrush.config.OilSpot.OilLoss)

					if DrillHole:GetOilAmount() <= 0 then
						SafeRemoveEntity(DrillHole)
					end
				end
			end)
		end)
	end

end

function zrush.DrillHole.OnRemove(DrillHole)
	if IsValid(DrillHole.OilSpot) then
		SafeRemoveEntity(DrillHole.OilSpot)
	end

	table.RemoveByValue(zrush.DrillHole.List,DrillHole)

	zclib.Timer.Remove("zrush_DrillholeOilLoss_" .. DrillHole:EntIndex())

	zclib.EntityTracker.Remove(DrillHole)
end

// This adds a pipe in our Drill Hole
function zrush.DrillHole.AddPipe(DrillHole)
	DrillHole:SetPipes(DrillHole:GetPipes() + 1)

	// Custom Hook
	hook.Run("zrush_OnPipeDrilled", DrillHole)

	zclib.Debug("Status is:" .. DrillHole:GetPipes() .. "/" .. DrillHole:GetNeededPipes())
end

// This Starts our ButanGas timer
function zrush.DrillHole.ButanGasCycle_Start(DrillHole)
	zrush.DrillHole.ButanGasCycle_Stop(DrillHole)
	zrush.Machine.SetState(ZRUSH_STATE_NEEDBURNER, DrillHole)

	local timerid = "zrush_working_" .. DrillHole:EntIndex()
	zclib.Timer.Remove(timerid)
	zclib.Timer.Create(timerid, zrush.config.Machine["DrillHole"].ButanGas_Speed, 0, function()
		if IsValid(DrillHole) then
			zrush.DrillHole.ButanGasCycle_Complete(DrillHole)
		end
	end)
end

// This Stops our ButanGas timer
function zrush.DrillHole.ButanGasCycle_Stop(DrillHole)
	zclib.Timer.Remove("zrush_working_" .. DrillHole:EntIndex())
	zclib.Debug("Destroyed BurnTimer (" .. DrillHole:EntIndex() .. ")")
end

// This handels the main Butan logic
function zrush.DrillHole.ButanGasCycle_Complete(DrillHole)
	if IsValid(DrillHole) and DrillHole:GetState() == ZRUSH_STATE_NEEDBURNER then
		local gas = DrillHole:GetGas()

		if (gas > 0) then
			DrillHole:SetGas(gas - 1)
		else
			// No more gas do emit
			zrush.DrillHole.ButanGas_Finished(DrillHole)
		end

		// The Damage gets Handeled via the Damage Handler!
	end
end

// This gets called when all of the gas is gone
function zrush.DrillHole.ButanGas_Finished(DrillHole)
	zrush.DrillHole.ReachedOil(DrillHole)
end

// Gets called when we finished the drilling
function zrush.DrillHole.HasGas(DrillHole)
	local BurnChancePool = {}

	for i = 1, zrush.Holes[DrillHole:GetHoleType()].burnchance do
		table.insert(BurnChancePool, true)
	end

	for i = 1, (100 - (zrush.Holes[DrillHole:GetHoleType()].burnchance)) do
		table.insert(BurnChancePool, false)
	end
	// 360413082
	local NeedsDoBurn = table.Random(BurnChancePool)

	if (NeedsDoBurn) then
		// This adds the gas it needs do burn
		DrillHole:SetGas(zrush.Holes[DrillHole:GetHoleType()].gas_amount)
		zrush.DrillHole.ButanGasCycle_Start(DrillHole)

		return true
	else
		zrush.DrillHole.ReachedOil(DrillHole)

		return false
	end
end

// Gets called when we reach the Oil
function zrush.DrillHole.ReachedOil(DrillHole)
	// This means its ready for the Pump
	zrush.Machine.SetState(ZRUSH_STATE_PUMPREADY, DrillHole)
end

// This gets called by the Pump when there is no more oil in the hole
function zrush.DrillHole.NoOil(DrillHole)
	if not IsValid(DrillHole) then return end
	zrush.Machine.SetState(ZRUSH_STATE_NOOIL, DrillHole)
	DrillHole.Closed = true
	DrillHole.NoOil_TimeStamp = CurTime()

	if IsValid(DrillHole.OilSpot) then
		zrush.OilSpot.Close(DrillHole.OilSpot)
	end

	DrillHole:SetBodygroup(0, 1)
end

// This gets called by the pump do remove oil
function zrush.DrillHole.RemoveOil(DrillHole,lamount)
	DrillHole:SetOilAmount(DrillHole:GetOilAmount() - lamount)
end

// This tells us if the DrillHole is Occupied by other entities
function zrush.DrillHole.IsOccupied(DrillHole)
	if (DrillHole:HasPump() or DrillHole:HasDrill() or DrillHole:HasBurner() or DrillHole.Closed) then
		return true
	else
		return false
	end
end

// This gets called by all the machines that are using this drillhole
function zrush.DrillHole.HadInteraction(DrillHole)
	DrillHole.LastInteraction_TimeStamp = CurTime()
end

// This gets called by the drillhole remover do check if its due do removal
function zrush.DrillHole.RemoverCheck(DrillHole)
	if DrillHole:HasPump() or DrillHole:HasDrill() or DrillHole:HasBurner() then return end

	if DrillHole.NoOil_TimeStamp > 0 then
		if (DrillHole.NoOil_TimeStamp + zrush.config.Machine["DrillHole"].PostCooldown) < CurTime() then
			SafeRemoveEntity(DrillHole)
		end
	elseif (DrillHole.LastInteraction_TimeStamp + zrush.config.Machine["DrillHole"].Cooldown) < CurTime() then
		SafeRemoveEntity(DrillHole)
	end
end

/*
	This makes sure unused drillholes get removed (Only used in zrush.config.Drill_Mode = 0)
*/
if zrush.config.Machine[ "DrillHole" ].Cooldown > 0 then
	timer.Simple(1, function()
		local timerid = "zrush_DrillholeChecker_id"
		zclib.Timer.Remove(timerid)

		zclib.Timer.Create(timerid, zrush.config.Machine[ "DrillHole" ].Cooldown, 0, function()
			for k, v in pairs(zrush.DrillHole.List) do
				if IsValid(v) then
					zrush.DrillHole.RemoverCheck(v)
				end
			end
		end)
	end)
end
