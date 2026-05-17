ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.Model = "models/zerochain/props_weedfarm/zwf_watertank.mdl"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Water Tank"
ENT.Category = "Zeros GrowOP"
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "Water")
    self:NetworkVar("Entity", 0, "Output")
    if (SERVER) then
        self:SetWater(zwf.config.WaterTank.Capacity)
        self:SetOutput(NULL)
    end
end


function ENT:RefillButton(ply)
    local trace = ply:GetEyeTrace()
    local lp = self:WorldToLocal(trace.HitPos)

    if lp.z > 37 and lp.z < 42 and lp.x < 10 and lp.x > -10 and lp.y < 33 and lp.y > 31 then
        return true
    else
        return false
    end
end
