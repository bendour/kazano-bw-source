include("shared.lua")

function ENT:Initialize()
	zwf.f.EntList_Add(self)
	self.LastWeedAmount = -1

	self.PlantData = nil

	self.IsInitialized = false

	timer.Simple(0.1,function()
		if IsValid(self) then
			self.IsInitialized = true
		end
	end)
end

function ENT:Draw()
	self:DrawModel()

	if  GetConVar("zwf_cl_vfx_drawui"):GetInt() == 1 and zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 300) and zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 35) == false and self.PlantData ~= nil and self.PlantData ~= -1 then
		self:DrawInfo()
	end
end

function ENT:DrawTranslucent()
	self:Draw()
end


function ENT:DrawInfo()
	cam.Start3D2D(/*self:LocalToWorld(Vector(0, 0, 20))*/ self:GetPos() + Vector(0, 0, 30), Angle(0, EyeAngles().y - 90, -EyeAngles().x + 90), 0.05)

		if zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 150) then
			draw.SimpleText(self:GetWeedName(), zwf.f.GetFont("zwf_jar_font01"), 0, -115, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			draw.RoundedBox(15, -200, -15, 400, 250, zwf.default_colors["black03"])

			surface.SetDrawColor(zwf.default_colors["white01"])
			surface.SetMaterial(zwf.default_materials["icon_mass"])
			surface.DrawTexturedRect(-150, 10, 100, 100)

			surface.SetDrawColor(zwf.default_colors["white01"])
			surface.SetMaterial(zwf.default_materials["icon_thc"])
			surface.DrawTexturedRect(45, 10, 100, 100)

			draw.SimpleText( math.Round(self:GetWeedAmount()) .. zwf.config.UoW, zwf.f.GetFont("zwf_jar_font02"), -100, 135, zwf.default_colors["green06"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			draw.SimpleText(math.Round(self:GetTHC(), 2) .. "%", zwf.f.GetFont("zwf_jar_font02"), 100, 135, zwf.default_colors["green06"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		else
			draw.SimpleText(self:GetWeedName(), zwf.f.GetFont("zwf_jar_font01"), 0, 0, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end

	cam.End3D2D()
end

function ENT:Think()
	if self.IsInitialized == false then return end

	if zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 1000) then

		if self.PlantData == nil or self.PlantData == -1 then
			self.PlantData = zwf.config.Plants[self:GetPlantID()]
		end

		local _weed = self:GetWeedAmount()

		if _weed ~= self.LastWeedAmount then
			self.LastWeedAmount = _weed
			self:SetBodygroup(1, 0)
			self:SetBodygroup(2, 0)
			self:SetBodygroup(3, 0)

			if self.LastWeedAmount <= zwf.config.Jar.Capacity / 3 then
				self:SetBodygroup(1, 1)
			elseif self.LastWeedAmount <= (zwf.config.Jar.Capacity / 3) * 2 then
				self:SetBodygroup(1, 1)
				self:SetBodygroup(2, 1)
			else
				self:SetBodygroup(1, 1)
				self:SetBodygroup(2, 1)
				self:SetBodygroup(3, 1)
			end

			if self.PlantData then
				self:SetSkin(self.PlantData.skin)
			end
		end
	else
		self.LastWeedAmount = -1
		self.PlantData = -1
	end
end
