include("shared.lua")

function ENT:Initialize()
	self.LastPowerLevel = -1
	self.LastPower = -1
	self.IsRunning = false

	self.Cached_Rope = false
	self.RopeRefresh = true

	self.PowerSource = nil
	zwf.f.EntList_Add(self)

	self.HasAirEffect = false
end

function ENT:Draw()
	self:DrawModel()

	zwf.f.UpdateEntityVisuals(self)

	if GetConVar("zwf_cl_vfx_drawui"):GetInt() == 1 and zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 300) then
		self:DrawUI()
	end
end



function ENT:DrawUI()
	local Pos02 = self:GetPos() + self:GetRight() * 2.4 + self:GetUp() * 30

	local Ang02 = self:GetAngles()
	Ang02:RotateAroundAxis(self:GetRight(),90)
	Ang02:RotateAroundAxis(self:GetUp(),90)
	Ang02:RotateAroundAxis(self:GetRight(),90)


	local _power = self:GetPower()
	local _isrunning = self:GetIsRunning()
	cam.Start3D2D(Pos02, Ang02, 0.1)

		//Power Bar
		if _power > 0 then
			local newPowerLvl = (68 / zwf.config.Ventilator.Power_storage) * _power

			newPowerLvl = math.Clamp(newPowerLvl,0,68)

			if self.LastPowerLevel ~= newPowerLvl then
				if newPowerLvl > self.LastPowerLevel then
					self.LastPowerLevel = self.LastPowerLevel + 25 * FrameTime()
					self.LastPowerLevel = math.Clamp(self.LastPowerLevel, 0, newPowerLvl)
				else
					self.LastPowerLevel = self.LastPowerLevel - 25 * FrameTime()
					self.LastPowerLevel = math.Clamp(self.LastPowerLevel, newPowerLvl, 380)
				end
			end

			draw.RoundedBox(3, -8 , -18, 16, self.LastPowerLevel, zwf.default_colors["power"])
		end
	cam.End3D2D()


	local Pos01 = self:GetPos() + self:GetRight() * 2.4 + self:GetUp() * 30
	local Ang01 = self:GetAngles()
	Ang01:RotateAroundAxis(self:GetRight(),90)
	Ang01:RotateAroundAxis(self:GetUp(),90)
	Ang01:RotateAroundAxis(self:GetRight(),-90)


	cam.Start3D2D(Pos01, Ang01, 0.1)

		draw.SimpleText( _power,zwf.f.GetFont("zwf_ventilator_font01"), 0, -15, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		if self:EnableButton(LocalPlayer()) then
			if _isrunning then
				draw.RoundedBox(5, -10, -84, 20, 20, zwf.default_colors["green02"])
			else
				draw.RoundedBox(5, -10, -84, 20, 20, zwf.default_colors["red01"])
			end
		else
			if _isrunning then
				draw.RoundedBox(5, -10, -84, 20, 20, zwf.default_colors["green03"])
			else
				draw.RoundedBox(5, -10, -84, 20, 20, zwf.default_colors["red02"])
			end
		end

		surface.SetDrawColor(zwf.default_colors["white01"])
		surface.SetMaterial(zwf.default_materials["switch"])
		surface.DrawTexturedRect(-8, -82, 16, 16)
		draw.NoTexture()
	cam.End3D2D()
end

function ENT:OnVolumeChange()
	if self.SoundObj and self.SoundObj:IsPlaying() == true then
		self.SoundObj:ChangeVolume(zwf.SoundVolume, 0)
	end
end

function ENT:Think()
	if zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 600) then
		local _isrunning = self:GetIsRunning()
		local _power = self:GetPower()

		if self.IsRunning ~= _isrunning or self.LastPower ~= _power then


			if self.IsRunning  ~= _isrunning then
				if self.IsRunning then
					zwf.f.EmitSoundENT("zwf_button_off", self)
				else
					zwf.f.EmitSoundENT("zwf_button_on", self)
				end
			end

			self.IsRunning = _isrunning
			self.LastPower = _power


			if self.IsRunning and self.LastPower > zwf.config.Ventilator.Power_usage then
				if self:GetSequenceName(self:GetSequence()) ~= "run" then
					zwf.f.ClientAnim(self,"run", 1)
				end
			else
				zwf.f.ClientAnim(self,"idle", 1)
			end
		end

		local _PowerSource = self:GetPowerSource()

		if self.PowerSource ~= _PowerSource then
			self.PowerSource = _PowerSource

			if IsValid(self.PowerSource) then
				self:SetBodygroup(0,1)
			else
				self:SetBodygroup(0,0)
			end
		end

		if self.IsRunning and self.LastPower > 0 then

			if GetConVar("zwf_cl_vfx_ventilatorffects"):GetInt() == 1 then
				if self.HasAirEffect == false then
					zwf.f.ParticleEffectAttach("zwf_airwave", PATTACH_POINT_FOLLOW, self, 1)
					self.HasAirEffect = true
				end
			else
				if self.HasAirEffect == true then
					self:StopParticlesNamed("zwf_airwave")
					self.HasAirEffect = false
				end
			end

			if self.SoundObj == nil then
				self.SoundObj = CreateSound(self, "zwf_ventilator_loop")
			end

			if self.SoundObj:IsPlaying() == false then
				self.SoundObj:Play()
				self.SoundObj:ChangeVolume(0, 0)
				self.SoundObj:ChangeVolume(zwf.SoundVolume, 0)
			end
		else

			if self.HasAirEffect == true then
				self:StopParticlesNamed("zwf_airwave")
				self.HasAirEffect = false
			end

			if self.SoundObj and self.SoundObj:IsPlaying() == true then
				self.SoundObj:ChangeVolume(0, 0)
				self.SoundObj:Stop()
			end
		end
	else

		if self.SoundObj and self.SoundObj:IsPlaying() == true then
			self.SoundObj:ChangeVolume(0, 0)
			self.SoundObj:Stop()
		end

		if self.HasAirEffect == true then
			self:StopParticlesNamed("zwf_airwave")
			self.HasAirEffect = false
		end

		self.PowerSource = nil
	end

	self:SetNextClientThink(CurTime())
	return true
end

function ENT:Remove()
	if self.SoundObj and self.SoundObj:IsPlaying() == true then
		self.SoundObj:ChangeVolume(0, 0)
		self.SoundObj:Stop()
	end
end

function ENT:UpdateVisuals()
	if IsValid(self.PowerSource) then
		self:SetBodygroup(0,1)
	else
		self:SetBodygroup(0,0)
	end
end
