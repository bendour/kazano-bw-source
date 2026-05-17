ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.Model = "models/zerochain/props_weedfarm/zwf_oven.mdl"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Oven"
ENT.Category = "Zeros GrowOP"
ENT.RenderGroup = RENDERGROUP_OPAQUE


function ENT:SetupDataTables()

    self:NetworkVar("Bool", 0, "IsBaking")

    // 0 = idle, 1 = open , 2 = close
    self:NetworkVar("Int", 0, "WorkState")

    if (SERVER) then
        self:SetIsBaking(false)
        self:SetWorkState(1)
    end
end

function ENT:OnRemoveButton(ply)
    local trace = ply:GetEyeTrace()

    local lp = self:WorldToLocal(trace.HitPos)

    if lp.x > -8.5 and lp.x < 0 and lp.y < 12 and lp.y > 11 and lp.z > 14 and lp.z < 18 then
        return true
    else
        return false
    end
end

function ENT:OnStartButton(ply)
    local trace = ply:GetEyeTrace()

    local lp = self:WorldToLocal(trace.HitPos)

    if lp.x > 2.5 and lp.x < 8 and lp.y < 7 and lp.y > 6 and lp.z > 24.7 and lp.z < 27.2 then
        return true
    else
        return false
    end
end
