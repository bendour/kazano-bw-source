/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

local ITEM = XeninInventory:CreateItemV2()
ITEM:SetMaxStack(1)
ITEM:SetModel("models/zerochain/props_pumpkinnight/zpn_candydrop.mdl")
ITEM:SetDescription("Sweet Sweet Candy!")

ITEM:AddDrop(function(self, ply, ent, tbl, tr)
	local data = tbl.data

	ent:SetCandy(data.Candy)
	ent:SetModel("models/zerochain/props_pumpkinnight/zpn_candydrop.mdl")
	ent:SetDisplayCandy(true)
	ent:SetColor(zpn.Theme.Design.color03)
	zclib.Player.SetOwner(ent, ply)
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d

function ITEM:GetData(ent)
	return {
		Candy = ent:GetCandy(),
	}
end

function ITEM:GetCameraModifiers(tbl)
	return {
		FOV = 40,
		X = 0,
		Y = -22,
		Z = 25,
		Angles = Angle(0, 0, 0),
		Pos = Vector(0, 0, -1)
	}
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d

function ITEM:GetVisualAmount(item)
	return item.data.Candy
end

function ITEM:GetDisplayName(item)
	return self:GetName(item)
end

function ITEM:GetName(item)
	local name = "Candy"

	return name
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d

function ITEM:GetClientsideModel(tbl, mdlPanel)
	mdlPanel:SetColor(zpn.Theme.Design.color03)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d

ITEM:Register("zpn_candy")
