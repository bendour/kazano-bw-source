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
ENT.PrintName               = "Slapper - Normal"
ENT.Category                = "Zeros PumpkinNight"
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- da71c7e0bf5016ce33a9f318a3747fb53331bb70d9090f016fdcc745ceefa6b8
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a2b46fa362cff6519809e40cc8d153299c414b52d9b8c3759ca38e67d8a7d851

ENT.MakeBounch = true
ENT.SkinValue = 0
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a2b46fa362cff6519809e40cc8d153299c414b52d9b8c3759ca38e67d8a7d851

ENT.OnTrigger = function(ent,ply)
    if CLIENT then
        zclib.Effect.ParticleEffect("zpn_cloud_slapper", ent:GetPos(), ent:GetAngles(), ent)
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- da71c7e0bf5016ce33a9f318a3747fb53331bb70d9090f016fdcc745ceefa6b8
