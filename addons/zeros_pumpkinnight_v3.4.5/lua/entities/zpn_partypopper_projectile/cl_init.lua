/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

include("shared.lua")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d

function ENT:Initialize()
	zclib.Effect.ParticleEffectAttach(zpn.Theme.PartyPopper_Projectile.effect_main, PATTACH_POINT_FOLLOW, self, 0)
end

function ENT:DrawTranslucent()
	self:Draw()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

function ENT:Draw()
	self:DrawModel()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

function ENT:OnRemove()
	self:StopParticles()
	zclib.Effect.ParticleEffect(zpn.Theme.PartyPopper_Projectile.effect_explo, self:GetPos(), self:GetAngles(), Entity(1))
	sound.Play(zpn.Sounds["projectile_explosion"], self:GetPos(), 90, 100, 0.5)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 69811ac079f3e93f705541d1ed39dfac3a9e2460011697a76c02cf9afa26f9c3
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000
