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

function ENT:Initialize()
	self:SetModel(self.Model)

	local r = 5
	self.PhysObjRadius = r

	self:PhysicsInitSphere(r, "default")
	self:SetCollisionBounds(Vector(-r, -r, -r), Vector(r, r, r))
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:DrawShadow(false)
	self.PhysgunDisabled = true
	self:SetSkin(1)

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

	SafeRemoveEntityDelayed(self,self.KillTime or 1)
end

function ENT:GravGunPickupAllowed( ply )
	return false
end

local maxForce = 2 ^ 32
function ENT:PhysicsSimulate(phys, dt)
	if self.zpn_Collided then return end

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

function ENT:Explode()
	local pos = self:GetPos()
	local radius = 400
	local phys_force = 1500
	local push_force = 256

	-- pull physics objects and push players
	for k, target in pairs(ents.FindInSphere(pos, radius)) do
		if IsValid(target) then
			local tpos = target:LocalToWorld(target:OBBCenter())
			local dir = (tpos - pos):GetNormal()
			local phys = target:GetPhysicsObject()

			if target:IsPlayer() and target:GetRole() ~= ROLE_TRAITOR and (not target:IsFrozen()) and ((not target.was_pushed) or target.was_pushed.t ~= CurTime()) then

				-- always need an upwards push to prevent the ground's friction from
				-- stopping nearly all movement
				dir.z = math.abs(dir.z) + 1
				local push = dir * push_force
				-- try to prevent excessive upwards force
				local vel = target:GetVelocity() + push
				vel.z = math.min(vel.z, push_force)

				target:SetVelocity(vel)

				target.was_pushed = {
					att = self.Owner,
					t = CurTime(),
					wep = "zpn_ttt_partypopper"
				}


				local d = DamageInfo()
				d:SetDamage(zpn.config.PartyPopper.ttt_damage)
				d:SetAttacker(self.Owner)
				d:SetDamageType(DMG_SONIC)
				target:TakeDamageInfo(d)
			elseif IsValid(phys) then
				phys:ApplyForceCenter(dir * -1 * phys_force)
			end
		end
	end

	local phexp = ents.Create("env_physexplosion")

	if IsValid(phexp) then
		phexp:SetPos(pos)
		phexp:SetKeyValue("magnitude", 100) --max
		phexp:SetKeyValue("radius", radius)
		-- 1 = no dmg, 2 = push ply, 4 = push radial, 8 = los, 16 = viewpunch
		phexp:SetKeyValue("spawnflags", 1 + 2 + 16)
		phexp:Spawn()
		phexp:Fire("Explode", "", 0.2)
	end
end
function ENT:PhysicsCollide(data, physobj)
	if not self.zpn_Collided then

		local velPlus = data.OurOldVelocity and data.OurOldVelocity:GetNormal() * 60 or Vector(0,0,0)

		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(false)
		end

		timer.Simple(FrameTime(), function()
			if not self:IsValid() then return end

			local pos = data.HitPos - data.HitNormal * self.PhysObjRadius
			self:SetPos(pos + velPlus)

			if IsValid(self.Owner) then
				self:Explode()
			end
		end)

		local deltime = FrameTime() * 2
		if not game.SinglePlayer() then deltime = FrameTime() * 6 end

		SafeRemoveEntityDelayed(self,deltime)

		self.zpn_Collided = true
	end
end
