/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a2b46fa362cff6519809e40cc8d153299c414b52d9b8c3759ca38e67d8a7d851

function ENT:SpawnFunction(ply, tr)
	local SpawnPos = tr.HitPos + tr.HitNormal * 0
	local ent = ents.Create(self.ClassName)
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:Initialize()
	self:SetModel("models/hunter/misc/sphere2x2.mdl")
	self:SetModelScale(2)
	//local r = 400
	//self.PhysObjRadius = r

	//self:PhysicsInitSphere(r, "default")
	//self:SetCollisionBounds(Vector(-r, -r, -r), Vector(r, r, r))

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	self:DrawShadow(false)
	self.PhysgunDisabled = true
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 69811ac079f3e93f705541d1ed39dfac3a9e2460011697a76c02cf9afa26f9c3

	local phys = self:GetPhysicsObject()

	if IsValid(phys) then
		phys:SetMass(100)
		phys:EnableMotion(false)
		phys:Wake()
	else
		self:Remove()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- da71c7e0bf5016ce33a9f318a3747fb53331bb70d9090f016fdcc745ceefa6b8
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 69811ac079f3e93f705541d1ed39dfac3a9e2460011697a76c02cf9afa26f9c3

		return
	end

	self:SetTrigger(true)
	self:SetCustomCollisionCheck(true)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

	SafeRemoveEntityDelayed(self,zpn.config.Boss.FireRain.Firepit_Duration)
end

function ENT:GravGunPickupAllowed( ply )
	return false
end

function ENT:Touch(other)

	if IsValid(other) and other:IsPlayer() and other:Alive() and (other.zpn_LastFireDamage == nil or other.zpn_LastFireDamage < CurTime()) then

		// Give the player some damage
		local d = DamageInfo()
		d:SetDamage(1)
		if IsValid(self.FireAreaSpawner) then
			d:SetAttacker(self.FireAreaSpawner)
		elseif IsValid(self) then
			d:SetAttacker(self)
		end
		d:SetDamageType(zpn.Theme.FireArea.damagetype)
		other:TakeDamageInfo(d)

		other.zpn_LastFireDamage = CurTime() + 0.75
	end
end
