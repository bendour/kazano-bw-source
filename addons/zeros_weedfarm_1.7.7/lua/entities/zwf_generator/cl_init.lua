include("shared.lua")

function ENT:Initialize()
	zwf.f.EntList_Add(self)
	self.Cached_Rope = false
	self.RopeRefresh = true

	self.LastPowerLevel = -1

	self.AnimState = false
	self.IsRefilling = false
	self.Output = nil

	self.HasSmokeEffect = false
	self.HasDamagedEffect = false
end

function ENT:Draw()
	self:DrawModel()

	zwf.f.UpdateEntityVisuals(self)

	if GetConVar("zwf_cl_vfx_drawui"):GetInt() == 1 and zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 300) then
		self:DrawScreenUI()
	end
end


function ENT:DrawScreenUI()

	local _maintance = self:GetMaintance()

	if _maintance < zwf.config.Generator.Maintance_time then
		local Pos01 = self:GetPos() + self:GetUp() * 3.5 + self:GetRight() * -6 + self:GetForward() * 19.15
		local Ang01 = self:GetAngles()
		Ang01:RotateAroundAxis(self:GetRight(),180)
		Ang01:RotateAroundAxis(self:GetForward(),90)
		Ang01:RotateAroundAxis(self:GetUp(),-90)

		cam.Start3D2D(Pos01, Ang01, 0.1)

			//Enable Button
			if self:EnableButton(LocalPlayer()) then
				if self.AnimState == 1 then

					surface.SetDrawColor(zwf.default_colors["red01"])
					surface.SetMaterial(zwf.default_materials["button_circle"])
					surface.DrawTexturedRect(-40, -90, 80, 80)
					draw.NoTexture()

					surface.SetDrawColor(zwf.default_colors["white01"])
					surface.SetMaterial(zwf.default_materials["switch"])
					surface.DrawTexturedRect(-30, -81, 60, 60)
					draw.NoTexture()

				else

					surface.SetDrawColor(zwf.default_colors["green02"])
					surface.SetMaterial(zwf.default_materials["button_circle"])
					surface.DrawTexturedRect(-40, -90, 80, 80)
					draw.NoTexture()

					surface.SetDrawColor(zwf.default_colors["white01"])
					surface.SetMaterial(zwf.default_materials["switch"])
					surface.DrawTexturedRect(-30, -81, 60, 60)
					draw.NoTexture()
				end
			else
				if self.AnimState == 1 then

					surface.SetDrawColor(zwf.default_colors["red02"])
					surface.SetMaterial(zwf.default_materials["button_circle"])
					surface.DrawTexturedRect(-40, -90, 80, 80)
					draw.NoTexture()

					surface.SetDrawColor(zwf.default_colors["white01"])
					surface.SetMaterial(zwf.default_materials["switch"])
					surface.DrawTexturedRect(-30, -81, 60, 60)
					draw.NoTexture()

				else
					surface.SetDrawColor(zwf.default_colors["green03"])
					surface.SetMaterial(zwf.default_materials["button_circle"])
					surface.DrawTexturedRect(-40, -90, 80, 80)
					draw.NoTexture()

					surface.SetDrawColor(zwf.default_colors["white01"])
					surface.SetMaterial(zwf.default_materials["switch"])
					surface.DrawTexturedRect(-30, -81, 60, 60)
					draw.NoTexture()
				end
			end
		cam.End3D2D()
	end

	local Pos = self:GetPos() + self:GetUp() * 29 + self:GetRight() * -17.5
	local Ang = self:GetAngles()
	Ang:RotateAroundAxis(self:GetRight(),90)
	Ang:RotateAroundAxis(self:GetForward(),90)
	Ang:RotateAroundAxis(self:GetUp(),-90)


	cam.Start3D2D(Pos, Ang, 0.1)

		if _maintance < zwf.config.Generator.Maintance_time then
			local _power = self:GetPower()

			draw.RoundedBox(5, -190 , 35, 380, 40,  zwf.default_colors["gray01"])

			//Power Bar
			if _power > 0 then

				local newPowerLvl = (380 / zwf.config.Generator.Power_storage) * _power
				newPowerLvl = math.Clamp(newPowerLvl,0,380)
				if self.LastPowerLevel ~= newPowerLvl then
					if newPowerLvl > self.LastPowerLevel then
						self.LastPowerLevel = self.LastPowerLevel + 50 * FrameTime()
						self.LastPowerLevel = math.Clamp(self.LastPowerLevel, 0, newPowerLvl)
					else
						self.LastPowerLevel = self.LastPowerLevel - 50 * FrameTime()
						self.LastPowerLevel = math.Clamp(self.LastPowerLevel, newPowerLvl, 380)
					end
				end

				draw.RoundedBox(5, -190 , 35, self.LastPowerLevel, 40,zwf.default_colors["power"])

			end
			draw.SimpleText( _power,zwf.f.GetFont("zwf_watertank_font01"), 0, 55, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		else

			if _maintance >= zwf.config.Generator.Maintance_time then
				if self:MaintanceButton(LocalPlayer()) then
					surface.SetDrawColor(zwf.default_colors["black01"])
					surface.SetMaterial(zwf.default_materials["shadow_circle"])
					surface.DrawTexturedRect(-300, 5, 600, 140)
					draw.NoTexture()
					draw.SimpleText(">> " .. zwf.language.General["generator_repair"] .. " <<", zwf.f.GetFont("zwf_generator_font01"), 0, 10, Color(237, 108, 108, math.abs(math.sin(RealTime() * math.pi * 5)) * 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
					draw.SimpleText(">> " .. zwf.language.General["generator_repair"] .. " <<", zwf.f.GetFont("zwf_generator_font02"), 0, 10, Color(203, 60, 60, math.abs(math.sin(RealTime() * math.pi * 5)) * 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
				else
					draw.SimpleText(">> " .. zwf.language.General["generator_repair"] .. " <<", zwf.f.GetFont("zwf_generator_font01"), 0, 10, Color(203, 60, 60, math.abs(math.sin(RealTime() * math.pi * 5)) * 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
				end
			end
		end
	cam.End3D2D()



	cam.Start3D2D(self:LocalToWorld(Vector(8, 0, 40)), Angle(0, EyeAngles().y - 90, -EyeAngles().x + 90), 0.1)

		draw.SimpleText(zwf.language.General["Fuel"] .. ": " .. self:GetFuel() .. zwf.config.UoL, zwf.f.GetFont("zwf_generator_font03"), 0, 5, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	cam.End3D2D()
end

function ENT:OnVolumeChange()

	if self.SoundObj and self.SoundObj:IsPlaying() == true then
		self.SoundObj:ChangeVolume(zwf.SoundVolume, 0)
	end

	if self.SoundObj_Damaged and self.SoundObj_Damaged:IsPlaying() == true then
		self.SoundObj_Damaged:ChangeVolume(zwf.SoundVolume, 0)
	end
end

function ENT:Think()

	if zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 1000) then

		local _Output = self:GetOutput()
		if self.Output ~= _Output then
			self.Output = _Output

			if IsValid(self.Output) then
				self:SetBodygroup(9,1)
			else
				self:SetBodygroup(9,0)
			end
		end

		if self:GetMaintance() >= zwf.config.Generator.Maintance_time then

			self:Generator_Damaged_VFX()
		else

			if self.SoundObj_Damaged and self.SoundObj_Damaged:IsPlaying() == true then
				self.SoundObj_Damaged:ChangeVolume(0, 0)
				self.SoundObj_Damaged:Stop()
			end

			if self.HasDamagedEffect then
				self:StopParticlesNamed("zwf_damaged")
				self.HasDamagedEffect = false
			end

			self:Generator_Running_VFX()
		end



		local _animstate = self:GetAnimState()
		if self.AnimState ~= _animstate then
			self.AnimState = _animstate

			if _animstate == 0 then

				zwf.f.ClientAnim(self, "idle", 1)
			elseif _animstate == 1 then
				zwf.f.ClientAnim(self, "running", 1)
			elseif _animstate == 2 then
				zwf.f.ClientAnim(self, "damaged", 1)
			end
		end


		local _isrefilling = self:GetIsRefilling()
		if self.IsRefilling ~= _isrefilling then
			self.IsRefilling = _isrefilling

			if self.IsRefilling then
				self:SetBodygroup(8, 1)
			else
				self:SetBodygroup(8, 0)
			end
		end

	else
		self.IsDamaged = false
		self.AnimState = -1
		self.Output = nil

		if self.HasSmokeEffect then
			self:StopParticlesNamed("zwf_exaust")
			self.HasSmokeEffect = false
		end

		if self.SoundObj and self.SoundObj:IsPlaying() == true then
			self.SoundObj:ChangeVolume(0, 0)
			self.SoundObj:Stop()
		end


		if self.HasDamagedEffect then
			self:StopParticlesNamed("zwf_damaged")
			self.HasDamagedEffect = false
		end

		if self.SoundObj_Damaged and self.SoundObj_Damaged:IsPlaying() == true then
			self.SoundObj_Damaged:ChangeVolume(0, 0)
			self.SoundObj_Damaged:Stop()
		end
	end

	self:SetNextClientThink(CurTime())
	return true
end

function ENT:Generator_Running_VFX()
	if self.AnimState == 1 then


		if self.HasSmokeEffect == false then

			zwf.f.ParticleEffectAttach("zwf_exaust", PATTACH_POINT_FOLLOW, self, 1)

			self.HasSmokeEffect = true
		end

		if self.SoundObj == nil then
			self.SoundObj = CreateSound(self, "zwf_generator_running")
		end

		if self.SoundObj:IsPlaying() == false then
			self.SoundObj:Play()
			self.SoundObj:ChangeVolume(0, 0)
			self.SoundObj:ChangeVolume(zwf.SoundVolume * 0.7, 0)
		end
	elseif self.AnimState == 0 then

		if self.SoundObj and self.SoundObj:IsPlaying() == true then
			self.SoundObj:ChangeVolume(0, 0)
			self.SoundObj:Stop()
			zwf.f.EmitSoundENT("zwf_generator_stop", self)
		end

		if self.HasSmokeEffect then
			self:StopParticlesNamed("zwf_exaust")
			self.HasSmokeEffect = false
		end
	end
end


function ENT:Generator_Damaged_VFX()

	if self.HasDamagedEffect == false then
		zwf.f.ParticleEffectAttach("zwf_damaged", PATTACH_POINT_FOLLOW, self, 0)
		self.HasDamagedEffect = true
	end

	if self.SoundObj_Damaged == nil then
		self.SoundObj_Damaged = CreateSound(self, "zwf_generator_damaged")
	end

	if self.SoundObj_Damaged:IsPlaying() == false then
		self.SoundObj_Damaged:Play()
		self.SoundObj_Damaged:ChangeVolume(0, 0)
		self.SoundObj_Damaged:ChangeVolume(zwf.SoundVolume * 0.7, 0)
	end
end


function ENT:OnRemove()
	if self.HasSmokeEffect then
		self:StopParticlesNamed("zwf_exaust")
		self.HasSmokeEffect = false
	end

	if self.SoundObj and self.SoundObj:IsPlaying() == true then
		self.SoundObj:ChangeVolume(0, 0)
		self.SoundObj:Stop()
	end


	if self.HasDamagedEffect then
		self:StopParticlesNamed("zwf_damaged")
		self.HasDamagedEffect = false
	end

	if self.SoundObj_Damaged and self.SoundObj_Damaged:IsPlaying() == true then
		self.SoundObj_Damaged:ChangeVolume(0, 0)
		self.SoundObj_Damaged:Stop()
	end
end


function ENT:UpdateVisuals()

	if IsValid(self.Output) then
		self:SetBodygroup(9,1)
	else
		self:SetBodygroup(9,0)
	end
end
