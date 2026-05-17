AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Use(ply)
	ashop.openMenu(ply)
end

function ENT:Initialize()
	self:SetModel(ashop.Config.NPCModel)
	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetNPCState(NPC_STATE_SCRIPT)
	self:SetSolid(SOLID_BBOX)
	self:CapabilitiesAdd(CAP_ANIMATEDFACE + CAP_TURN_HEAD)
	self:SetUseType(SIMPLE_USE)
	self:DropToFloor()
	self:SetMaxYawSpeed(90)

	self:SetUseType(SIMPLE_USE)
end