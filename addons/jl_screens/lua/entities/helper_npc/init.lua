AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/breen.mdl")
    self:SetHullType(HULL_HUMAN)
    self:SetHullSizeNormal()
    self:SetNPCState(NPC_STATE_SCRIPT)
    self:SetSolid(SOLID_BBOX)
    self:SetUseType(SIMPLE_USE)
    self:CapabilitiesAdd(CAP_ANIMATEDFACE + CAP_TURN_HEAD)
    self:SetMaxYawSpeed(90)
    self:DropToFloor()
end

function ENT:Use(activator, caller)
    if IsValid(activator) and activator:IsPlayer() then
        net.Start("OpenHelperMenu")
        net.Send(activator)
    end
end

if SERVER then
    util.AddNetworkString("OpenHelperMenu")
end