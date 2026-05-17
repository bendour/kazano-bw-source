/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.Model = "models/zerochain/props_pumpkinnight/zpn_pumpkinboss.mdl"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Boss"
ENT.Category = "Zeros PumpkinNight"
ENT.RenderGroup = RENDERGROUP_BOTH
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d

function ENT:SetupDataTables()
    self:NetworkVar( "Int", 0, "MonsterHealth" )
    self:NetworkVar( "Int", 1, "ActionState" )
    self:NetworkVar( "Int", 2, "Shield" )
    self:NetworkVar( "Vector", 0, "TargetPos" )

    if SERVER then
        self:SetActionState(-1)
        self:SetTargetPos(Vector(0,0,0))
        self:SetShield(0)
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- da71c7e0bf5016ce33a9f318a3747fb53331bb70d9090f016fdcc745ceefa6b8
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 6af6efba71e4015ff987fc919ecacbe102ec0873079409ab2a0ed0bf25e3f3cd
