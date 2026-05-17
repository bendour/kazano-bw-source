/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

local ITEM = XeninInventory:CreateItemV2()
ITEM:SetMaxStack(10)
ITEM:SetModel("models/zerochain/props_pumpkinnight/zpn_partypopper.mdl")
ITEM:SetDescription("A powerful weapon against pumpkins!")
ITEM:AddDrop(function(self, ply, ent, tbl, tr)
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a2b46fa362cff6519809e40cc8d153299c414b52d9b8c3759ca38e67d8a7d851

function ITEM:GetCameraModifiers(tbl)
	return {
		FOV = 17,
		X = 0,
		Y = -22,
		Z = 25,
		Angles = Angle(0, 0, 0),
		Pos = Vector(0, 0, -1)
	}
end

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a2b46fa362cff6519809e40cc8d153299c414b52d9b8c3759ca38e67d8a7d851

function ITEM:GetClientsideModel(tbl, mdlPanel)
	mdlPanel.Entity:SetSkin(1)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 6af6efba71e4015ff987fc919ecacbe102ec0873079409ab2a0ed0bf25e3f3cd

function ITEM:GetDisplayName(item)
	return self:GetName(item)
end

function ITEM:GetName(item)
	local name = "Partypopper - Weapon"

	return name
end

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 6af6efba71e4015ff987fc919ecacbe102ec0873079409ab2a0ed0bf25e3f3cd

ITEM:Register("zpn_partypopper01")
