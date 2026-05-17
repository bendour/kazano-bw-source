ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.Model = "models/zerochain/props_weedfarm/zwf_weedseed.mdl"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.PrintName = "Seed"
ENT.Category = "Zeros GrowOP"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "SeedID")

    self:NetworkVar("Int", 1, "Perf_Time")
    self:NetworkVar("Int", 2, "Perf_Amount")
    self:NetworkVar("Int", 3, "Perf_THC")

    self:NetworkVar("Int", 4, "SeedCount")

    self:NetworkVar("String", 0, "SeedName")


    if (SERVER) then
        self:SetSeedID(0)
    end
end
