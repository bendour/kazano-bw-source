ITEM.Name = "Joint"
ITEM.Description = "A Joint"
ITEM.Model = "models/zerochain/props_weedfarm/zwf_joint.mdl"
ITEM.Base = "base_darkrp"
ITEM.Stackable = false
ITEM.DropStack = false

function ITEM:GetName()
	local name = self:GetData("WeedName") .. " " .. self:GetData("WeedAmount") .. zwf.config.UoW .. "\n[" .. zwf.config.Plants[self:GetData("WeedID")].name .. "]"

	return self:GetData("Name", name)
end

function ITEM:SaveData(ent)
	self:SetData("WeedID", ent:GetWeedID())
	self:SetData("WeedName", ent:GetWeed_Name())
	self:SetData("WeedAmount", ent:GetWeed_Amount())
	self:SetData("THC", ent:GetWeed_THC())
end

function ITEM:LoadData(ent)
	ent:SetWeedID(self:GetData("WeedID"))
	ent:SetWeed_Name(self:GetData("WeedName"))
	ent:SetWeed_Amount(self:GetData("WeedAmount"))
	ent:SetWeed_THC(self:GetData("THC"))
end
