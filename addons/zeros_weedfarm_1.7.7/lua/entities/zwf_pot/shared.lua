ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.Model = "models/zerochain/props_weedfarm/zwf_pot01.mdl"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Flowerpot"
ENT.Category = "Zeros GrowOP"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:SetupDataTables()

    self:NetworkVar("String", 0, "SeedName")

    self:NetworkVar("Int", 0, "Water")
    self:NetworkVar("Int", 1, "NutritionID")
    self:NetworkVar("Int", 2, "Seed")
    self:NetworkVar("Int", 4, "Light")

    self:NetworkVar("Int", 5, "Temperatur")

    // This counts the progress steps in which the plants was perfectly happy aka Water levels are at perfect balance , it has light and the plants was not overheated and no plague
    self:NetworkVar("Int", 6, "PerfectProgress")

    self:NetworkVar("Bool", 0, "HasPlague")
    self:NetworkVar("Bool", 1, "HarvestReady")
    self:NetworkVar("Bool", 2, "HasSoil")

    // Tells us how long the plant is allready growing
    // Stores the seconds
    self:NetworkVar("Float", 1, "Progress")

    self:NetworkVar("Float", 0, "YieldAmount")


    self:NetworkVar("Int", 7, "Perf_Time")
    self:NetworkVar("Int", 8, "Perf_Amount")
    self:NetworkVar("Int", 9, "Perf_THC")


    if (SERVER) then
        self:SetWater(0)
        self:SetLight(0)
        self:SetNutritionID(-1)
        self:SetSeed(-1)

        self:SetPerfectProgress(0)

        self:SetTemperatur(0)
        self:SetHasSoil(false)
        self:SetHasPlague(false)
        self:SetHarvestReady(false)

        self:SetProgress(0)

        self:SetYieldAmount(0)

        self:SetPerf_Time(100)
        self:SetPerf_Amount(100)
        self:SetPerf_THC(100)
    end
end
