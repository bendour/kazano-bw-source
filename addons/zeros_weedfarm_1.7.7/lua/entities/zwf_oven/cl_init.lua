include("shared.lua")

function ENT:Initialize()
	zwf.f.EntList_Add(self)

	self.LastWorkState = -1
	self.IsBaking = false
	self.BakeStart = -1
end

function ENT:Draw()
	self:DrawModel()

	zwf.f.UpdateEntityVisuals(self)

	if GetConVar("zwf_cl_vfx_drawui"):GetInt() == 1 and zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 200) then
		self:DrawScreenUI()
	end
end

function ENT:DrawScreenUI()
	if self:GetIsBaking() then
		cam.Start3D2D(self:LocalToWorld(Vector(3.3,13, 19.4)), self:LocalToWorldAngles(Angle(0, 180, 90)), 0.1)

		if self.BakeStart ~= -1 then
			draw.RoundedBox(5, -90, -55, 180, 20, zwf.default_colors["gray02"])
			local width = (180 / zwf.config.Cooking.bake_duration) * (CurTime() - self.BakeStart)
			draw.RoundedBox(5, -90, -55, width, 20, zwf.default_colors["green04"])
		end

		cam.End3D2D()
	end
end



function ENT:Think()

	self.IsBaking = self:GetIsBaking()

	zwf.f.LoopedSound(self, "zwf_oven_loop", self.IsBaking)


	if zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 1000) then

		local _workstate = self:GetWorkState()

		if self.LastWorkState ~= _workstate then
			self.LastWorkState = _workstate

			if _workstate == 0 then

				// Play idle Animation
				zwf.f.ClientAnim(self, "idle", 1)

			elseif _workstate == 1 then

				// Play open Animation
				zwf.f.ClientAnim(self, "open", 1)
				zwf.f.EmitSoundENT("zwf_oven_open", self)

			elseif _workstate == 2 then

				// Play close Animation
				zwf.f.ClientAnim(self, "close", 1)
				zwf.f.EmitSoundENT("zwf_oven_close", self)
			end

			if self.IsBaking then
				if self.BakeStart == -1 then
					self.BakeStart = CurTime()
				end
				//self:SetBodygroup(0,1)
			else
				self.BakeStart = -1
				//self:SetBodygroup(0,0)
			end
		end
	else
		self.LastWorkState = -1
		self.BakeStart = -1
	end

	self:SetNextClientThink(CurTime())
	return true
end

function ENT:UpdateVisuals()

	local _workstate = self:GetWorkState()

	if _workstate == 0 then

		// Play idle Animation
		zwf.f.ClientAnim(self, "idle", 5)
	elseif _workstate == 1 then

		// Play open Animation
		zwf.f.ClientAnim(self, "open",  5)

	elseif _workstate == 2 then

		// Play close Animation
		zwf.f.ClientAnim(self, "close", 5)

	end

	/*
	if self.IsBaking then
		self:SetBodygroup(0, 1)
	else
		self:SetBodygroup(0, 0)
	end
	*/
end

function ENT:OnRemove()
	self:StopSound("zwf_oven_loop")
end
