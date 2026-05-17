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

function ENT:AcceptInput( input, ply, caller, data )
	if string.lower( input ) == "use" and IsValid(ply) and ply:IsPlayer() and ply:Alive() then

		if self.LastPickUp > CurTime() then return end
		self.LastPickUp = CurTime() + 1


		local SWEPData = zwf.config.Bongs.items[self.BongID]

		if ply:HasWeapon( SWEPData.w_class ) == false then

			ply:Give( SWEPData.w_class, false )

			local bong = ply:GetWeapon( SWEPData.w_class )

			bong:SetWeedID(self:GetWeedID())
			bong:SetWeed_Name(self:GetWeed_Name())
			bong:SetWeed_THC(self:GetWeed_THC())
			bong:SetWeed_Amount(self:GetWeed_Amount())
			bong:SetIsBurning(self:GetIsBurning())

			ply:SelectWeapon(SWEPData.w_class)

			SafeRemoveEntity( self )
		else
			zwf.f.Notify(ply, zwf.language.General["bong_pickup_fail"], 1)
		end
	end
end
