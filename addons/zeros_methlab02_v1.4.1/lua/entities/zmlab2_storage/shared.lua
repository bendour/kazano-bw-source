/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.1 (stable)
*/

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Model = "models/zerochain/props_methlab/zmlab2_storage.mdl"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Storage"
ENT.Category = "Zeros Methlab 2"
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:SetupDataTables()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

    self:NetworkVar("Int", 1, "NextPurchase")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 99958388d5b8bc21e4d7af1df39fd75077f0660617b3c526ce40ea9691a5fd3b

    if (SERVER) then
        self:SetNextPurchase(0)
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 99958388d5b8bc21e4d7af1df39fd75077f0660617b3c526ce40ea9691a5fd3b

function ENT:CanProperty(ply)
    return zclib.Player.IsAdmin(ply)
end

function ENT:CanTool(ply, tab, str)
    return zclib.Player.IsAdmin(ply)
end

function ENT:CanDrive(ply)
    return zclib.Player.IsAdmin(ply)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7e845693ad2a490ead94c2e1f6c2eaff90beaf41e1d134566247921805d9f29b
