/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.1 (stable)
*/

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Model = "models/zerochain/props_methlab/zmlab2_table.mdl"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Table"
ENT.Category = "Zeros Methlab 2"
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:SetupDataTables()
    self:NetworkVar("Int", 1, "ProcessState")
    self:NetworkVar("Entity", 1, "Crate")
    self:NetworkVar("Entity", 2, "Tray")
    self:NetworkVar("Bool", 1, "IsAutobreaking")

    if (SERVER) then
        self:SetIsAutobreaking(false)
        self:SetProcessState(0)
        self:SetCrate(NULL)
        self:SetTray(NULL)
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 071bfceb8fb4fbc39d3b52c5c3fe7b52159006ab4669d1b75f42deff9fdb1cb2

function ENT:OnDrop_Crate(ply)
    local trace = ply:GetEyeTrace()
    local lp = self:WorldToLocal(trace.HitPos)
    if lp.x > 5 and lp.x < 19 and lp.y < 13 and lp.y > 6 and lp.z > 35 and lp.z < 38 then
        return true
    else
        return false
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 99958388d5b8bc21e4d7af1df39fd75077f0660617b3c526ce40ea9691a5fd3b

function ENT:OnDrop_Tray(ply)
    local trace = ply:GetEyeTrace()
    local lp = self:WorldToLocal(trace.HitPos)
    if lp.x > -19 and lp.x < -6 and lp.y < 13 and lp.y > 6 and lp.z > 35 and lp.z < 38 then
        return true
    else
        return false
    end
end

function ENT:CanProperty(ply)
    return zclib.Player.IsAdmin(ply)
end

function ENT:CanTool(ply, tab, str)
    return zclib.Player.IsAdmin(ply)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7e845693ad2a490ead94c2e1f6c2eaff90beaf41e1d134566247921805d9f29b

function ENT:CanDrive(ply)
    return zclib.Player.IsAdmin(ply)
end
