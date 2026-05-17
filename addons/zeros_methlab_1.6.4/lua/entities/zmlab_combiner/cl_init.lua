include("shared.lua")

function ENT:Initialize()

	self.LastStage = 1
	self.HasFilter = false
	self.HasTray = false

	self.LastMethSludge = 0

	self.stageinfo = {
		[1] = zmlab.language.combiner_step01,
		[2] = zmlab.language.combiner_step02,
		[3] = zmlab.language.combiner_step03,
		[4] = zmlab.language.combiner_step04,
		[5] = zmlab.language.combiner_step05,
		[6] = zmlab.language.combiner_step06,
		[7] = zmlab.language.combiner_step07,
		[8] = zmlab.language.combiner_step08
	}
end

// Draw
function ENT:Draw()
	self:DrawModel()

	if zmlab.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 500) then
		self:DrawInfo()
	end
end

function ENT:DrawTranslucent()
	self:Draw()
end

// UI
function ENT:DrawInfo()

	cam.Start3D2D(self:LocalToWorld(Vector(0,64.1,59.2)), self:LocalToWorldAngles(Angle(180,0,-75)), 0.05)
		// BG
		draw.RoundedBox(3, -380, -200, 760, 400, zmlab.default_colors["black01"])
		draw.RoundedBox(0, -380, -100, 760, 5, zmlab.default_colors["grey01"])
		draw.RoundedBox(0, -380, 13, 760, 5, zmlab.default_colors["grey01"])

		// NextStep Text
		draw.DrawText(zmlab.language.combiner_nextstep, "zmlab_nextstep", -350, -90, zmlab.default_colors["white01"], TEXT_ALIGN_LEFT)

		if self.LastStage and self.stageinfo[self.LastStage] then
			draw.DrawText(self.stageinfo[self.LastStage], "zmlab_font_info", -80, -88, zmlab.default_colors["yellow01"], TEXT_ALIGN_LEFT)
		end

		if self.LastStage == 3 then
			draw.DrawText(zmlab.language.aluminium .. ": " .. self:GetNeedAluminium() .. " (" .. self:GetAluminium() .. ")", "zmlab_font1", -350, -170, zmlab.default_colors["white01"], TEXT_ALIGN_LEFT)
		end

		if self.LastStage == 1 then
			draw.DrawText(zmlab.language.methylamin .. ": " .. self:GetNeedMethylamin() .. " (" .. self:GetMethylamin() .. ")", "zmlab_font1", -350, -170, zmlab.default_colors["white01"], TEXT_ALIGN_LEFT)
		end

		// Filter
		if self.HasFilter then
			draw.DrawText(zmlab.language.combiner_filter, "zmlab_font2", 340, -160, zmlab.default_colors["green01"], TEXT_ALIGN_RIGHT)
		else
			if self.LastStage == 5 then
				local glow = math.abs(math.sin(CurTime() * 6) * 255) // Math stuff for flashing.
				local warncolor = Color(glow, 0, 0) // This flashes red.
				draw.DrawText(zmlab.language.combiner_danger, "zmlab_font3", 350, -175, warncolor, TEXT_ALIGN_RIGHT)
			end
		end


		local MaxTime = self:GetMaxProcessingTime()
		local StartTime = self:GetStartProcessingTime()
		local EndTime = (StartTime + MaxTime) -  CurTime()
		EndTime = MaxTime - EndTime

		local methSludge = self:GetMethSludge()
		local cleanProcess = self:GetCleaningProgress()

		// Processing Bar
		if (StartTime > 0) then
			draw.RoundedBox(12, -349, 55, 695 , 100, zmlab.default_colors["black02"])
			draw.RoundedBox(12, -349, 55, math.Clamp((695 / MaxTime) * EndTime,0,695), 100, zmlab.default_colors["green02"])
			draw.DrawText(zmlab.language.combiner_processing, "zmlab_font_processing", 0, 76, zmlab.default_colors["white01"], TEXT_ALIGN_CENTER)
		end

		// Methsludge Amount
		if (methSludge > 0) then
			draw.RoundedBox(12, -349, 55, 695 , 100, zmlab.default_colors["black02"])
			draw.RoundedBox(12, -349, 55, (695 / self:GetMaxMethSludge()) * methSludge, 100, zmlab.default_colors["methsludge"])
			draw.DrawText(zmlab.language.combiner_methsludge .. math.Round(methSludge), "zmlab_font_processing", 0, 76, zmlab.default_colors["white01"], TEXT_ALIGN_CENTER)
		end

		// Cleaning Process
		if (cleanProcess > 0) then
			local progress = (1 / zmlab.config.Combiner.DirtAmount) * cleanProcess
			local progressColor = zmlab.f.LerpColor(progress, zmlab.default_colors["dirt01"], zmlab.default_colors["dirt02"])

			draw.RoundedBox(12, -349, 55, 695 , 100, zmlab.default_colors["black02"])
			draw.RoundedBox(12, -349, 55, (695 / zmlab.config.Combiner.DirtAmount) * cleanProcess, 100, progressColor)
		end
	cam.End3D2D()
end


function ENT:CreateFilterEffects()
	if self:GetModel() == nil then return end
	if GetConVar("zmlab_cl_vfx_particleeffects"):GetInt() ~= 1 then return end

	self:StopParticles()

	if self.LastStage == 5 then
		if self.HasFilter then
			ParticleEffectAttach("zmlab_cleand_gas", PATTACH_POINT_FOLLOW, self, 7)
		else
			ParticleEffectAttach("zmlab_poison_gas", PATTACH_POINT_FOLLOW, self, 7)
		end
	else
		self:StopParticles()
	end
end

function ENT:Think()
	if zmlab.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 600) then

		zmlab.f.LoopedSound(self, "Combiner_poision", self.LastStage == 5 and self.HasFilter == false)
		zmlab.f.LoopedSound(self, "Combiner_filtering", self.LastStage == 5 and self.HasFilter == true)
		zmlab.f.LoopedSound(self, "progress_cooking", self.LastStage == 2 or self.LastStage == 4 or self.LastStage == 6)


		// PumpSound and Effects
		self:OutputVFX()

		if self.ClientProps then

			if not IsValid(self.ClientProps["MethSludge"]) then
				self:SpawnClientModel_MethSludge()
			else


				local hasFilter = self:GetHasFilter()
				local hasTray = self:GetHasTray()
				local currentStage = self:GetStage()

				if self.LastStage ~= currentStage or hasFilter ~= self.HasFilter or hasTray ~= self.HasTray then

					self.LastStage = currentStage
					self.HasFilter = hasFilter
					self.HasTray = hasTray

					self:CreateFilterEffects()

					self.ClientProps["MethSludge"]:SetNoDraw(false)

					if self.LastStage == 1 then

						self.ClientProps["MethSludge"]:SetNoDraw(true)
						zmlab.f.ClientAnim(self.ClientProps["MethSludge"], "idle", 1)
						zmlab.f.ClientAnim(self, "mode_idle", 1)

					elseif self.LastStage == 2 then

						zmlab.f.ClientAnim(self.ClientProps["MethSludge"], "half", 1)
						zmlab.f.ClientAnim(self, "mode_mix", 1)

					elseif self.LastStage == 3 then

						zmlab.f.ClientAnim(self, "mode_idle", 1)
						self:EmitSound("progress_done")

					elseif self.LastStage == 4 then

						zmlab.f.ClientAnim(self.ClientProps["MethSludge"], "full", 1)
						zmlab.f.ClientAnim(self, "mode_mix", 1)

					elseif self.LastStage == 5 then

						zmlab.f.ClientAnim(self, "mode_mix", 1)
						zmlab.f.ClientAnim(self.ClientProps["MethSludge"], "full", 1)

					elseif self.LastStage == 6 then

						zmlab.f.ClientAnim(self, "mode_mix", 1)
						zmlab.f.ClientAnim(self.ClientProps["MethSludge"], "full", 1)

					elseif self.LastStage == 7 then

						if self.HasTray then
							zmlab.f.ClientAnim(self, "mode_pump", 1)
						else
							zmlab.f.ClientAnim(self, "mode_idle", 1)
						end

						zmlab.f.ClientAnim(self.ClientProps["MethSludge"], "full", 1)

					elseif self.LastStage == 8 then

						zmlab.f.ClientAnim(self, "mode_idle", 1)
						self.ClientProps["MethSludge"]:SetNoDraw(true)
						zmlab.f.ClientAnim(self.ClientProps["MethSludge"], "idle", 1)
					end
				end
			end
		else
			self.ClientProps = {}
		end

	else
		self.LastStage = -1
		self.HasFilter = -1
		self.HasTray = -1

		self:StopSound("progress_cooking")
		self:StopSound("progress_done")

		self:RemoveClientModels()

		self:StopParticles()
	end

	self:SetNextClientThink(CurTime())

	return true
end


function ENT:OutputVFX()
	local currentMeth = self:GetMethSludge()

	if self.LastMethSludge ~= currentMeth and self.HasTray then

		self:EmitSound("MethylaminSludge_pump")

		local attach = self:LookupAttachment("effect0" .. math.random(1, 5))
		local attachData = self:GetAttachment(attach)
		if GetConVar("zmlab_cl_vfx_particleeffects"):GetInt() == 1 then
			ParticleEffect("zmlab_methsludge_fill", attachData.Pos, attachData.Ang, self)
		end
		self.LastMethSludge = currentMeth
	end
end


// Client Model
function ENT:SpawnClientModel_MethSludge()
	local ent = ents.CreateClientProp()
	if not IsValid(ent) then return end

	ent:SetPos(self:GetPos() + self:GetUp() * 20)
	ent:SetModel("models/zerochain/zmlab/zmlab_sludge.mdl")
	ent:SetAngles(self:GetAngles())
	ent:Spawn()
	ent:Activate()
	ent:SetParent(self)
	ent:SetNoDraw(true)
	self.ClientProps["MethSludge"] = ent
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
	self.RollCount = 0
end

function ENT:OnRemove()
	self:StopSound("progress_cooking")
	self:StopSound("progress_done")
	self:StopSound("Combiner_filtering")

	self:RemoveClientModels()

	if self.Sounds == nil then return end

	for k, v in pairs(self.Sounds) do
		if v and v:IsPlaying() then
			v:Stop()
		end
	end
end
