/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.Model = "models/zerochain/props_pumpkinnight/zpn_ghost.mdl"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Ghost"
ENT.Category = "Zeros PumpkinNight"
ENT.RenderGroup = RENDERGROUP_OPAQUE
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 69811ac079f3e93f705541d1ed39dfac3a9e2460011697a76c02cf9afa26f9c3

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "MonsterHealth")
    self:NetworkVar("Int", 1, "Candy")
    self:NetworkVar("Int", 2, "ActionState")
    self:NetworkVar("Vector", 0, "TargetPos")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 6af6efba71e4015ff987fc919ecacbe102ec0873079409ab2a0ed0bf25e3f3cd
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

    if SERVER then
        self:SetCandy(0)
        self:SetActionState(0)
        self:SetTargetPos(Vector(0, 0, 0))
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000
