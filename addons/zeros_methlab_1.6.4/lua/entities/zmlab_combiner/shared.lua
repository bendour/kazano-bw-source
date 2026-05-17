ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.PrintName = "Combiner"
ENT.Author = "JL"
ENT.Information = "info"
ENT.Category = "Zeros Meth Lab"

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Aluminium")
	self:NetworkVar("Int", 1, "Methylamin")
	self:NetworkVar("Int", 2, "Stage")
	self:NetworkVar("Int", 3, "NeedAluminium")
	self:NetworkVar("Int", 4, "NeedMethylamin")
	self:NetworkVar("Bool", 0, "HasFilter")
	self:NetworkVar("Bool", 1, "HasTray")
	self:NetworkVar("Bool", 2, "IsBusy")
	self:NetworkVar("Float", 0, "StartProcessingTime")
	self:NetworkVar("Float", 1, "MaxProcessingTime")
	self:NetworkVar("Float", 2, "MethSludge")
	self:NetworkVar("Float", 3, "MaxMethSludge")
	self:NetworkVar("Float", 4, "CleaningProgress")

	if SERVER then
		self:SetAluminium(0)
		self:SetMethylamin(0)
		self:SetStage(1)
		self:SetNeedAluminium(0)
		self:SetNeedMethylamin(0)

		self:SetHasFilter(false)
		self:SetHasTray(false)
		self:SetIsBusy(false)

		self:SetStartProcessingTime(0)
		self:SetMaxProcessingTime(0)
		self:SetMethSludge(0)
		self:SetMaxMethSludge(0)
		self:SetCleaningProgress(0)
	end
end
