if CLIENT then return end
zrush = zrush or {}
zrush.OilSpot = zrush.OilSpot or {}
zrush.OilSpot.List = zrush.OilSpot.List or {}


function zrush.OilSpot.Initialize(Oilspot)
	Oilspot:SetModel("models/zerochain/props_oilrush/zor_oilspot.mdl")
	Oilspot:PhysicsInit(SOLID_VPHYSICS)
	Oilspot:SetMoveType(MOVETYPE_VPHYSICS)
	Oilspot:SetSolid(SOLID_VPHYSICS)
	Oilspot:SetUseType(SIMPLE_USE)
	Oilspot:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	Oilspot:DrawShadow(false)

	local phys = Oilspot:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:EnableMotion(false)
	end

	Oilspot.InUse = false
	Oilspot.NoOil_TimeStamp = -1
	Oilspot.Created_TimeStamp = CurTime() + zrush.config.OilSpot_Zone.MaxLifeTime
	Oilspot.DrillHole = nil

	table.insert(zrush.OilSpot.List,Oilspot)

	zclib.EntityTracker.Add(Oilspot)
end

function zrush.OilSpot.OnRemove(Oilspot)
	table.RemoveByValue(zrush.OilSpot.List,Oilspot)
end

// Connects the OilSpot with a DrillHole
function zrush.OilSpot.Drill(Oilspot,Drillhole)
	Oilspot.InUse = true
	Oilspot:SetNoDraw(true)
	Oilspot.DrillHole = Drillhole
	Oilspot:SetHasDrillHole(true)
	Drillhole.OilSpot = Oilspot
end

// Sets the time at which the oilspot got closed for later refresh
function zrush.OilSpot.Close(Oilspot)
	Oilspot.NoOil_TimeStamp = CurTime() + zrush.config.OilSpot.Cooldown
end

// Checks if the Oilspot is ready to get refreshed
function zrush.OilSpot.ReadyForRefresh(Oilspot)
	if not Oilspot.DrillHole:HasPump() and not Oilspot.DrillHole:HasDrill() and not Oilspot.DrillHole:HasBurner() then
		return true
	else
		return false
	end
end

// Called to correctly remove the oilspot
function zrush.OilSpot.Remove(Oilspot)
	zclib.Debug(Oilspot:EntIndex() .. " OilSpot got removed!")
	if IsValid(Oilspot.DrillHole) then
		SafeRemoveEntity(Oilspot.DrillHole)
	end

	SafeRemoveEntity(Oilspot)
end
