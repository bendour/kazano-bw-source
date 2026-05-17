/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

AddCSLuaFile()
DEFINE_BASECLASS("zpn_slapper_base")
ENT.Type                    = "anim"
ENT.Base                    = "zpn_slapper_base"
ENT.Model                   = "models/zerochain/props_pumpkinnight/zpn_slapper.mdl"
ENT.Spawnable               = true
ENT.AdminSpawnable          = false
ENT.PrintName               = "Slapper - Fire"
ENT.Category                = "Zeros PumpkinNight"
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

ENT.OnTrigger = function(ent,ply)
    if SERVER then
        local firearea = ents.Create("zpn_firearea")
        firearea:SetPos(ent:GetPos())
        firearea:Spawn()
        firearea:Activate()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 69811ac079f3e93f705541d1ed39dfac3a9e2460011697a76c02cf9afa26f9c3
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a2b46fa362cff6519809e40cc8d153299c414b52d9b8c3759ca38e67d8a7d851
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 69811ac079f3e93f705541d1ed39dfac3a9e2460011697a76c02cf9afa26f9c3

        ply:Ignite(1.5,1)
    else
        zclib.Effect.ParticleEffect("zpn_fireexplosion", ent:GetPos(), ent:GetAngles(), ent)
    end
end
ENT.SkinValue = 2
ENT.MakeBounch = true
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d
