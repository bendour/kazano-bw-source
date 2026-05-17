AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SpawnFunction(ply, tr)
	local SpawnPos = tr.HitPos + tr.HitNormal * 1
	local ent = ents.Create(self.ClassName)
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()
	zwf.f.SetOwner(ent, ply)
	return ent
end

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:UseClientSideAnimation()
	self:SetCustomCollisionCheck( true )

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:EnableMotion(true)
	end

	self.IsMerging = false
	self.IsInSeedLab = false
	zwf.f.EntList_Add(self)
end

function ENT:StartTouch(other)
	if self.IsInSeedLab then return end
	if self.IsMerging then return end
	if IsValid(self) and IsValid(other) and other:GetClass() == "zwf_jar" then
		self.IsMerging = true

		timer.Simple(1,function()
			if IsValid(self) then
				self.IsMerging = false
			end
		end)

		zwf.f.Jar_Touch(self, other)
	end
end

function ENT:OnTakeDamage(dmg)
	if self.IsInSeedLab then return end
	zwf.f.Entity_OnTakeDamage(self, dmg)
end
