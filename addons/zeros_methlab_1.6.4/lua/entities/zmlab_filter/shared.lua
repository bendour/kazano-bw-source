ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Filter"
ENT.Author = "JL"
ENT.Information = "info"
ENT.Category = "Zeros Meth Lab"

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "CombinerEnt")
	self:NetworkVar("Float", 0, "FilterHealth")

	if SERVER then
		self:SetCombinerEnt(NULL)
		self:SetFilterHealth(0)
	end
end
