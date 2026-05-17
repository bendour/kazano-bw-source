local ITEM = XeninInventory:CreateItemV2()
ITEM:SetMaxStack(1)
ITEM:SetModel("models/zerochain/props_weedfarm/zwf_bong01.mdl")
ITEM:SetDescription("A Bong")

ITEM:AddDrop(function(self, ply, ent, tbl, tr)
	local data = tbl.data

	ent:SetIsBurning(data.IsBurning)

	ent:SetWeedID(data.WeedID)
	ent:SetWeed_Name(data.WeedName)
	ent:SetWeed_Amount(data.WeedAmount)
	ent:SetWeed_THC(data.THC)
end)

function ITEM:GetData(ent)
	return {
		IsBurning = ent:GetIsBurning(),
		WeedID = ent:GetWeedID(),
		WeedName = ent:GetWeed_Name(),
		WeedAmount = ent:GetWeed_Amount(),
		THC = ent:GetWeed_THC(),
	}
end

function ITEM:GetVisualAmount(item)
	return item.data.WeedAmount
end

function ITEM:GetName(item)
	local ent = isentity(item)
	local weedID = ent and item:GetWeedID() or item.data.WeedID
	local str = "Empty"

	if weedID > 0 then
		local weedName = ent and item:GetWeed_Name() or item.data.WeedName
		str = weedName

		local plant = zwf.config.Plants[weedID]
		if (plant and plant.name) then
			str = str .. " [" .. plant.name .. "]"
		end
	end

	return str
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
	if tbl.data.IsBurning then
		mdlPanel.Entity:SetSkin(1)
	end
end


ITEM:Register("zwf_bong01_ent")
