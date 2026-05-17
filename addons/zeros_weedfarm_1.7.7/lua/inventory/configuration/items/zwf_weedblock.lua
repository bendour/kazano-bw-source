local ITEM = XeninInventory:CreateItemV2()
ITEM:SetMaxStack(1)
ITEM:SetModel("models/zerochain/props_weedfarm/zwf_weedblock.mdl")
ITEM:SetDescription("A block of weed")

ITEM:AddDrop(function(self, ply, ent, tbl, tr)
	local data = tbl.data

	ent:SetWeedID(data.WeedID)
	ent:SetWeedName(data.WeedName)
	ent:SetWeedAmount(data.WeedAmount)
	ent:SetTHC(data.THC)

	zwf.f.SetOwnerByID(ent, data.ZWFOwner)
end)

function ITEM:GetData(ent)
	return {
		WeedID = ent:GetWeedID(),
		WeedName = ent:GetWeedName(),
		WeedAmount = ent:GetWeedAmount(),
		THC = ent:GetTHC(),
		ZWFOwner = zwf.f.GetOwnerID(ent)
	}
end

function ITEM:GetVisualAmount(item)
	return item.data.WeedAmount
end

function ITEM:GetName(item)
	local ent = isentity(item)
	local name = ent and item:GetWeedName() or item.data.WeedName
	local plant = ent and item:GetWeedID() or item.data.WeedID
	plant = zwf.config.Plants[plant].name

	return name .. " " .. plant
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

function ITEM:GetSkin(tbl)
	return zwf.config.Plants[tbl.data.WeedID].skin
end

ITEM:Register("zwf_weedblock")
