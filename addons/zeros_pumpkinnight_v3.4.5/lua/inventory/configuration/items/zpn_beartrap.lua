/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

local ITEM = XeninInventory:CreateItemV2()
ITEM:SetMaxStack(1)
ITEM:SetModel("models/zerochain/props_saw/modern_beartrap.mdl")
ITEM:SetDescription("A prank item.")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- da71c7e0bf5016ce33a9f318a3747fb53331bb70d9090f016fdcc745ceefa6b8

ITEM:AddDrop(function(self, ply, ent, tbl, tr)
	zclib.Player.SetOwner(ent, ply)
	ent.TrapOwner = ply
end)

function ITEM:OnPickup(ply, ent)
	if (not IsValid(ent)) then return end
	if ply ~= ent.TrapOwner then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

	local info = {
		ent = self:GetEntityClass(ent),
		dropEnt = self:GetDropEntityClass(ent),
		amount = self:GetEntityAmount(ent),
		data = self:GetData(ent)
	}

	self:Pickup(ply, ent, info)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- da71c7e0bf5016ce33a9f318a3747fb53331bb70d9090f016fdcc745ceefa6b8

	return true
end

function ITEM:GetName(item)
	return "Brainteaser Beartrap"
end

function ITEM:GetCameraModifiers(tbl)
	return {
		FOV = 30,
		X = 0,
		Y = 0,
		Z = 25,
		Angles = Angle(0, 0, 0),
		Pos = Vector(0, 0, 0)
	}
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 6af6efba71e4015ff987fc919ecacbe102ec0873079409ab2a0ed0bf25e3f3cd
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a2b46fa362cff6519809e40cc8d153299c414b52d9b8c3759ca38e67d8a7d851

ITEM:Register("zpn_beartrap")
