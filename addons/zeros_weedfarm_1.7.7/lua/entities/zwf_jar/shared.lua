ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.Model = "models/zerochain/props_weedfarm/zwf_jar.mdl"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Jar"
ENT.Category = "Zeros GrowOP"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "PlantID")
    self:NetworkVar("Float", 0, "WeedAmount")
    self:NetworkVar("Float", 1, "THC")

    self:NetworkVar("Int", 1, "Perf_Time")
    self:NetworkVar("Int", 2, "Perf_Amount")
    self:NetworkVar("Int", 3, "Perf_THC")

    self:NetworkVar("String", 0, "WeedName")


    if (SERVER) then
        self:SetWeedAmount(200)
        self:SetPlantID(7)
        self:SetTHC(25)

        self:SetPerf_Time(125)
        self:SetPerf_Amount(115)
        self:SetPerf_THC(102)

        self:SetWeedName("OG Kush")
    end
end
