/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.1 (stable)
*/

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Model = "models/zerochain/props_methlab/zmlab2_tent_door.mdl"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.PrintName = "Tent"
ENT.Category = "Zeros Methlab 2"
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:SetupDataTables()

    self:NetworkVar("Bool", 1, "IsLocked")
    self:NetworkVar("Bool", 2, "IsPublic")
    self:NetworkVar("Int", 1, "NextInteraction")
    if (SERVER) then
        self:SetIsLocked(false)
        self:SetIsPublic(false)
        self:SetNextInteraction(-1)
    end
end

function ENT:OnLockButton(ply)
    local trace = ply:GetEyeTrace()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7e845693ad2a490ead94c2e1f6c2eaff90beaf41e1d134566247921805d9f29b

    if trace.Hit and trace.HitPos and IsValid(trace.Entity) and trace.Entity == self and zclib.util.InDistance(self:GetPos(), ply:GetPos(), 100) then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 20505de7028925e794a03b5d1a113ab09db033ae5f8a5a69bfd7d0ab6982aaae

        local lp = self:WorldToLocal(trace.HitPos)
        if lp.x > -5 and lp.x < 5 and lp.y < 11 and lp.y > -11 and lp.z > 20 and lp.z < 40 then
            return true
        else
            return false
        end
    else
        return false
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

function ENT:CanProperty(ply)
    return zclib.Player.IsAdmin(ply)
end

function ENT:CanTool(ply, tab, str)
    return zclib.Player.IsAdmin(ply)
end

function ENT:CanDrive(ply)
    return zclib.Player.IsAdmin(ply)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 20505de7028925e794a03b5d1a113ab09db033ae5f8a5a69bfd7d0ab6982aaae
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7e845693ad2a490ead94c2e1f6c2eaff90beaf41e1d134566247921805d9f29b
