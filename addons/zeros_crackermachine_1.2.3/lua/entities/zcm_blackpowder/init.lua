AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SpawnFunction(ply, tr)
	if (not tr.Hit) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 25
	local ent = ents.Create(self.ClassName)
	local angle = ply:GetAimVector():Angle()
	angle = Angle(0, angle.yaw, 0)
	angle:RotateAroundAxis(angle:Up(), 90)
	ent:SetAngles(angle)
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()
	zcm.f.SetOwner(ent, ply)
	return ent
end

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(true)
	end

	self:SetMaxHealth(150)
	self:SetHealth(self:GetMaxHealth())

	zcm.f.EntList_Add(self)
	self.Destroyed = false
end

function ENT:ExplodeBlackpowder()
	self.Destroyed = true
	if zcm.config.BlackPowder.Damage > 0 then
		for k, v in pairs(ents.FindInSphere(self:GetPos(), 300)) do
			if IsValid(v) and v:IsPlayer() and v:Alive() then
				v:SetHealth(v:Health() - zcm.config.BlackPowder.Damage)
			end
		end
	end

	zcm.f.CreateNetEffect("zcm_blackpowder_explode",self:GetPos())

	timer.Simple(0, function()
		if IsValid(self) then
			SafeRemoveEntity(self)
		end
	end)
end

function ENT:OnTakeDamage(dmg)
	if self.Destroyed == true then return end

	BaseWars:EntityTakeDamage(self, dmg, function()
		self:ExplodeBlackpowder()
	end)
end
