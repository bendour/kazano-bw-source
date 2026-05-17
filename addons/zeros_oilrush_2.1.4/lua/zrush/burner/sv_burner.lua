if CLIENT then return end
zrush = zrush or {}
zrush.Burner = zrush.Burner or {}

function zrush.Burner.Initialize(Burner)
	Burner:SetModel("models/zerochain/props_oilrush/zor_drillburner.mdl")
	Burner:PhysicsInit(SOLID_VPHYSICS)
	Burner:SetMoveType(MOVETYPE_VPHYSICS)
	Burner:SetSolid(SOLID_VPHYSICS)
	Burner:SetUseType(SIMPLE_USE)

	if (zrush.config.Machine_NoCollide) then
		Burner:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	end

	local phys = Burner:GetPhysicsObject()

	if IsValid(phys) then
		phys:Wake()
		phys:EnableMotion(false)
		phys:SetMass(150)
	end

	Burner:UseClientSideAnimation()
	Burner.PhysgunDisabled = true

	zrush.Modules.Setup(Burner)

	zclib.EntityTracker.Add(Burner)
end

// Called when a player presses e on the burner
function zrush.Burner.OnUse(Burner,ply)
	if (Burner.Wait or false) then return end

	zrush.Machine.OpenUI(Burner,ply)
end

function zrush.Burner.OnRemove(Burner)
	zclib.EntityTracker.Remove(Burner)

	// This deletes the oilspot and the drillhole
	local hole = Burner:GetHole()

	if (IsValid(hole)) then
		local OilSpot = hole.OilSpot

		if (IsValid(OilSpot)) then
			zrush.OilSpot.Remove(OilSpot)
		end
	end
end

// This gets called if a new module is installed
function zrush.Burner.ModulesChanged(Burner)

	// This resets the burn timer do be sure he has the right time if a speed module got installed
	zrush.Burner.BurnGasCycle_Start(Burner)
end


////////////////////////////////////////////
////////////// Construction ////////////////
////////////////////////////////////////////
function zrush.Burner.PostBuild(Burner, ply, drillhole)

	// Attaches the burner on the drillhole

	Burner:SetHole(drillhole)

	Burner:SetPos(drillhole:LocalToWorld(Vector(0, 0, 3)))

	drillhole:SetParent(Burner)

	zrush.DrillHole.HadInteraction(drillhole)

	zrush.DrillHole.ButanGasCycle_Stop(drillhole)
	drillhole:SetParent(Burner)

	timer.Simple(0.1, function()
		if IsValid(Burner) then
			zrush.Burner.BurnGasCycle_Start(Burner)
		end
	end)
end

// This gets called from a button
function zrush.Burner.Deconstruct(Burner)
	zrush.Burner.BurnGasCycle_Stop(Burner)

	local shole = Burner:GetHole()
	if IsValid(shole) then
		shole:SetParent(nil)
		if shole:GetGas() > 0 then
			zrush.DrillHole.ButanGasCycle_Start(shole)
		end
	end
end
////////////////////////////////////////////
////////////////////////////////////////////





////////////////////////////////////////////
///////////////// MainLogic ////////////////
////////////////////////////////////////////
// This Starts our ButanGas timer
function zrush.Burner.BurnGasCycle_Start(Burner)
	local hole = Burner:GetHole()

	if not IsValid(hole) then return end
	if not hole.GetGas then return end

	local gas = hole:GetGas()

	if (gas <= 0) then
		zrush.Machine.SetState(ZRUSH_STATE_NOGASLEFT, Burner)

		return
	end

	zrush.Burner.BurnGasCycle_Stop(Burner)

	zrush.Machine.SetState(ZRUSH_STATE_BURNINGGAS, Burner)
	zrush.Machine.SetState(ZRUSH_STATE_HASBURNER, hole)

	zclib.NetEvent.Create("zrush_burner_anim_burn", {Burner})

	// How long does it take do emit one butan gas unit
	local burnSpeed = Burner:GetBoostValue("speed")

	local timerid = "zrush_working_" .. Burner:EntIndex()
	zclib.Timer.Remove(timerid)
	zclib.Timer.Create(timerid, burnSpeed, 0, function()
		if (IsValid(Burner)) then
			zrush.Burner.BurnGasCycle_Complete(Burner)
		end
	end)
end

// This Stops our ButanGas timer
function zrush.Burner.BurnGasCycle_Stop(Burner)

	zclib.Timer.Remove("zrush_working_" .. Burner:EntIndex())

	zclib.Animation.Play(Burner, "idle", 1)
	zclib.NetEvent.Create("zrush_burner_anim_idle", {Burner})

	zrush.Machine.SetState(ZRUSH_STATE_IDLE, Burner)

	zclib.Debug("Destroyed BurnTimer (" .. Burner:EntIndex() .. ")")
end

// This handels the main Butan logic
function zrush.Burner.BurnGasCycle_Complete(Burner)
	if (IsValid(Burner) and Burner:GetState() == ZRUSH_STATE_BURNINGGAS) then
		local aHole = Burner:GetHole()

		if (IsValid(aHole)) then
			local gas = aHole:GetGas()

			if (gas > 0) then
				local burnAmount = Burner:GetBoostValue("production")

				// Custom Hook
				hook.Run("zrush_OnGasBurned", Burner,burnAmount)

				aHole:SetGas(gas - burnAmount)

				// This sends a UI update message do all players
				zrush.Machine.UpdateUI(Burner, false,true)
			else
				// No more gas do burn
				zrush.Burner.BurnGas_Finished(Burner)

				// This sends a UI update message do all players
				zrush.Machine.UpdateUI(Burner, true)
			end
		end
	end
end

// This gets called when all of the gas is gone
function zrush.Burner.BurnGas_Finished(Burner)
	zrush.Machine.SetState(ZRUSH_STATE_PUMPREADY, Burner:GetHole())
	zrush.Machine.SetState(ZRUSH_STATE_NOGASLEFT, Burner)


	zclib.Animation.Play(Burner, "idle", 1)
	zclib.NetEvent.Create("zrush_burner_anim_idle", {Burner})

	// Custom Hook
	hook.Run("zrush_OnGasBurnedFinished", Burner)
end

////////////////////////////////////////////
////////////////////////////////////////////





////////////////////////////////////////////
//////////////// Heat Event ////////////////
////////////////////////////////////////////
// This function gets called when the machine explodes because of the overheat event
function zrush.Burner.OnHeatFailed(Burner)
	// THis deletes the oilspot and the drillhole
	local hole = Burner:GetHole()

	if (IsValid(hole)) then
		local OilSpot = hole.OilSpot

		if (IsValid(OilSpot)) then
			zrush.OilSpot.Remove(OilSpot)
		end
	end
end

// Cools down the machine so it doesent explode
function zrush.Burner.OnHeatFixed(Burner)
	zrush.Burner.BurnGasCycle_Start(Burner)
end
////////////////////////////////////////////
////////////////////////////////////////////
