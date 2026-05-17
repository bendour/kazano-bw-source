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
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(true)
	end

	self:SetMaxHealth(250)
	self:SetHealth(self:GetMaxHealth())

	self:SetBodygroup(0,1)
	self:SetBodygroup(1,1)

	self.Ignited = false

	zcm.f.EntList_Add(self)
end

function ENT:AcceptInput(key, ply)
	if ((self.lastUsed or CurTime()) <= CurTime()) and (key == "Use" and IsValid(ply) and ply:IsPlayer() and ply:Alive()) then
		self.lastUsed = CurTime() + 0.25
		if self.Ignited == true then return end

		self:IgniteFirework()
	end
end

function ENT:IgniteFirework()

	// Ignite firework
	self.Ignited = true

	zcm.f.CreateNetEffect("zcm_fuse",self)

	self.PhysgunDisabled = true

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:EnableMotion(false)
	end

	timer.Simple(3,function()
		if IsValid(self) then
			SafeRemoveEntity(self)
		end
	end)
end

function ENT:OnTakeDamage(dmg)
	if self.Ignited == true then return end

	BaseWars:EntityTakeDamage(self, dmg, function()
		self:IgniteFirework()
	end)
end
