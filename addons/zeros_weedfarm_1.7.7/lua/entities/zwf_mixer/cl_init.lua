include("shared.lua")

function ENT:Initialize()
	zwf.f.EntList_Add(self)

	self.LastWorkState = -1
	self.MixStart = -1
	self.DoughState = -1
end

function ENT:Draw()
	self:DrawModel()

	zwf.f.UpdateEntityVisuals(self)

	if GetConVar("zwf_cl_vfx_drawui"):GetInt() == 1 and zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 200) then
		self:DrawScreenUI()
	end
end

function ENT:DrawScreenUI()
	if self:GetHasBowl() then

		if self:GetHasDough() and self.MixStart ~= -1 then
			cam.Start3D2D(self:LocalToWorld(Vector(-2, 6, 25)), self:LocalToWorldAngles(Angle(0, 180, 90)), 0.1)

				draw.RoundedBox(5, -170, -55, 180, 20, zwf.default_colors["gray02"])
				local width = (180 / zwf.config.Cooking.mix_duration) * (CurTime() - self.MixStart)
				draw.RoundedBox(5, -170, -55, width, 20, zwf.default_colors["green04"])

			cam.End3D2D()
		end

		if self:GetHasDough() == false then
			cam.Start3D2D(self:LocalToWorld(Vector(-5, 12, 25)), self:LocalToWorldAngles(Angle(0, 180, 90)), 0.1)
				self:Draw_RemoveButton()
			cam.End3D2D()
		end
	end
end

function ENT:Draw_RemoveButton()
	if self:OnRemoveButton(LocalPlayer()) then
		draw.SimpleText(zwf.language.General["Remove"], zwf.f.GetFont("zwf_splicelab_font02"), -10, 75, zwf.default_colors["orange01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	else
		draw.SimpleText(zwf.language.General["Remove"], zwf.f.GetFont("zwf_splicelab_font02"), -10, 75, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end
end



function ENT:Think()

	zwf.f.LoopedSound(self, "zwf_mixer_loop", self.LastWorkState == 3)

	if zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 1000) then

		local _workstate = self:GetWorkState()
		local _weedid = self:GetWeedID()

		if self.LastWorkState ~= _workstate then
			self.LastWorkState = _workstate

			if _workstate == 0 then

				// Play idle Animation
				zwf.f.ClientAnim(self, "idle", 1)

			elseif _workstate == 1 then

				// Play open Animation
				zwf.f.ClientAnim(self, "open", 1)
				zwf.f.EmitSoundENT("zwf_mixer_open", self)

			elseif _workstate == 2 then

				// Play close Animation
				zwf.f.ClientAnim(self, "close", 1)
				zwf.f.EmitSoundENT("zwf_mixer_close", self)

			elseif _workstate == 3 then

				// Play run Animation
				zwf.f.ClientAnim(self, "run", 1)
			end

			if _workstate == 3 then
				if self.MixStart == -1 then
					self.MixStart = CurTime()
				end
				self.DoughState = 0

			else
				self.MixStart = -1
				self.DoughState = -1
				self:SetColor(zwf.default_colors["white01"])
			end
		end


		if self.MixStart ~= -1 then

			local mixtime = (CurTime() - self.MixStart)

			if mixtime >= zwf.config.Cooking.mix_duration * 0.8 and self.DoughState == 2 then
				self.DoughState = 3

				if _weedid ~= -1 then
					// Update dough color
					self:SetColor(zwf.f.LerpColor((1 / zwf.config.Cooking.mix_duration) * mixtime, zwf.default_colors["white01"], zwf.config.Plants[_weedid].color))
				end

			elseif mixtime >= zwf.config.Cooking.mix_duration * 0.5 and self.DoughState == 1 then
				self.DoughState = 2

				if _weedid ~= -1 then
					// Update dough color
					self:SetColor(zwf.f.LerpColor((1 / zwf.config.Cooking.mix_duration) * mixtime, zwf.default_colors["white01"], zwf.config.Plants[_weedid].color))
				end

			elseif mixtime >= zwf.config.Cooking.mix_duration * 0.2 and self.DoughState == 0 then
				self.DoughState = 1

				if _weedid ~= -1 then

					// Disable weed
					self:SetBodygroup(2,0)

					// Update dough color
					self:SetColor(zwf.f.LerpColor((1 / zwf.config.Cooking.mix_duration) * mixtime, zwf.default_colors["white01"], zwf.config.Plants[_weedid].color))
				end
			end
		end
	else
		self.LastWorkState = -1
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
		zwf.f.ClientAnim(self, "open", 5)

	elseif _workstate == 2 then

		// Play close Animation
		zwf.f.ClientAnim(self, "close", 5)

	elseif _workstate == 3 then

		// Play run Animation
		zwf.f.ClientAnim(self, "run", 1)
	end
end

function ENT:OnRemove()
	self:StopSound("zwf_mixer_loop")
end
