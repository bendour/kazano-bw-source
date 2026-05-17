ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.Model = "models/zerochain/props_weedfarm/zwf_packingstation.mdl"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Packing Station"
ENT.Category = "Zeros GrowOP"
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "PlantID")
    self:NetworkVar("String", 0, "WeedName")

    self:NetworkVar("Int", 1, "JarCount")
    self:NetworkVar("Vector", 0, "GamePos")
    self:NetworkVar("Int", 2, "GameStage")

    self:NetworkVar("Bool", 0, "AutoPacker")

    if (SERVER) then
        self:SetPlantID(-1)
        self:SetJarCount(0)
        self:SetGamePos(Vector(0,0,0))
        self:SetGameStage(-1)
        self:SetAutoPacker(false)
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


function ENT:OnRemoveButton(ply)
    local trace = ply:GetEyeTrace()
    local lp = self:WorldToLocal(trace.HitPos)

    if lp.y > -9.5 and lp.y < 9.5 and lp.x < -18.3 and lp.x > -24 and lp.z < 42 and lp.z > 41 then
        return true
    else
        return false
    end
end
