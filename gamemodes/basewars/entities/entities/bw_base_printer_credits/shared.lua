ENT.Base = "bw_base_electronics"
ENT.PrintName = "Basic Printer Credits"
ENT.Author = "JL"
ENT.Category = "BaseWars - Printers"
ENT.Spawnable = true
ENT.Model = "models/props_c17/consolebox01a.mdl"

ENT.IsPrinter = false
ENT.PresetHealth = 150

ENT.Capacity = 100
ENT.UpgradeCost = 1000
ENT.PrintInterval = 60
ENT.PrintAmount = 1

ENT.Color = Color(0, 0, 0)
ENT.SubColor = Color(60, 60, 60)
ENT.TextColor = "PRESTIGE"

function ENT:SetupNetWork()
	self:NetworkVar("Float", 0, "Money")
	self:NetworkVar("Float", 1, "Capacity")
	self:NetworkVar("Float", 4, "PACost")
	self:NetworkVar("Float", 5, "PICost")
	self:NetworkVar("Float", 6, "PCCost")
	self:NetworkVar("Float", 7, "AutoPaperCost")
	self:NetworkVar("Float", 8, "CapacityCost")
	self:NetworkVar("Float", 9, "PrintAmount")
	self:NetworkVar("Float", 10, "PrintInterval")
	self:NetworkVar("Float", 11, "BaseCost")

	self:NetworkVar("Int", 0, "Paper")
	self:NetworkVar("Int", 1, "MaxPaper")
	self:NetworkVar("Int", 2, "PILevel")
	self:NetworkVar("Int", 3, "PALevel")
	self:NetworkVar("Int", 4, "CLevel")
	self:NetworkVar("Int", 5, "PCLevel")

	self:NetworkVar("Bool", 0, "AutoPaper")
	self:NetworkVar("Bool", 1, "ConnectedToBank")
	self:NetworkVar("Bool", 2, "Refund")
end

function ENT:OnUpgrade(ply)
	local trace = ply:GetEyeTrace()
	if trace.Entity != self then return false end
	local pos = self:WorldToLocal(trace.HitPos)

	return pos.y >= -14.61 and pos.y <= .01 and pos.x >= 7.91 and pos.x <= 13.88
end

function ENT:OnBuyPaper(ply)
	local trace = ply:GetEyeTrace()
	if trace.Entity != self then return false end
	local pos = self:WorldToLocal(trace.HitPos)

	return pos.y >= .46 and pos.y <= 15.12 and pos.x >= 7.95 and pos.x <= 13.9
end