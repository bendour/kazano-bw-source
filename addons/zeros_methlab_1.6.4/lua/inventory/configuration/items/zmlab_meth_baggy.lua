local ITEM = XeninInventory:CreateItemV2()
ITEM:SetMaxStack(1)
ITEM:SetModel("models/zerochain/zmlab/zmlab_methbag.mdl")
ITEM:SetDescription("A bag of meth.")

ITEM:AddDrop(function(self, ply, ent, tbl, tr)
	local data = tbl.data

	ent:SetMethAmount(data.MethAmount)
end)

function ITEM:GetData(ent)
	return {
		MethAmount = ent:GetMethAmount(),
	}
end

function ITEM:GetVisualAmount(item)
	return item.data.MethAmount
end

function ITEM:GetName(item)
	return "Meth baggy"
end

function ITEM:GetCameraModifiers(tbl)
	return {
		FOV = 65,
		X = 0,
		Y = -30,
		Z = 25,
		Angles = Angle(0, 15, 0),
		Pos = Vector(0, 0, -1.5)
	}
end

ITEM:Register("zmlab_meth_baggy")
