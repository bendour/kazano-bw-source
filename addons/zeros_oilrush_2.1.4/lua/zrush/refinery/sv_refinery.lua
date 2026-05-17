if CLIENT then return end
zrush = zrush or {}
zrush.Refinery = zrush.Refinery or {}

function zrush.Refinery.Initialize(Refinery)
	Refinery:SetModel(Refinery.Model)
	Refinery:PhysicsInit(SOLID_VPHYSICS)
	Refinery:SetMoveType(MOVETYPE_VPHYSICS)
	Refinery:SetSolid(SOLID_VPHYSICS)
	Refinery:SetUseType(SIMPLE_USE)

	if (zrush.config.Machine_NoCollide) then
		Refinery:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	end

	local phys = Refinery:GetPhysicsObject()

	if IsValid(phys) then
		phys:Wake()
		phys:EnableMotion(false)
		phys:SetMass(150)
	end

	Refinery:UseClientSideAnimation()
	Refinery.PhysgunDisabled = true

	zrush.Modules.Setup(Refinery)

	zclib.EntityTracker.Add(Refinery)
end

// Called when a player presses e on the Refinery
function zrush.Refinery.OnUse(Refinery,ply)
	if (Refinery.Wait or false) then return end

	zrush.Machine.OpenUI(Refinery,ply)
end

function zrush.Refinery.OnTouch(Refinery, Barrel)
	if not IsValid(Refinery) then return end
	if not IsValid(Barrel) then return end
	if Barrel:GetClass() ~= "zrush_barrel" then return end
	if zclib.util.CollisionCooldown(Barrel) then return end
	if Refinery.IsDeconstructing then return end

	// That barrel already has a machine
	if IsValid(Barrel.Machine) then return end

	local barrelOwner = Barrel:CPPIGetOwner()
	if Refinery:CPPIGetOwner() != barrelOwner then
        if IsValid(barrelOwner) then
            BaseWars:Notify(barrelOwner, "#notYours", NOTIFICATION_ERROR, 8)
        end

        return
    end

	if Barrel:GetOil() > 0 then

		if not IsValid(Refinery:GetInputBarrel()) then
			zrush.Refinery.AttachBarrel(Refinery,1, Barrel)
		end
	elseif Barrel:GetFuel() <= 0 and Barrel:GetOil() <= 0 then

		if not IsValid(Refinery:GetOutputBarrel()) then
			zrush.Refinery.AttachBarrel(Refinery,2, Barrel)
		end
	elseif Barrel:GetFuel() > 0 and Barrel:GetFuel() < zrush.config.Barrel.Storage and Barrel:GetFuelTypeID() == Refinery:GetFuelTypeID() then

		if not IsValid(Refinery:GetOutputBarrel()) then
			zrush.Refinery.AttachBarrel(Refinery,2, Barrel)
		end
	end
end


////////////////////////////////////////////
////////////// Construction ////////////////
////////////////////////////////////////////

// Called after the DrillTower got build
function zrush.Refinery.PostBuild(Refinery, ply, BuildOnEntity)
	Refinery.PhysgunDisabled = true
	zrush.Machine.SetState(ZRUSH_STATE_NEEDOILBARREL, Refinery)

	Refinery:SetAngles(Angle(0, Refinery:GetAngles().y, 0))

	local phys = Refinery:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:EnableMotion(false)
	end
end

// This deconstructs the refinery
function zrush.Refinery.Deconstruct(Refinery)
	zrush.Refinery.Stop(Refinery)

	local inputBarrel = Refinery:GetInputBarrel()
	local outputBarrel = Refinery:GetOutputBarrel()

	if (IsValid(inputBarrel)) then
		zrush.Refinery.DetachBarrel(Refinery,1, inputBarrel)
	end

	if (IsValid(outputBarrel)) then
		zrush.Refinery.DetachBarrel(Refinery,2, outputBarrel)
	end
end

////////////////////////////////////////////
////////////////////////////////////////////




////////////////////////////////////////////
/////////////////// Modules ////////////////
////////////////////////////////////////////

// This updates the machine if a module gets installed
function zrush.Refinery.ModulesChanged(Refinery)
	// This resets the refine timer do be sure he has the right time if a speed module got installed
	if Refinery:IsRunning() then
		zrush.Refinery.Start(Refinery)
	end

	// The Updates the Pitch of the Looped Sound on CLIENT
	zrush.Machine.UpdateSound(Refinery)
end

////////////////////////////////////////////
////////////////////////////////////////////







////////////////////////////////////////////
//////////////// MAIN LOGIC ////////////////
////////////////////////////////////////////
// Called when the fuel gets changed to a new fuel type
util.AddNetworkString("zrush_Refinery_ChangeFuel")
net.Receive("zrush_Refinery_ChangeFuel", function(len, ply)
	if zclib.Player.Timeout(nil,ply) then return end
	local ent = net.ReadEntity()
	local fuelID = net.ReadInt(16)

	local FuelData = zrush.FuelTypes[fuelID]

	if (IsValid(ent) and ent:GetClass() == "zrush_refinery") and FuelData then
		if (not zclib.Player.IsOwner(ply, ent) and rush.config.EquipmentSharing == false) then
			zrush.Notify(ply, zrush.language["YouDontOwnThis"], 1)

			return
		end

		// Add checks for disdtance, have money, is allowed etc
		if zclib.util.InDistance(ent:GetPos(), ply:GetPos(), 300) == false then
			zrush.Notify(ply, zrush.language["TooFarAway"], 1)
			return
		end

		if FuelData.jobs and not zclib.Player.JobCheck(ply, FuelData.jobs) then
			zrush.Notify(ply, zrush.language["WrongJob"], 1)
			return
		end

		if FuelData.ranks and not zclib.Player.RankCheck(ply, FuelData.ranks) then
			zrush.Notify(ply, zrush.language["WrongUserGroup"], 1)
			return
		end

		zrush.Refinery.ChangeFuel(ent, fuelID)

		timer.Simple(0.2, function()
			net.Start("zrush_Refinery_ChangeFuel")
			net.WriteEntity(ent)
			net.Send(ply)
		end)
	end
end)
function zrush.Refinery.ChangeFuel(Refinery,newFuelID)
	local outputBarrel = Refinery:GetOutputBarrel()

	if (IsValid(outputBarrel) and outputBarrel:GetFuel() > 0 and outputBarrel:GetFuelTypeID() ~= newFuelID) then
		zrush.Refinery.DetachBarrel(Refinery,2, Refinery:GetOutputBarrel())
	end

	Refinery:SetFuelTypeID(newFuelID)
end

// This function attaches a barrel depending on its type
function zrush.Refinery.AttachBarrel(Refinery,bType, barrel)
	if (Refinery:IsOverHeating()) then return end

	// If the barrel has a attach cooldown then stop
	if zrush.Barrel.CanAttach(barrel) == false then return end

	DropEntityIfHeld(barrel)

	if (bType == 1) then
		Refinery:SetInputBarrel(barrel)
		zrush.Barrel.Attach(barrel,Refinery:LocalToWorld(Vector(-45,0,15)),Refinery:LocalToWorldAngles(Angle(0,0,0)),Refinery)
	elseif (bType == 2) then
		barrel:SetFuelTypeID(Refinery:GetFuelTypeID())
		Refinery:SetOutputBarrel(barrel)
		zrush.Barrel.Attach(barrel,Refinery:LocalToWorld(Vector(45,0,15)),Refinery:LocalToWorldAngles(Angle(0,180,0)),Refinery)
	end

	zrush.Refinery.StateUpdater(Refinery)

	zrush.Refinery.AutoStart(Refinery)
end

// This function detaches a barrel depending on the type
function zrush.Refinery.DetachBarrel(Refinery,bType, barrel)
	if Refinery:HasChaosEvent() then return end

	if (IsValid(Refinery) and IsValid(barrel)) then
		local posOffset = 0

		if (bType == 1) then
			posOffset = -60
			Refinery:SetInputBarrel(NULL)
		elseif (bType == 2) then
			posOffset = 60
			Refinery:SetOutputBarrel(NULL)
		end

		zrush.Barrel.Drop(barrel,Refinery:LocalToWorld(Vector(posOffset,-70,10)))

		zrush.Refinery.Stop(Refinery)
	end
end


// This Toggles the work status of the machine
function zrush.Refinery.Toggle(Refinery,ply)
	local inputBarrel = Refinery:GetInputBarrel()
	local outputBarrel = Refinery:GetOutputBarrel()

	if (not IsValid(inputBarrel)) then
		zrush.Notify(ply, zrush.language["MissingOilBarrel"], 1)

		return
	end

	if (not IsValid(outputBarrel)) then
		zrush.Notify(ply, zrush.language["MissingEmptyBarrel"], 1)

		return
	elseif (outputBarrel:GetFuel() >= zrush.config.Barrel.Storage) then
		zrush.Notify(ply, zrush.language["FUELBARREL_FULL"], 1)

		return
	end

	if Refinery:IsRunning() then
		zrush.Refinery.Stop(Refinery)
	else
		zrush.Refinery.Start(Refinery)
	end

	// This sends a UI update message do all players
	zrush.Machine.UpdateUI(Refinery, true)
end

// This AutoStarts the machine if we have everything we need
function zrush.Refinery.AutoStart(Refinery)
	local inputBarrel = Refinery:GetInputBarrel()
	local outputBarrel = Refinery:GetOutputBarrel()

	if (IsValid(inputBarrel) and IsValid(outputBarrel) and outputBarrel:GetFuel() < zrush.config.Barrel.Storage) then
		zrush.Refinery.Start(Refinery)
	end
end

// This Starts our timer
function zrush.Refinery.Start(Refinery)
	local inputBarrel = Refinery:GetInputBarrel()
	local outputBarrel = Refinery:GetOutputBarrel()

	if (not IsValid(inputBarrel) or not IsValid(outputBarrel)) then return end

	if (Refinery:IsOverHeating()) then return end

	zrush.Refinery.Stop(Refinery)

	local refineSpeed = Refinery:GetBoostValue("speed")
	zrush.Machine.SetState(ZRUSH_STATE_REFINING, Refinery)

	local timerid = "zrush_working_" .. Refinery:EntIndex()
	zclib.Timer.Remove(timerid)
	zclib.Timer.Create(timerid, refineSpeed, 0, function()
		if (IsValid(Refinery)) then
			zrush.Refinery.Complete(Refinery)
		end
	end)
end

// This Stops our pump timer
function zrush.Refinery.Stop(Refinery)
	zclib.Timer.Remove("zrush_working_" .. Refinery:EntIndex())

	zrush.Refinery.StateUpdater(Refinery)

	zclib.Debug("Destroyed RefinerTimer (" .. Refinery:EntIndex() .. ")")
end

// This handels the main pump logic
function zrush.Refinery.Complete(Refinery)
	if (Refinery:IsOverHeating()) then return end
	local inputBarrel = Refinery:GetInputBarrel()
	local outputBarrel = Refinery:GetOutputBarrel()

	// Do we have a Oil Barrel?
	if (IsValid(inputBarrel)) then

		// Do we have a Empty Barrel?
		if (IsValid(outputBarrel)) then
			local oil = inputBarrel:GetOil()
			local Fuel = outputBarrel:GetFuel()

			// Does the Input Barrel has Oil?
			if (oil > 0) then

				// Is the Output Barrel full?
				if (Fuel >= zrush.config.Barrel.Storage) then

					zrush.Refinery.Stop(Refinery)
				else

					///// This is the Oil Refining Function
					local takeAmount = Refinery:GetBoostValue("production")

					zclib.NetEvent.Create("zrush_refinery_fillfuel", {Refinery})

					local outputAmount = takeAmount * Refinery:GetBoostValue("refining")


					// Custom Hook
					hook.Run("zrush_OnFuelRefined", Refinery,outputAmount,Refinery:GetFuelTypeID())


					zrush.Barrel.RemoveLiquid(inputBarrel,"Oil", takeAmount)
					zrush.Barrel.AddLiquid(outputBarrel,Refinery:GetFuelTypeID(), outputAmount)

					zrush.Machine.SetState(ZRUSH_STATE_REFINING, Refinery)
					/////
				end
			else
				inputBarrel:SetOil(0)
				inputBarrel:SetFuelTypeID(0)
				inputBarrel:SetFuel(0)

				zrush.Refinery.DetachBarrel(Refinery,1, inputBarrel)
				zrush.Refinery.Stop(Refinery)
			end

			// Is the Output Barrel full?
			// We test again do make sure we remove it after the action
			if (Fuel >= zrush.config.Barrel.Storage) then

				zrush.Refinery.Stop(Refinery)
			end
		else
			zrush.Refinery.Stop(Refinery)
		end
	else
		zrush.Refinery.Stop(Refinery)
	end

	// This sends a UI update message do all players
	zrush.Machine.UpdateUI(Refinery, false,true)
end

function zrush.Refinery.StateUpdater(Refinery)
	local inputBarrel = Refinery:GetInputBarrel()
	local outputBarrel = Refinery:GetOutputBarrel()

	// Do we have a Oil Barrel?
	if (IsValid(inputBarrel)) then
		// Do we have a Empty Barrel?
		if (IsValid(outputBarrel)) then
			if (outputBarrel:GetFuel() >= zrush.config.Barrel.Storage) then
				zrush.Machine.SetState(ZRUSH_STATE_FUELBARRELFULL, Refinery)
			else
				zrush.Machine.SetState(ZRUSH_STATE_READYFORWORK, Refinery)
			end
		else
			zrush.Machine.SetState(ZRUSH_STATE_NEEDEMPTYBARREL, Refinery)
		end
	else
		zrush.Machine.SetState(ZRUSH_STATE_NEEDOILBARREL, Refinery)
	end
end
////////////////////////////////////////////
////////////////////////////////////////////






////////////////////////////////////////////
//////////// OVERHEAT EVENT ////////////////
////////////////////////////////////////////

function zrush.Refinery.OnHeatEvent(Refinery)
	zclib.Timer.Remove("zrush_working_" .. Refinery:EntIndex())
end

// This function gets called when the machine explodes because of the overheat event
function zrush.Refinery.OnHeatFailed(Refinery)
	// This detaches our barrels
	zrush.Refinery.DetachBarrel(Refinery,1, Refinery:GetInputBarrel())
	zrush.Refinery.DetachBarrel(Refinery,2, Refinery:GetOutputBarrel())
end

// Cools down the machine so it doesent explode
function zrush.Refinery.OnHeatFixed(Refinery)
	zrush.Refinery.Start(Refinery)
end
////////////////////////////////////////////
////////////////////////////////////////////
