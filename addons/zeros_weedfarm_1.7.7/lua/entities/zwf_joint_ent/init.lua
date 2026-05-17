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

	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(true)
	end

	zwf.f.EntList_Add(self)

	self.LastPickUp = CurTime() + 1
end

function ENT:AcceptInput( input, activator, caller, data )
	if string.lower( input ) == "use" and IsValid(activator) and activator:IsPlayer() and activator:Alive() then

		if self.LastPickUp > CurTime() then return end
		self.LastPickUp = CurTime() + 1

		if activator:HasWeapon( "zwf_joint" ) == false then

			activator:Give( "zwf_joint", false )

			local joint = activator:GetWeapon( "zwf_joint" )
			if not IsValid(joint) then return end
			if joint.SetWeedID == nil then return end

			joint:SetWeedID(self:GetWeedID())
			joint:SetWeed_Name(self:GetWeed_Name())
			joint:SetWeed_THC(self:GetWeed_THC())
			joint:SetWeed_Amount(self:GetWeed_Amount())
			joint:SetIsBurning(self:GetIsBurning())

			activator:SelectWeapon("zwf_joint")

			SafeRemoveEntity( self )
		else
			zwf.f.Notify(activator, zwf.language.General["joint_pickup_fail"], 1)
		end
	end
end
