include("shared.lua")

function ENT:Initialize()
	zwf.f.EntList_Add(self)
	self.Cached_Rope = false
	self.RopeRefresh = true

	self.PlantData = nil
	self.NutritionData = {
		name = "nil",
		b_speed = 0,
		b_amount = 0,
		b_plague = 0
	}

	self.LastSeed = -1
	self.LastWater = -1

	self.HasSoil = false

	self.Grow_Duration = -1

	self.LastWaterSource = nil

	self.HasPlagueEffect = false
end

function ENT:Think()

	zwf.f.LoopedSound(self, "zwf_plant_plague", self.HasPlagueEffect )

	if zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 1000) then

		local seed = self:GetSeed()
		if seed ~= self.LastSeed then

			self.LastSeed = seed

			if self.LastSeed == -1 then
				self.PlantData = nil
				self.Grow_Duration = -1
			else

				self.PlantData = zwf.config.Plants[self.LastSeed]

				local growBoost = self:GetPerf_Time() - 100
				self.Grow_Duration = self.PlantData.Grow.Duration * (1 - ((1 / 100) * growBoost))
				self.Grow_Duration = math.Clamp(self.Grow_Duration,zwf.f.Flowerpot_GetMinGrowDuration(self),99999999)
			end

			self:UpdateDirt()
		end


		local _soil = self:GetHasSoil()
		if self.HasSoil ~= _soil then
			self.HasSoil = _soil

			if self.HasSoil then
				self:SetBodygroup(1,1)
			else
				self:SetBodygroup(1,0)
			end


			self:UpdateDirt()
		end

		local _water = self:GetWater()
		if self.LastWater ~= _water then

			self.LastWater = _water


			self:UpdateDirt()
		end

		local _plague = self:GetHasPlague()
		if self.HasPlagueEffect ~= _plague then

			self.HasPlagueEffect = _plague


			if self.HasPlagueEffect then
				zwf.f.ParticleEffectAttach("zwf_flys", PATTACH_POINT_FOLLOW, self, 0)

			else
				self:StopParticlesNamed("zwf_flys")
			end
		end
	else

		self.LastWater = -1
		self.HasSoil = -1

		if self.HasPlagueEffect == true then
			self.HasPlagueEffect = false
			self:StopParticlesNamed("zwf_flys")
		end

		self.NutritionData = nil


		self.LastSeed = -1
	end
end



function ENT:UpdateVisuals()

	if self.HasSoil then
		self:SetBodygroup(1,1)
	else
		self:SetBodygroup(1,0)
	end

	self:UpdateDirt()
end

function ENT:UpdateDirt()
	local MinWaterLevel , MaxWaterLevel

	if self.PlantData and self.LastSeed ~= nil and self.LastSeed ~= -1 then
		MinWaterLevel , MaxWaterLevel = zwf.f.Flowerpot_GetWaterLevels(self)
	else
		MinWaterLevel = zwf.config.Flowerpot.Water_Capacity * 0.1
		MaxWaterLevel = zwf.config.Flowerpot.Water_Capacity * 0.9
	end

	if self.LastWater > MaxWaterLevel then
		self:SetSkin(1)
	elseif self.LastWater < MinWaterLevel then
		self:SetSkin(2)
	else
		self:SetSkin(0)
	end
end

function ENT:Draw()
	self:DrawModel()

	zwf.f.UpdateEntityVisuals(self)

	if GetConVar("zwf_cl_vfx_drawui"):GetInt() == 1 and zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 500) then
		self:DrawUI()
	end
end

function ENT:DrawUI()
	local Pos = self:GetPos() + self:GetUp() * 8 + self:GetRight() * -15
	local Ang = self:GetAngles()

	Ang:RotateAroundAxis(self:GetRight(),90)
	Ang:RotateAroundAxis(self:GetForward(),90)
	Ang:RotateAroundAxis(self:GetUp(),-90)

	local _nutritionID = self:GetNutritionID()
	local _light = self:GetLight()
	local _progress = self:GetProgress()
	local _temperatur = self:GetTemperatur()





	if _nutritionID ~= -1 then
		if self.NutritionData == nil  then
			local nutData = zwf.config.Nutrition[_nutritionID]

			local b_speed = 0
			local b_amount = 0
			local b_plague = 0

			for k, v in pairs(nutData.boost) do
				if v.b_type == 1 then
					b_speed = b_speed + v.b_amount
				elseif v.b_type == 2 then
					b_amount = b_amount + v.b_amount
				elseif v.b_type == 3 then
					b_plague = b_plague + v.b_amount
				end
			end

			self.NutritionData = {
				name = nutData.name,
				b_speed = b_speed,
				b_amount = b_amount,
				b_plague = b_plague,
			}
		end
	else
		self.NutritionData = nil
	end



	cam.Start3D2D(Pos, Ang, 0.1)

		//BG
		draw.RoundedBox(5, -90 , -90, 180, 150,  zwf.default_colors["gray01"])

		local _harvestReady = self:GetHarvestReady()
		local _hasplague = self:GetHasPlague()


		draw.RoundedBox(2, -85 , 10, 170, 20,  zwf.default_colors["black04"])
		if self.PlantData and self.LastSeed ~= nil and self.LastSeed ~= -1 then

			if _hasplague then
				draw.RoundedBox(2, -85 , 10, 170, 20, zwf.default_colors["red02"])
				draw.SimpleText(zwf.language.General["plant_infected"], zwf.f.GetFont("zwf_flowerpot_font01"), 0, 19,  zwf.default_colors["black01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			elseif _harvestReady and zwf.config.Growing.PostGrow.Enabled then
				draw.RoundedBox(2, -85 , 10, 170, 20, zwf.default_colors["orange02"])
				draw.SimpleText(zwf.language.General["plant_postgrow"], zwf.f.GetFont("zwf_flowerpot_font01"), 0, 19, zwf.default_colors["black01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			else
				if _progress > 0 then
					local progressBar = (170 / self.Grow_Duration) * _progress
					draw.RoundedBox(2, -85 , 10, math.Clamp(progressBar,0,170), 20,  zwf.default_colors["green03"])
				end
			end

			draw.SimpleText(self:GetSeedName(), zwf.f.GetFont("zwf_flowerpot_font01"), 0, -70, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			draw.SimpleText(zwf.language.General["plant_empty"], zwf.f.GetFont("zwf_flowerpot_font01"), 0, -70, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		draw.RoundedBox(2, -85 , 35, 170, 20,  zwf.default_colors["black04"])
		if self.LastWater > 0 then
			local waterbar = (170 / zwf.config.Flowerpot.Water_Capacity) * self.LastWater
			draw.RoundedBox(2, -85 , 35, math.Clamp(waterbar,0,170), 20,  zwf.default_colors["water"])
		end

		if self.PlantData and self.LastSeed ~= nil and self.LastSeed ~= -1 then

			// Water Level Info
			draw.SimpleText(zwf.language.General["Bad"], zwf.f.GetFont("zwf_flowerpot_font03"), -80, 45, zwf.default_colors["white01"], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(zwf.language.General["Bad"], zwf.f.GetFont("zwf_flowerpot_font03"), 80, 45, zwf.default_colors["white01"], TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			draw.SimpleText(zwf.language.General["Good"], zwf.f.GetFont("zwf_flowerpot_font03"), 0, 45, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			local MinWaterLevel , MaxWaterLevel = zwf.f.Flowerpot_GetWaterLevels(self)

			local wMinBar = (170 / zwf.config.Flowerpot.Water_Capacity) * MinWaterLevel

			local wMaxBar = (170 / zwf.config.Flowerpot.Water_Capacity) * MaxWaterLevel

			draw.RoundedBox(0, wMinBar - 85, 35, 2, 20, zwf.default_colors["white02"])
			draw.RoundedBox(0,  wMaxBar - 85, 35, 2, 20,zwf.default_colors["white02"])


			// State
			if self:GetHasPlague() then
				surface.SetDrawColor(zwf.default_colors["white01"])
				surface.SetMaterial(zwf.default_materials["plant_infected"])
				surface.DrawTexturedRect(-30, -55, 60, 60)
				draw.NoTexture()
			else
				if self.LastWater < MinWaterLevel or self.LastWater > MaxWaterLevel or _temperatur > 25 or  _light <= 0 then
					surface.SetDrawColor(zwf.default_colors["white01"])
					surface.SetMaterial(zwf.default_materials["plant_sad"])
					surface.DrawTexturedRect(-30, -55, 60, 60)
					draw.NoTexture()

				elseif _harvestReady then
					surface.SetDrawColor(zwf.default_colors["white01"])
					surface.SetMaterial(zwf.default_materials["plant_harvestready"])
					surface.DrawTexturedRect(-30, -55, 60, 60)
					draw.NoTexture()

				else
					surface.SetDrawColor(zwf.default_colors["white01"])
					surface.SetMaterial(zwf.default_materials["plant_happy"])
					surface.DrawTexturedRect(-30, -55, 60, 60)
					draw.NoTexture()
				end
			end
		end



		// Temperatur
		local tFract = (1 / 30) * _temperatur
		local tempColor = zwf.f.LerpColor(tFract, zwf.default_colors["blue01"], zwf.default_colors["red04"])
		_temperatur = 10 + _temperatur
		draw.SimpleText(_temperatur .. "c", zwf.f.GetFont("zwf_flowerpot_font04"), -58, -25, tempColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		surface.SetDrawColor(zwf.default_colors["white03"])
		surface.SetMaterial(zwf.default_materials["temperatur"])
		surface.DrawTexturedRect(-87, -55, 60, 60)
		draw.NoTexture()


		// Light
		if _light > 0 then

			surface.SetDrawColor(zwf.default_colors["yellow01"])
			surface.SetMaterial(zwf.default_materials["sun"])
			surface.DrawTexturedRect(38, -43, 40, 40)
			draw.NoTexture()
		else
			surface.SetDrawColor(zwf.default_colors["white03"])
			surface.SetMaterial(zwf.default_materials["sun"])
			surface.DrawTexturedRect(38, -43, 40, 40)
			draw.NoTexture()
		end


		// Nutrition info
		if _nutritionID ~= -1 and self.NutritionData ~= nil and _harvestReady == false then
			local info = ""

			if self.NutritionData.b_speed > 0 then
				info = info .. zwf.language.General["Speed"] .. ": +" .. self.NutritionData.b_speed .. "% "
			end

			if self.NutritionData.b_amount > 0 then
				info = info .. " | " .. zwf.language.General["Productivity"] .. ": +" .. self.NutritionData.b_amount .. "% "
			end

			if self.NutritionData.b_plague > 0 then
				info = info .. " | " .. zwf.language.General["AntiPlague"] .. ": +" .. self.NutritionData.b_plague .. "% "
			end

			local aSize = 6 * string.len(info)
			draw.RoundedBox(5, -aSize / 2, -118, aSize, 25, zwf.default_colors["gray01"])
			draw.RoundedBox(5, -80, -145, 160, 30, zwf.default_colors["gray01"])
			draw.SimpleText(self.NutritionData.name, zwf.f.GetFont("zwf_flowerpot_font01"), 0, -130, zwf.default_colors["power"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(info, zwf.f.GetFont("zwf_flowerpot_font03"), 0, -105, zwf.default_colors["power"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

	cam.End3D2D()
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:OnRemove()
	self:StopSound("zwf_plant_plague")
end
