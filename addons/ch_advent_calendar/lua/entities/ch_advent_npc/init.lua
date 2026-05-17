AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()
	self:SetHullType( HULL_HUMAN )
	self:SetHullSizeNormal()
	self:SetNPCState( NPC_STATE_SCRIPT )
	self:SetSolid( SOLID_BBOX )
	self:CapabilitiesAdd( CAP_ANIMATEDFACE )
	self:DropToFloor()
	self:SetMaxYawSpeed( 90 )
	self:SetCollisionGroup( COLLISION_GROUP_NONE )
end

function ENT:Use( ply )
	local cur_time = CurTime()
	if ( self.LastUsed or 0 ) > cur_time then
		return
	end
	self.LastUsed = cur_time + 1

	-- Open the menu
	CH_Advent.OpenSquareMenu( ply )
end

function ENT:OnTakeDamage( dmg )
	return 0
end