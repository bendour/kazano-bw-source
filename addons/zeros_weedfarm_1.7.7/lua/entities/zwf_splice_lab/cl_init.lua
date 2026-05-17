include("shared.lua")

function ENT:Initialize()
	zwf.f.EntList_Add(self)
	self.ClientProps = {}

	self.WeedA = nil
	self.WeedB = nil

	self.PerfData = {
		WeedA_ID = 1,
		WeedA_Name = "nil",
		WeedA_Amount = 100,
		PerfA_Time = 100,
		PerfA_Amount = 100,
		PerfA_THC = 100,

		WeedB_ID = 1,
		WeedB_Name = "nil",
		WeedB_Amount = 100,
		PerfB_Time = 100,
		PerfB_Amount = 100,
		PerfB_THC = 100
	}

	self.SpliceData = nil

	self.IsAnimating = false

	self.ProgressSmooth = -1
end

function ENT:Draw()
	self:DrawModel()

	if zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 300) then
		self:DrawInfo()
	end
end

function ENT:GetColorFromBoostValue(boost)
	if (boost - 100) < 0 then
		return zwf.default_colors["red03"]
	else
		return zwf.default_colors["green06"]
	end
end

function ENT:DrawItem(xPos,mat,txt,color)
	draw.RoundedBox(5, xPos , -85, 73, 120,  zwf.default_colors["black03"])

	surface.SetDrawColor(zwf.default_colors["white01"])
	surface.SetMaterial(mat)
	surface.DrawTexturedRect(xPos-2, -83, 75, 75)

	draw.SimpleText(txt, zwf.f.GetFont("zwf_lamp01_font01"), xPos + 37, 15, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function ENT:DrawPerfData(JarNum,left)
	local Perf_Time
	local Perf_Amount
	local Perf_THC

	local plantData

	if JarNum == 1 then
		Perf_Time = self.PerfData.PerfA_Time
		Perf_Amount = self.PerfData.PerfA_Amount
		Perf_THC = self.PerfData.PerfA_THC

		plantData = zwf.config.Plants[self.PerfData.WeedA_ID]
	elseif JarNum == 2 then
		Perf_Time = self.PerfData.PerfB_Time
		Perf_Amount = self.PerfData.PerfB_Amount
		Perf_THC = self.PerfData.PerfB_THC

		plantData = zwf.config.Plants[self.PerfData.WeedB_ID]
	end


	local c_time = self:GetColorFromBoostValue(Perf_Time)
	local c_amount = self:GetColorFromBoostValue(Perf_Amount)
	local c_thc = self:GetColorFromBoostValue(Perf_THC)


	Perf_Time = 100 - (Perf_Time - 100)
	Perf_Time = Perf_Time * 0.01
	local def_time = plantData.Grow.Duration
	Perf_Time = def_time * Perf_Time
	Perf_Time =  math.Round(Perf_Time) .. "s"

	Perf_Amount = Perf_Amount * 0.01
	local def_amount = plantData.Grow.MaxYieldAmount
	Perf_Amount = def_amount * Perf_Amount
	Perf_Amount =  math.Round(Perf_Amount) .. zwf.config.UoW

	Perf_THC = Perf_THC * 0.01
	local def_thc = plantData.thc_level
	Perf_THC = def_thc * Perf_THC
	Perf_THC =  math.Round(Perf_THC) .. "%"


	local xPos = 0

	if left then
		xPos = -20
	else
		xPos = 240
	end


	self:DrawItem(xPos-230,zwf.default_materials["icon_growtime"],Perf_Time,c_time)
	self:DrawItem(xPos-147,zwf.default_materials["icon_mass"],Perf_Amount,c_amount)
	self:DrawItem(xPos-64,zwf.default_materials["icon_thc"],Perf_THC,c_thc)
end

function ENT:DrawInfo()


	cam.Start3D2D(self:LocalToWorld(Vector(0.7,0,68)), self:LocalToWorldAngles(Angle(0, 90, 90)), 0.05)

		draw.RoundedBox(15, -280 , -170, 560, 340,  zwf.default_colors["violett01"])

		local _SpliceStartTime = self:GetSpliceStartTime()

		if _SpliceStartTime ~= -1 then
			local _SpliceEndTime = _SpliceStartTime + zwf.config.SeedLab.SpliceTime
			local _SpliceProgress = math.Round(_SpliceEndTime - CurTime())

			draw.SimpleText(self:GetSeedName(), zwf.f.GetFont("zwf_jar_font02"), 0, -45, zwf.default_colors["violett02"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			draw.RoundedBox(5, -230 , 65, 460, 50,  zwf.default_colors["violett02"])

			_SpliceProgress = zwf.config.SeedLab.SpliceTime - _SpliceProgress

			self.ProgressSmooth = self.ProgressSmooth + 1.1 * FrameTime()
			self.ProgressSmooth = math.Clamp(self.ProgressSmooth, 0, _SpliceProgress)

			local barW = (460 / zwf.config.SeedLab.SpliceTime) * self.ProgressSmooth
			draw.RoundedBox(5, -230 , 65, barW, 50,  zwf.default_colors["white04"])
		else
			if IsValid(self.WeedA) then

				draw.SimpleText(self.PerfData.WeedA_Name, zwf.f.GetFont("zwf_flowerpot_font04"), -250, -135, zwf.default_colors["white01"], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

				self:DrawPerfData(1, true)

				draw.SimpleText("[" .. zwf.config.Plants[self.PerfData.WeedA_ID].name .. "]", zwf.f.GetFont("zwf_splicelab_font02"), -250, -105, zwf.default_colors["white01"], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

				if self:Remove_WeedA(LocalPlayer()) then
					draw.RoundedBox(5, -250 , 43, 240, 60, zwf.default_colors["red05"])
				else
					draw.RoundedBox(5, -250 , 43, 240, 60,  zwf.default_colors["black03"])
				end

				draw.SimpleText(zwf.language.General["Remove"], zwf.f.GetFont("zwf_generator_font03"), -132, 74, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			if IsValid(self.WeedB) then
				draw.SimpleText(self.PerfData.WeedB_Name, zwf.f.GetFont("zwf_flowerpot_font04"), 10, -135, zwf.default_colors["white01"], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

				self:DrawPerfData(2, false)

				draw.SimpleText("[" .. zwf.config.Plants[self.PerfData.WeedB_ID].name .. "]", zwf.f.GetFont("zwf_splicelab_font02"), 10, -105, zwf.default_colors["white01"], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)


				if self:Remove_WeedB(LocalPlayer()) then
					draw.RoundedBox(5, 10 , 43, 240, 60, zwf.default_colors["red05"])
				else
					draw.RoundedBox(5, 10 , 43, 240, 60,  zwf.default_colors["black03"])
				end
				draw.SimpleText(zwf.language.General["Remove"], zwf.f.GetFont("zwf_generator_font03"), 132, 74, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			if IsValid(self.WeedA) and IsValid(self.WeedB) then
				if self:SpliceWeed(LocalPlayer()) then
					draw.RoundedBox(5, -250 , 112, 500, 50,  zwf.default_colors["violett03"])
				else
					draw.RoundedBox(5, -250 , 112, 500, 50, zwf.default_colors["black03"])
				end
				draw.SimpleText(zwf.language.General["Splice"], zwf.f.GetFont("zwf_generator_font03"), 0, 140, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.RoundedBox(0, -4 , -87, 8, 190,  zwf.default_colors["black03"])
			end

			if not IsValid(self.WeedA) and not IsValid(self.WeedB) then

				draw.SimpleText(zwf.language.General["seedlab_titlescreen"], zwf.f.GetFontFromTextSize(zwf.language.General["seedlab_titlescreen"],12,zwf.f.GetFont("zwf_jar_font02"),zwf.f.GetFont("zwf_watertank_font01")), 0, 0, zwf.default_colors["violett02"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
	cam.End3D2D()
end

function ENT:OnVolumeChange()
	if self.SoundObj and self.SoundObj:IsPlaying() == true then
		self.SoundObj:ChangeVolume(zwf.SoundVolume, 0)
	end
end


function ENT:Think()

	if zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 1000) then
		local _WeedA = self:GetWeedA()
		local _WeedB = self:GetWeedB()

		if self.WeedA ~= _WeedA or self.WeedB ~= _WeedB then

			self:RemoveClientModels()

			if IsValid(_WeedA) then
				self.WeedA = _WeedA

				self.PerfData.WeedA_ID = self.WeedA:GetPlantID()


				self.PerfData.WeedA_Name = self.WeedA:GetWeedName()

				self.PerfData.WeedA_Amount = self.WeedA:GetWeedAmount()

				self.PerfData.PerfA_Time = self.WeedA:GetPerf_Time()
				self.PerfData.PerfA_Amount = self.WeedA:GetPerf_Amount()
				self.PerfData.PerfA_THC = self.WeedA:GetPerf_THC()

				self:SpawnClientModel_Jar(Vector(-9.6,-19.8,41.5),self.PerfData.WeedA_Amount,self.PerfData.WeedA_ID,1)
			else
				self.WeedA = NULL
				self.SpliceData = nil
			end

			if IsValid(_WeedB) then
				self.WeedB = _WeedB

				self.PerfData.WeedB_ID = self.WeedB:GetPlantID()
				self.PerfData.WeedB_Name = self.WeedB:GetWeedName()
				self.PerfData.WeedB_Amount = self.WeedB:GetWeedAmount()

				self.PerfData.PerfB_Time = self.WeedB:GetPerf_Time()
				self.PerfData.PerfB_Amount = self.WeedB:GetPerf_Amount()
				self.PerfData.PerfB_THC = self.WeedB:GetPerf_THC()

				self:SpawnClientModel_Jar(Vector(-9.6,19.8,41.5),self.PerfData.WeedB_Amount,self.PerfData.WeedB_ID,2)
			else
				self.WeedB = NULL
				self.SpliceData = nil
			end

			if IsValid(self.WeedA) and IsValid(self.WeedB) then
				self.SpliceData = zwf.f.SpliceLab_CalculateSpliceData(self.PerfData)
			end
		end

		if not IsValid(self.WeedA) and IsValid(self.ClientProps["Jar1"]) then
			self.ClientProps["Jar1"]:Remove()
		end

		if not IsValid(self.WeedB) and IsValid(self.ClientProps["Jar2"]) then
			self.ClientProps["Jar2"]:Remove()
		end

		local _SpliceStartTime = self:GetSpliceStartTime()

		if self.IsAnimating == false then

			if IsValid(self.WeedA) and IsValid(self.WeedB) and _SpliceStartTime ~= -1 then
				zwf.f.ClientAnim(self, "scanning", 1)
				self.IsAnimating = true
			end
		elseif self.IsAnimating == true then

			if not IsValid(self.WeedA) or not IsValid(self.WeedB) or _SpliceStartTime == -1 then

				zwf.f.ClientAnim(self, "unload",2)

				timer.Simple(1,function()
					if IsValid(self) then
						zwf.f.ClientAnim(self, "idle", 1)
					end
				end)

				self.IsAnimating = false
			end
		end

		if _SpliceStartTime ~= -1 then
			if self.SoundObj == nil then
				self.SoundObj = CreateSound(self, "zwf_seedlab_scan")
			end

			if self.SoundObj:IsPlaying() == false then
				self.SoundObj:Play()
				self.SoundObj:ChangeVolume(0, 0)
				self.SoundObj:ChangeVolume(zwf.SoundVolume, 0)
			end
		else
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

		self.SpliceData = nil
		self.WeedA = nil
		self.WeedB = nil
		self.IsAnimating = false
		self:RemoveClientModels()
	end
end

function ENT:SpawnClientModel_Jar(pos,amount,WeedID,Num)
	local plantData = zwf.config.Plants[WeedID]

	local ent = ents.CreateClientProp()
	if not IsValid(ent) then return end
	ent:SetModel("models/zerochain/props_weedfarm/zwf_jar.mdl")
	ent:SetPos(self:LocalToWorld(pos))
	ent:SetAngles(self:GetAngles())
	ent:Spawn()
	ent:Activate()
	ent:SetParent(self)
	ent:SetRenderMode(RENDERMODE_TRANSALPHA)

	if amount <= zwf.config.Jar.Capacity / 3 then
		ent:SetBodygroup(1, 1)
	elseif amount <= (zwf.config.Jar.Capacity / 3) * 2 then
		ent:SetBodygroup(1, 1)
		ent:SetBodygroup(2, 1)
	else
		ent:SetBodygroup(1, 1)
		ent:SetBodygroup(2, 1)
		ent:SetBodygroup(3, 1)
	end

	ent:SetSkin(plantData.skin)

	self.ClientProps["Jar" .. Num] = ent
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
		self.SoundObj:ChangeVolume(0, 0)
		self.SoundObj:Stop()
	end
end
