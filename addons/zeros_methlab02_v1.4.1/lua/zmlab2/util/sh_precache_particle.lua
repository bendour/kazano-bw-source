/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.1 (stable)
*/

game.AddParticles("particles/zmlab2_fx.pcf")
PrecacheParticleSystem("zmlab2_cleaning")
PrecacheParticleSystem("zmlab2_methsludge_fill")
PrecacheParticleSystem("zmlab2_poison_gas")
PrecacheParticleSystem("zmlab2_vent_clean")
PrecacheParticleSystem("zmlab2_vent_poision")
PrecacheParticleSystem("zmlab2_methylamin_fill")
PrecacheParticleSystem("zmlab2_aluminium_fill")
PrecacheParticleSystem("zmlab2_acid_fill")
PrecacheParticleSystem("zmlab2_acid_explo")
PrecacheParticleSystem("zmlab2_aluminium_explo")
PrecacheParticleSystem("zmlab2_methylamine_explo")
PrecacheParticleSystem("zmlab2_lox_explo")
PrecacheParticleSystem("zmlab2_frozen_gas")
PrecacheParticleSystem("zmlab2_purchase")
PrecacheParticleSystem("zmlab2_filter_exhaust")
PrecacheParticleSystem("zmlab2_extinguish")

for k, v in pairs(zmlab2.config.MethTypes) do
    if v.visuals then
        if v.visuals.effect then
            PrecacheParticleSystem(v.visuals.effect)
        end

        if v.visuals.effect_breaking then
            PrecacheParticleSystem(v.visuals.effect_breaking)
        end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e3b23fe5de9dfb761758a006a7271ce1817b0b3d31fddc5f22fc8264734156bf

        if v.visuals.effect_filling then
            PrecacheParticleSystem(v.visuals.effect_filling)
        end

        if v.visuals.effect_exploding then
            PrecacheParticleSystem(v.visuals.effect_exploding)
        end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7e845693ad2a490ead94c2e1f6c2eaff90beaf41e1d134566247921805d9f29b
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e3b23fe5de9dfb761758a006a7271ce1817b0b3d31fddc5f22fc8264734156bf

        if v.visuals.effect_mixer_liquid then
            PrecacheParticleSystem(v.visuals.effect_mixer_liquid)
        end

        if v.visuals.effect_mixer_exhaust then
            PrecacheParticleSystem(v.visuals.effect_mixer_exhaust)
        end
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7e845693ad2a490ead94c2e1f6c2eaff90beaf41e1d134566247921805d9f29b
