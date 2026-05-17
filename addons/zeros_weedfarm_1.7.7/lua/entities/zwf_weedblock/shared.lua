ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.Model = "models/zerochain/props_weedfarm/zwf_weedblock.mdl"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "WeedBlock"
ENT.Category = "Zeros GrowOP"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "WeedID")
    self:NetworkVar("Float", 1, "THC")
    self:NetworkVar("String", 0, "WeedName")
    self:NetworkVar("Int", 1, "WeedAmount")


    if (SERVER) then
        self:SetWeedID(1)
        self:SetTHC(100)
        self:SetWeedName("OG Kush")
        self:SetWeedAmount(100)
    end
end

function ENT:CollectButton(ply)
    local trace = ply:GetEyeTrace()
    local lp = self:WorldToLocal(trace.HitPos)

    if lp.z > 5 and lp.z < 6 and lp.x < 4 and lp.x > -4 and lp.y < 9 and lp.y > -9 then
        return true
    else
        return false
    end
end
