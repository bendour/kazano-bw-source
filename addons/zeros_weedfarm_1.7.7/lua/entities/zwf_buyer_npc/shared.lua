ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.PrintName = "Weed Buyer"
ENT.Category = "Zeros GrowOP"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Price")
	if (SERVER) then
		self:SetPrice(1)
	end
end
