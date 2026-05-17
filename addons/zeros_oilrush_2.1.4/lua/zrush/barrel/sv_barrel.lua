if CLIENT then return end
zrush = zrush or {}
zrush.Barrel = zrush.Barrel or {}

function zrush.Barrel.Initialize(Barrel)
	Barrel:SetModel("models/zerochain/props_oilrush/zor_barrel.mdl")
	Barrel:PhysicsInit(SOLID_VPHYSICS)
	Barrel:SetMoveType(MOVETYPE_VPHYSICS)
	Barrel:SetSolid(SOLID_VPHYSICS)
	Barrel:SetUseType(SIMPLE_USE)

	if (zrush.config.Machine_NoCollide) then
		Barrel:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	end

	local phys = Barrel:GetPhysicsObject()

	if IsValid(phys) then
		phys:Wake()
		phys:EnableMotion(true)
		phys:SetMass(150)
	end

	// This will be used to store the Pump/Refinery since the barrel cant be connected at both at the same time anyway
	Barrel.Machine = nil

	zrush.Barrel.UpdateVisual(Barrel)

	zclib.EntityTracker.Add(Barrel)
end

// Called when a player presses e on the barrel
function zrush.Barrel.OnUse(Barrel,ply)
	if not IsValid(Barrel) then return end

	if zrush.Barrel.CanAttach(Barrel) == false then return end

	if (Barrel:GetFuel() > 0 and not IsValid(Barrel.Machine)) then

		if zrush.config.FuelBuyer.SellMode == 2 then return end

		if not zrush.Barrel.PickUpCheck(ply, zrush.FuelTypes[Barrel:GetFuelTypeID()].ranks) then
			zrush.Notify(ply, zrush.language["WrongUserGroup"], 1)

			return
		end

		zrush.Barrel.OpenInterface(Barrel,ply)
	end

	if IsValid(Barrel.Machine) then

		local class = Barrel.Machine:GetClass()
		if class == "zrush_pump" then
			zrush.Pump.DetachBarrel(Barrel.Machine)
		elseif class == "zrush_refinery" then

			if (Barrel:GetOil() > 0) then
				//TODO There is some bug where users can deconnect the barrel from the refinery while still keeping its connections so maybe lets just stop them from removing the barrel all together
				// Or disable barrel use while the entity being dropped by the refinery
				zrush.Refinery.DetachBarrel(Barrel.Machine,1, Barrel)

			elseif (Barrel:GetFuel() > 0 or (Barrel:GetFuel() <= 0 and Barrel:GetOil() <= 0)) then

				zrush.Refinery.DetachBarrel(Barrel.Machine,2, Barrel)
			end
		end
	end
end

// Called when the barrel gets removed
function zrush.Barrel.OnRemove(Barrel)
	zclib.EntityTracker.Remove(Barrel)
end

// Is the barrel full?
function zrush.Barrel.IsFull(Barrel)
	if (Barrel:GetOil() >= zrush.config.Barrel.Storage or Barrel:GetFuel() >= zrush.config.Barrel.Storage) then
		return true
	else
		return false
	end
end

// Adds liquid to the barrel
function zrush.Barrel.AddLiquid(Barrel,ltype, lamount)
	if (ltype == "Oil") then
		Barrel:SetOil(Barrel:GetOil() + lamount)
	else
		Barrel:SetFuelTypeID(ltype)
		Barrel:SetFuel(Barrel:GetFuel() + lamount)
	end

	zrush.Barrel.UpdateVisual(Barrel)
end

// Removes liquid from the barrel
function zrush.Barrel.RemoveLiquid(Barrel,ltype, lamount)
	if (ltype == "Oil") then
		Barrel:SetOil(Barrel:GetOil() - lamount)

		if (Barrel:GetOil() <= 0) then
			zrush.Barrel.ResetLiquid(Barrel)
		end
	else
		Barrel:SetFuelTypeID(ltype)
		Barrel:SetFuel(Barrel:GetFuel() - lamount)

		if (Barrel:GetFuel() <= 0) then
			zrush.Barrel.ResetLiquid(Barrel)
		end
	end

	zrush.Barrel.UpdateVisual(Barrel)
end

// Emptys the Barrel
function zrush.Barrel.ResetLiquid(Barrel)
	Barrel:SetFuelTypeID(0)
	Barrel:SetOil(0)
	Barrel:SetFuel(0)
	zrush.Barrel.UpdateVisual(Barrel)
end

// Updates the Barrels color
function zrush.Barrel.UpdateVisual(Barrel)
	if Barrel:GetOil() > 0 then
		Barrel:SetColor(zrush.default_colors["grey02"])
	elseif Barrel:GetFuel() > 0 then
		Barrel:SetColor(zrush.FuelTypes[Barrel:GetFuelTypeID()].color)
	else
		Barrel:SetColor(color_white)
	end
end

// Attaches the barrel to the machine
function zrush.Barrel.Attach(Barrel,pos,ang,machine)
	local phys = Barrel:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:EnableMotion(false)
	end
	Barrel:SetPos(pos)
	Barrel:SetAngles(ang)
	Barrel:SetParent(machine)

	Barrel.Machine = machine
	Barrel.PhysgunDisabled = true

	zclib.Animation.Play(Barrel, "open", 1)
	zclib.NetEvent.Create("zrush_barrel_attached", {Barrel})

	Barrel.NextAttach = CurTime() + 1
end

// Can we attach this barrel?
function zrush.Barrel.CanAttach(Barrel)
	return CurTime() > (Barrel.NextAttach or 0)
end

// Drops a barrel from a machine
function zrush.Barrel.Drop(Barrel,pos)
	Barrel:SetParent(nil)
	Barrel:SetPos(pos)
	local phys = Barrel:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:EnableMotion(true)
	end

	Barrel.Machine = nil
	Barrel.PhysgunDisabled = false

	zclib.Animation.Play(Barrel, "close", 1)
	zclib.NetEvent.Create("zrush_barrel_detached", {Barrel})
	Barrel.NextAttach = CurTime() + 1
end


util.AddNetworkString("zrush_Barrel_OpenUI")
function zrush.Barrel.OpenInterface(Barrel,ply)
	net.Start("zrush_Barrel_OpenUI")
	net.WriteEntity(Barrel)
	net.Send(ply)
end


// This Handles the Fuel Barrel Collect function
util.AddNetworkString("zrush_Barrel_CollectFuel")
net.Receive("zrush_Barrel_CollectFuel", function(len, ply)
	if zclib.Player.Timeout(nil,ply) then return end
	local ent = net.ReadEntity()
	if not IsValid(ent) then return end
	if string.sub(ent:GetClass(),1,12) ~= "zrush_barrel" then return end
	if zclib.util.InDistance(ent:GetPos(), ply:GetPos(), 200) == false then return end

	// Its not fuel
	if ent:GetOil() > 0 then return end
	if ent:GetFuel() <= 0 then return end
	if ent:GetFuelTypeID() <= 0 then return end

	// Stop if the barrel is attached to a pump or refinery
	if IsValid(ent:GetParent()) then return end

	if zrush.config.Barrel.Owner_PickUpCheck and not zclib.Player.IsOwner(ply, ent) then
		zrush.Notify(ply, zrush.language["YouDontOwnThis"], 1)
		return
	end

	if ply:zrush_GetFuelBarrelCount() >= zrush.config.Player.FuelInvSize then
		zrush.Notify(ply, zrush.language["InventoryFull"] .. " [" .. ply:zrush_GetFuelBarrelCount() .. "/" .. zrush.config.Player.FuelInvSize .. "]", 1)
	else
		local id, amount = ent:GetFuelTypeID(), math.Round(ent:GetFuel())

		if zrush.Barrel.PickUpCheck(ply, zrush.FuelTypes[id].ranks) then
			zrush.Notify(ply, "+" .. tostring(math.Round(ent:GetFuel())) .. " " .. zrush.FuelTypes[id].name, 0)
			ply:zrush_AddFuelBarrel(id, amount)
			SafeRemoveEntity(ent)
			zrush.Notify(ply, "[" .. ply:zrush_GetFuelBarrelCount() .. "/" .. zrush.config.Player.FuelInvSize .. "]", 0)
		end
	end
end)

// This Handles the Fuel Barrel split function for VCMod
util.AddNetworkString("zrush_Barrel_SplittFuel")
net.Receive("zrush_Barrel_SplittFuel", function(len, ply)
	if zclib.Player.Timeout(nil,ply) then return end
	local ent = net.ReadEntity()

	if not IsValid(ent) then return end
	if string.sub(ent:GetClass(),1,12) ~= "zrush_barrel" then return end
	if zclib.util.InDistance(ent:GetPos(), ply:GetPos(), 200) == false then return end
	if zclib.Player.IsOwner(ply, ent) == false and rush.config.EquipmentSharing == false then return end

	// Its not fuel
	if ent:GetOil() > 0 then return end
	if ent:GetFuel() <= 0 then return end
	if ent:GetFuelTypeID() <= 0 then return end

	// Stop if the barrel is attached to a pump or refinery
	if IsValid(ent:GetParent()) then return end

	if (ent:GetFuel() >= 20) then
		zrush.Barrel.SpawnVCModFuelCan(ent)
	else
		zrush.Notify(ply, zrush.language["NeedMoreFuel"], 1)
	end
end)

// Extracts fuel and creates a VCMod FuelCan
function zrush.Barrel.SpawnVCModFuelCan(Barrel)
	if IsValid(Barrel.Machine) then return end
	if Barrel:GetFuel() < 20 then return end
	zrush.Barrel.RemoveLiquid(Barrel, Barrel:GetFuelTypeID(), 20)
	local vc_fueltype = zrush.Fuel.GetVCFuel(Barrel:GetFuelTypeID())
	local ent

	if SVMOD then
		ent = ents.Create("sv_petrol_canister")
	else
		if (vc_fueltype == 0) then
			ent = ents.Create("vc_pickup_fuel_petrol")
		elseif (vc_fueltype == 1) then
			ent = ents.Create("vc_pickup_fuel_diesel")
		end
	end

	ent:SetAngles(Angle(0, 0, 0))
	ent:SetPos(Barrel:GetPos() + Vector(0, 0, 100))
	ent:Spawn()
	ent:Activate()
end

concommand.Add("zrush_debug_spawn_oil", function(ply, cmd, args)
	if zclib.Player.IsAdmin(ply) then
		local tr = ply:GetEyeTrace()

		if tr.HitPos then
			local ent = ents.Create("zrush_barrel")
			ent:SetPos(tr.HitPos)
			ent:Spawn()
			ent:Activate()
			zclib.Player.SetOwner(ent, ply)

			zrush.Barrel.AddLiquid(ent,"Oil", zrush.config.Barrel.Storage)
		end
	end
end)

concommand.Add("zrush_debug_spawn_fuel", function(ply, cmd, args)
	if zclib.Player.IsAdmin(ply) then
		local tr = ply:GetEyeTrace()

		if tr.HitPos then
			local ent = ents.Create("zrush_barrel")
			ent:SetPos(tr.HitPos)
			ent:Spawn()
			ent:Activate()
			zclib.Player.SetOwner(ent, ply)

			zrush.Barrel.AddLiquid(ent,math.random(1,table.Count(zrush.FuelTypes)),math.random(zrush.config.Barrel.Storage) /*zrush.config.Barrel.Storage*/)
		end
	end
end)
