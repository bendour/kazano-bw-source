/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SpawnFunction(ply, tr)
	local SpawnPos = tr.HitPos + tr.HitNormal * 25
	local ent = ents.Create(self.ClassName)
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()

	return ent
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

function ENT:Initialize()
	self:SetModel(zpn.Theme.Projectile.model)

	local r = 1
	self.PhysObjRadius = r

	self:PhysicsInitSphere(r, "default")
	self:SetCollisionBounds(Vector(-r, -r, -r), Vector(r, r, r))
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:DrawShadow(false)
	self.PhysgunDisabled = true

	local phys = self:GetPhysicsObject()

	if IsValid(phys) then
		phys:SetMass(1)
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:Wake()
	else
		self:Remove()

		return
	end

	self:StartMotionController()
	self:SetCustomCollisionCheck(true)

	// This gets set by other system to tell it where to fly
	// but if it doesent then we just fly up
	if self.FlyDir == nil then
		self.FlyDir = self:GetAngles():Up()
	end

	self.HitPlayer = false

	SafeRemoveEntityDelayed(self,0.5)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

function ENT:GravGunPickupAllowed( ply )
	return false
end

local maxForce = 2 ^ 32
function ENT:PhysicsSimulate(phys, dt)
	if self.zpn_Collided then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- da71c7e0bf5016ce33a9f318a3747fb53331bb70d9090f016fdcc745ceefa6b8

	if not self.zpn_Increase then
		self.zpn_Increase = 1
	end

	self.zpn_Increase = math.Approach(self.zpn_Increase, maxForce, dt * maxForce * 0.01)

	local force = Vector(0, 0, 0)
	local angForce = Vector(0, 0, 0)

	//local pos = VectorRand() * 5
	//if pos then force = force + pos end

	force = force + self.FlyDir * self.zpn_Increase

	force = force * dt
	angForce = angForce * dt

	return angForce, force, SIM_GLOBAL_ACCELERATION
end

function ENT:PhysicsCollide(data, physobj)
	local ent = data.HitEntity
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

	if IsValid(data.HitObject) and IsValid(ent) and ent:IsPlayer() and ent:Alive() then

		self.HitPlayer = true

		// Give the player some damage
		local d = DamageInfo()
		d:SetDamage(self.dmg or 5)
		if IsValid(self.FireballShooter) then
			d:SetAttacker(self.FireballShooter)
		elseif IsValid(self) then
			d:SetAttacker(self)
		end
		d:SetDamageType(zpn.Theme.Projectile.damagetype)
		ent:TakeDamageInfo(d)
	end

	if not self.zpn_Collided then

		local velPlus = data.OurOldVelocity and data.OurOldVelocity:GetNormal() * 60 or Vector(0,0,0)

		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(false)
		end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 6af6efba71e4015ff987fc919ecacbe102ec0873079409ab2a0ed0bf25e3f3cd

		timer.Simple(FrameTime(), function()
			if not IsValid(self) then return end

			local pos = data.HitPos - data.HitNormal * self.PhysObjRadius
			self:SetPos(pos + velPlus)
		end)

		local deltime = FrameTime() * 2
		if not game.SinglePlayer() then deltime = FrameTime() * 6 end

		SafeRemoveEntityDelayed(self,deltime)

		if self.CreateFire and self.HitPlayer == false then
			local firePos = self:GetPos()
			timer.Simple(0,function()
				if firePos then
					local firearea = ents.Create("zpn_firearea")
					firearea.FireAreaSpawner = self.FireballShooter
					firearea:SetPos(firePos)
					firearea:Spawn()
					firearea:Activate()
				end
			end)
		end

		self.zpn_Collided = true
	end
end
