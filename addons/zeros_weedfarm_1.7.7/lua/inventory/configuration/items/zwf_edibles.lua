local ITEM = XeninInventory:CreateItemV2()
ITEM.Name = "Muffin"
ITEM:SetMaxStack(1)
ITEM:SetModel("models/zerochain/props_weedfarm/zwf_muffin.mdl")
ITEM:SetDescription(function(self, tbl)

	local data = tbl.data

	local desc = ""
	if (data.WeedID ~= -1) then
		desc = "A tasty Muffin with traces of weed"
	else
		desc = "A tasty Muffin"
	end

	local edible_id = data.EdibleID
	if edible_id and zwf.config.Cooking.edibles[edible_id] and zwf.config.Cooking.edibles[edible_id].name then
		desc = string.Replace(desc, "Muffin", zwf.config.Cooking.edibles[edible_id].name)
	end

	return desc
end)

ITEM:AddDrop(function(self, ply, ent, tbl, tr)
	local data = tbl.data
	ent.EdibleID = data.EdibleID
	ent.WeedID = data.WeedID
	ent.WeedName = data.WeedName
	ent.WeedAmount = data.WeedAmount
	ent.WeedTHC = data.THC
	ent:SetColor(data.color)

	if (ent.WeedID ~= -1) then
		ent:SetSkin(1)
	end

	if ent.EdibleID and zwf.config.Cooking.edibles[ent.EdibleID] and zwf.config.Cooking.edibles[ent.EdibleID].edible_model then
		ent:SetModel(zwf.config.Cooking.edibles[ent.EdibleID].edible_model)
	end
end)

function ITEM:GetData(ent)
	return {
		EdibleID = ent.EdibleID,
		WeedID = ent.WeedID,
		WeedName = ent.WeedName,
		WeedAmount = math.Round(ent.WeedAmount),
		THC = math.Round(ent.WeedTHC),
		color = ent:GetColor()
	}
end

function ITEM:GetName(item)
	local ent = isentity(item)

	local name = ""

	local edible_id

	if ent then
		edible_id = self.EdibleID
	else
		edible_id = item.data.EdibleID
	end

	if edible_id and zwf.config.Cooking.edibles[edible_id] and zwf.config.Cooking.edibles[edible_id].name then
		name = zwf.config.Cooking.edibles[edible_id].name .. " "
	end

	if !ent and item.data and item.data.WeedID ~= -1 then
		name = name .. "[" .. zwf.config.Plants[item.data.WeedID].name .. "]"
	end

	return name
end

function ITEM:GetDisplayName(item)
	return "Edible"
end

function ITEM:GetCameraModifiers(tbl)
	return {
		FOV = 40,
		X = 0,
		Y = -22,
		Z = 30,
		Angles = Angle(0, -190, 0),
		Pos = Vector(0, 0, -1)
	}
end

function ITEM:GetClientsideModel(tbl, mdlPanel)
	if tbl.data.EdibleID and zwf.config.Cooking.edibles[tbl.data.EdibleID] and zwf.config.Cooking.edibles[tbl.data.EdibleID].edible_model then
		mdlPanel:SetModel(zwf.config.Cooking.edibles[tbl.data.EdibleID].edible_model)
	end
	mdlPanel:SetColor(tbl.data.color)

	if (tbl.data.WeedID ~= -1) then
		mdlPanel.Entity:SetSkin(1)
	else
		mdlPanel.Entity:SetSkin(0)
	end
end

ITEM:Register("zwf_edibles")
