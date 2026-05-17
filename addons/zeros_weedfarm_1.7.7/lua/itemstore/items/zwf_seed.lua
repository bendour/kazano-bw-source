ITEM.Name = "Seed"
ITEM.Description = "Desc"
ITEM.Model = "models/zerochain/props_weedfarm/zwf_weedseed.mdl"
ITEM.Base = "base_darkrp"
ITEM.Stackable = false
ITEM.DropStack = false

--ITEM.MaxStack = 10
function ITEM:GetDescription()

	local Perf_Time = self:GetData("Perf_Time")
	local Perf_Amount = self:GetData("Perf_Amount")
	local Perf_THC = self:GetData("Perf_THC")

	local seedData = zwf.config.Plants[self:GetData("SeedID")]

	Perf_Time = 100 - (Perf_Time - 100)
	Perf_Time = Perf_Time * 0.01
	Perf_Time = seedData.Grow.Duration * Perf_Time
	Perf_Time = math.Round(Perf_Time) .. "s"

	Perf_Amount = Perf_Amount * 0.01
	Perf_Amount = seedData.Grow.MaxYieldAmount * Perf_Amount
	Perf_Amount = math.Round(Perf_Amount) .. zwf.config.UoW

	Perf_THC = Perf_THC * 0.01
	Perf_THC = seedData.thc_level * Perf_THC
	Perf_THC = math.Round(Perf_THC) .. "%"

	local desc = zwf.language.VGUI["Duration"] .. ": " .. tostring(Perf_Time) .. "\n" .. zwf.language.VGUI["HarvestAmount"] .. ": " .. tostring(Perf_Amount) .. "\n" .. zwf.language.General["THC"] .. ": " .. tostring(Perf_THC)

	return self:GetData("Description", desc)
end


function ITEM:GetName()
	local name = self:GetData("SeedName") .. " x" .. self:GetData("SeedCount") .. "\n[" .. zwf.config.Plants[self:GetData("SeedID")].name .. "]"

	return self:GetData("Name", name)
end

function ITEM:SaveData(ent)
	self:SetData("SeedID", ent:GetSeedID())
	self:SetData("SeedName", ent:GetSeedName())
	self:SetData("Perf_Time", ent:GetPerf_Time())
	self:SetData("Perf_Amount", ent:GetPerf_Amount())
	self:SetData("Perf_THC", ent:GetPerf_THC())

	self:SetData("SeedCount", ent:GetSeedCount())

	self:SetData("ZWFOwner", zwf.f.GetOwnerID(ent))
end

function ITEM:LoadData(ent)
	ent:SetSeedID(self:GetData("SeedID"))
	ent:SetSeedName(self:GetData("SeedName"))
	ent:SetPerf_Time(self:GetData("Perf_Time"))
	ent:SetPerf_Amount(self:GetData("Perf_Amount"))
	ent:SetPerf_THC(self:GetData("Perf_THC"))

	ent:SetSeedCount(self:GetData("SeedCount"))

	zwf.f.SetOwnerByID(ent, self:GetData("ZWFOwner"))

	timer.Simple(0.25,function()
		if IsValid(ent) then
			ent:OnItemStoreDrop()
		end
	end)
end
