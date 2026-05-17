include("shared.lua")

function ENT:Initialize()
	zwf.f.EntList_Add(self)
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

	if zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 300) then
		self:DrawInfo()
	end
end

function ENT:DrawTranslucent()
	self:Draw()
end


function ENT:DrawInfo()

	if zwf.config.NPC.SellMode == 2 then

		cam.Start3D2D(self:LocalToWorld(Vector(0, 0, 5.1)), self:LocalToWorldAngles(Angle(0, 90,0)), 0.05)

			if self:CollectButton(LocalPlayer()) then
				draw.RoundedBox(15, -200, -75, 400, 150, zwf.default_colors["orange01"])
			else
				draw.RoundedBox(15, -200, -75, 400, 150, zwf.default_colors["black03"])
			end

			draw.SimpleText(zwf.language.General["Collect"], zwf.f.GetFont("zwf_jar_font01"), 0, -50, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

		cam.End3D2D()
	end

	if self.PlantData ~= nil and self.PlantData ~= -1  then
		cam.Start3D2D(/*self:LocalToWorld(Vector(0, 0, 20))*/  self:GetPos() + Vector(0, 0, 20), Angle(0, EyeAngles().y - 90, -EyeAngles().x + 90), 0.05)

			if zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 150) then
				draw.RoundedBox(15, -200, -15, 400, 240, zwf.default_colors["black03"])
				draw.SimpleText(self:GetWeedName(), zwf.f.GetFont("zwf_jar_font01"), 0, -115, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

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
end

function ENT:Think()
	if self.IsInitialized == nil or self.IsInitialized == false then return end

	if zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 300) then
		if self.PlantData == nil or self.PlantData == -1 then
			self.PlantData = zwf.config.Plants[self:GetWeedID()]
			self:SetSkin(self.PlantData.skin)
		end
	else
		self.PlantData = -1
	end
end
