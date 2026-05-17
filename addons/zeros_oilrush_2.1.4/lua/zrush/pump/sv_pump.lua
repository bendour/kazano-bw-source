if CLIENT then return end
zrush = zrush or {}
zrush.Pump = zrush.Pump or {}

function zrush.Pump.Initialize(Pump)
	Pump:SetModel("models/zerochain/props_oilrush/zor_oilpump.mdl")
	Pump:PhysicsInit(SOLID_VPHYSICS)
	Pump:SetMoveType(MOVETYPE_VPHYSICS)
	Pump:SetSolid(SOLID_VPHYSICS)
	Pump:SetUseType(SIMPLE_USE)

	if (zrush.config.Machine_NoCollide) then
		Pump:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	end

	local phys = Pump:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(false)
		phys:SetMass(150)
	end

	Pump:UseClientSideAnimation()
	Pump.PhysgunDisabled = true

	Pump:SetBodygroup(0, 1)
	Pump:SetBodygroup(1, 1)
	Pump:SetBodygroup(3, 1)
	Pump:SetBodygroup(5, 1)

	zrush.Modules.Setup(Pump)

	zclib.EntityTracker.Add(Pump)
end

// Called when a player presses e on the Pump
function zrush.Pump.OnUse(Pump,ply)
	if (Pump.Wait or false) then return end

	zrush.Machine.OpenUI(Pump,ply)
end

function zrush.Pump.OnTouch(Pump,Barrel)
	if not IsValid(Pump) then return end
	if not IsValid(Barrel) then return end
	if Barrel:GetClass() ~= "zrush_barrel" then return end
	if zclib.util.CollisionCooldown(Barrel) then return end
	if Pump.IsDeconstructing then return end

	if not IsValid(Pump:GetBarrel()) then
		zrush.Pump.AddBarrel(Pump,Barrel)
	end
end



////////////////////////////////////////////
//////////// CONSTRUCTION //////////////////
////////////////////////////////////////////
// This Places the pump on a drill hole
function zrush.Pump.PostBuild(Pump, ply, hole)
	if not IsValid(hole) then return end
	if not hole:IsValid() then return end
	if (hole:HasPump() or hole:HasBurner() or hole:HasDrill() or hole.Closed) then return end

	Pump:SetHole(hole)

	zrush.DrillHole.HadInteraction(hole)

	hole:SetParent(Pump)

	zrush.Machine.SetState(ZRUSH_STATE_NEEDEMPTYBARREL, Pump)

	Pump:SetBodygroup(2, 1)
	Pump:SetBodygroup(4, 1)
end

// This removes the pump from the drillhole
function zrush.Pump.Deconstruct(Pump)
	zrush.Pump.Stop(Pump)

	local dHole = Pump:GetHole()
	if IsValid(dHole) then
		dHole:SetParent(nil)
	end

	local sBarrel = Pump:GetBarrel()
	if IsValid(sBarrel) then zrush.Pump.DetachBarrel(Pump) end
end
////////////////////////////////////////////
////////////////////////////////////////////




////////////////////////////////////////////
//////////////// MODULES ///////////////////
////////////////////////////////////////////
// Gets called when something on the Modules change
function zrush.Pump.ModulesChanged(Pump)
	// This resets the pump timer do be sure he has the right time if a speed module got installed
	if (Pump:IsRunning()) then
		zrush.Pump.Start(Pump)
	end

	zrush.Machine.UpdateSound(Pump)
end
////////////////////////////////////////////
////////////////////////////////////////////




////////////////////////////////////////////
////////////// MAIN LOGIC //////////////////
////////////////////////////////////////////

// This adds a barrel
function zrush.Pump.AddBarrel(Pump,Barrel)

	// If the pumps drillhole is already closed then stop
	local sHole = Pump:GetHole()
	if (IsValid(sHole) and sHole.Closed) then return end
	// If the machine is jammed then stop
	if (Pump:IsJammed()) then return end
	// If the pump already has a barrel then stop
	if IsValid(Pump:GetBarrel()) then return end
	// If the barrel has fuel then stop
	if Barrel:GetFuel() > 0 then return end
	// If the barrel is fuel of oil then stop
	if Barrel:GetOil() >= zrush.config.Barrel.Storage then return end

	// If the barrel has a attach cooldown then stop
	if zrush.Barrel.CanAttach(Barrel) == false then return end

	// That barrel already has a machine
	if IsValid(Barrel.Machine) then return end

	Pump:SetBarrel(Barrel)

	zrush.Barrel.Attach(Barrel,Pump:LocalToWorld(Vector(35,0,11)),Pump:LocalToWorldAngles(Angle(0,180,0)),Pump)

	zrush.Machine.SetState(ZRUSH_STATE_PUMPREADY, Pump)

	zrush.Pump.AutoStart(Pump)
end

// This removes a barrel
function zrush.Pump.DetachBarrel(Pump)
	local barrel = Pump:GetBarrel()

	if (IsValid(barrel) and IsValid(Pump)) then
		Pump:SetBarrel(NULL)

		zrush.Barrel.Drop(barrel,Pump:LocalToWorld(Vector(40,70,50)))

		zrush.Pump.Stop(Pump)

		if (Pump:GetHole().Closed == false) then
			zrush.Machine.SetState(ZRUSH_STATE_NEEDEMPTYBARREL, Pump)
		else
			if (Pump:GetState() == ZRUSH_STATE_NOOIL) then
				Pump:SetBodygroup(2, 0)
			end
		end
	end
end

// This Toggles the work status of the machine
function zrush.Pump.Toggle(Pump,ply)
	if not IsValid(Pump:GetHole()) or Pump:GetHole():GetOilAmount() <= 0 then
		zrush.Notify(ply, zrush.language["OilSourceEmpty"], 1)
		zrush.Pump.NoOil(Pump)
		return
	end

	if not IsValid(Pump:GetBarrel()) then
		zrush.Notify(ply, zrush.language["MissingBarrel"], 1)

		return
	end

	if (Pump:IsRunning()) then
		zrush.Pump.Stop(Pump)
	else
		zrush.Pump.Start(Pump)
	end

	// This sends a UI update message do all players
	zrush.Machine.UpdateUI(Pump, true)
end

// This AutoStarts the machine if we have everything we need
function zrush.Pump.AutoStart(Pump)
	local sHole = Pump:GetHole()
	local Barrel = Pump:GetBarrel()
	if IsValid(Barrel) and Barrel:GetOil() < zrush.config.Barrel.Storage and Pump:IsJammed() == false and IsValid(sHole) and sHole.Closed == false then
		zrush.Pump.Start(Pump)
	end
end

// This Starts our timer
function zrush.Pump.Start(Pump)
	if not IsValid(Pump:GetBarrel()) then return end

	zrush.Pump.Stop(Pump)

	local pumpSpeed = Pump:GetBoostValue("speed")
	timer.Simple(0.1,function()
		if IsValid(Pump) then
			zclib.NetEvent.Create("zrush_pump_anim_pumping", {Pump})
		end
	end)

	zrush.Machine.SetState(ZRUSH_STATE_PUMPING, Pump)

	local timerid = "zrush_working_" .. Pump:EntIndex()
	zclib.Timer.Remove(timerid)
	zclib.Timer.Create(timerid, pumpSpeed, 0, function()
		if (IsValid(Pump)) then
			zrush.Pump.Complete(Pump)
		end
	end)
end

// This Stops our pump timer
function zrush.Pump.Stop(Pump)
	zclib.Timer.Remove("zrush_working_" .. Pump:EntIndex())

	if (IsValid(Pump:GetBarrel())) then
		if zrush.Barrel.IsFull(Pump:GetBarrel()) then
			zrush.Machine.SetState(ZRUSH_STATE_BARRELFULL, Pump)
		else
			zrush.Machine.SetState(ZRUSH_STATE_PUMPREADY, Pump)
		end
	else
		zrush.Machine.SetState(ZRUSH_STATE_NEEDEMPTYBARREL, Pump)
	end

	zclib.Debug("Destroyed PumpTimer (" .. Pump:EntIndex() .. ")")

	zclib.Animation.Play(Pump, "idle", 1)
	zclib.NetEvent.Create("zrush_pump_anim_idle", {Pump})
end

// This handels the main pump logic
function zrush.Pump.Complete(Pump)
	if (Pump:IsJammed()) then return end
	local shole = Pump:GetHole()
	local sbarrel = Pump:GetBarrel()

	// Do we have a oil hole
	if (IsValid(shole)) then

		// Do we have a barrel
		if (IsValid(sbarrel)) then

			// Is the Barrel full?
			if (sbarrel:GetOil() >= zrush.config.Barrel.Storage) then

				zrush.Machine.SetState(ZRUSH_STATE_BARRELFULL, Pump)

				if timer.Exists("zrush_working_" .. Pump:EntIndex()) == true then
					zrush.Pump.Stop(Pump)
				end
			else
				local Oil = shole:GetOilAmount()

				if (Oil > 0) then
					local pumpAmount = Pump:GetBoostValue("production")

					// Custom Hook
					hook.Run("zrush_OnOilPumped", Pump,pumpAmount)

					zclib.NetEvent.Create("zrush_pump_filloil", {Pump})

					zrush.DrillHole.RemoveOil(shole,pumpAmount)
					zrush.Barrel.AddLiquid(sbarrel,"Oil", pumpAmount)
				else
					// No Oil
					zrush.Pump.NoOil(Pump)
				end
			end
		end

		// This sends a UI update message do all players
		zrush.Machine.UpdateUI(Pump, false,true)
	end
end

function zrush.Pump.NoOil(Pump)
	zrush.DrillHole.NoOil(Pump:GetHole())
	zrush.Pump.Stop(Pump)
	zrush.Machine.SetState(ZRUSH_STATE_NOOIL, Pump)

	// This sends a UI update message do all players
	zrush.Machine.UpdateUI(Pump, true)
	Pump:SetBodygroup(4, 0)
end

////////////////////////////////////////////
////////////////////////////////////////////





////////////////////////////////////////////
////////////// JAMM EVENT //////////////////
////////////////////////////////////////////

// For The Jam Event
function zrush.Pump.OnJamEvent(Pump)
	zclib.Timer.Remove("zrush_working_" .. Pump:EntIndex())

	// Play Jam Animation
	zclib.NetEvent.Create("zrush_pump_anim_jammed", {Pump})
end

function zrush.Pump.OnJamFixed(Pump)
	zclib.Animation.Play(Pump, "idle", 1)

	zclib.NetEvent.Create("zrush_pump_anim_idle", {Pump})

	zrush.Pump.Start(Pump)
end

////////////////////////////////////////////
////////////////////////////////////////////


concommand.Add("zrush_debug_pump_dropbarrel", function(ply, cmd, args)
	if zclib.Player.IsAdmin(ply) then
		local tr = ply:GetEyeTrace()
		local ent = tr.Entity
		if IsValid(ent) and ent:GetClass() == "zrush_pump" then
			zrush.Pump.DetachBarrel(ent)
		end
	end
end)
