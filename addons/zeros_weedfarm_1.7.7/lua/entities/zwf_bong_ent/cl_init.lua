include("shared.lua")

function ENT:Initialize()
	zwf.f.EntList_Add(self)

	self.Last_WeedID = -1

	self.Last_IsBurning = false

	self.IsInitialized = false

	timer.Simple(0.1,function()
		if IsValid(self) then
			self.IsInitialized = true
		end
	end)
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Think()
	if self.IsInitialized == false then return end

	if zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 500) then

		local _WeedID = self:GetWeedID()
		if self.Last_WeedID ~= _WeedID then
			self.Last_WeedID = _WeedID

			if self.Last_WeedID ~= -1 then

				self:SetBodygroup(2,1)
				self:SetSkin(zwf.config.Plants[self.Last_WeedID].skin)
			else

				self:SetBodygroup(2,0)
			end
		end


		local _IsBurning = self:GetIsBurning()
		if self.Last_IsBurning ~= _IsBurning then
			self.Last_IsBurning = _IsBurning

			if self.Last_IsBurning then
				self:SetSkin(7)
				zwf.f.ParticleEffectAttach("zwf_ent_fire", PATTACH_POINT_FOLLOW, self, 1)
			else
				self:StopParticles()
			end
		end
	else
		self.Last_WeedID = -1

		if self.Last_IsBurning == true then
			self.Last_IsBurning = false
			self:StopParticles()
		end
	end

end
