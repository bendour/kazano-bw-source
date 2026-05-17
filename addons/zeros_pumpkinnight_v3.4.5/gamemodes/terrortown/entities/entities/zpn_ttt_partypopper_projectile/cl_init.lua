/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

include("shared.lua")

function ENT:Initialize()
	zclib.Effect.ParticleEffectAttach("zpn_ppp_head", PATTACH_POINT_FOLLOW, self, 0)
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:OnRemove()
	self:StopParticles()
	zclib.Effect.ParticleEffect("zpn_ppp", self:GetPos(), self:GetAngles(), Entity(1))
	sound.Play(zpn.Sounds["projectile_explosion"], self:GetPos(), 90, 100, 0.5)
end
