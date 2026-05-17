ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.Model = "models/zerochain/props_weedfarm/zwf_mixpot.mdl"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.PrintName = "Mixer Bowl"
ENT.Category = "Zeros GrowOP"
ENT.RenderGroup = RENDERGROUP_OPAQUE


function ENT:SetupDataTables()

    self:NetworkVar("Int", 0, "WeedID")
    self:NetworkVar("Float", 0, "WeedAmount")
    self:NetworkVar("Float", 1, "THC")

    if (SERVER) then
        self:SetWeedID(-1)
        self:SetWeedAmount(0)
        self:SetTHC(0)
    end
end
