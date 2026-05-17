ENT.Base = "bw_base"
ENT.Type = "anim"
ENT.PrintName = "Base Electronics"
ENT.Author = "JL"
ENT.Model = "models/props_interiors/pot02a.mdl"
ENT.IsElectronic = true

function ENT:SetupNetWork()
end

function ENT:SetupDataTables()
	-- No energy system in this BaseWars version
	self:SetupNetWork()
end