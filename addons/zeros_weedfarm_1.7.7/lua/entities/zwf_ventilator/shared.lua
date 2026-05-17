ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.Model = "models/zerochain/props_weedfarm/zwf_ventilator01.mdl"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Ventilator"
ENT.Category = "Zeros GrowOP"
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "Power")
    self:NetworkVar("Bool", 0, "IsRunning")
    self:NetworkVar("Entity", 0, "Output")
    self:NetworkVar("Entity", 1, "PowerSource")
    if (SERVER) then
        self:SetPower(0)
        self:SetIsRunning(false)
        self:SetPowerSource(NULL)
        self:SetOutput(NULL)
    end
end


function ENT:EnableButton(ply)
    local trace = ply:GetEyeTrace()

    local lp = self:WorldToLocal(trace.HitPos)
    if lp.z > 36 and lp.z < 39 and lp.x < 1.2 and lp.x > -1.2 then
        return true
    else
        return false
    end
end
