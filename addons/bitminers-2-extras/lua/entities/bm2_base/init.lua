AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:OnTakeDamage(dmg)
	BaseWars:EntityTakeDamage(self, dmg, function()
		SafeRemoveEntity(self)
	end)
end