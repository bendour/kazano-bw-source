AddCSLuaFile()
DEFINE_BASECLASS("zwf_bong_ent")
ENT.Type = "anim"
ENT.Base = "zwf_bong_ent"
ENT.Model = "models/zerochain/props_weedfarm/zwf_bong03.mdl"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Dark Leaf"
ENT.Category = "Zeros GrowOP"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.BongID = 3

function ENT:SetupDataTables()
    self:NetworkVar("Int", 1, "WeedID")
    self:NetworkVar("String", 0, "Weed_Name")
    self:NetworkVar("Int", 2, "Weed_THC")
    self:NetworkVar("Int", 3, "Weed_Amount")
    self:NetworkVar("Bool", 0, "IsBurning")

    if (SERVER) then
        self:SetWeedID(-1)
        self:SetWeed_Name("NILL")
        self:SetWeed_THC(-1)
        self:SetWeed_Amount(0)
        self:SetIsBurning(false)
    end
end
