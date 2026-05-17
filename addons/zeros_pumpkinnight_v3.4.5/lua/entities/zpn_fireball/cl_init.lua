/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

include("shared.lua")

function ENT:Initialize()
	zclib.Effect.ParticleEffectAttach(zpn.Theme.Projectile.fly_effect, PATTACH_POINT_FOLLOW, self, 0)
	self:EmitSound("zpn_projectile_fly")
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

function ENT:DrawTranslucent()
	self:Draw()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 69811ac079f3e93f705541d1ed39dfac3a9e2460011697a76c02cf9afa26f9c3

function ENT:Draw()
	//self:DrawModel()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

function ENT:OnRemove()
	self:StopParticles()
	zclib.Effect.ParticleEffect(zpn.Theme.Projectile.explo_effect, self:GetPos(), self:GetAngles(), Entity(1))
	sound.Play(zpn.Sounds[zpn.Theme.Projectile.explo_sound], self:GetPos(), 75, 100, 0.5)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- da71c7e0bf5016ce33a9f318a3747fb53331bb70d9090f016fdcc745ceefa6b8
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 69811ac079f3e93f705541d1ed39dfac3a9e2460011697a76c02cf9afa26f9c3
