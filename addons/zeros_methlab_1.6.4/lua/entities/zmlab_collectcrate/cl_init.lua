include("shared.lua")

-- Draw
function ENT:Draw()
	self:DrawModel()

	if zmlab.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 200) then
		self:DrawInfo()
	end
end

function ENT:DrawTranslucent()
	self:Draw()
end

-- UI
function ENT:DrawInfo()
	local meth = self:GetMethAmount()
	if meth <= 0 then return end

	local Pos = self:GetPos() + Vector(0, 0, 30)
	local Ang = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)
	local Text = math.Round(meth) .. zmlab.config.UoW
	cam.Start3D2D(Pos, Ang, 0.1)
		draw.DrawText(Text, "zmlab_font4", 0, 5, zmlab.default_colors["white01"], TEXT_ALIGN_CENTER)
	cam.End3D2D()
end

function ENT:Think()
	self:SetNextClientThink(CurTime())
	return true
end
