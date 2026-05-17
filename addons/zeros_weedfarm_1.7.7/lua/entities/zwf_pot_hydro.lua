AddCSLuaFile()
DEFINE_BASECLASS("zwf_pot")
ENT.Type = "anim"
ENT.Base = "zwf_pot"

ENT.AutomaticFrameAdvance = true
ENT.Model = "models/zerochain/props_weedfarm/zwf_pot02.mdl"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Hydro Flowerpot"
ENT.Category = "Zeros GrowOP"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT



function ENT:SetupDataTables()

    self:NetworkVar("String", 0, "SeedName")

    self:NetworkVar("Int", 0, "Water")
    self:NetworkVar("Int", 1, "NutritionID")
    self:NetworkVar("Int", 2, "Seed")
    self:NetworkVar("Int", 4, "Light")

    self:NetworkVar("Int", 5, "Temperatur")

    self:NetworkVar("Bool", 0, "HasPlague")
    self:NetworkVar("Bool", 1, "HarvestReady")
    self:NetworkVar("Bool", 2, "HasSoil")


    // This counts the progress steps in which the plants was perfectly happy aka Water levels are at perfect balance , it has light and the plants was not overheated
    self:NetworkVar("Int", 6, "PerfectProgress")

    // Tells us how long the plant is allready growing
    // Stores the seconds
    self:NetworkVar("Float", 1, "Progress")

    self:NetworkVar("Float", 0, "YieldAmount")


    self:NetworkVar("Entity", 0, "Output")
    self:NetworkVar("Entity", 1, "WaterSource")

    self:NetworkVar("Int", 7, "Perf_Time")
    self:NetworkVar("Int", 8, "Perf_Amount")
    self:NetworkVar("Int", 9, "Perf_THC")


    if (SERVER) then

        self:SetOutput(NULL)
        self:SetWaterSource(NULL)

        self:SetWater(0)
        self:SetLight(0)
        self:SetNutritionID(-1)
        self:SetSeed(-1)

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
