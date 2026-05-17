include("shared.lua")

function ENT:Initialize()
	self.LastSeedID = -1
	self.LastProgress = -1
	self.Pot = nil
	self.Grow_Duration = -1
	self.Grow_Amount = -1

	self.SkankEffect = {
		em = ParticleEmitter(self:GetPos()),
		last_emit = -1
	}

	self.IsInitialized = false

	timer.Simple(0.1,function()
		if IsValid(self) then
			self.IsInitialized = true
		end
	end)
end

function ENT:Draw()
	self:DrawModel()

	zwf.f.UpdateEntityVisuals(self)

	if GetConVar("zwf_cl_vfx_drawui"):GetInt() == 1 and zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 250) and IsValid(self.Pot) then
		self:DrawPlantInfo()
	end
end

function ENT:DrawPlantInfo()
	local harvestReady = self.Pot:GetHarvestReady()
	local hasplague = self.Pot:GetHasPlague()

	if harvestReady or hasplague then

		cam.Start3D2D(self:LocalToWorld(Vector(0, 35, 55)), /* self:LocalToWorldAngles(Angle(0, 180, 90))*/ Angle(0, EyeAngles().y - 90, -EyeAngles().x + 90), 0.05)

		if hasplague then
			draw.SimpleText(">> " .. zwf.language.General["plant_heal"] .. " <<", zwf.f.GetFont("zwf_plant_font01"), 0, 10, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		elseif harvestReady then
			draw.SimpleText(">> " .. zwf.language.General["plant_harvest"] .. " <<", zwf.f.GetFont("zwf_plant_font01"), 0, 10, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			draw.SimpleText("[ " .. math.Round(self.Pot:GetYieldAmount()) .. zwf.config.UoW .. " ]", zwf.f.GetFont("zwf_plant_font02"), 0, 120, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end

		cam.End3D2D()
	end
end

function ENT:DrawTranslucent()
	self:Draw()
end

// Gets called when the entity gets rendered again after certain amount of time
function ENT:UpdateVisuals()

	self:UpdateGrowData()
	self:UpdateBodygroups()
	self:UpdateModelScale()
	self:UpdateSkin()
end

function ENT:UpdateGrowData()

	local growData = zwf.config.Plants[self.LastSeedID]

	if growData == nil then return end

	if not IsValid(self.Pot) then
		self.Pot = self:GetParent()
	end

	if not IsValid(self.Pot) then return end

	local growBoost = self.Pot:GetPerf_Time() - 100
	local grow_Duration = growData.Grow.Duration * (1 - ((1 / 100) * growBoost))
	local grow_Amount = growData.Grow.MaxYieldAmount * ((1 / 100) * self.Pot:GetPerf_Amount())

	self.Grow_Duration = grow_Duration
	self.Grow_Amount = grow_Amount
end

function ENT:UpdateBodygroups()
	if not IsValid(self.Pot) then return end

	local dur = self.Grow_Duration

	local fraction = dur / 6

	if self.LastProgress >= dur then

		// Enables the Weed Buds Bodygroup depending on YieldAmount
		local MaxYieldAmount = self.Grow_Amount
		local CurYieldAmount = self.Pot:GetYieldAmount()

		if CurYieldAmount >= MaxYieldAmount /** 1.5*/ then

			// Bushes
			self:SetBodygroup(5,1)

			self:SetBodygroup(6,1)
			self:SetBodygroup(7,1)
			self:SetBodygroup(8,1)
		elseif CurYieldAmount >= MaxYieldAmount then
			self:SetBodygroup(6,1)
			self:SetBodygroup(7,1)

		elseif CurYieldAmount > 0 then
			self:SetBodygroup(6,1)
		end

		// Disable grow stage
		self:SetBodygroup(0,0)

		// Stem
		self:SetBodygroup(1,1)

		// Leafs small
		self:SetBodygroup(2,1)

		// Leafs big
		self:SetBodygroup(3,1)

		// Leafs inner
		self:SetBodygroup(4,1)

	elseif self.LastProgress > fraction * 5 then

		// Disable grow stage
		self:SetBodygroup(0,0)

		// Stem
		self:SetBodygroup(1,1)

		// Leafs small
		self:SetBodygroup(2,1)

		// Leafs big
		self:SetBodygroup(3,1)

		// Leafs inner
		self:SetBodygroup(4,1)

	elseif self.LastProgress > fraction * 4 then
		self:SetBodygroup(0,5)
	elseif self.LastProgress > fraction * 3 then
		self:SetBodygroup(0,4)
	elseif self.LastProgress > fraction * 2 then
		self:SetBodygroup(0,3)
	elseif self.LastProgress > fraction then

		self:SetBodygroup(0,2)
	elseif self.LastProgress > 0 then

		self:SetBodygroup(0,1)
	end
end

function ENT:UpdateModelScale()
	if not IsValid(self.Pot) then return end
	local weedAmount = self.Pot:GetYieldAmount()
	local extraSize = (0.25 / zwf.config.Growing.max_amount) * weedAmount
	extraSize = math.Clamp(extraSize,0,0.25)

	self:SetModelScale(1 + extraSize)
end

function ENT:UpdateSkin()
	local growData = zwf.config.Plants[self.LastSeedID]

	if growData == nil then return end

	self:SetSkin(growData.skin)
end

function ENT:Think()
	if self.IsInitialized == false then return end

	if zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 1000) then


		if not IsValid(self.Pot) then
			self.Pot = self:GetParent()
		else

			local seedID = self.Pot:GetSeed()
			local _harvestready = self.Pot:GetHarvestReady()

			if self.LastSeedID ~= seedID then
				self.LastSeedID = seedID

				self:UpdateSkin()
			end


			local Progress = self.Pot:GetProgress()
			if self.LastProgress ~= Progress then

				self.LastProgress = Progress
				self:UpdateGrowData()
				self:UpdateBodygroups()
			end

			if CurTime() > 	self.SkankEffect.last_emit and _harvestready then

				if GetConVar("zwf_cl_vfx_skankeffect"):GetInt() == 1 then
					self:SkankEmitter("zerochain/zwf/particle/zwf_glow")
					self:SkankEmitter("zerochain/zwf/particle/zwf_skankcloud")
				end

				// If the plant is harvest ready and we have PostGrow enabled then we increase the Model Scale a bit to visualize the Post Growth
				if zwf.config.Growing.PostGrow.Enabled then
					self:UpdateModelScale()
				end

				self.SkankEffect.last_emit = CurTime() + math.Rand(0.3,0.6)
			end
		end

	else
		self.Grow_Duration = -1
		self.Grow_Amount = -1
		self.LastSeedID = -1
		self.LastProgress = -1

		if self.SkankEffect.em ~= NULL and type(self.SkankEffect.em) == "CLuaEmitter" then
			self.SkankEffect.em:Finish()
			self.SkankEffect.em = NULL
		end
	end
end


function ENT:SkankEmitter(mat)
	if self.SkankEffect.em == NULL or type(self.SkankEffect.em) ~= "CLuaEmitter" then

		self.SkankEffect = {
			em = ParticleEmitter(self:GetPos()),
			last_emit = -1
		}

		return
	end

	local pos = self:GetPos() + self:GetUp() * 35 + self:GetRight() * -15 + self:GetForward() * math.random(-5, 5)
	local vel = Vector(0, 0, math.random(25, 55))
	local icon = self.SkankEffect.em:Add(mat, pos)
	icon:SetVelocity(vel)
	icon:SetDieTime(1)
	icon:SetStartAlpha(200)
	icon:SetEndAlpha(0)
	icon:SetStartSize(15)
	icon:SetEndSize(55)
	local iconColor = zwf.default_colors["white01"]
	iconColor = zwf.config.Plants[self.LastSeedID].color
	icon:SetColor(iconColor.r, iconColor.g, iconColor.b)
	icon:SetGravity(Vector(0, 0, 0))
	icon:SetAirResistance(15)
end

function ENT:OnRemove()
	if self.SkankEffect.em ~= NULL and type(self.SkankEffect.em) == "CLuaEmitter" then
		self.SkankEffect.em:Finish()
		self.SkankEffect.em = NULL
	end
end
