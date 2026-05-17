AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SpawnFunction(ply, tr)
	if (not tr.Hit) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 35
	local ent = ents.Create(self.ClassName)
	local angle = ply:GetAimVector():Angle()
	angle = Angle(0, angle.yaw, 0)
	angle:RotateAroundAxis(angle:Up(), 90)
	ent:SetAngles(angle)
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()
	zmlab.f.SetOwner(ent, ply)

	return ent
end

function ENT:Initialize()
	self:SetModel("models/zerochain/zmlab/zmlab_transportcrate.mdl")
	self:SetBodygroup(0, 0)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:UseClientSideAnimation()
	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(true)
	end

	self:SetMaxHealth(100)
	self:SetHealth(self:GetMaxHealth())

	zmlab.f.TransportCrate_Initialize(self)
end

function ENT:AcceptInput(input, activator, caller, data)
	if string.lower(input) == "use" and IsValid(activator) and activator:IsPlayer() and activator:Alive() then
		zmlab.f.TransportCrate_USE(self, activator)
	end
end

function ENT:StartTouch(other)
	zmlab.f.TransportCrate_StartTouch(self, other)
end

function ENT:OnTakeDamage(dmg)
	BaseWars:EntityTakeDamage(self, dmg, function()
		zmlab.f.Destruct(self, "Explosion")
	end)
end
