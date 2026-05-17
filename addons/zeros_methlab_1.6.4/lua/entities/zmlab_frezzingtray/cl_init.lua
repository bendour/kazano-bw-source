include("shared.lua")

function ENT:Draw()
	self:DrawModel()

	if zmlab.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 300) and self:GetInBucket() > 0 then
		self:DrawInfo()
	end
end

function ENT:DrawInfo()
	local Pos = self:GetPos() + self:GetUp() * 1
	local Ang = self:GetAngles()
	Ang:RotateAroundAxis(Ang:Forward(), 90)
	Ang:RotateAroundAxis(Ang:Forward(), -90)

	cam.Start3D2D(Pos, Ang, 0.1)
		local text = math.Round(self:GetInBucket()) .. zmlab.config.UoW

		draw.DrawText(text, "zmlab_font4", 0, -50, zmlab.default_colors["white01"], TEXT_ALIGN_CENTER)
	cam.End3D2D()
end

function ENT:DrawTranslucent()
	self:Draw()
end
