ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.Model = "models/zerochain/props_weedfarm/zwf_doobytable.mdl"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "DoobyTable"
ENT.Category = "Zeros GrowOP"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "DoobyProgress")

    self:NetworkVar("Int", 1, "WeedID")
    self:NetworkVar("String", 1, "WeedName")
    self:NetworkVar("Float", 0, "WeedAmount")
    self:NetworkVar("Float", 1, "THC")
    self:NetworkVar("Vector", 0, "GamePos")

    if (SERVER) then
        self:SetDoobyProgress(0)
        self:SetWeedName("NIL")
        self:SetWeedID(-1)
        self:SetWeedAmount(0)
        self:SetTHC(0)
        self:SetGamePos(Vector(0,0,0))
    end
end

function ENT:OnRemoveButton(ply)
    local trace = ply:GetEyeTrace()

    local lp = self:WorldToLocal(trace.HitPos)

    if lp.x > -5 and lp.x < -2 and lp.y < 22 and lp.y > 13 and lp.z > 5 and lp.z < 6 then
        return true
    else
        return false
    end
end

function ENT:OnStartButton(ply)
    local trace = ply:GetEyeTrace()

    local lp = self:WorldToLocal(trace.HitPos)

    if lp.x > -8.5 and lp.x < -5 and lp.y < 22 and lp.y > 13 and lp.z > 5 and lp.z < 6 then
        return true
    else
        return false
    end
end

function ENT:OnPaper(ply)
    local trace = ply:GetEyeTrace()

    local lp = self:WorldToLocal(trace.HitPos)

    if lp.x > -2.2 and lp.x < 2.5 and lp.y < 2.8 and lp.y > -2.8 and lp.z > 5 and lp.z < 6 then
        return true
    else
        return false
    end
end

function ENT:OnGrinder(ply)
    local trace = ply:GetEyeTrace()

    local lp = self:WorldToLocal(trace.HitPos)

    if lp.x > -9 and lp.x < -4.9 and lp.y < -14 and lp.y > -20 and lp.z > 5 and lp.z < 6 then
        return true
    else
        return false
    end
end

function ENT:OnHitButton(ply)
    local trace = ply:GetEyeTrace()
    local lp = self:WorldToLocal(trace.HitPos)

    local LGP = self:GetGamePos()


    if lp.x < (LGP.x + 1) and lp.x > (LGP.x - 4) and lp.y < (LGP.y + 3) and lp.y > (LGP.y - 3) then
        return true
    else
        return false
    end
end
