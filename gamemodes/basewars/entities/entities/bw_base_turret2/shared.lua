ENT.Base = "bw_base_electronics"
ENT.Type = "anim"
ENT.PrintName = "Turret"
ENT.Author = "JL"
ENT.Category = "BaseWars - Defense"
ENT.Model = "models/Combine_turrets/Floor_turret.mdl"

ENT.Damage = 3
ENT.Range = 750
ENT.ShootingDelay = .08
ENT.EyePosOffset = Vector(0, 0, 0)
ENT.Sounds 	= Sound("npc/turret_floor/shoot1.wav")
ENT.Spread = 15
ENT.NextShot = 0

ENT.IsTurret = true

ENT.PresetHealth = 500

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "ShowAimLine")
	self:NetworkVar("Float", 0, "AimLineEndTime")
	self:NetworkVar("Vector", 0, "AimDirection")
end