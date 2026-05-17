/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

include("shared.lua")

function ENT:Initialize()
	zclib.EntityTracker.Add(self)
end

function ENT:DrawTranslucent()
	self:Draw()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d

function ENT:Draw()
	self:DrawModel()

	self.LastDraw = CurTime()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 6af6efba71e4015ff987fc919ecacbe102ec0873079409ab2a0ed0bf25e3f3cd

function ENT:Think()

	if not self.LastDraw or CurTime() > (self.LastDraw + 1) and LocalPlayer():GetPos():Distance(self:GetPos()) > 200 then
		local lookDir = (self:GetPos() - LocalPlayer():GetPos()):Angle()
		lookDir:RotateAroundAxis(lookDir:Up(),90)

		self.LookAngle = Angle(0,lookDir.y,0)
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

	if self.LookAngle then self:SetRenderAngles(self.LookAngle) end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a2b46fa362cff6519809e40cc8d153299c414b52d9b8c3759ca38e67d8a7d851
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 69811ac079f3e93f705541d1ed39dfac3a9e2460011697a76c02cf9afa26f9c3
