ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.Model = "models/zerochain/props_weedfarm/zwf_generator.mdl"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Generator"
ENT.Category = "Zeros GrowOP"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "Fuel")
    self:NetworkVar("Int", 2, "AnimState")
    self:NetworkVar("Bool", 1, "IsRefilling")
    self:NetworkVar("Entity", 0, "Output")
    self:NetworkVar("Int", 1, "Power")
    self:NetworkVar("Float", 2, "Maintance")

    if (SERVER) then
        self:SetIsRefilling(false)
        self:SetFuel(0)
        self:SetPower(0)
        self:SetAnimState(0)
        self:SetMaintance(0)
    end
end

function ENT:EnableButton(ply)
    local trace = ply:GetEyeTrace()

    local lp = self:WorldToLocal(trace.HitPos)

    if lp.z > 5 and lp.z < 13 and lp.y < 10 and lp.y > 2 then
        return true
    else
        return false
    end
end

function ENT:MaintanceButton(ply)
    local trace = ply:GetEyeTrace()

    local lp = self:WorldToLocal(trace.HitPos)

    if lp.z > 17 and lp.z < 29 and lp.y < 18 and lp.y > 16 and lp.x < 18 and lp.x > -18  then
        return true
    else
        return false
    end
end
