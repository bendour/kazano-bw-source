ITEM.Name = "Muffin"
ITEM.Description = "A tasty Muffin."
ITEM.Model = "models/zerochain/props_weedfarm/zwf_muffin.mdl"
ITEM.Base = "base_darkrp"
ITEM.Stackable = false
ITEM.DropStack = false

function ITEM:GetName()

	local name = ""

	local edible_id = self:GetData("EdibleID")

	if edible_id and zwf.config.Cooking.edibles[edible_id] and zwf.config.Cooking.edibles[edible_id].name then

		name = zwf.config.Cooking.edibles[edible_id].name .. " "
	end

	if self:GetData("WeedID") ~= -1 then
		name = self:GetData("WeedName") .. " " .. self:GetData("WeedAmount") .. zwf.config.UoW .. " [" .. self:GetData("THC") .. "%] \n[" .. zwf.config.Plants[self:GetData("WeedID")].name .. "]"
	end

	return self:GetData("Name", name)
end


function ITEM:GetDescription()

	local desc

	if self:GetData("WeedID") ~= -1 then
		desc = "A tasty Muffin with traces of weed."
	else
		desc = self.Description
	end

	local edible_id = self:GetData("EdibleID")
	if edible_id and zwf.config.Cooking.edibles[edible_id] and zwf.config.Cooking.edibles[edible_id].name then
		desc = string.Replace(desc, "Muffin", zwf.config.Cooking.edibles[edible_id].name)
	end

	return self:GetData("Description", desc)
end

function ITEM:GetModel()
	local edible_id = self:GetData("EdibleID")
	if edible_id and zwf.config.Cooking.edibles[edible_id] and zwf.config.Cooking.edibles[edible_id].edible_model then
		return zwf.config.Cooking.edibles[edible_id].edible_model
	else
		return "models/zerochain/props_weedfarm/zwf_muffin.mdl"
	end
end

function ITEM:SaveData(ent)
	self:SetData("EdibleID",ent.EdibleID)
	self:SetData("WeedID", ent.WeedID)
	self:SetData("WeedAmount", math.Round(ent.WeedAmount))
	self:SetData("THC", math.Round(ent.WeedTHC))
	self:SetData("WeedName", ent.WeedName)
end

function ITEM:LoadData(ent)
	timer.Simple(0.25,function()
		if IsValid(ent) then
			ent.EdibleID = self:GetData("EdibleID")
			ent.WeedID = self:GetData("WeedID")
			ent.WeedAmount = self:GetData("WeedAmount")
			ent.WeedTHC = self:GetData("THC")
			ent.WeedName = self:GetData("WeedName")

			if ent.EdibleID and zwf.config.Cooking.edibles[ent.EdibleID] and zwf.config.Cooking.edibles[ent.EdibleID].edible_model then
				ent:SetModel(zwf.config.Cooking.edibles[ent.EdibleID].edible_model)
			end

			if ent.WeedID ~= -1 then
				ent:SetSkin(1)

				ent:SetColor(zwf.config.Plants[ent.WeedID].color)
			else
				ent:SetColor(HSVToColor( math.random(0,360), 0.5, 0.85 ) )
			end
		end
	end)
end
