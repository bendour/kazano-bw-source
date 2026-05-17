local ITEM = XeninInventory:CreateItemV2()
ITEM:SetMaxStack(1)
ITEM:SetModel("models/zerochain/props_weedfarm/zwf_jar.mdl")
ITEM:SetDescription("A jar of weed")

ITEM:AddDrop(function(self, ply, ent, tbl, tr)
	local data = tbl.data

	ent:SetPlantID(data.PlantID)
	ent:SetWeedName(data.WeedName)
	ent:SetWeedAmount(data.WeedAmount)
	ent:SetTHC(data.THC)

	ent:SetPerf_Time(data.Perf_Time)
	ent:SetPerf_Amount(data.Perf_Amount)
	ent:SetPerf_THC(data.Perf_THC)

	zwf.f.SetOwnerByID(ent, data.ZWFOwner)
end)

function ITEM:GetData(ent)
	return {
		PlantID = ent:GetPlantID(),
		WeedName = ent:GetWeedName(),
		WeedAmount = math.Round(ent:GetWeedAmount()),
		THC = ent:GetTHC(),
		Perf_Time = ent:GetPerf_Time(),
		Perf_Amount = ent:GetPerf_Amount(),
		Perf_THC = ent:GetPerf_THC(),
		ZWFOwner = zwf.f.GetOwnerID(ent)
	}
end

function ITEM:GetVisualAmount(item)
	return item.data.WeedAmount
end

function ITEM:GetName(item)
	local ent = isentity(item)
	local weedName = ent and item:GetWeedName() or item.data.WeedName
	local plant = ent and item:GetPlantID() or item.data.PlantID
	plant = zwf.config.Plants[plant]
	plant = plant and plant.name or "Unknown plant"

	return weedName .. " [" .. plant .. "]"
end

function ITEM:GetCameraModifiers(tbl)
	return {
		FOV = 40,
		X = 0,
		Y = -22,
		Z = 25,
		Angles = Angle(0, -190, 0),
		Pos = Vector(0, 0, -1)
	}
end

function ITEM:GetClientsideModel(tbl, mdlPanel)
	local weed_data = zwf.config.Plants[tbl.data.PlantID]
	local weed_amount = tbl.data.WeedAmount

	mdlPanel.Entity:SetBodygroup(1, 0)
	mdlPanel.Entity:SetBodygroup(2, 0)
	mdlPanel.Entity:SetBodygroup(3, 0)

	if weed_amount <= zwf.config.Jar.Capacity / 3 then
		mdlPanel.Entity:SetBodygroup(1, 1)
	elseif weed_amount <= (zwf.config.Jar.Capacity / 3) * 2 then
		mdlPanel.Entity:SetBodygroup(1, 1)
		mdlPanel.Entity:SetBodygroup(2, 1)
	else
		mdlPanel.Entity:SetBodygroup(1, 1)
		mdlPanel.Entity:SetBodygroup(2, 1)
		mdlPanel.Entity:SetBodygroup(3, 1)
	end

	mdlPanel.Entity:SetSkin(weed_data.skin)
end

ITEM:Register("zwf_jar")
