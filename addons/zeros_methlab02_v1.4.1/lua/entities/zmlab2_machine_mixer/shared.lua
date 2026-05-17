/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.1 (stable)
*/

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Model = "models/zerochain/props_methlab/zmlab2_mixer.mdl"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Mixer"
ENT.Category = "Zeros Methlab 2"
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:SetupDataTables()
    self:NetworkVar("Int", 1, "ProcessState")
    /*
        0 = Needs Barrel
        1 = Needs Acid
        2 = Press the Start Mix Button
        3 = Add Aluminium
        4 = Press the Start Mix Button
        5 = Add Exhaust pipe
        6 = Moving Acid (Loading)
        7 = Needs to be cleaned
    */

    self:NetworkVar("Int", 2, "MethQuality")
    self:NetworkVar("Int", 3, "NeedAmount")

    self:NetworkVar("Int", 5, "ErrorStart")
    self:NetworkVar("Int", 6, "ProcessStart")

    self:NetworkVar("Int", 7, "MethType")

    if (SERVER) then
        self:SetProcessState(-1)

        self:SetMethQuality(0)
        self:SetNeedAmount(0)

        self:SetErrorStart(-1)
        self:SetProcessStart(-1)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 20505de7028925e794a03b5d1a113ab09db033ae5f8a5a69bfd7d0ab6982aaae

        self:SetMethType(1)
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e3b23fe5de9dfb761758a006a7271ce1817b0b3d31fddc5f22fc8264734156bf

function ENT:OnStart(ply)
    local trace = ply:GetEyeTrace()
    local lp = self:WorldToLocal(trace.HitPos)
    if lp.x > -10 and lp.x < 0 and lp.y < 15 and lp.y > 10 and lp.z > 27 and lp.z < 31 then
        return true
    else
        return false
    end
end

function ENT:OnMethType(ply)
    local trace = ply:GetEyeTrace()
    local lp = self:WorldToLocal(trace.HitPos)
    if lp.x > -10 and lp.x < 0 and lp.y < 15 and lp.y > 10 and lp.z > 32 and lp.z < 37 then
        return true
    else
        return false
    end
end

function ENT:OnErrorButton(ply)
    local trace = ply:GetEyeTrace()
    local lp = self:WorldToLocal(trace.HitPos)
    if lp.x > -10 and lp.x < 0 and lp.y < 15 and lp.y > 10 and lp.z > 28 and lp.z < 33.6 then
        return true
    else
        return false
    end
end

function ENT:OnCenterButton(ply)
    local trace = ply:GetEyeTrace()
    local lp = self:WorldToLocal(trace.HitPos)

    if lp.x > -10 and lp.x < 0 and lp.y < 15 and lp.y > 10 and lp.z > 25 and lp.z < 38 then
        return true
    else
        return false
    end
end




// Tell us if you allow to receive liquid
function ENT:AllowConnection(From_ent)
    if From_ent:GetClass() == "zmlab2_machine_furnace" and From_ent:GetProcessState() == 4 and self:GetProcessState() == 1 then
        return true
    else
        return false
    end
end

// Returns the start position and direction for a hose
function ENT:GetHose_In()
    local attach = self:GetAttachment(1)
    if attach == nil then return self:GetPos(),self:GetAngles() end
    local ang = attach.Ang
    ang:RotateAroundAxis(ang:Right(),180)

    return attach.Pos,ang
end


// Returns the start position and direction for a hose
function ENT:GetHose_Out()
    local attach = self:GetAttachment(2)
    if attach == nil then return self:GetPos(),self:GetAngles() end
    return attach.Pos,attach.Ang
end


                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

function ENT:CanProperty(ply)
    return zclib.Player.IsAdmin(ply)
end

function ENT:CanTool(ply, tab, str)
    return zclib.Player.IsAdmin(ply)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 071bfceb8fb4fbc39d3b52c5c3fe7b52159006ab4669d1b75f42deff9fdb1cb2

function ENT:CanDrive(ply)
    return zclib.Player.IsAdmin(ply)
end
