local ITEM = XeninInventory:CreateItemV2()
ITEM:SetMaxStack(1)
ITEM:SetModel("models/zerochain/zmlab/zmlab_transportcrate.mdl")
ITEM:SetDescription("A crate used for transporting meth.")

ITEM:AddDrop(function(self, ply, ent, tbl, tr)
	local data = tbl.data

	ent:SetMethAmount(data.MethAmount)
	zmlab.f.TransportCrate_XeninDrop(ent)
	zmlab.f.SetOwner(ent, ply)
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
	return "Transport Crate"
end

function ITEM:GetCameraModifiers(tbl)
	return {
		FOV = 40,
		X = 0,
		Y = -30,
		Z = 25,
		Angles = Angle(0, 15, 0),
		Pos = Vector(0, 0, -1.5)
	}
end

function ITEM:GetClientsideModel(tbl, mdlPanel)
	local methAmount = tbl.data.MethAmount

	if methAmount >= zmlab.config.TransportCrate.Capacity then
		mdlPanel.Entity:SetModel("models/zerochain/zmlab/zmlab_transportcrate_full.mdl")
	elseif methAmount > zmlab.config.TransportCrate.Capacity * 0.7 then
		mdlPanel.Entity:SetBodygroup(0, 3)
	elseif methAmount > zmlab.config.TransportCrate.Capacity * 0.5 then
		mdlPanel.Entity:SetBodygroup(0, 2)
	elseif methAmount <= 0 then
		mdlPanel.Entity:SetBodygroup(0, 0)
	else
		mdlPanel.Entity:SetBodygroup(0, 1)
	end
end


ITEM:Register("zmlab_collectcrate")
