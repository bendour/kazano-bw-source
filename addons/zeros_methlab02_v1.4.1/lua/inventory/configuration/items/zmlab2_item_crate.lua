/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.1 (stable)
*/

local ITEM = XeninInventory:CreateItemV2()
ITEM:SetMaxStack(1)
ITEM:SetModel("models/zerochain/props_methlab/zmlab2_crate.mdl")
ITEM:SetDescription(function(self, tbl)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

	local MethType = tbl.data.MethType
	local desc = ""
	if zmlab2.config.MethTypes[MethType] and zmlab2.config.MethTypes[MethType].desc then
		desc = zmlab2.config.MethTypes[MethType].desc
	end

	return {
		"Quality: " .. tbl.data.MethQuality .. "%",
		"Info: " .. desc,
	}
end)

ITEM:AddDrop(function(self, ply, ent, tbl, tr)
	local data = tbl.data

	ent:SetMethType(data.MethType)
	ent:SetMethAmount(data.MethAmount)
	ent:SetMethQuality(data.MethQuality)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

	zclib.Player.SetOwner(ent, ply)
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 99958388d5b8bc21e4d7af1df39fd75077f0660617b3c526ce40ea9691a5fd3b

function ITEM:GetData(ent)
	return {
		MethType = ent:GetMethType(),
		MethAmount = ent:GetMethAmount(),
		MethQuality = ent:GetMethQuality(),
	}
end

function ITEM:GetVisualAmount(item)
	return item.data.MethAmount
end

function ITEM:GetDisplayName(item)
	return self:GetName(item)
end

function ITEM:GetName(item)
	local name = "Unkown"

	local ent = isentity(item)
	local MethType = ent and item:GetMethType() or item.data.MethType
	//local MethAmount = ent and item:GetMethAmount() or item.data.MethAmount
	//local MethQuality = ent and item:GetMethQuality() or item.data.MethQuality

	if zmlab2.config.MethTypes[MethType] and zmlab2.config.MethTypes[MethType].name then
		name = zmlab2.config.MethTypes[MethType].name//.. " " .. (MethQuality or 0) .. "%"
	end

	return name
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

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
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 99958388d5b8bc21e4d7af1df39fd75077f0660617b3c526ce40ea9691a5fd3b

function ITEM:GetClientsideModel(tbl, mdlPanel)
	local MethMat = zmlab2.Meth.GetMaterial(tbl.data.MethType,tbl.data.MethQuality)
	if MethMat then
		mdlPanel.Entity:SetSubMaterial(0, "!" .. MethMat)
	end

	local cur_amount = tbl.data.MethAmount
	if cur_amount <= 0 then
		mdlPanel.Entity:SetBodygroup(0, 5)
	else
		local bg = math.Clamp(5 - math.Round((5 / zmlab2.config.Crate.Capacity) * cur_amount), 1, 5)
		mdlPanel.Entity:SetBodygroup(0, bg)
	end
end

ITEM:Register("zmlab2_item_crate")
