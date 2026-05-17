AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

util.AddNetworkString("ShowBodygroups")
util.AddNetworkString("ChangeBodygroup")

function ENT:Initialize()
	self.Entity:SetModel("models/props_c17/FurnitureDresser001a.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	
	local phys = self.Entity:GetPhysicsObject()
	self.nodupe = true
	self.ShareGravgun = true

	if phys and phys:IsValid() then phys:Wake() end
    self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS) 
end

function ENT:SpawnFunction(ply, tr)
   	if (!tr.Hit) then
	return end
 	 
 	local SpawnPos = tr.HitPos + tr.HitNormal * 40

 	local ent = ents.Create("bodygroups_wardrobe")
	ent:SetPos(SpawnPos)
	ent:Spawn()
    ent:Activate()
 	 	 
	return ent 
end

function ENT:Use(plyUse)
	net.Start("ShowBodygroups")
	net.Send(plyUse)
end

net.Receive("ChangeBodygroup", function(len, ply)
	local bodygroup = tonumber(net.ReadString())
	local value = net.ReadInt(32)

	ply:SetBodygroup(bodygroup, value)
end)

function ENT:OnRemove()
	self:Remove()
end