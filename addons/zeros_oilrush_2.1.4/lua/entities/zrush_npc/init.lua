AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	zrush.FuelBuyer.Initialize(self)
end

function ENT:AcceptInput(key, ply)
	if ((self.lastUsed or CurTime()) <= CurTime()) and (key == "Use" and IsValid(ply) and ply:IsPlayer() and ply:Alive()) then
		self.lastUsed = CurTime() + 0.25
		zrush.FuelBuyer.OnUse(self, ply)
	end
end

function ENT:OnTakeDamage(dmginfo)
	return 0
end
