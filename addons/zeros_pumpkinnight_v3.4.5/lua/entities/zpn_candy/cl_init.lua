/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

include("shared.lua")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 69811ac079f3e93f705541d1ed39dfac3a9e2460011697a76c02cf9afa26f9c3
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a2b46fa362cff6519809e40cc8d153299c414b52d9b8c3759ca38e67d8a7d851

function ENT:Initialize()
	zclib.EntityTracker.Add(self)

	if zclib.util.RandomChance(50) then
		zclib.Effect.ParticleEffectAttach("zpn_candy01_fx", PATTACH_POINT_FOLLOW, self, 0)
	elseif zclib.util.RandomChance(50) then
		zclib.Effect.ParticleEffectAttach("zpn_candy02_fx", PATTACH_POINT_FOLLOW, self, 0)
	else
		zclib.Effect.ParticleEffectAttach("zpn_candy03_fx", PATTACH_POINT_FOLLOW, self, 0)
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- da71c7e0bf5016ce33a9f318a3747fb53331bb70d9090f016fdcc745ceefa6b8
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Draw()
	self:DrawModel()
	if zclib.util.InDistance(LocalPlayer():GetPos(), self:GetPos(), 500) then
		self:SetRenderAngles(Angle(0,  15 * math.abs(CurTime() * 5), 0))
		if self:GetDisplayCandy() then
			cam.Start3D2D(self:LocalToWorld(Vector(0,0,35 + (1 * math.abs(math.sin(CurTime()) * 5)))), zclib.HUD.GetLookAngles(), 0.1)
				local candy = self:GetCandy()
				surface.SetDrawColor(color_white)
				surface.SetMaterial(zpn.default_materials[zpn.CandyIcon(candy,50)])
				surface.DrawTexturedRect(-100,-100,200,200)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 69811ac079f3e93f705541d1ed39dfac3a9e2460011697a76c02cf9afa26f9c3

				draw.SimpleText("+" .. candy, zclib.GetFont("zpn_candy_shadow"), 0, 110, zpn.default_colors["green01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText("+" .. candy, zclib.GetFont("zpn_candy"), 0, 110, zpn.default_colors["green01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			cam.End3D2D()
		end
	end
end

function ENT:OnRemove()

end
