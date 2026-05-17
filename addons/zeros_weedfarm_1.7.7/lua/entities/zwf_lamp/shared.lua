ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.Model = "models/zerochain/props_weedfarm/zwf_lamp01.mdl"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Lamp"
ENT.Category = "Zeros GrowOP"
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "Power")
    self:NetworkVar("Entity", 0, "Output")
    self:NetworkVar("Entity", 1, "PowerSource")
    self:NetworkVar("Bool", 0, "IsRunning")
    self:NetworkVar("Int", 2, "LampID")

    if (SERVER) then
        self:SetPower(0)
        self:SetIsRunning(false)
        self:SetPowerSource(NULL)
        self:SetLampID(1)
    end
end

function ENT:EnableButton(ply)
    local trace = ply:GetEyeTrace()
    local lp = self:WorldToLocal(trace.HitPos)

    --zwf.f.Debug_Sphere(pos,size,lifetime,color,ignorez)
    if lp.z > -2 and lp.z < 4 and lp.x < 34 and lp.x > 28 then
        return true
    else
        return false
    end
end
