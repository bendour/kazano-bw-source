/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.1 (stable)
*/

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Model = "models/zerochain/props_methlab/zmlab2_chest.mdl"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Equipment"
ENT.Category = "Zeros Methlab 2"
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:OnBuild(ply)
    local trace = ply:GetEyeTrace()
    local lp = self:WorldToLocal(trace.HitPos)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 071bfceb8fb4fbc39d3b52c5c3fe7b52159006ab4669d1b75f42deff9fdb1cb2
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

    if lp.x > -10 and lp.x < 10 and lp.y < 15 and lp.y > 13 and lp.z > 44 and lp.z < 51 then
        return true
    else
        return false
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

function ENT:OnMove(ply)
    local trace = ply:GetEyeTrace()
    local lp = self:WorldToLocal(trace.HitPos)

    if lp.x > -10 and lp.x < 10 and lp.y < 15 and lp.y > 13 and lp.z > 37 and lp.z < 44 then
        return true
    else
        return false
    end
end

function ENT:OnRepair(ply)
    local trace = ply:GetEyeTrace()
    local lp = self:WorldToLocal(trace.HitPos)

    if lp.x > -10 and lp.x < 10 and lp.y < 15 and lp.y > 13 and lp.z > 30 and lp.z < 37 then
        return true
    else
        return false
    end
end

function ENT:OnRemoveButton(ply)
    local trace = ply:GetEyeTrace()
    local lp = self:WorldToLocal(trace.HitPos)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 99958388d5b8bc21e4d7af1df39fd75077f0660617b3c526ce40ea9691a5fd3b

    if lp.x > -10 and lp.x < 10 and lp.y < 15 and lp.y > 13 and lp.z > 23 and lp.z < 30 then
        return true
    else
        return false
    end
end

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e3b23fe5de9dfb761758a006a7271ce1817b0b3d31fddc5f22fc8264734156bf

function ENT:CanProperty(ply)
    return zclib.Player.IsAdmin(ply)
end

function ENT:CanTool(ply, tab, str)
    return zclib.Player.IsAdmin(ply)
end

function ENT:CanDrive(ply)
    return zclib.Player.IsAdmin(ply)
end
