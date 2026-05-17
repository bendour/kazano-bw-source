ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.Model = "models/zerochain/props_weedfarm/zwf_outlets.mdl"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Outlet"
ENT.Category = "Zeros GrowOP"
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "Power")
    self:NetworkVar("Entity", 0, "PowerSource")
    self:NetworkVar("Entity", 1, "Output01")
    self:NetworkVar("Entity", 2, "Output02")
    self:NetworkVar("Entity", 3, "Output03")

    if (SERVER) then
        self:SetPower(0)
        self:SetPowerSource(NULL)
        self:SetOutput01(NULL)
        self:SetOutput02(NULL)
        self:SetOutput03(NULL)
    end
end
