// I can't split it in server/client code, because I also need this code clientside

AddCSLuaFile()
ENT.Base = "base_entity"
ENT.Type = "anim"
ENT.Spawnable = false
ENT.AutomaticFrameAdvance = true

ENT.PrintName = "Case in GUI"
ENT.Category = "AShop"

function ENT:Initialize()
	if ( SERVER ) then
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )
	end
end

function ENT:Think()
	self:NextThink( CurTime() )
	self:SetNextClientThink(CurTime())
	return true
end

if ( SERVER ) then -- This hook is only available on the server
	function ENT:Use( activator, caller ) -- If a player uses this entity, play an animation
		if ( !self.Opened ) then -- If we are not "opened"
			self:ResetSequence( "open" ) -- Play the open sequence
			self.Opened = true -- We are now opened
		else
			self:ResetSequence( "close" ) -- Play the close sequence
			self.Opened = false -- We are now closed
		end
	end
end