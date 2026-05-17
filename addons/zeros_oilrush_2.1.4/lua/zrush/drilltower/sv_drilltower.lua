if CLIENT then return end
zrush = zrush or {}
zrush.DrillTower = zrush.DrillTower or {}

function zrush.DrillTower.Initialize(DrillTower)
	zclib.Debug("zrush.DrillTower.Initialize")

	DrillTower:SetModel("models/zerochain/props_oilrush/zor_drilltower.mdl")
	DrillTower:PhysicsInit(SOLID_VPHYSICS)
	DrillTower:SetMoveType(MOVETYPE_VPHYSICS)
	DrillTower:SetSolid(SOLID_VPHYSICS)
	DrillTower:SetUseType(SIMPLE_USE)

	if (zrush.config.Machine_NoCollide) then
		DrillTower:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	end

	local phys = DrillTower:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:EnableMotion(false)
		phys:EnableDrag(true)
		phys:SetDragCoefficient(0.99)
		phys:SetAngleDragCoefficient(0.99)
		phys:SetMass(150)
	end

	DrillTower:UseClientSideAnimation()

	DrillTower.PhysgunDisabled = true
	DrillTower.IsConstructing = false

	zrush.Modules.Setup(DrillTower)

	zrush.Machine.SetState(ZRUSH_STATE_IDLE, DrillTower)

	zclib.EntityTracker.Add(DrillTower)
end

// Called when a player presses e on the drilltower
function zrush.DrillTower.OnUse(DrillTower,ply)
	zclib.Debug("zrush.DrillTower.OnUse")
	if (DrillTower.Wait or false) then return end

	// If the Tower is constructing then we dont allow any interaction
	if DrillTower.IsConstructing == true then return end

	zrush.Machine.OpenUI(DrillTower,ply)
end

function zrush.DrillTower.OnTouch(DrillTower, other)
	zclib.Debug("zrush.DrillTower.OnTouch")
	if not IsValid(DrillTower) then return end
	if not IsValid(other) then return end
	if other:GetClass() ~= "zrush_drillpipe_holder" then return end
	if zclib.util.CollisionCooldown(other) then return end
	if DrillTower.IsDeconstructing then return end

	zrush.DrillTower.AddPipesHolder(DrillTower,other)
end


////////////////////////////////////////////
///////////////// SETUP /////////////////////
////////////////////////////////////////////

// Called after the DrillTower got build
function zrush.DrillTower.PostBuild(DrillTower, ply, BuildOnEntity)
	zclib.Debug("zrush.DrillTower.PostBuild")
	if (IsValid(BuildOnEntity) and BuildOnEntity:GetClass() == "zrush_oilspot") then
		zrush.DrillTower.SnapSetup(DrillTower, BuildOnEntity, ply)
		return
	end

	if (IsValid(BuildOnEntity) and BuildOnEntity:GetClass() == "zrush_drillhole") then

		zrush.DrillTower.SnapTower(DrillTower, ply, BuildOnEntity)
		return
	end

	if (zrush.config.Drill_Mode == 0) then
		zrush.DrillTower.TraceSetup(DrillTower, ply)
	end
end

//This snaps the drill to a existing drillhole
function zrush.DrillTower.SnapTower(DrillTower,ply, hole)
	zclib.Debug("zrush.DrillTower.SnapTower")
	if not zrush.DrillHole.IsOccupied(hole) and hole:GetState() ~= ZRUSH_STATE_NEEDBURNER or hole:GetState() ~= ZRUSH_STATE_PUMPREADY then

		DrillTower:SetHole(hole)

		hole:SetParent(DrillTower)

		zrush.DrillHole.HadInteraction(hole)

		if (hole:GetState() == ZRUSH_STATE_PUMPREADY) then
			zrush.Machine.SetState(ZRUSH_STATE_FINISHEDDRILLING, DrillTower)
		else
			zrush.Machine.SetState(ZRUSH_STATE_NEEDPIPES, DrillTower)
		end

		zclib.NetEvent.Create("zrush_action_building", {DrillTower})
	else
		zrush.Notify(ply, zrush.language["NoDrillholeFound"], 1)
	end
end

// This uses traces do create a new drill hole correctly
function zrush.DrillTower.TraceSetup(DrillTower,ply)
	zclib.Debug("zrush.DrillTower.TraceSetup")
	DrillTower.PhysgunDisabled = true
	DrillTower.IsConstructing = true
	DrillTower:GetPhysicsObject():EnableMotion(false)
	local tr

	timer.Simple(0.1, function()
		if (IsValid(DrillTower)) then
			local tracedata = {}
			tracedata.start = DrillTower:GetPos()
			tracedata.endpos = DrillTower:GetPos() + DrillTower:GetUp() * -1000
			tracedata.filter = DrillTower
			tracedata.mask = MASK_SOLID_BRUSHONLY
			tr = util.TraceLine(tracedata)
			DrillTower:SetPos(tr.HitPos)
			local validAng = tr.HitNormal:Angle()
			validAng:RotateAroundAxis(validAng:Right(), -90)
			validAng:RotateAroundAxis(validAng:Up(), 90)
			DrillTower:SetAngles(validAng)
		end
	end)

	timer.Simple(0.2, function()
		if (IsValid(DrillTower)) then

			local hole = zrush.DrillHole.Create(DrillTower,ply)
			hole:SetParent(DrillTower)
			zrush.Machine.SetState(ZRUSH_STATE_NEEDPIPES, DrillTower)
		end
	end)

	timer.Simple(0.5, function()
		if (IsValid(DrillTower)) then

			zclib.NetEvent.Create("zrush_action_building", {DrillTower})

			DrillTower.IsConstructing = false
		end
	end)
end

// This searches and returns a oilspot
function zrush.DrillTower.FindFreeOilSpot(DrillTower)
	zclib.Debug("zrush.DrillTower.FindFreeOilSpot")

	local find = ents.FindByClass("zrush_oilspot")
	local ValidOilSpot = nil
	local nearestD = zrush.config.Machine["Drill"].SearchRadius

	for k, v in pairs(find) do
		local loDis = v:GetPos():Distance(DrillTower:GetPos())

		if (loDis < nearestD and v.InUse == false and v.NoOil_TimeStamp == -1) then
			ValidOilSpot = v
			nearestD = loDis
		end
	end

	return ValidOilSpot
end

// This creates a drill hole on a oilspot
function zrush.DrillTower.SnapSetup(DrillTower,oilspot,ply)
	zclib.Debug("zrush.DrillTower.SnapSetup")
	if IsValid(oilspot) then

		DrillTower.IsConstructing = true

		local hole = zrush.DrillHole.Create(DrillTower,ply)
		zclib.NetEvent.Create("zrush_action_building", {DrillTower})

		// This tells the oilspot that there is a drillhole on it
		zrush.OilSpot.Drill(oilspot,hole)

		hole:SetParent(DrillTower)

		zrush.Machine.SetState(ZRUSH_STATE_NEEDPIPES, DrillTower)

		DrillTower.IsConstructing = false
	else
		zrush.Notify(ply, zrush.language["NoOilSpotFound"], 1)
	end
end

// Called when the drill gets Deconstructed
function zrush.DrillTower.Deconstruct(DrillTower)
	zclib.Debug("zrush.DrillTower.Deconstruct")
	zrush.DrillTower.DropPipeHolders(DrillTower,DrillTower:GetPipes())
	local dHole = DrillTower:GetHole()
	if IsValid(dHole) then
		dHole:SetParent(nil)
	end
end
////////////////////////////////////////////
////////////////////////////////////////////




////////////////////////////////////////////
/////////// ModuleChanged Logic ////////////
////////////////////////////////////////////

// This gets called if a new module is installed
function zrush.DrillTower.ModulesChanged(DrillTower)
	zclib.Debug("zrush.DrillTower.ModulesChanged")
	// This checks if we have more pipes then the limit in out drill and removes pipes
	zrush.DrillTower.UpdateMaxPipes(DrillTower)

	// This resets the drill timer do be sure he has the right time if a speed module got installed
	if (DrillTower:IsRunning()) then
		zrush.DrillTower.Start(DrillTower)
	end

	// The Updates the Pitch of the Looped Sound on CLIENT
	zrush.Machine.UpdateSound(DrillTower)
end

// This checks if we have more pipes then the limit in our drill and removes pipes
function zrush.DrillTower.UpdateMaxPipes(DrillTower)
	zclib.Debug("zrush.DrillTower.UpdateMaxPipes")
	local PipesInMachine = DrillTower:GetPipes()
	local maxPipes = DrillTower:GetBoostValue("pipes")

	// If we have more pipes in the Queue then we can carry then we remove some
	if (PipesInMachine > maxPipes) then
		local diff = PipesInMachine - maxPipes
		zrush.DrillTower.DropPipeHolders(DrillTower,diff)
		DrillTower:SetPipes(maxPipes)
	end
end
////////////////////////////////////////////
////////////////////////////////////////////




////////////////////////////////////////////
/////////////// Drill Logic ////////////////
////////////////////////////////////////////

// This Toggles the work status of the machine
function zrush.DrillTower.Toggle(DrillTower,ply)
	zclib.Debug("zrush.DrillTower.Toggle")
	if (DrillTower:GetState() == ZRUSH_STATE_FINISHEDDRILLING) then
		zrush.Notify(ply, zrush.language["AllreadyReachedOil"], 1)
		return
	end

	if DrillTower:GetPipes() <= 0 then
		zrush.Notify(ply, zrush.language["DrillPipesMissing"], 1)
		return
	end

	if DrillTower:IsRunning() then
		zrush.DrillTower.Stop(DrillTower)
	else
		zrush.DrillTower.Start(DrillTower)
	end

	// This sends a UI update message do all players
	zrush.Machine.UpdateUI(DrillTower, true)
end

// This AutoStarts the machine if we have everything we need
function zrush.DrillTower.AutoStart(DrillTower)
	zclib.Debug("zrush.DrillTower.AutoStart")
	local sHole = DrillTower:GetHole()
	if DrillTower:GetPipes() > 0 and DrillTower:IsJammed() == false and IsValid(sHole) and sHole:GetPipes() < sHole:GetNeededPipes() then
		zrush.DrillTower.Start(DrillTower)
	end
end

// This Starts the Drilling
function zrush.DrillTower.Start(DrillTower)
	zclib.Debug("zrush.DrillTower.Start")
	// Do we still have pipes?
	if (DrillTower:GetPipes() <= 0) then
		zrush.Machine.SetState(ZRUSH_STATE_NEEDPIPES, DrillTower)

		return
	end

	if not DrillTower:IsJammed() then

		zrush.Machine.SetState(ZRUSH_STATE_ISDRILLING, DrillTower)

		// This sends a UI update message do all players
		zrush.Machine.UpdateUI(DrillTower, false)

		// If we did not reach our depth then just reset the drill animation and wait for the timer
		local currentSpeed = DrillTower:GetBoostValue("speed")

		local timerid = "zrush_working_" .. DrillTower:EntIndex()
		zclib.Timer.Remove(timerid)
		zclib.Timer.Create(timerid, currentSpeed, 0, function()
			if IsValid(DrillTower) then
				zrush.DrillTower.Complete(DrillTower)
			end
		end)

		zclib.NetEvent.Create("zrush_drill_anim_drilldown", {DrillTower})
	end
end

// This Stops a drill cycle
function zrush.DrillTower.Stop(DrillTower)
	zclib.Debug("zrush.DrillTower.Stop")

	zclib.Timer.Remove("zrush_working_" .. DrillTower:EntIndex())

	local sHole = DrillTower:GetHole()

	if (IsValid(sHole)) then
		if (sHole:GetPipes() < sHole:GetNeededPipes() and DrillTower:GetPipes() <= 0) then
			zrush.Machine.SetState(ZRUSH_STATE_NEEDPIPES, DrillTower)
		elseif (sHole:GetPipes() < sHole:GetNeededPipes() and DrillTower:GetPipes() > 0) then
			zrush.Machine.SetState(ZRUSH_STATE_READYFORWORK, DrillTower)
		else
			zrush.Machine.SetState(ZRUSH_STATE_FINISHEDDRILLING, DrillTower)
		end
	else
		zrush.Machine.SetState(ZRUSH_STATE_IDLE, DrillTower)
	end

	zclib.Animation.Play(DrillTower, "idle", 1)
	zclib.NetEvent.Create("zrush_drill_anim_idle", {DrillTower})

	// This sends a UI update message do all players
	zrush.Machine.UpdateUI(DrillTower, true)
end

//This function gets called when we complete a drill cycle
function zrush.DrillTower.Complete(DrillTower)
	zclib.Debug("zrush.DrillTower.Complete")
	if (DrillTower:IsJammed()) then return end
	local sHole = DrillTower:GetHole()
	if not IsValid(sHole) then return end

	// Adds a pipe do our hole
	zrush.DrillHole.AddPipe(sHole)
	local pipes = DrillTower:GetPipes()
	local newC = math.Clamp(pipes - 1, 0, 1000)
	DrillTower:SetPipes(newC)
	zclib.Debug("Drill Cycle Complete (" .. DrillTower:EntIndex() .. ") " .. newC .. " pipes left")

	zclib.NetEvent.Create("zrush_drill_cycle_complete", {DrillTower})

	// This sends a UI update message do all players
	zrush.Machine.UpdateUI(DrillTower, false,true)

	// Did we reach the the required Depth
	if sHole:GetPipes() >= sHole:GetNeededPipes() then
		zrush.DrillTower.Finished(DrillTower)
	else
		// If we did not reach our depth then just reset the drill animation and wait for the timer
		zclib.NetEvent.Create("zrush_drill_anim_drilldown", {DrillTower})

		// Do we still have pipes in the machine?
		if newC <= 0 then
			zrush.DrillTower.Stop(DrillTower)
		end
	end
end

// This function gets called when we fnished drilling
function zrush.DrillTower.Finished(DrillTower)
	zclib.Debug("zrush.DrillTower.Finished")
	zrush.Machine.SetState(ZRUSH_STATE_FINISHEDDRILLING, DrillTower)
	zrush.DrillTower.Stop(DrillTower)

	// If we hole has gas then we remove ourDrillTower
	if zrush.DrillHole.HasGas(DrillTower:GetHole()) then

		zclib.NetEvent.Create("zrush_action_deconnect", {DrillTower})

		// Call some custom stuff for the specific machine
		DrillTower:Deconstruct()

		// This makes the machine too a box
		zrush.Machinecrate.DeConstruct(DrillTower)

		// Close the interface for any person who uses the machine right now
		zrush.Machine.CloseUI(DrillTower)
	end
end
////////////////////////////////////////////
////////////////////////////////////////////




////////////////////////////////////////////
/////////// DrillPipes Add/Remove //////////
////////////////////////////////////////////

// This spawns a pipeholder
function zrush.DrillTower.SpawnPipeHolders(DrillTower,pos, amount)
	zclib.Debug("zrush.DrillTower.SpawnPipeHolders")
	local ent = ents.Create("zrush_drillpipe_holder")
	ent:SetAngles(Angle(0, 0, 0))
	ent:SetPos(pos)
	ent:Spawn()
	ent:Activate()
	ent:SetPipeCount(amount)
	local ply = zclib.Player.GetOwner(DrillTower)

	if (ply) then
		zclib.Player.SetOwner(ent, ply)
	end

	return ent
end

// This drops the specified amount of pipes
function zrush.DrillTower.DropPipeHolders(DrillTower,PipeCount)
	zclib.Debug("zrush.DrillTower.DropPipeHolders")
	if (PipeCount > 0) then
		// Do we have more pipes as the max capacity as a pipeholder can hold?
		if (PipeCount > 10) then
			local totalPipes = PipeCount
			local HolderCount = totalPipes / 10
			local full_HolderCount = math.floor(HolderCount)

			// This spawns the full pipeholders
			for i = 1, full_HolderCount do

				zrush.DrillTower.SpawnPipeHolders(DrillTower,DrillTower:LocalToWorld(Vector(40, 0, 50 * i)), 10)
			end

			local restamount = totalPipes - (full_HolderCount * 10)

			if (restamount > 0) then
				// This spawns the rest amount in a holder
				zrush.DrillTower.SpawnPipeHolders(DrillTower,DrillTower:LocalToWorld(Vector(40, 0, 50)), restamount)
			end
		else

			zrush.DrillTower.SpawnPipeHolders(DrillTower,DrillTower:LocalToWorld(Vector(40, 0, 50)), PipeCount)
		end
	end
end

// This functions adds a pipeholder in the tower
function zrush.DrillTower.AddPipesHolder(DrillTower,pipeholder)
	zclib.Debug("zrush.DrillTower.AddPipesHolder")
	if DrillTower:IsJammed() then return end
	if DrillTower:GetState() == ZRUSH_STATE_FINISHEDDRILLING then return end
	if DrillTower:GetState() == ZRUSH_STATE_JAMMED then return end

	if (CurTime() < (DrillTower.LastPipesAdd or 0)) then
		return
	end

	DrillTower.LastPipesAdd = CurTime() + 1

	local pipes = DrillTower:GetPipes()
	local maxPipe = DrillTower:GetBoostValue("pipes")

	// Do we need pipes?
	if pipes < maxPipe then
		// PipesCount the holder has
		local pipeholderPipes = pipeholder:GetPipeCount()
		// The Amount we need
		local needAmount = maxPipe - pipes
		// The Amount we add
		local addAmount = 1

		if (pipeholderPipes > needAmount) then
			addAmount = needAmount
			pipeholder:SetPipeCount(pipeholderPipes - addAmount)
		else
			pipeholder:SetPipeCount(0)
			addAmount = pipeholderPipes
		end

		if pipeholder:GetPipeCount() <= 0 then
			SafeRemoveEntity(pipeholder)
		end

		zclib.NetEvent.Create("zrush_drill_loadpipe", {DrillTower})
		zclib.NetEvent.Create("zrush_action_deconnect", {DrillTower})

		DrillTower:SetPipes(DrillTower:GetPipes() + addAmount)
		zclib.Debug("Added a pipes " .. addAmount)

		if not DrillTower:IsRunning() then
			zrush.Machine.SetState(ZRUSH_STATE_READYFORWORK, DrillTower)
		end

		zrush.DrillTower.AutoStart(DrillTower)
	end
end
////////////////////////////////////////////
////////////////////////////////////////////




////////////////////////////////////////////
////////////// Jammed Event ////////////////
////////////////////////////////////////////
// For The Jam Event
function zrush.DrillTower.OnJamEvent(DrillTower)
	zclib.Debug("zrush.DrillTower.OnJamEvent")
	zclib.Timer.Remove("zrush_working_" .. DrillTower:EntIndex())
	// Play Jam Animation
	zclib.NetEvent.Create("zrush_drill_anim_jammed", {DrillTower})
end

function zrush.DrillTower.OnJamFixed(DrillTower)
	zclib.Debug("zrush.DrillTower.OnJamFixed")
	// Start the machine again
	zrush.DrillTower.Start(DrillTower)
end
////////////////////////////////////////////
////////////////////////////////////////////
