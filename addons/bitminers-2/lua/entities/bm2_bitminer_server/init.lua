AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/bitminers2/bitminer_2.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	local physics = self:GetPhysicsObject()
	if (physics:IsValid()) then
		physics:Wake()
	end

	self:SetMaxHealth(250)
	self:SetHealth(self:GetMaxHealth())

	self.inserted = false
end	

function ENT:OnRemove()
	if self.parentServer ~= nil then
		if self.beenPlacedIntoRack then
			self.parentServer:RemoveServer(self.index) 
		end
	end
end

//Destroying it
function ENT:OnTakeDamage(dmg)
	BaseWars:EntityTakeDamage(self, dmg, function()
		SafeRemoveEntity(self)
	end)
end
