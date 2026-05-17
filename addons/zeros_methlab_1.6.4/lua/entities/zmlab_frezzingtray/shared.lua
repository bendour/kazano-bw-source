ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Spawnable = false
ENT.AdminSpawnable = true
ENT.PrintName = "Freezing Tray"
ENT.Author = "JL"
ENT.Information = "info"
ENT.Category = "Zeros Meth Lab"

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "InBucket")
	self:NetworkVar("Float", 1, "FrezzingProgress")

	if SERVER then
		self:SetInBucket(0)
		self:SetFrezzingProgress(0)
	end
end
