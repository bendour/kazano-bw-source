ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Lean Crate"
ENT.Category = "Lean-Production"
ENT.Spawnable = true

function ENT:SetupDataTables()
	-- Integer
	self:NetworkVar("Int", 0, "holding")
	-- Boolean
	self:NetworkVar("Bool", 0, "full")
	--Entity
	self:NetworkVar("Entity", 0, "owning_ent")
end