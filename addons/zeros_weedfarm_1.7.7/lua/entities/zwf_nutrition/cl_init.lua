include("shared.lua")

function ENT:Initialize()

end

function ENT:Draw()
	self:DrawModel()

	if zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 300) then
		self:DrawInfo()
	end
end

function ENT:DrawInfo()

	if self.NutData == nil then
		self.NutData = zwf.config.Nutrition[self:GetNutritionID()]
	else

		cam.Start3D2D(self:LocalToWorld(Vector(0, 0, 25)), Angle(0, EyeAngles().y - 90, -EyeAngles().x + 90), 0.05)

			// Title
			draw.SimpleText(self.NutData.name, zwf.f.GetFont("zwf_seed_font01"), 0, 10, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )

		cam.End3D2D()
	end
end
