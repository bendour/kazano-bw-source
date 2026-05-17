/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.1 (stable)
*/

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Model = "models/zerochain/props_methlab/zmlab2_tentkit.mdl"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Tent"
ENT.Category = "Zeros Methlab 2"
ENT.RenderGroup = RENDERGROUP_OPAQUE
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

function ENT:SetupDataTables()

    self:NetworkVar("Int", 1, "BuildState")
    self:NetworkVar("Int", 2, "BuildCompletion")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

    self:NetworkVar("Int", 3, "TentID")

    self:NetworkVar("Int", 4, "ColorID")

    self:NetworkVar("Bool", 1, "IsPublic")

    self:NetworkVar("Int", 5, "LastExtinguish")


    if (SERVER) then
        self:SetTentID(-1)
        self:SetColorID(1)
		// 280770769
        // Unfolded
        self:SetBuildState(-1)
        self:SetBuildCompletion(-1)

        self:SetIsPublic(false)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e3b23fe5de9dfb761758a006a7271ce1817b0b3d31fddc5f22fc8264734156bf

        self:SetLastExtinguish(0)
    end
end

function ENT:OnControllPanel(ply)
    if self:GetAttachment(1) == nil then return false end
    local trace = ply:GetEyeTrace()

    if trace.HitPos:Distance(self:GetAttachment(1).Pos) < 5 then
        return true
    else
        return false
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 071bfceb8fb4fbc39d3b52c5c3fe7b52159006ab4669d1b75f42deff9fdb1cb2
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

function ENT:OnLightButton(ply)
    if self:GetAttachment(1) == nil then return false end
    local attach = self:GetAttachment(1)
    local trace = ply:GetEyeTrace()
    if zclib.util.InDistance(attach.Pos - attach.Ang:Forward() * 5, trace.HitPos, 2) then
        return true
    else
        return false
    end
end

function ENT:OnExtinquisher(ply)
    if self:GetAttachment(1) == nil then return false end
    local attach = self:GetAttachment(1)
    local trace = ply:GetEyeTrace()
    if zclib.util.InDistance(attach.Pos, trace.HitPos, 2) then
        return true
    else
        return false
    end
end

function ENT:OnFoldButton(ply)
    if self:GetAttachment(1) == nil then return false end
    local attach = self:GetAttachment(1)
    local trace = ply:GetEyeTrace()

    //debugoverlay.Sphere(attach.Pos - attach.Ang:Forward() * 5,2,0.1,Color( 255, 255, 255 ),true)

    if zclib.util.InDistance(attach.Pos + attach.Ang:Forward() * 5, trace.HitPos, 2) then
        return true
    else
        return false
    end
end

function ENT:CanProperty(ply)
    return zclib.Player.IsAdmin(ply)
end

function ENT:CanTool(ply, tab, str)
    return str == "colour" or zclib.Player.IsAdmin(ply)
end

function ENT:CanDrive(ply)
    return zclib.Player.IsAdmin(ply)
end
