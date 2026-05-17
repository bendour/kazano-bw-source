/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.1 (stable)
*/

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SpawnFunction(ply, tr)
	local ent = ents.Create(self.ClassName)
	if not IsValid(ent) then return end
	ent:SetPos(tr.HitPos + tr.HitNormal * 1)
	local angle = ply:GetAimVector():Angle()
	angle = Angle(0, angle.yaw, 0)
	angle:RotateAroundAxis(angle:Up(), 180)
	ent:SetAngles(angle)
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()
	zmlab2.NPC.Initialize(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 20505de7028925e794a03b5d1a113ab09db033ae5f8a5a69bfd7d0ab6982aaae
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e3b23fe5de9dfb761758a006a7271ce1817b0b3d31fddc5f22fc8264734156bf
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7e845693ad2a490ead94c2e1f6c2eaff90beaf41e1d134566247921805d9f29b

function ENT:AcceptInput(inputName, activator, caller, data)
	if inputName == "Use" and IsValid(activator) and activator:IsPlayer() and activator:Alive() then
		zmlab2.NPC.OnUse(self, activator)
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7e845693ad2a490ead94c2e1f6c2eaff90beaf41e1d134566247921805d9f29b

function ENT:OnTakeDamage(dmg)
	return 0
end
