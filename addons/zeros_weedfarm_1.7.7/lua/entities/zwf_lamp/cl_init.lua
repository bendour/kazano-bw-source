include("shared.lua")

function ENT:Initialize()
	self.LastPower = -1
	self.LastRunning = -1
	self.LastPowerLevel = -1
	self.Cached_Rope = false
	self.RopeRefresh = true

	self.Output = nil
	self.PowerSource = nil

	self.PixVis = util.GetPixelVisibleHandle()

	self.LampID = self:GetLampID()
	self.LampData =  zwf.config.Lamps[self.LampID ]

	self:DrawShadow(false)

	zwf.f.EntList_Add(self)
end

function ENT:PixVisLight()
	local LightPos = self:GetPos() - self:GetUp() * 2

	if self.LampID  == 1 then
		LightPos = self:GetPos() - self:GetUp() * 2
	else
		LightPos = self:GetPos() - self:GetUp() * 10
	end

	render.SetMaterial(zwf.default_materials["light_sprite"])

	local ViewNormal = LightPos - EyePos()
	ViewNormal:Normalize()

	local Visibile = util.PixelVisible(LightPos, 4, self.PixVis)
	if (not Visibile or Visibile < 0.1) then return end

	render.DrawSprite(LightPos, 256, 128, self.LampData.light_color)
end

function ENT:DynamicLight()
	local dlight01 = DynamicLight(self:EntIndex())

	if (dlight01) then
		dlight01.pos = self:GetPos() + self:GetUp() * -35
		dlight01.r = self.LampData.light_color.r
		dlight01.g = self.LampData.light_color.g
		dlight01.b = self.LampData.light_color.b
		dlight01.brightness = 0.5
		dlight01.Decay = 1000
		dlight01.Size = 1000
		dlight01.DieTime = CurTime() + 1
	end
end

function ENT:Draw()
	self:DrawModel()

	zwf.f.UpdateEntityVisuals(self)

	if zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 500) then

		if GetConVar("zwf_cl_vfx_drawui"):GetInt() == 1 then
			self:DrawUI()
		end

		if self.LastRunning == true and self.LastPower > 0 and GetConVar("zwf_cl_vfx_lightsprite"):GetInt() == 1 then
			self:PixVisLight()
		end
	end

	if GetConVar("zwf_cl_vfx_dynlight"):GetInt() == 1 and zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 1000) and self.LastRunning == true and self.LastPower > 0 then
		self:DynamicLight()
	end
end


function ENT:DrawUI()
	local Pos = self:GetPos() + self:GetRight() * -7 + self:GetUp() * 0.1 + self:GetForward() * 15

	local Ang02 = self:GetAngles()
	Ang02:RotateAroundAxis(self:GetRight(),-90)
	Ang02:RotateAroundAxis(self:GetUp(),90)
	Ang02:RotateAroundAxis(self:GetRight(),-90)


	local _power = self:GetPower()
	local _isrunning = self:GetIsRunning()
	cam.Start3D2D(Pos, Ang02, 0.1)

		//BG

		//Power Bar

		draw.RoundedBox(5, -215 , 30, 100, 20,  zwf.default_colors["gray01"])

		if _power > 0 then
			local newPowerLvl = (92 / zwf.config.Lamps[self:GetLampID()].Power_storage) * _power

			newPowerLvl = math.Clamp(newPowerLvl,0,92)

			if self.LastPowerLevel ~= newPowerLvl then
				if newPowerLvl > self.LastPowerLevel then
					self.LastPowerLevel = self.LastPowerLevel + 25 * FrameTime()
					self.LastPowerLevel = math.Clamp(self.LastPowerLevel, 0, newPowerLvl)
				else
					self.LastPowerLevel = self.LastPowerLevel - 25 * FrameTime()
					self.LastPowerLevel = math.Clamp(self.LastPowerLevel, newPowerLvl, 380)
				end
			end

			draw.RoundedBox(5, -211 , 32, self.LastPowerLevel, 16, zwf.default_colors["power"])
		end

		draw.SimpleText( _power,zwf.f.GetFont("zwf_lamp01_font01"), -165, 41, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)


		if self:EnableButton(LocalPlayer()) then
			if _isrunning then
				draw.RoundedBox(5, -190, -25, 50, 50, zwf.default_colors["green02"])
			else
				draw.RoundedBox(5, -190, -25, 50, 50, zwf.default_colors["red01"])
			end
		else
			if _isrunning then
				draw.RoundedBox(5, -190, -25, 50, 50, zwf.default_colors["green03"])
			else
				draw.RoundedBox(5, -190, -25, 50, 50, zwf.default_colors["red02"])
			end
		end


		surface.SetDrawColor(zwf.default_colors["white01"])
		surface.SetMaterial(zwf.default_materials["switch"])
		surface.DrawTexturedRect(-185, -20, 40, 40)
		draw.NoTexture()
	cam.End3D2D()
end


function ENT:Lamp_Running_VFX()
	if self.LastRunning and self.LastPower > 0 then

		if self.SoundObj == nil then
			if self.LampID == 1 then
				self.SoundObj = CreateSound(self, "zwf_lamp_sodium_loop")
			elseif self.LampID == 2 then
				self.SoundObj = CreateSound(self, "zwf_lamp_led_loop")
			end
		end

		if self.SoundObj:IsPlaying() == false then

			if self.LampID == 1 then
				zwf.f.EmitSoundENT("zwf_lamp_sodium_start", self)
			end

			self.SoundObj:Play()
			self.SoundObj:ChangeVolume(0, 0)
			self.SoundObj:ChangeVolume(zwf.SoundVolume, 1)
		end
	else

		if self.SoundObj and self.SoundObj:IsPlaying() == true then

			if self.LampID == 1 then
				zwf.f.EmitSoundENT("zwf_lamp_sodium_stop", self)
			end

			self.SoundObj:ChangeVolume(0, 1)
			self.SoundObj:Stop()
		end
	end
end

function ENT:OnVolumeChange()
	if self.SoundObj and self.SoundObj:IsPlaying() == true then
		self.SoundObj:ChangeVolume(zwf.SoundVolume, 0)
	end
end

function ENT:Think()
	if zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 1000) then

		local _energy = self:GetPower()
		local _isrunning = self:GetIsRunning()


		if self.ClientProps == nil then
			self.ClientProps = {}
		end

		if GetConVar("zwf_cl_vfx_lightcone"):GetInt() == 1 then

			if not IsValid(self.ClientProps["LightVolume"]) then
				self:SpawnClientModel_LightVolume()
			else
				if self.LastPower > 0 and self.LastRunning then
					if self.ClientProps["LightVolume"]:GetNoDraw() == true then
						self.ClientProps["LightVolume"]:SetPos(self:GetPos())
						self.ClientProps["LightVolume"]:SetNoDraw(false)
						self.ClientProps["LightVolume"]:SetColor(self.LampData.light_color)
					end
				else
					if self.ClientProps["LightVolume"]:GetNoDraw() == false then
						self.ClientProps["LightVolume"]:SetNoDraw(true)
					end
				end
			end
		else
			if IsValid(self.ClientProps["LightVolume"]) then
				self.ClientProps["LightVolume"]:Remove()
			end
		end

		if self.LastPower ~= _energy or self.LastRunning  ~= _isrunning then


			if self.LastRunning  ~= _isrunning then
				if self.LastRunning then
					zwf.f.EmitSoundENT("zwf_button_off", self)
				else
					zwf.f.EmitSoundENT("zwf_button_on", self)
				end
			end

			self.LastRunning = _isrunning

			self.LastPower = _energy


			if self.LastPower > 0 and self.LastRunning then
				self:SetSkin(1)
			else
				self:SetSkin(0)
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


		local _Output = self:GetOutput()
		if self.Output ~= _Output then
			self.Output = _Output

			if IsValid(self.Output) then
				self:SetBodygroup(1,1)
			else
				self:SetBodygroup(1,0)
			end
		end


		self:Lamp_Running_VFX()
	else
		self:RemoveClientModels()
		self.LastPower = -1
		self.PowerSource = nil
		self.Output = nil
		self.LastRunning = false
	end
	self:SetNextClientThink(CurTime())
	return true
end

function ENT:SpawnClientModel_LightVolume()

	local ent = ents.CreateClientProp()
	if not IsValid(ent) then return end
	ent:SetModel("models/zerochain/props_weedfarm/zwf_light_volume.mdl")
	ent:SetPos(self:GetPos())
	ent:SetAngles(self:GetAngles())
	ent:Spawn()
	ent:Activate()
	ent:SetParent(self)
	ent:SetNoDraw(true)
	ent:SetRenderMode(RENDERMODE_TRANSALPHA)
	self.ClientProps["LightVolume"] = ent
end

function ENT:RemoveClientModels()
	if (self.ClientProps and table.Count(self.ClientProps) > 0) then
		for k, v in pairs(self.ClientProps) do
			if IsValid(v) then
				v:Remove()
			end
		end
	end

	self.ClientProps = {}
end

function ENT:OnRemove()
	self:RemoveClientModels()

	if self.SoundObj and self.SoundObj:IsPlaying() == true then
		self.SoundObj:ChangeVolume(0, 1)
		self.SoundObj:Stop()
	end
end

function ENT:UpdateVisuals()
	if IsValid(self.PowerSource) then
		self:SetBodygroup(0,1)
	else
		self:SetBodygroup(0,0)
	end

	if IsValid(self.Output) then
		self:SetBodygroup(1,1)
	else
		self:SetBodygroup(1,0)
	end
end
