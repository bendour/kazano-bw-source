ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.PrintName = "Freezer"
ENT.Author = "JL"
ENT.Information = "info"
ENT.Category = "Zeros Meth Lab"

function ENT:SetupDataTables()
	self:NetworkVar("Int", 1, "UsedPositions")
	self:NetworkVar("Bool", 0, "IsFreezing")

	if (SERVER) then
		self:SetUsedPositions(0)
		self:SetIsFreezing(false)
	end
end
