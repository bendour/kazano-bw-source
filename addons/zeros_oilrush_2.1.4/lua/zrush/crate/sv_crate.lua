if not SERVER then return end
zrush = zrush or {}
zrush.Machinecrate = zrush.Machinecrate or {}

function zrush.Machinecrate.Initialize(Machinecrate)
	Machinecrate:SetModel("models/zerochain/props_oilrush/zor_machinecrate.mdl")
	Machinecrate:PhysicsInit(SOLID_VPHYSICS)
	Machinecrate:SetMoveType(MOVETYPE_VPHYSICS)
	Machinecrate:SetSolid(SOLID_VPHYSICS)
	Machinecrate:SetUseType(SIMPLE_USE)

	if (zrush.config.Machine_NoCollide) then
		Machinecrate:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	end

	local phys = Machinecrate:GetPhysicsObject()

	if IsValid(phys) then
		phys:Wake()
		phys:EnableMotion(true)
		phys:SetMass(150)
	end

	Machinecrate.Wait = true

	timer.Simple(0.1, function()
		if (IsValid(Machinecrate)) then
			Machinecrate.Wait = false
		end
	end)

	zclib.EntityTracker.Add(Machinecrate)
end

-- Called when a player presses e on the Machinecrate
function zrush.Machinecrate.OnUse(Machinecrate, ply)
	if (Machinecrate.Wait) then return end

	--Do we have a machine selected?
	if Machinecrate:GetMachineID() <= 0 then
		zrush.Machinecrate.OpenShop(Machinecrate, ply)
	else
		zrush.Machinecrate.OpenOptions(Machinecrate, ply)
	end
end

-- Opens the shop interface
util.AddNetworkString("zrush_Machinecrate_Buy")
function zrush.Machinecrate.OpenShop(Machinecrate, ply)
	if (not zclib.Player.IsOwner(ply, Machinecrate) and zrush.config.EquipmentSharing == false) then
		zrush.Notify(ply, zrush.language["YouDontOwnThis"], 1)

		return
	end

	net.Start("zrush_Machinecrate_Buy")
	net.WriteEntity(Machinecrate)
	net.Send(ply)
end

-- Adds the purchased machine in the machinecrate
net.Receive("zrush_Machinecrate_Buy", function(len, ply)
	if zclib.Player.Timeout(nil, ply) then return end
	local ent = net.ReadEntity()
	local machineshopId = net.ReadInt(16)

	-- Add checks for disdtance, is owner
	if (IsValid(ent) and ent:GetClass() == "zrush_machinecrate") then
		zrush.Machinecrate.Buy(ent, machineshopId, ply)
	end
end)
function zrush.Machinecrate.Buy(ent, machineshopId, ply)
	if not zclib.Player.IsOwner(ply, ent) and zrush.config.EquipmentSharing == false then return end

	if zclib.util.InDistance(ent:GetPos(), ply:GetPos(), 300) == false then
		zrush.Notify(ply, zrush.language["TooFarAway"], 1)

		return
	end

	local machineData = zrush.Machine.GetData(machineshopId)
	local entCount = 0
	for k, v in pairs(zclib.EntityTracker.GetList()) do
		if IsValid(v) and zclib.Player.IsOwner(ply, v) and v:GetClass() == "zrush_machinecrate" and v:GetMachineID() == machineshopId then
			entCount = entCount + 1
		end
	end

	-- if entCount >= machineData.limit then
	-- 	zrush.Notify(ply, zrush.language["MachineLimitReached"], 1)
	-- 	return
	-- end

	-- Check if the player has enough money
	local cost = zrush.Machine.GetPrice(machineshopId)

	if (not zclib.Money.Has(ply, cost)) then
		zrush.Notify(ply, zrush.language["Youcannotafford"], 1)

		return
	end

	local str = zrush.language["Youbougt"]
	str = string.Replace(str, "$Name", zrush.Machine.GetName(machineshopId))
	str = string.Replace(str, "$Price", BaseWars:FormatMoney(cost))
	zrush.Notify(ply, str, 0)
	-- Takes some money from the player
	ply:TakeMoney(cost)
	zclib.NetEvent.Create("zrush_npc_cash", {ply})
	ent:SetMachineID(machineshopId)
end

-- Opens the OptionBox for the machinecrate which has options like, Place , Sell
util.AddNetworkString("zrush_Machinecrate_Options")
function zrush.Machinecrate.OpenOptions(Machinecrate, ply)
	if (not zclib.Player.IsOwner(ply, Machinecrate) and zrush.config.Machine["MachineCrate"].AllowSell == false) then
		zrush.Notify(ply, zrush.language["YouDontOwnThis"], 1)

		return
	end

	Machinecrate.InstalledModules = Machinecrate.InstalledModules or {}
	net.Start("zrush_Machinecrate_Options")
	net.WriteEntity(Machinecrate)
	net.WriteTable(Machinecrate.InstalledModules)
	net.Send(ply)
end

-- This gets used to sell the machine or / and modules from the machinecrate
util.AddNetworkString("zrush_MachineCrate_Sell")
net.Receive("zrush_MachineCrate_Sell", function(len, ply)
	if zclib.Player.Timeout(nil, ply) then return end
	local ent = net.ReadEntity()

	if (IsValid(ent) and ent:GetClass() == "zrush_machinecrate") then
		if zclib.util.InDistance(ent:GetPos(), ply:GetPos(), 300) == false then
			zrush.Notify(ply, zrush.language["TooFarAway"], 1)

			return
		end

		if zclib.Player.IsOwner(ply, ent) then
			zrush.Machinecrate.Sell(ent, ent:GetMachineID(), ply)
		else
			if zrush.config.Machine["MachineCrate"].AllowSell == true then
				zrush.Machinecrate.Sell(ent, ent:GetMachineID(), ply)
			end
		end
	end
end)
function zrush.Machinecrate.Sell(ent, MachineID, ply)
	-- Here we sell all the modules
	if (ent.InstalledModules and table.Count(ent.InstalledModules) > 0) then
		for k, v in pairs(ent.InstalledModules) do
			local mData = zrush.Modules.GetData(v)
			if mData == nil then continue end
			local earning = mData.price * zrush.config.MachineBuilder.SellValue
			local str = zrush.language["YouSold"]
			str = string.Replace(str, "$Name", mData.name)
			str = string.Replace(str, "$Price", BaseWars:FormatMoney(earning))
			zrush.Notify(ply, str, 0)
			-- Give the player the Cash
			zclib.Money.Give(ply, earning)
		end
	end

	-- Here we sell the machine
	local earning = zrush.Machine.GetPrice(MachineID) * zrush.config.MachineBuilder.SellValue
	local str = zrush.language["YouSold"]
	str = string.Replace(str, "$Name", zrush.Machine.GetName(MachineID))
	str = string.Replace(str, "$Price", BaseWars:FormatMoney(earning))
	zrush.Notify(ply, str, 0)
	-- Give the player the Cash
	zclib.Money.Give(ply, earning)
	zclib.NetEvent.Create("zrush_npc_cash", {ply})
	-- Here we reset all the information
	ent:SetMachineID(-1)
	ent.InstalledModules = {}
	zrush.Machinecrate.AddModules(ent, ent.InstalledModules)
end

-- Gets called to inform the clients in distance about what models are inside the machine
util.AddNetworkString("zrush_MachineCrate_AddModules")
function zrush.Machinecrate.AddModules(Machinecrate, mTable)
	if mTable == nil then return end
	if istable(mTable) == false then return end
	Machinecrate.InstalledModules = {}
	table.CopyFromTo(mTable, Machinecrate.InstalledModules)

	timer.Simple(0.1, function()
		if (IsValid(Machinecrate)) then
			net.Start("zrush_MachineCrate_AddModules")
			net.WriteEntity(Machinecrate)
			net.WriteTable(mTable)
			net.SendPVS(Machinecrate:GetPos())
		end
	end)
end

-- The Building action
util.AddNetworkString("zrush_Machinecrate_Build")
net.Receive("zrush_Machinecrate_Build", function(len, ply)
	if zclib.Player.Timeout(nil, ply) then return end
	local ent = net.ReadEntity()

	if (IsValid(ent) and (zclib.Player.IsOwner(ply, ent) or zrush.config.EquipmentSharing) and ent:GetClass() == "zrush_machinecrate" and zclib.util.InDistance(ent:GetPos(), ply:GetPos(), 2000)) then
		zrush.Machinecrate.Build(ent, ply)
	end
end)
function zrush.Machinecrate.Build(Machinecrate, ply)
	local machineID = Machinecrate:GetMachineID()
	local machineData = zrush.Machine.GetData(machineID)
	local canBuild, buildPos, buildAng, buildEnt = zrush.Machinecrate.CanBuild(ply, machineID, Machinecrate)
	if canBuild == false then return end
	-- Check if the player can build more from this entity!
	local entCount = 0

	for k, v in pairs(zclib.EntityTracker.GetList()) do
		if IsValid(v) and zclib.Player.IsOwner(ply, v) and v:GetClass() == machineData.class then
			entCount = entCount + 1
		end
	end

	-- if entCount >= machineData.limit then
	-- 	zrush.Notify(ply, zrush.language["MachineLimitReached"], 1)

	-- 	return
	-- end

	if (machineID == ZRUSH_DRILL and (not IsValid(buildEnt) or buildEnt:GetClass() ~= "zrush_drillhole") and ply:zrush_ReturnActiveDrillHoleCount() >= zrush.config.Player.MaxActiveDrillHoles) then
		zrush.Notify(ply, zrush.language["ReachedMaxDrillhole"], 2)

		return
	end

	local ent = ents.Create(machineData.class)
	ent:SetAngles(buildAng)
	ent:SetPos(buildPos)
	ent:Spawn()
	ent:Activate()

	local phys = ent:GetPhysicsObject()
	if (IsValid(phys)) then
		phys:Wake()
		phys:EnableMotion(false)
	end

	ent.PhysgunDisabled = true

	zclib.NetEvent.Create("zrush_action_building", {Machinecrate})
	zclib.NetEvent.Create("zrush_drill_loadpipe", {Machinecrate})

	zclib.Player.SetOwner(ent, ply)

	--Add function that adds modules too the machine
	if (Machinecrate.InstalledModules) then

		for k, v in pairs(Machinecrate.InstalledModules) do
			if v > 0 then
				local freeSocket = zrush.Modules.FindFreeSocket(ent)

				if (freeSocket) then
					zrush.Modules.Add(v, ent, freeSocket)
				end
			end
		end
	end

	SafeRemoveEntity(Machinecrate)

	-- Called after the entity got build
	timer.Simple(0.1, function()
		if IsValid(ent) then
			ent:PostBuild(ply, buildEnt)
		end
	end)
end

-- This function disambles the machine into a crate
function zrush.Machinecrate.DeConstruct(machine)
	local tMachine = machine
	local tPlayer = zclib.Player.GetOwner(tMachine)
	tMachine.Wait = true

	timer.Simple(0.1, function()
		if (IsValid(tMachine)) then
			local ent = ents.Create("zrush_machinecrate")
			local pos = tMachine:GetPos()

			if (tMachine.MachineID ~= "Refinery") then
				local hole = tMachine:GetHole()

				if (IsValid(hole)) then
					pos = hole:GetPos()
				end
			end

			ent:SetAngles(tMachine:GetAngles())
			ent:SetPos(pos + Vector(0, 0, 50))
			ent:Spawn()
			ent:Activate()
			zclib.Player.SetOwner(ent, tPlayer)

			local installedModules = zrush.Modules.Get(tMachine)
			-- Here we add all the module info too the  crate
			zrush.Machinecrate.AddModules(ent, installedModules)
			ent:SetMachineID(zrush.Machine.FindConfigByClass(tMachine:GetClass()))
			SafeRemoveEntity(tMachine)
		end
	end)
end
