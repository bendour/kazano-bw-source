AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SpawnFunction(ply, tr)
	local SpawnPos = tr.HitPos + tr.HitNormal * 25
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
	self:SetUseType(CONTINUOUS_USE)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:UseClientSideAnimation()
	self:SetCustomCollisionCheck(true)

	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(true)
	end

	zwf.f.EntList_Add(self)


	self.PlantID = 1
	self.THC = 15
	self.PlantName = "OG Kush"

	self.perf_time = 100
	self.perf_amount = 100
	self.perf_thc = 100

	self.NextInteraction = -1
end

function ENT:AcceptInput(input, activator, caller, data)
	if string.lower(input) == "use" and IsValid(activator) and activator:IsPlayer() and activator:Alive() and IsValid(self:GetParent()) and CurTime() > (self:GetStartDryTime() + zwf.config.DryStation.Duration) then

		if self:GetProgress() <= 0 then
			zwf.f.DryStation_RemoveWeedStick(self,self:GetParent(),activator)
		else
			if zwf.f.IsWeedSeller(activator) == false then return end
			if zwf.config.Sharing.DryStation == false and zwf.f.IsOwner(activator, self) == false then return end

			if CurTime() < self.NextInteraction then return end
			self.NextInteraction = CurTime() + 0.25

			self:StartRemoval()
		end
	end
end

function ENT:StartRemoval()
	self:SetProgress( self:GetProgress() - 1)
end

function ENT:OnTakeDamage(dmg)
	zwf.f.Entity_OnTakeDamage(self,dmg)
end
