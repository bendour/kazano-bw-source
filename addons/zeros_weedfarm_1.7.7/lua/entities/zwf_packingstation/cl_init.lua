include("shared.lua")

function ENT:Initialize()
	zwf.f.EntList_Add(self)
	self.LastJarCount = -1
	self.LastStage = -1
end

function ENT:Draw()
	self:DrawModel()

	if GetConVar("zwf_cl_vfx_drawui"):GetInt() == 1 and zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 300) then
		self:DrawInfo()
	end
end

function ENT:DrawInfo()

	local autopacker = self:GetAutoPacker()

	if self.LastStage > 0 then
		if autopacker == false then
			cam.Start3D2D(self:LocalToWorld(self:GetGamePos()), self:LocalToWorldAngles(Angle(180, 90, 180)), 0.05)

				if self:OnHitButton(LocalPlayer()) then
					draw.RoundedBox(5, -46 , -34, 92, 80,  zwf.default_colors["orange01"])
				else
					draw.RoundedBox(5, -46 , -34, 92, 80,  zwf.default_colors["gray02"])
				end
				draw.SimpleText("[E]", zwf.f.GetFont("zwf_packingstation_font01"), 0, 0, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			cam.End3D2D()
		else

			cam.Start3D2D(self:LocalToWorld(Vector(-17, 0, 41)), self:LocalToWorldAngles(Angle(180, 90, 180)), 0.05)
				draw.RoundedBox(5, -300, 80, 600, 40, zwf.default_colors["gray02"])
				local width = (600 / math.Clamp(zwf.config.PackingStation.PackingCount, 7, 99)) * self.LastStage
				draw.RoundedBox(5, -300, 80, width, 40, zwf.default_colors["green04"])
			cam.End3D2D()

		end
	end

	cam.Start3D2D(self:LocalToWorld(Vector(20, 0, 65)), self:LocalToWorldAngles(Angle(180, 90, -90)), 0.05)

		draw.SimpleText(zwf.language.General["packingstation_info"], zwf.f.GetFont("zwf_packingstation_font02"), 0, 100, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

	cam.End3D2D()

	if self.LastJarCount > 0 then
		cam.Start3D2D(self:LocalToWorld(Vector(20, 0, 65)), self:LocalToWorldAngles(Angle(180, 90, -90)), 0.05)
			draw.RoundedBox(5, -300, -10, 600, 15, zwf.default_colors["black03"])
			draw.SimpleText(self:GetWeedName(), zwf.f.GetFont("zwf_packingstation_font01"), 0, 0, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			draw.RoundedBox(5, -300, 70, 600, 15, zwf.default_colors["black03"])

		cam.End3D2D()

		if self.LastStage <= 0 then
			cam.Start3D2D(self:LocalToWorld(Vector(-18, 0, 41)), self:LocalToWorldAngles(Angle(0, -90, 0)), 0.05)

				if self:OnRemoveButton(LocalPlayer()) then
					draw.RoundedBox(5, -200, -10, 400, 100, zwf.default_colors["red05"])
				else
					draw.RoundedBox(5, -200, -10, 400, 100, zwf.default_colors["black03"])
				end
				draw.SimpleText(zwf.language.General["Remove"], zwf.f.GetFont("zwf_packingstation_font01"), 0, 0, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

			cam.End3D2D()
		end
	end
end

function ENT:Think()

	if zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 1000) then
		local _JarCount = self:GetJarCount()
		local _Gamestage = self:GetGameStage()

		if self.LastJarCount ~= _JarCount then
			self.LastJarCount = _JarCount

			self:RemoveClientModels()

			for i = 1, self.LastJarCount do
				self:SpawnClientModel_Jar(i)
			end
		end

		if _Gamestage ~= self.LastStage  then
			self.LastStage = _Gamestage

			if self.LastStage == -1 then
				zwf.f.ClientAnim(self, "idle", 1)
			else
				zwf.f.ClientAnim(self, "packing", 2)

				local effect = zwf.config.Plants[self:GetPlantID()].pack_effect
				local pos = self:GetPos() + self:GetUp() * 50
				zwf.f.ParticleEffect(effect, pos, self:GetAngles(), self)

				zwf.f.EmitSoundENT("zwf_weed_pack", self)
			end

			local MaxStage = math.Clamp(zwf.config.PackingStation.PackingCount,7,99)

			local fraction = MaxStage / 7

			if self.LastStage == -1 then

				self:SetBodygroup(1, 0)

			elseif self.LastStage < fraction then

				self:SetBodygroup(1,1)

			elseif self.LastStage < fraction * 2  then

				self:SetBodygroup(1,2)
				if IsValid(self.ClientProps["Jar" .. 1]) then
					self.ClientProps["Jar" .. 1]:SetNoDraw(true)
				end

			elseif self.LastStage < fraction * 3 then

				self:SetBodygroup(1,3)
				if IsValid(self.ClientProps["Jar" .. 1]) then
					self.ClientProps["Jar" .. 1]:SetNoDraw(true)
				end
				if IsValid(self.ClientProps["Jar" .. 2]) then
					self.ClientProps["Jar" .. 2]:SetNoDraw(true)
				end

			elseif self.LastStage < fraction * 4 then

				self:SetBodygroup(1,4)
				if IsValid(self.ClientProps["Jar" .. 1]) then
					self.ClientProps["Jar" .. 1]:SetNoDraw(true)
				end
				if IsValid(self.ClientProps["Jar" .. 2]) then
					self.ClientProps["Jar" .. 2]:SetNoDraw(true)
				end
				if IsValid(self.ClientProps["Jar" .. 3]) then
					self.ClientProps["Jar" .. 3]:SetNoDraw(true)
				end

			elseif self.LastStage < fraction * 5 then

				self:SetBodygroup(1,5)
				for i = 1, 4 do
					if IsValid(self.ClientProps["Jar" .. i]) then
						self.ClientProps["Jar" .. i]:SetNoDraw(true)
					end
				end

			elseif self.LastStage < fraction * 6 then

				self:SetBodygroup(1,6)
				for i = 1, 4 do
					if IsValid(self.ClientProps["Jar" .. i]) then
						self.ClientProps["Jar" .. i]:SetNoDraw(true)
					end
				end

			elseif self.LastStage >= MaxStage - 1 then

				self:SetBodygroup(1,7)
				for i = 1, 4 do
					if IsValid(self.ClientProps["Jar" .. i]) then
						self.ClientProps["Jar" .. i]:SetNoDraw(true)
					end
				end

			end
		end
	else
		self:RemoveClientModels()
		self.LastJarCount = -1
		self.LastStage = -1
	end

	self:SetNextClientThink(CurTime())
	return true
end

local jarPos = {
	[1] = Vector(19, -15, 40.6),
	[2] = Vector(19, -5, 40.6),
	[3] = Vector(19, 5, 40.6),
	[4] = Vector(19, 15, 40.6)
}

function ENT:SpawnClientModel_Jar(pos)
	local plantData = zwf.config.Plants[self:GetPlantID()]

	if plantData == nil then return end

	local ent = ents.CreateClientProp()
	if not IsValid(ent) then return end

	ent:SetModel("models/zerochain/props_weedfarm/zwf_jar.mdl")
	ent:SetPos(self:LocalToWorld(jarPos[pos]))
	ent:SetAngles(self:GetAngles())
	ent:Spawn()
	ent:Activate()
	ent:SetParent(self)
	ent:SetRenderMode(RENDERMODE_TRANSALPHA)

	ent:SetBodygroup(1, 1)
	ent:SetBodygroup(2, 1)
	ent:SetBodygroup(3, 1)

	ent:SetSkin(plantData.skin)

	self.ClientProps["Jar" .. pos] = ent
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
end
