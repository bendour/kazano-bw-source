ITEM.Name = "Weed Jar"
ITEM.Description = "A Jar of weed"
ITEM.Model = "models/zerochain/props_weedfarm/zwf_jar.mdl"
ITEM.Base = "base_darkrp"
ITEM.Stackable = false
ITEM.DropStack = false

function ITEM:GetName()
	local name = self:GetData("WeedName") .. " " .. self:GetData("WeedAmount") .. zwf.config.UoW .. "\n[" .. zwf.config.Plants[self:GetData("PlantID")].name .. "]"

	return self:GetData("Name", name)
end

function ITEM:SaveData(ent)
	self:SetData("PlantID", ent:GetPlantID())
	self:SetData("WeedName", ent:GetWeedName())
	self:SetData("WeedAmount", ent:GetWeedAmount())
	self:SetData("THC", ent:GetTHC())

	self:SetData("Perf_Time", ent:GetPerf_Time())
	self:SetData("Perf_Amount", ent:GetPerf_Amount())
	self:SetData("Perf_THC", ent:GetPerf_THC())

	self:SetData("ZWFOwner", zwf.f.GetOwnerID(ent))
end

function ITEM:LoadData(ent)
	ent:SetPlantID(self:GetData("PlantID"))
	ent:SetWeedName(self:GetData("WeedName"))
	ent:SetWeedAmount(self:GetData("WeedAmount"))
	ent:SetTHC(self:GetData("THC"))

	ent:SetPerf_Time(self:GetData("Perf_Time"))
	ent:SetPerf_Amount(self:GetData("Perf_Amount"))
	ent:SetPerf_THC(self:GetData("Perf_THC"))

	zwf.f.SetOwnerByID(ent, self:GetData("ZWFOwner"))

	timer.Simple(0.25,function()
		if IsValid(ent) then
			zwf.f.Jar_ItemStore(ent)
		end
	end)
end
