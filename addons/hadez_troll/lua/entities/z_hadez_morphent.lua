AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true

function ENT:UpdatePos(owner)
	
	local angles = owner:GetAngles()
	local fixedAngle = Angle(0, angles.y, angles.z)

	self:SetAngles(fixedAngle)
	self:SetPos(owner:GetPos() - Vector(0, 0, self:OBBMins().z))

end

if SERVER then 

	function ENT:Initialize()
	
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		
	end
	
	function ENT:Think()
		
		local owner = self:GetOwner()
		
		if !IsValid(owner) or !owner:IsPlayer() then return end
		
		self:UpdatePos(owner)
		
		-- Force think hook to run each frame
		self:NextThink( CurTime() )
		return true
		
	end
	
end

if CLIENT then

	function ENT:Draw()
		
		local ply = LocalPlayer()
		local owner = self:GetOwner()
		
		if !IsValid(owner) or !owner:IsPlayer() or !owner:Alive() then return end
		
		local isLocalPlayer = ply == owner
		
		-- Draw if not in thirdperson
		if !ply:ShouldDrawLocalPlayer() and isLocalPlayer then return end
		
		-- Smooth animation for localplayer
		if isLocalPlayer then
			self:UpdatePos(owner)
		end
		
		self:DrawModel()
		
	end 

end