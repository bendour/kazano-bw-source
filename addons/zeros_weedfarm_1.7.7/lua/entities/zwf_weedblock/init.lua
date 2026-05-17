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
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:UseClientSideAnimation()

	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(true)
	end
	zwf.f.EntList_Add(self)
	self.PlantID = 1
end


function ENT:AcceptInput(key, ply)
	if ((self.lastUsed or CurTime()) <= CurTime()) and (key == "Use" and IsValid(ply) and ply:IsPlayer() and ply:Alive()) and zwf.f.InDistance(ply:GetPos(), self:GetPos(), 100) then
		self.lastUsed = CurTime() + 0.25

		if zwf.config.NPC.SellMode == 2 and self:CollectButton(ply) then
        if (ply != self:CPPIGetOwner()) then
				BaseWars:Notify(ply, "#notYours", NOTIFICATION_ERROR, 5)
				return
			end
			zwf.f.CollectWeed(self,ply)
		end
	end
end

function ENT:OnTakeDamage(dmg)
	zwf.f.Entity_OnTakeDamage(self,dmg)
end
