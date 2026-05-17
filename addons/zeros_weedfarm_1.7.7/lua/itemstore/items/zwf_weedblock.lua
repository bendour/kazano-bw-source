ITEM.Name = "Weed Block"
ITEM.Description = "A block of weed"
ITEM.Model = "models/zerochain/props_weedfarm/zwf_weedblock.mdl"
ITEM.Base = "base_darkrp"
ITEM.Stackable = false
ITEM.DropStack = false

function ITEM:GetName()
	local name = self:GetData("WeedName") .. " " .. self:GetData("WeedAmount") .. zwf.config.UoW .. "\n[" .. zwf.config.Plants[self:GetData("WeedID")].name .. "]"

	return self:GetData("Name", name)
end

function ITEM:SaveData(ent)
	self:SetData("WeedID", ent:GetWeedID())
	self:SetData("WeedName", ent:GetWeedName())
	self:SetData("WeedAmount", ent:GetWeedAmount())
	self:SetData("THC", ent:GetTHC())

	self:SetData("ZWFOwner", zwf.f.GetOwnerID(ent))
end

function ITEM:LoadData(ent)
	ent:SetWeedID(self:GetData("WeedID"))
	ent:SetWeedName(self:GetData("WeedName"))
	ent:SetWeedAmount(self:GetData("WeedAmount"))
	ent:SetTHC(self:GetData("THC"))

	zwf.f.SetOwnerByID(ent, self:GetData("ZWFOwner"))
end
