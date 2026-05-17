/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

include("shared.lua")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

function ENT:Initialize()
	zclib.EntityTracker.Add(self)
	self:SetRenderAngles(self:GetAngles())
	//self:SetRenderOrigin(self:GetPos())
	self.DefaultPos = self:GetPos()

	self.LastChange = 0
	self.NewDir = Vector(0,0,0)

	zclib.Effect.ParticleEffectAttach(zpn.Theme.Minions.effects["zpn_minion"], PATTACH_POINT_FOLLOW, self, 1)
	zclib.Effect.ParticleEffectAttach(zpn.Theme.Minions.effects["zpn_minion_eye"], PATTACH_POINT_FOLLOW, self, 2)
	zclib.Effect.ParticleEffectAttach(zpn.Theme.Minions.effects["zpn_minion_eye"], PATTACH_POINT_FOLLOW, self, 3)
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Draw()
	self:DrawModel()

	if zclib.util.InDistance(LocalPlayer():GetPos(), self:GetPos(), 1000) then


		local target = self:GetPlayerTarget()
		if IsValid(target) then
			self.NewDir = self:GetPos() - (target:GetPos() + Vector(0, 0, 55))
			local newAngle = LerpAngle(FrameTime() * 2, self:GetRenderAngles(), self.NewDir:Angle())
			self:SetRenderAngles(newAngle)
		else
			if CurTime() > self.LastChange then
				self.LastChange = CurTime() + math.Rand(1, 3)
				local rndPos = self:GetPos()
				local randomAngle = math.random(1000)
				local circleRadius = math.random(100, 200)
				rndPos = rndPos + Vector(math.cos(randomAngle) * circleRadius, math.sin(randomAngle) * circleRadius, 200)
				self.NewDir = self:GetPos() - (rndPos + Vector(0, 0, 55))
			end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

			local newAngle = LerpAngle(FrameTime() * 2, self:GetRenderAngles(), self.NewDir:Angle())
			self:SetRenderAngles(Angle(0, newAngle.y, 0))
		end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 6af6efba71e4015ff987fc919ecacbe102ec0873079409ab2a0ed0bf25e3f3cd

		if zpn.config.Boss.Minions.CircleBoss == false then
			local Pos = self.DefaultPos + self:GetUp() * (2 * math.abs(math.sin(CurTime()) * 5))
			self:SetRenderOrigin(Pos)
		end

		if zclib.Convar.Get("zclib_cl_drawui") == 1 then
			self:Draw_HealthBar()
		end
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a2b46fa362cff6519809e40cc8d153299c414b52d9b8c3759ca38e67d8a7d851

function ENT:Draw_HealthBar()
	cam.Start3D2D(self:LocalToWorld(Vector(0,0,50 + (5 * math.abs(math.sin(CurTime()) * 5)))), zclib.HUD.GetLookAngles(), 0.1)

		surface.SetDrawColor(color_white)
		surface.SetMaterial(zpn.Theme.Design.icon_health_bar_bg)
		surface.DrawTexturedRect(-200, 25 ,400, 50)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a2b46fa362cff6519809e40cc8d153299c414b52d9b8c3759ca38e67d8a7d851

		local hbar = (400 / zpn.config.Boss.Minions.Health) * self:GetMonsterHealth()
		draw.RoundedBox(5, -200, 25 ,hbar, 50, zpn.Theme.Design.color_health)

		surface.SetDrawColor(zpn.default_colors["white02"])
		surface.SetMaterial(zpn.Theme.Design.icon_health_bar_alpha)
		surface.DrawTexturedRect(-200, 25 ,400, 50)


	cam.End3D2D()
end
