ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.Model = "models/zerochain/props_weedfarm/zwf_seedlab.mdl"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Seed Lab"
ENT.Category = "Zeros GrowOP"
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "WeedA")
    self:NetworkVar("Entity", 1, "WeedB")

    self:NetworkVar("Int", 0, "SpliceStartTime")
    self:NetworkVar("String", 0, "SeedName")

    if (SERVER) then
        self:SetWeedA(NULL)
        self:SetWeedB(NULL)

        self:SetSpliceStartTime(-1)
        self:SetSeedName("nil")
    end
end

function ENT:Remove_WeedB(ply)
    local trace = ply:GetEyeTrace()
    local lp = self:WorldToLocal(trace.HitPos)

    if lp.y > 0.6 and lp.y < 12.3 and lp.x < 2 and lp.x > 1 and lp.z < 65.9 and lp.z > 63 then

        return true
    else
        return false
    end
end

function ENT:Remove_WeedA(ply)
    local trace = ply:GetEyeTrace()
    local lp = self:WorldToLocal(trace.HitPos)

    if lp.y > -12.5 and lp.y < -0.3 and lp.x < 2 and lp.x > 1 and lp.z < 65.9 and lp.z > 63 then
        return true
    else
        return false
    end
end


function ENT:SpliceWeed(ply)
    local trace = ply:GetEyeTrace()
    local lp = self:WorldToLocal(trace.HitPos)

    if lp.y > -12.5 and lp.y < 12.5  and lp.x < 2 and lp.x > 1 and lp.z < 62.6 and lp.z > 60 then
        return true
    else
        return false
    end
end
