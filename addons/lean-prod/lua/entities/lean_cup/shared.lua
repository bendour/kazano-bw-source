ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Category = "Lean-Production"
ENT.PrintName = "Lean Cup"
ENT.Spawnable = true

function ENT:SetupDataTables()
	-- Boolean
	self:NetworkVar("Bool",0,"liquid")
end